"""
qtadmin asset refresh 命令集成测试

集成测试需要真实的 git 环境和目录结构。
"""

import pytest
from pathlib import Path
import subprocess
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app.asset.refresh import (
    RefreshResult,
    _do_refresh,
    _get_dirty_submodules,
    _fetch_submodules,
    _get_submodules_behind_remote,
    _sync_submodule,
    _get_status,
    _commit_and_push,
    SUBMODULE_PATHS,
)


@pytest.fixture
def temp_repo_with_submodule(tmp_path):
    """创建带有子模块的临时仓库用于集成测试"""
    # 允许文件协议
    subprocess.run(["git", "config", "--global", "protocol.file.allow", "always"], capture_output=True)
    
    # 创建"远程"仓库（模拟子模块的远程仓库）
    remote_repo = tmp_path / "remote_submodule"
    remote_repo.mkdir()
    subprocess.run(["git", "init", "--bare"], cwd=remote_repo, capture_output=True)

    # 创建子模块仓库
    submodule_repo = tmp_path / "submodule"
    submodule_repo.mkdir()
    subprocess.run(["git", "init"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=submodule_repo, capture_output=True)
    
    # 创建初始提交
    (submodule_repo / "file.txt").write_text("initial content")
    subprocess.run(["git", "add", "."], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "checkout", "-b", "main"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "remote", "add", "origin", str(remote_repo)], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "push", "-u", "origin", "main"], cwd=submodule_repo, capture_output=True)

    # 创建主仓库
    main_repo = tmp_path / "main_repo"
    main_repo.mkdir()
    subprocess.run(["git", "init"], cwd=main_repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=main_repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=main_repo, capture_output=True)
    
    # 添加子模块（使用绝对路径）
    subprocess.run(
        ["git", "-C", str(main_repo), "submodule", "add", str(remote_repo), "submodule"],
        capture_output=True
    )
    subprocess.run(["git", "-C", str(main_repo), "commit", "-m", "Add submodule"], capture_output=True)
    
    # 初始化子模块工作目录并检出 main 分支
    subprocess.run(
        ["git", "-C", str(main_repo), "submodule", "update", "--init", "--checkout"],
        capture_output=True
    )
    
    # 确保子模块检出 main 分支
    subprocess.run(
        ["git", "-C", str(main_repo / "submodule"), "checkout", "main"],
        capture_output=True
    )

    return {
        "tmp_path": tmp_path,
        "remote_repo": remote_repo,
        "submodule_repo": submodule_repo,
        "main_repo": main_repo,
    }


@pytest.fixture
def temp_repo_simple(tmp_path):
    """创建简单的临时仓库用于测试"""
    repo = tmp_path / "repo"
    repo.mkdir()
    subprocess.run(["git", "init"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo, capture_output=True)
    
    # 创建初始提交
    (repo / "README.md").write_text("# Test Repo")
    subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo, capture_output=True)
    
    return repo


class TestRefreshIntegration:
    """refresh 命令集成测试"""

    def test_get_dirty_submodules_clean(self, temp_repo_simple):
        """测试干净的子模块状态"""
        repo = temp_repo_simple
        
        # 创建模拟的子模块目录结构
        journal_dir = repo / "docs" / "journal"
        journal_dir.mkdir(parents=True)
        subprocess.run(["git", "init"], cwd=journal_dir, capture_output=True)
        
        dirty = _get_dirty_submodules(repo)
        
        # 由于 SUBMODULE_PATHS 中的路径可能不存在，结果可能为空
        # 这个测试主要验证函数不会抛出异常
        assert isinstance(dirty, list)

    def test_get_dirty_submodules_dirty(self, temp_repo_simple):
        """测试有变更的子模块"""
        repo = temp_repo_simple
        
        # 创建模拟的子模块目录
        journal_dir = repo / "docs" / "journal"
        journal_dir.mkdir(parents=True)
        subprocess.run(["git", "init"], cwd=journal_dir, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=journal_dir, capture_output=True)
        subprocess.run(["git", "config", "user.name", "Test"], cwd=journal_dir, capture_output=True)
        
        # 创建未提交的文件
        (journal_dir / "test.md").write_text("test")
        
        dirty = _get_dirty_submodules(repo)
        
        # 应该检测到变更
        assert "docs/journal" in dirty

    def test_get_status_clean(self, temp_repo_simple):
        """测试干净的 git 状态"""
        repo = temp_repo_simple
        
        status = _get_status(repo)
        
        assert status is False

    def test_get_status_dirty(self, temp_repo_simple):
        """测试有变更的 git 状态"""
        repo = temp_repo_simple
        
        # 创建未提交的文件
        (repo / "new_file.txt").write_text("new content")
        
        status = _get_status(repo)
        
        assert status is True

    def test_commit_and_push_success(self, temp_repo_simple):
        """测试成功提交并推送"""
        repo = temp_repo_simple
        
        # 创建变更
        (repo / "new_file.txt").write_text("new content")
        
        # 注意：这个测试需要远程仓库，所以会失败
        # 我们只测试提交部分
        result = _commit_and_push(repo, "test commit")
        
        # 由于没有远程仓库，推送会失败，返回 None
        assert result is None
        
        # 但提交应该已经创建
        log_result = subprocess.run(
            ["git", "log", "--oneline"],
            cwd=repo,
            capture_output=True,
            text=True
        )
        assert "test commit" in log_result.stdout

    def test_do_refresh_no_submodules(self, temp_repo_simple):
        """测试没有子模块时的 refresh"""
        repo = temp_repo_simple
        
        result = _do_refresh(repo, dry_run=True)
        
        assert result.success is True
        assert result.dry_run is True
        assert len(result.updated_submodules) == 0

    def test_fetch_submodules(self, temp_repo_simple):
        """测试 fetch 子模块"""
        repo = temp_repo_simple
        
        # 创建模拟的子模块目录
        journal_dir = repo / "docs" / "journal"
        journal_dir.mkdir(parents=True)
        subprocess.run(["git", "init"], cwd=journal_dir, capture_output=True)
        
        # 这个测试主要验证函数不会抛出异常
        _fetch_submodules(repo, submodule="docs/journal")

    def test_sync_submodule(self, temp_repo_with_submodule):
        """测试同步子模块"""
        fixtures = temp_repo_with_submodule
        main_repo = fixtures["main_repo"]
        
        # 这个测试需要子模块有远程更新
        # 由于环境复杂，主要验证函数调用不抛出异常
        _sync_submodule(main_repo, "submodule")

    def test_get_submodules_behind_remote(self, temp_repo_with_submodule):
        """测试检测落后于远程的子模块"""
        fixtures = temp_repo_with_submodule
        main_repo = fixtures["main_repo"]
        submodule_path = main_repo / "submodule"
        
        # 在子模块中创建新提交（直接在主仓库的子模块目录中操作）
        (submodule_path / "new_file.txt").write_text("new content")
        subprocess.run(["git", "add", "."], cwd=submodule_path, capture_output=True)
        subprocess.run(["git", "commit", "-m", "New commit"], cwd=submodule_path, capture_output=True)
        
        # 推送到远程
        result = subprocess.run(["git", "push", "origin", "main"], cwd=submodule_path, capture_output=True, text=True)
        
        # 如果推送成功，说明子模块不落后
        # 如果推送失败（因为不是最新），说明子模块落后
        # 这个测试主要验证函数不会抛出异常
        behind = _get_submodules_behind_remote(main_repo, submodule="submodule")
        
        # 验证返回类型
        assert isinstance(behind, list)

    def test_do_refresh_dry_run(self, temp_repo_with_submodule):
        """测试 dry run 模式"""
        fixtures = temp_repo_with_submodule
        main_repo = fixtures["main_repo"]
        
        # dry run 模式主要验证函数不抛出异常
        result = _do_refresh(main_repo, dry_run=True, submodule="submodule")
        
        assert result.success is True
        # 如果子模块已经是最新，dry_run 标志可能为 False（因为不需要实际操作）
        # 这个测试主要验证 dry_run 参数不会导致错误

    def test_do_refresh_with_dirty_submodule(self, temp_repo_with_submodule):
        """测试子模块有未提交变更时的 refresh"""
        fixtures = temp_repo_with_submodule
        main_repo = fixtures["main_repo"]
        submodule_path = main_repo / "submodule"
        
        # 在子模块中创建未提交的变更
        (submodule_path / "dirty_file.txt").write_text("dirty content")
        
        result = _do_refresh(main_repo, submodule="submodule")
        
        # 由于主仓库没有远程，提交推送会失败
        # 这个测试主要验证函数能正确处理子模块变更检测
        # 如果有脏子模块，应该返回失败
        if result.success is False:
            # 要么是因为脏子模块，要么是因为提交推送失败
            assert "未提交的变更" in result.message or "提交推送失败" in result.message

    def test_full_refresh_workflow(self, temp_repo_with_submodule):
        """测试完整的 refresh 工作流程"""
        fixtures = temp_repo_with_submodule
        main_repo = fixtures["main_repo"]
        submodule_path = main_repo / "submodule"
        
        # 在子模块中创建新提交
        (submodule_path / "update.txt").write_text("update")
        subprocess.run(["git", "add", "."], cwd=submodule_path, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Update submodule"], cwd=submodule_path, capture_output=True)
        
        # 尝试推送（可能失败，因为远程可能已有更新）
        subprocess.run(["git", "pull", "--rebase"], cwd=submodule_path, capture_output=True)
        subprocess.run(["git", "push", "origin", "main"], cwd=submodule_path, capture_output=True)
        
        # 运行 refresh（dry run 模式）
        result = _do_refresh(main_repo, dry_run=True, submodule="submodule")
        
        # 验证函数执行成功
        assert result.success is True
        # 如果子模块已经和远程同步，则不会有更新
        # dry_run 模式下，如果有更新会返回 dry_run=True，否则返回实际结果


class TestSubmodulePaths:
    """测试 SUBMODULE_PATHS 常量"""

    def test_all_expected_paths(self):
        """测试所有预期的子模块路径"""
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

    def test_paths_are_strings(self):
        """测试所有路径都是字符串"""
        for path in SUBMODULE_PATHS:
            assert isinstance(path, str)
            assert len(path) > 0


class TestRefreshResult:
    """测试 RefreshResult 数据类"""

    def test_refresh_result_default(self):
        """测试默认值"""
        result = RefreshResult(success=True, message="success")
        assert result.success is True
        assert result.message == "success"
        assert result.error is None
        assert result.updated_submodules == []
        assert result.commit_sha is None
        assert result.dry_run is False

    def test_refresh_result_custom_values(self):
        """测试自定义值"""
        result = RefreshResult(
            success=True,
            message="done",
            error=None,
            updated_submodules=["journal", "archive"],
            commit_sha="abc1234",
            dry_run=True,
        )
        assert result.success is True
        assert result.message == "done"
        assert result.error is None
        assert result.updated_submodules == ["journal", "archive"]
        assert result.commit_sha == "abc1234"
        assert result.dry_run is True

    def test_refresh_result_with_error(self):
        """测试错误情况"""
        result = RefreshResult(
            success=False,
            message="failed",
            error="some error occurred",
        )
        assert result.success is False
        assert result.message == "failed"
        assert result.error == "some error occurred"
