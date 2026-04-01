# Asset Backup 问题排查

## 问题描述

`qtadmin asset backup` 只扫描到 1 个文件，但实际应有更多文件需要归档。

## 环境信息

- 日期：2026-04-01
- 归档条件：3 天前

## 实际文件结构

```
docs/journal/
├── default/qtclass/2026-03-18.md      # 14天前
├── knowl/qtclass/2026-03-18.md        # 14天前
├── qtclass/train/2026-03-26.md        # 6天前
└── stdn/business/2026-03-18.md        # 14天前
```

## 根本原因

### 扫描逻辑缺陷

`scan_journal_files()` 函数只遍历**一层**子目录：

```python
for category_dir in journal_dir.iterdir():  # 只遍历直接子目录
    if not category_dir.is_dir():
        continue
    category = category_dir.name
    for file_path in category_dir.iterdir():  # 只扫描这一层
        ...
```

**实际结构 vs 代码假设**：

| 实际路径 | 嵌套层数 | 是否被扫描 |
|---------|---------|-----------|
| `docs/journal/organization/2026-03-25.md` | 1层 | ✓ |
| `docs/journal/qtclass/train/2026-03-26.md` | 2层 | ✗ |
| `docs/journal/default/qtclass/2026-03-18.md` | 2层 | ✗ |

代码假设日志文件直接在分类目录下（如 `docs/journal/qtclass/`），但实际嵌套更深。

## 解决方案

### 方案：递归扫描所有子目录

```python
def scan_journal_files(journal_dir: Path) -> list[tuple[Path, datetime, str]]:
    """递归扫描 journal 目录下所有日期文件"""
    files = []
    if not journal_dir.exists():
        return files

    for file_path in journal_dir.rglob("*.md"):  # 递归扫描所有 .md
        if file_path.name.startswith("."):
            continue
        
        date = parse_date_from_filename(file_path.name)
        if not date:
            continue
        
        # 分类：取第二层目录名
        parts = file_path.relative_to(journal_dir).parts
        category = parts[0] if len(parts) > 1 else "default"
        
        files.append((file_path, date, category))

    return files
```

### 归档后移动到对应目录

移动时按嵌套层级保持结构：

```python
def move_files(...):
    for source, date, category in files:
        # 保持嵌套结构
        target_dir = archive_dir / category
        # 如果有子分类，也保留
        parts = source.relative_to(journal_dir).parts[1:-1]
        target_dir = target_dir / "/".join(parts) if parts else target_dir
        ...
```

## 待办

- [ ] 修改 `scan_journal_files()` 支持递归扫描
- [ ] 修复分类逻辑（从路径提取正确的分类）
- [ ] 保持嵌套目录结构
- [ ] 添加单元测试覆盖嵌套目录场景
- [ ] 更新文档 `src/cli/docs/dev/asset_backup.md`