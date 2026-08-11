# Status

## Studio vs CLI 架构对比

| 维度 | CLI | Studio |
|------|-----|--------|
| 版本 | v0.0.17 | v0.1.3 |
| 领域分包 | 职能域（asset/business/connect/human/knowl） | `qtadmin-org`、`qtadmin-qtconsult` |
| 页面 | 命令执行入口 | org、qtconsult、recruitment 三个历史业务屏 |
| 可测试性 | trait 注入（EmailFetcher, PlanStore） | `DataLoader.inject()` ✅ |
| 配置化 | TOML 文件 + 环境变量 | 待确认业务规则是否硬编码 |
| 主入口 | thin `main.rs` + dispatch | 主项目路由聚合，router 仍引用已剥离业务域包（dashboard、think、qtclass），存在死引用风险 |

## 覆盖缺口

- 治理可视化空白：asset、knowl、delib、strategy、执行评审均无页面
- 执行环节：评审闭环无载体（角色槽位、评审节点、评审留痕、摩擦登记）
- workspace：无多用户、无每人一个 workspace 概念
- 双端共享：CLI 数据文件（`~/.local/share/qtadmin/`）未被 studio 读取

## 建议方向

1. 清理 router 死引用，确认可构建
2. 对齐路线：asset 可视化起步 → 评审闭环 MVP → 评审质量飞轮（打回聚类、标准库）
3. 业务规则走 `FileSource` 配置化，不编入 freezed
4. CLI 数据文件双端共享，为 workspace 与 Provider 数据契约铺路
