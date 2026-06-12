from pydantic import BaseModel

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.services.material_service import (
    get_artifacts_by_candidate,
    get_artifacts_by_queue,
)

router = APIRouter(prefix="/materials", tags=["materials"])


class ArtifactItem(BaseModel):
    id: int
    queue_item_id: int | None
    candidate_id: int | None
    artifact_type: str
    content_json: str | None = None
    file_path: str | None = None
    created_at: str = ""

    model_config = {"from_attributes": True}


class ArtifactListResponse(BaseModel):
    items: list[ArtifactItem]


@router.get("/by-queue/{queue_id}", response_model=ArtifactListResponse)
def list_by_queue(queue_id: int, db: Session = Depends(get_db)):
    items = get_artifacts_by_queue(db, queue_id)
    return ArtifactListResponse(
        items=[ArtifactItem(
            id=a.id, queue_item_id=a.queue_item_id, candidate_id=a.candidate_id,
            artifact_type=a.artifact_type, content_json=a.content_json,
            file_path=a.file_path, created_at=str(a.created_at),
        ) for a in items]
    )


@router.get("/by-candidate/{candidate_id}", response_model=ArtifactListResponse)
def list_by_candidate(candidate_id: int, db: Session = Depends(get_db)):
    items = get_artifacts_by_candidate(db, candidate_id)
    return ArtifactListResponse(
        items=[ArtifactItem(
            id=a.id, queue_item_id=a.queue_item_id, candidate_id=a.candidate_id,
            artifact_type=a.artifact_type, content_json=a.content_json,
            file_path=a.file_path, created_at=str(a.created_at),
        ) for a in items]
    )
