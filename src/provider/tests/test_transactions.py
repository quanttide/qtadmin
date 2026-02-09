"""
交易相关单元测试
测试边界：
- 交易创建参数校验
- 无效交易拦截
"""
import pytest
from fastapi.testclient import TestClient
from qtadmin_provider.main import app

@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client

def test_valid_transaction_creation(client):
    """测试有效交易创建"""
    valid_data = {"customer": "测试客户", "amount": 100000}
    response = client.post("/transactions", json=valid_data)
    assert response.status_code == 201
    assert "id" in response.json()
    assert response.json()["status"] == "pending"

def test_invalid_transaction_creation(client):
    """测试无效交易创建"""
    invalid_data = {"customer": ""}
    response = client.post("/transactions", json=invalid_data)
    assert response.status_code == 422
    assert "customer" in response.json()["detail"][0]["loc"]