from datetime import datetime

from pydantic import BaseModel, ConfigDict


class CandidateUpdate(BaseModel):
    email: str | None = None
    real_name: str | None = None
    phone: str | None = None


class CandidateRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    real_name: str
    phone: str | None = None
    created_at: datetime
