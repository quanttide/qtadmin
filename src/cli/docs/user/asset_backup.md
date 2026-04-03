# qtadmin asset backup

将 journal 日志归档到 archive。

## 使用方法

```bash
# 归档 3 天前的日志（默认）
qtadmin asset backup

# 归档 7 天前的日志
qtadmin asset backup --days 7

# 预览模式，不执行实际变更
qtadmin asset backup --dry-run

# 仅提交不推送
qtadmin asset backup --no-push

# 跳过确认直接执行
qtadmin asset backup -y
```

## 示例

### 预览模式

```bash
$ qtadmin asset backup --dry-run
项目根目录：/home/user/quanttide-founder
Journal 目录：/home/user/quanttide-founder/docs/journal
Archive 目录：/home/user/quanttide-founder/docs/archive/journal
归档条件：3 天前

扫描到 38 个日志文件

开始归档...
[DRY-RUN] docs/journal/default/2026-03-26.md -> docs/archive/journal/default/2026-03-26.md
[DRY-RUN] docs/journal/write/2026-03-24.md -> docs/archive/journal/write/2026-03-24.md

[DRY-RUN] 共 17 个文件将被归档。
```

### 执行归档

```bash
$ qtadmin asset backup -y
项目根目录：/home/user/quanttide-founder
Journal 目录：/home/user/quanttide-founder/docs/journal
Archive 目录：/home/user/quanttide-founder/docs/archive/journal
归档条件：3 天前

扫描到 38 个日志文件

开始归档...
已移动：docs/journal/default/2026-03-26.md -> docs/archive/journal/default/2026-03-26.md

提交子模块变更...
执行：git add -A (在 docs/journal)
已推送：docs/journal

更新主仓库子模块引用...
执行：git add journal (在 .)
主仓库已推送：journal

归档完成！
```

## 流程

1. 递归扫描 `docs/journal/` 下所有日期文件（`YYYY-MM-DD.md`），支持任意嵌套目录
2. 筛选 N 天前的日志
3. 移动文件到 `docs/archive/journal/{category}/` 对应目录，保持原始嵌套结构
4. 跳过已存在的目标文件
5. 提交并推送 journal 和 archive 子模块
6. 更新主仓库子模块引用

## 目录结构示例

```
docs/journal/
├── qtclass/train/2026-03-26.md    # 分类: qtclass, 嵌套: train
└── default/2026-03-18.md          # 分类: default

归档后:
docs/archive/journal/
├── qtclass/train/2026-03-26.md    # 保持嵌套结构
└── default/2026-03-18.md
```

## 注意事项

- 支持任意嵌套目录层级，归档后保持原始结构
- 目标文件已存在时会自动跳过
- 使用 `--dry-run` 预览将要归档的文件
- 默认会提示确认，使用 `-y` 跳过确认
