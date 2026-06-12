import json
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from fastapi_quanttide_hr.models.talent import TalentStatus


class ApplicationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    candidate_id: int
    recruitment_id: int
    status: TalentStatus
    sub_stage: str | None = None
    quality: str = "normal"
    stage_results: dict | None = None
    source: str = "manual_seed"
    pooled_at: datetime | None = None
    deactivated_at: datetime | None = None
    last_message_id: int | None = None
    last_message_at: datetime | None = None
    created_at: datetime
    updated_at: datetime


class ApplicationListQuery(BaseModel):
    status: TalentStatus | None = None
    candidate_id: int | None = Field(default=None, ge=1)
    recruitment_id: int | None = Field(default=None, ge=1)
    pooled: bool | None = None
    skip: int = Field(default=0, ge=0)
    limit: int = Field(default=100, ge=1, le=500)


class ApplicationTransitionRequest(BaseModel):
    status: TalentStatus
    sub_stage: str | None = None


class UnpoolRequest(BaseModel):
    recruitment_id: int = Field(..., ge=1)


class PoolItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    candidate_id: int
    recruitment_id: int
    status: TalentStatus
    sub_stage: str | None = None
    quality: str = "normal"
    stage_results: dict | None = None
    source: str = "manual_seed"
    pooled_at: datetime | None = None
    deactivated_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    candidate_email: str = ""
    candidate_name: str = ""


class AttachmentInfo(BaseModel):
    filename: str
    size: int
    mime_type: str | None = None
    message_attachment_id: str | None = None
    storage_path: str | None = None


class QueueItemMaterials(BaseModel):
    subject: str
    sender_name: str | None = None
    sender_email: str
    body: str | None = None
    body_text: str | None = None
    attachments: list[AttachmentInfo] = []


class ResumeParseResult(BaseModel):
    status: str  # "success" | "failure" | "not_applicable"
    text_excerpt: str | None = None
    error: str | None = None
    name: str | None = None
    phone: str | None = None
    email: str | None = None


class ApplicationMaterialsRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    application: ApplicationRead
    candidate: dict
    queue_item: QueueItemMaterials | None = None
    resume_parse: ResumeParseResult | None = None
    classifier_info: dict | None = None
    corrections: list[dict] | None = None
