# qtadmin_studio

量潮管理后台客户端，治理思想的展示与执行载体——展示的不是功能，是治理方法。定位与阶段规划见 [ROADMAP.md](./ROADMAP.md)。

## 现状

- 单项目结构：全部代码在 `lib/` 下（数据源、导航、模型、页面内聚），无领域分包
- 双端数据共享已落地（v0.1.3）：与 CLI 同源读取 `recruitment.json`（v0.1.3）
- 已清理 router 死引用（v0.1.4）：移除 dashboard、think、qtclass 页面，主项目只保留治理相关页面（写作占位、组织管理、招聘计划）

## 目录

```
lib/
├── app_state.dart   # 应用状态（ValueNotifier + 数据加载）
├── data_sources/    # 数据源抽象（DataSource + FileSource）
├── models/          # 数据模型（freezed：metadata/org/recruitment）
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
