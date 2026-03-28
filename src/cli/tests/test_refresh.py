"""
qtadmin meta refresh 命令测试
"""

import pytest
from unittest.mock import patch, MagicMock
from pathlib import Path
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from qtadmin_cli.cli import (
    RefreshResult,
    _do_refresh,
    _get_dirty_submodules,
    _get_submodules_behind_remote,
    _get_status,
    SUBMODULE_PATHS,
)


class TestGetDirtySubmodules:
    @patch("subprocess.run")
    def test_clean_submodules(self, mock_run):
        mock_run.return_value = MagicMock(stdout="", returncode=0)
        result = _get_dirty_submodules(Path("."))
        assert result == []

    @patch("subprocess.run")
    def test_dirty_submodules(self, mock_run):
        mock_run.return_value = MagicMock(stdout=" M file.txt", returncode=0)
        result = _get_dirty_submodules(Path("."))
        assert "docs/journal" in result


class TestGetSubmodulesBehindRemote:
    @patch("subprocess.run")
    def test_up_to_date_submodule(self, mock_run):
        mock_run.return_value = MagicMock(stdout="abc123", returncode=0)
        result = _get_submodules_behind_remote(Path("."), submodule="docs/journal")
        assert len(result) == 0

    @patch("subprocess.run")
    def test_behind_submodule(self, mock_run):
        def side_effect(*args, **kwargs):
            cmd = args[0]
            if "rev-parse" in cmd and "HEAD" in cmd:
                return MagicMock(stdout="abc123", returncode=0)
            elif "rev-parse" in cmd and "origin/main" in cmd:
                return MagicMock(stdout="def456", returncode=0)
            return MagicMock(stdout="", returncode=0)

        mock_run.side_effect = side_effect
        result = _get_submodules_behind_remote(Path("."), submodule="docs/journal")
        assert len(result) == 1
        assert result[0].path == "docs/journal"


class TestGetStatus:
    @patch("subprocess.run")
    def test_clean_status(self, mock_run):
        mock_run.return_value = MagicMock(stdout="", returncode=0)
        result = _get_status(Path("."))
        assert result is False

    @patch("subprocess.run")
    def test_dirty_status(self, mock_run):
        mock_run.return_value = MagicMock(stdout="M file.txt", returncode=0)
        result = _get_status(Path("."))
        assert result is True


class TestDoRefresh:
    @patch("qtadmin_cli.cli._get_dirty_submodules")
    @patch("qtadmin_cli.cli._fetch_submodules")
    @patch("qtadmin_cli.cli._get_submodules_behind_remote")
    @patch("qtadmin_cli.cli._get_status")
    def test_refresh_with_dirty_submodule(
        self, mock_status, mock_behind, mock_fetch, mock_dirty
    ):
        mock_dirty.return_value = ["docs/journal"]
        result = _do_refresh(Path("."))
        assert result.success is False
        assert "未提交的变更" in result.message

    @patch("qtadmin_cli.cli._get_dirty_submodules")
    @patch("qtadmin_cli.cli._fetch_submodules")
    @patch("qtadmin_cli.cli._get_submodules_behind_remote")
    @patch("qtadmin_cli.cli._get_status")
    def test_refresh_already_up_to_date(
        self, mock_status, mock_behind, mock_fetch, mock_dirty
    ):
        mock_dirty.return_value = []
        mock_behind.return_value = []
        mock_status.return_value = False
        result = _do_refresh(Path("."))
        assert result.success is True
        assert "已是最新" in result.message

    @patch("qtadmin_cli.cli._get_dirty_submodules")
    @patch("qtadmin_cli.cli._fetch_submodules")
    @patch("qtadmin_cli.cli._get_submodules_behind_remote")
    @patch("qtadmin_cli.cli._sync_submodule")
    @patch("qtadmin_cli.cli._get_status")
    @patch("qtadmin_cli.cli._commit_and_push")
    def test_refresh_with_updates(
        self, mock_commit, mock_status, mock_sync, mock_behind, mock_fetch, mock_dirty
    ):
        mock_dirty.return_value = []

        class MockSubmoduleInfo:
            def __init__(self):
                self.path = "docs/journal"
                self.local_commit = "abc123"

        mock_behind.return_value = [MockSubmoduleInfo()]
        mock_status.return_value = True
        mock_commit.return_value = "abc1234"

        result = _do_refresh(Path("."))
        assert result.success is True
        assert "已提交并推送" in result.message

    @patch("qtadmin_cli.cli._get_dirty_submodules")
    @patch("qtadmin_cli.cli._fetch_submodules")
    @patch("qtadmin_cli.cli._get_submodules_behind_remote")
    @patch("qtadmin_cli.cli._get_status")
    def test_refresh_dry_run(self, mock_status, mock_behind, mock_fetch, mock_dirty):
        mock_dirty.return_value = []

        class MockSubmoduleInfo:
            def __init__(self):
                self.path = "docs/journal"
                self.local_commit = "abc123"

        mock_behind.return_value = [MockSubmoduleInfo()]
        mock_status.return_value = True

        result = _do_refresh(Path("."), dry_run=True)
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
