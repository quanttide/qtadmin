"""Human 职能域集成测试：验证 Provider API 的人事增删改查能力。"""

import json

import pytest
import requests

pytestmark = pytest.mark.requires_server


def post(provider_url, path, data=None):
    url = f"{provider_url}{path}"
    if data is not None:
        resp = requests.post(url, json=data)
    else:
        resp = requests.post(url)
    return resp


def put(provider_url, path, data):
    return requests.put(f"{provider_url}{path}", json=data)


def get(provider_url, path):
    return requests.get(f"{provider_url}{path}")


def delete(provider_url, path):
    return requests.delete(f"{provider_url}{path}")


class TestPositionLifecycle:
    """岗位管理：创建 → 查询 → 列表 → 更新 → 删除"""

    POSITION = {
        "name": "后端工程师",
        "department": "研发部",
        "description": "Golang 开发",
    }
    POSITION_UPDATED = {
        "name": "高级后端工程师",
        "department": "研发部",
        "description": "Golang 架构设计",
    }

    def test_create(self, provider_url):
        resp = post(provider_url, "/api/v1/positions", self.POSITION)
        assert resp.status_code == 201, f"创建岗位失败: {resp.text}"
        data = resp.json()
        assert data["name"] == self.POSITION["name"]
        assert data["department"] == self.POSITION["department"]
        assert data["description"] == self.POSITION["description"]
        assert data["id"], "应返回非空ID"
        pytest.obj = data  # 暂存给后续测试

    def test_get(self, provider_url):
        position_id = pytest.obj["id"]
        resp = get(provider_url, f"/api/v1/positions/{position_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["name"] == self.POSITION["name"]

    def test_list(self, provider_url):
        resp = get(provider_url, "/api/v1/positions")
        assert resp.status_code == 200
        items = resp.json()
        assert isinstance(items, list)
        assert any(p["name"] == self.POSITION["name"] for p in items)

    def test_update(self, provider_url):
        position_id = pytest.obj["id"]
        resp = put(provider_url, f"/api/v1/positions/{position_id}", self.POSITION_UPDATED)
        assert resp.status_code == 200, f"更新岗位失败: {resp.text}"
        data = resp.json()
        assert data["name"] == self.POSITION_UPDATED["name"]

    def test_delete(self, provider_url):
        position_id = pytest.obj["id"]
        resp = delete(provider_url, f"/api/v1/positions/{position_id}")
        assert resp.status_code == 204, f"删除岗位失败: {resp.text}"

        resp = get(provider_url, f"/api/v1/positions/{position_id}")
        assert resp.status_code == 404


class TestEmployeeLifecycle:
    """员工管理：入职 → 查询 → 列表 → 转岗 → 离职"""

    EMPLOYEE = {
        "name": "张三",
        "department": "研发部",
        "position": "后端工程师",
        "hire_date": "2026-01-15",
        "status": "active",
    }
    EMPLOYEE_UPDATED = {
        "name": "张三",
        "department": "架构部",
        "position": "架构师",
        "hire_date": "2026-01-15",
        "status": "active",
    }

    def test_hire(self, provider_url):
        resp = post(provider_url, "/api/v1/employees", self.EMPLOYEE)
        assert resp.status_code == 201, f"创建员工失败: {resp.text}"
        data = resp.json()
        assert data["name"] == self.EMPLOYEE["name"]
        assert data["status"] == "active"
        assert data["id"]
        pytest.emp = data

    def test_get(self, provider_url):
        emp_id = pytest.emp["id"]
        resp = get(provider_url, f"/api/v1/employees/{emp_id}")
        assert resp.status_code == 200
        assert resp.json()["name"] == self.EMPLOYEE["name"]

    def test_list(self, provider_url):
        resp = get(provider_url, "/api/v1/employees")
        assert resp.status_code == 200
        items = resp.json()
        assert isinstance(items, list)
        assert any(e["name"] == self.EMPLOYEE["name"] for e in items)

    def test_transfer(self, provider_url):
        emp_id = pytest.emp["id"]
        resp = put(provider_url, f"/api/v1/employees/{emp_id}", self.EMPLOYEE_UPDATED)
        assert resp.status_code == 200, f"转岗失败: {resp.text}"
        data = resp.json()
        assert data["position"] == "架构师"

    def test_leave(self, provider_url):
        emp_id = pytest.emp["id"]
        resp = delete(provider_url, f"/api/v1/employees/{emp_id}")
        assert resp.status_code == 204

        resp = get(provider_url, f"/api/v1/employees/{emp_id}")
        assert resp.status_code == 404


class TestDepartmentLifecycle:
    """部门管理"""

    def test_create_and_query(self, provider_url):
        resp = post(provider_url, "/api/v1/departments", {"name": "测试部", "leader": "李四"})
        assert resp.status_code == 201
        data = resp.json()
        dept_id = data["id"]

        resp = get(provider_url, f"/api/v1/departments/{dept_id}")
        assert resp.status_code == 200

        resp = get(provider_url, "/api/v1/departments")
        assert resp.status_code == 200
        assert any(d["name"] == "测试部" for d in resp.json())

    def test_invalid_creation(self, provider_url):
        resp = post(provider_url, "/api/v1/departments", {})
        assert resp.status_code == 400

        resp = post(provider_url, "/api/v1/employees", {})
        assert resp.status_code == 400

        resp = post(provider_url, "/api/v1/positions", {})
        assert resp.status_code == 400
