from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from fastapi_quanttide_hr.database import Base


class AIConfig(Base):
    __tablename__ = "ai_configs"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    provider: Mapped[str] = mapped_column(String(50), default="openai")
    base_url: Mapped[str] = mapped_column(String(500), default="")
    api_key_encrypted: Mapped[str] = mapped_column(String(500), default="")
    model: Mapped[str] = mapped_column(String(100), default="")
    prompt_template: Mapped[str] = mapped_column(Text, default="")
    timeout_seconds: Mapped[int] = mapped_column(Integer, default=30)
    retry_times: Mapped[int] = mapped_column(Integer, default=2)

    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())
