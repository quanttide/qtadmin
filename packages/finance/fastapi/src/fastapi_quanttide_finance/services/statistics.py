"""Statistics query service — summary, breakdown, trend, drilldown."""

from sqlalchemy import exists, text
from sqlalchemy.orm import Session

from fastapi_quanttide_finance.models.classification_result import ClassificationResult
from fastapi_quanttide_finance.models.normalized_record import NormalizedRecord
from fastapi_quanttide_finance.schemas.statistics import StatisticsFilterParams

# Allowed dimensions for breakdown
ALLOWED_DIMENSIONS = {
    "department",
    "person",
    "counterparty",
    "record_type",
    "direction",
    "currency",
}

# Granularity -> strftime format
GRANULARITY_FORMAT = {
    "day": "%Y-%m-%d",
    "week": "%Y-%W",
    "month": "%Y-%m",
}


def build_where(filters: StatisticsFilterParams):
    """Build WHERE clauses and params dict from filter params."""
    where = []
    params = {}

    if filters.from_date is not None:
        where.append("nr.business_date >= :from_date")
        params["from_date"] = filters.from_date
    if filters.to_date is not None:
        where.append("nr.business_date <= :to_date")
        params["to_date"] = filters.to_date
    if filters.department is not None:
        where.append("nr.department = :department")
        params["department"] = filters.department
    if filters.person is not None:
        where.append("nr.person = :person")
        params["person"] = filters.person
    if filters.counterparty is not None:
        where.append("nr.counterparty = :counterparty")
        params["counterparty"] = filters.counterparty
    if filters.record_type is not None:
        where.append("nr.record_type = :record_type")
        params["record_type"] = filters.record_type
    if filters.direction is not None:
        where.append("nr.direction = :direction")
        params["direction"] = filters.direction
    if filters.normalization_status is not None:
        where.append("nr.normalization_status = :normalization_status")
        params["normalization_status"] = filters.normalization_status
    if filters.currency is not None and filters.currency != "*":
        where.append("nr.currency = :currency")
        params["currency"] = filters.currency
    if filters.taxonomy is not None and filters.category is not None:
        where.append(
            "EXISTS ("
            "SELECT 1 FROM classification_result cr "
            "WHERE cr.normalized_record_id = nr.id "
            "AND cr.is_active = 1 "
            "AND cr.review_status = 'accepted' "
            "AND cr.taxonomy = :taxonomy "
            "AND cr.category = :category"
            ")"
        )
        params["taxonomy"] = filters.taxonomy
        params["category"] = filters.category

    return where, params


def _where_sql(where: list[str]) -> str:
    """Join WHERE clauses with AND, or return empty string."""
    if not where:
        return ""
    return " WHERE " + " AND ".join(where)


def get_summary(filters: StatisticsFilterParams, db: Session) -> dict:
    """Return record_count, amount_cents, classified_count."""
    where, params = build_where(filters)
    ws = _where_sql(where)

    # Query A: record_count + amount_cents
    row = db.execute(
        text(
            "SELECT COUNT(*), COALESCE(SUM(amount_cents), 0) "
            "FROM normalized_record nr" + ws
        ),
        params,
    ).one()
    record_count = row[0]
    amount_cents = row[1]

    # When currency='*', amount aggregation is meaningless
    if filters.currency == "*":
        amount_cents = None

    # Query B: classified_count (EXISTS subquery)
    classified_sql = (
        "SELECT COUNT(*) FROM normalized_record nr "
        "WHERE EXISTS ("
        "SELECT 1 FROM classification_result cr "
        "WHERE cr.normalized_record_id = nr.id "
        "AND cr.is_active = 1 "
        "AND cr.review_status = 'accepted'"
        ")"
    )
    if where:
        classified_sql += " AND " + " AND ".join(where)
    classified_row = db.execute(text(classified_sql), params).one()
    classified_count = classified_row[0]

    return {
        "record_count": record_count,
        "amount_cents": amount_cents,
        "classified_count": classified_count,
    }


def get_breakdown(
    filters: StatisticsFilterParams, dimension: str, db: Session
) -> list[dict]:
    """Return grouped rows for a given dimension."""
    where, params = build_where(filters)
    ws = _where_sql(where)

    sql = (
        f"SELECT nr.{dimension} AS key, "
        f"COUNT(*) AS count, "
        f"COALESCE(SUM(amount_cents), 0) AS amount_cents "
        f"FROM normalized_record nr" + ws +
        f" GROUP BY nr.{dimension} "
        f"ORDER BY count DESC"
    )

    rows = []
    for row in db.execute(text(sql), params).all():
        amount = None if filters.currency == "*" else row[2]
        rows.append({"key": row[0], "count": row[1], "amount_cents": amount})
    return rows


def get_trend(
    filters: StatisticsFilterParams, granularity: str, db: Session
) -> list[dict]:
    """Return time-series rows grouped by granularity."""
    fmt = GRANULARITY_FORMAT[granularity]
    where, params = build_where(filters)
    ws = _where_sql(where)

    sql = (
        f"SELECT strftime('{fmt}', nr.business_date) AS date, "
        f"COUNT(*) AS count, "
        f"COALESCE(SUM(amount_cents), 0) AS amount_cents "
        f"FROM normalized_record nr" + ws +
        f" GROUP BY strftime('{fmt}', nr.business_date) "
        f"ORDER BY MIN(nr.business_date)"
    )

    rows = []
    for row in db.execute(text(sql), params).all():
        amount = None if filters.currency == "*" else row[2]
        rows.append({"date": row[0], "count": row[1], "amount_cents": amount})
    return rows


def get_drilldown(
    filters: StatisticsFilterParams, skip: int, limit: int, db: Session
) -> tuple[list[NormalizedRecord], int]:
    """Return (items, total) for drilldown query."""
    qb = db.query(NormalizedRecord)

    if filters.from_date is not None:
        qb = qb.filter(NormalizedRecord.business_date >= filters.from_date)
    if filters.to_date is not None:
        qb = qb.filter(NormalizedRecord.business_date <= filters.to_date)
    if filters.department is not None:
        qb = qb.filter(NormalizedRecord.department == filters.department)
    if filters.person is not None:
        qb = qb.filter(NormalizedRecord.person == filters.person)
    if filters.counterparty is not None:
        qb = qb.filter(NormalizedRecord.counterparty == filters.counterparty)
    if filters.record_type is not None:
        qb = qb.filter(NormalizedRecord.record_type == filters.record_type)
    if filters.direction is not None:
        qb = qb.filter(NormalizedRecord.direction == filters.direction)
    if filters.normalization_status is not None:
        qb = qb.filter(
            NormalizedRecord.normalization_status == filters.normalization_status
        )
    if filters.currency is not None and filters.currency != "*":
        qb = qb.filter(NormalizedRecord.currency == filters.currency)
    if filters.taxonomy is not None and filters.category is not None:
        exists_clause = (
            exists()
            .where(
                ClassificationResult.normalized_record_id == NormalizedRecord.id,
                ClassificationResult.is_active == True,
                ClassificationResult.review_status == "accepted",
                ClassificationResult.taxonomy == filters.taxonomy,
                ClassificationResult.category == filters.category,
            )
        )
        qb = qb.filter(exists_clause)

    total = qb.count()
    items = (
        qb.order_by(NormalizedRecord.business_date.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return items, total
