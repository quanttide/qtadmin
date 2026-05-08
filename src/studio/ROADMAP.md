# ROADMAP

go_router 引入暴露的设计问题，按影响排序。

## P0 路由表合并 ✓

`RouteConfig.builder` 自携带屏构建逻辑，消除 `buildScreen` 独立 switch。

## P1 Section 构建缓存 ✓

`_SidebarShell` 改为 StatefulWidget，`_rebuildSections` 仅 workspace 切换时重建。

## P2 ConsultBloc 生命周期 ✓

`ConsultBloc` 提升到 ShellRoute 层级，页面切换不重置状态。

## P3 统一路由入口 ✓

已重构为纯 GoRouter 方案。GoRouter 统管所有 AppState：
- `/loading` → AppInitial/AppLoading
- `/error` → AppError  
- `/workspace/:workspace/:page` → AppLoaded
- `_AppStateNotifier` 桥接 AppBloc stream 触发路由重定向
