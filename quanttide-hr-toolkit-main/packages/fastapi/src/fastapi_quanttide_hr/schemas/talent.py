from datetime import datetime

from pydantic import BaseModel

from fastapi_quanttide_hr.models.talent import TalentStatus


class TalentCreate(BaseModel):
    email: str
    real_name: str
    auto_screening_result: str | None = None


class TalentUpdate(BaseModel):
    quality: str | None = None

    model_config = {"extra": "forbid"}


class TalentTransition(BaseModel):
    status: TalentStatus
    sub_stage: str | None = None


class SubStageUpdate(BaseModel):
    sub_stage: str | None = None


class TalentRead(BaseModel):
    id: int
    recruitment_id: int
    email: str
    real_name: str
    status: TalentStatus
    sub_stage: str | None = None
    quality: str = "normal"
    stage_results: dict | None = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
