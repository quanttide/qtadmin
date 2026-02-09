"""
工资计算单元测试
测试边界：
- 有效工资参数计算
- 无效参数拦截
- 边界条件校验（如加班阈值）
"""
import pytest
from fastapi.testclient import TestClient
from qtadmin_provider.main import app

@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client

def test_basic_salary_calculation():
    """测试基础计时工资计算"""
    from qtadmin_provider.salaries import calculate_salary
    
    # 正常情况计算
    assert calculate_salary(160, 100) == 160*100 + 160*100*0.1
    # 含加班费计算
    assert calculate_salary(160, 100, 10) == (160*100) + (10*100*1.5) + (160*100*0.1)
    # 扣款测试
    assert calculate_salary(160, 100, deductions=500) == (160*100*1.1) - 500

def test_boundary_conditions():
    """测试边界条件"""
    from qtadmin_provider.salaries import calculate_salary
    
    # 最低工资保障
    assert calculate_salary(0, 100, deductions=1000) == 0
    # 加班费边界
    assert calculate_salary(175, 80, 0) == 175*80*1.1

def test_invalid_inputs():
    """测试非法输入"""
    from qtadmin_provider.salaries import calculate_salary
    
    with pytest.raises(ValueError):
        calculate_salary(-40, 100)
        
    with pytest.raises(ValueError):
        calculate_salary(160, -20)

def test_valid_salary_calculation(client):
    """测试有效工资计算"""
    # 基础工资计算
    base_response = client.post("/salaries/calculate", json={
        "base_hours": 160,
        "hourly_rate": 100,
        "overtime_hours": 10,
        "deductions": 500
    })
    assert base_response.status_code == 200
    assert base_response.json()["net_salary"] == 160*100 + 10*150 - 500  # 假设加班费是1.5倍

def test_boundary_overtime_threshold(client):
    """测试刚好达到加班阈值"""
    response = client.post("/salaries/calculate", json={
        "base_hours": 175,
        "hourly_rate": 80,
        "overtime_hours": 0,
        "deductions": 0
    })
    assert response.status_code == 200
    assert response.json()["overtime_pay"] == 0

def test_invalid_negative_hours(client):
    """测试负数工作时间"""
    response = client.post("/salaries/calculate", json={
        "base_hours": -40,
        "hourly_rate": 100,
        "overtime_hours": 10
    })
    assert response.status_code == 422

def test_unsupported_salary_type(client):
    """测试不支持的工资类型"""
    response = client.post("/salaries/calculate", json={
        "salary_type": "daily",
        "days_worked": 20,
        "daily_rate": 500
    })
    assert response.status_code == 422