from datetime import datetime

from pydantic import BaseModel


class RecruitmentCreate(BaseModel):
    title: str = ""


class RecruitmentRead(BaseModel):
    id: int
    title: str = ""
    status: str | None = None
    deadline: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class HeadcountRead(BaseModel):
    recruitment_id: int
    total_offers: int
    accepted: int
