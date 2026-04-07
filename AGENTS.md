# Agent Guidelines for qtadmin

## Project Overview

qtadmin is evolving from a payroll-focused backend into QuantTide's second-brain platform.

Current implementation is still centered on a Python FastAPI backend (`src/provider/`) with a Flutter client
(`src/studio/`).

## Documentation Workflow

Documentation follows role-based structure:

- `docs/dev/` - Development documentation (technical specs, API docs)
- `docs/ops/` - Operations documentation (deployment, maintenance)

Rules:
- `README.md` files are for **workflow/process** information.
- `index.md` files are for **content/summary** information.
- If a workflow rule changes, update the relevant `README.md` first.

## Build/Lint/Test Commands

### Setup
```bash
cd src/provider
pdm install  # Install dependencies using PDM
```

### Running Tests
```bash
# Run all tests
cd src/provider
pytest

# Run a single test file
pytest tests/test_projects.py

# Run a single test function
pytest tests/test_projects.py::test_project_creation_with_valid_transaction

# Run with coverage
pytest --cov=app --cov-report=html
```

### Running the Application
```bash
cd src/provider
pdm run uvicorn app:app --reload
# Or
python -m app
```

### Code Quality (Recommended - Not Yet Configured)
Add to `pyproject.toml`:
```toml
[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]
ignore = ["E501"]

[tool.black]
line-length = 100

[tool.isort]
profile = "black"
```

Then use:
```bash
ruff check .
ruff format .
```

## Code Style Guidelines

### General
- Use **Python 3.10+** features (e.g., built-in collection types as type hints)
- Use **snake_case** for function/variable names
- Use **PascalCase** for class names
- Use **Chinese** for docstrings and comments (project convention)
- Keep lines under **100 characters** when practical

### Imports
- Group imports in order: stdlib → third-party → local
- Use absolute imports from project root (e.g., `from app.models.employee import ...`)
- Avoid wildcard imports (`from module import *`)

Example:
```python
# stdlib
from typing import List, Optional, TYPE_CHECKING

# third-party
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select, SQLModel

# local
from app.models.employee import Employee
from app.database import get_session
```

### Type Hints
- Always add type hints for function parameters and return values
- Use `Optional[X]` instead of `X | None`
- Use `list[X]` instead of `List[X]` (Python 3.9+)
- Use `TYPE_CHECKING` block for circular imports:

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.salary import SalaryCalculation
```

### Naming Conventions
- **Variables/functions**: `snake_case` (e.g., `get_employee`, `employee_list`)
- **Classes**: `PascalCase` (e.g., `EmployeeCreate`, `EmployeeRead`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Files**: `snake_case.py` (e.g., `employee_service.py`)

### Pydantic/SQLModel Models
Follow this pattern:
```python
class EmployeeBase(SQLModel):
    name: str
    position: str

class Employee(EmployeeBase, table=True):
    id: int = Field(default=None, primary_key=True)

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeRead(EmployeeBase):
    id: int
```

### Error Handling
- Use `HTTPException` for API errors with appropriate status codes
- Return meaningful error messages in Chinese
- Validate inputs using Pydantic models

```python
from fastapi import HTTPException

@router.get("/{employee_id}")
def get_employee(employee_id: int, session: Session = Depends(get_session)):
    employee = session.get(Employee, employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="员工不存在")
    return employee
```

### API Routes
- Use plural nouns for collections: `/employees`, `/projects`
- Use proper HTTP methods: `GET` (retrieve), `POST` (create), `PUT` (update), `DELETE` (delete), `PATCH` (partial update)
- Return appropriate status codes: `200` (OK), `201` (Created), `204` (No Content), `404` (Not Found), `422` (Validation Error)

### Database
- Use SQLModel for ORM models
- Use dependency injection for database sessions
- Always commit after write operations

```python
from fastapi import Depends
from sqlmodel import Session
from app.database import get_session

@router.post("")
def create_employee(employee: EmployeeCreate, session: Session = Depends(get_session)):
    db_employee = Employee(**employee.dict())
    session.add(db_employee)
    session.commit()
    session.refresh(db_employee)
    return db_employee
```

### Testing
- Use `pytest` with `pytest-asyncio` for async tests
- Use `TestClient` from `fastapi.testclient` for API testing
- Place tests in `tests/` directory mirroring the app structure
- Use fixtures for common test setup

```python
import pytest
from fastapi.testclient import TestClient
from qtadmin_provider.main import app

@pytest.fixture
def client():
    with TestClient(app) as test_client:
        yield test_client

def test_get_employees(client):
    response = client.get("/employees")
    assert response.status_code == 200
```

### Async/Await
- Use `async def` for async route handlers
- Use `await` for async operations
- Keep async functions non-blocking

### Project Structure
```
src/provider/
├── app/
│   ├── __init__.py
│   ├── __main__.py
│   ├── config.py
│   ├── database.py
│   ├── api/
│   │   ├── dependencies.py
│   │   └── v1/
│   ├── models/
│   ├── schemas/
│   └── services/
├── tests/
├── integrated_tests/
├── pyproject.toml
└── README.md
```

### Dependencies
- Primary: FastAPI, SQLModel, Uvicorn, Pydantic, python-dotenv
- Dev: pytest, httpx, pytest-asyncio, pytest-cov

## Git 提交规范

### 默认工具：commitizen

使用 `commitizen` 生成符合 Conventional Commits 规范的 commit message。

**基本用法：**
```bash
# 交互式创建规范提交
cz commit
# 或简写
cz c

# 自动版本升级 + 生成 CHANGELOG
cz bump
```

**Commit 类型：**

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add user authentication` |
| `fix` | 修复 bug | `fix: resolve null pointer exception` |
| `docs` | 文档更新 | `docs: update README` |
| `test` | 测试相关 | `test: add unit tests for api` |
| `refactor` | 代码重构 | `refactor: simplify logic` |
| `chore` | 构建/工具 | `chore: update dependencies` |

## 发布规范

### 项目结构

qtadmin 为 monorepo，包含三个独立项目：

| 项目 | 路径 | 入口文件 |
|------|------|---------|
| provider | `src/provider/` | `pyproject.toml` |
| studio | `src/studio/` | `pubspec.yaml` |
| cli | `src/cli/` | `pyproject.toml` |

### 版本标签规范

使用 `项目名/版本号` 格式，符合社区 monorepo 习惯：

```bash
# provider 发布
git tag provider/v0.0.1
git push origin provider/v0.0.1

# cli 发布
git tag cli/v0.0.1
git push origin cli/v0.0.1

# studio 发布
git tag studio/v0.0.1
git push origin studio/v0.0.1
```

### 发布流程

1. **更新版本号** - 在 `pyproject.toml` 或 `pubspec.yaml` 中更新版本号
2. **更新 CHANGELOG.md** - 总结该版本所有变更（alpha/beta 版本应合并总结）
3. **提交变更** - `git commit`
4. **创建标签** - `git tag <project>/v<version>`
5. **推送标签** - `git push origin <project>/v<version>`
6. **创建 GitHub Release** - 使用 `gh release create` 创建正式发布说明

### 版本规范

遵循语义化版本（SemVer）：
- alpha: `v0.0.1-alpha.1`
- beta: `v0.0.1-beta.1`
- release: `v0.0.1`

## Utilities

### Taking Screenshots
Use Python with Pillow:
```python
from PIL import ImageGrab
img = ImageGrab.grab()
img.save('docs/user/screenshot.png')
```
Requires `pip install Pillow`.
