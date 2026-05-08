# ROADMAP

go_router 引入暴露的设计问题，按影响排序。

## P0 路由表合并

`RouteConfig.all` + `buildScreen` switch 是两套映射。新增页面必须改两处，漏一处就崩。

方向：让 `RouteConfig` 自带屏构建逻辑，消除 `buildScreen` 独立 switch。

```dart
sealed class AppRoute {
  Widget build(ScreenContext ctx);
}
class DashboardRoute extends AppRoute { ... }
```

## P1 Section 构建缓存

`_SidebarShell.build()` 每次 rebuild 都从 metadata 重建 `NavSection` 列表。仅 workspace 切换时需要重建。

方向：`NavSection` 列表计算后缓存，workspace 变更时失效。或由 AppBloc 直接计算好并放在 `AppData` 中。

## P2 ConsultBloc 生命周期

每次进入 consulting 页面创建新 `ConsultBloc`，切走再回来状态丢失。

方向：将 `ConsultBloc` 提升到 `AppBloc` 级别或使用 `BlocProvider` 的 `lazy` 管理。

## P3 统一路由入口

加载态由外层 MaterialApp 控制，路由态由 GoRouter 控制。当前 `Router(routerDelegate, routeInformationParser)` 不是标准写法。

方向：等 URL 需求固化后重构为纯 GoRouter 方案，AppBloc 加载完成后再初始化 GoRouter。
