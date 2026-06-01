from datetime import datetime
from typing import Optional

from pydantic import field_validator
from pydantic import BaseModel as PydanticBase


class ClassificationResultCreate(PydanticBase):
    normalized_record_id: int
    taxonomy: str
    category: str
    tags: Optional[dict] = None
    classifier_kind: str
    confidence: Optional[float] = None
    model_version: Optional[str] = None
    review_status: str = "candidate"
    is_active: bool = True

    @field_validator("taxonomy")
    @classmethod
    def validate_taxonomy(cls, v: str) -> str:
        allowed = {"expense_type", "business_tag"}
        if v not in allowed:
            raise ValueError(
                f"taxonomy must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("classifier_kind")
    @classmethod
    def validate_classifier_kind(cls, v: str) -> str:
        allowed = {"ai", "rule", "manual"}
        if v not in allowed:
            raise ValueError(
                f"classifier_kind must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("review_status")
    @classmethod
    def validate_review_status(cls, v: str) -> str:
        allowed = {"candidate", "accepted", "rejected"}
        if v not in allowed:
            raise ValueError(
                f"review_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v


class ClassificationResultResponse(PydanticBase):
    model_config = {"from_attributes": True}

    id: int
    normalized_record_id: int
    taxonomy: str
    category: str
    tags: Optional[dict] = None
    classifier_kind: str
    confidence: Optional[float] = None
    model_version: Optional[str] = None
    review_status: str = "candidate"
    is_active: bool = True
    created_at: datetime
    updated_at: datetime


class ClassificationResultUpdate(PydanticBase):
    category: Optional[str] = None
    tags: Optional[dict] = None
    confidence: Optional[float] = None
    review_status: Optional[str] = None
    is_active: Optional[bool] = None
