import re
from datetime import date
from typing import Optional

from pydantic import field_validator, model_validator
from pydantic import BaseModel as PydanticBase

from fastapi_quanttide_finance.schemas.normalized_record import (
    NormalizedRecordResponse,
)


class StatisticsFilterParams(PydanticBase):
    """Optional filters that apply to all statistics endpoints."""

    from_date: Optional[date] = None
    to_date: Optional[date] = None
    department: Optional[str] = None
    person: Optional[str] = None
    counterparty: Optional[str] = None
    record_type: Optional[str] = None
    direction: Optional[str] = None
    normalization_status: Optional[str] = None
    currency: str = "CNY"
    taxonomy: Optional[str] = None
    category: Optional[str] = None

    @field_validator("record_type")
    @classmethod
    def validate_record_type(cls, v: str) -> str:
        if v is None:
            return v
        allowed = {"expense", "income", "transfer", "reimbursement", "other"}
        if v not in allowed:
            raise ValueError(
                f"record_type must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("direction")
    @classmethod
    def validate_direction(cls, v: str) -> str:
        if v is None:
            return v
        allowed = {"outflow", "inflow"}
        if v not in allowed:
            raise ValueError(f"direction must be one of: {', '.join(sorted(allowed))}")
        return v

    @field_validator("normalization_status")
    @classmethod
    def validate_normalization_status(cls, v: str) -> str:
        if v is None:
            return v
        allowed = {"draft", "normalized", "reviewed", "merged"}
        if v not in allowed:
            raise ValueError(
                f"normalization_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, v: str) -> str:
        if v == "*":
            return v
        if not re.match(r"^[A-Z]{3}$", v):
            raise ValueError(
                f"Invalid currency '{v}'. Use ISO 4217 code (e.g. CNY, USD) or '*' for all."
            )
        return v

    @model_validator(mode="after")
    def check_taxonomy_category_pair(self):
        if (self.taxonomy is None) != (self.category is None):
            raise ValueError("taxonomy and category must be provided together")
        return self

    @model_validator(mode="after")
    def check_date_range(self):
        if self.from_date is not None and self.to_date is not None:
            if self.from_date > self.to_date:
                raise ValueError("from_date must not be later than to_date")
        return self


class StatisticsSummaryResponse(PydanticBase):
    record_count: int = 0
    amount_cents: Optional[int] = 0
    classified_count: int = 0
    filters: dict


class StatisticsRow(PydanticBase):
    key: Optional[str] = None
    count: int = 0
    amount_cents: Optional[int] = 0


class StatisticsBreakdownResponse(PydanticBase):
    dimension: str
    rows: list[StatisticsRow]
    filters: dict


class StatisticsTrendRow(PydanticBase):
    date: str
    count: int = 0
    amount_cents: Optional[int] = 0


class StatisticsTrendResponse(PydanticBase):
    granularity: str
    rows: list[StatisticsTrendRow]
    filters: dict


class StatisticsDrilldownResponse(PydanticBase):
    items: list[NormalizedRecordResponse]
    total: int = 0
    skip: int = 0
    limit: int = 50
    filters: dict
