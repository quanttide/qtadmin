# qtadmin 开发计划

## 概述

本文档定义了 qtadmin 项目的整体开发路线图。基于默认工作文档 (`docs/default`) 的设计理念，采用分阶段迭代方式构建智能体管理系统。

---

## 架构分层

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Application)                      │
│  ┌─────────┐ ┌────────────┐ ┌─────────┐ ┌─────────┐        │
│  │ asset   │ │ qtresearch │ │ salaries│ │ tokens  │        │
│  └─────────┘ └────────────┘ └─────────┘ └─────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    智能体层 (Agent)                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  agent + meta - 多智能体协作与自我演化机制           │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                    核心引擎层 (Engine)                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                       │
│  │ think   │ │ knowl   │ │ asset   │                       │
│  │ 思考模式 │ │ 知识工程 │ │ 数字资产 │                       │
│  └─────────┘ └─────────┘ └─────────┘                       │
├─────────────────────────────────────────────────────────────┤
│                    基础设施层 (Infra)                        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                       │
│  │ config  │ │ iam     │ │ cli     │                       │
│  │ 配置管理 │ │ 数字身份 │ │ 命令行   │                       │
│  └─────────┘ └─────────┘ └─────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: 基础设施层 (预计 1-2 周)

### 1.1 配置管理 (`config`)

**目标**: 实现声明式配置 + 环境变量分离

**功能需求**:
- 配置模型定义 (Pydantic/SQLModel)
- 配置加载器 (支持本地/DRR 大脑)
- 环境变量密钥管理
- 配置热重载机制

**文件结构**:
```
src/provider/app/
├── config/
│   ├── __init__.py
│   ├── settings.py      # 配置加载器
│   ├── models.py        # 配置模型定义
│   └── secrets.py       # 密钥管理
```

**API 端点**:
```
GET    /api/v1/config           # 获取配置
PUT    /api/v1/config           # 更新声明式配置
GET    /api/v1/config/secrets   # 密钥状态检查 (不返回实际密钥)
```

---

### 1.2 数字身份 (`iam`)

**目标**: 建立零信任安全体系，支持智能体注册

**功能需求**:
- 用户/智能体身份模型
- JWT/OAuth2 认证
- 权限系统 (RBAC + ABAC)
- AI 行为日志记录
- 安全等级配置

**核心模型**:
```python
class Identity(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str
    type: IdentityType  # HUMAN or AI_AGENT
    created_at: datetime
    
class Permission(SQLModel, table=True):
    id: int = Field(primary_key=True)
    resource: str
    action: str
    identity_id: int
    
class AIBehaviorLog(SQLModel, table=True):
    id: int = Field(primary_key=True)
    agent_id: int
    action: str
    context: dict
    timestamp: datetime
```

**API 端点**:
```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/identities         # 注册智能体
GET    /api/v1/identities         # 列出身份
PUT    /api/v1/identities/{id}    # 更新权限
GET    /api/v1/logs/ai-behavior   # AI 行为日志
```

---

### 1.3 命令行 (`cli`)

**目标**: 实现外置程序性记忆交互

**功能需求**:
- CLI 框架搭建 (typer/click)
- 与 FastAPI 后端对接
- 命令历史/会话管理
- 第二大脑仓库集成

**文件结构**:
```
src/provider/
├── cli/
│   ├── __init__.py
│   ├── main.py          # CLI 入口
│   ├── commands/        # 命令定义
│   └── client.py        # API 客户端
```

**命令示例**:
```bash
qtadmin config get          # 获取配置
qtadmin auth login          # 登录
qtadmin agent list          # 列出智能体
qtadmin think start         # 启动思考模式
qtadmin asset sync          # 同步资产
```

---

## Phase 2: 核心引擎层 (预计 2-3 周)

### 2.1 思考模式 (`think`)

**目标**: 实现大模型默认工作状态

**功能需求**:
- 思考模式状态管理
- 上下文窗口管理
- 思维链记录与可视化
- 思考模式配置 (个人/团队级别)

**核心模型**:
```python
class ThinkingSession(SQLModel, table=True):
    id: int = Field(primary_key=True)
    user_id: int
    started_at: datetime
    context: dict
    chain_of_thought: list[dict]
```

**API 端点**:
```
POST   /api/v1/thinking/sessions      # 创建思考会话
GET    /api/v1/thinking/sessions/{id} # 获取会话详情
GET    /api/v1/thinking/sessions      # 列出会话
PUT    /api/v1/thinking/sessions/{id} # 更新思考状态
```

---

### 2.2 知识工程 (`knowl`)

**目标**: 构建知识发现与蒸馏系统

**功能需求**:
- 知识输入接口 (人机交互)
- 知识存储模型
- 知识蒸馏到规则引擎
- 数据清洗管道

**核心模型**:
```python
class Knowledge(SQLModel, table=True):
    id: int = Field(primary_key=True)
    title: str
    content: str
    source: str
    confidence: float  # 置信度
    distilled: bool    # 是否已蒸馏到规则引擎
    
class KnowledgeRule(SQLModel, table=True):
    id: int = Field(primary_key=True)
    knowledge_id: int
    rule_type: str
    condition: dict
    action: dict
```

**API 端点**:
```
POST   /api/v1/knowledge           # 输入知识
GET    /api/v1/knowledge           # 查询知识
PUT    /api/v1/knowledge/{id}      # 更新知识
POST   /api/v1/knowledge/{id}/distill  # 蒸馏到规则引擎
```

---

### 2.3 数字资产 (`asset`)

**目标**: 零代码工作空间，帮助整理数字资产

**功能需求**:
- 资产管理模型
- 工作空间界面 (低代码组件)
- 资产分类分流入口
- 本地优先存储策略
- GitHub 等外部资产集成

**核心模型**:
```python
class Asset(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str
    type: AssetType  # REPO, DOC, MEDIA, etc.
    location: str    # 本地路径或 URL
    metadata: dict
    workspace_config: dict
    
class Workspace(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str
    assets: list[int]  # 资产 ID 列表
    components: list[dict]  # 低代码组件配置
```

**API 端点**:
```
GET    /api/v1/assets              # 列出资产
POST   /api/v1/assets              # 创建资产
PUT    /api/v1/assets/{id}         # 更新资产
DELETE /api/v1/assets/{id}         # 删除资产
GET    /api/v1/workspaces          # 列出工作空间
POST   /api/v1/workspaces          # 创建工作空间
```

---

## Phase 3: 智能体层 (预计 3-4 周)

### 3.1 智能体系统 (`agent`)

**目标**: 管理 AI 工人/秘书角色

**功能需求**:
- 智能体注册中心
- 智能体上下文边界管理
- 原智能体实现 (生成其他智能体)
- 模块智能体分配 (安全/产品等)
- Multi-agent 协作机制

**核心模型**:
```python
class Agent(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str
    role: str  # 安全、产品、客服等
    capabilities: list[str]
    context_boundary: dict
    parent_id: Optional[int]  # 原智能体 ID
    
class AgentCollaboration(SQLModel, table=True):
    id: int = Field(primary_key=True)
    agents: list[int]
    task: str
    status: str
    result: dict
```

**API 端点**:
```
POST   /api/v1/agents              # 注册智能体
GET    /api/v1/agents              # 列出智能体
GET    /api/v1/agents/{id}         # 获取智能体详情
PUT    /api/v1/agents/{id}         # 更新智能体
POST   /api/v1/agents/{id}/spawn   # 生成子智能体
POST   /api/v1/agents/collaborate  # 启动协作
```

---

### 3.2 元认知 (`meta`)

**目标**: 平台自我演化机制

**功能需求**:
- 功能抽取与重组机制
- 领域层迭代追踪
- 演化规则引擎

**核心模型**:
```python
class Evolution(SQLModel, table=True):
    id: int = Field(primary_key=True)
    source_module: str
    target_module: str
    evolution_type: str  # EXTRACT, MERGE, SPLIT
    timestamp: datetime
    
class DomainIteration(SQLModel, table=True):
    id: int = Field(primary_key=True)
    domain: str
    version: str
    changes: list[dict]
```

**API 端点**:
```
GET    /api/v1/meta/evolutions       # 查看演化历史
POST   /api/v1/meta/evolve           # 触发演化
GET    /api/v1/meta/domains          # 列出领域层
GET    /api/v1/meta/domains/{id}/iterations  # 领域迭代历史
```

---

## Phase 4: 集成与可视化 (预计 2 周)

### 4.1 多智能体可视化

**功能需求**:
- 智能体层级关系图
- 协作流程可视化
- 智能体状态监控

**API 端点**:
```
GET    /api/v1/visualization/agents        # 智能体层级图数据
GET    /api/v1/visualization/collaboration # 协作流程图数据
WS     /api/v1/visualization/stream        # 实时状态流
```

---

### 4.2 安全可视化

**功能需求**:
- AI 行为日志展示
- 权限变更历史
- 安全风险仪表盘

**API 端点**:
```
GET    /api/v1/visualization/security/logs      # 行为日志
GET    /api/v1/visualization/security/permissions # 权限历史
GET    /api/v1/visualization/security/dashboard # 安全仪表盘
```

---

### 4.3 零代码工作空间完善

**功能需求**:
- 资产维护界面
- 拖拽式组件配置
- 标准化代码生成

**API 端点**:
```
GET    /api/v1/workspaces/{id}/components  # 获取组件列表
PUT    /api/v1/workspaces/{id}/components  # 更新组件配置
POST   /api/v1/workspaces/{id}/generate    # 生成代码
```

---

## 现有业务模块整合

### 量潮科研服务 (`qtresearch`)

**阶段整合**:
- **Phase 1**: 集成 iam 认证，记录项目操作日志
- **Phase 2**: 集成 think 思考模式，记录项目决策链
- **Phase 3**: 为项目配备专属智能体 (项目经理、安全审查)

**API 端点扩展**:
```
POST   /api/v1/projects                  # 创建项目 (集成 agent 自动配置)
GET    /api/v1/projects/{id}/thinking    # 获取项目思考链
```

---

### 工资系统 (`salaries`)

**阶段整合**:
- **Phase 1**: 集成 iam 权限，保护薪资数据
- **Phase 2**: 集成 knowl 知识工程，记录薪资规则
- **Phase 3**: 配备薪资核算智能体

**API 端点扩展**:
```
GET    /api/v1/salaries/calculate        # 计算薪资 (agent 执行)
POST   /api/v1/salaries/rules            # 更新薪资规则 (knowl 蒸馏)
```

---

### 代币系统 (`tokens`)

**阶段整合**:
- **Phase 1**: 集成 iam 身份，代币与身份绑定
- **Phase 3**: 配备代币管理智能体

---

### 数字资产 (`assets`)

**阶段整合**:
- **Phase 2**: 作为核心引擎层 asset 模块的具体实现
- **Phase 3**: 配备资产整理智能体

---

## 开发优先级矩阵

| 优先级 | 模块 | 依赖 | 预计工时 | 风险等级 |
|--------|------|------|----------|----------|
| P0 | config | 无 | 3 天 | 低 |
| P0 | iam | config | 5 天 | 中 |
| P1 | cli | config, iam | 3 天 | 低 |
| P1 | think | iam | 4 天 | 中 |
| P2 | knowl | think | 5 天 | 中 |
| P2 | asset | think | 5 天 | 中 |
| P3 | agent | config, iam, think | 10 天 | 高 |
| P3 | meta | agent | 5 天 | 高 |
| P4 | 可视化 | 全部 | 5 天 | 低 |

---

## 待确定事项

以下事项需要在开发前明确：

### 1. 默认智能体配置
- **选项 A**: 每人一个智能体
- **选项 B**: 团队共享 + 配置文件隔离
- **建议**: 先实现选项 A，后续支持选项 B

### 2. 思考模式范围
- **问题**: 是否支持公司级别的思考模式配置？
- **建议**: 支持个人 + 团队 + 公司三级配置

### 3. 密钥管理方案
- **选项 A**: 环境变量 + 加密文件
- **选项 B**: HashiCorp Vault
- **选项 C**: 云服务商 Secrets Manager
- **建议**: 先实现选项 A，后续支持 B/C

### 4. 第二大脑仓库
- **问题**: 具体的存储方案和技术栈？
- **建议**: 使用 Git 仓库 + SQLite/PostgreSQL

---

## 里程碑

| 里程碑 | 阶段 | 预计完成时间 | 交付物 |
|--------|------|--------------|--------|
| M1 | Phase 1 完成 | Week 2 | 配置管理、身份认证、CLI 可用 |
| M2 | Phase 2 完成 | Week 5 | 思考模式、知识工程、数字资产可用 |
| M3 | Phase 3 完成 | Week 9 | 智能体系统、元认知可用 |
| M4 | Phase 4 完成 | Week 11 | 可视化界面、零代码工作空间完善 |

---

## 下一步行动

1. **立即可开始**: Phase 1.1 配置管理模块
2. **并行准备**: 设计 iam 数据模型，准备 JWT 认证方案
3. **文档完善**: 为每个模块编写详细的 API 文档

---

## 参考文档

- [默认工作文档](../default/README.md)
- [Provider 开发者文档](provider/README.md)
- [AGENTS.md](../../AGENTS.md)