# DashboardData Schema

## Fixture 路径

`assets/fixtures/{workspace}/dashboard.json`

## DashboardData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `businessUnits` | object[] | 是 | 业务线列表，展示在仪表盘上方 |
| `functionCards` | object[] | 是 | 职能线卡片列表，展示在仪表盘下方 |

## BusinessUnitData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `name` | string | 是 | — | 业务线名称 |
| `tag` | string | 是 | — | 标签（如 `"主营"`、`"孵化中"`） |
| `isPrimary` | bool | 否 | `false` | 是否主营 |
| `screenType` | string | 否 | — | 覆盖 `pageType`，跳转到独立页面（如 `"consulting"`、`"thinking"`） |
| `consultSource` | string | 否 | — | 咨询数据来源，`"customer"` / `"internal"` |
| `decisions` | object[] | 是 | — | 待决策事项列表 |
| `emptyMessage` | string | 否 | — | 无决策事项时的占位文案 |

## DecisionData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `fromPerson` | string | 是 | — | 发起人 |
| `deadline` | string | 是 | — | 截止时间描述 |
| `title` | string | 是 | — | 决策标题 |
| `context` | string | 是 | — | 上下文背景 |
| `teamAdvice` | string | 是 | — | 团队建议 |
| `isUrgent` | bool | 否 | `false` | 是否紧急 |
| `actions` | object[] | 是 | — | 可执行的决策操作 |

## DecisionAction

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `label` | string | 是 | — | 操作文字 |
| `isPrimary` | bool | 否 | `false` | 是否为主要操作按钮 |

## FuncCardData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `name` | string | 是 | — | 职能名称 |
| `metrics` | object[] | 是 | — | 指标列表（2-3 个） |
| `trend` | object | 否 | — | 趋势状态 |
| `warning` | string | 否 | — | 预警文案 |
| `isWarning` | bool | 否 | `false` | 是否显示预警态 |

## MetricData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `label` | string | 是 | 指标名 |
| `value` | string | 是 | 指标值 |

## TrendData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `text` | string | 是 | — | 趋势描述 |
| `direction` | string | 否 | `"flat"` | `"up"` / `"down"` / `"flat"` |
