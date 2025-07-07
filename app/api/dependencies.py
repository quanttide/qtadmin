# app/api/dependencies.py
from fastapi import Query, HTTPException
from datetime import date

def validate_period(
    period_start: date = Query(..., description="薪资周期开始日期"),
    period_end: date = Query(..., description="薪资周期结束日期")
):
    if period_end <= period_start:
        raise HTTPException(status_code=400, detail="结束日期必须晚于开始日期")
    return period_start, period_end