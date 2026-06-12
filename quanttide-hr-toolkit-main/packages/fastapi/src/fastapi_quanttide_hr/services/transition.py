from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.talent import ALLOWED_STATUSES_FOR_SUB_STAGE, STATUS_TRANSITIONS, Talent, TalentStatus


def transition_application(
    app: Application,
    target: TalentStatus,
    sub_stage: str | None = None,
) -> Application:
    """Transition an Application to a new status.

    Pure Application logic — no Talent awareness.
    Caller is responsible for syncing Talent separately.
    """
    if target not in STATUS_TRANSITIONS.get(app.status, []):
        raise ValueError(f"Cannot transition from {app.status.value} to {target.value}")

    old_status = app.status
    app.status = target

    if target != old_status:
        app.sub_stage = None

    if sub_stage is not None and target in ALLOWED_STATUSES_FOR_SUB_STAGE:
        app.sub_stage = sub_stage

    stage_key = old_status.value
    if stage_key in ("contacted", "evaluating", "interview", "offer"):
        if not (stage_key == "evaluating" and target.value == "exam_sent"):
            if app.stage_results is None:
                app.stage_results = {}
            app.stage_results[stage_key] = "pass" if target.value != "closed" else "fail"

    return app


def sync_talent_from_application(talent: Talent, app: Application) -> None:
    """Copy derived state fields from Application to an existing Talent."""
    talent.status = app.status
    talent.sub_stage = app.sub_stage
    talent.quality = app.quality
    talent.stage_results = app.stage_results
