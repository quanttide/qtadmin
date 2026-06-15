from datetime import datetime

from sqlalchemy import DateTime, String, Text, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.human.database import Base


class PendingQueueItem(Base):
    __tablename__ = "pending_queue"
    __table_args__ = (UniqueConstraint("message_id"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    source: Mapped[str] = mapped_column(String(50), default="feishu_api")
    message_id: Mapped[str] = mapped_column(String(255))
    subject: Mapped[str] = mapped_column(String(500))
    sender_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    sender_email: Mapped[str] = mapped_column(String(255))
    recipient_email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    suggested_status: Mapped[str | None] = mapped_column(String(50), nullable=True)
    confidence: Mapped[str] = mapped_column(String(20), default="low")
    suggested_recruitment_title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    attachments_json: Mapped[str | None] = mapped_column(Text, nullable=True)
    body: Mapped[str | None] = mapped_column(Text, nullable=True)
    body_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    extracted_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    extracted_email: Mapped[str | None] = mapped_column(Text, nullable=True)
    extracted_phone: Mapped[str | None] = mapped_column(Text, nullable=True)
    classifier_source: Mapped[str | None] = mapped_column(String(30), nullable=True)
    classifier_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    merge_result: Mapped[str | None] = mapped_column(String(20), nullable=True)
    hr_status: Mapped[str] = mapped_column(String(20), default="pending")
    hr_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())
