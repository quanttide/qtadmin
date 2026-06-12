import json
import os

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.mail_message import MailMessage
from fastapi_quanttide_hr.models.pending_queue import PendingQueueItem
from fastapi_quanttide_hr.schemas.pending_queue import (
    IngestItemResult,
    IngestRequest,
    IngestResponse,
)
from fastapi_quanttide_hr.services.classifier import classify
from fastapi_quanttide_hr.services.email_matcher import (
    effective_email,
    has_pending_queue_for_email,
    match_by_email,
)
from fastapi_quanttide_hr.services.material_service import (
    generate_attachment_artifact,
    generate_body_artifact,
)

_DEFAULT_MATERIALS_DIR = os.environ.get("QTADMIN_MATERIALS_DIR", "")

router = APIRouter(prefix="/ingest", tags=["ingest"])


@router.post("", response_model=IngestResponse, status_code=201)
def ingest_items(body: IngestRequest, db: Session = Depends(get_db)):
    # Dual dedup: check both pending_queue and mail_messages
    message_ids = [i.message_id for i in body.items]
    existing_pq = {
        row[0]
        for row in db.query(PendingQueueItem.message_id)
        .filter(PendingQueueItem.message_id.in_(message_ids))
        .all()
    }
    existing_mm = {
        row[0]
        for row in db.query(MailMessage.message_id)
        .filter(MailMessage.message_id.in_(message_ids))
        .all()
    }
    existing = existing_pq | existing_mm

    queued = 0
    skipped = 0
    results: list[IngestItemResult] = []
    errors: list[str] = []
    pending_emails_in_batch: set[str] = set()

    for item in body.items:
        if item.message_id in existing:
            results.append(IngestItemResult(message_id=item.message_id, action="skipped"))
            skipped += 1
            continue

        attachments_list = [a.model_dump() for a in item.attachments] if item.attachments else None
        cl = classify(
            subject=item.subject,
            body_text=item.body_text,
            sender_name=item.sender_name,
            sender_email=item.sender_email,
            db=db,
            attachments=attachments_list,
        )

        if not (cl.merge_result == "existing_auto" and cl.match and cl.match.active_application_id):
            rematch = match_by_email(item.sender_email, db, subject=item.subject)
            if rematch.active_application_id:
                cl.merge_result = "existing_auto"
                cl.match = rematch

        item_email = effective_email(item.extracted_email, item.sender_email)
        if item_email and (
            item_email in pending_emails_in_batch
            or has_pending_queue_for_email(db, item_email)
        ):
            results.append(IngestItemResult(message_id=item.message_id, action="skipped"))
            skipped += 1
            continue

        attachments_json = json.dumps(attachments_list, ensure_ascii=False) if attachments_list else None

        # auto_merged: high confidence + existing active application → create MailMessage immediately
        if cl.merge_result == "existing_auto" and cl.match and cl.match.active_application_id:
            app = db.query(Application).filter(Application.id == cl.match.active_application_id).first()
            mm = MailMessage(
                source_queue_item_id=None,
                candidate_id=cl.match.candidate_id,
                application_id=cl.match.active_application_id,
                message_id=item.message_id,
                sender_email=item.sender_email,
                recipient_email=item.recipient_email,
                subject=item.subject,
                body=item.body,
                body_text=item.body_text,
                attachments_json=attachments_json,
                stage_snapshot=app.status.value if app else None,
                direction="inbound",
                occurred_at=func.now(),
            )
            db.add(mm)
            db.flush()

            if app:
                app.last_message_id = mm.id
                app.last_message_at = mm.occurred_at

            # Generate materials for auto-merged messages
            candidate_id = cl.match.candidate_id
            generate_body_artifact(db, None, candidate_id, item.body, item.body_text, _DEFAULT_MATERIALS_DIR)
            generate_attachment_artifact(db, None, candidate_id, attachments_list, _DEFAULT_MATERIALS_DIR)

            results.append(IngestItemResult(message_id=item.message_id, action="auto_merged"))
            queued += 1
            continue

        # Non-auto-merged: write to pending_queue
        qi = PendingQueueItem(
            source=body.source,
            message_id=item.message_id,
            subject=item.subject,
            sender_name=item.sender_name,
            sender_email=item.sender_email,
            recipient_email=item.recipient_email,
            suggested_status=cl.suggested_status,
            confidence=cl.confidence,
            suggested_recruitment_title=item.suggested_recruitment_title,
            attachments_json=attachments_json,
            body=item.body,
            body_text=item.body_text,
            extracted_name=cl.extracted_name or item.extracted_name,
            extracted_email=item.extracted_email,
            extracted_phone=item.extracted_phone,
            classifier_source=cl.classifier_source,
            classifier_reason=cl.classifier_reason,
            merge_result=cl.merge_result,
        )

        if cl.merge_result == "existing_auto" and cl.match and cl.match.active_application_id:
            qi.hr_status = "auto_merged"

        db.add(qi)
        db.flush()

        candidate_id = cl.match.candidate_id if cl.match and cl.match.candidate_id else None
        generate_body_artifact(db, qi.id, candidate_id, item.body, item.body_text, _DEFAULT_MATERIALS_DIR)
        generate_attachment_artifact(db, qi.id, candidate_id, attachments_list, _DEFAULT_MATERIALS_DIR)

        action = "auto_merged" if qi.hr_status == "auto_merged" else "queued"
        results.append(IngestItemResult(message_id=item.message_id, queue_id=qi.id, action=action))
        queued += 1
        if item_email:
            pending_emails_in_batch.add(item_email)

    db.commit()
    return IngestResponse(
        batch_id=body.batch_id,
        queued=queued,
        skipped=skipped,
        errors=errors,
        items=results,
    )
