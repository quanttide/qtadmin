from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, String, Text, func
from sqlalchemy.dialects.sqlite import JSON

from fastapi_quanttide_finance.database import Base


class SourceRecord(Base):
    __tablename__ = "source_record"

    id = Column(Integer, primary_key=True, autoincrement=True)
    source_type = Column(String(50), nullable=False)
    source_channel = Column(String(50), nullable=True)
    external_id = Column(String(255), nullable=True)
    raw_payload = Column(JSON, nullable=True)
    raw_text = Column(Text, nullable=False, default="")
    evidence_refs = Column(JSON, nullable=True)
    occurred_at = Column(DateTime, nullable=True)
    ingestion_status = Column(String(50), nullable=False, default="pending")
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
