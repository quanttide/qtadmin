import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

DATA_DIR = Path(__file__).resolve().parent.parent.parent / "data"
DATA_DIR.mkdir(exist_ok=True)

# 支持 DEMO_DB 环境变量指向独立数据库（不碰生产库）
_demo_db = os.environ.get("DEMO_DB")
if _demo_db:
    DATABASE_URL = f"sqlite:///{Path(_demo_db).resolve()}"
else:
    DATABASE_URL = f"sqlite:///{DATA_DIR / 'quanttide_finance.db'}"

engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
