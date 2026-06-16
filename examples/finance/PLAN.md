# Demo 计划：全流程财务演示（产品版）

## 目标

制作一个**单页 Web 应用**覆盖 M1–M4 全链路，让财务部同事体验真实工作流：
**录入结构化单据 → 确认标准化 → 系统自动预分类 → 批量审核确认 → 统计看效果**。

---

## 与现有 demo/index.html 的关系

**新建文件**，不与现有 M4 统计页共用。文件名为 `demo/index.html`（覆盖原统计页），或另起 `demo/full.html`。

---

## 支持范围（硬性约束）

| 维度 | 约束 | 原因 |
|------|------|------|
| 可录入的 source_type | 仅 `manual` | `csv_row` 是批量导入场景，demo 演示单笔录入 |
| 分类 taxonomy | 固定 `expense_type` | 后端只有一个 |
| 分类 category | `办公用品`/`差旅`/`采购`/`工资`/`其他` | 来自 `services/classification.py` |
| 币种 | 默认 `CNY`，不做多币种 | 无业务需求 |
| 金额聚合 | 始终返回数值 | `currency=*` 不暴露 |

**不包含**：`csv_row`/`image`/`chat`/`bank_tx`/`form`/`api`；`source_channel`。

---

## 主流程

```
① 录入单据         ② 确认标准化       ③ 系统自动预分类      ④ 批量审核           ⑤ 看统计
                   （编辑 → 确认）      + 人工调分类          （一键提交一类）
```

---

## 功能模块

### 模块 1：结构化单据录入（M1 修正）

用户填的是业务字段，不是 `raw_text`。

**表单**：

| 字段 | 控件 | 说明 |
|------|------|------|
| 金额 (元) | `<input type="number">` | 必填，单位元 |
| 方向 | `<select>` | 支出 / 收入 |
| 业务日期 | `<input type="date">` | 默认当天 |
| 描述 | `<input type="text">` | 必填 |
| 部门 | `<select>` | 研发部 / 市场部 / 行政部 / 财务部 / 销售部 / 采购部 |
| 人员 | `<input type="text">` | 选填 |

**提交后**：前端组装为 `{ source_type: "manual", raw_text: "..." }` 调 `POST /source-records`。同时直接写入 `NormalizedRecord`（跳过标准化步骤，见下方说明）。

**为什么跳过 POST /source-records → POST .../normalize 两步？**
当前 `manual` Normalizer 没有结构化解析逻辑，它只是原样把 `raw_text` 拷贝到 `description`，`record_type=other`，`normalization_status=draft`。既然 demo 录入时已经填好了结构化字段，直接在录入时写入 `NormalizedRecord` 更高效。提交逻辑变为：

```
POST /source-records（存原始证据）
+ POST /normalized-records（同时写入标准化记录，字段来自表单）
```

---

### 模块 2：确认标准化（M2 修正）

实际是"预览 → 编辑 → 确认"。

录入后立即展示一条**可编辑的标准化记录预览**：

| 字段 | 来源 |
|------|------|
| 金额 / 方向 / 日期 | 来自录入表单 |
| 部门 / 人员 | 来自录入表单 |
| 描述 | 可编辑 |
| record_type | 自动设为 `expense`，可改 |

**按钮**：

| 操作 | 说明 |
|------|------|
| 确认 | 标准化记录写入 `normalization_status=normalized` |
| 修改 | 编辑后重新提交 |
| 放弃 | 删除该条记录（不回写） |

---

### 模块 3：自动分类 + 批量审核（M3 修正）

**核心变化**：系统先自动预分类，用户只需确认。

#### 3a. 自动预分类（前端规则引擎）

根据 `NormalizedRecord.description` 的关键词匹配，预填 `category`：

| 关键词规则 | 分类 |
|-----------|------|
| 含"机票""高铁""住宿""差旅""出差""酒店""交通" | 差旅 |
| 含"A4""墨盒""文具""打印""办公桌""办公椅""纸" | 办公用品 |
| 含"采购""购买""设备""服务器""电脑""软件" | 采购 |
| 含"工资""奖金""薪" | 工资 |
| 未匹配任何规则 | 其他 |

规则写在 JS 中（`function autoClassify(description)`），不入库。**演示目的，非生产逻辑**。

#### 3b. 分类展示分组

标准化记录按 `category` 分组展示：

```
┌─ 差旅（3 条待审核）─────────────────────┐
│  [x] 张伟 - 北京出差机票 - ¥2,300     │
│  [x] 李强 - 上海高铁票 - ¥650          │
│  [x] 王芳 - 杭州住宿 - ¥480            │
│  [确认以上 3 条为差旅]  [批量修改为...] │
├────────────────────────────────────────┤
│  ...其他类别...                         │
└────────────────────────────────────────┘
```

**交互步骤**：

1. 每条记录旁显示系统预判的分类标签（绿色：已匹配 / 灰色：待确认）
2. 用户扫一眼，如果整体分类正确 → 点"确认以上 N 条为 XX" → 批量调 `POST .../classifications` → `review_status=accepted`
3. 如果某条分错了 → 在该条旁下拉框手动改分类
4. 改完后调单条确认

**批量确认 API 调用**：逐条 POST（后端无批量端点，demo 前端循环调 `POST /normalized-records/{id}/classifications`）。

#### 3c. 已审核分类状态变更

确认后该条移到"已审核"区，统计看板 `classified_count` 立即增加。

---

### 模块 4：统计看板（M4 — 复用）

同之前设计，但去掉过滤栏、去掉分类过滤器，自动刷新。

---

## API 调用清单

```
# 1. 录入原始证据
POST /source-records
  { "source_type": "manual", "raw_text": "研发部张伟购A4纸一箱" }

# 2. 同时写入标准化记录（录入时已结构化）
POST /normalized-records
  { "record_type": "expense", "business_date": "2026-09-01",
    "amount_cents": 12000, "direction": "outflow",
    "department": "研发部", "person": "张伟",
    "description": "购买A4纸一箱",
    "normalization_status": "normalized" }

# 3. 批量确认分类
for each id in [3, 7, 12]:
  POST /normalized-records/{id}/classifications
    { "taxonomy": "expense_type", "category": "办公用品",
      "classifier_kind": "rule", "confidence": 0.85 }

# 4. 查看统计
GET /statistics/summary
GET /statistics/breakdown?dimension=department
GET /statistics/trend?granularity=month
GET /statistics/drilldown?limit=15
```

---

## 注意事项

1. **自动分类是演示辅助，非生产逻辑**。JS 关键词匹配只是为了 demo 中"系统先分、人再确认"的交互能跑通。生产环境应走后端规则引擎或 AI。
2. **录入时写 NormalizedRecord** 跳过了 Normalizer 流程。这是因为 demo 场景下用户输入已经是结构化数据。生产环境仍应通过 Normalizer 做抽取。
3. **批量确认无后端批量端点**，前端循环调单条 API。如果后续需要，可以加 `POST /classifications/batch`。
4. **中文映射表**同之前版本。
