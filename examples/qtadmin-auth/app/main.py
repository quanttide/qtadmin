from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.database import Base, engine
from app.routers import user_profiles


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="QtCloud Auth",
    description="身份认证系统 — 用户档案",
    version="0.1.0",
    lifespan=lifespan,
)

app.include_router(user_profiles.router)


@app.get("/health")
def health():
    return {"status": "ok"}
