from sqlalchemy import text


def test_db_connectivity(db_session):
    result = db_session.execute(text("SELECT 1"))
    assert result.scalar() == 1


def test_db_has_tables(db_session):
    result = db_session.execute(
        text("SELECT name FROM sqlite_master WHERE type='table'")
    )
    tables = {row[0] for row in result}
    assert "alembic_version" in tables
