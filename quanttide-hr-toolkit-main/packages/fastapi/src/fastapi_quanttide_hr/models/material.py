from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from fastapi_quanttide_hr.database import Base


class MaterialArtifact(Base):
    __tablename__ = "material_artifacts"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    queue_item_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("pending_queue.id"), index=True, nullable=True
    )
    candidate_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("candidates.id"), index=True, nullable=True
    )
    artifact_type: Mapped[str] = mapped_column(String(50))
    content_json: Mapped[str | None] = mapped_column(Text, nullable=True)
    file_path: Mapped[str | None] = mapped_column(String(500), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
