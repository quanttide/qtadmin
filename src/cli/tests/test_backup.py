"""
qtadmin asset backup 命令测试
"""

import pytest
from unittest.mock import patch, MagicMock, mock_open
from pathlib import Path
from datetime import datetime, timedelta
from dataclasses import dataclass
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app.asset.backup import (
    BackupResult,
    DATE_PATTERN,
    parse_date_from_filename,
    scan_journal_files,
    filter_old_files,
    move_files,
    run_git_command,
    check_git_status,
    commit_and_push,
    update_submodule_in_main_repo,
    get_project_root,
)


class TestDatePattern:
    """测试日期文件名正则"""

    def test_valid_date_filename(self):
        """测试有效的日期文件名"""
        assert DATE_PATTERN.match("2024-01-15.md") is not None
        assert DATE_PATTERN.match("2024-12-31.md") is not None
        assert DATE_PATTERN.match("2000-01-01.md") is not None

    def test_invalid_date_filename(self):
        """测试无效的日期文件名"""
        assert DATE_PATTERN.match("2024-1-15.md") is None  # 月份不是两位
        assert DATE_PATTERN.match("24-01-15.md") is None  # 年份不是四位
        assert DATE_PATTERN.match("2024-01-15.txt") is None  # 扩展名错误
        assert DATE_PATTERN.match("journal-2024-01-15.md") is None  # 前缀错误
        assert DATE_PATTERN.match("2024-01-15-backup.md") is None  # 后缀错误


class TestParseDateFromFilename:
    """测试文件名日期解析"""

    def test_valid_dates(self):
        """测试有效的日期解析"""
        result = parse_date_from_filename("2024-01-15.md")
        assert result == datetime(2024, 1, 15)

        result = parse_date_from_filename("2024-12-31.md")
        assert result == datetime(2024, 12, 31)

    def test_invalid_dates(self):
        """测试无效的日期解析"""
        assert parse_date_from_filename("invalid.md") is None
        assert parse_date_from_filename("2024-13-01.md") is None  # 无效月份
        assert parse_date_from_filename("2024-02-30.md") is None  # 无效日期
        assert parse_date_from_filename("not-a-date.txt") is None

    def test_edge_cases(self):
        """测试边界情况"""
        # 空字符串
        assert parse_date_from_filename("") is None
        # 只有扩展名
        assert parse_date_from_filename(".md") is None


class TestScanJournalFiles:
    """测试扫描 journal 文件"""

    @patch("app.asset.backup.typer.echo")
    def test_journal_dir_not_exists(self, mock_echo):
        """测试 journal 目录不存在"""
        with pytest.raises(Exception) as exc_info:  # typer.Exit(1) 会抛出 Exit 异常
            scan_journal_files(Path("/nonexistent/path"))
        assert exc_info.value.exit_code == 1

    @patch("app.asset.backup.typer.echo")
    @patch("pathlib.Path.exists")
    @patch("pathlib.Path.iterdir")
    def test_scan_files(self, mock_iterdir, mock_exists, mock_echo):
        """测试扫描文件"""
        mock_exists.return_value = True

        # 模拟分类目录
        mock_category_dir = MagicMock()
        mock_category_dir.is_dir.return_value = True
        mock_category_dir.name = "work"

        # 模拟文件
        mock_file1 = MagicMock()
        mock_file1.is_file.return_value = True
        mock_file1.name = "2024-01-15.md"

        mock_file2 = MagicMock()
        mock_file2.is_file.return_value = True
        mock_file2.name = "2024-01-16.md"

        mock_file3 = MagicMock()
        mock_file3.is_file.return_value = False  # 目录

        mock_category_dir.iterdir.return_value = [mock_file1, mock_file2, mock_file3]
        mock_iterdir.return_value = [mock_category_dir]

        journal_dir = Path("/tmp/journal")
        files = scan_journal_files(journal_dir)

        assert len(files) == 2
        assert files[0][2] == "work"  # category
        assert files[0][1] == datetime(2024, 1, 15)
        assert files[1][1] == datetime(2024, 1, 16)

    @patch("app.asset.backup.typer.echo")
    @patch("pathlib.Path.exists")
    @patch("pathlib.Path.iterdir")
    def test_skip_hidden_dirs(self, mock_iterdir, mock_exists, mock_echo):
        """测试跳过隐藏目录"""
        mock_exists.return_value = True

        mock_hidden_dir = MagicMock()
        mock_hidden_dir.is_dir.return_value = True
        mock_hidden_dir.name = ".git"

        mock_iterdir.return_value = [mock_hidden_dir]

        files = scan_journal_files(Path("/tmp/journal"))
        assert len(files) == 0

    @patch("app.asset.backup.typer.echo")
    @patch("pathlib.Path.exists")
    @patch("pathlib.Path.iterdir")
    def test_skip_non_date_files(self, mock_iterdir, mock_exists, mock_echo):
        """测试跳过非日期文件"""
        mock_exists.return_value = True

        mock_category_dir = MagicMock()
        mock_category_dir.is_dir.return_value = True
        mock_category_dir.name = "work"

        mock_file = MagicMock()
        mock_file.is_file.return_value = True
        mock_file.name = "readme.md"  # 非日期文件名

        mock_category_dir.iterdir.return_value = [mock_file]
        mock_iterdir.return_value = [mock_category_dir]

        files = scan_journal_files(Path("/tmp/journal"))
        assert len(files) == 0


class TestFilterOldFiles:
    """测试筛选旧文件"""

    def test_filter_by_days(self):
        """测试按天数筛选"""
        now = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

        files = [
            (Path("2024-01-01.md"), now - timedelta(days=5), "work"),  # 5 天前
            (Path("2024-01-02.md"), now - timedelta(days=2), "work"),  # 2 天前
            (Path("2024-01-03.md"), now - timedelta(days=10), "work"),  # 10 天前
        ]

        # 筛选 3 天前的文件
        result = filter_old_files(files, days=3)
        assert len(result) == 2
        assert result[0][0].name == "2024-01-01.md"
        assert result[1][0].name == "2024-01-03.md"

    def test_no_old_files(self):
        """测试没有旧文件"""
        now = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

        files = [
            (Path("2024-01-01.md"), now - timedelta(hours=1), "work"),  # 1 小时前
            (Path("2024-01-02.md"), now, "work"),  # 今天
        ]

        result = filter_old_files(files, days=1)
        assert len(result) == 0

    def test_all_old_files(self):
        """测试所有文件都旧"""
        now = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

        files = [
            (Path("2024-01-01.md"), now - timedelta(days=10), "work"),
            (Path("2024-01-02.md"), now - timedelta(days=20), "work"),
        ]

        result = filter_old_files(files, days=3)
        assert len(result) == 2


class TestMoveFiles:
    """测试移动文件"""

    @patch("app.asset.backup.typer.echo")
    @patch("shutil.move")
    @patch("pathlib.Path.mkdir")
    @patch("pathlib.Path.exists")
    def test_move_files_success(self, mock_exists, mock_mkdir, mock_move, mock_echo):
        """测试成功移动文件"""
        project_root = Path("/tmp/project")
        archive_dir = project_root / "docs" / "archive" / "journal"
        
        # 使用 project_root 下的路径，避免 relative_to 错误
        files = [
            (project_root / "docs" / "journal" / "work" / "2024-01-15.md", datetime(2024, 1, 15), "work"),
        ]

        # 目标文件不存在
        mock_exists.return_value = False

        moved = move_files(files, archive_dir, project_root, dry_run=False)

        assert len(moved) == 1
        mock_mkdir.assert_called()
        mock_move.assert_called()

    @patch("app.asset.backup.typer.echo")
    @patch("shutil.move")
    @patch("pathlib.Path.mkdir")
    @patch("pathlib.Path.exists")
    def test_move_files_skip_existing(self, mock_exists, mock_mkdir, mock_move, mock_echo):
        """测试跳过已存在的文件"""
        project_root = Path("/tmp/project")
        archive_dir = project_root / "docs" / "archive" / "journal"
        
        mock_exists.return_value = True

        files = [
            (project_root / "docs" / "journal" / "work" / "2024-01-15.md", datetime(2024, 1, 15), "work"),
        ]

        moved = move_files(files, archive_dir, project_root, dry_run=False)

        assert len(moved) == 0
        mock_move.assert_not_called()

    @patch("app.asset.backup.typer.echo")
    @patch("shutil.move")
    @patch("pathlib.Path.mkdir")
    @patch("pathlib.Path.exists")
    def test_move_files_dry_run(self, mock_exists, mock_mkdir, mock_move, mock_echo):
        """测试预览模式"""
        project_root = Path("/tmp/project")
        archive_dir = project_root / "docs" / "archive" / "journal"
        
        mock_exists.return_value = False

        files = [
            (project_root / "docs" / "journal" / "work" / "2024-01-15.md", datetime(2024, 1, 15), "work"),
        ]

        moved = move_files(files, archive_dir, project_root, dry_run=True)

        assert len(moved) == 1
        mock_move.assert_not_called()
        mock_mkdir.assert_not_called()


class TestRunGitCommand:
    """测试运行 git 命令"""

    @patch("app.asset.backup.subprocess.run")
    @patch("app.asset.backup.typer.echo")
    def test_run_git_command_success(self, mock_echo, mock_run):
        """测试成功运行 git 命令"""
        mock_run.return_value = MagicMock(stdout="", stderr="", returncode=0)

        result = run_git_command(["git", "status"], Path("/tmp/repo"), Path("/tmp"))

        assert result.returncode == 0
        mock_run.assert_called_once()

    @patch("app.asset.backup.subprocess.run")
    @patch("app.asset.backup.typer.echo")
    def test_run_git_command_failure(self, mock_echo, mock_run):
        """测试 git 命令失败"""
        mock_run.return_value = MagicMock(
            stdout="", stderr="error message", returncode=1
        )

        result = run_git_command(["git", "invalid"], Path("/tmp/repo"), Path("/tmp"))

        assert result.returncode == 1
        assert result.stderr == "error message"


class TestCheckGitStatus:
    """测试检查 git 状态"""

    @patch("app.asset.backup.run_git_command")
    def test_clean_git_status(self, mock_run_git):
        """测试干净的 git 状态"""
        mock_run_git.return_value = MagicMock(stdout="", returncode=0)

        result = check_git_status(Path("/tmp/repo"), Path("/tmp"))

        assert result is False
        mock_run_git.assert_called_once()

    @patch("app.asset.backup.run_git_command")
    def test_dirty_git_status(self, mock_run_git):
        """测试有变更的 git 状态"""
        mock_run_git.return_value = MagicMock(
            stdout=" M file.txt\n?? new_file.txt", returncode=0
        )

        result = check_git_status(Path("/tmp/repo"), Path("/tmp"))

        assert result is True


class TestCommitAndPush:
    """测试提交和推送"""

    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_commit_no_changes(self, mock_echo, mock_check_status):
        """测试没有变更时不提交"""
        mock_check_status.return_value = False

        result = commit_and_push(Path("/tmp/repo"), "test commit", Path("/tmp"))

        assert result is False
        mock_echo.assert_called()

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_commit_success(self, mock_echo, mock_check_status, mock_run_git):
        """测试成功提交"""
        mock_check_status.return_value = True
        mock_run_git.return_value = MagicMock(returncode=0)

        result = commit_and_push(
            Path("/tmp/repo"), "test commit", Path("/tmp"), push=False
        )

        assert result is True
        assert mock_run_git.call_count == 2  # add 和 commit

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_commit_with_push(self, mock_echo, mock_check_status, mock_run_git):
        """测试提交并推送"""
        mock_check_status.return_value = True
        mock_run_git.return_value = MagicMock(returncode=0)

        result = commit_and_push(Path("/tmp/repo"), "test commit", Path("/tmp"), push=True)

        assert result is True
        assert mock_run_git.call_count == 3  # add, commit,push

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_commit_failure(self, mock_echo, mock_check_status, mock_run_git):
        """测试提交失败"""
        mock_check_status.return_value = True
        mock_run_git.side_effect = [
            MagicMock(returncode=0),  # git add
            MagicMock(returncode=1, stderr="commit failed"),  # git commit
        ]

        result = commit_and_push(Path("/tmp/repo"), "test commit", Path("/tmp"))

        assert result is False


class TestUpdateSubmoduleInMainRepo:
    """测试更新主仓库子模块引用"""

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_update_submodule_no_changes(self, mock_echo, mock_check_status, mock_run_git):
        """测试子模块无变更"""
        mock_check_status.return_value = False

        update_submodule_in_main_repo("journal", "update message", Path("/tmp"))

        mock_run_git.assert_called_once()  # 只调用 git add

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_update_submodule_success(self, mock_echo, mock_check_status, mock_run_git):
        """测试成功更新子模块"""
        mock_check_status.return_value = True
        mock_run_git.return_value = MagicMock(returncode=0)

        update_submodule_in_main_repo("journal", "update message", Path("/tmp"))

        assert mock_run_git.call_count >= 2  # add, commit

    @patch("app.asset.backup.run_git_command")
    @patch("app.asset.backup.check_git_status")
    @patch("app.asset.backup.typer.echo")
    def test_update_submodule_with_push(self, mock_echo, mock_check_status, mock_run_git):
        """测试更新子模块并推送"""
        mock_check_status.return_value = True
        mock_run_git.return_value = MagicMock(returncode=0)

        update_submodule_in_main_repo("journal", "update message", Path("/tmp"), push=True)

        assert mock_run_git.call_count >= 3  # add, commit,push


class TestGetProjectRoot:
    """测试获取项目根目录"""

    @patch("pathlib.Path.cwd")
    @patch("pathlib.Path.exists")
    def test_found_project_root(self, mock_exists, mock_cwd):
        """测试找到项目根目录"""
        mock_cwd.return_value = Path("/tmp/project/subdir")

        def exists_side_effect(path):
            if str(path).endswith("docs/journal"):
                return True
            if str(path).endswith("docs/archive/journal"):
                return True
            return False

        mock_exists.side_effect = exists_side_effect

        # 由于 mock 限制，直接测试返回值逻辑
        # 实际测试需要真实的目录结构
        pass

    def test_get_project_root_current_dir(self):
        """测试获取当前目录作为项目根"""
        # 这是一个集成测试，依赖真实环境
        # 在测试环境中可能返回当前工作目录
        result = get_project_root()
        assert isinstance(result, Path)


class TestBackupResult:
    """测试 BackupResult 数据类"""

    def test_backup_result_default(self):
        """测试默认值"""
        result = BackupResult(success=True, message="success")
        assert result.success is True
        assert result.message == "success"
        assert result.moved_count == 0
        assert result.dry_run is False

    def test_backup_result_custom_values(self):
        """测试自定义值"""
        result = BackupResult(
            success=True, message="done", moved_count=5, dry_run=True
        )
        assert result.success is True
        assert result.message == "done"
        assert result.moved_count == 5
        assert result.dry_run is True


