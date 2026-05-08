# ThinkingData Schema

## Fixture 路径

`assets/fixtures/founder/thinking.json`

## ThinkingData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `title` | string | 是 | 页面主标题 |
| `subtitle` | string | 是 | 副标题 |
| `period` | string | 是 | 周期概述文案 |
| `awarenessSection` | object | 是 | 情境意识段落配置 |
| `awarenessSection.label` | string | 是 | 段落标签名 |
| `awarenessSection.icon` | string | 是 | 段落图标名 |
| `awarenessSection.color` | string | 是 | 段落主题色 hex |
| `stages` | object[] | 是 | 认知阶段列表 |
| `emotions` | object[] | 是 | 情绪数据列表 |
| `emotionNote` | string | 是 | 情绪分析说明 |
| `insightSection` | object | 是 | 心智模型段落配置 |
| `insightSection.label` | string | 是 | 段落标签名 |
| `insightSection.icon` | string | 是 | 段落图标名 |
| `insightSection.color` | string | 是 | 段落主题色 hex |
| `insights` | object[] | 是 | 心智洞察列表 |
| `closing` | object | 是 | 结尾总结 |

## ThinkingStage

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `icon` | string | 是 | 图标名 |
| `title` | string | 是 | 阶段标题 |
| `subtitle` | string | 是 | 副标题 |
| `points` | string[] | 是 | 要点列表 |
| `color` | string | 是 | 主题色 hex |

## ThinkingEmotion

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `label` | string | 是 | 情绪名称 |
| `value` | string | 是 | 统计值（如 `"450次"`） |
| `color` | string | 是 | 主题色 hex |

## ThinkingInsight

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `icon` | string | 是 | 图标名 |
| `title` | string | 是 | 洞察标题 |
| `description` | string | 是 | 洞察描述 |

## ThinkingClosing

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `title` | string | 是 | 总结标题 |
| `description` | string | 是 | 总结描述 |
| `quote` | string | 是 | 金句引用 |
