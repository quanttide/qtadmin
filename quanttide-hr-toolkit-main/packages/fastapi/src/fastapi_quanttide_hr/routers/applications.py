import json

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.correction_log import CorrectionLog
from fastapi_quanttide_hr.models.pending_queue import PendingQueueItem
from fastapi_quanttide_hr.models.talent import Talent, TalentStatus
from fastapi_quanttide_hr.schemas.application import (
    ApplicationMaterialsRead,
    ApplicationRead,
    ApplicationTransitionRequest,
    AttachmentInfo,
    QueueItemMaterials,
    UnpoolRequest,
)
from fastapi_quanttide_hr.services.pool import pool_application, unpool_application
from fastapi_quanttide_hr.services.transition import sync_talent_from_application, transition_application

router = APIRouter(prefix="/applications", tags=["applications"])


@router.get("", response_model=list[ApplicationRead])
def list_applications(
    status: TalentStatus | None = None,
    candidate_id: int | None = Query(default=None, ge=1),
    recruitment_id: int | None = Query(default=None, ge=1),
    pooled: bool | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    qb = db.query(Application)
    if status:
        qb = qb.filter(Application.status == status)
    if candidate_id:
        qb = qb.filter(Application.candidate_id == candidate_id)
    if recruitment_id:
        qb = qb.filter(Application.recruitment_id == recruitment_id)
    if pooled is True:
        qb = qb.filter(Application.pooled_at.isnot(None))
    elif pooled is False:
        qb = qb.filter(Application.pooled_at.is_(None))
    return qb.order_by(Application.updated_at.desc()).offset(skip).limit(limit).all()


@router.post("/{application_id}/transition", response_model=ApplicationRead)
def transition_application_endpoint(application_id: int, body: ApplicationTransitionRequest, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == application_id).first()
    if not app:
        raise HTTPException(404, "Application not found")

    try:
        transition_application(app, body.status, body.sub_stage)
    except ValueError as e:
        raise HTTPException(400, str(e))

    # Sync corresponding Talent
    talent = app.talent
    if not talent:
        talent = db.query(Talent).filter(
            Talent.recruitment_id == app.recruitment_id,
            Talent.email == app.candidate.email,
        ).first()
    if talent:
        sync_talent_from_application(talent, app)

    db.commit()
    db.refresh(app)
    return app


@router.post("/{application_id}/pool", response_model=ApplicationRead)
def pool_application_endpoint(application_id: int, db: Session = Depends(get_db)):
    app = pool_application(db, application_id)
    if not app:
        raise HTTPException(404, "Application not found")
    return app


@router.post("/{application_id}/unpool", response_model=ApplicationRead, status_code=201)
def unpool_application_endpoint(application_id: int, body: UnpoolRequest, db: Session = Depends(get_db)):
    original = db.query(Application).filter(Application.id == application_id).first()
    if not original:
        raise HTTPException(404, "Application not found")
    if original.pooled_at is None:
        raise HTTPException(400, "Application is not pooled")
    new_app = unpool_application(db, application_id, body.recruitment_id)
    return new_app


@router.get("/{application_id}/materials", response_model=ApplicationMaterialsRead)
def get_application_materials(application_id: int, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == application_id).first()
    if not app:
        raise HTTPException(404, "Application not found")

    candidate = db.query(Candidate).filter(Candidate.id == app.candidate_id).first()

    queue_item = None
    resume_parse = None
    classifier_info = None
    corrections = None
    if app.source_queue_item_id:
        qi = db.query(PendingQueueItem).filter(PendingQueueItem.id == app.source_queue_item_id).first()
        if qi:
            attachments = []
            if qi.attachments_json:
                try:
                    raw = json.loads(qi.attachments_json)
                    if isinstance(raw, list):
                        attachments = [AttachmentInfo(**a) for a in raw]
                except (json.JSONDecodeError, TypeError):
                    pass

            queue_item = QueueItemMaterials(
                subject=qi.subject,
                sender_name=qi.sender_name,
                sender_email=qi.sender_email,
                body=qi.body,
                body_text=qi.body_text,
                attachments=attachments,
            )

            # Classifier info
            if qi.classifier_source or qi.classifier_reason:
                classifier_info = {
                    "classifier_source": qi.classifier_source,
                    "classifier_reason": qi.classifier_reason,
                }

            # Corrections linked to this application
            corr_logs = db.query(CorrectionLog).filter(
                CorrectionLog.application_id == app.id
            ).all()
            if corr_logs:
                corrections = [
                    {
                        "field_name": log.field_name,
                        "original_value": log.original_value,
                        "corrected_value": log.corrected_value,
                        "created_at": str(log.created_at),
                    }
                    for log in corr_logs
                ]

            # Attachments available for preview — no server-side parsing needed
            resume_parse = None

    return ApplicationMaterialsRead(
        application=app,
        candidate={
            "id": candidate.id,
            "real_name": candidate.real_name,
            "email": candidate.email,
        },
        queue_item=queue_item,
        resume_parse=resume_parse,
        classifier_info=classifier_info,
        corrections=corrections,
    )
