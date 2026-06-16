from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.human.database import get_db
from app.human.models.application import Application
from app.human.models.candidate import Candidate
from app.human.models.recruitment import Recruitment
from app.human.models.talent import ALLOWED_STATUSES_FOR_SUB_STAGE, Talent, TalentStatus
from app.human.schemas.recruitment import HeadcountRead, RecruitmentCreate, RecruitmentRead
from app.human.schemas.talent import SubStageUpdate, TalentCreate, TalentRead, TalentTransition, TalentUpdate
from app.human.services.headcount import get_headcount
from app.human.services.transition import sync_talent_from_application, transition_application

router = APIRouter(prefix="/recruitments", tags=["human"])


@router.get("", response_model=list[RecruitmentRead])
def list_recruitments(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return db.query(Recruitment).order_by(Recruitment.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{recruitment_id}", response_model=RecruitmentRead)
def get_recruitment(recruitment_id: int, db: Session = Depends(get_db)):
    r = db.query(Recruitment).filter(Recruitment.id == recruitment_id).first()
    if not r:
        raise HTTPException(404, "Recruitment not found")
    return r


@router.post("", response_model=RecruitmentRead, status_code=201)
def create_recruitment(data: RecruitmentCreate, db: Session = Depends(get_db)):
    r = Recruitment(title=data.title)
    db.add(r)
    db.commit()
    db.refresh(r)
    return r


@router.delete("/{recruitment_id}", status_code=204)
def delete_recruitment(recruitment_id: int, db: Session = Depends(get_db)):
    r = db.query(Recruitment).filter(Recruitment.id == recruitment_id).first()
    if not r:
        raise HTTPException(404, "Recruitment not found")
    db.delete(r)
    db.commit()


@router.get("/{recruitment_id}/headcount", response_model=HeadcountRead)
def get_recruitment_headcount(recruitment_id: int, db: Session = Depends(get_db)):
    _recruitment_exists(recruitment_id, db)
    return get_headcount(db, recruitment_id)


def _recruitment_exists(recruitment_id: int, db: Session) -> None:
    if not db.query(Recruitment).filter(Recruitment.id == recruitment_id).first():
        raise HTTPException(404, "Recruitment not found")


@router.get("/{recruitment_id}/talents", response_model=list[TalentRead])
def list_talents(
    recruitment_id: int,
    status: TalentStatus | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    _recruitment_exists(recruitment_id, db)
    qb = db.query(Talent).filter(Talent.recruitment_id == recruitment_id)
    if status:
        qb = qb.filter(Talent.status == status)
    return qb.order_by(Talent.updated_at.desc()).offset(skip).limit(limit).all()


@router.get("/{recruitment_id}/talents/{talent_id}", response_model=TalentRead)
def get_talent(recruitment_id: int, talent_id: int, db: Session = Depends(get_db)):
    t = db.query(Talent).filter(Talent.id == talent_id, Talent.recruitment_id == recruitment_id).first()
    if not t:
        raise HTTPException(404, "Talent not found")
    return t


@router.post("/{recruitment_id}/talents", response_model=TalentRead, status_code=201)
def create_talent(recruitment_id: int, data: TalentCreate, db: Session = Depends(get_db)):
    recruitment = db.query(Recruitment).filter(Recruitment.id == recruitment_id).first()
    if not recruitment:
        raise HTTPException(404, "Recruitment not found")

    candidate = db.query(Candidate).filter(Candidate.email == data.email).first()
    if not candidate:
        candidate = Candidate(email=data.email, real_name=data.real_name)
        db.add(candidate)
        db.flush()
    app = Application(candidate_id=candidate.id, recruitment_id=recruitment_id, source="manual_debug")
    db.add(app)
    db.flush()

    t = Talent(recruitment_id=recruitment_id, email=data.email, real_name=data.real_name, application_id=app.id)
    db.add(t)

    db.commit()
    db.refresh(t)
    return t


@router.patch("/{recruitment_id}/talents/{talent_id}", response_model=TalentRead)
def update_talent(recruitment_id: int, talent_id: int, data: TalentUpdate, db: Session = Depends(get_db)):
    t = db.query(Talent).filter(Talent.id == talent_id, Talent.recruitment_id == recruitment_id).first()
    if not t:
        raise HTTPException(404, "Talent not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(t, k, v)
    db.commit()
    db.refresh(t)
    return t


@router.post("/{recruitment_id}/talents/{talent_id}/transition", response_model=TalentRead)
def transition_talent(recruitment_id: int, talent_id: int, data: TalentTransition, db: Session = Depends(get_db)):
    t = db.query(Talent).filter(Talent.id == talent_id, Talent.recruitment_id == recruitment_id).first()
    if not t:
        raise HTTPException(404, "Talent not found")

    # Find Application via bidirectional relationship or heuristic fallback
    app = t.application
    if not app:
        candidate = db.query(Candidate).filter(Candidate.email == t.email).first()
        if candidate:
            app = (db.query(Application)
                   .filter(Application.candidate_id == candidate.id,
                           Application.recruitment_id == recruitment_id)
                   .order_by(Application.created_at.desc())
                   .first())

    if not app:
        raise HTTPException(400, "No associated Application found for this Talent")

    try:
        transition_application(app, data.status, data.sub_stage)
    except ValueError as e:
        raise HTTPException(400, str(e))

    sync_talent_from_application(t, app)

    db.commit()
    db.refresh(t)
    return t


@router.patch("/{recruitment_id}/talents/{talent_id}/sub-stage", response_model=TalentRead)
def set_talent_sub_stage(recruitment_id: int, talent_id: int, data: SubStageUpdate, db: Session = Depends(get_db)):
    t = db.query(Talent).filter(Talent.id == talent_id, Talent.recruitment_id == recruitment_id).first()
    if not t:
        raise HTTPException(404, "Talent not found")
    if t.status not in ALLOWED_STATUSES_FOR_SUB_STAGE:
        raise HTTPException(400, f"Cannot set sub_stage for status {t.status.value}")
    t.sub_stage = data.sub_stage
    db.commit()
    db.refresh(t)
    return t


@router.delete("/{recruitment_id}/talents/{talent_id}", status_code=204)
def delete_talent(recruitment_id: int, talent_id: int, db: Session = Depends(get_db)):
    t = db.query(Talent).filter(Talent.id == talent_id, Talent.recruitment_id == recruitment_id).first()
    if not t:
        raise HTTPException(404, "Talent not found")
    db.delete(t)
    db.commit()
