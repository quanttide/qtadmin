# qtadmin 开发文档（第二大脑迁移版）

## 1. 文档目的

本开发文档用于把以下三层内容转成工程执行计划：

- `docs/default`：新想法与草案
- `docs/meta`：项目级方向与阶段判断
- `docs/prd`：可交付需求与 MVP 边界

当前统一目标：将 qtadmin 从"计算系统"迁移为 QuantTide 的第二大脑平台。

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
- 缺少"输入 -> 整理 -> 输出 -> 回流"的工作闭环
- 缺少平台级审计与智能体操作边界
- 缺少 Default/Work 双模式支持

## 3. 开发原则

1. 兼容旧能力：不推倒重来，薪资模块保留并模块化
2. 先平台后领域：先补知识中枢，再扩展业务模块
3. 小步快跑：每个阶段都可验收、可回滚
4. 文档驱动：架构变更必须同步更新 `meta + prd + dev`
5. 模式优先：Default 模式优先实现基础能力，Work 模式后置

## 4. 目标架构（工程视角）

### 4.1 平台层

- **Work API**：统一入口（Default + Work 双模式）
- **Knowledge Object API**：对象与关系模型
- **Audit API**：关键操作可追溯
- **IAM API**：人类/智能体最小可控授权

### 4.2 模块优先级（按 PRD）

1. **Work**（统一入口）- Default + Work 双模式
2. **Knowledge**（对象与关系）
3. **IAM + Audit**（安全与追溯）
4. **Agent**（多智能体协作）
5. **Meta**（平台元认知）
6. **Asset / CLI / Config**（工具与基础设施）

### 4.3 领域层

- Salaries（历史能力）
- Transactions / Projects / Assets（按 PRD 逐步接入）

### 4.4 交互层

- Studio（Flutter）作为统一工作台
- CLI 作为外置程序性记忆入口

## 5. 模块开发计划

### 5.1 Work 模块（默认模块）

#### Default 模式（MVP）

目标：实现无需 formal 工作流程的基础能力

核心能力：
- 收藏（Clip）：快速保存网页、文本、图片、截图
- 记录（Note）：快速记录想法、灵感
- 检索（Search）：跨笔记、跨时间检索
- 整理（Organize）：标签管理、AI 辅助分类
- 提醒（Reminder）：设置提醒、待办
- 通信（Message）：简单沟通

建议目录：
```
src/provider/app/
├── models/
│   ├── clip.py
│   ├── note.py
│   └── tag.py
├── api/v1/
│   └── default.py   # Default 模式入口
└── services/
    └── default_service.py
```

#### Work 模式

目标：实现"君臣共治"的 formal 工作模式

核心机制：
- **双智能体**：创造者（System1）+ 观察者（System2）
- **协议先行**：工作前约定交付物与检查项
- **人类裁决**：AI 分歧时由人裁决

建议目录：
```
src/provider/app/
├── models/
│   ├── protocol.py
│   ├── deliverable.py
│   └── judgment.py
├── api/v1/
│   └── work.py
└── services/
    ├── creator_service.py
    └── observer_service.py
```

### 5.2 Knowledge 模块

目标：建立知识对象与关系模型

核心模型：
- Document（文档）
- Task（任务）
- Decision（决策）
- Entity（实体）
- Relation（关系）

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
│   └── knowledge.py
└── services/
    └── knowledge_service.py
```

### 5.3 IAM + Audit 模块

目标：区分人类与智能体权限，关键操作可追溯

建议目录：
```
src/provider/app/
├── models/
│   ├── audit_log.py
│   └── identity.py
├── api/v1/
│   ├── audit.py
│   └── iam.py
└── services/
    ├── audit_service.py
    └── iam_service.py
```

### 5.4 Agent 模块

目标：管理多智能体协作

建议目录：
```
src/provider/app/
├── models/
│   └── agent.py
├── api/v1/
│   └── agent.py
└── services/
    └── agent_service.py
```

### 5.5 Meta 模块

目标：平台自监控与演化

建议目录：
```
src/provider/app/
├── models/
│   └── metrics.py
├── api/v1/
│   └── meta.py
└── services/
    └── meta_service.py
```

## 6. 里程碑计划（对应 PRD MVP）

### M1：统一对象模型与入口

目标：

- 建立第一版对象模型：`Document`、`Task`、`Decision`、`Entity`、`Relation`
- 提供最小 CRUD 与关系查询 API
- 提供统一输入入口（Default 模式基础能力）

验收：

1. 可创建对象并建立关系
2. 可按对象与关系维度查询
3. Default 模式可完成收藏、记录、检索

### M2：闭环与审计最小化

目标：

- 打通"输入 -> 整理 -> 输出 -> 回流"
- 为关键写操作记录审计日志
- 区分人类与智能体操作来源

验收：

1. 一次完整知识工作可闭环
2. 关键变更可追溯"谁在何时做了什么"
3. 提供最小审计查询接口

### M3：Work 模式与旧模块接入

目标：

- 实现 Work 模式（君臣共治机制）
- 将薪资模块作为"领域插件"接入对象模型
- 明确单一后端入口，收敛历史双轨

验收：

1. Work 模式可完成 formal 工作流程
2. 薪资记录可关联到知识对象
3. 后端入口与包边界清晰

## 7. API 分组建议

```
/api/v1/work/default     # Default 模式
/api/v1/work             # Work 模式
/api/v1/knowledge        # 知识对象
/api/v1/relations        # 关系查询
/api/v1/audit            # 审计日志
/api/v1/iam              # 身份与权限
/api/v1/agent            # 智能体管理
/api/v1/meta             # 平台元认知
/api/v1/salary           # 旧能力保留
```

## 8. 测试分层建议

- `tests/test_api/`：接口行为
- `tests/test_services/`：业务逻辑
- `integrated_tests/`：端到端闭环

新增功能至少包含：

1. 正常路径测试
2. 权限/边界测试
3. 审计记录测试
4. Default/Work 模式切换测试

## 9. 版本与发布建议

阶段版本可按迁移节奏标记：

- `0.3.x`：方向切换与 PRD 基线建立（进行中）
- `0.4.x`：M1 对象模型 + Default 模式上线
- `0.5.x`：M2 闭环与审计上线
- `0.6.x`：M3 Work 模式 + 旧模块接入

## 10. 协作规则

1. `default` 中反复出现的稳定主题，必须提炼到 `meta`
2. 文档流转遵循：`default -> other docs -> meta`
3. `prd` 的范围变化，必须更新 `dev` 开发计划
4. 实现偏离 `prd` 时，优先补文档再继续开发
