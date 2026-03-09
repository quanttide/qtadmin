# Agent Guidelines for qtadmin

## Project Overview

qtadmin is evolving from a payroll-focused backend into QuantTide's second-brain platform.

Current implementation is still centered on a Python FastAPI backend (`src/provider/`) with a Flutter client
(`src/studio/`).

## Documentation Workflow (Important)

Follow this docs flow strictly:

`docs/default -> other docs -> docs/meta`

Rules:
- `README.md` files are for **workflow/process** information.
- `index.md` files are for **content/summary** information.
- `docs/default` is the idea incubation layer.
- `other docs` (primarily `docs/prd`, `docs/dev`, and related domain docs) refine ideas into requirements and execution plans.
- `docs/meta` is the final project-level reflection layer.
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
