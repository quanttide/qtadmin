# Status — qtadmin Studio

量潮管理后台客户端的当前状态快照。方向与阶段规划见 [ROADMAP.md](./ROADMAP.md)，变更历史见 [CHANGELOG.md](./CHANGELOG.md)。

## 版本

- 最新发布：v0.1.3（pubspec.yaml 当前 0.1.3）
- 待发布：v0.1.4（router 死引用清理已完成，asset 可视化起步未完成）

## 现状

- 主项目已瘦身：仅保留数据加载、路由与入口（`lib/` 下 blocs、models、screens、views、`main.dart`、`router.dart`、`theme.dart`）
- 领域分包 4 个包：`data-sources`、`qtadmin-navigation`、`qtadmin-org`、`qtadmin-qtconsult`
- 双端数据共享已落地（v0.1.3）：与 CLI 同源读取 `recruitment.json`
- router 死引用已清理：dashboard、think、qtclass 页面已从主项目移除，`lib/` 不再引用对应包
- 遗留领域包已移除（`qtadmin-dashboard`、`qtadmin-qtclass`、`qtadmin-think`）：无引用、无数据活水源，对应产品线由 qtcloud-asset / qtcloud-course / qtcloud-think 承接
- 当前路由表：写作占位、量潮咨询、组织管理、招聘计划
- 数据接入统一走 Loader 的 `inject()` / `load()` / `clearCache()`，不感知数据来源

## 覆盖缺口

- 治理可视化空白：asset、knowl、delib、strategy、执行评审均无页面
- 执行环节：评审闭环无载体（角色槽位、评审节点、评审留痕、摩擦登记）
- workspace：无多用户、无每人一个 workspace 概念
- 双端共享仅覆盖 recruitment，asset 等 CLI 数据文件（`~/.local/share/qtadmin/`）尚未接入

## 下一步

按 [ROADMAP.md](./ROADMAP.md) 推进：asset 可视化起步（v0.1.4）→ 执行环节评审闭环 MVP（v0.2.0）→ 治理可视化扩展（v0.3.x）。
