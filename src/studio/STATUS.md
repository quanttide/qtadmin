# Status — qtadmin Studio

量潮管理后台客户端的当前状态快照。方向与阶段规划见 [ROADMAP.md](./ROADMAP.md)，变更历史见 [CHANGELOG.md](./CHANGELOG.md)。

## 版本

- 最新发布：v0.1.3（pubspec.yaml 当前 0.1.3）
- 待发布：v0.1.4（router 死引用清理已完成，asset 可视化起步未完成）

## 现状

- 主项目已瘦身：仅保留数据加载、路由与入口（`lib/` 下 data_sources、models、screens、views、`app_state.dart`、`main.dart`、`router.dart`、`theme.dart`）
- 单项目结构：全部代码内聚于 `lib/`（数据源、导航、模型、页面），无领域分包
- 双端数据共享已落地（v0.1.3）：与 CLI 同源读取 `recruitment.json`
- router 死引用已清理：dashboard、think、qtclass、qtconsult、org 页面已从主项目移除，`lib/` 不再引用对应领域
- 遗留领域实现已移除（dashboard、qtclass、think、qtconsult、org）：对应产品线由 qtcloud-asset / qtcloud-course / qtcloud-think / qtcloud-org 承接（org 示例数据已移至 `qtcloud-org/examples/`）
- 剩余包（data-sources、qtadmin-navigation、qtadmin-org）已合并回 `lib/` 后随领域下线移除，`packages/` 目录不复存在
- 当前路由表：写作占位、招聘计划（静态导航，无 metadata 配置）
- 数据接入统一走 Loader 的 `inject()` / `load()` / `clearCache()`，不感知数据来源

## 覆盖缺口

- 治理可视化空白：asset、knowl、delib、strategy、执行评审均无页面
- 执行环节：评审闭环无载体（角色槽位、评审节点、评审留痕、摩擦登记）
- 双端共享仅覆盖 recruitment，asset 等 CLI 数据文件（`~/.local/share/qtadmin/`）尚未接入

## 下一步

按 [ROADMAP.md](./ROADMAP.md) 推进：asset 可视化起步（v0.1.4）→ 执行环节评审闭环 MVP（v0.2.0）→ 治理可视化扩展（v0.3.x）。
