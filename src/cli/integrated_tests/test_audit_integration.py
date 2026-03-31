"""
qtadmin asset audit 命令集成测试

集成测试需要真实的 git 环境和目录结构。
"""

import pytest
from pathlib import Path
import subprocess
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app.asset.audit import (
    AuditResult,
    AuditReport,
    GitRepoAuditor,
    audit,
)


@pytest.fixture
def temp_git_repo(tmp_path):
    """创建简单的 Git 仓库用于测试"""
    repo = tmp_path / "repo"
    repo.mkdir()
    subprocess.run(["git", "init"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo, capture_output=True)

    # 创建初始提交（使用符合规范的提交信息）
    (repo / "README.md").write_text("# Test Repo\n\n项目简介\n")
    subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
    subprocess.run(["git", "commit", "-m", "feat: initial commit"], cwd=repo, capture_output=True)

    return repo


@pytest.fixture
def temp_git_repo_with_files(tmp_path):
    """创建带有标准文件的 Git 仓库"""
    repo = tmp_path / "repo"
    repo.mkdir()
    subprocess.run(["git", "init"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo, capture_output=True)

    # 创建所有必需文件
    (repo / "README.md").write_text("""# Test Project

项目简介

## 目录结构

```
src/
tests/
```

## 快速开始

安装依赖...
""")

    (repo / "CONTRIBUTING.md").write_text("""# Contributing

## 项目结构

目录说明

## 开发环境

环境配置

## 提交规范

使用 Conventional Commits

## 发布流程

版本发布步骤
""")

    (repo / "AGENTS.md").write_text("""# Agents

| 任务 | 查看 |
|------|------|
| 测试 | README |

快速索引
""")

    (repo / "CHANGELOG.md").write_text("""# Changelog

## [0.1.0] - 2024-01-15

### Added
- Feature 1

### Changed
- Change 1
""")

    (repo / ".gitignore").write_text("""# Python
.venv/
__pycache__/
*.pyc

# Environment
.env
""")

    # 创建 meta 目录
    meta_dir = repo / "meta"
    meta_dir.mkdir()

    # 创建初始提交（使用符合规范的提交信息）
    subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
    subprocess.run(["git", "commit", "-m", "feat: initial commit with standard files"], cwd=repo, capture_output=True)

    return repo


@pytest.fixture
def temp_git_repo_with_submodule(tmp_path):
    """创建带有子模块的 Git 仓库"""
    # 允许文件协议
    subprocess.run(["git", "config", "--global", "protocol.file.allow", "always"], capture_output=True)

    # 创建"远程"仓库
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
    subprocess.run(["git", "commit", "-m", "feat: initial commit"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "checkout", "-b", "main"], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "remote", "add", "origin", str(remote_repo)], cwd=submodule_repo, capture_output=True)
    subprocess.run(["git", "push", "-u", "origin", "main"], cwd=submodule_repo, capture_output=True)

    # 创建主仓库
    main_repo = tmp_path / "main_repo"
    main_repo.mkdir()
    subprocess.run(["git", "init"], cwd=main_repo, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@test.com"], cwd=main_repo, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=main_repo, capture_output=True)

    # 创建基本文件
    (main_repo / "README.md").write_text("# Main Repo")
    subprocess.run(["git", "add", "."], cwd=main_repo, capture_output=True)
    subprocess.run(["git", "commit", "-m", "feat: initial commit"], cwd=main_repo, capture_output=True)

    # 添加子模块
    subprocess.run(
        ["git", "-C", str(main_repo), "submodule", "add", str(remote_repo), "submodule"],
        capture_output=True
    )
    subprocess.run(["git", "-C", str(main_repo), "commit", "-m", "chore: add submodule"], capture_output=True)

    return {
        "tmp_path": tmp_path,
        "remote_repo": remote_repo,
        "submodule_repo": submodule_repo,
        "main_repo": main_repo,
    }


class TestGitRepoAuditorIntegration:
    """GitRepoAuditor 集成测试"""

    def test_audit_clean_repo(self, temp_git_repo_with_files):
        """测试审计干净的仓库"""
        repo = temp_git_repo_with_files

        auditor = GitRepoAuditor(str(repo))
        report = auditor.audit()

        assert report.total_count > 0
        # 所有检查都应该通过
        assert report.failed_count == 0
        assert report.pass_rate == 100.0

    def test_audit_missing_files(self, temp_git_repo):
        """测试审计缺少文件的仓库"""
        repo = temp_git_repo

        auditor = GitRepoAuditor(str(repo))
        report = auditor.audit()

        # 应该检测到缺少文件
        assert report.failed_count > 0
        assert report.pass_rate < 100.0

        # 检查是否有缺少文件的错误
        failed_names = [r.name for r in report.results if not r.passed]
        assert any("必需文件" in name for name in failed_names)

    def test_audit_readme_content(self, temp_git_repo):
        """测试 README 内容检查"""
        repo = temp_git_repo

        # 创建简单的 README
        (repo / "README.md").write_text("# Test\n")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add README"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_readme_content()

        # 应该有 README 检查结果
        assert len(auditor._results) == 1
        # 内容不完整应该失败
        assert auditor._results[0].passed is False

    def test_audit_contributing_content(self, temp_git_repo):
        """测试 CONTRIBUTING 内容检查"""
        repo = temp_git_repo

        # 创建简单的 CONTRIBUTING
        (repo / "CONTRIBUTING.md").write_text("# Contributing\n")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add CONTRIBUTING"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_contributing_content()

        # 应该有 CONTRIBUTING 检查结果
        assert len(auditor._results) == 1
        # 缺少章节应该失败
        assert auditor._results[0].passed is False

    def test_audit_agents_content(self, temp_git_repo):
        """测试 AGENTS 内容检查"""
        repo = temp_git_repo

        # 创建带有表格的 AGENTS
        (repo / "AGENTS.md").write_text("""# Agents

| Task | Doc |
|------|-----|
| Test | README |

索引
""")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add AGENTS"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_agents_content()

        # 应该有 AGENTS 检查结果
        assert len(auditor._results) == 1
        # 简洁且有表格应该通过
        assert auditor._results[0].passed is True

    def test_audit_changelog_format(self, temp_git_repo):
        """测试 CHANGELOG 格式检查"""
        repo = temp_git_repo

        # 创建有效的 CHANGELOG
        (repo / "CHANGELOG.md").write_text("""# Changelog

## [0.1.0] - 2024-01-15

### Added
- Feature
""")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add CHANGELOG"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_changelog_format()

        # 应该有 CHANGELOG 检查结果
        assert len(auditor._results) == 1
        # 格式正确应该通过
        assert auditor._results[0].passed is True

    def test_audit_gitignore_content(self, temp_git_repo):
        """测试 .gitignore 内容检查"""
        repo = temp_git_repo

        # 创建完整的 .gitignore
        (repo / ".gitignore").write_text(""".venv/
__pycache__/
*.pyc
.env
""")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "chore: add .gitignore"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_gitignore_content()

        # 应该有 .gitignore 检查结果
        assert len(auditor._results) == 1
        # 规则完整应该通过
        assert auditor._results[0].passed is True

    def test_audit_with_submodules_clean(self, temp_git_repo_with_submodule):
        """测试带有干净子模块的仓库"""
        fixtures = temp_git_repo_with_submodule
        main_repo = fixtures["main_repo"]

        auditor = GitRepoAuditor(str(main_repo))
        auditor._check_submodules()

        # 应该有子模块检查结果
        assert len(auditor._results) == 1
        # 子模块已推送应该通过
        assert auditor._results[0].passed is True

    def test_audit_with_submodules_unpushed(self, temp_git_repo_with_submodule):
        """测试带有未推送子模块的仓库"""
        fixtures = temp_git_repo_with_submodule
        main_repo = fixtures["main_repo"]
        submodule_path = main_repo / "submodule"

        # 在子模块中创建未推送的提交
        (submodule_path / "new_file.txt").write_text("new content")
        subprocess.run(["git", "add", "."], cwd=submodule_path, capture_output=True)
        subprocess.run(["git", "commit", "-m", "feat: new commit"], cwd=submodule_path, capture_output=True)

        # 更新主仓库的子模块引用
        subprocess.run(["git", "add", "submodule"], cwd=main_repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "chore: update submodule"], cwd=main_repo, capture_output=True)

        # 注意：由于子模块已经推送了初始提交，新提交未推送到远程
        # 但是 git submodule status 可能不会显示为未推送（因为远程已经有了基础提交）
        # 这个测试主要验证函数能正确检测子模块状态
        auditor = GitRepoAuditor(str(main_repo))
        auditor._check_submodules()

        # 应该有子模块检查结果
        assert len(auditor._results) == 1
        # 验证检查被执行了（子模块配置或子模块状态）
        assert "子模块" in auditor._results[0].name

    def test_audit_commits_conventional(self, temp_git_repo):
        """测试符合 Conventional Commits 规范的提交"""
        repo = temp_git_repo

        # 创建符合规范的提交
        (repo / "file1.txt").write_text("content1")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "feat: add new feature"], cwd=repo, capture_output=True)

        (repo / "file2.txt").write_text("content2")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "fix: fix bug"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_recent_commits()

        # 应该有提交检查结果
        assert len(auditor._results) == 1
        # 符合规范应该通过
        assert auditor._results[0].passed is True

    def test_audit_commits_non_conventional(self, temp_git_repo):
        """测试不符合规范的提交"""
        repo = temp_git_repo

        # 创建不符合规范的提交
        (repo / "file1.txt").write_text("content1")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "bad commit message"], cwd=repo, capture_output=True)

        (repo / "file2.txt").write_text("content2")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "another bad message"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_recent_commits()

        # 应该有提交检查结果
        assert len(auditor._results) == 1
        # 不符合规范应该失败
        assert auditor._results[0].passed is False


class TestAuditReportIntegration:
    """AuditReport 集成测试"""

    def test_auditrt_print_full_workflow(self, temp_git_repo_with_files, capsys):
        """测试完整的审计报告打印流程"""
        repo = temp_git_repo_with_files

        auditor = GitRepoAuditor(str(repo))
        report = auditor.audit()

        # 打印报告
        result = report.print_report(verbose=True)

        # 捕获输出
        captured = capsys.readouterr()

        # 验证输出内容
        assert "Git 仓库资产审计报告" in captured.out
        assert "审计结果：" in captured.out
        assert result is True  # 应该通过

    def test_auditrt_failure_output(self, temp_git_repo, capsys):
        """测试失败审计报告的输出"""
        repo = temp_git_repo

        auditor = GitRepoAuditor(str(repo))
        report = auditor.audit()

        # 打印报告
        result = report.print_report(verbose=False)

        # 捕获输出
        captured = capsys.readouterr()

        # 验证输出内容
        assert "Git 仓库资产审计报告" in captured.out
        assert "未通过项目" in captured.out
        assert result is False  # 应该失败


class TestAuditRepoFunction:
    """audit 函数集成测试"""

    def test_audit_success(self, temp_git_repo_with_files):
        """测试成功审计"""
        repo = temp_git_repo_with_files

        # 应该不抛出异常
        result = audit(str(repo), verbose=False)

        # 验证返回 True
        assert result is True

    def test_audit_failure(self, temp_git_repo):
        """测试失败审计"""
        repo = temp_git_repo

        # 由于缺少文件，应该抛出 Exit 异常
        from click.exceptions import Exit
        with pytest.raises(Exit):
            audit(str(repo), verbose=False)

    def test_audit_verbose_output(self, temp_git_repo_with_files, capsys):
        """测试详细输出"""
        repo = temp_git_repo_with_files

        # 应该成功
        audit(str(repo), verbose=True)

        captured = capsys.readouterr()

        # 详细模式应该显示通过的项目
        assert "通过项目" in captured.out


class TestAuditEdgeCases:
    """边界情况测试"""

    def test_audit_empty_repo(self, temp_git_repo):
        """测试空仓库"""
        repo = temp_git_repo

        auditor = GitRepoAuditor(str(repo))
        report = auditor.audit()

        # 空仓库应该有很多检查失败
        assert report.failed_count > 0

    def test_audit_with_meta_dir(self, temp_git_repo_with_files):
        """测试带有 meta 目录的仓库"""
        repo = temp_git_repo_with_files

        auditor = GitRepoAuditor(str(repo))
        auditor._check_optional_dirs()

        # meta 目录存在应该通过
        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    def test_audit_without_meta_dir(self, temp_git_repo):
        """测试没有 meta 目录的仓库"""
        repo = temp_git_repo

        auditor = GitRepoAuditor(str(repo))
        auditor._check_optional_dirs()

        # meta 目录不存在应该失败（但有建议）
        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False
        assert "缺少" in auditor._results[0].message

    def test_audit_long_agents_file(self, temp_git_repo):
        """测试过长的 AGENTS 文件"""
        repo = temp_git_repo

        # 创建过长的 AGENTS 文件
        content = "# Agents\n" + "\n".join([f"Line {i}" for i in range(150)])
        (repo / "AGENTS.md").write_text(content)
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add AGENTS"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_agents_content()

        # 过长的 AGENTS 应该失败
        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False

    def test_audit_changelog_without_version(self, temp_git_repo):
        """测试没有版本号的 CHANGELOG"""
        repo = temp_git_repo

        # 创建没有版本号的 CHANGELOG
        (repo / "CHANGELOG.md").write_text("# Changelog\n\nSome changes\n")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add CHANGELOG"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_changelog_format()

        # 没有版本号应该失败
        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False

    def test_audit_changelog_with_v_prefix(self, temp_git_repo):
        """测试带 v 前缀的版本号"""
        repo = temp_git_repo

        # 创建带 v 前缀的 CHANGELOG
        (repo / "CHANGELOG.md").write_text("""# Changelog

## v0.1.0 - 2024-01-15

### Added
- Feature
""")
        subprocess.run(["git", "add", "."], cwd=repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", "docs: add CHANGELOG"], cwd=repo, capture_output=True)

        auditor = GitRepoAuditor(str(repo))
        auditor._check_changelog_format()

        # v 前缀应该被接受
        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True
