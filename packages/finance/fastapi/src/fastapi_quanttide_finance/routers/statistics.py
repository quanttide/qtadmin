"""Statistics API router — summary, breakdown, trend, drilldown."""

import re
from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from fastapi_quanttide_finance.database import get_db
from fastapi_quanttide_finance.schemas.statistics import (
    StatisticsBreakdownResponse,
    StatisticsDrilldownResponse,
    StatisticsFilterParams,
    StatisticsRow,
    StatisticsSummaryResponse,
    StatisticsTrendResponse,
    StatisticsTrendRow,
)
from fastapi_quanttide_finance.services.statistics import (
    ALLOWED_DIMENSIONS,
    GRANULARITY_FORMAT,
    get_breakdown,
    get_drilldown,
    get_summary,
    get_trend,
)

router = APIRouter()


def _parse_filters(
    from_date: Optional[date] = Query(default=None),
    to_date: Optional[date] = Query(default=None),
    department: Optional[str] = Query(default=None),
    person: Optional[str] = Query(default=None),
    counterparty: Optional[str] = Query(default=None),
    record_type: Optional[str] = Query(default=None),
    direction: Optional[str] = Query(default=None),
    normalization_status: Optional[str] = Query(default=None),
    currency: str = Query(default="CNY"),
    taxonomy: Optional[str] = Query(default=None),
    category: Optional[str] = Query(default=None),
) -> StatisticsFilterParams:
    """Parse and validate query params manually, then build StatisticsFilterParams."""
    # Manual field validation
    if record_type is not None:
        allowed_rt = {"expense", "income", "transfer", "reimbursement", "other"}
        if record_type not in allowed_rt:
            raise HTTPException(
                status_code=422,
                detail=f"record_type must be one of: {', '.join(sorted(allowed_rt))}",
            )
    if direction is not None:
        allowed_dir = {"outflow", "inflow"}
        if direction not in allowed_dir:
            raise HTTPException(
                status_code=422,
                detail=f"direction must be one of: {', '.join(sorted(allowed_dir))}",
            )
    if normalization_status is not None:
        allowed_ns = {"draft", "normalized", "reviewed", "merged"}
        if normalization_status not in allowed_ns:
            raise HTTPException(
                status_code=422,
                detail=f"normalization_status must be one of: {', '.join(sorted(allowed_ns))}",
            )
    if currency != "*" and not re.match(r"^[A-Z]{3}$", currency):
        raise HTTPException(
            status_code=422,
            detail=f"Invalid currency '{currency}'. Use ISO 4217 code (e.g. CNY, USD) or '*' for all.",
        )
    if (taxonomy is None) != (category is None):
        raise HTTPException(
            status_code=422,
            detail="taxonomy and category must be provided together",
        )
    if from_date is not None and to_date is not None and from_date > to_date:
        raise HTTPException(
            status_code=422,
            detail="from_date must not be later than to_date",
        )

    return StatisticsFilterParams(
        from_date=from_date,
        to_date=to_date,
        department=department,
        person=person,
        counterparty=counterparty,
        record_type=record_type,
        direction=direction,
        normalization_status=normalization_status,
        currency=currency,
        taxonomy=taxonomy,
        category=category,
    )


def _filters_to_dict(filters: StatisticsFilterParams) -> dict:
    return filters.model_dump(exclude_none=True)


@router.get(
    "/statistics/summary",
    response_model=StatisticsSummaryResponse,
)
def list_summary(
    filters: StatisticsFilterParams = Depends(_parse_filters),
    db: Session = Depends(get_db),
):
    result = get_summary(filters, db)
    return {
        "record_count": result["record_count"],
        "amount_cents": result["amount_cents"],
        "classified_count": result["classified_count"],
        "filters": _filters_to_dict(filters),
    }


@router.get(
    "/statistics/breakdown",
    response_model=StatisticsBreakdownResponse,
)
def list_breakdown(
    dimension: str = Query(...),
    filters: StatisticsFilterParams = Depends(_parse_filters),
    db: Session = Depends(get_db),
):
    if dimension not in ALLOWED_DIMENSIONS:
        allowed = ", ".join(sorted(ALLOWED_DIMENSIONS))
        raise HTTPException(
            status_code=422,
            detail=f"Invalid dimension '{dimension}'. Allowed: {allowed}",
        )

    rows_data = get_breakdown(filters, dimension, db)
    return {
        "dimension": dimension,
        "rows": [StatisticsRow(**r) for r in rows_data],
        "filters": _filters_to_dict(filters),
    }


@router.get(
    "/statistics/trend",
    response_model=StatisticsTrendResponse,
)
def list_trend(
    granularity: str = "day",
    filters: StatisticsFilterParams = Depends(_parse_filters),
    db: Session = Depends(get_db),
):
    if granularity not in GRANULARITY_FORMAT:
        allowed = ", ".join(sorted(GRANULARITY_FORMAT))
        raise HTTPException(
            status_code=422,
            detail=f"Invalid granularity '{granularity}'. Allowed: {allowed}",
        )

    rows_data = get_trend(filters, granularity, db)
    return {
        "granularity": granularity,
        "rows": [StatisticsTrendRow(**r) for r in rows_data],
        "filters": _filters_to_dict(filters),
    }


@router.get(
    "/statistics/drilldown",
    response_model=StatisticsDrilldownResponse,
)
def list_drilldown(
    skip: int = 0,
    limit: int = 50,
    filters: StatisticsFilterParams = Depends(_parse_filters),
    db: Session = Depends(get_db),
):
    if limit > 200:
        raise HTTPException(
            status_code=422,
            detail="limit must not exceed 200",
        )

    items, total = get_drilldown(filters, skip, limit, db)
    return {
        "items": items,
        "total": total,
        "skip": skip,
        "limit": limit,
        "filters": _filters_to_dict(filters),
    }
