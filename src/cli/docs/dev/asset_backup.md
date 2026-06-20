# Asset Backup 开发文档

## 模块概述

将 `docs/journal/` 下的日志归档到 `docs/archive/journal/` 目录。

## 核心逻辑

### 扫描逻辑

使用 `rglob("*.md")` 递归扫描所有子目录，支持任意嵌套层级：

```python
for file_path in journal_dir.rglob("*.md"):
    parts = file_path.relative_to(journal_dir).parts
    category = parts[0] if len(parts) > 1 else "default"
```

### 分类提取

从相对路径的第一层目录名提取分类：

| 路径 | 分类 |
|------|------|
| `docs/journal/qtclass/train/2026-03-26.md` | qtclass |
| `docs/journal/default/qtclass/2026-03-18.md` | default |
| `docs/journal/organization/2026-03-25.md` | organization |

### 归档目录结构

保持原始嵌套层级：

```python
rel_parts = source.relative_to(journal_dir).parts[1:-1]  # 去掉分类名和文件名
target_dir = archive_dir / category / "/".join(rel_parts)
```

示例：
- `docs/journal/qtclass/train/2026-03-26.md` → `docs/archive/journal/qtclass/train/2026-03-26.md`

## 函数说明

| 函数 | 说明 |
|------|------|
| `get_project_root()` | 向上查找包含 docs/journal 和 docs/archive/journal 的目录 |
| `parse_date_from_filename()` | 从 `YYYY-MM-DD.md` 文件名解析日期 |
| `scan_journal_files()` | 递归扫描所有日期文件 |
| `filter_old_files()` | 筛选 N 天前的文件 |
| `move_files()` | 移动文件，保持嵌套结构 |
| `commit_and_push()` | 提交并推送子模块变更 |
| `update_submodule_in_main_repo()` | 更新主仓库子模块引用 |

## 已知问题

| 问题 | 状态 |
|------|------|
| 扫描逻辑只支持单层目录 | 已修复 |
| 归档后目录结构丢失 | 已修复 |
