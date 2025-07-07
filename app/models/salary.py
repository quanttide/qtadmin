from sqlmodel import SQLModel, Field, Relationship
from datetime import date
from typing import Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from .employee import Employee

class SalaryCalculationBase(SQLModel):
    employee_id: int = Field(foreign_key="employee.id")
    base_hours: float
    hourly_rate: float
    overtime_hours: float = 0
    deductions: float = 0
    period_start: date
    period_end: date
    #calculated_salary: float

class SalaryCalculation(SalaryCalculationBase, table=True):
    id: int = Field(default=None, primary_key=True)
    employee: "Employee" = Relationship(back_populates="salaries")
    calculated_salary: float

class SalaryCalculationCreate(SQLModel):
    employee_id: int
    base_hours: float
    hourly_rate: float
    overtime_hours: float = 0
    deductions: float = 0
    period_start: date
    period_end: date

class SalaryCalculationRead(SalaryCalculationBase):
    id: int
    employee_id: int
    calculated_salary: float




'''class SalaryCalculationCreate(SalaryCalculationBase):
    pass

class SalaryCalculationRead(SalaryCalculationBase):
    id: int'''