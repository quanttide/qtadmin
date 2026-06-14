from datetime import datetime
from typing import Optional

from pydantic import Field, field_validator
from pydantic import BaseModel as PydanticBase


class SourceRecordCreate(PydanticBase):
    source_type: str
    source_channel: Optional[str] = None
    external_id: Optional[str] = None
    raw_payload: Optional[dict] = None
    raw_text: str = ""
    evidence_refs: Optional[dict] = None
    occurred_at: Optional[datetime] = None
    ingestion_status: str = "pending"

    @field_validator("source_type")
    @classmethod
    def validate_source_type(cls, v: str) -> str:
        allowed = {
            "image",
            "chat",
            "form",
            "csv_row",
            "bank_tx",
            "api",
            "manual",
            "other",
        }
        if v not in allowed:
            raise ValueError(
                f"source_type must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("ingestion_status")
    @classmethod
    def validate_ingestion_status(cls, v: str) -> str:
        allowed = {"pending", "parsed", "reviewed", "failed"}
        if v not in allowed:
            raise ValueError(
                f"ingestion_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("raw_text")
    @classmethod
    def validate_raw_text_length(cls, v: str) -> str:
        if len(v) > 65535:
            raise ValueError(
                f"raw_text exceeds maximum length of 65535 characters (got {len(v)})"
            )
        return v


class SourceRecordResponse(PydanticBase):
    model_config = {"from_attributes": True}

    id: int
    source_type: str
    source_channel: Optional[str] = None
    external_id: Optional[str] = None
    raw_payload: Optional[dict] = None
    raw_text: str = ""
    evidence_refs: Optional[dict] = None
    occurred_at: Optional[datetime] = None
    ingestion_status: str = "pending"
    created_at: datetime
    updated_at: datetime


class SourceRecordUpdate(PydanticBase):
    source_type: Optional[str] = None
    source_channel: Optional[str] = None
    external_id: Optional[str] = None
    raw_payload: Optional[dict] = None
    raw_text: Optional[str] = None
    evidence_refs: Optional[dict] = None
    occurred_at: Optional[datetime] = None
    ingestion_status: Optional[str] = None
