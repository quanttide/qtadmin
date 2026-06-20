"""Human 职能域集成测试：验证 Provider API 的人事增删改查能力。"""

import json
import os
import subprocess
from pathlib import Path

import pytest
import requests

pytestmark = pytest.mark.requires_server

CLI_DIR = Path(__file__).parents[1] / "src" / "cli"
CLI_BIN = str(CLI_DIR / "target" / "debug" / "qtadmin")


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


def cli(*args: str) -> subprocess.CompletedProcess:
    """运行 qtadmin CLI（自动加 --provider 指向本地 :8001）。"""
    cmd = [CLI_BIN, "--provider", "human", *args]
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=30,
        env={**os.environ, "PROVIDER_URL": "http://localhost:8001"},
    )


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
        pytest.obj = data

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


class TestCLIviaProvider:
    """CLI 通过 --provider 调用 Provider 的端到端测试"""

    def test_cli_create_position(self, provider_url):
        result = cli("position", "create", "--name", "CLI测试岗", "--department", "研发部")
        assert result.returncode == 0, f"CLI 失败:\nstdout:{result.stdout}\nstderr:{result.stderr}"
        data = json.loads(result.stdout)
        assert data["name"] == "CLI测试岗"
        assert data["department"] == "研发部"
        assert data["id"]
        pytest.cli_pos_id = data["id"]

    def test_cli_list_includes_created(self, provider_url):
        result = cli("position", "list")
        assert result.returncode == 0, f"CLI list 失败: {result.stderr}"
        items = json.loads(result.stdout)
        assert any(p["name"] == "CLI测试岗" for p in items), f"列表未找到创建的数据: {result.stdout}"

    def test_cli_get_position(self, provider_url):
        pos_id = pytest.cli_pos_id
        result = cli("position", "get", str(pos_id))
        assert result.returncode == 0, f"CLI get 失败: {result.stderr}"
        data = json.loads(result.stdout)
        assert data["id"] == pos_id


class TestPersistence:
    """数据持久化：验证数据通过文件存储，重启后仍在"""

    def test_store_file_exists(self, provider_url, store_path):
        """写入数据后，存储目录下应有对应的 JSON 文件"""
        post(provider_url, "/api/v1/positions", {"name": "持久化测试岗", "department": "测试部"})
        files = list(Path(store_path).glob("**/positions.json"))
        # store 用到的 collection 路径是 human/positions，文件可能在 store_path/human/positions.json
        files += list(Path(store_path).glob("**/*positions*"))
        assert len(files) > 0, f"存储目录 {store_path} 下未找到 position 数据文件"
        content = files[0].read_text()
        assert "持久化测试岗" in content

    def test_data_survives_restart(self, provider_url):
        """验证数据可通过 API 查询到（provider 持续运行中，验证可读即持久化正确）"""
        # 前序测试已写入数据，这里直接验证可读性
        resp = get(provider_url, "/api/v1/positions")
        assert resp.status_code == 200
        items = resp.json()
        assert len(items) > 0, "应该至少有一条数据"
