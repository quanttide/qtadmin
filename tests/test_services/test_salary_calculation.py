# tests/test_services/test_salary_calculation.py
import pytest
from datetime import date
from sqlmodel import SQLModel, create_engine, Session

from app.models.salary import SalaryCalculation, SalaryCalculationCreate
from app.models.employee import Employee
from app.services.salary_calculation import (
    calculate_salary,
    create_salary_record,
    get_records_by_period
)
from app.schemas.salary import SalaryCalculationParams


# 测试数据库设置
@pytest.fixture(name="engine")
def engine_fixture():
    """创建测试数据库引擎"""
    engine = create_engine(
        "sqlite:///:memory:",
        echo=False,
        connect_args={"check_same_thread": False}
    )
    # 确保创建所有表
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="session")
def session_fixture(engine):
    """创建数据库会话"""
    with Session(engine) as session:
        yield session


@pytest.fixture(name="test_employee")
def create_test_employee(session):
    """创建测试员工"""
    employee = Employee(name="测试员工", position="工程师", department="技术部")
    session.add(employee)
    session.commit()
    session.refresh(employee)
    return employee


def test_calculate_salary_valid_params():
    """测试薪资计算服务-有效参数"""
    params = SalaryCalculationParams(
        base_hours=160,
        hourly_rate=25,
        overtime_hours=10,
        deductions=200
    )

    result = calculate_salary(params)

    # 计算预期值
    base_salary = 160 * 25
    overtime_pay = 10 * 25 * 1.5
    performance_bonus = base_salary * 0.1
    net_salary = base_salary + overtime_pay + performance_bonus - 200

    assert result.net_salary == net_salary
    assert result.base_salary == base_salary
    assert result.overtime_pay == overtime_pay
    assert result.performance_bonus == performance_bonus


def test_calculate_salary_negative_params():
    """测试薪资计算服务-负值参数"""
    from pydantic import ValidationError
    with pytest.raises(ValidationError) as exc_info:
        SalaryCalculationParams(
            base_hours=-10,
            hourly_rate=25,
            overtime_hours=0,
            deductions=0
        )
    assert "ensure this value is greater than or equal to 0" in str(exc_info.value)


def test_create_salary_record(session, test_employee):
    """测试创建薪资记录服务"""
    params = SalaryCalculationCreate(
        employee_id=test_employee.id,
        base_hours=160,
        hourly_rate=25,
        overtime_hours=10,
        deductions=200,
        period_start=date(2025, 1, 1),
        period_end=date(2025, 1, 31)
    )

    record = create_salary_record(session, params)

    assert record.id is not None
    assert record.calculated_salary > 0
    assert record.employee_id == test_employee.id

    # 验证记录已保存到数据库
    db_record = session.get(SalaryCalculation, record.id)
    assert db_record is not None


def test_get_records_by_period(session, test_employee):
    """测试按周期查询薪资记录服务"""
    # 创建测试记录
    record1 = SalaryCalculation(
        employee_id=test_employee.id,
        base_hours=160,
        hourly_rate=25,
        overtime_hours=10,
        deductions=200,
        period_start=date(2025, 1, 1),
        period_end=date(2025, 1, 31),
        calculated_salary=5000
    )
    record2 = SalaryCalculation(
        employee_id=test_employee.id,
        base_hours=150,
        hourly_rate=30,
        overtime_hours=5,
        deductions=100,
        period_start=date(2025, 2, 1),
        period_end=date(2025, 2, 28),
        calculated_salary=6000
    )
    session.add(record1)
    session.add(record2)
    session.commit()

    # 查询1月份记录
    records = get_records_by_period(
        session,
        date(2025, 1, 1),
        date(2025, 1, 31)
    )
    assert len(records) == 1
    assert records[0].period_start == date(2025, 1, 1)

    # 查询所有记录
    all_records = get_records_by_period(
        session,
        date(2025, 1, 1),
        date(2025, 12, 31)
    )
    assert len(all_records) == 2

    # 按部门查询
    tech_records = get_records_by_period(
        session,
        date(2025, 1, 1),
        date(2025, 12, 31),
        "技术部"
    )
    assert len(tech_records) == 2

    # 查询不存在的部门
    market_records = get_records_by_period(
        session,
        date(2025, 1, 1),
        date(2025, 12, 31),
        "市场部"
    )
    assert len(market_records) == 0