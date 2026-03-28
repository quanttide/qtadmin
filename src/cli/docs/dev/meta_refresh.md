# qtadmin meta refresh

同步子模块并提交推送主仓库。

## 命令

```bash
# 同步所有子模块
qtadmin meta refresh

# 只同步指定子模块
qtadmin meta refresh journal
qtadmin meta refresh qtadmin

# 预览模式，不执行实际变更
qtadmin meta refresh --dry-run
```

## 流程

1. 检测子模块内部是否有未提交的变更
2. Fetch 子模块远程
3. 检测子模块远程更新
4. 拉取最新（checkout main + pull）
5. 提交并推送主仓库变更

## 子模块列表

| 名称 | 路径 |
|------|------|
| archive | docs/archive |
| bylaw | docs/bylaw |
| essay | docs/essay |
| handbook | docs/handbook |
| history | docs/history |
| journal | docs/journal |
| library | docs/library |
| paper | docs/paper |
| profile | docs/profile |
| report | docs/report |
| roadmap | docs/roadmap |
| specification | docs/specification |
| tutorial | docs/tutorial |
| usercase | docs/usercase |
| data | packages/data |
| devops | packages/devops |
| qtadmin | src/qtadmin |
| thera | src/thera |

## 实现

源码位置：`src/qtadmin_cli/cli.py`

## 与 thera 的关系

从 `thera refresh` 迁移而来，功能完全兼容。
