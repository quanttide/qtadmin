from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.human.database import get_db
from app.human.models.application import Application
from app.human.models.candidate import Candidate
from app.human.models.talent import Talent
from app.human.schemas.application import ApplicationRead
from app.human.schemas.candidate import CandidateRead, CandidateUpdate

router = APIRouter(prefix="/candidates", tags=["human"])


@router.get("", response_model=list[CandidateRead])
def list_candidates(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return db.query(Candidate).order_by(Candidate.created_at.desc()).offset(skip).limit(limit).all()


@router.patch("/{candidate_id}", response_model=CandidateRead)
def update_candidate(candidate_id: int, data: CandidateUpdate, db: Session = Depends(get_db)):
    c = db.query(Candidate).filter(Candidate.id == candidate_id).first()
    if not c:
        raise HTTPException(404, "Candidate not found")

    old_email = c.email
    for field, val in data.model_dump(exclude_unset=True).items():
        setattr(c, field, val)
    db.flush()

    # Sync changes to associated Talents
    apps = db.query(Application).filter(Application.candidate_id == candidate_id).all()
    for app in apps:
        t = db.query(Talent).filter(Talent.application_id == app.id).first()
        if t:
            if data.email is not None:
                t.email = data.email
            if data.real_name is not None:
                t.real_name = data.real_name
        else:
            # Legacy null application_id — fall back to email match
            t = db.query(Talent).filter(Talent.email == old_email).first()
            if t:
                if data.email is not None:
                    t.email = data.email
                if data.real_name is not None:
                    t.real_name = data.real_name

    db.commit()
    db.refresh(c)
    return c


@router.get("/{candidate_id}/applications", response_model=list[ApplicationRead])
def get_candidate_applications(candidate_id: int, db: Session = Depends(get_db)):
    c = db.query(Candidate).filter(Candidate.id == candidate_id).first()
    if not c:
        raise HTTPException(404, "Candidate not found")
    return db.query(Application).filter(Application.candidate_id == candidate_id).all()
