# qtadmin_studio

量潮管理后台客户端，治理思想的展示与执行载体——展示的不是功能，是治理方法。定位与阶段规划见 [ROADMAP.md](./ROADMAP.md)。

## 现状

- 已完成领域分包：`packages/` 下 4 个包，主项目保留数据加载、路由与入口
- 双端数据共享已落地：与 CLI 同源读取 `recruitment.json`（v0.1.3）
- 已清理 router 死引用（v0.1.4）：移除 dashboard、think、qtclass 页面，主项目只保留治理相关页面（写作占位、量潮咨询、组织管理、招聘计划）

## 目录

```
lib/
├── blocs/        # BLoC 状态管理
├── models/       # 数据模型（freezed）
├── screens/      # 页面
├── views/        # 组件
├── theme.dart    # 颜色工具
├── main.dart     # 入口 + 路由 + 侧边栏外壳
└── router.dart   # RouteConfig 路由表

packages/
├── data-sources/         # 数据源抽象（DataLoader + FileSource）
├── qtadmin-navigation/   # 导航组件
├── qtadmin-org/          # 组织管理
└── qtadmin-qtconsult/    # 量潮咨询
```

开发原则：新领域与跨域逻辑先写在主项目，稳定后再由人类决定是否分包；业务规则走配置化，不编入 freezed。详见 [AGENTS.md](./AGENTS.md)。

## 开发

```bash
git config core.hooksPath .githooks   # 激活 pre-commit 检查（dart analyze）
flutter test                           # 运行全部测试
dart analyze lib/ test/               # 静态检查
```
