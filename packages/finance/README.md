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

## 典型使用流程（产品视角）

以上数据流在财务部日常使用中表现为 5 步操作：

```
① 录入单据 ─→ ② 确认标准化 ─→ ③ 系统自动分类 ─→ ④ 批量审核 ─→ ⑤ 统计看板
  填金额/描述    预览/编辑/确认    关键词匹配预填    扫一眼批量确认     汇总/趋势/明细
  选部门/人员                      分为 5 大类        单条可调类别
```

**每个步骤的职责**：

| 步骤 | 用户做什么 | 系统做什么 | 对应技术层 |
|------|-----------|-----------|-----------|
| ① 录入 | 填写金额、描述、日期、部门、人员等结构化字段 | 将原始证据存入 `SourceRecord`，同时写入 `NormalizedRecord` | M1–M2 |
| ② 确认 | 预览标准化结果，修正字段后点确认 | 确认后 `normalization_status` 标记为 `normalized` | M2 |
| ③ 自动分类 | 无需操作，观察系统预分类结果 | 根据描述关键词（机票→差旅、A4纸→办公用品等）预填 `category` | M3 |
| ④ 批量审核 | 逐类浏览，点"确认"批量接受一类；错分的单条拖到正确类别 | 写入 `ClassificationResult`，`review_status=accepted` 后才纳入统计 | M3 |
| ⑤ 统计 | 查看汇总卡片、部门分布、趋势图、明细表 | 聚合 `NormalizedRecord` 事实字段 + 已接受的分类结果 | M4 |

**重要区分**：数据流（SourceRecord → NormalizedRecord → ClassificationResult）描述的是**数据如何存储**；使用流程描述的是**用户如何操作**。两者对应但并不相同——例如用户录入结构化的金额/描述时，系统同时写入 SourceRecord（存原始证据）和 NormalizedRecord（存结构化事实），不是"用户先填 raw_text、再调标准化 API"。

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

## 当前版本

**v1.0** — M0–M4 全链路完成，Demo 可运行。

- `packages/fastapi` **M0–M4 完成** — 四个 ORM 模型 + Pydantic Schema + Alembic 迁移 + Normalizer 接口 + CsvRowNormalizer + ManualNormalizer + 分类服务 + 4 统计端点（summary/breakdown/trend/drilldown），三包总计 132 tests。
- `demo/` **全流程演示已上线** — 覆盖完整 5 步产品流程：结构化录入 → 预览确认 → 自动预分类 → 批量审核 → 统计看板。一键启动脚本 `run_demo.sh` / `run_demo.bat`。
- `packages/dart` 已发布 [`quanttide_finance`](https://pub.dev/packages/quanttide_finance) `^0.1.1`，提供 `Journal`、`JournalEntry`、`JournalEntryLine` 三个 freezed 不可变模型（可选下游凭证层，非主干）。

## 产品功能矩阵

以下将 5 步产品流程映射到当前的实现状态：

| 步骤 | 用户操作 | 实现状态 | 后端支撑 | Demo 覆盖 |
|------|---------|---------|---------|-----------|
| ① 录入单据 | 填写金额、方向、日期、部门、人员、描述 | **已实现** | `POST /source-records` + `POST /normalized-records` | 结构化表单，录入即写两条记录 |
| ② 确认标准化 | 预览标准化结果，修正字段后点确认 | **已实现** | `PATCH /normalized-records/{id}` 可改任意字段，`normalization_status` 标记已确认 | 可编辑预览面板，确认/放弃按钮 |
| ③ 自动分类 | 系统根据关键词规则预分类，无需操作 | **已实现** | 前端 `autoClassify()`（非生产逻辑，仅 demo） | 关键词匹配 → 预填 `category` |
| ④ 批量审核 | 分组浏览，一键确认一类；错分可单条下调改 | **已实现** | `POST /normalized-records/{id}/classifications` 写入，`PATCH /classifications/{id}` 审核通过 | 5 类分组 + 复选框批量确认 + 下拉改分类 |
| ⑤ 统计看板 | 汇总卡片、部门分布、趋势图、明细表 | **已实现** | `GET /statistics/summary` / `breakdown` / `trend` / `drilldown` | 无过滤栏，自动刷新的 Chart.js 看板 |

**说明**：
- 分类基于前端关键词规则，是演示辅助，非生产逻辑。生产环境应走后端规则引擎或 AI 分类。
- 统计 `classified_count` 仅计入 `review_status=accepted` 的分类结果。
- 所有步骤均可在 `demo/index.html` 中体验完整流程。

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
| `packages/fastapi` | M4 完成 | 核心模型 + 标准化 + 分类 + 统计 API 就绪；下一阶段 M5（数据安全） |

## 近期计划

1. **M5（数据安全）**：脱敏器 + 外部 API 审计日志 + Taxonomy 输出校验。
2. **M6（Dart 模型同步）**：`id` → `int`，`amount` → `int`（分），`normalizedRecordId` 对齐。

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
