# 财务管理

量潮财务管理模块提供财务记录的标准化录入、分类和统计分析能力。核心流程：

```
录入 → 标准化确认 → 分类审核 → 统计看板
```

## 使用方式

### Studio 工作台

在量潮管理后台侧边栏点击"财务管理"进入 Finance 工作区。

工作区分为四个区域：

**统计概览** — 顶部三张卡片显示当前范围内的汇总数据：
- Records：标准化记录总数
- Amount：金额汇总
- Classified：已确认分类的记录数

**手工录入** — 左侧"Manual Entry"面板：
1. 填写 Raw Text（原始描述，如"打车到机场，188 元"）
2. 填写 Business Date（格式 `YYYY-MM-DD`）
3. 填写 Amount Cents（金额，单位为分，如 `18800` 表示 ¥188.00）
4. 选择 Record Type（expense / income / transfer / reimbursement / other）
5. 选择 Direction（outflow 支出 / inflow 收入）
6. 填写 Department 和 Person
7. 填写 Description
8. 点击"提交录入"

录入成功后系统同时创建 SourceRecord 和 NormalizedRecord。

**审核队列** — 右侧"Review Queue"面板：
- 每条记录显示描述、日期、金额、部门、当前分类
- 点击"编辑"可修改记录字段
- 点击"审核"打开分类审核对话框，选择分类并确认/驳回
- 勾选多条记录后点击"批量确认"可一次审核多条

**趋势与分布** — 下方面板：
- "Department Breakdown"：按部门分组的金额与记录数排行
- "Monthly Trend"：月度金额与记录数趋势

### 命令行

```bash
# 启动后端服务
cd packages/finance/fastapi
uvicorn fastapi_quanttide_finance.app:app --reload

# 运行 Dart 测试
cd packages/finance/dart
dart test

# 运行 FastAPI 测试
cd packages/finance/fastapi
python -m pytest
```

### 演示 Demo

```bash
cd examples/finance
python seed.py          # 生成种子数据
# 打开 index.html 体验完整流程
```

Demo 覆盖五步产品流程：录入 → 标准化确认 → 自动分类 → 批量审核 → 统计看板。

## 核心概念

| 术语 | 说明 |
|---|---|
| SourceRecord | 原始记录，保留导入时的原始证据和文本 |
| NormalizedRecord | 标准化记录，抽取后的结构化事实字段 |
| ClassificationResult | 分类结果，作为叠加维度不写入标准化记录 |
| RecordLink | 关联表，连接 SourceRecord 与 NormalizedRecord |
| amount_cents | 金额，单位为分（如 ¥188.00 = 18800） |
| direction | 资金方向，outflow（支出）或 inflow（收入） |

## API

后端提供 REST API（默认 `http://localhost:8000`）：

| 端点 | 方法 | 说明 |
|---|---|---|
| `/source-records` | GET/POST | 原始记录列表/创建 |
| `/source-records/{id}` | GET | 原始记录详情 |
| `/source-records/{id}/normalize` | POST | 执行标准化 |
| `/normalized-records` | GET/POST | 标准化记录列表/创建 |
| `/normalized-records/{id}` | GET/PATCH | 标准化记录详情/更新 |
| `/normalized-records/{id}/classifications` | GET/POST | 分类结果列表/创建 |
| `/classifications/{id}` | PATCH | 审核分类（accepted/rejected） |
| `/statistics/summary` | GET | 统计汇总 |
| `/statistics/breakdown` | GET | 分组统计 |
| `/statistics/trend` | GET | 趋势统计 |
| `/statistics/drilldown` | GET | 明细查询 |

## Studio 集成配置

API base URL 通过 `QTADMIN_FINANCE_API_BASE_URL` 环境变量或 `FinanceModuleConfig` 注入，避免硬编码。

## 限制

- 金额以分为单位，字段约束 `amount_cents >= 0`，方向通过 `outflow`/`inflow` 表示
- `raw_text` 超过 65535 字符会被拒绝
- `description` 超过 1000 字符自动截断
- 分类审核通过（`accepted`）后才纳入统计口径
