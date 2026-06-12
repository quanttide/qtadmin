from datetime import datetime

from pydantic import BaseModel


class AttachmentInfo(BaseModel):
    filename: str
    size: int = 0
    mime_type: str | None = None
    message_attachment_id: str | None = None
    storage_path: str | None = None


class MailMessageRead(BaseModel):
    id: int
    candidate_id: int | None = None
    application_id: int | None = None
    message_id: str | None = None
    sender_email: str
    recipient_email: str | None = None
    subject: str
    body: str | None = None
    body_text: str | None = None
    attachments_json: str | None = None
    stage_snapshot: str | None = None
    direction: str
    send_status: str | None = None
    occurred_at: str = ""
    created_at: str = ""

    model_config = {"from_attributes": True}


class ReplyRequest(BaseModel):
    application_id: int
    subject: str
    body: str | None = None
    body_text: str | None = None
    sender_email: str | None = None
    recipient_email: str | None = None


class ReplyResponse(BaseModel):
    id: int
    direction: str = "outbound"
    send_status: str = "pending"
    subject: str
    created_at: str = ""


class OutboxCountResponse(BaseModel):
    count: int


class ClaimOutboxResponse(BaseModel):
    claimed: list[dict]


class OutboxMessageDetail(BaseModel):
    id: int
    lease_id: str
    subject: str
    body: str | None = None
    body_text: str | None = None
    recipient_email: str | None = None
    attachments_json: str | None = None


class SendStatusUpdate(BaseModel):
    lease_id: str
    send_status: str  # "sent" | "failed"
    sent_at: str | None = None
    platform_message_id: str | None = None
    failure_reason: str | None = None


class TimelineItem(BaseModel):
    type: str  # "message" | "stage_change"
    timestamp: str
    description: str
    detail: dict | None = None
