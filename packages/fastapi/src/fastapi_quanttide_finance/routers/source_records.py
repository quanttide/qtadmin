from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from fastapi_quanttide_finance.database import get_db
from fastapi_quanttide_finance.models.source_record import SourceRecord
from fastapi_quanttide_finance.models.normalized_record import NormalizedRecord
from fastapi_quanttide_finance.models.record_link import RecordLink
from fastapi_quanttide_finance.schemas.source_record import (
    SourceRecordCreate,
    SourceRecordResponse,
)
from fastapi_quanttide_finance.schemas.normalized_record import (
    NormalizedRecordResponse,
)
from fastapi_quanttide_finance.services.normalization import (
    NormalizeInput,
    normalize,
)
from fastapi_quanttide_finance.services.normalizers import (
    CsvRowNormalizer,
    ManualNormalizer,
)

router = APIRouter()

# Register built-in normalizers on module load
try:
    from fastapi_quanttide_finance.services.normalization import register_normalizer
    register_normalizer(CsvRowNormalizer())
    register_normalizer(ManualNormalizer())
except RuntimeError:
    pass


@router.post("/source-records/{record_id}/normalize", response_model=list[NormalizedRecordResponse])
def normalize_source_record(record_id: int, db: Session = Depends(get_db)):
    source = db.get(SourceRecord, record_id)
    if source is None:
        raise HTTPException(status_code=404, detail="SourceRecord not found")

    input_data = NormalizeInput(
        source_record_id=source.id,
        raw_text=source.raw_text,
        source_type=source.source_type,
    )

    try:
        result = normalize(input_data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    created_records = []
    for nr_data in result.normalized_records:
        nr = NormalizedRecord(**nr_data, primary_source_id=source.id)
        db.add(nr)
        db.flush()
        created_records.append(nr)

    for link_data in result.links:
        nr_id = created_records[link_data["normalized_record_id"]].id
        link = RecordLink(
            source_record_id=link_data["source_record_id"],
            normalized_record_id=nr_id,
            relation_type=link_data["relation_type"],
        )
        db.add(link)

    db.commit()
    for nr in created_records:
        db.refresh(nr)
    return created_records


@router.get("/source-records", response_model=list[SourceRecordResponse])
def list_source_records(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(SourceRecord).order_by(SourceRecord.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/source-records/{record_id}", response_model=SourceRecordResponse)
def get_source_record(record_id: int, db: Session = Depends(get_db)):
    record = db.get(SourceRecord, record_id)
    if record is None:
        raise HTTPException(status_code=404, detail="SourceRecord not found")
    return record


@router.get("/normalized-records", response_model=list[NormalizedRecordResponse])
def list_normalized_records(
    source_record_id: int | None = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    qb = db.query(NormalizedRecord)
    if source_record_id is not None:
        qb = qb.filter(NormalizedRecord.primary_source_id == source_record_id)
    return qb.order_by(NormalizedRecord.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/normalized-records/{record_id}", response_model=NormalizedRecordResponse)
def get_normalized_record(record_id: int, db: Session = Depends(get_db)):
    record = db.get(NormalizedRecord, record_id)
    if record is None:
        raise HTTPException(status_code=404, detail="NormalizedRecord not found")
    return record


@router.post("/source-records", response_model=SourceRecordResponse, status_code=201)
def create_source_record(data: SourceRecordCreate, db: Session = Depends(get_db)):
    record = SourceRecord(**data.model_dump())
    db.add(record)
    db.commit()
    db.refresh(record)
    return record
