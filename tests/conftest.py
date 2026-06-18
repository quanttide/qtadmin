"""pytest 共享 fixtures。"""

import json
from pathlib import Path

import pytest

CONTRACT_DIR = Path(__file__).parent / "contract"


@pytest.fixture
def contract_dir() -> Path:
    return CONTRACT_DIR


@pytest.fixture
def recruitment_contract() -> dict:
    path = CONTRACT_DIR / "recruitment.json"
    with open(path, encoding="utf-8") as f:
        return json.load(f)
