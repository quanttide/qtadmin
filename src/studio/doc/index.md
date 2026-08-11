# Studio 开发者文档

qtadmin Studio 是治理思想的展示与执行载体。旧业务域已清空，当前为导航壳，从零承载「限制创始人」目标（见仓库根 `ROADMAP.md`）。

## 页面设计

- [任务页](./screens/tasks.md)：分配工作，任务绑定角色槽位
- [评审页](./screens/reviews.md)：接受评审结果，通过/打回留痕
- [摩擦页](./screens/frictions.md)：复盘四问，一次摩擦一条标准
- [角色页](./screens/roles.md)：任务类型 → 默认评审人

## 目录结构

```
lib/
├── main.dart       # 入口 + GoRouter + 侧边栏外壳
├── router.dart     # RouteConfig 路由表
├── navigation.dart # 导航组件（NavSidebar / NavSection / NavItem）
└── theme.dart      # 主题
```

## 应用入口

`lib/main.dart` 创建 `MaterialApp.router`，`GoRouter` 路径格式 `/:page`（如 `/writing`），`ShellRoute` 承载 `_SidebarShell` 侧边栏外壳。

## 页面路由

`RouteConfig.all` 静态路由表（`lib/router.dart`），按导航分组注册，导航栏直接取表渲染，`RouteConfig.find` 按 id 分发，未注册 id 抛 `StateError`：

| id | Screen | 分组 |
|----|--------|------|
| `tasks` | `TasksScreen`（任务分配） | 执行 |
| `reviews` | `ReviewsScreen`（评审工作台） | 执行 |
| `frictions` | `FrictionsScreen`（摩擦登记） | 制度 |
| `roles` | `RolesScreen`（角色） | 制度 |

新增页面只需注册 `RouteConfig` 条目并指定分组，侧边栏自动出现导航项。

## 数据接入

治理数据由 `AppStore`（ChangeNotifier）内存承载，通过 `StoreScope`（InheritedNotifier）分发，MVP 阶段无文件持久化。后续接入 `FileSource` 读取本地 JSON，业务规则走配置化不编入代码。
