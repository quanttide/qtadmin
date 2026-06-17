from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.position import Position
from app.schemas.position import PositionCreate, PositionRead, PositionUpdate

router = APIRouter(prefix="/positions", tags=["positions"])


@router.get("", response_model=list[PositionRead])
def list_positions(
    q: str | None = Query(None, min_length=1, description="搜索：名称/部门"),
    department: str | None = None,
    active: bool | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    qb = db.query(Position)
    if q:
        like = f"%{q}%"
        qb = qb.filter(or_(Position.name.ilike(like), Position.department.ilike(like)))
    if department:
        qb = qb.filter(Position.department == department)
    if active is not None:
        qb = qb.filter(Position.active == active)
    return qb.order_by(Position.name).offset(skip).limit(limit).all()


@router.get("/{position_id}", response_model=PositionRead)
def get_position(position_id: int, db: Session = Depends(get_db)):
    p = db.query(Position).filter(Position.id == position_id).first()
    if not p:
        raise HTTPException(404, "Position not found")
    return p


@router.post("", response_model=PositionRead, status_code=201)
def create_position(data: PositionCreate, db: Session = Depends(get_db)):
    p = Position(**data.model_dump())
    db.add(p)
    db.commit()
    db.refresh(p)
    return p


@router.patch("/{position_id}", response_model=PositionRead)
def update_position(position_id: int, data: PositionUpdate, db: Session = Depends(get_db)):
    p = db.query(Position).filter(Position.id == position_id).first()
    if not p:
        raise HTTPException(404, "Position not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(p, k, v)
    db.commit()
    db.refresh(p)
    return p


@router.delete("/{position_id}", status_code=204)
def delete_position(position_id: int, db: Session = Depends(get_db)):
    p = db.query(Position).filter(Position.id == position_id).first()
    if not p:
        raise HTTPException(404, "Position not found")
    db.delete(p)
    db.commit()
