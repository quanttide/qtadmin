from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from sqlalchemy import func

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.models.mail_message import MailMessage
from fastapi_quanttide_hr.models.pending_queue import PendingQueueItem
from fastapi_quanttide_hr.models.recruitment import Recruitment
from fastapi_quanttide_hr.models.talent import Talent, TalentStatus
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.correction_log import CorrectionLog
from fastapi_quanttide_hr.services.email_matcher import (
    effective_email,
    find_active_application,
    find_candidate_by_email,
)
from fastapi_quanttide_hr.services.transition import transition_application
from fastapi_quanttide_hr.schemas.pending_queue import (
    ConfirmRequest,
    ConfirmResponse,
    IgnoreRequest,
    QueueItemRead,
    QueueListResponse,
)

router = APIRouter(prefix="/queue", tags=["queue"])


def _dedupe_queue_by_email(items: list[PendingQueueItem]) -> list[PendingQueueItem]:
    """Keep the newest queue row per candidate email."""
    seen: set[str] = set()
    deduped: list[PendingQueueItem] = []
    for item in items:
        email_key = effective_email(item.extracted_email, item.sender_email)
        if email_key and email_key in seen:
            continue
        if email_key:
            seen.add(email_key)
        deduped.append(item)
    return deduped


@router.get("", response_model=QueueListResponse)
def list_queue(
    hr_status: str | None = None,
    confidence: str | None = None,
    source: str | None = None,
    merge_result: str | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    qb = db.query(PendingQueueItem)
    if hr_status:
        qb = qb.filter(PendingQueueItem.hr_status == hr_status)
    if confidence:
        qb = qb.filter(PendingQueueItem.confidence == confidence)
    if source:
        qb = qb.filter(PendingQueueItem.source == source)
    if merge_result:
        qb = qb.filter(PendingQueueItem.merge_result == merge_result)

    if hr_status == "pending":
        all_pending = qb.order_by(PendingQueueItem.created_at.desc()).all()
        unique_pending = _dedupe_queue_by_email(all_pending)
        total = len(unique_pending)
        items = unique_pending[skip : skip + limit]
    else:
        all_items = qb.order_by(PendingQueueItem.created_at.desc()).all()
        unique_items = _dedupe_queue_by_email(all_items)
        total = len(unique_items)
        items = unique_items[skip : skip + limit]

    return QueueListResponse(
        items=[QueueItemRead(
            queue_id=item.id,
            message_id=item.message_id,
            subject=item.subject,
            sender_name=item.sender_name,
            sender_email=item.sender_email,
            recipient_email=item.recipient_email,
            extracted_name=item.extracted_name,
            extracted_email=item.extracted_email,
            suggested_status=item.suggested_status,
            confidence=item.confidence,
            suggested_recruitment_title=item.suggested_recruitment_title,
            attachments_json=item.attachments_json,
            body=item.body,
            body_text=item.body_text,
            hr_status=item.hr_status,
            hr_notes=item.hr_notes,
            classifier_source=item.classifier_source,
            classifier_reason=item.classifier_reason,
            merge_result=item.merge_result,
            created_at=str(item.created_at),
        ) for item in items],
        total=total,
    )


@router.patch("/{queue_id}/confirm", response_model=ConfirmResponse)
def confirm_queue_item(queue_id: int, body: ConfirmRequest, db: Session = Depends(get_db)):
    item = db.query(PendingQueueItem).filter(PendingQueueItem.id == queue_id).first()
    if not item:
        raise HTTPException(404, "Queue item not found")
    if item.hr_status != "pending":
        raise HTTPException(409, "Queue item already processed")

    if not body.recruitment_title:
        raise HTTPException(400, "recruitment_title is required")

    effective_email_raw = body.email or item.extracted_email or item.sender_email
    effective_real_name = body.real_name or item.extracted_name or item.sender_name or "未知"

    candidate = find_candidate_by_email(db, effective_email_raw)
    if not candidate:
        candidate = Candidate(
            email=effective_email_raw,
            real_name=effective_real_name,
        )
        db.add(candidate)
        db.flush()
    elif effective_real_name and effective_real_name != "未知":
        candidate.real_name = effective_real_name

    existing_app = find_active_application(db, candidate.id)
    merged = existing_app is not None

    if merged:
        app = existing_app
        talent = db.query(Talent).filter(Talent.application_id == app.id).first()
        if not talent:
            talent = Talent(
                recruitment_id=app.recruitment_id,
                email=candidate.email,
                real_name=candidate.real_name,
                status=app.status,
                sub_stage=app.sub_stage,
                quality=app.quality,
                stage_results=app.stage_results,
                application_id=app.id,
            )
            db.add(talent)
            db.flush()
    else:
        recruitment = db.query(Recruitment).filter(Recruitment.title == body.recruitment_title).first()
        if not recruitment:
            recruitment = Recruitment(title=body.recruitment_title)
            db.add(recruitment)
            db.flush()

        app = Application(
            candidate_id=candidate.id,
            recruitment_id=recruitment.id,
            source="feishu_api",
            source_queue_item_id=item.id,
        )
        db.add(app)
        db.flush()

        talent = Talent(
            recruitment_id=recruitment.id,
            email=candidate.email,
            real_name=candidate.real_name,
            status=app.status,
            sub_stage=app.sub_stage,
            quality=app.quality,
            stage_results=app.stage_results,
            application_id=app.id,
        )
        db.add(talent)
        db.flush()

    item.hr_status = body.action
    db.flush()

    target_status = body.status or item.suggested_status or "new"
    if target_status and target_status != app.status.value:
        status_order = [
            "new", "contacted", "exam_sent", "exam_received",
            "evaluating", "interview", "offer", "closed",
        ]
        try:
            current_idx = status_order.index(app.status.value)
            target_idx = status_order.index(target_status)
            for s in status_order[current_idx + 1 : target_idx + 1]:
                transition_application(app, TalentStatus(s))
            talent.status = app.status
            talent.sub_stage = app.sub_stage
            talent.stage_results = app.stage_results
        except (ValueError, KeyError):
            pass

    corrections = []
    if body.status and body.status != item.suggested_status:
        corrections.append(("status", item.suggested_status, body.status))
    if body.email and item.sender_email and body.email != item.sender_email:
        corrections.append(("email", item.sender_email, body.email))
    if body.real_name and item.sender_name and body.real_name != item.sender_name:
        corrections.append(("real_name", item.sender_name, body.real_name))
    if body.email and item.extracted_email and body.email != item.extracted_email:
        corrections.append(("email", item.extracted_email, body.email))
    if body.real_name and item.extracted_name and body.real_name != item.extracted_name:
        corrections.append(("real_name", item.extracted_name, body.real_name))
    for field_name, original, corrected in corrections:
        db.add(CorrectionLog(
            queue_item_id=item.id,
            application_id=app.id,
            field_name=field_name,
            original_value=str(original) if original else None,
            corrected_value=str(corrected) if corrected else None,
        ))

    mm = MailMessage(
        source_queue_item_id=item.id,
        candidate_id=candidate.id,
        application_id=app.id,
        message_id=item.message_id,
        sender_email=item.sender_email,
        recipient_email=item.recipient_email,
        subject=item.subject,
        body=item.body,
        body_text=item.body_text,
        attachments_json=item.attachments_json,
        stage_snapshot=app.status.value,
        direction="inbound",
        occurred_at=func.now(),
    )
    db.add(mm)
    db.flush()

    app.last_message_id = mm.id
    app.last_message_at = mm.occurred_at

    db.commit()
    db.refresh(talent)

    return ConfirmResponse(queue_id=item.id, action=body.action, talent_id=talent.id)


@router.patch("/{queue_id}/ignore", response_model=ConfirmResponse)
def ignore_queue_item(queue_id: int, body: IgnoreRequest, db: Session = Depends(get_db)):
    item = db.query(PendingQueueItem).filter(PendingQueueItem.id == queue_id).first()
    if not item:
        raise HTTPException(404, "Queue item not found")

    item.hr_status = "ignored"
    db.commit()

    return ConfirmResponse(queue_id=item.id, action="ignored")


@router.get("/by-email")
def get_queue_by_email(email: str, db: Session = Depends(get_db)):
    """按候选人邮箱查询关联的飞书邮件详情。"""
    item = db.query(PendingQueueItem).filter(
        (PendingQueueItem.sender_email == email)
    ).order_by(PendingQueueItem.created_at.desc()).first()
    if not item:
        return {"found": False}
    return {"found": True, "item": {
        "subject": item.subject,
        "sender_name": item.sender_name,
        "sender_email": item.sender_email,
        "suggested_status": item.suggested_status,
        "confidence": item.confidence,
        "hr_status": item.hr_status,
        "hr_notes": item.hr_notes,
        "created_at": str(item.created_at),
    }}


@router.get("/stats")
def queue_stats(db: Session = Depends(get_db)):
    stats: dict[str, int] = {}
    for status in ("pending", "confirmed", "ignored"):
        rows = (
            db.query(PendingQueueItem.extracted_email, PendingQueueItem.sender_email)
            .filter(PendingQueueItem.hr_status == status)
            .all()
        )
        unique = {
            effective_email(ext, snd)
            for ext, snd in rows
            if effective_email(ext, snd)
        }
        if unique:
            stats[status] = len(unique)
    return stats or {"pending": 0, "confirmed": 0, "ignored": 0}
