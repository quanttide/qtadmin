"""Candidate model — person entity, not tied to a specific recruitment."""
from datetime import datetime

from sqlalchemy import DateTime, String, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.human.database import Base


class Candidate(Base):
    __tablename__ = "candidates"
    __table_args__ = (UniqueConstraint("email", name="uq_candidates_email"),)

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(200))
    real_name: Mapped[str] = mapped_column(String(100))
    phone: Mapped[str | None] = mapped_column(String(30), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
