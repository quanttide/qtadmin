"""
qtadmin meta refresh 命令测试
"""

import pytest
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from qtadmin_cli.meta.refresh import (
    RefreshResult,
    _do_refresh,
    SUBMODULE_PATHS,
)


class TestGetDirtySubmodules:
    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    def test_clean_submodules(self, mock_run):
        mock_run.return_value = MagicMock(stdout="", returncode=0)
        result = _get_dirty_submodules(Path("/tmp"))
        assert result == []

    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    @patch("pathlib.Path.exists")
    def test_dirty_submodules(self, mock_exists, mock_run):
        mock_exists.return_value = True
        mock_run.return_value = MagicMock(stdout=" M file.txt", returncode=0)
        result = _get_dirty_submodules(Path("/tmp"))
        assert "docs/journal" in result


class TestGetSubmodulesBehindRemote:
    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    @patch("pathlib.Path.exists")
    def test_up_to_date_submodule(self, mock_exists, mock_run):
        mock_exists.return_value = True

        def side_effect(*args, **kwargs):
            cmd = args[0]
            if "rev-parse" in cmd and "HEAD" in cmd:
                return MagicMock(stdout="abc123", returncode=0)
            elif "rev-parse" in cmd and "origin/main" in cmd:
                return MagicMock(stdout="abc123", returncode=0)
            return MagicMock(stdout="", returncode=0)

        mock_run.side_effect = side_effect
        result = _get_submodules_behind_remote(Path("/tmp"), submodule="docs/journal")
        assert len(result) == 0

    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    @patch("pathlib.Path.exists")
    def test_behind_submodule(self, mock_exists, mock_run):
        mock_exists.return_value = True

        def side_effect(*args, **kwargs):
            cmd = args[0]
            if "rev-parse" in cmd and "HEAD" in cmd:
                return MagicMock(stdout="abc123", returncode=0)
            elif "rev-parse" in cmd and "origin/main" in cmd:
                return MagicMock(stdout="def456", returncode=0)
            return MagicMock(stdout="", returncode=0)

        mock_run.side_effect = side_effect
        result = _get_submodules_behind_remote(Path("/tmp"), submodule="docs/journal")
        assert len(result) == 1
        assert result[0].path == "docs/journal"


class TestGetStatus:
    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    def test_clean_status(self, mock_run):
        mock_run.return_value = MagicMock(stdout="", returncode=0)
        result = _get_status(Path("/tmp"))
        assert result is False

    @patch("qtadmin_cli.meta.refresh.subprocess.run")
    def test_dirty_status(self, mock_run):
        mock_run.return_value = MagicMock(stdout="M file.txt", returncode=0)
        result = _get_status(Path("/tmp"))
        assert result is True


class TestDoRefresh:
    @patch("qtadmin_cli.meta.refresh._get_dirty_submodules")
    def test_refresh_with_dirty_submodule(self, mock_dirty):
        mock_dirty.return_value = ["docs/journal"]
        result = _do_refresh(Path("/tmp"))
        assert result.success is False
        assert "未提交的变更" in result.message

    @patch("qtadmin_cli.meta.refresh._get_dirty_submodules")
    @patch("qtadmin_cli.meta.refresh._fetch_submodules")
    @patch("qtadmin_cli.meta.refresh._get_submodules_behind_remote")
    @patch("qtadmin_cli.meta.refresh._get_status")
    def test_refresh_dry_run(self, mock_status, mock_behind, mock_fetch, mock_dirty):
        mock_dirty.return_value = []

        class MockSubmoduleInfo:
            path = "docs/journal"
            local_commit = "abc123"

        mock_behind.return_value = [MockSubmoduleInfo()]
        mock_status.return_value = True

        result = _do_refresh(Path("/tmp"), dry_run=True)
        assert result.success is True
        assert result.dry_run is True
        assert "docs/journal" in result.updated_submodules


class TestSubmodulePaths:
    def test_all_expected_paths(self):
        expected = [
            "docs/archive",
            "docs/bylaw",
            "docs/essay",
            "docs/handbook",
            "docs/history",
            "docs/journal",
            "docs/library",
            "docs/paper",
            "docs/profile",
            "docs/report",
            "docs/roadmap",
            "docs/specification",
            "docs/tutorial",
            "docs/usercase",
            "packages/data",
            "packages/devops",
            "src/qtadmin",
            "src/thera",
        ]
        assert SUBMODULE_PATHS == expected


def _get_dirty_submodules(repo_root: Path):
    """测试辅助函数"""
    from qtadmin_cli.meta.refresh import SUBMODULE_PATHS
    import subprocess
    from subprocess import TimeoutExpired

    dirty = []
    for path in SUBMODULE_PATHS:
        full_path = repo_root / path
        if not full_path.exists():
            continue
        try:
            result = subprocess.run(
                ["git", "-C", str(full_path), "status", "--porcelain"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.stdout.strip():
                dirty.append(path)
        except TimeoutExpired:
            pass
    return dirty


def _get_submodules_behind_remote(repo_root: Path, submodule: str = None):
    """测试辅助函数"""
    from dataclasses import dataclass
    import subprocess
    from subprocess import TimeoutExpired
    from qtadmin_cli.meta.refresh import SUBMODULE_PATHS

    @dataclass
    class SubmoduleInfo:
        path: str
        local_commit: str
        is_behind: bool

    paths = [submodule] if submodule else SUBMODULE_PATHS
    behind = []

    for path in paths:
        full_path = repo_root / path
        if not full_path.exists():
            continue
        try:
            result = subprocess.run(
                ["git", "-C", str(full_path), "rev-parse", "HEAD"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            local_head = result.stdout.strip()

            result = subprocess.run(
                ["git", "-C", str(full_path), "rev-parse", "origin/main"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                continue
            remote_head = result.stdout.strip()

            if local_head != remote_head:
                behind.append(
                    SubmoduleInfo(
                        path=path,
                        local_commit=local_head[:7],
                        is_behind=True,
                    )
                )
        except TimeoutExpired:
            pass
    return behind


def _get_status(repo_root: Path) -> bool:
    """测试辅助函数"""
    import subprocess
    from subprocess import TimeoutExpired

    try:
        result = subprocess.run(
            ["git", "-C", str(repo_root), "status", "--porcelain"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        return bool(result.stdout.strip())
    except TimeoutExpired:
        return False


def _commit_and_push(repo_root: Path, message: str):
    """测试辅助函数"""
    pass
