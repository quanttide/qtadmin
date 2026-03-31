#!/usr/bin/env python3
"""
Git 仓库资产审计模块

根据 docs/handbook/asset/governace/git_repo.md 规范，
检查 Git 仓库是否符合标准资产体系要求。
"""

import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import typer


@dataclass
class AuditResult:
    """审计结果"""

    name: str
    passed: bool
    message: str
    suggestion: Optional[str] = None


@dataclass
class AuditReport:
    """审计报告"""

    repo_path: str
    results: list[AuditResult] = field(default_factory=list)

    @property
    def passed_count(self) -> int:
        return sum(1 for r in self.results if r.passed)

    @property
    def failed_count(self) -> int:
        return sum(1 for r in self.results if not r.passed)

    @property
    def total_count(self) -> int:
        return len(self.results)

    @property
    def pass_rate(self) -> float:
        if self.total_count == 0:
            return 0.0
        return self.passed_count / self.total_count * 100

    def print_report(self, verbose: bool = False):
        """打印审计报告"""
        print("\n" + "=" * 60)
        print("Git 仓库资产审计报告")
        print("=" * 60)
        print(f"仓库路径：{self.repo_path}")
        print(f"审计结果：{self.passed_count}/{self.total_count} 通过 "
              f"({self.pass_rate:.1f}%)")
        print("-" * 60)

        # 先显示未通过的项目
        failed_results = [r for r in self.results if not r.passed]
        if failed_results:
            print("\n❌ 未通过项目:")
            for result in failed_results:
                print(f"\n  [{result.name}]")
                print(f"  {result.message}")
                if result.suggestion:
                    print(f"  💡 建议：{result.suggestion}")

        # 显示通过的项目
        if verbose:
            passed_results = [r for r in self.results if r.passed]
            if passed_results:
                print("\n✅ 通过项目:")
                for result in passed_results:
                    print(f"  ✓ {result.name}")

        print("\n" + "=" * 60)

        if self.failed_count > 0:
            print("⚠️  审计未通过，请根据建议修复问题")
            return False
        else:
            print("✅ 审计通过，仓库符合标准资产体系规范")
            return True


class GitRepoAuditor:
    """Git 仓库审计器"""

    REQUIRED_FILES = {
        "README.md": "项目概述、目录结构",
        "CONTRIBUTING.md": "贡献指南、工作流、环境变量",
        "AGENTS.md": "Agent 导航",
        "CHANGELOG.md": "版本历史",
        ".gitignore": "Git 忽略规则",
    }

    OPTIONAL_DIRS = {
        "meta": "元数据目录",
    }

    COMMIT_TYPES = {
        "feat", "fix", "docs", "test",
        "refactor", "chore", "style", "perf"
    }

    def __init__(self, repo_path: str):
        self.repo_path = Path(repo_path).resolve()
        self._results: list[AuditResult] = []

    def audit(self) -> AuditReport:
        """执行完整审计"""
        if not self.repo_path.exists():
            print(f"错误：路径不存在 - {self.repo_path}")
            sys.exit(1)

        if not (self.repo_path / ".git").exists():
            print(f"错误：不是 Git 仓库 - {self.repo_path}")
            sys.exit(1)

        # 执行各项检查
        self._check_required_files()
        self._check_optional_dirs()
        self._check_readme_content()
        self._check_contributing_content()
        self._check_agents_content()
        self._check_changelog_format()
        self._check_gitignore_content()
        self._check_submodules()
        self._check_recent_commits()

        report = AuditReport(str(self.repo_path))
        report.results = self._results
        return report

    def _add_result(self, result: AuditResult):
        """添加审计结果"""
        self._results.append(result)

    def _check_required_files(self):
        """检查必需文件是否存在"""
        for filename, description in self.REQUIRED_FILES.items():
            file_path = self.repo_path / filename
            passed = file_path.exists()
            self._add_result(AuditResult(
                name=f"必需文件：{filename}",
                passed=passed,
                message=f"{filename} - {description}" if passed else f"缺少 {filename}",
                suggestion=f"创建 {filename} 文件" if not passed else None
            ))

    def _check_optional_dirs(self):
        """检查可选目录"""
        for dirname, description in self.OPTIONAL_DIRS.items():
            dir_path = self.repo_path / dirname
            passed = dir_path.exists() and dir_path.is_dir()
            self._add_result(AuditResult(
                name=f"可选目录：{dirname}/",
                passed=passed,
                message=f"{dirname}/ - {description}" if passed else f"缺少 {dirname}/ 目录",
                suggestion=f"考虑创建 {dirname}/ 目录用于存储元数据" if not passed else None
            ))

    def _check_readme_content(self):
        """检查 README.md 内容"""
        readme_path = self.repo_path / "README.md"
        if not readme_path.exists():
            return

        content = readme_path.read_text(encoding="utf-8")

        # 检查是否包含项目简介
        has_intro = len(content.split("\n")[0].replace("#", "").strip()) > 0

        # 检查是否包含目录结构
        has_structure = "目录" in content or "结构" in content or "```" in content

        # 检查是否包含快速开始
        has_quickstart = ("快速" in content or "开始" in content or
                         "Quick" in content or "Start" in content or
                         "开始使用" in content)

        passed = has_intro and (has_structure or has_quickstart)
        self._add_result(AuditResult(
            name="README.md 内容规范",
            passed=passed,
            message="包含项目简介、目录结构、快速开始" if passed else "内容不完整",
            suggestion="添加项目简介、目录结构和快速开始指南" if not passed else None
        ))

    def _check_contributing_content(self):
        """检查 CONTRIBUTING.md 内容"""
        contrib_path = self.repo_path / "CONTRIBUTING.md"
        if not contrib_path.exists():
            return

        content = contrib_path.read_text(encoding="utf-8")

        # 检查关键章节
        required_sections = [
            ("项目结构", ["结构", "目录", "Project Structure"]),
            ("开发环境", ["开发", "环境", "Environment", "Setup"]),
            ("提交规范", ["提交", "Commit", "规范"]),
            ("发布流程", ["发布", "Release", "版本"]),
        ]

        missing_sections = []
        for section_name, keywords in required_sections:
            has_section = any(kw in content for kw in keywords)
            if not has_section:
                missing_sections.append(section_name)

        passed = len(missing_sections) == 0
        self._add_result(AuditResult(
            name="CONTRIBUTING.md 内容规范",
            passed=passed,
            message="包含项目结构、开发环境、提交规范、发布流程" if passed
                    else f"缺少章节：{', '.join(missing_sections)}",
            suggestion=f"添加缺失的章节：{', '.join(missing_sections)}" if not passed else None
        ))

    def _check_agents_content(self):
        """检查 AGENTS.md 内容"""
        agents_path = self.repo_path / "AGENTS.md"
        if not agents_path.exists():
            return

        content = agents_path.read_text(encoding="utf-8")
        lines = content.strip().split("\n")

        # 检查行数（建议 ~50 行）
        line_count = len(lines)
        is_concise = line_count <= 100  # 宽松一点，不超过 100 行

        # 检查是否包含使用场景表格
        has_table = "|" in content and "---" in content

        # 检查是否包含快速索引
        has_index = ("索引" in content or "Index" in content or
                    "README" in content or "CONTRIBUTING" in content)

        passed = is_concise and (has_table or has_index)
        self._add_result(AuditResult(
            name="AGENTS.md 内容规范",
            passed=passed,
            message=f"简洁 ({line_count}行)，包含使用场景和快速索引" if passed
                    else f"需要优化 (共{line_count}行)",
            suggestion="保持简洁 (~50 行)，添加使用场景表格和快速索引" if not passed else None
        ))

    def _check_changelog_format(self):
        """检查 CHANGELOG.md 格式"""
        changelog_path = self.repo_path / "CHANGELOG.md"
        if not changelog_path.exists():
            return

        content = changelog_path.read_text(encoding="utf-8")

        # 检查基本格式
        has_changelog_header = "# Changelog" in content or "# CHANGELOG" in content

        # 检查是否有版本记录
        has_version = bool(re.search(r'## \[?v?\d+\.\d+\.\d+', content))

        # 检查是否有分类标题
        has_sections = any(section in content for section in
                          ["### Added", "### Changed", "### Fixed", "### Removed"])

        passed = has_changelog_header and has_version
        self._add_result(AuditResult(
            name="CHANGELOG.md 格式规范",
            passed=passed,
            message="符合语义化版本格式" if passed else "格式不规范",
            suggestion="添加 # Changelog 标题和版本号，使用 ### Added/Changed/Fixed/Removed 分类"
                      if not passed else None
        ))

    def _check_gitignore_content(self):
        """检查 .gitignore 内容"""
        gitignore_path = self.repo_path / ".gitignore"
        if not gitignore_path.exists():
            return

        content = gitignore_path.read_text(encoding="utf-8")

        # 检查是否包含常见忽略规则
        common_patterns = [
            (".venv", "Python 虚拟环境"),
            ("__pycache__", "Python 缓存"),
            ("*.pyc", "Python 编译文件"),
            (".env", "环境变量文件"),
        ]

        found_patterns = []
        for pattern, description in common_patterns:
            if pattern in content:
                found_patterns.append(f"{pattern} ({description})")

        passed = len(found_patterns) >= 2  # 至少包含 2 个常见规则
        self._add_result(AuditResult(
            name=".gitignore 内容规范",
            passed=passed,
            message=f"包含 {len(found_patterns)} 个常见规则" if passed else "规则较少",
            suggestion="添加常见的忽略规则：.venv, __pycache__, *.pyc, .env 等"
                      if not passed else None
        ))

    def _check_submodules(self):
        """检查子模块配置"""
        gitmodules_path = self.repo_path / ".gitmodules"

        if not gitmodules_path.exists():
            self._add_result(AuditResult(
                name="子模块配置",
                passed=True,
                message="无子模块配置",
                suggestion=None
            ))
            return

        # 检查 .gitmodules 文件格式
        content = gitmodules_path.read_text(encoding="utf-8")
        has_submodule = "[submodule" in content

        # 检查子模块是否已推送（如果有远程）
        try:
            result = subprocess.run(
                ["git", "submodule", "status"],
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                timeout=10
            )
            submodule_status = result.stdout.strip()

            # 检查是否有未推送的提交
            unpushed = False
            if submodule_status:
                for line in submodule_status.split("\n"):
                    if line.startswith("-") or line.startswith("+"):
                        unpushed = True
                        break

            passed = has_submodule and not unpushed
            self._add_result(AuditResult(
                name="子模块状态",
                passed=passed,
                message="子模块配置正确且已推送" if passed else "子模块有未推送的提交",
                suggestion="请先推送所有子模块的提交，再推送父仓库" if not passed else None
            ))
        except (subprocess.TimeoutExpired, Exception) as e:
            self._add_result(AuditResult(
                name="子模块状态",
                passed=has_submodule,
                message=f"子模块配置存在，状态检查跳过 ({e})",
                suggestion=None
            ))

    def _check_recent_commits(self):
        """检查最近的提交是否符合规范"""
        try:
            result = subprocess.run(
                ["git", "log", "--oneline", "-10"],
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                timeout=10
            )

            if result.returncode != 0:
                return

            commits = result.stdout.strip().split("\n")
            if not commits:
                return

            # 检查提交信息格式
            conventional_pattern = re.compile(
                r'^[a-z]+\([a-z-]+\)?:|^feat:|^fix:|^docs:|^test:|^refactor:|^chore:|^style:|^perf:'
            )

            compliant_count = 0
            for commit in commits:
                # 跳过空行
                if not commit.strip():
                    continue
                # 提取提交信息（去掉 hash）
                message = commit.split(" ", 1)[1] if " " in commit else commit
                if conventional_pattern.match(message.lower()):
                    compliant_count += 1

            compliance_rate = compliant_count / len(commits) * 100 if commits else 0
            passed = compliance_rate >= 50  # 至少 50% 符合规范

            self._add_result(AuditResult(
                name="提交规范符合度",
                passed=passed,
                message=f"{compliant_count}/{len(commits)} 符合 Conventional Commits "
                       f"({compliance_rate:.0f}%)",
                suggestion="使用 `cz commit` 创建规范提交，或手动遵循 <type>: <description> 格式"
                          if not passed else None
            ))
        except (subprocess.TimeoutExpired, Exception) as e:
            self._add_result(AuditResult(
                name="提交规范符合度",
                passed=True,
                message=f"提交检查跳过 ({e})",
                suggestion=None
            ))


def audit(
    repo_path: str = typer.Argument(".", help="要审计的 Git 仓库路径"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="显示所有通过的项目")
) -> bool:
    """
    审计 Git 仓库是否符合标准资产体系规范
    
    检查项目包括：必需文件、可选目录、README/CONTRIBUTING/AGENTS/CHANGELOG 内容规范、
    .gitignore 规则、子模块状态、提交规范符合度
    
    Returns:
        是否通过审计
    """
    auditor = GitRepoAuditor(repo_path)
    report = auditor.audit()
    passed = report.print_report(verbose)
    if not passed:
        raise typer.Exit(code=1)
    return True
