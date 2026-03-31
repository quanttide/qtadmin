# qtadmin asset refresh

同步子模块并提交推送主仓库。

## 使用方法

```bash
# 同步所有子模块
qtadmin asset refresh

# 只同步指定子模块
qtadmin asset refresh journal
qtadmin asset refresh qtadmin
qtadmin asset refresh thera

# 预览模式
qtadmin asset refresh --dry-run
```

## 示例

### 同步所有子模块

```bash
$ qtadmin asset refresh
✓ docs/journal: 已更新
✓ src/qtadmin: 已更新
✓ 已提交并推送 (abc1234)
```

### 只同步 journal 子模块

```bash
$ qtadmin asset refresh journal
✓ docs/journal: 已更新
```

### 预览模式

```bash
$ qtadmin asset refresh --dry-run
✓ docs/journal: 将更新
✓ src/qtadmin: 将更新
```

## 注意事项

- 子模块有未提交的变更时会报错，需先在子模块中提交
- 同步前会先 checkout 到 main 分支再 pull
- 提交信息固定为 `chore(submodule): sync submodules`
