# app/schemas/salary.py
from .base import BaseModel
from datetime import date
from pydantic import Field

class SalaryResult(BaseModel):
    base_salary: float
    overtime_pay: float
    performance_bonus: float
    net_salary: float
    deduction: float = 0

class SalaryCalculationParams(BaseModel):
    base_hours: float = Field(ge=0, description="基础工时，必须大于等于0")
    hourly_rate: float = Field(ge=0, description="小时工资，必须大于等于0")
    overtime_hours: float = Field(ge=0, default=0, description="加班工时，必须大于等于0")
    deductions: float = Field(ge=0, default=0, description="扣除金额，必须大于等于0")