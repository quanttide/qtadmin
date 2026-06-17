from datetime import datetime

from pydantic import BaseModel


class UserProfileCreate(BaseModel):
    real_name: str
    email: str
    phone: str | None = None
    school: str | None = None
    major: str | None = None
    avatar_url: str | None = None
    resume_url: str | None = None


class UserProfileUpdate(BaseModel):
    real_name: str | None = None
    email: str | None = None
    phone: str | None = None
    school: str | None = None
    major: str | None = None
    avatar_url: str | None = None
    resume_url: str | None = None


class UserProfileRead(BaseModel):
    id: int
    real_name: str
    email: str
    phone: str | None
    school: str | None
    major: str | None
    avatar_url: str | None
    resume_url: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
