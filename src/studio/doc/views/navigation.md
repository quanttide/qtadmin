# 元数据驱动导航

**metadata.json 决定导航长什么样，panorama.json 决定页面内容是什么。** 两者分离，改导航不用动业务数据，反之亦然。

导航元数据分两层：

| 层级 | 文件 | 职责 |
|---|---|---|
| 全局 | `assets/fixtures/metadata.json` | 租户注册表 + 段定义（分隔线规则） |
| 每租户 | `assets/fixtures/{dir}/metadata.json` | 该租户导航项内容 |

新增租户只需根 metadata 加一条 + 写 fixture 文件，不改 Dart 代码。

## 工作方式

```
assets/fixtures/metadata.json        ← 根
  │ MetadataLoader.loadRoot()
  │  → RootMetadata { tenants[] , sections[] }
  ▼                         
  main.dart 根据根 tenants 遍历加载每租户 metadata
  │ MetadataLoader.load(dir)
  │  → TenantMetadata { sections[{id, items[]}] }
  ▼
合并：用根 sections[id].dividerBefore + 租户 sections[id].items
  │ main.dart:_buildSections → 为每项构建 page widget 闭包
  ▼
NavSidebar(sections, selectedIndex, ..., tenants, ...)
  │ NavSidebar 内部：TenantSwitcher → divider 规则 → NavIcon
  │ 点击 → onItemTap / onTenantChanged
  ▼
main.dart:_buildScreenForItem → pageType 分发路由
```

根 metadata 在 `initState` 一次性加载，各租户 metadata 遍历加载并缓存。

## 公开组件（`lib/views/navigation.dart`）

整个侧边栏由 `NavSidebar` 一个组件封装，内部编排 `TenantSwitcher`、分隔线、`NavIcon`，`main.dart` 只传数据。

| 组件 | 说明 |
|---|---|
| `NavSidebar` | 完整侧边栏，接收 sections / selectedIndex / onItemTap / tenants / selectedTenant / onTenantChanged |
| `TenantSwitcher` | 租户切换下拉菜单，`NavSidebar` 内部使用 |
| `NavIcon` | 图标按钮，`NavSidebar` 内部使用 |
| `NavItem` | 运行时导航项数据类 |
| `NavSection` | 导航段数据类 |

测试文件 `test/widgets/nav_widgets_test.dart` 直接 import 使用，不再重复定义。

## 真实示例

### 根 metadata.json

```json
{
  "tenants": [
    { "id": "internal", "name": "量潮创始人", "icon": "person_outline", "dir": "founder" },
    { "id": "customer", "name": "量潮科技", "icon": "business_outlined", "dir": "company" }
  ],
  "sections": [
    { "id": "panorama",  "dividerBefore": false },
    { "id": "business",  "dividerBefore": true },
    { "id": "function",  "dividerBefore": true }
  ]
}
```

### founder/metadata.json

```json
{
  "sections": [
    { "id": "panorama", "items": [
      { "label": "全景图", "icon": "today_outlined", "pageType": "panorama" }
    ]},
    { "id": "business", "items": [
      { "label": "思考", "icon": "psychology_outlined", "pageType": "thinking" },
      { "label": "写作", "icon": "edit_outlined", "pageType": "writing" }
    ]}
  ]
}
```

→ 侧边栏: 全景图 | 分隔线 | 思考 · 写作
（全景图段 dividerBefore=false → 无上分隔线）

### company/metadata.json

```json
{
  "sections": [
    { "id": "panorama", "items": [
      { "label": "全景图", "icon": "today_outlined", "pageType": "panorama" }
    ]},
    { "id": "business", "items": [
      { "label": "量潮数据", "icon": "storage_outlined", "pageType": "business_detail" },
      { "label": "量潮课堂", "icon": "school_outlined", "pageType": "business_detail" },
      { "label": "量潮咨询", "icon": "support_agent_outlined", "pageType": "consulting" },
      { "label": "量潮云", "icon": "cloud_outlined", "pageType": "business_detail" }
    ]},
    { "id": "function", "items": [
      { "label": "人力资源", "icon": "people_outline", "pageType": "function_detail" },
      { "label": "财务管理", "icon": "account_balance_outlined", "pageType": "function_detail" },
      { "label": "组织管理", "icon": "account_tree_outlined", "pageType": "function_detail" },
      { "label": "战略管理", "icon": "track_changes_outlined", "pageType": "function_detail" },
      { "label": "新媒体", "icon": "campaign_outlined", "pageType": "function_detail" }
    ]}
  ]
}
```

→ 侧边栏: 全景图 | 分隔线 | 数据·课堂·咨询·云 | 分隔线 | 人力·财务·组织·战略·新媒体

注意 founder 只引用了 `panorama` + `business` 两个段，company 引用了全部三个段。

## Schema

### 根 metadata.json

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `tenants` | array | 是 | 所有可用租户 |
| `tenants[].id` | string | 是 | 逻辑 ID，不依赖目录名 |
| `tenants[].name` | string | 是 | 租户显示名，出现在 `TenantSwitcher` |
| `tenants[].icon` | string | 是 | 图标名 |
| `tenants[].dir` | string | 是 | fixture 子目录名，解耦 ID 和路径 |
| `sections` | array | 是 | 导航段定义 |
| `sections[].id` | string | 是 | 段标识符，租户按 id 引用 |
| `sections[].dividerBefore` | boolean | 是 | 该段前是否渲染分隔线 |

### 每租户 metadata.json

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `sections` | array | 是 | 该租户引用的导航段 |
| `sections[].id` | string | 是 | 引用根的段 id |
| `sections[].items` | array | 是 | 该段下导航项 |
| `items[].label` | string | 是 | 显示文字，也用作匹配 panorama 的 key |
| `items[].icon` | string | 是 | 图标名，传给 `NavIcon` |
| `items[].pageType` | string | 是 | 路由类型 |

### pageType 路由表

| pageType | 目标页面 | 依赖数据 |
|---|---|---|
| `panorama` | `PanoramaScreen` | panorama.json |
| `thinking` | `ThinkingScreen` | 无 |
| `writing` | `Center(child: Text('即将上线'))` | 无 |
| `consulting` | `QtConsultScreen` | qtconsult.json |
| `business_detail` | `BusinessDetailScreen` | panorama.json → `businessUnits` |
| `function_detail` | `FuncDetailScreen` | panorama.json → `functionCards` |

### 可用图标

`person_outline` `business_outlined` `today_outlined` `storage_outlined`
`school_outlined` `support_agent_outlined` `cloud_outlined`
`psychology_outlined` `edit_outlined` `people_outline`
`account_balance_outlined` `account_tree_outlined`
`track_changes_outlined` `campaign_outlined`

定义在 `NavItemData.resolveIcon()` 的 `const icons` map，未识别的降级为 `Icons.circle_outlined`。

## 设计决策

### 为什么 metadata 和 panorama 分开？

**之前：** 导航结构由 `PanoramaData.businessUnits + functionCards` 推导，调顺序必须改业务数据。

**现在：** metadata 独立控制导航，panorama 只提供页面内容。

### 为什么拆根 metadata + 每租户 metadata？

上一版每租户自己的 metadata.json 包含完整信息（tenant + sections），分隔线规则写在 Dart 代码的 if-else 里。拆为两层后：

- **根 = 注册表：** 有哪些租户、有哪些段、分隔线规则——这些都是全局不变的
- **每租户 = 内容：** 该租户用哪些段、段里放什么项——这些是租户间差异

新增租户只需要在根加一条注册 + 写内容文件，不再改 `fixture_config.dart`、`_loadData()`、`TenantSwitcher` 三处 Dart。

### 为什么 sections 用 id 引用而不是位置？

第一版 sections 是位置数组（index 0 = 全景图，index 1 = 业务线）。positional 隐式依赖顺序，容易错位。id 引用显式声明了"我是什么段"，根和租户通过 id 匹配，顺序由根定义控制。

### 为什么 icon 用字符串？

JSON 没有枚举类型。字符串 + 集中 map 解析，fixture 可读且无 Dart 类型引用。

### 为什么 `NavItem.builder` 是零参数闭包？

之前 builder 接受 `(PanoramaData, String)` 且闭包在 `_buildSections()` 外部捕获，切换租户后 `_data` 变了但闭包未更新。现在 builder 在 `_buildSections()` 重建时生成，从 `_selectedPanorama` 取值，始终最新。

### 为什么提取公开组件？

`NavIcon`、`TenantSwitcher` 等原为 `main.dart` 私有类，widget test 被迫重复定义。提取到 `views/navigation.dart` 后可直接 import，减少代码重复。

### 为什么 NavSidebar 封装完整侧边栏？

上一版布局逻辑（flatIndex 计算、divider 插入、TenantSwitcher 排列）写在 `main.dart` 的 `_buildSidebar()` 里，不可独立测试、不可复用。`NavSidebar` 将其封装为一个 props-driven widget，`main.dart` 从编排布局降级为传数据。

## 操作指南

### 新增导航项

1. 对应租户的 metadata.json sections[].items 里加一项
2. 如果 pageType 是 `business_detail` 或 `function_detail`，panorama.json 也要加对应数据（label 一致）

### 新增图标

1. `NavItemData.resolveIcon()` 的 `const icons` map 加一条
2. metadata.json 对应项 icon 字段填这个名称

### 新增 pageType

1. `main.dart:_buildScreenForItem()` 加 case 分支
2. 需要新数据则在 `_loadData()` 的 `Future.wait` 添加加载

### 新增租户

1. 根 `metadata.json` 的 `tenants[]` 加一条
2. `assets/fixtures/` 下按 `dir` 值新建目录
3. 写 `metadata.json` + `panorama.json`（以及可选 `qtconsult.json`）

不需要改任何 Dart 文件。

### 新增导航段

1. 根 `metadata.json` 的 `sections[]` 加一条（定义 `dividerBefore`）
2. 需要此段的租户在自己 metadata.json 里引用该 id

## 已知陷阱

| 陷阱 | 优先级 | 说明 |
|---|---|---|
| 咨询数据硬编码为 customer | 中 | `QtConsultLoader.load(tenant: TenantType.customer)`，founder 若有 consulting 页会展示 company 数据 |
| per-tenant metadata.json 引用的 section id 必须在根存在 | 低 | 运行时 `_buildSections()` 查找不到会抛 StateError |
