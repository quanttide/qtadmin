from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.database import Base, engine
from app.routers import positions


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="QtCloud Org",
    description="组织架构系统 — 岗位定义",
    version="0.1.0",
    lifespan=lifespan,
)

app.include_router(positions.router)


@app.get("/health")
def health():
    return {"status": "ok"}
