"""pytest 共享 fixtures。"""

import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path

import pytest

PROVIDER_DIR = Path(__file__).parents[1] / "src" / "provider"


@pytest.fixture(scope="session")
def provider_url():
    """启动 Provider 进程并等待就绪，返回 base URL。"""
    env = {
        "ADDR": ":8001",
        "CONFIG_PATH": str(PROVIDER_DIR / "testdata" / "config.json"),
    }
    proc = subprocess.Popen(
        ["go", "run", "./cmd/server"],
        cwd=PROVIDER_DIR,
        env=env,
    )

    url = "http://localhost:8001"
    _wait_for_health(url, timeout=30)
    yield url
    proc.terminate()
    proc.wait()


def _wait_for_health(url: str, timeout: int):
    """轮询 /health 直到返回 200。"""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            resp = urllib.request.urlopen(f"{url}/health")
            if resp.status == 200:
                return
        except urllib.error.URLError:
            pass
        time.sleep(0.5)
    pytest.fail(f"Provider 未在 {timeout}s 内就绪")
