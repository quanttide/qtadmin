from sqlalchemy.orm import Session

from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.talent import TalentStatus


def get_headcount(db: Session, recruitment_id: int) -> dict:
    base = db.query(Application).filter(Application.recruitment_id == recruitment_id)
    total_offers = base.filter(Application.status == TalentStatus.OFFER).count()
    accepted = base.filter(
        Application.status == TalentStatus.OFFER,
        Application.sub_stage == "accepted",
    ).count()
    return {
        "recruitment_id": recruitment_id,
        "total_offers": total_offers,
        "accepted": accepted,
    }
