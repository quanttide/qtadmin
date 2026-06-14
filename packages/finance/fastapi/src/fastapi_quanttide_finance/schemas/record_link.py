from datetime import datetime

from pydantic import field_validator
from pydantic import BaseModel as PydanticBase


class RecordLinkCreate(PydanticBase):
    source_record_id: int
    normalized_record_id: int
    relation_type: str

    @field_validator("relation_type")
    @classmethod
    def validate_relation_type(cls, v: str) -> str:
        allowed = {"primary", "supplementary", "split", "merged"}
        if v not in allowed:
            raise ValueError(
                f"relation_type must be one of: {', '.join(sorted(allowed))}"
            )
        return v


class RecordLinkResponse(PydanticBase):
    model_config = {"from_attributes": True}

    id: int
    source_record_id: int
    normalized_record_id: int
    relation_type: str
    created_at: datetime
