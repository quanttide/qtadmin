from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from fastapi_quanttide_hr.database import Base


class MailMessage(Base):
    __tablename__ = "mail_messages"
    __table_args__ = (UniqueConstraint("message_id", name="uq_mail_messages_message_id"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    source_queue_item_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("pending_queue.id"), nullable=True, index=True
    )
    candidate_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("candidates.id"), nullable=True, index=True
    )
    application_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("applications.id"), nullable=True, index=True
    )
    message_id: Mapped[str | None] = mapped_column(
        String(255), nullable=True
    )
    platform_message_id: Mapped[str | None] = mapped_column(String(255), nullable=True)

    sender_email: Mapped[str] = mapped_column(String(255))
    recipient_email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    subject: Mapped[str] = mapped_column(String(500))
    body: Mapped[str | None] = mapped_column(Text, nullable=True)
    body_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    attachments_json: Mapped[str | None] = mapped_column(Text, nullable=True)

    stage_snapshot: Mapped[str | None] = mapped_column(String(50), nullable=True)
    direction: Mapped[str] = mapped_column(String(20), default="inbound")

    send_status: Mapped[str | None] = mapped_column(String(20), nullable=True)
    lease_id: Mapped[str | None] = mapped_column(String(100), nullable=True)
    leased_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    retry_count: Mapped[int] = mapped_column(Integer, default=0)
    last_retry_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    failure_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    sent_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    occurred_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
