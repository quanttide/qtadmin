from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column

from fastapi_quanttide_hr.database import Base


class CorrectionLog(Base):
    __tablename__ = "correction_logs"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    queue_item_id: Mapped[int] = mapped_column(ForeignKey("pending_queue.id"), index=True)
    application_id: Mapped[int | None] = mapped_column(ForeignKey("applications.id"), nullable=True, index=True)
    field_name: Mapped[str] = mapped_column(String(50))
    original_value: Mapped[str | None] = mapped_column(String(500), nullable=True)
    corrected_value: Mapped[str | None] = mapped_column(String(500), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
