from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from .salary import SalaryCalculation

class EmployeeBase(SQLModel):
    name: str = Field(index=True)
    position: str
    department: str = Field(index=True)

class Employee(EmployeeBase, table=True):
    id: int = Field(default=None, primary_key=True)
    salaries: List["SalaryCalculation"] = Relationship(back_populates="employee")

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeRead(EmployeeBase):
    id: int

class EmployeeWithSalaries(EmployeeRead):
    salaries: List["SalaryCalculation"] = []