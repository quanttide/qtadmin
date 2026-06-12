from sqlalchemy.orm import Session, joinedload

from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.talent import TalentStatus


def get_pipeline(db: Session) -> dict:
    stages = {}
    total = 0
    for status in TalentStatus:
        apps = (
            db.query(Application)
            .options(joinedload(Application.candidate))
            .filter(Application.status == status, Application.deactivated_at.is_(None))
            .order_by(Application.updated_at.desc())
            .all()
        )
        seen_candidates: set[int] = set()
        cards = []
        for app in apps:
            if app.candidate_id in seen_candidates:
                continue
            seen_candidates.add(app.candidate_id)
            cards.append(_application_to_card(app))
        stages[status.value] = cards
        total += len(cards)

    need_attention = len(stages.get("exam_received", [])) + len(stages.get("evaluating", []))
    return {
        "stages": stages,
        "summary": {
            "total": total,
            "by_stage": {s.value: len(stages.get(s.value, [])) for s in TalentStatus},
            "need_attention": need_attention,
        },
    }


def _application_to_card(a: Application) -> dict:
    return {
        "id": a.id,
        "candidate_id": a.candidate_id,
        "email": a.candidate.email,
        "real_name": a.candidate.real_name,
        "recruitment_id": a.recruitment_id,
        "status": a.status.value,
        "sub_stage": a.sub_stage,
        "quality": a.quality,
        "stage_results": a.stage_results,
        "created_at": a.created_at.isoformat(),
        "updated_at": a.updated_at.isoformat(),
    }
