# Studio 开发者文档

## 数据接入

`lib/app_state.dart` 的 `loadAppData()` 通过 `DataLoader` 并行加载数据，状态由 `ValueNotifier<AppState>` 承载：

```
FileSource (data/ 相对路径) → DataLoader.load() → AppState (Loaded/Error) → Screen
```

`AppStateScope`（InheritedNotifier）供路由层读取已加载的 `AppData`。

| 数据 | 路径 | 模型 |
|------|------|------|
| 组织管理 | `data/company/org.json` | `OrgDashboard` |
| 招聘计划 | `data/recruitment.json` | `RecruitmentPlan` |

## 应用入口

`lib/main.dart` 启动后创建 `ValueNotifier<AppState>`，`initState` 中调用 `loadAppData()`，GoRouter 通过 `refreshListenable` 响应状态变化。

## 页面路由

`RouteConfig.find` 按路由 id 分发，路由表见 `lib/router.dart`（静态配置，导航栏直接取 `RouteConfig.all` 渲染）：

| id | Screen | 数据模型 |
|----|--------|----------|
| `writing` | 占位 | — |
| `org` | `OrgScreen` | `OrgDashboard` |
| `recruitment` | `HumanScreen` | `RecruitmentPlan` |

路径格式 `/:page`（如 `/org`），未注册 id 抛 `StateError`。

## 导航系统

布局：`NavSidebar` → `NavSection` → `NavIcon`，flat index 跟踪选中项。导航项完全硬编码于 `RouteConfig.all`，无配置文件。

## 数据模型

各模型类的定义见 `lib/models/`（`org.dart`、`human.dart`），均为手写数据类（无代码生成）。

## 开发 fixture

Fixture 文件位于仓库根级 `assets/fixtures/`（当前仅 `company/org.json`）。本地开发时需将其复制到 `data/` 相对路径（`FileSource` 直接读文件系统），或通过 `DataLoader.inject()` 注入。
