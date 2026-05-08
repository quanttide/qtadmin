# QtClassData Schema

## Fixture 路径

`assets/fixtures/company/qtclass.json`

## QtClassData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `components` | object[] | 是 | 量潮课堂的组成部分列表 |

## QtClassComponentData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `type` | string | 是 | — | `"schoolEnterprise"` / `"trainingBase"` / `"internalTeaching"` / `"oneOnOne"` |
| `name` | string | 是 | — | 组件显示名 |
| `description` | string | 是 | — | 描述 |
| `status` | string | 是 | — | 状态标签（如 `"进行中"`、`"运营中"`、`"常态化"`、`"可预约"`） |
| `studentCount` | number | 是 | — | 学员数 |
| `projectCount` | number | 是 | — | 项目数 |
| `deadline` | string | 否 | `null` | 截止时间描述 |
| `highlights` | string[] | 是 | — | 亮点列表 |

## ComponentType 枚举

| 值 | 含义 | 图标 | 颜色 |
|---|---|---|---|
| `schoolEnterprise` | 校企合作 | `business_outlined` | `#1565C0` |
| `trainingBase` | 实训基地 | `school_outlined` | `#2E7D32` |
| `internalTeaching` | 内部教学 | `group_outlined` | `#6A1B9A` |
| `oneOnOne` | 一对一 | `person_outline` | `#E65100` |
