import pytest
from sqlmodel import SQLModel, create_engine, Session
from fastapi.testclient import TestClient
from fastapi import FastAPI
from app.__main__ import app as fastapi_app
from app.database import get_session
import app.models  # noqa: F401

app: FastAPI = fastapi_app

TEST_DATABASE_URL = "sqlite:///file::memory:?cache=shared"
engine = create_engine(
    TEST_DATABASE_URL,
    echo=False,
    connect_args={"check_same_thread": False, "uri": True}
)

@pytest.fixture
def session():
    with Session(engine) as session:
        yield session

@pytest.fixture
def client():
    SQLModel.metadata.create_all(engine)
    def get_session_override():
        with Session(engine) as s:
            yield s
    app.dependency_overrides[get_session] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()
    SQLModel.metadata.drop_all(engine)