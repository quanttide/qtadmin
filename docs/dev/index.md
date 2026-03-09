# qtadmin 开发文档（第二大脑迁移版）

## 1. 文档目的

本开发文档用于把以下三层内容转成工程执行计划：

- `docs/default`：新想法与草案
- `docs/meta`：项目级方向与阶段判断
- `docs/prd`：可交付需求与 MVP 边界

当前统一目标：将 qtadmin 从“计算系统”迁移为 QuantTide 的第二大脑平台。

## 2. 当前代码现实

仓库现状（2026-03-10）：

- 后端主实现：`src/provider/app`（FastAPI + SQLModel）
- 后端历史并存：`src/provider/qtadmin_provider`
- 客户端骨架：`src/studio`（Flutter）

已有能力：

- 员工与薪资相关 API 与服务
- 基础测试框架与部分测试用例

关键差距：

- 缺少统一知识对象模型（Document/Task/Decision/Entity/Relation）
- 缺少“输入 -> 整理 -> 输出 -> 回流”的工作闭环
- 缺少平台级审计与智能体操作边界

## 3. 开发原则

1. 兼容旧能力：不推倒重来，薪资模块保留并模块化
2. 先平台后领域：先补知识中枢，再扩展业务模块
3. 小步快跑：每个阶段都可验收、可回滚
4. 文档驱动：架构变更必须同步更新 `meta + prd + dev`

## 4. 目标架构（工程视角）

### 4.1 平台层

- Knowledge Work API：统一入口
- Knowledge Object API：对象与关系模型
- Audit API：关键操作可追溯
- IAM API：人类/智能体最小可控授权

### 4.2 领域层

- Salaries（历史能力）
- Transactions / Projects / Assets（按 PRD 逐步接入）

### 4.3 交互层

- Studio（Flutter）作为统一工作台
- CLI 作为外置程序性记忆入口

## 5. 里程碑计划（对应 PRD MVP）

### M1：统一对象模型与入口

目标：

- 建立第一版对象模型：`Document`、`Task`、`Decision`、`Entity`、`Relation`
- 提供最小 CRUD 与关系查询 API
- 提供统一输入入口（可先在后端 API 实现）

建议目录：

```
src/provider/app/
├── models/
│   ├── knowledge_document.py
│   ├── knowledge_task.py
│   ├── knowledge_decision.py
│   ├── knowledge_entity.py
│   └── knowledge_relation.py
├── api/v1/
│   ├── knowledge.py
│   └── work.py
└── services/
    └── knowledge_service.py
```

验收：

1. 可创建对象并建立关系
2. 可按对象与关系维度查询
3. API 文档可用于前端联调

### M2：闭环与审计最小化

目标：

- 打通“输入 -> 整理 -> 输出 -> 回流”
- 为关键写操作记录审计日志
- 区分人类与智能体操作来源

建议新增：

```
src/provider/app/
├── models/audit_log.py
├── api/v1/audit.py
└── services/audit_service.py
```

验收：

1. 一次完整知识工作可闭环
2. 关键变更可追溯“谁在何时做了什么”
3. 提供最小审计查询接口

### M3：旧模块接入与边界收敛

目标：

- 将薪资模块作为“领域插件”接入对象模型
- 明确单一后端入口，收敛历史双轨
- 提供端到端示例流程（至少一条）

验收：

1. 薪资记录可关联到知识对象
2. 后端入口与包边界清晰
3. 关键端到端流程有自动化测试

## 6. 代码组织建议

### 6.1 后端入口收敛

- 保持 `src/provider/app` 为主服务入口
- 将 `qtadmin_provider` 中可复用逻辑迁移到 `app/services`
- 避免新增并行入口

### 6.2 API 分组建议

```
/api/v1/work
/api/v1/knowledge
/api/v1/entities
/api/v1/relations
/api/v1/audit
/api/v1/iam
/api/v1/salary   # 旧能力保留
```

### 6.3 测试分层建议

- `tests/test_api/`：接口行为
- `tests/test_services/`：业务逻辑
- `integrated_tests/`：端到端闭环

新增功能至少包含：

1. 正常路径测试
2. 权限/边界测试
3. 审计记录测试

## 7. 版本与发布建议

阶段版本可按迁移节奏标记：

- `0.3.x`：方向切换与 PRD 基线建立（进行中）
- `0.4.x`：M1 对象模型上线
- `0.5.x`：M2 闭环与审计上线
- `0.6.x`：M3 旧模块接入与入口收敛

## 8. 协作规则

1. `default` 中反复出现的稳定主题，必须提炼到 `meta`
2. `meta` 的阶段判断变化，必须更新 `prd`
3. `prd` 的范围变化，必须更新 `dev` 开发计划
4. 实现偏离 `prd` 时，优先补文档再继续开发
