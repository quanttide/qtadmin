from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, JSON, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from fastapi_quanttide_hr.database import Base
from fastapi_quanttide_hr.models.talent import TalentStatus


class Application(Base):
    __tablename__ = "applications"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    candidate_id: Mapped[int] = mapped_column(ForeignKey("candidates.id"), index=True)
    recruitment_id: Mapped[int] = mapped_column(ForeignKey("recruitments.id"), index=True)
    source_queue_item_id: Mapped[int | None] = mapped_column(ForeignKey("pending_queue.id"), nullable=True, index=True)

    last_message_id: Mapped[int | None] = mapped_column(
        ForeignKey("mail_messages.id"), nullable=True, index=True
    )
    last_message_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    candidate: Mapped["Candidate"] = relationship("Candidate")
    talent: Mapped["Talent | None"] = relationship("Talent", back_populates="application", uselist=False)

    status: Mapped[TalentStatus] = mapped_column(Enum(TalentStatus), default=TalentStatus.NEW, index=True)
    sub_stage: Mapped[str | None] = mapped_column(String(30), nullable=True)
    quality: Mapped[str] = mapped_column(String(10), default="normal")
    stage_results: Mapped[dict | None] = mapped_column(JSON, nullable=True, default=None)
    source: Mapped[str] = mapped_column(String(50), default="manual_seed")

    pooled_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    deactivated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())
