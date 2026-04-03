"""
Asset backup command

将 docs/journal/ 下的日志移动到 docs/archive/journal/ 目录。
"""

import re
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

import typer

# 日期文件名正则
DATE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}\.md$")


@dataclass
class BackupResult:
    """backup 操作结果"""

    success: bool
    message: str
    moved_count: int = 0
    dry_run: bool = False


app = typer.Typer(help="将 journal 日志归档到 archive")


def get_project_root() -> Path:
    """获取项目根目录（包含 docs/journal 和 docs/archive/journal 的目录）"""
    current = Path.cwd()
    while current != current.parent:
        journal = current / "docs" / "journal"
        archive = current / "docs" / "archive" / "journal"
        if journal.exists() and archive.exists():
            return current
        current = current.parent
    return Path.cwd()


def parse_date_from_filename(filename: str) -> Optional[datetime]:
    """从文件名解析日期"""
    if not DATE_PATTERN.match(filename):
        return None
    date_str = filename.replace(".md", "")
    try:
        return datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        return None


def scan_journal_files(journal_dir: Path) -> list[tuple[Path, datetime, str]]:
    """
    递归扫描 journal 目录下的所有日期文件

    返回：[(文件路径, 日期, 分类), ...]
    """
    files = []
    if not journal_dir.exists():
        typer.echo(f"错误：journal 目录不存在: {journal_dir}")
        raise typer.Exit(1)

    for file_path in journal_dir.rglob("*.md"):
        if file_path.name.startswith("."):
            continue
        if not file_path.is_file():
            continue

        date = parse_date_from_filename(file_path.name)
        if not date:
            continue

        # 分类：取第一层目录名
        parts = file_path.relative_to(journal_dir).parts
        category = parts[0] if len(parts) > 1 else "default"

        files.append((file_path, date, category))

    return files


def filter_old_files(
    files: list[tuple[Path, datetime, str]], days: int
) -> list[tuple[Path, datetime, str]]:
    """筛选 N 天前的文件"""
    cutoff_date = datetime.now().replace(
        hour=0, minute=0, second=0, microsecond=0
    ) - timedelta(days=days)
    return [
        (path, date, category) for path, date, category in files if date < cutoff_date
    ]


def move_files(
    files: list[tuple[Path, datetime, str]],
    archive_dir: Path,
    journal_dir: Path,
    project_root: Path,
    dry_run: bool,
) -> list[tuple[Path, Path]]:
    """移动文件到 archive 目录，保持嵌套结构"""
    moved = []
    for source, date, category in files:
        # 保持嵌套目录结构
        rel_parts = source.relative_to(journal_dir).parts[1:-1]  # 去掉分类名和文件名
        target_dir = (
            archive_dir / category / "/".join(rel_parts)
            if rel_parts
            else archive_dir / category
        )
        target = target_dir / source.name

        if target.exists():
            typer.echo(f"跳过（已存在）：{target.relative_to(project_root)}")
            continue

        if dry_run:
            typer.echo(
                f"[DRY-RUN] {source.relative_to(project_root)} -> {target.relative_to(project_root)}"
            )
        else:
            target_dir.mkdir(parents=True, exist_ok=True)
            shutil.move(str(source), str(target))
            typer.echo(
                f"已移动：{source.relative_to(project_root)} -> {target.relative_to(project_root)}"
            )

        moved.append((source, target))

    return moved


def run_git_command(
    cmd: list[str], cwd: Path, project_root: Path
) -> subprocess.CompletedProcess:
    """运行 git 命令"""
    typer.echo(f"执行：git {' '.join(cmd[1:])} (在 {cwd.relative_to(project_root)})")
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def check_git_status(repo_path: Path, project_root: Path) -> bool:
    """检查是否有未提交的变更"""
    result = run_git_command(["git", "status", "--porcelain"], repo_path, project_root)
    return bool(result.stdout.strip())


def commit_and_push(
    repo_path: Path, message: str, project_root: Path, push: bool = True
) -> bool:
    """提交并推送子模块变更"""
    if not check_git_status(repo_path, project_root):
        typer.echo(f"无变更：{repo_path.relative_to(project_root)}")
        return False

    run_git_command(["git", "add", "-A"], repo_path, project_root)

    result = run_git_command(["git", "commit", "-m", message], repo_path, project_root)
    if result.returncode != 0:
        typer.echo(f"提交失败：{result.stderr}")
        return False

    if push:
        result = run_git_command(
            ["git", "push", "origin", "main"], repo_path, project_root
        )
        if result.returncode != 0:
            typer.echo(f"推送失败：{result.stderr}")
            return False
        typer.echo(f"已推送：{repo_path.relative_to(project_root)}")
    else:
        typer.echo(f"已提交（未推送）：{repo_path.relative_to(project_root)}")

    return True


def update_submodule_in_main_repo(
    submodule_name: str, message: str, project_root: Path, push: bool = True
):
    """在主仓库中更新子模块引用"""
    run_git_command(["git", "add", submodule_name], project_root, project_root)

    if not check_git_status(project_root, project_root):
        typer.echo(f"主仓库无变更：{submodule_name}")
        return

    result = run_git_command(
        ["git", "commit", "-m", message], project_root, project_root
    )
    if result.returncode != 0:
        typer.echo(f"主仓库提交失败：{result.stderr}")
        return

    if push:
        result = run_git_command(
            ["git", "push", "origin", "main"], project_root, project_root
        )
        if result.returncode != 0:
            typer.echo(f"主仓库推送失败：{result.stderr}")
            return
        typer.echo(f"主仓库已推送：{submodule_name}")


@app.command()
def backup(
    days: int = typer.Option(3, "--days", help="归档 N 天前的日志（默认 3）"),
    dry_run: bool = typer.Option(False, "--dry-run", help="预览模式，不执行实际变更"),
    no_push: bool = typer.Option(False, "--no-push", help="仅提交不推送"),
    yes: bool = typer.Option(False, "--yes", "-y", help="跳过确认直接执行"),
):
    """
    将 journal 日志归档到 archive。

    用法:
        qtadmin asset backup              # 归档 3 天前的日志
        qtadmin asset backup --days 7     # 归档 7 天前的日志
        qtadmin asset backup --dry-run    # 预览模式
    """
    project_root = get_project_root()
    journal_dir = project_root / "docs" / "journal"
    archive_dir = project_root / "docs" / "archive" / "journal"

    typer.echo(f"项目根目录：{project_root}")
    typer.echo(f"Journal 目录：{journal_dir}")
    typer.echo(f"Archive 目录：{archive_dir}")
    typer.echo(f"归档条件：{days} 天前\n")

    # 扫描文件
    all_files = scan_journal_files(journal_dir)
    typer.echo(f"扫描到 {len(all_files)} 个日志文件")

    # 筛选旧文件
    old_files = filter_old_files(all_files, days)
    if not old_files:
        typer.echo(f"没有 {days} 天前的日志需要归档。")
        raise typer.Exit(0)

    # 确认执行
    if not dry_run and not yes:
        typer.echo(f"\n共找到 {len(old_files)} 个待归档文件：")
        for path, date, category in sorted(old_files, key=lambda x: x[1]):
            typer.echo(f"  {date.strftime('%Y-%m-%d')} [{category}] {path.name}")

        if not typer.confirm("\n确认执行归档？"):
            typer.echo("已取消。")
            raise typer.Exit(0)

    # 移动文件
    typer.echo("\n开始归档...")
    moved = move_files(old_files, archive_dir, journal_dir, project_root, dry_run)

    if dry_run:
        typer.echo(f"\n[DRY-RUN] 共 {len(moved)} 个文件将被归档。")
        raise typer.Exit(0)

    if not moved:
        typer.echo("没有文件被移动。")
        raise typer.Exit(0)

    # 提交子模块
    typer.echo("\n提交子模块变更...")
    commit_message = f"archive: backup journal logs older than {days} days"
    push = not no_push

    commit_and_push(journal_dir, commit_message, project_root, push)
    commit_and_push(archive_dir, commit_message, project_root, push)

    # 更新主仓库子模块引用
    typer.echo("\n更新主仓库子模块引用...")
    update_submodule_in_main_repo(
        "journal", f"Update journal submodule: {commit_message}", project_root, push
    )
    update_submodule_in_main_repo(
        "archive", f"Update archive submodule: {commit_message}", project_root, push
    )

    typer.echo("\n归档完成！")
