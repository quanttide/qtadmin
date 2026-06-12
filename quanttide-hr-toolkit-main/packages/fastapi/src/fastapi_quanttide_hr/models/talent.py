from __future__ import annotations

import enum
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, JSON, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from fastapi_quanttide_hr.database import Base


class TalentStatus(str, enum.Enum):
    NEW = "new"
    CONTACTED = "contacted"
    EXAM_SENT = "exam_sent"
    EXAM_RECEIVED = "exam_received"
    EVALUATING = "evaluating"
    INTERVIEW = "interview"
    OFFER = "offer"
    CLOSED = "closed"


# 允许设置子阶段的主状态集合
ALLOWED_STATUSES_FOR_SUB_STAGE = {
    TalentStatus.CONTACTED,
    TalentStatus.EXAM_SENT,
    TalentStatus.EVALUATING,
    TalentStatus.INTERVIEW,
    TalentStatus.OFFER,
}

STATUS_TRANSITIONS = {
    TalentStatus.NEW: [TalentStatus.CONTACTED, TalentStatus.CLOSED],
    TalentStatus.CONTACTED: [TalentStatus.EXAM_SENT, TalentStatus.CLOSED],
    TalentStatus.EXAM_SENT: [TalentStatus.EXAM_RECEIVED, TalentStatus.CLOSED],
    TalentStatus.EXAM_RECEIVED: [TalentStatus.EVALUATING, TalentStatus.CLOSED],
    TalentStatus.EVALUATING: [TalentStatus.INTERVIEW, TalentStatus.EXAM_SENT, TalentStatus.CLOSED],
    TalentStatus.INTERVIEW: [TalentStatus.OFFER, TalentStatus.CLOSED],
    TalentStatus.OFFER: [TalentStatus.CLOSED],
    TalentStatus.CLOSED: [],
}


class Talent(Base):
    __tablename__ = "talents"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    recruitment_id: Mapped[int] = mapped_column(ForeignKey("recruitments.id"), index=True)
    application_id: Mapped[int | None] = mapped_column(ForeignKey("applications.id"), nullable=True, index=True)
    email: Mapped[str] = mapped_column(String(200))
    real_name: Mapped[str] = mapped_column(String(100))

    status: Mapped[TalentStatus] = mapped_column(Enum(TalentStatus), default=TalentStatus.NEW, index=True)
    sub_stage: Mapped[str | None] = mapped_column(String(30), nullable=True)
    quality: Mapped[str] = mapped_column(String(10), default="normal")
    stage_results: Mapped[dict | None] = mapped_column(JSON, nullable=True, default=None)

    application: Mapped[Application | None] = relationship("Application", back_populates="talent")

    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())


