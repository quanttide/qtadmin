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

`_loadData()` 在 `initState` 中并行加载三个数据源：

```dart
final results = await Future.wait([
  PanoramaLoader.load(tenant: TenantType.internal),     // 创始人全景图
  PanoramaLoader.load(tenant: TenantType.customer),     // 公司全景图
  QtConsultLoader.load(tenant: TenantType.customer),    // 量潮咨询数据
]);
```

两个租户各有独立全景图，咨询数据共用一份。

## 导航数据模型

```dart
_NavItem          — 单个导航项：图标、标签、页面构建器
_NavSection       — 导航分组：一组 _NavItem
_TenantConfig     — 租户配置：名称、图标
```

构建方法 `_buildSections()` 无分支，直接遍历当前 `_data`：

```dart
void _buildSections() {
  _sections = [
    // 1. 全景图
    _NavSection(items: [_NavItem(icon: today, label: '全景图', builder: ...)]),
    // 2. 业务线：遍历 businessUnits，screenType 决定页面类型
    _NavSection(items: _data!.businessUnits.map((u) => _NavItem(
      label: u.name,
      builder: u.isConsulting ? (_, __) => QtConsultScreen(data: _consultData!) : (_, __) => BusinessDetailScreen(unit: u),
    ))),
    // 3. 职能线：遍历 functionCards
    _NavSection(items: _data!.functionCards.map((c) => _NavItem(label: c.name, ...))),
  ];
}
```

| screenType | 页面 |
|-----------|------|
| `detail`（默认） | `BusinessDetailScreen` |
| `consulting` | `QtConsultScreen(company/qtconsult.json)` — 量潮咨询 |

创始人全景图 `businessUnits` 为空，故导航栏无业务线区域，仅显示全景图和职能线。

## 侧栏渲染

`_buildSidebar` 遍历 `_sections`，flat index 跟踪选中项，每个区域前渲染分隔线。空 section 自动跳过不分隔。

## 页面切换

`_buildPage` 展开 sections 为 flat list，按 `_selectedIndex` 调用 builder。`PanoramaScreen` 的租户名称由 `_currentTenant.name` 传入。

## 图标映射

`_iconForName` 集中管理所有业务线和职能线的图标。新增名称必须在此添加映射。
