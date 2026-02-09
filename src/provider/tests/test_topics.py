"""
协作主题单元测试
测试边界：
- 协作主题创建约束
- 消息关联性校验
- 数据完整性校验
"""
import pytest
from fastapi.testclient import TestClient
from qtadmin_provider.main import app

@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client

@pytest.fixture
def existing_project(client):
    """创建预置项目"""
    transaction_id = client.post("/transactions", json={
        "customer": "测试客户",
        "amount": 100000
    }).json()["id"]
    return client.post("/projects", json={
        "name": "测试项目",
        "transaction_id": transaction_id
    }).json()

def test_create_collaboration_topic(client, existing_project):
    """测试协作主题创建"""
    response = client.post("/collaborations", json={
        "title": "技术讨论",
        "project_id": existing_project["id"]
    })
    assert response.status_code == 201
    assert response.json()["status"] == "active"

def test_create_topic_with_invalid_project_id(client):
    """测试无效项目ID创建协作主题"""
    response = client.post("/collaborations", json={
        "title": "无效主题",
        "project_id": "invalid_project_id"
    })
    assert response.status_code == 404

def test_create_message_without_topic(client, existing_project):
    """测试无主题消息拦截"""
    response = client.post("/messages", json={
        "content": "测试消息",
        "topic_id": "invalid_topic_id"
    })
    assert response.status_code == 404