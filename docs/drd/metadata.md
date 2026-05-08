# metadata.json Schema

## 根 metadata.json

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `workspaces` | array | 是 | 所有可用 Workspace 工作空间 |
| `workspaces[].id` | string | 是 | 逻辑 ID，不依赖目录名 |
| `workspaces[].name` | string | 是 | Workspace 显示名，出现在 `WorkspaceSwitcher` |
| `workspaces[].icon` | string | 是 | 图标名 |
| `workspaces[].dir` | string | 是 | fixture 子目录名，解耦 ID 和路径 |
| `sections` | array | 是 | 导航段定义 |
| `sections[].id` | string | 是 | 段标识符，Workspace 按 id 引用 |
| `sections[].dividerBefore` | boolean | 是 | 该段前是否渲染分隔线 |

```json
{
  "workspaces": [
    { "id": "internal", "name": "量潮创始人", "icon": "person_outline", "dir": "founder" },
    { "id": "customer", "name": "量潮科技", "icon": "business_outlined", "dir": "company" }
  ],
  "sections": [
    { "id": "dashboard",  "dividerBefore": false },
    { "id": "business",  "dividerBefore": true },
    { "id": "function",  "dividerBefore": true }
  ]
}
```

→ `dashboard` 段无上分隔线，`business` 和 `function` 段前有分隔线。

## 每 Workspace metadata.json

`assets/fixtures/{dir}/metadata.json`

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `sections` | array | 是 | 该 Workspace 引用的导航段 |
| `sections[].id` | string | 是 | 引用根的段 id |
| `sections[].items` | string[] | 是 | 导航项 name 列表，通过 `RouteConfig.find(name)` 解析路由 |

items 为纯字符串，对应 `RouteConfig` 中定义的 `id`。label、icon、screenType 均在 Dart 代码的 `RouteConfig` 中集中管理。

founder 引用 `dashboard` + `business` 两个段：

```json
{
  "sections": [
    { "id": "dashboard", "items": ["dashboard"] },
    { "id": "business", "items": ["thinking", "writing"] }
  ]
}
```

→ 侧边栏: 仪表盘 | 分隔线 | 思考 · 写作

company 引用全部三个段：

```json
{
  "sections": [
    { "id": "dashboard", "items": ["dashboard"] },
    { "id": "business", "items": ["data", "classroom", "consulting", "cloud"] },
    { "id": "function", "items": ["hr", "finance", "org", "strategy", "media"] }
  ]
}
```

→ 侧边栏: 仪表盘 | 分隔线 | 数据·课堂·咨询·云 | 分隔线 | 人力·财务·组织·战略·新媒体

## RouteConfig 路由表

路由定义集中在 `lib/route_config.dart` 的 `RouteConfig.all` 列表中。

| id | label | icon | screenType | 依赖数据 |
|---|---|---|---|---|
| `dashboard` | 仪表盘 | `today_outlined` | `dashboard` | dashboard.json |
| `thinking` | 思考 | `psychology_outlined` | `thinking` | thinking.json |
| `writing` | 写作 | `edit_outlined` | `writing` | 无（占位） |
| `consulting` | 量潮咨询 | `support_agent_outlined` | `consulting` | qtconsult.json |
| `classroom` | 量潮课堂 | `school_outlined` | `classroom` | qtclass.json |
| `org` | 组织管理 | `account_tree_outlined` | `org` | org.json |
| `data` | 量潮数据 | `storage_outlined` | `business_detail` | dashboard.json → businessUnits |
| `cloud` | 量潮云 | `cloud_outlined` | `business_detail` | dashboard.json → businessUnits |
| `hr` | 人力资源 | `people_outline` | `function_detail` | dashboard.json → functionCards |
| `finance` | 财务管理 | `account_balance_outlined` | `function_detail` | dashboard.json → functionCards |
| `strategy` | 战略管理 | `track_changes_outlined` | `function_detail` | dashboard.json → functionCards |
| `media` | 新媒体 | `campaign_outlined` | `function_detail` | dashboard.json → functionCards |

## 可用图标

`person_outline` `business_outlined` `today_outlined` `storage_outlined`
`school_outlined` `support_agent_outlined` `cloud_outlined`
`psychology_outlined` `edit_outlined` `people_outline`
`account_balance_outlined` `account_tree_outlined`
`track_changes_outlined` `campaign_outlined`

未识别的降级为 `Icons.circle_outlined`。
