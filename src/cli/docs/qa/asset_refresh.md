# Asset Refresh 问题排查

## 问题描述

`qtadmin asset refresh` 命令未能正确更新子模块。

## 根本原因

### 1. 分支检测问题
 `_get_submodules_behind_remote` 函数硬编码使用 `origin/main` 分支：

```python
result = subprocess.run(
    ["git", "-C", str(full_path), "rev-parse", "origin/main"],
    ...
)
```

**问题**: 并非所有子模块都使用 `main` 分支，某些子模块可能是：
- 分离头指针状态（detached HEAD）
- 使用其他分支名（如 `master`, `HEAD`）
- upstream 未设置

### 2. 子模块列表过时
 `SUBMODULE_PATHS` 包含的路径与实际项目不匹配：

| 代码中的路径 | 实际存在 |
|-------------|----------|
| docs/history | 不存在 |
| docs/library | 不存在 |
| docs/paper | 不存在 |
| docs/specification | 不存在 |
| docs/usercase | 不存在 |
| packages/data | 不存在 |
| packages/devops | 不存在 |
| src/thera | 不存在 |

**当前实际子模块**:
```
docs/archive, docs/bylaw, docs/essay, docs/handbook, 
docs/journal, docs/profile, docs/report, docs/roadmap, 
docs/tutorial, src/qtadmin, src/qtcloud-data
```

### 3. 同步逻辑简单
 `_sync_submodule` 直接使用 `checkout main + pull`，不处理：
- 冲突情况
- 分离头指针状态
- 本地有提交但远程无更新的情况

## 解决方案

### 方案 1: 修复分支检测逻辑
```python
def _get_remote_head(repo_path: Path) -> Optional[str]:
    """获取远程分支 HEAD"""
    # 尝试 origin/HEAD -> origin/main
    for remote_branch in ["origin/HEAD", "origin/main", "origin/master"]:
        result = subprocess.run(
            ["git", "-C", str(repo_path), "rev-parse", remote_branch],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    return None
```

### 方案 2: 动态获取子模块列表
```python
def _get_submodule_paths(repo_root: Path) -> list[str]:
    """从 .gitmodules 动态获取子模块路径"""
    result = subprocess.run(
        ["git", "-C", str(repo_root), "config", "--get-regexp", "submodule\\..*\\.path"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []
    paths = []
    for line in result.stdout.strip().split("\n"):
        parts = line.split()
        if len(parts) >= 2:
            paths.append(parts[1])
    return paths
```

### 方案 3: 增强同步逻辑
```python
def _sync_submodule(repo_root: Path, path: str) -> None:
    """同步单个子模块，支持分离头指针"""
    sm_path = repo_root / path
    
    # 检查当前分支状态
    result = subprocess.run(
        ["git", "-C", str(sm_path), "branch", "--show-current"],
        capture_output=True,
        text=True,
    )
    current_branch = result.stdout.strip()
    
    if not current_branch:  # 分离头指针
        # 尝试获取 origin/main 并 checkout
        subprocess.run(
            ["git", "-C", str(sm_path), "checkout", "origin/main", "-b", "main"],
            capture_output=True,
        )
    
    # Pull with rebase
    subprocess.run(
        ["git", "-C", str(sm_path), "pull", "--rebase", "origin", "main"],
        capture_output=True,
    )
```

## 测试验证

```bash
# 预览模式
qtadmin asset refresh --dry-run

# 指定单个子模块
qtadmin asset refresh profile

# 检查子模块状态
git submodule status
```

## 待办

- [ ] 修复 `_get_submodules_behind_remote` 支持动态分支检测
- [ ] 从 `.gitmodules` 动态获取子模块路径
- [ ] 增强 `_sync_submodule` 处理分离头指针
- [ ] 添加网络超时重试机制
- [ ] 添加日志输出详细调试信息