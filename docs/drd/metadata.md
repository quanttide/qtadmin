# metadata.json Schema

## 根 metadata.json

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `workspaces` | array | 是 | 所有可用Workspace工作空间 |
| `workspaces[].id` | string | 是 | 逻辑 ID，不依赖目录名 |
| `workspaces[].name` | string | 是 | Workspace工作空间显示名，出现在 `WorkspaceSwitcher` |
| `workspaces[].icon` | string | 是 | 图标名 |
| `workspaces[].dir` | string | 是 | fixture 子目录名，解耦 ID 和路径 |
| `sections` | array | 是 | 导航段定义 |
| `sections[].id` | string | 是 | 段标识符，Workspace工作空间按 id 引用 |
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

## 每Workspace工作空间 metadata.json

`assets/fixtures/{dir}/metadata.json`

| 路径 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `sections` | array | 是 | 该Workspace工作空间引用的导航段 |
| `sections[].id` | string | 是 | 引用根的段 id |
| `sections[].items` | array | 是 | 该段下导航项 |
| `items[].label` | string | 是 | 显示文字，也用作匹配 dashboard 的 key |
| `items[].icon` | string | 是 | 图标名，传给 `NavIcon` |
| `items[].pageType` | string | 是 | 路由类型 |

founder 引用 `dashboard` + `business` 两个段：

```json
{
  "sections": [
    { "id": "dashboard", "items": [
      { "label": "仪表盘", "icon": "today_outlined", "pageType": "dashboard" }
    ]},
    { "id": "business", "items": [
      { "label": "思考", "icon": "psychology_outlined", "pageType": "thinking" },
      { "label": "写作", "icon": "edit_outlined", "pageType": "writing" }
    ]}
  ]
}
```

→ 侧边栏: 仪表盘 | 分隔线 | 思考 · 写作

company 引用全部三个段：

```json
{
  "sections": [
    { "id": "dashboard", "items": [
      { "label": "仪表盘", "icon": "today_outlined", "pageType": "dashboard" }
    ]},
    { "id": "business", "items": [
      { "label": "量潮数据", "icon": "storage_outlined", "pageType": "business_detail" },
      { "label": "量潮课堂", "icon": "school_outlined", "pageType": "classroom" },
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

→ 侧边栏: 仪表盘 | 分隔线 | 数据·课堂·咨询·云 | 分隔线 | 人力·财务·组织·战略·新媒体

## pageType 路由表

| pageType | 目标页面 | 依赖数据 |
|---|---|---|
| `dashboard` | `DashboardScreen` | dashboard.json |
| `thinking` | `ThinkingScreen` | thinking.json |
| `writing` | `Center(child: Text('即将上线'))` | 无 |
| `classroom` | `QtClassScreen` | qtclass.json |
| `consulting` | `QtConsultScreen` | qtconsult.json |
| `business_detail` | `BusinessDetailScreen` | dashboard.json → `businessUnits` |
| `function_detail` | `FuncDetailScreen` | dashboard.json → `functionCards` |

## 可用图标

`person_outline` `business_outlined` `today_outlined` `storage_outlined`
`school_outlined` `support_agent_outlined` `cloud_outlined`
`psychology_outlined` `edit_outlined` `people_outline`
`account_balance_outlined` `account_tree_outlined`
`track_changes_outlined` `campaign_outlined`

未识别的降级为 `Icons.circle_outlined`。
