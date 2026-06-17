# p03-auth-demo：权限体系端到端验证

## 目的

验证剩余权限原则和三轨审计在 qtadmin CLI 中的可行性。

## 文件说明

| 文件 | 说明 |
|------|------|
| `src/auth.rs` | Role 枚举、权限表、审计日志模块。复制到 `cli/src/auth.rs` |
| `cli.patch` | 对 `cli.rs` 和 `main.rs` 的修改。添加 `--role` 参数、权限守卫、审计写入 |

## 应用方式

将 `src/auth.rs` 复制到 `cli/src/auth.rs`，在 `main.rs` 添加 `mod auth;`，按 `cli.patch` 修改 `cli.rs`。

## 验证结果

```bash
# SuperAdmin 可运行 human status → 审计日志记录
$ qtadmin-cli --role super_admin human status

# Operator 运行受限命令被拒绝
$ qtadmin-cli --role operator asset audit
# → "角色 `operator` 无权执行 `asset` 命令"

# 审计日志
$ cat ~/.local/share/qtadmin/audit.log
{"t":...,"role":"super_admin","cmd":"human","mode":"exec","result":"success"}
```

## 发现的架构问题

子命令级别的权限无法在顶层统一做守卫——`asset audit` 和 `asset backup` 共享 `asset` 权限，无法在 `cli.rs` 中区分。细粒度权限需要各模块的 `dispatch()` 各自守卫。
