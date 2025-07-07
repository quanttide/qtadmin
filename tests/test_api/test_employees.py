# tests/test_api/test_employees.py
import pytest
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, create_engine, Session
from sqlalchemy import text

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
    # 确保创建所有表
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


def test_database_tables_exist(session):
    """验证数据库表是否存在"""
    try:
        # 检查employee表
        result = session.exec(text("SELECT name FROM sqlite_master WHERE type='table' AND name='employee'"))
        assert result.first() is not None, "employee表不存在"
        
        # 检查salarycalculation表
        result = session.exec(text("SELECT name FROM sqlite_master WHERE type='table' AND name='salarycalculation'"))
        assert result.first() is not None, "salarycalculation表不存在"
    except Exception as e:
        pytest.fail(f"数据库表验证失败: {e}")


def test_create_employee(client):
    """测试创建员工API"""
    payload = {
        "name": "张三",
        "position": "工程师",
        "department": "技术部"
    }

    response = client.post("/api/v1/employees", json=payload)
    assert response.status_code == 201  # 修正状态码

    employee = response.json()
    assert employee["name"] == "张三"
    assert employee["id"] is not None


def test_get_employees(client, session):
    """测试获取员工列表API"""
    # 创建测试数据
    employee1 = Employee(name="员工1", position="工程师", department="技术部")
    employee2 = Employee(name="员工2", position="设计师", department="设计部")
    session.add(employee1)
    session.add(employee2)
    session.commit()

    # 获取所有员工
    response = client.get("/api/v1/employees")
    assert response.status_code == 200
    employees = response.json()
    assert len(employees) == 2

    # 按部门筛选
    response = client.get("/api/v1/employees", params={"department": "技术部"})
    assert response.status_code == 200
    tech_employees = response.json()
    assert len(tech_employees) == 1
    assert tech_employees[0]["name"] == "员工1"


def test_get_employee(client, session):
    """测试获取单个员工信息API"""
    # 创建测试数据
    employee = Employee(name="测试员工", position="经理", department="管理部")
    session.add(employee)
    session.commit()

    # 获取员工
    response = client.get(f"/api/v1/employees/{employee.id}")
    assert response.status_code == 200
    fetched_employee = response.json()
    assert fetched_employee["name"] == "测试员工"

    # 获取不存在的员工
    response = client.get("/api/v1/employees/999")
    assert response.status_code == 404
    assert "员工不存在" in response.json()["detail"]


def test_update_employee(client, session):
    """测试更新员工信息API"""
    # 创建测试数据
    employee = Employee(name="原姓名", position="原职位", department="原部门")
    session.add(employee)
    session.commit()

    # 更新员工
    update_payload = {
        "name": "新姓名",
        "position": "新职位",
        "department": "新部门"
    }

    response = client.put(f"/api/v1/employees/{employee.id}", json=update_payload)
    assert response.status_code == 200
    updated_employee = response.json()
    assert updated_employee["position"] == "新职位"
    assert updated_employee["department"] == "新部门"

    # 验证数据库更新
    db_employee = session.get(Employee, employee.id)
    assert db_employee.position == "新职位"


def test_delete_employee(client, session):
    """测试删除员工API"""
    # 创建测试数据
    employee = Employee(name="待删除员工", position="职位", department="部门")
    session.add(employee)
    session.commit()

    # 删除员工
    response = client.delete(f"/api/v1/employees/{employee.id}")
    assert response.status_code == 204  # 修正状态码
    assert response.content == b''  # 204状态码应该没有内容

    # 验证员工已删除
    response = client.get(f"/api/v1/employees/{employee.id}")
    assert response.status_code == 404