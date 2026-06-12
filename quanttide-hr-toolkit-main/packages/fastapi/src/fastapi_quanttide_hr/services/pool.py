from datetime import datetime, timezone

from sqlalchemy.orm import Session, joinedload

from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.talent import TalentStatus


def pool_application(db: Session, application_id: int) -> Application | None:
    app = db.query(Application).filter(Application.id == application_id).first()
    if not app:
        return None
    if app.pooled_at is not None:
        return app
    now = datetime.now(timezone.utc)
    app.pooled_at = now
    app.deactivated_at = now
    app.status = TalentStatus.CLOSED
    app.sub_stage = None
    db.commit()
    db.refresh(app)
    return app


def unpool_application(db: Session, application_id: int, recruitment_id: int) -> Application | None:
    original = db.query(Application).filter(Application.id == application_id).first()
    if not original:
        return None
    new_app = Application(
        candidate_id=original.candidate_id,
        recruitment_id=recruitment_id,
        source=original.source,
    )
    db.add(new_app)
    db.commit()
    db.refresh(new_app)
    return new_app


def get_pooled_applications(db: Session, skip: int = 0, limit: int = 100) -> list[Application]:
    return (
        db.query(Application)
        .options(joinedload(Application.candidate))
        .filter(Application.pooled_at.isnot(None))
        .order_by(Application.pooled_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
