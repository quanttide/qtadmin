# Status

## Studio vs CLI 架构对比

| 维度 | CLI | Studio |
|------|-----|--------|
| 版本 | v0.0.5 | v0.1.2 |
| 领域分包 | 业务域（qt-前缀）/ 职能域（无前缀） | `qtadmin-qtconsult`（业务）/ `qtadmin-org`（职能）✅ |
| 可测试性 | trait 注入（EmailFetcher, PlanStore） | `DataLoader.inject()` ✅ |
| 配置化 | TOML 文件 + 环境变量 | 待确认业务规则是否硬编码 |
| 主入口 | thin `main.rs` + dispatch | 主项目应仅做路由聚合，`lib/screens/` 当前为空 |

## Studio 覆盖缺口

CLI 已规划但 studio 无对应领域包：
- `human`（人力资源）— studio 仅有 `org`（组织管理），缺人事/考勤/绩效
- `connect`（沟通连接）— 飞书/企微消息、邮件
- `asset`（数字资产）— 日志归档、仓库审计

## 建议方向

1. 明确主项目与领域包的界面边界：screens 在包里还是主项目
2. 对齐 CLI v0.1.0 规划，补齐 `human`/`connect`/`asset` 领域包
3. 业务规则走 `FileSource` 配置化，不编入 freezed
4. CLI 数据文件（`~/.local/share/qtadmin/`）可被 studio 直接读取，实现双端数据共享
