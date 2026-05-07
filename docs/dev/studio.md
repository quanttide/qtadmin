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
FixtureConfig               ← 读取环境变量，拼接 JSON 文件路径
  ├── panoramaPath()        → company/panorama.json（两个租户共享）
  ├── qtconsultPath(customer)→ company/qtconsult.json
  └── qtconsultPath(internal)→ founder/qtconsult.json
        │
        ▼
PanoramaLoader.load()        ← 读文件 → 解析 JSON → PanoramaData（含缓存）
QtConsultLoader.load(tenant) ← 读文件 → 解析 JSON → QtConsultData（含缓存）
```

三个 loader 在 `initState` 的 `_loadData()` 中通过 `Future.wait` 并行加载：

```dart
final results = await Future.wait([
  PanoramaLoader.load(),
  QtConsultLoader.load(tenant: TenantType.customer),
  QtConsultLoader.load(tenant: TenantType.internal),
]);
```

加载完成后触发 `setState`，写入 `_data`、`_customerConsultData`、`_internalConsultData` 并调用 `_buildSections()`。

## 导航数据模型

```dart
_NavItem          — 单个导航项：图标、标签、页面构建器
_NavSection       — 导航分组：一组 _NavItem
_TenantConfig     — 租户配置：名称、图标、咨询模块标签
```

构建方法 `_buildSections()` 无参数、无分支，直接遍历 `_data`：

```dart
void _buildSections() {
  _sections = [
    // 1. 全景图
    _NavSection(items: [_NavItem(icon: today, label: '全景图', builder: ...)]),
    // 2. 业务线：遍历 businessUnits
    _NavSection(items: _data!.businessUnits.map((u) => _NavItem(label: u.name, ...))),
    // 3. 职能线：遍历 functionCards
    _NavSection(items: _data!.functionCards.map((c) => _NavItem(label: c.name, ...))),
    // 4. 咨询模块（标签为空，渲染时从当前租户配置读取）
    _NavSection(items: [_NavItem(label: '', builder: _buildConsult)]),
  ];
}
```

咨询模块的标签在渲染时从 `_currentTenant.consultLabel` 读取，页面数据按当前租户选取：

```dart
Widget _buildConsult(...) {
  final consult = _selectedTenant == 0 ? _internalConsultData : _customerConsultData;
  return QtConsultScreen(data: consult);
}
```

## 侧栏渲染

`_buildSidebar` 遍历 `_sections`，用 flat index 跟踪选中项：

- 每个区域前渲染分隔线（第一个区域也在全景图后有分隔线）
- 咨询模块标签通过 `item.label.isEmpty ? _currentTenant.consultLabel : item.label` 动态解析
- 选中高亮通过 `_selectedIndex == idx` 控制

## 页面切换

`_buildPage` 将所有 `_NavSection` 展开为 flat list，根据 `_selectedIndex` 调用对应 `builder`：

```dart
final allItems = _sections.expand((s) => s.items).toList();
return allItems[_selectedIndex].builder(_data!, _currentTenant.name);
```

## 图标映射

`_iconForName` 集中管理所有业务线和职能线的图标，新增名称必须先在此添加映射。
