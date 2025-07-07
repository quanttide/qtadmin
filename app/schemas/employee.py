# app/schemas/employee.py
from typing import Optional

from .base import BaseModel

class EmployeeCreate(BaseModel):
    name: str
    position: str
    department: str

class EmployeeUpdate(BaseModel):
    position: Optional[str] = None
    department: Optional[str] = None