# quanttide-finance-toolkit

**量潮财务记录标准化工具箱** —— 把各种原始记录收进系统，标准化、分类、统计。

## 为什么做这个

企业财务里的原始记录来源非常杂：报销单、付款单、银行流水、微信转账截图、聊天消息、口头说明、CSV 导出。

问题不在于“先记账”，而在于**这些记录先天就不统一**：

- 有的只有截图，没有结构化字段
- 有的有金额，没有清晰分类
- 有的能看出是支出，但看不出该归到什么费用类型
- 同一件事可能分散在多条记录里

所以本项目的核心目标不是做一个传统记账 App，而是做两件事：

1. 把各种形态的原始记录标准化进系统
2. 基于标准化结果和分类结果做统计分析

会计凭证只是可选下游，不是主干。

## 核心流程

```text
原始输入（图片 / 聊天 / 表单 / API / CSV / 人工录入）
    ↓
SourceRecord（保留原始证据和原始语义）
    │
    │  ┌─ RecordLink ──┐ (关联表，两端记录存在后创建)
    │  │               │
    ↓  ↓               ↓
NormalizedRecord（抽取并统一成可统计的标准字段）
    │
    ├──→ Statistics（基于标准字段聚合、筛选、钻取）
    │       ↑
    └──→ ClassificationResult（AI/规则/人工分类，作为叠加维度，可选）

可选下游：
NormalizedRecord
    ↓
Journal（日记账）→ JournalEntry（凭证）→ JournalEntryLine（分录行）
```

## 产品定位

- **核心是数据标准化**：先把杂乱记录变成统一结构。
- **核心也是数据统计**：统计基于标准字段和分类结果，而不是只围绕凭证。
- **分类是独立步骤**：分类不是原始事实本身，可以由 AI、规则或人工给出，并允许修订。
- **凭证是可选能力**：只有在需要对接会计系统时，才把标准化记录映射成凭证。

## 核心实体

| 实体 | 作用 | 是否主干 |
|---|---|---|
| `SourceRecord` | 保存原始记录、来源、原始文本、附件引用、导入状态 | 是 |
| `RecordLink` | 关联 SourceRecord 与 NormalizedRecord（支持拆/并关系） | 是 |
| `NormalizedRecord` | 保存标准化后的事实字段，作为统计基线 | 是 |
| `ClassificationResult` | 保存分类、标签、置信度、分类来源、审核状态 | 是 |
| `Journal` / `JournalEntry` / `JournalEntryLine` | 会计凭证层，用于下游记账或系统集成 | 否，可选 |

`SourceDocument` 这个名字过窄，更适合替换为 `SourceRecord`，因为输入不一定是“单据”，也可能是聊天、截图、流水行或导入记录。

## 设计原则

- **原始优先**：原始记录必须保留，方便回溯、复核和重新抽取。
- **标准化与分类分离**：金额、日期、人员、部门等是标准化事实；费用类型、业务标签等是分类结果。
- **统计先于凭证**：产品主线是“能统计、能筛选、能钻取”，不是“先做借贷分录”。
- **允许多轮整理**：同一条记录可以先粗标准化，再补分类，再人工修正。
- **统一类型约定**：所有 `id` 目标使用 `int`，金额使用 `int` 且单位为“分”。

## 当前实现

- `packages/fastapi` **M2 完成** — `SourceRecord` / `NormalizedRecord` / `RecordLink` / `ClassificationResult` 四个 ORM 模型 + Pydantic Schema + Alembic 迁移 + `Normalizer` 接口 + `CsvRowNormalizer` + `ManualNormalizer` + 标准化路由 + GET 列表/详情端点（57 tests）。参见 [`ROADMAP.md`](ROADMAP.md)。
- `packages/dart` 已发布 [`quanttide_finance`](https://pub.dev/packages/quanttide_finance) `^0.1.1`，提供 `Journal`、`JournalEntry`、`JournalEntryLine` 三个 freezed 不可变模型（可选下游凭证层，非主干）。

## 当前 Dart 版本的定位

以下示例对应当前已发布的 Dart 包 `^0.1.1`。它展示的是凭证层模型，不代表本项目未来的完整主干架构。

```yaml
dependencies:
  quanttide_finance: ^0.1.1
```

```dart
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  final journal = Journal(
    id: '1',
    name: '备用金',
    createdAt: DateTime.now(),
  );

  final entry = JournalEntry(
    id: 'je1',
    journalId: journal.id,
    createdAt: DateTime.now(),
    description: '采购办公用品',
    lines: [
      JournalEntryLine(
        id: 'l1',
        type: LineType.debit,
        amount: 1200,
        createdAt: DateTime.now(),
      ),
      JournalEntryLine(
        id: 'l2',
        type: LineType.credit,
        amount: 1200,
        createdAt: DateTime.now(),
      ),
    ],
  );

  print('${entry.description}: 共 ${entry.lines.length} 行');
}
```

## 目标架构

| 路径 | 状态 | 说明 |
|---|---|---|
| `packages/dart` | 已有 | 当前是凭证模型；后续可继续承担共享 DTO 或下游模型 |
| `packages/fastapi` | M2 完成 | 核心模型 + 标准化服务就绪；下一阶段 M3（分类服务） |

## 近期计划

1. **M3（分类服务）**：硬编码 taxonomy + 分类 API + 审核流程（`candidate → accepted/rejected`）。
2. **M4（统计 API）**：按维度 + 指标 + 过滤条件的统一统计查询。
3. **M5（数据安全）**：脱敏器 + 外部 API 审计日志 + Taxonomy 输出校验。
4. 同步升级 Dart 模型，逐步对齐 `int id` 和”分”为单位的金额约定。

## 安全与数据治理（规划）

### 脱敏原则

- **脱敏在数据离站前一刻执行**，不污染存储层。原始 `raw_text` 和 `description` 完整入库，仅在发往外部 AI 前做替换。
- 本地模型（Ollama）调用不脱敏，数据不出域。
- 脱敏使用类型标记替换（`[AMOUNT]`、`[ID_CARD]`、`[BANK_CARD]`），保留语义信息供 AI 参考，不暴露精确值。

### 分类结果审核

- AI 分类结果写入 `ClassificationResult`，`review_status = candidate`，不参与统计。
- 人工审核确认后改为 `accepted`，此时才纳入统计口径。
- 置信度阈值可配置（默认 0.7），低于阈值自动标记待审核。

### Taxonomy 受控词表

- 初期硬编码基础分类列表（`办公用品` / `差旅` / `采购` / `工资` / `其他`）。
- V2 升级为数据库表 + 管理后台，支持增删改并记录版本。
- AI 返回的分类标签必须在 taxonomy 范围内，非法值丢弃或标记异常。

### 输入校验

- `raw_text` 上限 65535 字符，`description` 上限 1000 字符。
- 分类模型上线前使用历史数据做沙箱测试，对比新旧分类差异。

## 待处理事项

| 优先级 | 事项 | 说明 |
|---|---|---|
| 🟡 高 | 脱敏粒度细化 | 金额保留相对大小标记（`[AMOUNT:SMALL]` / `[AMOUNT:LARGE]`），保留量级信息辅助 AI 分类 |
| 🟡 中 | 置信度阈值校准 | 上线后基于实际分布调整默认值 |
| 🟢 低 | 速率限制 | 外部 API 每分钟调用上限、超时、降级策略 |
| 🟢 低 | 附件存储 | `evidence_refs` 指向的对象存储方案 |
| 🟢 低 | 导入格式规范 | CSV / 银行流水导入模板 |

## 许可证

本项目基于 [LICENSE](LICENSE) 发布。

## 链接

- [设计文档](doc/architecture.md) — 架构总览、实体、API、服务、安全、计划
- [Dart 包文档](packages/dart/README.md)
- [更新日志](packages/dart/CHANGELOG.md)
- [报告 Issue](https://github.com/quanttide/quanttide-finance-toolkit/issues)
