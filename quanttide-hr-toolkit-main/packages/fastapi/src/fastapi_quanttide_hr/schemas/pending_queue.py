from pydantic import BaseModel


class IngestAttachment(BaseModel):
    filename: str
    size: int
    mime_type: str | None = None
    message_attachment_id: str | None = None
    storage_path: str | None = None


class IngestItem(BaseModel):
    message_id: str
    subject: str
    sender_name: str | None = None
    sender_email: str
    recipient_email: str | None = None
    suggested_status: str | None = None
    confidence: str = "low"
    suggested_recruitment_title: str | None = None
    attachments: list[IngestAttachment] | None = None
    body: str | None = None
    body_text: str | None = None
    extracted_name: str | None = None
    extracted_email: str | None = None
    extracted_phone: str | None = None
    classifier_source: str | None = None
    classifier_reason: str | None = None


class IngestRequest(BaseModel):
    source: str = "feishu_api"
    batch_id: str | None = None
    items: list[IngestItem]


class IngestItemResult(BaseModel):
    message_id: str
    queue_id: int | None = None
    action: str  # "queued" | "skipped"


class IngestResponse(BaseModel):
    batch_id: str | None = None
    queued: int = 0
    skipped: int = 0
    errors: list[str] = []
    items: list[IngestItemResult]


class QueueItemRead(BaseModel):
    queue_id: int
    message_id: str
    subject: str
    sender_name: str | None = None
    sender_email: str = ""
    recipient_email: str | None = None
    extracted_name: str | None = None
    extracted_email: str | None = None
    suggested_status: str | None = None
    confidence: str = "low"
    suggested_recruitment_title: str | None = None
    attachments_json: str | None = None
    body: str | None = None
    body_text: str | None = None
    hr_status: str = "pending"
    hr_notes: str | None = None
    classifier_source: str | None = None
    classifier_reason: str | None = None
    merge_result: str | None = None
    created_at: str = ""

    model_config = {"from_attributes": True}


class QueueListResponse(BaseModel):
    items: list[QueueItemRead]
    total: int


class ConfirmRequest(BaseModel):
    action: str = "confirmed"  # "confirmed" | "adjusted"
    status: str | None = None
    real_name: str = ""
    email: str = ""
    recruitment_title: str | None = None


class ConfirmResponse(BaseModel):
    queue_id: int
    action: str
    talent_id: int | None = None


class IgnoreRequest(BaseModel):
    action: str = "ignored"
