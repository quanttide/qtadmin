from sqlmodel import SQLModel, Field
from typing import Optional

class EmployeeBase(SQLModel):
    name: str = Field(index=True)
    position: str
    department: str = Field(index=True)

class Employee(EmployeeBase, table=True):
    id: int = Field(default=None, primary_key=True)

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeRead(EmployeeBase):
    id: int