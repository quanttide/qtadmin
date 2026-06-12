from collections.abc import Generator

from sqlalchemy.orm import DeclarativeBase, Session


class Base(DeclarativeBase):
    pass


def get_db() -> Generator[Session, None, None]:
    raise NotImplementedError(
        "Override this dependency in your application:\n"
        "    from fastapi_quanttide_hr.database import get_db as lib_get_db\n"
        "    app.dependency_overrides[lib_get_db] = your_get_db"
    )
