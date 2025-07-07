# app/api/v1/employees.py
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from app.models.employee import Employee, EmployeeCreate, EmployeeRead, EmployeeWithSalaries
from app.database import get_session

router = APIRouter()

@router.post("", response_model=EmployeeRead,status_code=201)#删掉了双引号的斜杠
def create_employee(
    employee: EmployeeCreate,
    session: Session = Depends(get_session)
):
    db_employee = Employee(**employee.dict())
    session.add(db_employee)
    session.commit()
    session.refresh(db_employee)
    return db_employee

@router.get("", response_model=list[EmployeeRead])
def get_employees(department: str = None, session: Session = Depends(get_session)):
    query = select(Employee)
    if department:
        query = query.where(Employee.department == department)
    return session.exec(query).all()

@router.get("/{employee_id}", response_model=EmployeeWithSalaries)
def get_employee(employee_id: int, session: Session = Depends(get_session)):
    employee = session.get(Employee, employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="员工不存在")
    return employee


# 添加 PUT 更新员工信息
@router.put("/{employee_id}", response_model=EmployeeRead)
def update_employee(
        employee_id: int,
        update_data: EmployeeCreate,  # 使用 EmployeeCreate 或创建 EmployeeUpdate 模型
        session: Session = Depends(get_session)
):
    employee = session.get(Employee, employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="员工不存在")

    # 更新员工信息
    employee_data = update_data.dict(exclude_unset=True)
    for key, value in employee_data.items():
        setattr(employee, key, value)

    session.add(employee)
    session.commit()
    session.refresh(employee)
    return employee


# 添加 DELETE 删除员工
@router.delete("/{employee_id}", status_code=204)
def delete_employee(
        employee_id: int,
        session: Session = Depends(get_session)
):
    employee = session.get(Employee, employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="员工不存在")

    session.delete(employee)
    session.commit()
    return  # 返回 204 No Content