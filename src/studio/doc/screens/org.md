# 组织管理 Screen 实现方案

## 架构模式

```
fixture JSON → Loader → Model → Screen (内聚 Widgets)
```

遵循现有模式：`QtConsultScreen` 级别的独立详情屏，三层 UI 内聚在一个 Screen 中。

## 文件清单

| # | 文件 | 操作 |
|---|------|------|
| 1 | `lib/models/org.dart` | 新增 |
| 2 | `assets/fixtures/company/org.json` | 新增 |
| 3 | `lib/services/org_loader.dart` | 新增 |
| 4 | `lib/screens/org_screen.dart` | 新增 |
| 5 | `assets/fixtures/company/metadata.json` | 修改 |
| 6 | `lib/main.dart` | 修改 |

## 1. Models — `lib/models/org.dart`

```dart
enum InstitutionStatus { normal, warning, overdue }

enum RepPerformanceTier { green, yellow, red }

class OrgInstitutionData {
  final String id;
  final String name;
  final String parentId;       // 上级机构 id，空字符串表示顶层
  final int level;             // 层级（0=合伙人委员会, 1=书记处, 2=执行委/技术委/代表大会）
  final InstitutionStatus status;
  final String? lastMeetingDate;
  final String? nextMeetingDate;
  final String expectedFrequency; // e.g. "每周一次"
  final List<String> memberIds;
  final int pendingProposalCount;
}

class OrgMeetingData {
  final String id;
  final String institutionId;
  final String date;
  final String title;
  final List<String> agendaItems;
  final int attendeeCount;
  final int totalMemberCount;
}

class OrgRepresentativeData {
  final String id;
  final String name;
  final String institutionId;
  final String rank;
  final String term;
  final double attendanceRate;   // 参会率 0-100
  final int proposalCount;       // 提案数
  final double voteRate;         // 表决参与率 0-100
  final int objectionCount;      // 异议次数
  final RepPerformanceTier tier;
  final List<OrgMeetingData> recentVotes;  // 最近5次表决
}

class OrgRankData {
  final String name;             // e.g. "专业序列" / "M1" / "M2"
  final bool isManagement;       // true=M序列, false=非M
  final int headCount;
}

class OrgPromotionData {
  final String id;
  final String personName;
  final String fromRank;
  final String toRank;
  final String date;
  final bool isCrossTrack;       // 是否跨序列晋升
}

class OrgDashboardData {
  final List<OrgInstitutionData> institutions;
  final List<OrgRepresentativeData> representatives;
  final List<OrgRankData> ranks;
  final List<OrgPromotionData> promotions;
}
```

## 2. Fixture — `assets/fixtures/company/org.json`

覆盖 PRD 三层场景：

```json
{
  "institutions": [
    { "id": "partner",   "name": "合伙人委员会",    "parentId": "",            "level": 0, "status": "normal",  "expectedFrequency": "每月一次", "pendingProposalCount": 0 },
    { "id": "secretary", "name": "书记处",           "parentId": "partner",    "level": 1, "status": "normal",  "expectedFrequency": "每周一次", "pendingProposalCount": 1 },
    { "id": "assembly",  "name": "公司代表大会",     "parentId": "secretary",  "level": 2, "status": "normal",  "expectedFrequency": "每周一次", "pendingProposalCount": 1 },
    { "id": "exec",      "name": "执行委员会",       "parentId": "assembly",   "level": 2, "status": "warning", "expectedFrequency": "每周一次", "pendingProposalCount": 2, "nextMeetingDate": "明天" },
    { "id": "tech",      "name": "技术委员会",       "parentId": "assembly",   "level": 2, "status": "overdue", "expectedFrequency": "每周一次", "pendingProposalCount": 3, "lastMeetingDate": "12天前", "nextMeetingDate": "逾期" }
  ],
  "representatives": [
    { "id": "p1", "name": "张三", "institutionId": "secretary", "rank": "M1", "term": "2026Q1-Q2", "attendanceRate": 100, "proposalCount": 5, "voteRate": 100, "objectionCount": 1, "tier": "green", "recentVotes": [] },
    { "id": "p2", "name": "李四", "institutionId": "exec",     "rank": "M2", "term": "2026Q1-Q2", "attendanceRate": 60,  "proposalCount": 2, "voteRate": 70,  "objectionCount": 0, "tier": "yellow", "recentVotes": [] }
  ],
  "ranks": [
    { "name": "专业序列", "isManagement": false, "headCount": 5 },
    { "name": "M1",       "isManagement": true,  "headCount": 2 },
    { "name": "M2",       "isManagement": true,  "headCount": 1 }
  ],
  "promotions": [
    { "id": "pr1", "personName": "王五", "fromRank": "专业序列", "toRank": "M1", "date": "2026-04-01", "isCrossTrack": true }
  ]
}
```

## 3. Loader — `lib/services/org_loader.dart`

模式同 `QtConsultLoader`：

- 从 `assets/fixtures/company/org.json` 加载
- `OrgDashboardData.fromJson()` 解析
- 带 `_cache`

## 4. Screen — `lib/screens/org_screen.dart`

三层布局，同 `QtConsultScreen` 的模式：

```
┌─ TopBar ──────────────────────────────┐
│ 组织管理   职能线                      │
├─ StatsBar ────────────────────────────┤
│ 机构 5  代表 2  职级 3  待晋升 1      │
├─ 机构看板 ────────────────────────────┤
│ ┌──────────┐ ┌──────────┐ ┌─────────┐│
│ │技术委员会 │ │执行委员会 │ │书记处   ││
│ │逾期(红色) │ │即将到期  │ │正常     ││
│ └──────────┘ └──────────┘ └─────────┘│
├─ 代表履职 ────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ 张三  M1  秘书处  绿标 100%参会  │ │
│ │ └ 近期记录（可展开）            │ │
│ ├──────────────────────────────────┤ │
│ │ 李四  M2  执行委  黄标  60%参会 │ │
│ └──────────────────────────────────┘ │
├─ 职级流动 ────────────────────────────┤
│ 专业序列 5人  |  M1 2人  |  M2 1人   │
│ ─── 晋升记录 ───                      │
│ 王五  专业序列→M1  2026-04-01  跨序列 │
└───────────────────────────────────────┘
```

状态管理：`StatefulWidget`，内部管理展开/收起状态。

## 5. 导航改造

### `assets/fixtures/company/metadata.json`

将组织管理的 `pageType` 从 `"function_detail"` 改为 `"org"`：

```json
{ "label": "组织管理", "icon": "account_tree_outlined", "pageType": "org" }
```

### `lib/main.dart`

```dart
// 新增 import
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/screens/org_screen.dart';
import 'package:qtadmin_studio/services/org_loader.dart';

// 新增状态变量
OrgDashboardData? _orgData;

// _loadData 中增加加载
_orgData = await OrgLoader.load();

// _buildScreenForItem 中增加分支
case 'org':
  return OrgScreen(data: _orgData!);
```

## 依赖关系

```
org_screen.dart → org.dart (model)
org_loader.dart → org.dart (model)
main.dart → org_loader.dart, org_screen.dart, org.dart
```
