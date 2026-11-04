# qtadmin_studio

量潮管理后台客户端。现存任务/评审/摩擦/角色四屏为旧治理操作台实体，与监控面板定位不同物，去留未定（定位见仓库根 `AGENTS.md`）。

## 现状

- 单项目结构：全部代码在 `lib/` 下（数据源、导航、模型、页面内聚），无领域分包
- 已清理 router 死引用（v0.1.4）：移除 dashboard、think、qtclass、qtconsult、org、recruitment 页面，主项目仅保留写作占位
- 组织管理已下线：实现与示例数据移至 qtcloud-org 仓库（`examples/`），待其产品线恢复
- 招聘计划已下线：参考实现与契约移至 qtcloud-human 仓库（`examples/recruitment-plan/`），待其 plan 模块承接

## 目录

```
lib/
├── app_state.dart   # 应用状态（ValueNotifier + 数据加载）
├── data_sources/    # 数据源抽象（DataSource + FileSource）
├── models/          # 数据模型（手写：human）
├── screens/         # 页面
├── views/           # 组件
├── theme.dart       # 颜色工具
├── navigation.dart  # 导航组件
├── main.dart        # 入口 + 路由 + 侧边栏外壳
└── router.dart      # RouteConfig 路由表
```

开发原则：新领域与跨域逻辑先写在主项目，稳定后再由人类决定是否分包；业务规则走配置化，不编入 freezed。详见 [AGENTS.md](./AGENTS.md)。

## 开发

```bash
git config core.hooksPath .githooks   # 激活 pre-commit 检查（dart analyze）
flutter test                           # 运行全部测试
dart analyze lib/ test/               # 静态检查
```
