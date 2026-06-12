from sqlalchemy.orm import Session

from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.correction_log import CorrectionLog
from fastapi_quanttide_hr.models.pending_queue import PendingQueueItem
from fastapi_quanttide_hr.schemas.export import TrainingPairItem


def get_training_pairs(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> list[TrainingPairItem]:
    rows = (
        db.query(Application, PendingQueueItem)
        .join(PendingQueueItem, Application.source_queue_item_id == PendingQueueItem.id)
        .filter(Application.source_queue_item_id.isnot(None))
        .order_by(Application.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    result = []
    for app, queue_item in rows:
        corrections = (
            db.query(CorrectionLog)
            .filter(CorrectionLog.queue_item_id == queue_item.id)
            .all()
        )
        corrected_fields = [c.field_name for c in corrections]

        candidate = db.query(Candidate).filter(Candidate.id == app.candidate_id).first()

        result.append(TrainingPairItem(
            queue_id=queue_item.id,
            subject=queue_item.subject,
            body=queue_item.body,
            sender_email=queue_item.sender_email,
            suggested_status=queue_item.suggested_status,
            final_status=app.status.value if app.status else None,
            final_real_name=candidate.real_name if candidate else None,
            final_email=candidate.email if candidate else None,
            hr_action=queue_item.hr_status,
            corrected_fields=corrected_fields,
        ))

    return result


def count_training_pairs(db: Session) -> int:
    return (
        db.query(Application)
        .filter(Application.source_queue_item_id.isnot(None))
        .count()
    )
