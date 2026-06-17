from datetime import datetime

from pydantic import BaseModel


class PositionCreate(BaseModel):
    name: str
    department: str | None = None
    level: str | None = None
    description: str | None = None
    responsibilities: str | None = None
    requirements: str | None = None


class PositionUpdate(BaseModel):
    name: str | None = None
    department: str | None = None
    level: str | None = None
    description: str | None = None
    responsibilities: str | None = None
    requirements: str | None = None
    active: bool | None = None


class PositionRead(BaseModel):
    id: int
    name: str
    department: str | None
    level: str | None
    description: str | None
    responsibilities: str | None
    requirements: str | None
    active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
