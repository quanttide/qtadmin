from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, func
from sqlalchemy.dialects.sqlite import JSON

from fastapi_quanttide_finance.database import Base


class ClassificationResult(Base):
    __tablename__ = "classification_result"

    id = Column(Integer, primary_key=True, autoincrement=True)
    normalized_record_id = Column(
        Integer, ForeignKey("normalized_record.id"), nullable=False
    )
    taxonomy = Column(String(50), nullable=False)
    category = Column(String(255), nullable=False)
    tags = Column(JSON, nullable=True)
    classifier_kind = Column(String(50), nullable=False)
    confidence = Column(Float, nullable=True)
    model_version = Column(String(50), nullable=True)
    review_status = Column(String(50), nullable=False, default="candidate")
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
