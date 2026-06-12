import os
from datetime import datetime, timedelta
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.correction_log import CorrectionLog
from fastapi_quanttide_hr.models.mail_message import MailMessage
from fastapi_quanttide_hr.models.pending_queue import PendingQueueItem
from fastapi_quanttide_hr.models.recruitment import Recruitment
from fastapi_quanttide_hr.schemas.messages import (
    ClaimOutboxResponse,
    MailMessageRead,
    OutboxCountResponse,
    OutboxMessageDetail,
    ReplyRequest,
    ReplyResponse,
    SendStatusUpdate,
    TimelineItem,
)

router = APIRouter(tags=["messages"])


# ── Batch C: Candidate messages ──

@router.get("/candidates/{candidate_id}/messages", response_model=list[MailMessageRead])
def list_candidate_messages(candidate_id: int, db: Session = Depends(get_db)):
    c = db.query(Candidate).filter(Candidate.id == candidate_id).first()
    if not c:
        raise HTTPException(404, "Candidate not found")

    msgs = (
        db.query(MailMessage)
        .filter(MailMessage.candidate_id == candidate_id)
        .order_by(MailMessage.occurred_at.desc())
        .all()
    )
    return [
        MailMessageRead(
            id=m.id, candidate_id=m.candidate_id, application_id=m.application_id,
            message_id=m.message_id, sender_email=m.sender_email,
            recipient_email=m.recipient_email, subject=m.subject,
            body=m.body, body_text=m.body_text, attachments_json=m.attachments_json,
            stage_snapshot=m.stage_snapshot, direction=m.direction,
            send_status=m.send_status, occurred_at=str(m.occurred_at),
            created_at=str(m.created_at),
        )
        for m in msgs
    ]


@router.get("/candidates/{candidate_id}/timeline", response_model=list[TimelineItem])
def list_candidate_timeline(candidate_id: int, db: Session = Depends(get_db)):
    c = db.query(Candidate).filter(Candidate.id == candidate_id).first()
    if not c:
        raise HTTPException(404, "Candidate not found")

    items: list[TimelineItem] = []

    # Mail messages
    msgs = (
        db.query(MailMessage)
        .filter(MailMessage.candidate_id == candidate_id)
        .order_by(MailMessage.occurred_at.desc())
        .all()
    )
    for m in msgs:
        direction_label = "收信" if m.direction == "inbound" else "发信"
        items.append(TimelineItem(
            type="message",
            timestamp=str(m.occurred_at),
            description=f"{direction_label}: {m.subject}",
            detail={
                "id": m.id,
                "direction": m.direction,
                "subject": m.subject,
                "stage_snapshot": m.stage_snapshot,
                "send_status": m.send_status,
            },
        ))

    # Correction logs (stage changes)
    apps = db.query(Application).filter(Application.candidate_id == candidate_id).all()
    app_ids = [a.id for a in apps]
    if app_ids:
        logs = (
            db.query(CorrectionLog)
            .filter(
                CorrectionLog.application_id.in_(app_ids),
                CorrectionLog.field_name == "status",
            )
            .order_by(CorrectionLog.created_at.desc())
            .all()
        )
        for log in logs:
            items.append(TimelineItem(
                type="stage_change",
                timestamp=str(log.created_at),
                description=f"HR 调整阶段: {log.original_value or '空'} → {log.corrected_value}",
                detail={
                    "queue_item_id": log.queue_item_id,
                    "original_value": log.original_value,
                    "corrected_value": log.corrected_value,
                },
            ))

    items.sort(key=lambda x: x.timestamp, reverse=True)
    return items


@router.post("/candidates/{candidate_id}/reply", response_model=ReplyResponse, status_code=201)
def create_reply(candidate_id: int, body: ReplyRequest, db: Session = Depends(get_db)):
    c = db.query(Candidate).filter(Candidate.id == candidate_id).first()
    if not c:
        raise HTTPException(404, "Candidate not found")

    app = db.query(Application).filter(Application.id == body.application_id).first()
    if not app or app.candidate_id != candidate_id:
        raise HTTPException(400, "Application not found for this candidate")

    # Look up original inbound message to determine system mailbox (sender)
    original_msg = (
        db.query(MailMessage)
        .filter(
            MailMessage.application_id == body.application_id,
            MailMessage.direction == "inbound",
        )
        .order_by(MailMessage.occurred_at.asc())
        .first()
    )

    _system_mailbox = os.environ.get("QTADMIN_MAILBOX", "")
    sender_email = (
        body.sender_email
        or (original_msg.recipient_email if original_msg else None)
        or _system_mailbox
        or ""
    )

    mm = MailMessage(
        candidate_id=candidate_id,
        application_id=body.application_id,
        sender_email=sender_email,
        recipient_email=body.recipient_email or c.email,
        subject=body.subject,
        body=body.body,
        body_text=body.body_text,
        stage_snapshot=app.status.value,
        direction="outbound",
        send_status="pending",
        occurred_at=func.now(),
    )
    db.add(mm)
    db.commit()
    db.refresh(mm)

    return ReplyResponse(
        id=mm.id,
        subject=mm.subject,
        send_status="pending",
        created_at=str(mm.created_at),
    )


# ── Batch C: Outbox ──

_OUTBOX_CLAIM_LIMIT = 10
_OUTBOX_TIMEOUT_MINUTES = 5
_OUTBOX_MAX_RETRIES = 5


@router.get("/messages/outbox", response_model=OutboxCountResponse)
def outbox_count(db: Session = Depends(get_db)):
    count = (
        db.query(func.count(MailMessage.id))
        .filter(
            MailMessage.direction == "outbound",
            MailMessage.send_status.in_(["pending", "sending"]),
        )
        .scalar()
    )
    return OutboxCountResponse(count=count or 0)


@router.post("/messages/outbox/claim", response_model=ClaimOutboxResponse)
def claim_outbox(db: Session = Depends(get_db)):
    now = datetime.now()

    # Pending messages — apply exponential backoff for retries
    pending_raw = (
        db.query(MailMessage)
        .filter(
            MailMessage.direction == "outbound",
            MailMessage.send_status == "pending",
        )
        .order_by(MailMessage.created_at.asc())
        .all()
    )
    pending = []
    for m in pending_raw:
        if m.retry_count == 0 or m.last_retry_at is None:
            pending.append(m)
        else:
            backoff_minutes = 2 ** (m.retry_count - 1)
            if m.last_retry_at + timedelta(minutes=backoff_minutes) <= now:
                pending.append(m)
    pending = pending[:_OUTBOX_CLAIM_LIMIT]

    expired = (
        db.query(MailMessage)
        .filter(
            MailMessage.direction == "outbound",
            MailMessage.send_status == "sending",
            MailMessage.leased_at < (now - timedelta(minutes=_OUTBOX_TIMEOUT_MINUTES)),
        )
        .limit(_OUTBOX_CLAIM_LIMIT)
        .all()
    )

    to_claim = pending + expired
    for m in to_claim:
        m.send_status = "sending"
        m.lease_id = str(uuid4())
        m.leased_at = now

    db.commit()

    claimed = [
        {
            "id": m.id,
            "lease_id": m.lease_id,
            "subject": m.subject,
            "recipient_email": m.recipient_email,
        }
        for m in to_claim
    ]
    return ClaimOutboxResponse(claimed=claimed)


@router.get("/messages/outbox/{message_id}", response_model=OutboxMessageDetail)
def get_outbox_message(message_id: int, lease_id: str = Query(...), db: Session = Depends(get_db)):
    m = db.query(MailMessage).filter(MailMessage.id == message_id).first()
    if not m:
        raise HTTPException(404, "Message not found")
    if m.lease_id != lease_id:
        raise HTTPException(403, "lease_id mismatch")
    return OutboxMessageDetail(
        id=m.id, lease_id=m.lease_id, subject=m.subject,
        body=m.body, body_text=m.body_text,
        recipient_email=m.recipient_email, attachments_json=m.attachments_json,
    )


# ── Batch D: Send status callback ──

@router.patch("/messages/{message_id}/send-status")
def update_send_status(message_id: int, body: SendStatusUpdate, db: Session = Depends(get_db)):
    m = db.query(MailMessage).filter(MailMessage.id == message_id).first()
    if not m:
        raise HTTPException(404, "Message not found")
    if m.lease_id != body.lease_id:
        raise HTTPException(409, "lease_id mismatch — callback rejected")

    m.send_status = body.send_status
    if body.send_status == "sent":
        m.sent_at = datetime.fromisoformat(body.sent_at) if body.sent_at else func.now()
        m.platform_message_id = body.platform_message_id
    elif body.send_status == "failed":
        now = datetime.now()
        m.retry_count = (m.retry_count or 0) + 1
        m.last_retry_at = now
        m.failure_reason = body.failure_reason
        if m.retry_count >= _OUTBOX_MAX_RETRIES:
            m.send_status = "failed"  # 死信：永久失败
            m.lease_id = None
            m.leased_at = None
        else:
            # 重置为 pending，让下一轮 claim 按指数退避重新领取
            m.send_status = "pending"
            m.lease_id = None
            m.leased_at = None

    db.commit()
    return {"ok": True}
