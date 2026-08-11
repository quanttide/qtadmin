# Studio 开发者文档

## 数据接入

Studio 不直接读取本地数据文件。数据通过 Loader 的 `inject()` 写入缓存，`load()` 供 Screen 读取。

```
后端 API / 开发 fixture → inject() → Loader._cache → Screen
```

各 Loader 职责一致：不感知数据来源，只管理缓存生命周期。

| 方法 | 说明 |
|------|------|
| `inject(data)` | 写入缓存 |
| `load()` | 读取缓存 |
| `clearCache()` | 重置 |

## 应用入口

`lib/main.dart` 启动后在 `_loadData()` 中并行调用各 Loader 的 `load()`。

## 页面路由

`RouteConfig.find` 按路由 id 分发，路由表见 `lib/router.dart`：

| id | Screen | 数据模型 |
|----|--------|----------|
| `writing` | 占位 | — |
| `org` | `OrgScreen` | `OrgDashboard` |
| `recruitment` | `RecruitmentScreen` | `RecruitmentPlan` |

导航数据（`data/*/metadata.json`）中出现的 id 必须存在于路由表，否则运行时抛 `StateError`。

## 导航系统

布局：`NavSidebar` → `NavSection` → `NavIcon`，flat index 跟踪选中项。

图标解析：`NavItemData.resolveIcon()` 通过字符串名映射 Flutter `IconData`，未识别降级为 `Icons.circle_outlined`。

## 数据模型

各模型类的定义见 `lib/models/`。

## 开发 fixture

Fixture 文件位于主仓库根级 `assets/fixtures/`。开发时直接用 `inject()` 注入，无需后端。
