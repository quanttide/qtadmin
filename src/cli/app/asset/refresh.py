"""
Asset refresh command
"""

import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from subprocess import TimeoutExpired
from typing import Optional

import typer


@dataclass
class RefreshResult:
    """refresh 操作结果"""

    success: bool
    message: str
    error: Optional[str] = None
    updated_submodules: list[str] = field(default_factory=list)
    commit_sha: Optional[str] = None
    dry_run: bool = False


app = typer.Typer(help="同步子模块并提交推送主仓库")


def _get_submodule_paths(repo_root: Path) -> list[str]:
    """从 .gitmodules 动态获取子模块路径"""
    result = subprocess.run(
        [
            "git",
            "-C",
            str(repo_root),
            "config",
            "--get-regexp",
            "submodule\\..*\\.path",
        ],
        capture_output=True,
        text=True,
        timeout=10,
    )
    if result.returncode != 0:
        return []
    paths = []
    for line in result.stdout.strip().split("\n"):
        parts = line.split()
        if len(parts) >= 2:
            paths.append(parts[1])
    return paths


SUBMODULE_PATHS = None  # 动态获取


def _get_submodule_paths_cached(repo_root: Path) -> list[str]:
    """获取子模块路径（带缓存）"""
    global SUBMODULE_PATHS
    if SUBMODULE_PATHS is None:
        SUBMODULE_PATHS = _get_submodule_paths(repo_root)
    return SUBMODULE_PATHS


@app.command()
def refresh(
    dry_run: bool = typer.Option(False, "--dry-run", help="预览模式，不执行实际变更"),
    submodule: Optional[str] = typer.Argument(
        None, help="子模块名（如 journal, archive）"
    ),
):
    """
    同步子模块并提交推送主仓库。

    用法:
        qtadmin asset refresh              # 同步所有子模块
        qtadmin asset refresh journal     # 只同步 docs/journal
        qtadmin asset refresh --dry-run   # 预览所有
    """
    result = _do_refresh(Path("."), dry_run=dry_run, submodule=submodule)

    if result.updated_submodules:
        for sm in result.updated_submodules:
            typer.echo(f"✓ {sm}: 已更新")

    if result.success:
        if result.commit_sha:
            typer.echo(f"✓ 已提交并推送 ({result.commit_sha})")
        else:
            typer.echo(f"✓ {result.message}")
        raise typer.Exit(0)
    else:
        typer.echo(f"[FAIL] {result.message}")
        if result.error:
            typer.echo(f"  Error: {result.error}")
        raise typer.Exit(1)


def _do_refresh(
    repo_root: Path, dry_run: bool = False, submodule: Optional[str] = None
) -> RefreshResult:
    """执行子模块同步"""
    dirty_submodules = _get_dirty_submodules(repo_root)
    if dirty_submodules:
        return RefreshResult(
            success=False,
            message="子模块有未提交的变更",
            error=f"请先在子模块中提交: {', '.join(dirty_submodules)}",
        )

    _fetch_submodules(repo_root, submodule=submodule)

    updated_submodules = []
    submodule_status = _get_submodules_behind_remote(repo_root, submodule=submodule)

    for sm in submodule_status:
        if dry_run:
            updated_submodules.append(sm.path)
        else:
            _sync_submodule(repo_root, sm.path)
            updated_submodules.append(sm.path)

    status = _get_status(repo_root)

    if status:
        if dry_run:
            return RefreshResult(
                success=True,
                dry_run=True,
                message="将提交变更",
                updated_submodules=updated_submodules,
            )

        commit_sha = _commit_and_push(repo_root, "chore(submodule): sync submodules")
        if commit_sha:
            return RefreshResult(
                success=True,
                message="已提交并推送",
                updated_submodules=updated_submodules,
                commit_sha=commit_sha,
            )
        else:
            return RefreshResult(
                success=False,
                message="提交推送失败",
                updated_submodules=updated_submodules,
            )

    if updated_submodules:
        if dry_run:
            return RefreshResult(
                success=True,
                dry_run=True,
                message=f"将更新 {len(updated_submodules)} 个子模块",
                updated_submodules=updated_submodules,
            )
        return RefreshResult(
            success=True,
            message="子模块已更新",
            updated_submodules=updated_submodules,
        )

    return RefreshResult(success=True, message="已是最新", updated_submodules=[])


def _get_dirty_submodules(repo_root: Path) -> list[str]:
    """检查子模块是否有未提交的变更"""
    dirty = []
    paths = _get_submodule_paths_cached(repo_root)
    for path in paths:
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


def _fetch_submodules(repo_root: Path, submodule: Optional[str] = None) -> None:
    """Fetch 子模块的远程"""
    paths = [submodule] if submodule else _get_submodule_paths_cached(repo_root)
    for path in paths:
        full_path = repo_root / path
        if not full_path.exists():
            continue
        try:
            subprocess.run(
                ["git", "-C", str(full_path), "fetch", "origin"],
                capture_output=True,
                timeout=10,
            )
        except TimeoutExpired:
            pass


def _get_remote_branch(repo_path: Path) -> Optional[str]:
    """获取子模块当前分支对应的远程分支"""
    try:
        # 先尝试获取当前分支名
        result = subprocess.run(
            ["git", "-C", str(repo_path), "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        branch = result.stdout.strip()

        # 如果是 detached HEAD，尝试获取 origin/HEAD
        if branch == "HEAD":
            result = subprocess.run(
                [
                    "git",
                    "-C",
                    str(repo_path),
                    "rev-parse",
                    "--abbrev-ref",
                    "origin/HEAD",
                ],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode == 0:
                return result.stdout.strip()
            # 回退到 origin/main
            return "origin/main"

        return f"origin/{branch}"
    except TimeoutExpired:
        return None


def _get_submodules_behind_remote(
    repo_root: Path, submodule: Optional[str] = None
) -> list:
    """获取落后于远程的子模块

    比较父仓库记录的子模块 commit 与子模块远程 HEAD，
    而不是比较本地 checkout 的 HEAD。
    """
    from dataclasses import dataclass

    @dataclass
    class SubmoduleInfo:
        path: str
        local_commit: str
        is_behind: bool

    paths = [submodule] if submodule else _get_submodule_paths_cached(repo_root)
    behind = []

    for path in paths:
        full_path = repo_root / path
        if not full_path.exists():
            continue
        try:
            # 获取父仓库记录的子模块 commit
            result = subprocess.run(
                ["git", "ls-tree", "HEAD", path],
                cwd=repo_root,
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                continue
            parts = result.stdout.strip().split()
            if len(parts) < 3:
                continue
            recorded_commit = parts[2]

            # 获取子模块远程 HEAD
            remote_branch = _get_remote_branch(full_path)
            if not remote_branch:
                continue

            result = subprocess.run(
                ["git", "-C", str(full_path), "rev-parse", remote_branch],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                continue
            remote_head = result.stdout.strip()

            if recorded_commit != remote_head:
                behind.append(
                    SubmoduleInfo(
                        path=path,
                        local_commit=recorded_commit[:7],
                        is_behind=True,
                    )
                )
        except TimeoutExpired:
            pass
    return behind


def _sync_submodule(repo_root: Path, path: str) -> None:
    """同步单个子模块到远程 HEAD"""
    # 使用 submodule update --remote 来同步到远程最新
    subprocess.run(
        ["git", "-C", str(repo_root), "submodule", "update", "--remote", path],
        capture_output=True,
    )


def _get_status(repo_root: Path) -> bool:
    """检查仓库是否有待提交的变更"""
    result = subprocess.run(
        ["git", "-C", str(repo_root), "status", "--porcelain"],
        capture_output=True,
        text=True,
        timeout=10,
    )
    return bool(result.stdout.strip())


def _commit_and_push(repo_root: Path, message: str) -> Optional[str]:
    """提交并推送"""
    subprocess.run(["git", "-C", str(repo_root), "add", "-A"], capture_output=True)
    result = subprocess.run(
        ["git", "-C", str(repo_root), "commit", "-m", message],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None

    result = subprocess.run(
        ["git", "-C", str(repo_root), "push"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None

    result = subprocess.run(
        ["git", "-C", str(repo_root), "rev-parse", "HEAD"],
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()[:7] if result.returncode == 0 else None
