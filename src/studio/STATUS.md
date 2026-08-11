# Status — qtadmin Studio

量潮管理后台客户端的当前状态快照。方向与阶段规划见 [ROADMAP.md](./ROADMAP.md)，变更历史见 [CHANGELOG.md](./CHANGELOG.md)。

## 版本

- 最新发布：v0.1.3（pubspec.yaml 当前 0.1.3）
- 待发布：v0.1.4（待定——领域全部下线后无明确内容，建议更新 ROADMAP 后重新定义）

## 现状

- 主项目为最小壳：`lib/` 仅保留入口、路由与导航（`main.dart`、`router.dart`、`navigation.dart`、`theme.dart`）
- 无数据层：数据加载（app_state）、数据源（data_sources）已随领域下线移除
- 无领域实现：dashboard、qtclass、think、qtconsult、org、recruitment 全部下线，对应产品线由 qtcloud-asset / qtcloud-course / qtcloud-think / qtcloud-org / qtcloud-human 承接（参考实现与示例位于各仓 `examples/`）
- 当前路由表：写作占位（静态导航，硬编码于 `RouteConfig.all`）
- 测试：路由、导航组件、主题工具（14 个）

## 覆盖缺口

- 全部治理可视化页面已下线：asset、knowl、delib、strategy、执行评审均无页面
- 执行环节：评审闭环无载体（角色槽位、评审节点、评审留痕、摩擦登记）
- 双端共享已无 studio 侧消费：recruitment 数据仅 CLI 产出

## 下一步

领域实现已全部移交各 qtcloud-* 产品线。qtadmin Studio 自身方向待定：恢复任一领域展示（从对应产品线 examples/ 引入），或维持壳状态仅承载导航框架。
