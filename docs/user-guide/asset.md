# 数字资产职能

通过 `qtadmin asset` 命令管理数字资产。

无参数时显示简要帮助；`qtadmin asset --help` 或 `qtadmin asset -h` 列出所有子命令及用法。

## 安装

```bash
pip install qtadmin-cli
# 或从源码安装
pip install -e src/cli
```

---

## 命令

### `qtadmin asset backup` (stable) — 日志归档

将 `docs/journal/` 下的过期日志移到 `docs/archive/journal/`，自动提交并推送子模块。建议每周运行一次。

```bash
qtadmin asset backup              # 归档 3 天前的日志（默认）
qtadmin asset backup --days 7     # 归档 7 天前的日志
qtadmin asset backup --dry-run    # 预览模式，不实际移动
qtadmin asset backup --yes        # 跳过确认直接执行
qtadmin asset backup -y           # 同上，短格式
```

默认会询问确认；使用 `--yes` / `-y` 跳过交互，`--dry-run` 预览变更。

执行输出：

```
$ qtadmin asset backup -y
项目根目录：/home/user/project
扫描到 38 个日志文件
开始归档...
已移动：docs/journal/default/2026-05-28.md -> docs/archive/journal/default/2026-05-28.md
提交子模块变更...
已推送：docs/journal
归档完成！
```

常见错误：
- 子模块存在未提交变更时，`backup` 会先尝试提交，失败则提示用户手动处理
- 网络断开导致 push 失败时，命令输出推送错误信息，本地 commit 仍然保留

### `qtadmin asset audit` (stable) — 资产审计

审计 Git 仓库是否符合标准资产体系规范。建议发布前运行。

```bash
qtadmin asset audit                    # 审计当前目录
qtadmin asset audit /path/to/repo      # 审计指定仓库
qtadmin asset audit --verbose          # 显示所有通过项目
```

审计通过时退出码为 0，未通过时退出码为 1。

审计项：
- 必需文件：README.md、CONTRIBUTING.md、AGENTS.md、CHANGELOG.md、.gitignore
- 上述文件的内容规范
- 子模块状态（未推送的提交会被标记）
- 提交信息是否符合 Conventional Commits
- CHANGELOG 与 pyproject.toml 版本一致性

执行输出：

```
$ qtadmin asset audit
✅ 所有审计项通过

$ qtadmin asset audit --verbose
✅ 必需文件：README.md — 通过
✅ 必需文件：CONTRIBUTING.md — 通过
…
✅ 提交规范符合度 — 3/3 符合 (100%)
✅ 版本发布规范一致性 — 通过
```

---

## 限制

- `asset refresh` 已移除（功能已迁移至其他工具）
- `asset apply` 规划中，尚未实现

## 说明

- 两个命令均经过单元测试和集成测试覆盖，可在 v0.0.1 生产使用
- 更多用法参见 `qtadmin asset backup --help`、`qtadmin asset audit --help`
- 详细文档见 `src/cli/docs/user/asset_backup.md`
- 在线文档：[https://github.com/quanttide/quanttide-tech](https://github.com/quanttide/quanttide-tech)
