# app/schemas/__init__.py
from .base import BaseModel
from .employee import EmployeeCreate, EmployeeUpdate
from .salary import SalaryResult, SalaryCalculationParams

__all__ = [
    "BaseModel",
    "EmployeeCreate", "EmployeeUpdate",
    "SalaryResult", "SalaryCalculationParams"
]