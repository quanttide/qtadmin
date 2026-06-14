from datetime import date, datetime
from typing import Optional

from pydantic import Field, field_validator
from pydantic import BaseModel as PydanticBase


class NormalizedRecordCreate(PydanticBase):
    primary_source_id: Optional[int] = None
    record_type: str
    business_date: date
    amount_cents: int = Field(default=0, ge=0)
    currency: str = "CNY"
    direction: str
    department: Optional[str] = None
    person: Optional[str] = None
    counterparty: Optional[str] = None
    description: str = ""
    normalization_status: str = "draft"

    @field_validator("record_type")
    @classmethod
    def validate_record_type(cls, v: str) -> str:
        allowed = {"expense", "income", "transfer", "reimbursement", "other"}
        if v not in allowed:
            raise ValueError(
                f"record_type must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("direction")
    @classmethod
    def validate_direction(cls, v: str) -> str:
        allowed = {"outflow", "inflow"}
        if v not in allowed:
            raise ValueError(f"direction must be one of: {', '.join(sorted(allowed))}")
        return v

    @field_validator("normalization_status")
    @classmethod
    def validate_normalization_status(cls, v: str) -> str:
        allowed = {"draft", "normalized", "reviewed", "merged"}
        if v not in allowed:
            raise ValueError(
                f"normalization_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("description")
    @classmethod
    def truncate_description(cls, v: str) -> str:
        if len(v) > 1000:
            return v[:1000]
        return v


class NormalizedRecordResponse(PydanticBase):
    model_config = {"from_attributes": True}

    id: int
    primary_source_id: Optional[int] = None
    record_type: str
    business_date: date
    amount_cents: int = 0
    currency: str = "CNY"
    direction: str
    department: Optional[str] = None
    person: Optional[str] = None
    counterparty: Optional[str] = None
    description: str = ""
    normalization_status: str = "draft"
    created_at: datetime
    updated_at: datetime


class NormalizedRecordUpdate(PydanticBase):
    record_type: Optional[str] = None
    business_date: Optional[date] = None
    amount_cents: Optional[int] = Field(default=None, ge=0)
    currency: Optional[str] = None
    direction: Optional[str] = None
    department: Optional[str] = None
    person: Optional[str] = None
    counterparty: Optional[str] = None
    description: Optional[str] = None
    normalization_status: Optional[str] = None
