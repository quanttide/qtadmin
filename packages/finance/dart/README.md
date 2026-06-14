# quanttide_finance

量潮财务领域模型包 —— 日记账与凭证的核心实体。

## 说明

本包是本项目早期发布的 Dart 模型库，提供基于 `freezed` 的不可变财务实体。当前覆盖的是**下游凭证层**（Journal / JournalEntry / JournalEntryLine），并非主干标准化模型。

项目主干（SourceRecord → NormalizedRecord → ClassificationResult → Statistics）正在 FastAPI 上构建中，参见根目录 README。

## 模型

| 实体 | 说明 |
|---|---|
| `Journal` | 日记账（id, name, createdAt） |
| `JournalEntry` | 凭证（id, journalId, createdAt, description, lines） |
| `JournalEntryLine` | 分录行（id, type, amount, description, createdAt） |
| `LineType` | 枚举：`debit` / `credit` |

所有模型支持 `copyWith`、`toJson` / `fromJson`。

## 使用

```dart
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  final journal = Journal(id: '1', name: '备用金', createdAt: DateTime.now());

  final entry = JournalEntry(
    id: 'je1',
    journalId: journal.id,
    createdAt: DateTime.now(),
    description: '采购办公用品',
    lines: [
      JournalEntryLine(id: 'l1', type: LineType.debit, amount: 1200, createdAt: DateTime.now()),
      JournalEntryLine(id: 'l2', type: LineType.credit, amount: 1200, createdAt: DateTime.now()),
    ],
  );
}
```

## 发布

版本 `0.1.1` 已发布到 pub.dev。
