# feishu-integration

飞书邮件分类 + HR 确认 CLI 工具。通过 `lark-cli` 读取飞书收件箱，自动分类到 Pipeline 各阶段，推送到服务端待 HR 确认。

## 工作流

```
飞书邮箱 → ① lark-cli 拉取 → ② 自动分类 → ③ POST /ingest → ④ 服务端待确认队列 → ⑤ HR 确认 → Pipeline 写入
```

- **① 邮件拉取**：通过 `lark-cli` 读取收件箱邮件（`lark login` 处理 OAuth，不含飞书 API 凭证管理）
- **② 自动分类**：基于关键字/主题分析，输出建议状态 + 置信度
- **③ 推送**：通过 HTTP POST 推送到服务端 `/ingest`，进入待确认队列
- **④ HR 确认**：HR 在服务端面板（或 Flutter 看板）中确认/调整/忽略
- **⑤ Pipeline 写入**：服务端创建 Candidate + Application

## 双模式

### Demo 模式（默认）

无需 `lark-cli`，使用 10 封内置模拟邮件测试完整流程：

```bash
cd packages/examples/provider
uvicorn app:app --port 8000
```

10 封模拟邮件覆盖：应聘简历、笔试答案、面试感谢信、放弃通知、offer 接受、招聘进度咨询等场景。

### 生产模式

需要本地安装并登录 `lark-cli`：

```bash
pip install lark-cli
lark login                        # 飞书 OAuth 登录
export QTADMIN_MAILBOX="your_mailbox"  # 飞书邮箱地址
```

## 包结构

```
integrations/feishu/
├── src/feishu_integration/
│   ├── __init__.py       # 包入口，公开 API
│   ├── classifier.py     # 规则分类引擎
│   ├── cli.py            # 命令行工具（pull/queue）
│   ├── demo.py           # Demo 模式模拟邮件
│   ├── mail_reader.py    # 邮件拉取 + 分类编排
│   └── pipeline_writer.py# HTTP 客户端写入 Pipeline
├── tests/
│   └── test_classifier.py
├── pyproject.toml
└── README.md
```

## 命令行

```bash
# 列出招聘相关邮件
qtadmin human mail list
qtadmin human mail list --demo

# 预览单封邮件分类结果
qtadmin human mail classify <id>

# 推送到服务端
qtadmin human mail ingest [--batch-id <id>]

# 查看服务端待确认队列
qtadmin human status pending
```

完整的 CLI 文档见独立仓库 `qtadmin-human-cli`。

## 服务端接口

本包不直接提供 API 路由。队列和 Pipeline 接口由 `packages/fastapi` 提供：

| 路由 | 方法 | 说明 |
|------|------|------|
| `POST /ingest` | 接收分类结果入队列 | 服务端 |
| `GET /queue` | 列出队列项 | 服务端 |
| `PATCH /queue/{id}/confirm` | 确认/调整 | 服务端 |
