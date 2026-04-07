# Default 模块：知识工作技术设计

基于 PRD [default.md](../../prd/default.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

知识工作模块采用前后端分离架构：

- **前端**：Flutter studio 客户端
- **后端**：FastAPI provider
- **存储**：本地文件系统 + OSS（可选）

### 1.2 Default 模式实现

轻量入口，无需 formal 流程：

```
用户输入 → 快速存储 → AI 辅助整理 → 索引构建
```

核心组件：
- 输入捕获器：支持文本、图片、网页等多种格式
- 快速存储层：SQLite 本地存储，3 秒内响应
- AI 整理引擎：自动分类、摘要、标签
- 索引服务：全文检索、标签过滤

### 1.3 Work 模式实现

君臣共治的双智能体架构：

```
用户 → 协议定义 → 创造者 + 观察者 → 人类裁决 → 最终交付
```

核心组件：
- 协议管理器：定义任务目标、输出格式、质量标准
- 创造者 Agent：基于 OpenClaw，负责快速产出
- 观察者 Agent：基于 OpenCode，负责质量检查
- 裁决接口：人类介入争议决策点
- 案卷生成器：输出终版成果、合规报告、审判记录

## 2. 数据结构

### 2.1 碎片记录（Default 模式）

```python
class Fragment(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    type: str  # text/image/web/screenshot
    content: str
    tags: list[str] = Field(default_factory=list)
    created_at: datetime
    source: Optional[str]  # 来源信息
```

### 2.2 工作协议（Work 模式）

```python
class WorkProtocol(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    task: str  # 任务描述
    output_format: str  # markdown/json/text
    requirements: list[str]  # 必须包含的要素
    quality_criteria: dict  # 质量标准
    checklist: list[str]  # 检查项列表
    status: str  # drafting/active/completed
```

### 2.3 工作记录（Work 模式）

```python
class WorkSession(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    protocol_id: int
    creator_output: str  # 创造者输出
    observer_report: str  # 观察者报告
    human_decisions: list[dict]  # 人类裁决记录
    final_output: str  # 最终成果
    created_at: datetime
```

## 3. API 设计

### 3.1 Default 模式 API

```
POST /fragments          # 创建碎片记录
GET  /fragments          # 查询碎片列表
GET  /fragments/{id}     # 获取单个碎片
POST /fragments/search   # 搜索碎片
POST /fragments/{id}/organize  # AI 整理
```

### 3.2 Work 模式 API

```
POST /protocols          # 创建工作协议
GET  /protocols/{id}     # 获取协议详情
POST /work-sessions      # 创建工作会话
GET  /work-sessions/{id} # 获取工作进度
POST /work-sessions/{id}/decide  # 人类裁决
GET  /work-sessions/{id}/dossier # 获取案卷
```

## 4. Meta 模块实现

### 4.1 经验回放系统

基于 OpenClaw ContextEngine 插件接口：

```python
class MetaModule:
    def __init__(self, openclaw_client):
        self.listener = EventListener(openclaw_client)
        self.reflector = ReflectionExecutor()
        self.injector = MemoryInjector()
    
    def on_session_end(self, session_result, user_feedback):
        # 监听事件
        if self.listener.detect_error(session_result):
            # 异步反思
            experience = self.reflector.analyze(session_result)
            # 注入记忆
            self.injector.save(experience)
    
    def on_session_start(self, user_query):
        # 检索相关经验
        relevant_experiences = self.injector.retrieve(user_query)
        # 注入系统提示词
        return self.injector.enrich_prompt(relevant_experiences)
```

### 4.2 存储方案

- **短期记忆**：SQLite（当前会话上下文）
- **长期记忆**：向量数据库（经验教训）
- **注入方式**：系统提示词前缀文件追加

## 5. 技术栈

| 组件 | 技术选型 |
|------|----------|
| 后端框架 | FastAPI + SQLModel |
| 前端框架 | Flutter |
| Agent 框架 | OpenClaw（创造者） + OpenCode（观察者） |
| 本地存储 | SQLite |
| 向量数据库 | 待定（可选 Chroma、Qdrant） |
| OSS | 阿里云 OSS（可选） |

## 6. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | Default 模式基础（记录、检索） | P0 |
| M2 | Work 模式双智能体 | P1 |
| M3 | Meta 模块经验回放 | P2 |
| M4 | 个人/团队场景扩展 | P2 |