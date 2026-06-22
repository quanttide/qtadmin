import tempfile
from collections.abc import Generator
from pathlib import Path

import pytest
from alembic.command import upgrade
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from sqlalchemy import event
from sqlalchemy.engine import Engine

from fastapi_quanttide_finance.app import app
from fastapi_quanttide_finance.database import get_db


@event.listens_for(Engine, "connect")
def _set_sqlite_pragma(dbapi_connection, connection_record):
    """Enable foreign key enforcement for SQLite."""
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()


TEST_DATA_DIR = Path(__file__).resolve().parent.parent / "data"
TEST_DB_PATH = TEST_DATA_DIR / "test.db"
ALEMBIC_CFG = Path(__file__).resolve().parent.parent / "alembic.ini"


@pytest.fixture(scope="session")
def test_db_path() -> Generator[Path, None, None]:
    TEST_DATA_DIR.mkdir(exist_ok=True)
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()
    yield TEST_DB_PATH
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()


@pytest.fixture(scope="session")
def alembic_config(test_db_path: Path) -> Config:
    config = Config(str(ALEMBIC_CFG))
    config.set_main_option("sqlalchemy.url", f"sqlite:///{test_db_path}")
    return config


@pytest.fixture(scope="session")
def db_engine(test_db_path: Path, alembic_config: Config) -> Generator:
    upgrade(alembic_config, "head")
    engine = create_engine(f"sqlite:///{test_db_path}", echo=False)
    yield engine
    engine.dispose()


@pytest.fixture
def db_session(db_engine) -> Generator[Session, None, None]:
    TestSessionLocal = sessionmaker(bind=db_engine)
    session = TestSessionLocal()
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture
def client(alembic_config) -> Generator[TestClient, None, None]:
    """Test client with per-test isolated SQLite DB."""
    tmp = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
    db_path = tmp.name
    tmp.close()

    # Run migrations on isolated database
    alembic_config.set_main_option("sqlalchemy.url", f"sqlite:///{db_path}")
    upgrade(alembic_config, "head")

    engine = create_engine(
        f"sqlite:///{db_path}", connect_args={"check_same_thread": False}
    )
    TestSessionLocal = sessionmaker(bind=engine)

    def override_get_db():
        db = TestSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c

    app.dependency_overrides.clear()
    engine.dispose()
    Path(db_path).unlink(missing_ok=True)
