# 招聘邮箱导入程序设计

## 问题

人力资源团队使用招聘专用邮箱（如 `zhaopin@quanttide.com`）接收简历投递、面试安排、录用沟通等邮件。目前这些邮件散落在邮箱中，没有结构化的候选人数据管理。

`docs/user-guide/human.md` 中有占位命令 `qtadmin human xxxxx`，描述为"使用 lark-cli 获取招聘邮箱数据并提交到服务端"，但无实现。

## 设计目标

- 将招聘邮件从邮箱中导入为结构化候选人数据
- 自动分类邮件类型（简历投递 / 面试邀请 / 录用通知 / 拒信）
- 提取候选人关键信息（姓名、岗位、联系方式）
- 支持增量导入和持续监控
- 与 provider API 对接持久化数据

## 整体架构

```
┌──────────────┐    subprocess     ┌──────────────────┐    HTTP    ┌──────────────┐
│   lark-cli    │ ◄──────────────► │  qtadmin human    │ ────────► │    Provider   │
│  (mail API)   │                  │  import-email     │           │   (FastAPI)   │
│              │                  │                  │           │              │
│  +triage     │ ──邮件列表────── │  1. fetch        │           │  POST /hr/   │
│  +message    │ ──邮件详情────── │  2. classify     │           │  candidates  │
│  attachments │ ──附件下载────── │  3. extract      │           │  POST /hr/   │
│              │                  │  4. submit       │           │  emails      │
└──────────────┘                  └──────────────────┘           └──────┬───────┘
                                                                       │
                                                                       ▼
                                                                ┌──────────────┐
                                                                │  PostgreSQL   │
                                                                │  (via SQLite  │
                                                                │   for dev)    │
                                                                └──────────────┘
```

### 分层职责

| 层 | 职责 | 技术 |
|---|---|---|
| **Connector** | 通过 lark-cli 访问招聘邮箱 | CLI subprocess 调用 `lark-cli mail` |
| **Pipeline** | 获取 → 分类 → 提取 → 提交 | Typer 命令编排 |
| **Provider** | 持久化候选人数据 | FastAPI + SQLAlchemy |
| **Storage** | 数据存储 | PostgreSQL（生产）/ SQLite（开发） |

## CLI 设计

### 命令树

```
qtadmin human
├── connect           测试邮箱连接
├── import-email      全量导入（fetch + classify + extract + submit）
│   ├── --mailbox    指定邮箱地址（默认配置文件中的招聘邮箱）
│   ├── --days       导入近 N 天的邮件（默认 30）
│   ├── --limit      最大导入数
│   ├── --dry-run    预览模式，不提交
│   ├── --since      指定起始日期
│   └── --watch      持续监控模式
├── emails list        查看已导入的邮件
├── candidates list    查看已提取的候选人
└── classify           手动分类单封邮件
```

### import-email 流程

```
import-email
  │
  ├── 1. fetch ── lark-cli mail +triage → 获取未处理的邮件列表
  │     └── 过滤：排除已导入的（按 message_id 去重）
  │
  ├── 2. read ── lark-cli mail +message → 逐封读取详情
  │     └── 含正文、发件人、收件人、主题、附件元数据
  │
  ├── 3. classify ── 规则分类
  │     ├── resume      简历投递 — 含附件简历
  │     ├── interview   面试邀请 — 主题含"面试"/"interview"
  │     ├── offer       录用通知 — 主题含"offer"/"录用"
  │     ├── rejection   拒信 — 主题含"感谢"/"unfortunately"
  │     └── other       其他
  │
  ├── 4. extract ── 从邮件中提取结构化信息
  │     ├── candidateName  候选人姓名（从正文/签名/附件推断）
  │     ├── position       应聘岗位（从主题/正文提取）
  │     ├── email          发件人邮箱
  │     ├── phone          联系方式（从正文正则匹配）
  │     ├── attachments    附件列表（简历文件）
  │     └── summary        邮件摘要
  │
  ├── 5. download ── lark-cli mail attachments → 下载附件简历
  │
  ├── 6. submit ── POST 到 provider API
  │     ├── POST /hr/emails         保存邮件记录
  │     └── POST /hr/candidates     保存候选人（如已分类为 resume）
  │
  └── 7. report ── 打印导入结果汇总
```

### 设计原则（来自 clig.dev）

- **默认存草稿，确认后发送**：`--dry-run` 预览变更，不加则询问确认
- **输出示例**：每次运行打印汇总表
- **退出码**：成功 0，部分失败 1，完全失败 2
- **标准 flag 名**：`--dry-run`, `--limit`, `--since` 等

## Provider API 设计

### 数据模型

```python
# Candidate
candidate:
  id: UUID
  name: str                    # 候选人姓名
  email: str                   # 发件人邮箱
  phone: str?                  # 联系方式
  position: str?               # 应聘岗位
  source: str                  # 来源渠道 ("email")
  source_email_id: UUID        # 关联邮件
  resume_file_url: str?        # 简历文件地址
  status: str                  # new / contacted / interviewed / offered / hired / rejected
  created_at: datetime
  updated_at: datetime

# RecruitmentEmail
email:
  id: UUID
  message_id: str              # lark-cli message_id（去重依据）
  mailbox: str                 # 邮箱地址
  subject: str
  sender_name: str
  sender_email: str
  received_at: datetime
  category: str                # resume / interview / offer / rejection / other
  body_text: str?              # 纯文本正文
  has_attachments: bool
  attachment_metadata: json?   # 附件列表 [{name, size, type}]
  is_imported: bool
  imported_at: datetime?

# ImportLog
import_log:
  id: UUID
  run_at: datetime
  total_emails: int
  imported_count: int
  skipped_count: int
  failed_count: int
  errors: json?
```

### 端点

```python
POST /api/v1/hr/emails          # 批量提交导入的邮件
POST /api/v1/hr/candidates      # 创建候选人（从简历邮件提取）
GET  /api/v1/hr/candidates      # 候选人列表（支持筛选）
GET  /api/v1/hr/candidates/:id  # 候选人详情
PATCH /api/v1/hr/candidates/:id # 更新候选人状态
GET  /api/v1/hr/import-logs     # 导入历史
```

## 数据分类规则

邮件分类使用关键词规则，初始版本无需 ML：

| 类别 | 判定条件 | 优先级 |
|---|---|---|
| **resume** | 有附件（.pdf/.doc/.docx）且主题/正文含"简历"/"应聘"/"求职"/"application" | 最高 |
| **offer** | 主题含"offer"/"录用"/"入职通知" | 高 |
| **interview** | 主题含"面试"/"interview"/"邀约" | 高 |
| **rejection** | 主题含"感谢投递"/"unfortunately"/"不合适" | 中 |
| **other** | 默认 | 最低 |

## 分阶段实施

### Phase 1 — CLI 获取+本地保存

- 实现 `qtadmin human import-email --dry-run`，将邮件数据保存到本地 JSON 文件
- 不依赖 provider，不依赖数据库
- 可手动审核分类结果

### Phase 2 — Provider API + 数据库

- 在 provider 中添加 SQLAlchemy + SQLite
- 实现数据模型和 CRUD 端点
- CLI 加上 `--submit` 模式，对接 provider API

### Phase 3 — 简历解析

- 集成简历解析（python-resume-parser 或类似库）
- 从 PDF/DOCX 中提取结构化简历信息
- 与候选人数据合并

### Phase 4 — 持续监控

- 实现 `--watch` 模式，使用 lark-cli mail +watch 实时监听新邮件
- 新邮件到达自动触发导入
- 可选：发送飞书 IM 通知给 HR

## 设计取舍

| 取舍 | 选择 | 代价 |
|---|---|---|
| CLI 调用 lark-cli vs 直接使用 Lark OAPI SDK | CLI subprocess 调用 lark-cli | 多一层进程开销，依赖本地安装 lark-cli |
| 规则分类 vs ML 分类 | 初始用规则，预留 ML 接口 | 泛化能力有限，需持续维护规则 |
| JSON 文件中间态 vs 直写数据库 | Phase 1 先落文件，Phase 2 再落库 | Phase 1→2 需做数据迁移 |
| SQLite vs PostgreSQL | 开发用 SQLite，生产用 PostgreSQL（SQLAlchemy 抽象） | 需注意方言差异 |

## 不解决的问题

- **简历解析的准确性**：Phase 3 评估后决定是否引入 ML 模型
- **多邮箱聚合**：当前只支持单招聘邮箱，多邮箱需后续扩展
- **候选人去重**：同一候选人多次投递的去重策略需后续定义
- **与现有 HR 系统对接**：不替换现有 HR 系统，数据由 HR 团队确认后手动导出
