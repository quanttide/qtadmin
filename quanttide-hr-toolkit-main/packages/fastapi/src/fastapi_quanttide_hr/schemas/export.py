from pydantic import BaseModel


class TrainingPairItem(BaseModel):
    queue_id: int
    subject: str
    body: str | None = None
    sender_email: str
    suggested_status: str | None = None
    final_status: str | None = None
    final_real_name: str | None = None
    final_email: str | None = None
    hr_action: str | None = None
    corrected_fields: list[str] = []


class TrainingPairResponse(BaseModel):
    items: list[TrainingPairItem]
    total: int
