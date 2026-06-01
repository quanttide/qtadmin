from datetime import datetime

from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String, Text, func

from fastapi_quanttide_finance.database import Base


class NormalizedRecord(Base):
    __tablename__ = "normalized_record"

    id = Column(Integer, primary_key=True, autoincrement=True)
    primary_source_id = Column(
        Integer, ForeignKey("source_record.id"), nullable=True
    )
    record_type = Column(String(50), nullable=False)
    business_date = Column(Date, nullable=False)
    amount_cents = Column(Integer, nullable=False, default=0)
    currency = Column(String(10), nullable=False, default="CNY")
    direction = Column(String(50), nullable=False)
    department = Column(String(255), nullable=True)
    person = Column(String(255), nullable=True)
    counterparty = Column(String(255), nullable=True)
    description = Column(String(1000), nullable=False, default="")
    normalization_status = Column(String(50), nullable=False, default="draft")
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )
