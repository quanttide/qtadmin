# OrgDashboardData Schema

## Fixture 路径

`assets/fixtures/{workspace}/org.json`

## OrgDashboardData

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `institutions` | object[] | 是 | 所有组织机构 |
| `representatives` | object[] | 是 | 所有代表/成员 |
| `ranks` | object[] | 是 | 职级体系 |
| `promotions` | object[] | 是 | 职级晋升记录 |

## OrgInstitutionData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | 机构唯一标识 |
| `name` | string | 是 | — | 机构显示名称 |
| `parentId` | string | 否 | `""` | 父机构 id，空串表示顶级 |
| `level` | int | 否 | `0` | 层级深度（顶级为 0） |
| `status` | string | 是 | — | `"normal"` / `"warning"` / `"overdue"` |
| `lastMeetingDate` | string | 否 | — | 最近会议时间描述（如 `"3天前"`） |
| `nextMeetingDate` | string | 否 | — | 下次会议时间描述（如 `"5天后"`） |
| `expectedFrequency` | string | 否 | `""` | 预期会议频率（如 `"每周一次"`） |
| `memberIds` | string[] | 否 | `[]` | 机构成员 id 列表 |
| `pendingProposalCount` | int | 否 | `0` | 待处理提案数 |

## OrgRepresentativeData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | 代表唯一标识 |
| `name` | string | 是 | — | 代表姓名 |
| `institutionIds` | string[] | 是 | — | 所属机构 id 列表（多对多） |
| `rank` | string | 是 | — | 职级（如 `"M1"`） |
| `term` | string | 否 | `""` | 任期（如 `"2026Q1-Q2"`） |
| `attendanceRate` | number | 否 | `0` | 出勤率（0-100） |
| `proposalCount` | int | 否 | `0` | 提案数 |
| `voteRate` | number | 否 | `0` | 投票参与率（0-100） |
| `objectionCount` | int | 否 | `0` | 反对票数 |
| `tier` | string | 是 | — | 绩效等第：`"green"` / `"yellow"` / `"red"` |
| `recentVotes` | object[] | 否 | `[]` | 最近投票记录 |

## OrgMeetingData（recentVotes 项）

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | 会议唯一标识 |
| `institutionId` | string | 是 | — | 所属机构 id |
| `date` | string | 是 | — | 会议日期（如 `"2026-05-06"`） |
| `title` | string | 是 | — | 会议标题 |
| `agendaItems` | string[] | 否 | `[]` | 议程项列表 |
| `attendeeCount` | int | 否 | `0` | 实际出席人数 |
| `totalMemberCount` | int | 否 | `0` | 应到人数 |

## OrgRankData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `name` | string | 是 | — | 职级名称（如 `"M1"`） |
| `isManagement` | bool | 否 | `false` | 是否为管理岗 |
| `headCount` | int | 否 | `0` | 当前在职人数 |

## OrgPromotionData

| 字段 | 类型 | 必填 | 默认 | 说明 |
|---|---|---|---|---|
| `id` | string | 是 | — | 晋升记录唯一标识 |
| `personName` | string | 是 | — | 晋升人员姓名 |
| `fromRank` | string | 是 | — | 晋升前职级 |
| `toRank` | string | 是 | — | 晋升后职级 |
| `date` | string | 是 | — | 晋升日期（如 `"2026-04-01"`） |
| `isCrossTrack` | bool | 否 | `false` | 是否跨序列晋升 |
