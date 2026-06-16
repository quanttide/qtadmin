# 人力资源职能

## 1. 项目介绍

人力资源职能（human）是量潮管理后台（QtCloud HR）的核心模块之一，覆盖招聘管道的全流程数字化管理。

### 解决什么问题

- **邮件轰炸**：招聘邮箱每天收到大量简历，人工筛选费时费力 → AI 自动分类+优先级排序
- **流程混乱**：候选人面试进度靠表格追踪，状态不透明 → 可视化管道看板
- **信息孤岛**：邮件往来、面试评价、附件分散各处 → 统一详情面板
- **协作困难**：HR 和业务部门信息不同步 → 实时共享的管道视图

### 核心流程

```
招聘邮件 → AI 分类 → 队列审核 → 入管道 → 面试流转 → 录用/人才池
                                     ↓
                              邮件往来 · 附件管理 · 修正追踪
```

### 适用角色

| 角色 | 使用场景 |
|------|----------|
| HR 专员 | 审核邮件队列、管理候选人管道、发送通知邮件 |
| HR 负责人 | 查看招聘进度、配置 AI 规则、导出数据 |
| 面试官 | 查看候选人材料、评价记录 |
| 管理员 | 配置服务端、管理飞书集成 |

---

## 2. 项目解析

### 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端 UI | Flutter 3.11+ / Dart 3 | 跨平台桌面/Web 看板应用 |
| 后端 | Python 3.12+ / FastAPI | REST API 服务 |
| ORM | SQLAlchemy 2.0 | 数据访问层 |
| 数据库 | SQLite | 本地存储（可切换 PostgreSQL） |
| AI 分类 | OpenAI / 任意 LLM API | 邮件智能分类 |
| 飞书集成 | Feishu Open API | 邮件自动拉取与发送 |
| CLI | Python / Click | 命令行管理工具 |

### 目录结构

```
qtadmin/
├── src/
│   ├── provider/                    # FastAPI 后端
│   │   └── app/
│   │       ├── __main__.py          # 应用入口（uvicorn 启动）
│   │       └── human/
│   │           ├── database.py      # SQLite 连接与会话
│   │           ├── seed.py          # 种子数据（演示用）
│   │           ├── models/          # SQLAlchemy 数据模型
│   │           │   ├── talent.py           # 8 状态候选人状态机
│   │           │   ├── recruitment.py      # 招聘项目
│   │           │   ├── candidate.py        # 候选人
│   │           │   ├── application.py      # 申请（候选人+项目关联）
│   │           │   ├── pending_queue.py    # 待处理邮件队列
│   │           │   ├── mail_message.py     # 邮件往来
│   │           │   ├── correction_log.py   # 人工修正日志
│   │           │   ├── material.py         # 素材附件
│   │           │   ├── ai_config.py        # AI 配置
│   │           │   └── processed_mail.py   # 已处理邮件记录
│   │           ├── schemas/         # Pydantic 请求/响应模型
│   │           ├── routers/         # API 路由
│   │           │   ├── pipeline.py         # 管道视图
│   │           │   ├── queue.py            # 邮件队列
│   │           │   ├── applications.py     # 申请 CRUD
│   │           │   ├── candidates.py       # 候选人 CRUD
│   │           │   ├── recruitments.py     # 招聘项目 CRUD
│   │           │   ├── messages.py         # 邮件往来
│   │           │   ├── ingest.py           # 邮箱导入
│   │           │   ├── ai_config.py        # AI 配置
│   │           │   ├── export.py           # 数据导出
│   │           │   ├── pool.py             # 人才池
│   │           │   └── materials.py        # 素材查询
│   │           └── services/        # 业务逻辑层
│   │               ├── pipeline.py         # 管道聚合
│   │               ├── transition.py       # 状态流转 + 同步
│   │               ├── classifier.py       # 关键词分类
│   │               ├── ai_classifier.py    # LLM 分类
│   │               ├── email_matcher.py    # 邮箱匹配
│   │               ├── pool.py             # 池管理
│   │               ├── resume_parser.py    # 简历解析
│   │               ├── material_service.py # 素材管理
│   │               ├── headcount.py        # 编制规划
│   │               └── export.py           # 导出生成
│   │
│   ├── hr-kanban/                   # Flutter 看板应用
│   │   └── lib/
│   │       ├── main.dart                   # 应用入口 + 导航壳
│   │       ├── theme/hr_theme.dart         # 深色主题 + 状态色
│   │       ├── services/api_service.dart   # API 客户端
│   │       ├── models/                     # Dart 数据模型
│   │       ├── screens/                    # 页面
│   │       │   ├── pipeline_screen.dart    # 管道看板
│   │       │   ├── queue_screen.dart       # 邮件队列
│   │       │   ├── pool_screen.dart        # 人才池
│   │       │   └── settings_screen.dart    # 设置
│   │       └── widgets/                    # 通用组件
│   │
│   └── cli/                          # CLI 命令行工具
│       └── app/human/
│           ├── cli.py               # 命令定义
│           ├── api_client.py        # HTTP 客户端
│           ├── classifier.py        # 本地分类
│           ├── mail_sender.py       # 邮件发送
│           └── lark_client.py       # 飞书 API
│
├── quanttide-hr-toolkit-main/        # HR 工具包（子模块）
│   ├── packages/
│   │   ├── dart/                    # 纯 Dart 领域模型
│   │   ├── fastapi/                 # FastAPI 库代码
│   │   └── flutter/                 # Flutter 库代码
│   └── integrations/feishu/         # 飞书集成
│       └── src/feishu_integration/
│           ├── mail_reader.py       # 邮件读取
│           ├── mail_sender.py       # 邮件发送
│           ├── mail_ingest_loop.py  # 拉取循环
│           ├── mail_sender_loop.py  # 发送循环
│           ├── classifier.py        # 分类器
│           └── pipeline_writer.py   # 管道写回
│
└── CHANGELOG-human.md               # Human 模块更新日志
```

### 数据流

```
1. 邮件进入
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ 飞书邮箱  │───>│ 分类器    │───>│ 待处理队列 │
   │ API 拉取  │    │ AI/规则   │    │ Pending   │
   └──────────┘    └──────────┘    └──────────┘

2. HR 审核
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │ 队列看板  │───>│ 确认/调整 │───>│ 申请创建  │
   │ Queue    │    │ Confirm   │    │Application│
   └──────────┘    └──────────┘    └──────────┘

3. 管道流转
   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
   │ NEW  │──>│EXAM  │──>│EVAL  │──>│OFFER │
   │      │   │SENT  │   │UATING│   │      │
   └──────┘   └──────┘   └──────┘   └──────┘
                    │
                    ▼
               ┌────────┐        ┌────────┐
               │ 人才池  │<───────│ CLOSED │
               │ Pool   │        │        │
               └────────┘        └────────┘
```

### 状态机

候选人沿以下路径流转，每个状态只能跳转到允许的下一个状态：

```
NEW ──→ CONTACTED ──→ EXAM_SENT ──→ EXAM_RECEIVED ──→ EVALUATING ──→ INTERVIEW ──→ OFFER ──→ CLOSED
 │          │             │               │                 │              │          │
 └──→ CLOSED   └──→ CLOSED   └──→ CLOSED     └──→ CLOSED      └──→ CLOSED    └──→ CLOSED └──
                                                                     │
                                                                EXAM_SENT (重评)
```

---

## 3. 启动教程

### 前置条件

| 工具 | 版本要求 | 验证命令 |
|------|----------|----------|
| Python | >= 3.12 | `python --version` |
| Flutter | >= 3.11 | `flutter --version` |
| pip | 最新 | `pip --version` |

### 3.1 启动后端服务

```bash
# 1. 进入后端目录
cd qtadmin/src/provider

# 2. 安装依赖
pip install -r requirements.txt

# 或使用虚拟环境
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows
pip install -r requirements.txt

# 3. 初始化数据库 + 启动服务
python -m app

# 服务运行在 http://localhost:8080
```

> 数据库文件 `hr.db` 自动创建在当前目录。首次启动时，如果数据库为空会自动填充演示数据。

**验证启动成功**：
```bash
curl http://localhost:8080/health
# 返回: {"status":"ok"}
```

打开浏览器访问 `http://localhost:8080/docs` 查看 Swagger API 文档。

### 3.2 启动 Flutter 看板

```bash
# 1. 进入看板目录
cd qtadmin/src/hr-kanban

# 2. 安装依赖
flutter pub get

# 3. 启动（默认打开 Chrome 浏览器）
flutter run -d chrome
```

看板启动后，在 **设置** 页面将服务端地址修改为 `http://localhost:8080`，点击保存即可连接。

> 也可编译为桌面应用：`flutter run -d linux` / `flutter run -d macos` / `flutter run -d windows`

### 3.3 使用演示数据

后端首次启动时自动调用 `seed_data()` 填充演示数据，包含：

- 1 个招聘项目
- 10+ 候选人在不同流转阶段
- 10 条待处理邮件队列
- 部分候选人有邮件往来记录

如果数据库被清空，重启服务会自动重新填充种子数据。

### 3.4 CLI 命令行工具

```bash
# 进入 CLI 目录
cd qtadmin/src/cli

# 查看可用命令
python -m qtadmin --help

# 管理队列
python -m qtadmin human queue list
python -m qtadmin human queue confirm <queue_id> --recruitment "高级后端工程师"
python -m qtadmin human queue ignore <queue_id>
```

### 3.5 配置 AI 分类（可选）

在看板 **设置** 页面或通过 API 配置：

```json
{
  "provider": "openai",
  "model": "gpt-4o-mini",
  "api_key": "sk-xxx",
  "base_url": "https://api.openai.com/v1",
  "temperature": 0.3,
  "prompt_template": "请根据邮件内容判断候选人适合的阶段：new/contacted/exam_sent/exam_received/evaluating/interview/offer/closed"
}
```

配置后可通过 **连接测试** 按钮验证。

### 3.6 飞书邮件集成（可选）

```bash
# 设置飞书邮箱
export QTADMIN_MAILBOX="user@feishu.cn"

# 启动后端（自动开始轮询邮箱）
python -m app
```

服务端启动时会自动创建后台任务，每 5 分钟拉取一次飞书邮箱，新邮件自动进入待处理队列。

---

## 4. 看板功能

### 4.1 管道（Pipeline）

招聘管道看板，按候选人状态分组展示：

- **状态分组**: 8 列，从 NEW 到 CLOSED
- **停留天数**: 每个卡片底部显示停留天数，超 7 天黄色，超 14 天橙色
- **搜索**: 按姓名或邮箱实时过滤
- **拖拽流转**: 拖拽卡片到目标状态列完成状态变更
- **详情面板**: 点击卡片弹出底部面板，查看完整信息

### 4.2 队列（Queue）

待处理邮件队列：

- **邮件列表**: 所有未处理招聘邮件，按时间倒序
- **置信度标签**: high(绿) / medium(黄) / low(灰)
- **操作**: 确认（创建候选人）、调整（修改状态后确认）、忽略

### 4.3 人才池（Pool）

备选候选人池：

- **筛选**: 按招聘项目过滤
- **详情**: 查看候选人完整信息
- **重新入池**: 移出池并分配到新的招聘项目

### 4.4 设置（Settings）

- AI 配置表单（供应商/模型/密钥/地址/温度/提示词）
- 服务端地址切换（运行时修改，即时生效）
- 连接测试按钮

---

## 5. API 端点参考

### 招聘项目

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/recruitments` | 列表所有招聘项目 |
| POST | `/recruitments` | 创建招聘项目 |
| GET | `/recruitments/{id}` | 获取单个项目详情 |
| POST | `/recruitments/{id}/talents` | 手动登记候选人 |
| PATCH | `/recruitments/{id}/talents/{tid}` | 更新候选人信息 |
| POST | `/recruitments/{id}/talents/{tid}/transition` | 流转候选人状态 |

### 管道

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/pipeline` | 获取聚合管道视图 |

### 队列

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/queue` | 列表待处理邮件队列 |
| POST | `/queue/{id}/confirm` | 确认并创建候选人 |
| POST | `/queue/{id}/ignore` | 忽略该邮件 |

### 申请

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/applications` | 列表申请 |
| POST | `/applications/{id}/transition` | 流转申请状态 |
| POST | `/applications/{id}/pool` | 归入人才池 |
| POST | `/applications/{id}/unpool` | 从人才池移出 |
| GET | `/applications/{id}/materials` | 获取申请材料 |

### 候选人

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/candidates` | 列表候选人 |
| GET | `/candidates/{id}` | 候选人详情 |
| PATCH | `/candidates/{id}` | 更新候选人信息 |

### 消息

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/candidates/{id}/messages` | 获取候选人邮件往来 |
| GET | `/candidates/{id}/timeline` | 获取候选人时间线 |
| POST | `/candidates/{id}/reply` | 回复候选人 |
| GET | `/messages/outbox` | 待发邮件列表 |
| GET | `/messages/outbox/dead` | 死信队列 |
| POST | `/messages/outbox/{id}/requeue` | 重新入队死信 |

### 其他

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/ingest` | 批量导入邮件 |
| GET | `/ai-config` | 获取 AI 配置 |
| PUT | `/ai-config` | 更新 AI 配置 |
| POST | `/ai-config/test` | 测试 AI 连接 |
| GET | `/export/talents` | 导出人才数据 |

---

## 6. CLI 工具

```bash
# 查看帮助
python -m qtadmin --help

# 导入招聘邮箱
python -m qtadmin human import data/emails.json

# 管理队列
python -m qtadmin human queue list
python -m qtadmin human queue confirm <id> -r "招聘项目名"
python -m qtadmin human queue ignore <id>
```

---

## 7. 飞书集成

详见 `quanttide-hr-toolkit-main/integrations/feishu/`。

```bash
# 环境变量配置
export FEISHU_APP_ID="cli_xxx"
export FEISHU_APP_SECRET="xxx"
export QTADMIN_MAILBOX="hr@company.feishu.cn"

# 启动后端（自动启用邮件轮询）
python -m app
```
