from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user_profile import UserProfile
from app.schemas.user_profile import UserProfileCreate, UserProfileRead, UserProfileUpdate

router = APIRouter(prefix="/user-profiles", tags=["user-profiles"])


@router.get("", response_model=list[UserProfileRead])
def list_user_profiles(
    q: str | None = Query(None, min_length=1, description="搜索：姓名/邮箱"),
    email: str | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
):
    qb = db.query(UserProfile)
    if q:
        like = f"%{q}%"
        qb = qb.filter(or_(UserProfile.real_name.ilike(like), UserProfile.email.ilike(like)))
    if email:
        qb = qb.filter(UserProfile.email == email)
    return qb.order_by(UserProfile.created_at.desc()).offset(skip).limit(limit).all()


@router.get("/{user_profile_id}", response_model=UserProfileRead)
def get_user_profile(user_profile_id: int, db: Session = Depends(get_db)):
    p = db.query(UserProfile).filter(UserProfile.id == user_profile_id).first()
    if not p:
        raise HTTPException(404, "UserProfile not found")
    return p


@router.post("", response_model=UserProfileRead, status_code=201)
def create_user_profile(data: UserProfileCreate, db: Session = Depends(get_db)):
    p = UserProfile(**data.model_dump())
    db.add(p)
    db.commit()
    db.refresh(p)
    return p


@router.patch("/{user_profile_id}", response_model=UserProfileRead)
def update_user_profile(user_profile_id: int, data: UserProfileUpdate, db: Session = Depends(get_db)):
    p = db.query(UserProfile).filter(UserProfile.id == user_profile_id).first()
    if not p:
        raise HTTPException(404, "UserProfile not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(p, k, v)
    db.commit()
    db.refresh(p)
    return p


@router.delete("/{user_profile_id}", status_code=204)
def delete_user_profile(user_profile_id: int, db: Session = Depends(get_db)):
    p = db.query(UserProfile).filter(UserProfile.id == user_profile_id).first()
    if not p:
        raise HTTPException(404, "UserProfile not found")
    db.delete(p)
    db.commit()
