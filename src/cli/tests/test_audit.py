"""
qtadmin asset audit 命令测试
"""

import pytest
from unittest.mock import patch, MagicMock, mock_open
from pathlib import Path
import sys
import os
import typer

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app.asset.audit import (
    AuditResult,
    AuditReport,
    GitRepoAuditor,
    audit_repo,
)


class TestAuditResult:
    """测试 AuditResult 数据类"""

    def test_audit_result_default(self):
        """测试默认值"""
        result = AuditResult(name="Test", passed=True, message="OK")
        assert result.name == "Test"
        assert result.passed is True
        assert result.message == "OK"
        assert result.suggestion is None

    def test_audit_result_with_suggestion(self):
        """测试带建议的审计结果"""
        result = AuditResult(
            name="Test",
            passed=False,
            message="Failed",
            suggestion="Fix it"
        )
        assert result.name == "Test"
        assert result.passed is False
        assert result.message == "Failed"
        assert result.suggestion == "Fix it"


class TestAuditReport:
    """测试 AuditReport 数据类"""

    def test_audit_report_default(self):
        """测试默认值"""
        report = AuditReport(repo_path="/tmp/repo")
        assert report.repo_path == "/tmp/repo"
        assert report.total_count == 0
        assert report.passed_count == 0
        assert report.failed_count == 0
        assert report.pass_rate == 0.0

    def test_audit_report_with_results(self):
        """测试带结果的审计报告"""
        report = AuditReport(repo_path="/tmp/repo")
        report.results = [
            AuditResult(name="Test1", passed=True, message="OK"),
            AuditResult(name="Test2", passed=False, message="Failed", suggestion="Fix"),
            AuditResult(name="Test3", passed=True, message="OK"),
        ]
        assert report.total_count == 3
        assert report.passed_count == 2
        assert report.failed_count == 1
        assert report.pass_rate == pytest.approx(66.666, rel=0.1)

    def test_audit_report_empty_results(self):
        """测试空结果的通过率"""
        report = AuditReport(repo_path="/tmp/repo")
        assert report.pass_rate == 0.0

    @patch("app.asset.audit.print")
    def test_audit_report_print_success(self, mock_print):
        """测试打印成功的审计报告"""
        report = AuditReport(repo_path="/tmp/repo")
        report.results = [
            AuditResult(name="Test1", passed=True, message="OK"),
        ]
        result = report.print_report(verbose=False)
        assert result is True
        mock_print.assert_called()

    @patch("app.asset.audit.print")
    def test_audit_report_print_failure(self, mock_print):
        """测试打印失败的审计报告"""
        report = AuditReport(repo_path="/tmp/repo")
        report.results = [
            AuditResult(name="Test1", passed=False, message="Failed", suggestion="Fix"),
        ]
        result = report.print_report(verbose=False)
        assert result is False
        mock_print.assert_called()

    @patch("app.asset.audit.print")
    def test_audit_report_print_verbose(self, mock_print):
        """测试打印详细审计报告"""
        report = AuditReport(repo_path="/tmp/repo")
        report.results = [
            AuditResult(name="Test1", passed=True, message="OK"),
            AuditResult(name="Test2", passed=False, message="Failed"),
        ]
        report.print_report(verbose=True)
        mock_print.assert_called()


class TestGitRepoAuditorInit:
    """测试 GitRepoAuditor 初始化"""

    def test_init_with_string_path(self):
        """测试使用字符串路径初始化"""
        auditor = GitRepoAuditor("/tmp/repo")
        assert str(auditor.repo_path) == "/tmp/repo"

    def test_init_with_path_object(self):
        """测试使用 Path 对象初始化"""
        auditor = GitRepoAuditor(Path("/tmp/repo"))
        assert str(auditor.repo_path) == "/tmp/repo"

    def test_init_resolves_path(self):
        """测试路径解析"""
        auditor = GitRepoAuditor(".")
        assert auditor.repo_path.is_absolute()


class TestGitRepoAuditorAudit:
    """测试 GitRepoAuditor.audit() 方法"""

    @patch("pathlib.Path.exists")
    def test_audit_nonexistent_path(self, mock_exists):
        """测试审计不存在的路径"""
        mock_exists.return_value = False
        auditor = GitRepoAuditor("/nonexistent/path")
        with pytest.raises(SystemExit) as exc_info:
            auditor.audit()
        assert exc_info.value.code == 1

    @patch("pathlib.Path.exists")
    def test_audit_non_git_repo(self, mock_exists):
        """测试审计非 Git 仓库"""
        mock_exists.return_value = False
        auditor = GitRepoAuditor("/tmp/not-a-repo")
        with pytest.raises(SystemExit) as exc_info:
            auditor.audit()
        assert exc_info.value.code == 1


class TestGitRepoAuditorRequiredFiles:
    """测试必需文件检查"""

    @patch("pathlib.Path.exists")
    def test_all_required_files_exist(self, mock_exists):
        """测试所有必需文件存在"""
        mock_exists.return_value = True

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_required_files()

        assert len(auditor._results) == 5
        for result in auditor._results:
            assert result.passed is True

    @patch("pathlib.Path.exists")
    def test_missing_required_files(self, mock_exists):
        """测试缺少必需文件"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_required_files()

        assert len(auditor._results) == 5
        for result in auditor._results:
            assert result.passed is False
            assert "缺少" in result.message

    @patch("pathlib.Path.exists")
    def test_some_required_files_missing(self, mock_exists):
        """测试部分必需文件缺失"""
        # 简单 mock：所有文件都不存在
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_required_files()

        # 所有检查都应该失败
        failed_results = [r for r in auditor._results if not r.passed]
        assert len(failed_results) == 5


class TestGitRepoAuditorOptionalDirs:
    """测试可选目录检查"""

    @patch("pathlib.Path.exists")
    @patch("pathlib.Path.is_dir")
    def test_optional_dir_exists(self, mock_is_dir, mock_exists):
        """测试可选目录存在"""
        mock_exists.return_value = True
        mock_is_dir.return_value = True

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_optional_dirs()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.exists")
    def test_optional_dir_missing(self, mock_exists):
        """测试可选目录缺失"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_optional_dirs()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False
        assert "缺少" in auditor._results[0].message


class TestGitRepoAuditorReadmeContent:
    """测试 README.md 内容检查"""

    @patch("pathlib.Path.exists")
    def test_readme_not_exists(self, mock_exists):
        """测试 README 不存在"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_readme_content()

        assert len(auditor._results) == 0

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_readme_complete(self, mock_exists, mock_read_text):
        """测试 README 内容完整"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Project Title

项目简介

## 目录结构

```
src/
tests/
```

## 快速开始

安装依赖...
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_readme_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_readme_incomplete(self, mock_exists, mock_read_text):
        """测试 README 内容不完整"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Project Title
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_readme_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False


class TestGitRepoAuditorContributingContent:
    """测试 CONTRIBUTING.md 内容检查"""

    @patch("pathlib.Path.exists")
    def test_contributing_not_exists(self, mock_exists):
        """测试 CONTRIBUTING 不存在"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_contributing_content()

        assert len(auditor._results) == 0

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_contributing_complete(self, mock_exists, mock_read_text):
        """测试 CONTRIBUTING 内容完整"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Contributing

## 项目结构

目录说明

## 开发环境

环境配置

## 提交规范

使用 Conventional Commits

## 发布流程

版本发布步骤
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_contributing_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_contributing_missing_sections(self, mock_exists, mock_read_text):
        """测试 CONTRIBUTING 缺少章节"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Contributing

一些内容
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_contributing_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False
        assert "缺少章节" in auditor._results[0].message


class TestGitRepoAuditorAgentsContent:
    """测试 AGENTS.md 内容检查"""

    @patch("pathlib.Path.exists")
    def test_agents_not_exists(self, mock_exists):
        """测试 AGENTS 不存在"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_agents_content()

        assert len(auditor._results) == 0

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_agents_concise_with_table(self, mock_exists, mock_read_text):
        """测试 AGENTS 简洁且有表格"""
        mock_exists.return_value = True
        content = """# Agents

| 任务 | 查看 |
|------|------|
| 测试 | README |

快速索引
"""
        mock_read_text.return_value = content

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_agents_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_agents_too_long(self, mock_exists, mock_read_text):
        """测试 AGENTS 太长"""
        mock_exists.return_value = True
        content = "# Agents\n" + "\n".join([f"Line {i}" for i in range(150)])
        mock_read_text.return_value = content

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_agents_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False


class TestGitRepoAuditorChangelogFormat:
    """测试 CHANGELOG.md 格式检查"""

    @patch("pathlib.Path.exists")
    def test_changelog_not_exists(self, mock_exists):
        """测试 CHANGELOG 不存在"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_changelog_format()

        assert len(auditor._results) == 0

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_changelog_valid_format(self, mock_exists, mock_read_text):
        """测试 CHANGELOG 格式正确"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Changelog

## [0.1.0] - 2024-01-15

### Added
- Feature 1

### Changed
- Change 1
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_changelog_format()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_changelog_invalid_format(self, mock_exists, mock_read_text):
        """测试 CHANGELOG 格式无效"""
        mock_exists.return_value = True
        mock_read_text.return_value = """Some random content
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_changelog_format()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False


class TestGitRepoAuditorGitignoreContent:
    """测试 .gitignore 内容检查"""

    @patch("pathlib.Path.exists")
    def test_gitignore_not_exists(self, mock_exists):
        """测试 .gitignore 不存在"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_gitignore_content()

        assert len(auditor._results) == 0

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_gitignore_complete(self, mock_exists, mock_read_text):
        """测试 .gitignore 内容完整"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Python
.venv/
__pycache__/
*.pyc

# Environment
.env
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_gitignore_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_gitignore_minimal(self, mock_exists, mock_read_text):
        """测试 .gitignore 内容不足"""
        mock_exists.return_value = True
        mock_read_text.return_value = """# Only one rule
*.log
"""

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_gitignore_content()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False


class TestGitRepoAuditorSubmodules:
    """测试子模块检查"""

    @patch("pathlib.Path.exists")
    def test_no_gitmodules(self, mock_exists):
        """测试没有 .gitmodules 文件"""
        mock_exists.return_value = False

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_submodules()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True
        assert "无子模块配置" in auditor._results[0].message

    @patch("subprocess.run")
    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_submodules_clean(self, mock_exists, mock_read_text, mock_run):
        """测试子模块状态正常"""
        # .gitmodules 存在
        mock_exists.return_value = True
        mock_read_text.return_value = '[submodule "test"]'
        mock_run.return_value = MagicMock(stdout="", returncode=0)

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_submodules()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("subprocess.run")
    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_submodules_unpushed(self, mock_exists, mock_read_text, mock_run):
        """测试子模块有未推送的提交"""
        # .gitmodules 存在
        mock_exists.return_value = True
        mock_read_text.return_value = '[submodule "test"]'
        mock_run.return_value = MagicMock(stdout="-abc123 test", returncode=0)

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_submodules()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False

    @patch("subprocess.run")
    @patch("pathlib.Path.read_text")
    @patch("pathlib.Path.exists")
    def test_submodules_timeout(self, mock_exists, mock_read_text, mock_run):
        """测试子模块检查超时"""
        from subprocess import TimeoutExpired
        # .gitmodules 存在
        mock_exists.return_value = True
        mock_read_text.return_value = '[submodule "test"]'
        mock_run.side_effect = TimeoutExpired("git submodule status", 10)

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_submodules()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True  # 超时视为通过（跳过检查）


class TestGitRepoAuditorRecentCommits:
    """测试最近提交检查"""

    @patch("subprocess.run")
    def test_commits_all_compliant(self, mock_run):
        """测试所有提交符合规范"""
        # git log --oneline 输出格式是 "hash message"
        mock_run.return_value = MagicMock(
            stdout="abc123 feat: add feature\ndef456 fix: fix bug\n789abc docs: update docs",
            returncode=0
        )

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_recent_commits()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is True

    @patch("subprocess.run")
    def test_commits_some_compliant(self, mock_run):
        """测试部分提交符合规范"""
        mock_run.return_value = MagicMock(
            stdout="abc123 feat: add feature\ndef456 bad commit\n789abc fix: fix bug\n012345 another bad one",
            returncode=0
        )

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_recent_commits()

        # 50% 符合率，应该通过
        assert len(auditor._results) == 1

    @patch("subprocess.run")
    def test_commits_none_compliant(self, mock_run):
        """测试没有提交符合规范"""
        mock_run.return_value = MagicMock(
            stdout="abc123 bad commit 1\ndef456 bad commit 2\n789abc bad commit 3",
            returncode=0
        )

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_recent_commits()

        assert len(auditor._results) == 1
        assert auditor._results[0].passed is False

    @patch("subprocess.run")
    def test_commits_error(self, mock_run):
        """测试获取提交失败"""
        mock_run.return_value = MagicMock(returncode=1)

        auditor = GitRepoAuditor("/tmp/repo")
        auditor._check_recent_commits()

        # 错误时不添加结果
        assert len(auditor._results) == 0


class TestAuditRepo:
    """测试 audit_repo 函数"""

    @patch("app.asset.audit.GitRepoAuditor")
    def test_audit_repo_success(self, mock_auditor_class):
        """测试成功审计"""
        mock_report = MagicMock()
        mock_report.print_report.return_value = True
        mock_auditor = MagicMock()
        mock_auditor.audit.return_value = mock_report
        mock_auditor_class.return_value = mock_auditor

        result = audit_repo("/tmp/repo", verbose=False)

        mock_auditor_class.assert_called_once_with("/tmp/repo")
        mock_auditor.audit.assert_called_once()
        # 成功时返回 True
        assert result is True

    @patch("app.asset.audit.GitRepoAuditor")
    def test_audit_repo_failure(self, mock_auditor_class):
        """测试审计失败"""
        try:
            from click.exceptions import Exit as ClickExit
        except ImportError:
            from click import ClickException as ClickExit
        
        mock_report = MagicMock()
        mock_report.print_report.return_value = False
        mock_auditor = MagicMock()
        mock_auditor.audit.return_value = mock_report
        mock_auditor_class.return_value = mock_auditor

        # 失败时抛出 Exit 异常
        with pytest.raises(ClickExit):
            audit_repo("/tmp/repo", verbose=False)
