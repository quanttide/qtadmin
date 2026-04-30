# app/schemas/__init__.py
from .base import BaseModel
from .employee import EmployeeCreate, EmployeeUpdate

__all__ = [
    "BaseModel",
    "EmployeeCreate", "EmployeeUpdate",
]