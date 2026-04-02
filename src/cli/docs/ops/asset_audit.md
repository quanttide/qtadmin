# Asset Audit 问题排查

## 问题描述

审计工具 `qtadmin asset audit` 本身存在的问题。

## 已发现问题

### 1. 提交规范检测模式不完整

**位置**: `audit.py:389-401`

```python
conventional_pattern = re.compile(
    r'^[a-z]+\([a-z-]+\)?:|^feat:|^fix:|^docs:|^test:|^refactor:|^chore:|^style:|^perf:'
)
```

**问题**: 
- 正则表达式混乱：`^[a-z]+\([a-z-]+\)?:` 和 `^feat:` 同时存在
- 匹配效率低，容易遗漏格式如 `docs(handbook):` 的提交

### 2. 默认仓库路径处理

**位置**: `audit.py:424`

```python
def audit(repo_path: str = typer.Argument(".", help="要审计的 Git 仓库路径"))
```

**问题**: 
- 默认值 `.` 不支持参数时使用当前工作目录
- 用户运行 `qtadmin asset audit`（无参数）会使用默认值而非当前目录

### 3. 子模块检查超时处理

**位置**: `audit.py:362-368`

```python
except (subprocess.TimeoutExpired, Exception) e:
    self._add_result(AuditResult(
        name="子模块状态",
        passed=has_submodule,
        message=f"子模块配置存在，状态检查跳过 ({e})",
        suggestion=None
    ))
```

**问题**:
- 超时时返回 `passed=True`，掩盖了实际问题
- 应该返回 `passed=False` 或警告状态

### 4. AGENTS.md 行数阈值过宽

**位置**: `audit.py:238`

```python
is_concise = line_count <= 100  # 宽松一点，不超过 100 行
```

**建议**:
- 阈值应为 50 行，而非 100 行
- 注释已说明"宽松一点"，但不符合原始需求

### 5. 缺少对审计结果的自动修复功能

**问题**:
- 只提供建议，无法自动修复
- 用户需要手动创建缺失的文件

### 6. 无法审计版本发布规范

**问题**:
- 审计工具只能检查提交规范，无法验证版本发布是否符合规范
- 导致无法发现 AI 不遵守发布规范导致的问题（如未更新 CHANGELOG.md、未打标签等）
- monorepo 项目需要检查多个子模块的发布规范执行情况

**影响**:
- 版本发布遗漏 CHANGELOG 更新
- 标签命名不符合规范（如应为 `cli/v0.0.1` 却打成 `v0.0.1`）
- 子模块未正确推送就更新主仓库引用

## 待办

- [ ] 修复正则表达式，统一匹配逻辑
- [ ] 修改默认路径为实际当前工作目录
- [ ] 超时时返回失败状态或警告
- [ ] 调整 AGENTS.md 行数阈值至 50 行
- [ ] 添加 `--fix` 选项自动修复常见问题
- [ ] 添加版本发布规范审计功能