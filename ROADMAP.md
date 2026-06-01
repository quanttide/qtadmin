# QuantTide Finance Toolkit — 路线图

---

## 探索阶段：财务数据标准化主干验证

> 来源：数据架构设计文档（2026-05-30）
> 首选方向：`SourceRecord → NormalizedRecord → Statistics` 主干链路

说明：

- `RecordLink` 是 `SourceRecord` 与 `NormalizedRecord` 之间的关联层，不是线性处理节点；两端记录存在后再创建。
- `ClassificationResult` 是叠加维度，不是事实层；分类结果只存于 `ClassificationResult`，不回写 `NormalizedRecord`。
- 统计主干基于 `NormalizedRecord`，未分类记录也可以进入汇总、趋势和明细查询。
- 当前 `packages/dart` 仍是下游凭证层模型；探索阶段主资源投入 `packages/fastapi` 主干。
- 里程碑日期以项目启动日为 Day 0，为工作日估算。

### 里程碑时间线

```text
Day 0 ── M0: 工程脚手架 (3天)
Day 3 ── M1: 核心模型就绪 (11天)
Day 14 ─ M2: 标准化服务可用 (14天)
Day 28 ─ [缓冲 3 天]
Day 31 ─ M3: 分类服务可用 (7天)
Day 38 ─ M4: 统计主干可用 (7天)
Day 45 ─ M5: 数据安全落地 (7天)
Day 52 ─ M6: Dart 包同步升级 (7天)
Day 59 ─ 探索阶段结束
```

### 里程碑详情

| 里程碑 | 目标日期 | 关键交付物 | 通过标准 |
|:-------|:--------:|:-----------|:---------|
| **M0: 工程脚手架** | Day 0-3 | `pyproject.toml` + 依赖管理；Alembic 初始迁移；pytest 框架 + 基础夹具（文件型 SQLite）；~~Docker Compose~~（→ 暂缓项）；~~FastAPI CI~~（→ 暂缓项） | `pytest` 可运行空测试套件通过；健康检查端点返回 200 |
| **M1: 核心模型就绪** | Day 3-14 | `SourceRecord`、`NormalizedRecord`、`RecordLink`、`ClassificationResult` 四个 ORM 模型 + Pydantic Schema + Alembic 迁移 | 模型可通过 Alembic 迁移创建，Pydantic 校验通过；核心模型 pytest 集成测试覆盖 CRUD 主干路径 |
| **M2: 标准化服务可用** | Day 14-28 | `Normalizer` 接口 + 注册机制 + `CsvRowNormalizer` + `ManualNormalizer` 首批实现 | 单条 CSV 记录导入 → 标准化记录生成 → `GET /normalized-records` 列表返回该记录，`GET /normalized-records/{id}` 返回详情；pytest 覆盖 Normalizer 注册、CSV 解析成功/错误路径 |
| **M3: 分类服务可用** | Day 31-38 | V1 硬编码 Taxonomy + 分类 API + 审核状态流转（`candidate → accepted/rejected`） | 标准化记录可通过 API 添加分类，审核流程走通；pytest 覆盖分类创建、审核流转、非法标签拦截 |
| **M4: 统计主干可用** | Day 38-45 | 汇总 / 分组 / 趋势 / 钻取四类统计 API | 至少支持按 `department` 和 `record_type` 两种维度分组统计；pytest 覆盖统计聚合计算正确性 |
| **M5: 数据安全落地** | Day 45-52 | 脱敏器（V1 支持 `[AMOUNT:SMALL]` / `[AMOUNT:LARGE]` 两级分段）+ 外部 API 审计日志 + Taxonomy 输出校验 | 脱敏规则表中每种敏感类型（金额/身份证/银行卡/手机号/人名）至少有一条测试用例验证正确替换；非法分类标签被拒绝并标记 `rejected` + `unknown`；审计日志记录脱敏后输入而非原始数据 |
| **M6: Dart 包同步升级** | Day 52-59 | Dart 模型 `id` 改为 `int`，`amount` 改为 `int`（分），`JournalEntry` 新增 `normalizedRecordId`；版本号从 `0.1.x` → `0.2.0`（breaking change） | 现有测试通过，序列化行为不变；`dart analyze` 无新增错误 |

### 模型验证里程碑

- **标准化效果验证**（M2+7 天）：用至少 3 种不同来源（CSV、手工、银行流水样例）导入数据，统计标准化成功率。通过标准按 source_type 分阶段：CSV ≥ 95%，银行流水 ≥ 90%，聊天消息 ≥ 80%（逐级放宽因结构化程度递减）。
- **分类准确度基线**（M3+14 天）：用至少 50 条已人工分类的记录，对比规则 / AI 分类输出，计算准确率。通过标准：V1 硬编码规则分类准确率 ≥ 80%；按类别分设期望：`办公用品`/`差旅` ≥ 90%，`其他` ≥ 75%。
- **统计口径验证**（M4+7 天）：人工核对统计 API 输出与原始数据，验证金额汇总、记录计数无误。同时检查 `department` 等维度字段的值一致性（无 "研发部" vs "研发部门" 异名同义）。

### Dart 包同步评估（M2 结束时启动）

M2 结束时（Day 28）启动 Dart 包同步评估，而非等到 M6 才动手：

| 评估项 | 方法 | 输出 |
|:-------|:-----|:-----|
| FastAPI 模型字段稳定性 | 检查 M1-M2 期间 model 字段变更次数 | 若变更 ≥ 2 次，M6 延后至字段稳定 2 周后 |
| Dart 包 breaking change 范围 | 列出 `id: String→int`、`amount: double→int`、`JournalEntry` 新增字段的调用方影响 | 影响分析报告 |
| 测试兼容性 | 在 Dart CI 中运行 `dart analyze + dart test` 检查当前状态 | CI 基线快照 |

### 实施边界

与字段默认值、约束规则、截断策略相关的所有规格，以 **`doc/entities.md`** 为唯一规范来源。本文档只列架构级边界：

- `NormalizeInput.existing_normalized_id` 在 M2 实现为 `Optional[int]`，传入时抛出 `NotImplementedError`（接口预留，实现延后）。
- 统计层不做写死的 `by_department`、`by_expense_type` 端点，统一走"维度 + 指标 + 过滤条件"。
- 统计维度字段（`department`、`person`、`record_type` 等）应在应用层做值归一化，避免异名同义。V1 不做枚举约束，但 M4 验证里程碑需检查值一致性。
- 审计日志 V1 存储在数据库独立表（`api_audit_log`）中，保留期 90 天，按时间戳分区。暂缓项中的"清理策略"指自动化归档与删除策略，手动清理可随时执行。
- 每个里程碑的通过标准隐式包含对应 API 的 pytest 集成测试覆盖主干路径和错误路径，覆盖率目标 ≥ 80%。
- 测试数据库策略：文件型 SQLite + Alembic 迁移建表。详见 `doc/entities.md` 末尾。

### M0 / M1 执行清单

| 阶段 | 步骤 | 内容 |
|:-----|:-----|:-----|
| **M0** | 1 | 搭建项目骨架（`pyproject.toml`、Alembic；~~CI `fastapi-check.yml`~~ → 暂缓至 M2 路由就绪后） |
| | 2 | 实现健康检查端点 |
| | 3 | 数据库烟雾测试：夹具获取 session + `alembic upgrade head` 成功（文件型 SQLite，Alembic 迁移建表） |
| **文档** | 4 | 在 `doc/entities.md` 锁定所有默认值、约束规则、截断策略、枚举值域 |
| **M1** | 5 | **Schema 单测**：字段类型、必填、`ge=0`、枚举值校验、`raw_text` 超限拒绝（422）、`description` 截断 |
| | 6 | **ORM 集成测试**：模型实例化、默认值注入、外键关联创建、`RecordLink` 的 `IntegrityError` |
| **M1 不做** | — | 不设 `ClassificationResult` 联合唯一约束；不写标准化/分类业务逻辑测试；不引入 PostgreSQL 方言测试 |

### 高风险变量数据获取计划

| 变量 | 当前状态 | 获取计划 | 预计获取时间 |
|:-----|:--------:|:---------|:-----------:|
| 标准化规则覆盖率 | 未知（CSV / 手工先行） | 每新增一种 `source_type` 记录覆盖比例与失败原因 | M2 起持续跟踪 |
| SourceRecord 导入失败率 | 未知 | 按 `source_type` 统计 `ingestion_status = failed` 占比 | M1 起持续跟踪 |
| AI 分类置信度分布 | 未知 | 上线 AI 分类后采集置信度直方图，并按 taxonomy 分层观察 | M3 + AI 分类器接入后 |
| 人工审核工作量 | 未知 | 统计 `candidate → accepted/rejected` 的平均延迟与积压量 | M3 起持续跟踪 |
| 外部 API 调用成本 | 未知 | 审计日志记录每次调用耗时、请求量与费用 | 首次接入外部 AI 起跟踪 |
| 未分类记录占比 | 未知 | 监控进入统计但缺少 `accepted` 分类结果的记录比例 | M4 起持续跟踪 |

### 暂缓项

- Docker Compose 环境（SQLite 单机开发已够用，PostgreSQL 场景尚无需求）。
- FastAPI CI 流水线 `fastapi-check.yml`（M2 路由就绪后再加，届时 CI 才有真实的回归校验价值）。
- 置信度阈值校准 SOP（V1 使用固定阈值 0.7）。
- 速率限制与成本控制（外部 API 调用由人工控制频率）。
- 附件对象存储方案（V1 `evidence_refs` 存本地路径或 URL）。
- CSV / 银行流水导入模板（M2 的 `CsvRowNormalizer` 按约定列名实现，模板作为后续增强）。
- 审计日志自动化清理策略（手动清理可行，保留期 90 天）。

---

*以上为数据架构设计（2026-05-30）输出的探索阶段。后续阶段将在此路线图中逐步追加。*
