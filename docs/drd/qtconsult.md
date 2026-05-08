# QtConsultData Schema

## Fixture 路径

`assets/fixtures/{workspace}/qtconsult.json`

## QtConsultData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `workspace` | string | 否 | `"customer"` / `"internal"`，默认 `"customer"` |
| `projectName` | string | 是 | 项目名称 |
| `phase` | string | 是 | 当前阶段 |
| `industry` | string | 是 | 行业 |
| `scale` | string | 是 | 团队规模描述 |
| `maturity` | string | 是 | 数字化成熟度 |
| `strategyGoal` | string | 是 | 策略目标 |
| `strategyInsight` | string | 是 | 策略洞察 |
| `strategySteps` | string[] | 是 | 策略步骤 |
| `riskNote` | string | 是 | 风险备注 |
| `discoveries` | object[] | 是 | 发现清单 |
| `communications` | object[] | 否 | 沟通记录，默认 `[]` |
| `revisions` | object[] | 是 | 策略修正历史 |
| `stakeholders` | object[] | 是 | 决策链路干系人 |

## DiscoveryData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | PK |
| `text` | string | 是 | — | 描述具体事实 |
| `type` | string | 是 | — | `"risk"` / `"concern"` / `"opportunity"` / `"neutral"` |
| `status` | string | 否 | `"pending"` | `"pending"` → `"confirmed"` / `"dismissed"` |
| `source` | string | 是 | — | 来源会议 |
| `date` | string | 是 | — | 创建日期 |
| `linkedToStrategy` | bool | 否 | `false` | 是否已链接到策略 |

## StrategyRevisionData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | PK |
| `date` | string | 是 | — | 修正日期 |
| `reason` | string | 是 | — | 修正原因 |
| `relatedDiscoveryId` | string? | 否 | `null` | FK → DiscoveryData.id |
| `isReviewed` | bool | 否 | `false` | 是否已审视确认 |

## CommunicationData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | 是 | PK |
| `title` | string | 是 | 标题 |
| `date` | string | 是 | 日期 |
| `summary` | string | 是 | 摘要 |

## StakeholderData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `id` | string | 是 | PK |
| `name` | string | 是 | 姓名 |
| `role` | string | 是 | 角色 |
| `stance` | string | 是 | `"support"` / `"neutral"` / `"oppose"` |
| `concern` | string | 是 | 核心关切 |
| `detail` | string | 是 | 补充说明 |

## WorkspaceType

`"customer"` — 对外交付，数据来源于客户沟通
`"internal"` — 自我诊断，数据来源于量潮云
