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
  ├── rootMetadataPath         → metadata.json
  ├── metadataPath(dir)        → {dir}/metadata.json
  ├── panoramaPath(tenant)     → founder|company/panorama.json
  └── qtconsultPath(tenant)    → founder|company/qtconsult.json
        │
        ▼
MetadataLoader            ← fixture JSON → Dart 模型
  ├── loadRoot()              → RootMetadata
  └── load(dir)               → NavMetadata（按目录缓存）
PanoramaLoader.load(tenant)   → PanoramaData
QtConsultLoader.load(tenant)  → QtConsultData
```

`_loadData()` 在 `initState` 中执行：

1. `MetadataLoader.loadRoot()` — 获取租户清单 + 段定义
2. 并行加载每个租户的 metadata + panorama + consult
3. 合并 sections（根段定义 + 租户项内容）

```dart
final root = await MetadataLoader.loadRoot();
final results = await Future.wait([
  MetadataLoader.load(root.tenants[0].dir),
  MetadataLoader.load(root.tenants[1].dir),
  PanoramaLoader.load(tenant: TenantType.internal),
  PanoramaLoader.load(tenant: TenantType.customer),
  QtConsultLoader.load(tenant: TenantType.customer),
]);
```

## 数据模型（`lib/models/metadata.dart`）

| 类 | 字段 | 来源 |
|---|---|---|
| `RootMetadata` | `tenants`, `sections` | 根 `metadata.json` |
| `TenantInfo` | `name`, `icon`, `dir` | 根 `tenants[]` |
| `SectionDef` | `id`, `dividerBefore` | 根 `sections[]` |
| `NavMetadata` | `sections` | 每租户 `metadata.json` |
| `NavSectionData` | `id`, `items` | 每租户 `sections[]` |
| `NavItemData` | `label`, `icon`, `pageType` | 每租户 `items[]` |

`TenantInfo` 的 `dir` 字段连接到 fixture 子目录（`founder` / `company`），解耦租户 ID 和路径。

`NavSectionData.id` 引用根的 `SectionDef.id`，匹配后拿到 `dividerBefore` 规则。

## 组件（`lib/views/navigation.dart`）

| 组件 | 说明 |
|---|---|
| `NavSidebar` | 完整侧边栏，props-driven：tenants/sections + 回调 |
| `TenantSwitcher` | 租户切换下拉菜单，`NavSidebar` 内部使用 |
| `NavIcon` | 图标按钮，`NavSidebar` 内部使用 |
| `NavItem` | 运行时导航项数据类（IconData + label + builder） |
| `NavSection` | 运行时导航段数据类（items + dividerBefore） |

渲染逻辑：`NavSidebar` 按 sections 数组遍历，`dividerBefore` 决定段前是否插入分隔线，flat index 跟踪选中项。

## 页面路由

`_buildScreenForItem` 按 `NavItemData.pageType` 分发：

| pageType | 页面 | 数据源 |
|---|---|---|
| `panorama` | `PanoramaScreen` | panorama.json |
| `thinking` | `ThinkingScreen` | 无 |
| `writing` | 占位 | 无 |
| `consulting` | `QtConsultScreen` | qtconsult.json |
| `business_detail` | `BusinessDetailScreen` | panorama.json → `businessUnits` |
| `function_detail` | `FuncDetailScreen` | panorama.json → `functionCards` |

`business_detail` 和 `function_detail` 通过 `item.label` 匹配 panorama 数据中的名称来查找对应数据。

## 页面切换

`_buildPage` 展开 `_sections` 为 flat list，按 `_selectedIndex` 调用 `NavItem.builder`。

## 图标解析

`NavItemData.resolveIcon()` 通过 `const icons` map 将字符串名解析为 Flutter `IconData`，未识别降级为 `Icons.circle_outlined`。当前支持 14 个图标名（详见 `docs/drd/metadata.md`）。
