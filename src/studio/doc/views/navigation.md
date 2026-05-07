# 元数据驱动导航

**metadata.json 决定导航长什么样（结构/图标/租户），panorama.json 决定页面内容是什么。** 两者分离，改导航不用动业务数据，反之亦然。

新增租户只需写 fixture 目录 + metadata.json + panorama.json，不改一行 Dart 代码。

## 工作方式

```
metadata.json  (每租户一份)
       │ MetadataLoader.readAsString → NavMetadata.fromJson
       ▼
NavMetadata { tenant, sections[].items[{label, icon, pageType}] }
       │ main.dart:_buildSections → 为每项构建 page widget 闭包
       ▼
_buildSidebar → NavIcon(label, icon, onTap)
       │ 点击 → _selectedIndex
       ▼
_buildScreenForItem → pageType 分发路由
```

两个租户的 metadata 在 `initState` 并行加载，切换时从缓存读取。

## 真实示例

### founder（量潮创始人）

```json
{
  "tenant": { "name": "量潮创始人", "icon": "person_outline" },
  "sections": [
    { "items": [
      { "label": "全景图", "icon": "today_outlined", "pageType": "panorama" }
    ]},
    { "items": [
      { "label": "思考", "icon": "psychology_outlined", "pageType": "thinking" },
      { "label": "写作", "icon": "edit_outlined", "pageType": "writing" }
    ]}
  ]
}
```

→ 侧边栏: 全景图 | 分隔线 | 思考 · 写作

### company（量潮科技）

```json
{
  "tenant": { "name": "量潮科技", "icon": "business_outlined" },
  "sections": [
    { "items": [
      { "label": "全景图", "icon": "today_outlined", "pageType": "panorama" }
    ]},
    { "items": [
      { "label": "量潮数据", "icon": "storage_outlined", "pageType": "business_detail" },
      { "label": "量潮课堂", "icon": "school_outlined", "pageType": "business_detail" },
      { "label": "量潮咨询", "icon": "support_agent_outlined", "pageType": "consulting" },
      { "label": "量潮云", "icon": "cloud_outlined", "pageType": "business_detail" }
    ]},
    { "items": [
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

## Schema

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `tenant.name` | string | 是 | 租户显示名，出现在租户切换器 |
| `tenant.icon` | string | 是 | 图标名，见下方可用列表 |
| `sections` | array | 是 | 导航段数组，每段前插入分隔线 |
| `sections[].items` | array | 是 | 该段下导航项 |
| `items[].label` | string | 是 | 显示文字，也用作匹配 panorama 的 key |
| `items[].icon` | string | 是 | 图标名 |
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

**现在：** metadata.json 独立控制导航，panorama.json 只提供页面内容。

### 为什么 icon 用字符串？

JSON 没有枚举类型。字符串 + 集中 map 解析，fixture 可读且无 Dart 类型引用。

### 为什么 `_NavItem.builder` 是零参数闭包？

之前 builder 接受 `(PanoramaData, String)`，切换租户后闭包捕获旧数据。现在 `_buildSections()` 重建时生成，从 `_selectedPanorama` 取值，始终最新。

## 操作指南

### 新增导航项

1. metadata.json 对应 section 的 items 里加一项
2. 如果 pageType 是 `business_detail` 或 `function_detail`，panorama.json 也要加对应数据（label 一致）
3. 重启 app（metadata 有缓存）

### 新增图标

1. `NavItemData.resolveIcon()` 的 `const icons` map 加一条
2. metadata.json 对应项 icon 字段填这个名称

### 新增 pageType

1. `_buildScreenForItem()` 加 case 分支
2. 需要新数据则在 `_loadData()` 的 `Future.wait` 添加加载

### 新增租户

1. `assets/fixtures/` 下新建目录
2. 写 metadata.json + panorama.json
3. `fixture_config.dart` 的 switch 里加路径
4. `main.dart:_loadData()` 的 Future.wait 加加载
5. `TenantSwitcher` 的 `tenants` 参数加新 metadata.tenant

## 已知陷阱

| 陷阱 | 优先级 | 说明 |
|---|---|---|
| 咨询数据硬编码为 customer | 中 | `QtConsultLoader.load(tenant: TenantType.customer)`，founder 若有 consulting 页会展示 company 数据 |
| 第 0 段上方分隔线与规格不符 | 低 | 所有段前都有分隔线，规格图要求全景图上无分隔线 |
| 新增租户需改 3 个 Dart 文件 | 中 | fixture_config、_loadData、TenantSwitcher，缺一不可 |
