from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from fastapi_quanttide_finance.database import get_db
from fastapi_quanttide_finance.models.classification_result import ClassificationResult
from fastapi_quanttide_finance.models.normalized_record import NormalizedRecord
from fastapi_quanttide_finance.schemas.classification_result import (
    ClassificationCreateRequest,
    ClassificationResultResponse,
    ClassificationReviewSchema,
)
from fastapi_quanttide_finance.services.classification import validate_category

router = APIRouter()


@router.post(
    "/normalized-records/{normalized_record_id}/classifications",
    response_model=ClassificationResultResponse,
    status_code=201,
)
def create_classification(
    normalized_record_id: int,
    body: ClassificationCreateRequest,
    db: Session = Depends(get_db),
):
    normalized = db.get(NormalizedRecord, normalized_record_id)
    if normalized is None:
        raise HTTPException(status_code=404, detail="NormalizedRecord not found")

    try:
        validate_category(body.taxonomy, body.category)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    record = ClassificationResult(
        normalized_record_id=normalized_record_id,
        review_status="candidate",
        is_active=True,
        **body.model_dump(),
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get(
    "/normalized-records/{normalized_record_id}/classifications",
    response_model=list[ClassificationResultResponse],
)
def list_classifications(
    normalized_record_id: int,
    review_status: str | None = None,
    db: Session = Depends(get_db),
):
    if review_status is not None and review_status not in {"candidate", "accepted", "rejected"}:
        raise HTTPException(
            status_code=422,
            detail=f"Invalid review_status: '{review_status}'. Allowed: candidate, accepted, rejected",
        )

    normalized = db.get(NormalizedRecord, normalized_record_id)
    if normalized is None:
        raise HTTPException(status_code=404, detail="NormalizedRecord not found")

    qb = db.query(ClassificationResult).filter(
        ClassificationResult.normalized_record_id == normalized_record_id
    )
    if review_status is not None:
        qb = qb.filter(ClassificationResult.review_status == review_status)
    return qb.order_by(ClassificationResult.created_at.desc()).all()


@router.patch(
    "/classifications/{classification_id}",
    response_model=ClassificationResultResponse,
)
def review_classification(
    classification_id: int,
    body: ClassificationReviewSchema,
    db: Session = Depends(get_db),
):
    record = db.get(ClassificationResult, classification_id)
    if record is None:
        raise HTTPException(status_code=404, detail="ClassificationResult not found")

    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(record, field, value)

    db.commit()
    db.refresh(record)
    return record
