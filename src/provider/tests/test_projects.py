"""
项目相关单元测试
测试边界：
- 项目创建参数校验
- 进度更新校验
- 无效交易关联拦截
"""
import pytest
from fastapi.testclient import TestClient
from qtadmin_provider.main import app

@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client

@pytest.fixture
def valid_transaction(client):
    """预创建有效交易"""
    return client.post("/transactions", json={
        "customer": "测试客户",
        "amount": 100000
    }).json()

def test_project_creation_with_valid_transaction(client, valid_transaction):
    """测试有效交易关联的项目创建"""
    response = client.post("/projects", json={
        "name": "有效项目",
        "transaction_id": valid_transaction["id"]
    })
    assert response.status_code == 201
    assert response.json()["status"] == "initiated"

def test_project_creation_with_invalid_transaction(client):
    """测试无效交易关联拦截"""
    response = client.post("/projects", json={
        "name": "无效项目",
        "transaction_id": "invalid_transaction_id"
    })
    assert response.status_code == 404

def test_progress_update_validation(client, valid_transaction):
    """测试进度更新范围校验"""
    project_id = client.post("/projects", json={
        "name": "进度测试项目",
        "transaction_id": valid_transaction["id"]
    }).json()["id"]
    
    # 测试非法进度值
    invalid_response = client.patch(f"/projects/{project_id}/progress", json={"progress": 150})
    assert invalid_response.status_code == 422
    
    # 测试有效进度值
    valid_response = client.patch(f"/projects/{project_id}/progress", json={"progress": 50})
    assert valid_response.status_code == 200