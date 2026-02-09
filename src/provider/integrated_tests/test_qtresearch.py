"""
量潮科研服务集成测试
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession
from qtadmin_provider.main import app
from qtadmin_provider.models import Transaction, Project, CollaborationTopic

# Fixtures
@pytest.fixture
async def client_fixture():
    with TestClient(app) as client:
        yield client

@pytest.fixture
async def async_session_fixture():
    # ... existing database session setup ...
    yield

# Test cases
@pytest.mark.asyncio
async def test_full_research_lifecycle(client_fixture: TestClient, async_session_fixture: AsyncSession):
    """测试完整科研服务生命周期"""
    # 1. 发起阶段 - 创建交易
    transaction_data = {"customer": "测试客户", "amount": 100000}
    transaction_response = client_fixture.post("/transactions", json=transaction_data)
    assert transaction_response.status_code == 201
    transaction_id = transaction_response.json()["id"]

    # 2. 发起阶段 - 创建项目
    project_data = {"name": "测试项目", "transaction_id": transaction_id}
    project_response = client_fixture.post("/projects", json=project_data)
    assert project_response.status_code == 201
    project_id = project_response.json()["id"]

    # 3. 发起阶段 - 创建协作主题
    collab_data = {"title": "测试协作", "project_id": project_id}
    collab_response = client_fixture.post("/collaborations", json=collab_data)
    assert collab_response.status_code == 201
    collab_id = collab_response.json()["id"]

    # 4. 实施阶段 - 更新项目进度
    update_response = client_fixture.patch(f"/projects/{project_id}/progress", json={"progress": 50})
    assert update_response.status_code == 200

    # 5. 实施阶段 - 添加协作沟通
    message_data = {"content": "测试沟通内容", "topic_id": collab_id}
    message_response = client_fixture.post("/messages", json=message_data)
    assert message_response.status_code == 201

    # 6. 交付阶段 - 整理交付物
    deliverable_data = {"project_id": project_id, "documents": ["report.pdf"]}
    deliverable_response = client_fixture.post("/deliverables", json=deliverable_data)
    assert deliverable_response.status_code == 201

    # 7. 交付阶段 - 完成交易
    complete_response = client_fixture.post(f"/transactions/{transaction_id}/complete")
    assert complete_response.status_code == 200
