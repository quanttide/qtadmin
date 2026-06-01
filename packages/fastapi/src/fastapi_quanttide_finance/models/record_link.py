from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, func

from fastapi_quanttide_finance.database import Base


class RecordLink(Base):
    __tablename__ = "record_link"

    id = Column(Integer, primary_key=True, autoincrement=True)
    source_record_id = Column(
        Integer, ForeignKey("source_record.id"), nullable=False
    )
    normalized_record_id = Column(
        Integer, ForeignKey("normalized_record.id"), nullable=False
    )
    relation_type = Column(String(50), nullable=False)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
