# Flutter 数据暴露壳（F0）开发计划

## 一、背景与前提

### 当前状态

| 层 | 包 | 状态 |
|:---|:-----|:------|
| 后端 API | `packages/fastapi` | M2 完成 — 6 个端点已实现（4 GET：source-records 列表/详情、normalized-records 列表/详情；2 POST：创建 source-record、标准化）。ClassificationResult 路由为 M3。 |
| 数据模型 | `packages/dart` | 已发布 `^0.1.1`，仅含凭证层模型（Journal / JournalEntry / JournalEntryLine） |
| **客户端** | — | **不存在** |

### 选型

Flutter Web + Dart，理由：
- **模型复用**：`packages/dart` 的 freezed 模型可直接被 Flutter 项目引用，无需手工维护 JSON 解析层
- **跨平台**：一套代码跑 Web / 桌面 / 移动端
- **团队语言栈**：与 Dart 包同语言，不引入 JavaScript/TypeScript

### F0 目标

不是"管理后台"，是**数据暴露壳**：

1. Dart 包补齐 DTO 模型并发布 v0.2.0，使 Flutter 项目能通过 `package:` 依赖获得类型安全的 JSON 反序列化
2. Typed API client 封装 4 个已实现的 GET 端点
3. 最小 Flutter 应用验证数据流「API → 反序列化 → 可读展示」

**不在 F0 范围内**（全部后移）：
- 页面体系、底部导航、路由
- Detail page、关联数据遍历
- ClassificationResult 相关（M3 路由未实现）
- 写入表单、分类审核、统计卡片
- Widget tests、Golden tests

---

## 二、Dart 包同步（v0.2.0）

### 目录结构

```
packages/dart/
├── lib/
│   ├── quanttide_finance.dart   # 导出 models/ + dto/
│   └── src/
│       ├── models/              # 已有凭证层模型，不受影响
│       │   ├── journal.dart
│       │   └── journal_entry.dart
│       └── dto/                 # 新增 API DTO
│           ├── enums.dart       # 枚举定义（5 个枚举，仅 F0 DTO 所用）
│           ├── source_record.dart
│           └── normalized_record.dart
├── test/
│   ├── models/                  # 已有测试，不变
│   └── dto/                     # 新测试
└── pubspec.yaml                 # 版本 ↑ 0.2.0
```

### 序列化规则

每个 DTO 类单独标注 `@JsonSerializable(fieldRename: FieldRename.snake)`，**不修改 `build.yaml`**。已有模型的 `camelCase` 行为不受影响。

| 位置 | JSON key 格式 | 机制 |
|:-----|:-------------|:-----|
| `lib/src/dto/` | `snake_case`（`source_type`、`amount_cents`） | `@JsonSerializable(fieldRename: FieldRename.snake)` |
| `lib/src/models/` | `camelCase`（`createdAt`、`journalId`） | 默认行为，无注解 |

### 枚举映射

服务端使用 `snake_case` wire value（`csv_row`、`bank_tx`），Dart 枚举用 `@JsonValue` 显式映射：

```dart
@JsonEnum()
enum SourceType {
  @JsonValue('image') image,
  @JsonValue('chat') chat,
  @JsonValue('form') form,
  @JsonValue('csv_row') csvRow,
  @JsonValue('bank_tx') bankTx,
  @JsonValue('api') api,
  @JsonValue('manual') manual,
  @JsonValue('other') other,
  @JsonValue('__unknown__') unknown,
}
```

每个 DTO 中使用该枚举的字段须额外声明 `@JsonKey(unknownEnumValue: SourceType.unknown)`，否则 `json_serializable` 在遇到未知 wire value 时会直接抛 `Error` 而非回退到 `unknown`：

```dart
@JsonKey(unknownEnumValue: SourceType.unknown)
final SourceType sourceType;
```

F0 需要的枚举（仅 DTO 所用）：`SourceType`、`IngestionStatus`、`RecordType`、`Direction`、`NormalizationStatus`。`RelationType`、`Taxonomy`、`ClassifierKind`、`ReviewStatus` 在 M3（ClassificationResult 模型）时再添加，避免在 v0.2.0 中暴露不必要的 API 面积。

### 首批同步的 DTO 字段

最小必需，只覆盖已实现的 GET 端点返回字段。

**SourceRecordDto**

| 字段 | Dart 类型 | 备注 |
|:-----|:----------|:-----|
| id | `int` | |
| sourceType | `SourceType` | 枚举 |
| rawText | `String` | |
| occurredAt | `DateTime?` | |
| ingestionStatus | `IngestionStatus` | 枚举 |
| createdAt | `DateTime` | |

**NormalizedRecordDto**

| 字段 | Dart 类型 | 备注 |
|:-----|:----------|:-----|
| id | `int` | |
| recordType | `RecordType` | 枚举 |
| businessDate | `String` | ISO 8601 YYYY-MM-DD，display-only，不涉及时区转换 |
| amountCents | `int` | 单位分 |
| direction | `Direction` | 枚举 |
| department | `String?` | |
| person | `String?` | |
| description | `String` | |
| createdAt | `DateTime` | |

ClassificationResultDto **延后**到 M3 路由实现后再添加。

---

## 三、Flutter 项目

### 项目结构

```
packages/flutter/
├── lib/
│   ├── main.dart           # 最小应用：调用 client 并展示原始数据
│   └── api/
│       └── client.dart     # FinanceApiClient — 4 个 GET 方法
├── pubspec.yaml
│       dependencies:
│         flutter:
│           sdk: flutter              # Flutter SDK 必须
│         quanttide_finance: ^0.2.0    # 依赖已发布的 v0.2.0，开发期可用 path:
│         http: ^1.2.0
└── test/
    └── api/
        └── client_test.dart # mock HTTP 测试
```

无 `pages/`、无 `widgets/`、无页面路由、无底部导航。

### API Client 设计

```dart
class FinanceApiClient {
  final String baseUrl;
  final http.Client _http;

  FinanceApiClient(this.baseUrl, {http.Client? http})
    : _http = http ?? http.Client();

  Future<List<SourceRecordDto>> listSourceRecords({int skip = 0, int limit = 100}) async {
    final response = await _http.get(
      Uri.parse('$baseUrl/source-records?skip=$skip&limit=$limit'),
    );
    if (response.statusCode != 200) {
      throw ApiException('Failed to load source records', response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => SourceRecordDto.fromJson(e)).toList();
  }

  Future<SourceRecordDto> getSourceRecord(int id) async { ... }
  Future<List<NormalizedRecordDto>> listNormalizedRecords({
    int? sourceRecordId, int skip = 0, int limit = 100,
  }) async { ... }
  Future<NormalizedRecordDto> getNormalizedRecord(int id) async { ... }
}
```

### main.dart

最小可读展示壳。一个 MaterialApp + 单页 `ListView`，依次调用 4 个 GET 端点，每个端点的返回结果作为独立 `Card` 区块展示。

**必须验证的 4 个数据流**：

| GET 端点 | Client 方法 | 展示方式 |
|:---------|:------------|:--------|
| `GET /source-records` | `listSourceRecords()` | 表格/卡片列表 |
| `GET /source-records/{id}` | `getSourceRecord(1)` | 单条详情区块 |
| `GET /normalized-records` | `listNormalizedRecords()` | 表格/卡片列表 |
| `GET /normalized-records/{id}` | `getNormalizedRecord(1)` | 单条详情区块 |

先在 main 中 `await client.listSourceRecords()` 创建一条 SourceRecord，然后对新创建的 id 调用 `getSourceRecord(id)`。NormalizedRecord 同理。整个链路不依赖页面体系、不依赖关联遍历。

---

## 四、里程碑时间线

```
现状：FastAPI M2 完成（57 tests），Dart v0.1.1（仅凭证模型）
        │
        ▼
M2.5：  Dart v0.2.0 — 新增 DTO 模型 + 枚举映射 + 不修改 build.yaml
        （约 1 天）
        │
        ▼
F0：    Flutter 项目创建 + typed API client + 数据展示壳
        （约 1 天）
        │
        ▼
F1+：   管理后台页面体系（后续阶段按需扩展，F0 不展开）
```

## 五、路线图对照

| 原 ROADMAP 条目 | 调整 |
|:----------------|:-----|
| M6（Dart 模型同步：id→int, amount→int） | 保留，仍为凭证层模型的 breaking change |
| — | **新增 M2.5：Dart DTO 同步（v0.2.0）**，作为 Flutter 客户端前置步骤 |
| Flutter 客户端 | **F0（数据暴露壳）**不展开页面体系；管理后台 UI 列为 F1+ 后续阶段 |

## 六、参考文档

- [ROADMAP.md](ROADMAP.md) — 探索阶段路线图
- [doc/api.md](doc/api.md) — API 端点列表（注意：仅 GET 端点已实现）
- [doc/entities.md](doc/entities.md) — 实体字段约束（唯一规范来源）
- [json_serializable 文档](https://pub.dev/packages/json_serializable)
