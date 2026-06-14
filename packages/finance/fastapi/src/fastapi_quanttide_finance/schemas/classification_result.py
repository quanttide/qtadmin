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
        allowed = {"expense_type"}
        if v not in allowed:
            raise ValueError(f"taxonomy must be one of: {', '.join(sorted(allowed))}")
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

    @field_validator("is_active")
    @classmethod
    def reject_null_is_active(cls, v):
        """Reject explicit null for is_active — non-nullable at DB layer."""
        if v is None:
            raise ValueError("is_active cannot be set to null")
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
    model_config = {"extra": "forbid"}

    category: Optional[str] = None
    tags: Optional[dict] = None
    confidence: Optional[float] = None
    review_status: Optional[str] = None
    is_active: Optional[bool] = None

    @field_validator("review_status")
    @classmethod
    def validate_review_status(cls, v: str) -> str:
        allowed = {"candidate", "accepted", "rejected"}
        if v not in allowed:
            raise ValueError(
                f"review_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("is_active", mode="before")
    @classmethod
    def reject_null_is_active(cls, v):
        """Reject explicit null for is_active — non-nullable at DB layer.
        Uses mode='before' to catch JSON null before Pydantic skips validation for Optional types."""
        if v is None:
            raise ValueError("is_active cannot be set to null")
        return v


class ClassificationCreateRequest(PydanticBase):
    model_config = {"extra": "forbid"}

    taxonomy: str = "expense_type"
    category: str
    tags: Optional[dict] = None
    classifier_kind: str
    confidence: Optional[float] = None
    model_version: Optional[str] = None

    @field_validator("taxonomy")
    @classmethod
    def validate_taxonomy(cls, v: str) -> str:
        allowed = {"expense_type"}
        if v not in allowed:
            raise ValueError(f"taxonomy must be one of: {', '.join(sorted(allowed))}")
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


class ClassificationReviewSchema(PydanticBase):
    model_config = {"extra": "forbid"}

    review_status: Optional[str] = None
    is_active: Optional[bool] = None

    @field_validator("review_status")
    @classmethod
    def validate_review_status(cls, v: str) -> str:
        allowed = {"candidate", "accepted", "rejected"}
        if v not in allowed:
            raise ValueError(
                f"review_status must be one of: {', '.join(sorted(allowed))}"
            )
        return v

    @field_validator("is_active", mode="before")
    @classmethod
    def reject_null_is_active(cls, v):
        if v is None:
            raise ValueError("is_active cannot be set to null")
        return v
