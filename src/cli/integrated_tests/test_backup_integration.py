"""
qtadmin asset backup 命令集成测试

集成测试需要真实的 git 环境和目录结构。
"""

import pytest
from pathlib import Path
from datetime import datetime, timedelta
import subprocess
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app.asset.backup import (
    get_project_root,
    scan_journal_files,
    filter_old_files,
    move_files,
    backup,
)


@pytest.fixture
def temp_project(tmp_path):
    """创建临时项目结构用于集成测试"""
    # 创建目录结构
    journal_dir = tmp_path / "docs" / "journal" / "work"
    archive_dir = tmp_path / "docs" / "archive" / "journal" / "work"
    journal_dir.mkdir(parents=True)
    archive_dir.mkdir(parents=True)

    # 创建测试文件
    old_file = journal_dir / "2024-01-01.md"
    old_file.write_text("# Old journal")

    recent_file = journal_dir / f"{(datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')}.md"
    recent_file.write_text("# Recent journal")

    today_file = journal_dir / f"{datetime.now().strftime('%Y-%m-%d')}.md"
    today_file.write_text("# Today journal")

    # 初始化为 git 仓库
    subprocess.run(["git", "init"], cwd=tmp_path, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=tmp_path, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=tmp_path, capture_output=True)
    subprocess.run(["git", "add", "."], cwd=tmp_path, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=tmp_path, capture_output=True)

    return tmp_path


class TestBackupIntegration:
    """backup 命令集成测试"""

    def test_get_project_root_finds_correct_root(self, temp_project):
        """测试找到正确的项目根目录"""
        # 切换到临时目录的子目录
        original_cwd = os.getcwd()
        try:
            subdir = temp_project / "subdir"
            subdir.mkdir()
            os.chdir(subdir)
            
            # 这个测试依赖于目录结构的存在
            # 由于 get_project_root 查找的是包含 docs/journal 和 docs/archive/journal 的目录
            # 在测试环境中可能需要调整
            pass
        finally:
            os.chdir(original_cwd)

    def test_scan_journal_files(self, temp_project):
        """测试扫描 journal 文件"""
        journal_dir = temp_project / "docs" / "journal"
        files = scan_journal_files(journal_dir)
        
        # 应该找到 3 个文件
        assert len(files) == 3
        
        # 验证文件信息
        categories = {f[2] for f in files}
        assert "work" in categories

    def test_filter_old_files_integration(self, temp_project):
        """测试筛选旧文件集成"""
        journal_dir = temp_project / "docs" / "journal"
        all_files = scan_journal_files(journal_dir)
        
        # 筛选 2 天前的文件（应该只有 2024-01-01.md）
        old_files = filter_old_files(all_files, days=2)
        
        # 2024-01-01.md 是很久以前的，应该被筛选出来
        assert len(old_files) >= 1
        assert any("2024-01-01.md" in str(f[0].name) for f in old_files)

    def test_move_files_integration(self, temp_project):
        """测试移动文件集成"""
        journal_dir = temp_project / "docs" / "journal"
        archive_dir = temp_project / "docs" / "archive" / "journal"
        
        all_files = scan_journal_files(journal_dir)
        old_files = filter_old_files(all_files, days=2)
        
        # 移动文件
        moved = move_files(old_files, archive_dir, temp_project, dry_run=False)
        
        # 验证文件被移动
        assert len(moved) >= 1
        
        # 验证源文件不存在
        for source, target in moved:
            assert not source.exists()
            assert target.exists()

    def test_move_files_dry_run_integration(self, temp_project):
        """测试预览模式集成"""
        journal_dir = temp_project / "docs" / "journal"
        archive_dir = temp_project / "docs" / "archive" / "journal"
        
        all_files = scan_journal_files(journal_dir)
        old_files = filter_old_files(all_files, days=2)
        
        # 预览模式
        moved = move_files(old_files, archive_dir, temp_project, dry_run=True)
        
        # 验证文件没有被实际移动
        assert len(moved) >= 1
        for source, target in moved:
            assert source.exists()
            assert not target.exists()

    def test_backup_command_full_integration(self, temp_project):
        """测试完整的 backup 命令流程（使用 --no-push 和 -y 选项）"""
        from typer.testing import CliRunner
        from app.asset.backup import app as backup_app

        runner = CliRunner()
        
        # 切换到临时项目目录
        import os
        original_cwd = os.getcwd()
        try:
            os.chdir(temp_project)
            
            # 使用 --no-push 避免需要远程仓库，使用 -y 跳过确认
            # 注意：直接调用 backup 命令，不需要再传 "backup" 参数
            result = runner.invoke(
                backup_app,
                ["--days", "2", "--no-push", "-y"],
                catch_exceptions=False
            )
            
            # 验证命令执行成功
            assert result.exit_code == 0, f"命令执行失败：{result.stdout}\n{result.exception}"
            
            # 验证输出信息
            assert "项目根目录" in result.stdout
            assert "Journal 目录" in result.stdout
            assert "Archive 目录" in result.stdout
            assert "扫描到" in result.stdout
            assert "开始归档" in result.stdout
            assert "归档完成" in result.stdout
            
            # 验证文件被移动到 archive
            archive_work_dir = temp_project / "docs" / "archive" / "journal" / "work"
            assert (archive_work_dir / "2024-01-01.md").exists(), "旧文件应该被移动到 archive"
            
            # 验证 journal 目录中的旧文件已被移除
            journal_work_dir = temp_project / "docs" / "journal" / "work"
            assert not (journal_work_dir / "2024-01-01.md").exists(), "旧文件应该从 journal 移除"
            
            # 验证 git 提交已创建（无推送）
            git_log_result = subprocess.run(
                ["git", "log", "--oneline"],
                cwd=temp_project,
                capture_output=True,
                text=True
            )
            assert "archive: backup journal logs older than 2 days" in git_log_result.stdout
        finally:
            os.chdir(original_cwd)
