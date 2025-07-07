# integrated_tests/test_system.py
import pytest
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, create_engine, Session
from datetime import date

from app.main import app
from app.database import get_session
from app.models.employee import Employee
from app.models.salary import SalaryCalculation


# 测试数据库设置
@pytest.fixture(name="engine")
def engine_fixture():
    """创建测试数据库引擎"""
    engine = create_engine(
        "sqlite:///:memory:",
        echo=False,
        connect_args={"check_same_thread": False}
    )
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture(name="session")
def session_fixture(engine):
    """创建数据库会话"""
    with Session(engine) as session:
        yield session


@pytest.fixture(name="client")
def client_fixture(session):
    """创建测试客户端"""
    def get_session_override():
        return session

    app.dependency_overrides[get_session] = get_session_override

    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


def test_full_salary_workflow(client, session):
    """测试完整薪资工作流：创建员工->计算薪资->保存记录->查询记录"""
    # 步骤1: 创建员工
    employee_payload = {"name": "李四", "position": "设计师", "department": "设计部"}
    employee_response = client.post("/api/v1/employees", json=employee_payload)
    assert employee_response.status_code == 201  # 修正状态码
    employee = employee_response.json()

    # 步骤2: 计算薪资
    salary_params = {
        "base_hours": 160,
        "hourly_rate": 30,
        "overtime_hours": 5,
        "deductions": 150
    }
    calculate_response = client.post("/api/v1/salary/calculate", json=salary_params)
    assert calculate_response.status_code == 200
    calculation = calculate_response.json()

    # 步骤3: 创建薪资记录
    salary_record = {
        "employee_id": employee["id"],
        "base_hours": salary_params["base_hours"],
        "hourly_rate": salary_params["hourly_rate"],
        "overtime_hours": salary_params["overtime_hours"],
        "deductions": salary_params["deductions"],
        "period_start": "2025-01-01",
        "period_end": "2025-01-31"
    }
    record_response = client.post("/api/v1/salary/records", json=salary_record)
    assert record_response.status_code == 200
    saved_record = record_response.json()

    # 验证薪资计算正确性
    base_salary = salary_params["base_hours"] * salary_params["hourly_rate"]
    overtime_pay = salary_params["overtime_hours"] * salary_params["hourly_rate"] * 1.5
    performance_bonus = base_salary * 0.1
    net_salary = base_salary + overtime_pay + performance_bonus - salary_params["deductions"]

    assert saved_record["calculated_salary"] == net_salary

    # 步骤4: 查询薪资记录
    query_params = {
        "period_start": "2025-01-01",
        "period_end": "2025-01-31"
    }
    records_response = client.get("/api/v1/salary/records", params=query_params)
    assert records_response.status_code == 200
    records = records_response.json()

    assert len(records) == 1
    assert records[0]["id"] == saved_record["id"]
    assert records[0]["employee_id"] == employee["id"]

    # 验证部门查询
    dept_records = client.get(
        "/api/v1/salary/records",
        params={
            "period_start": "2025-01-01",
            "period_end": "2025-01-31",
            "department": "设计部"
        }
    )
    assert dept_records.status_code == 200
    assert len(dept_records.json()) == 1

    # 验证员工详情中的薪资记录
    employee_details = client.get(f"/api/v1/employees/{employee['id']}")
    assert employee_details.status_code == 200
    assert len(employee_details.json()["salaries"]) == 1
    assert employee_details.json()["salaries"][0]["id"] == saved_record["id"]