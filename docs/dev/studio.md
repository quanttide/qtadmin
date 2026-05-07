# Studio 实现细节

## 应用入口

`lib/main.dart` 是唯一入口：

1. `dotenv.load()` 加载 `.env` 配置（fixture 路径）
2. `runApp(QtAdminStudio)` 启动应用

## Fixture 加载管线

```
.env: QTADMIN_FIXTURES_PATH=/path/to/assets/fixtures
        │
        ▼
FixtureConfig              ← 读取环境变量，拼接 JSON 文件路径
  ├── panoramaPath(internal) → founder/panorama.json
  ├── panoramaPath(customer) → company/panorama.json
  └── qtconsultPath(customer)→ company/qtconsult.json
        │
        ▼
PanoramaLoader.load(tenant)  ← 读文件 → 解析 JSON → PanoramaData（tenant 级缓存）
QtConsultLoader.load(tenant) ← 读文件 → 解析 JSON → QtConsultData
```

`_loadData()` 在 `initState` 中并行加载：

```dart
final results = await Future.wait([
  PanoramaLoader.load(tenant: TenantType.internal),
  PanoramaLoader.load(tenant: TenantType.customer),
  QtConsultLoader.load(tenant: TenantType.customer),
]);
```

每个租户有独立的全景图 fixture，因此导航栏可以完全不同。

## 导航数据模型

```dart
_NavItem          — 单个导航项：图标、标签、页面构建器
_NavSection       — 导航分组：一组 _NavItem
_TenantConfig     — 租户配置：名称、图标
```

`_buildSections()` 通过 `BusinessUnitData.screenType` 分发到不同的页面：

```dart
switch (unit.screenType) {
  case 'thinking':   return ThinkingScreen();
  case 'writing':    return Center(child: Text('即将上线'));
  case 'consulting': return QtConsultScreen(data: _consultData!);
  default:           return BusinessDetailScreen(unit: unit);
}
```

| screenType | 用途 | 页面 |
|-----------|------|------|
| `detail`（默认） | 常规业务线 | `BusinessDetailScreen` |
| `consulting` | 咨询模块（量潮咨询） | `QtConsultScreen` |
| `thinking` | 创始人的思考空间 | `ThinkingScreen` |
| `writing` | 创始人的写作空间 | 占位 |

## 侧栏渲染

`_buildSidebar` 遍历 `_sections`，flat index 跟踪选中项，每个区域前渲染分隔线。空 section 自动跳过。

## 页面切换

`_buildPage` 展开 sections 为 flat list，按 `_selectedIndex` 调用 builder。

## 图标映射

`_iconForName` 集中管理所有导航项图标，包括业务线和个性工具。
