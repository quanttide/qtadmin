from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.services.pipeline import get_pipeline

router = APIRouter(prefix="/pipeline", tags=["pipeline"])


@router.get("")
def pipeline(db: Session = Depends(get_db)):
    return get_pipeline(db)
