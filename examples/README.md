# 示例目录

| 示例 | 技术栈 | 成熟度 | 说明 |
|------|--------|--------|------|
| [auth](auth/) | Rust (axum+sqlx+sqlite) | 完成 | 身份认证 CRUD API + 权限体系，编译通过，Port 3000 |
| [org](org/) | Rust (axum+sqlx+sqlite) | 完成 | 组织架构 positions CRUD API，编译通过，Port 3001 |
| [business](business/) | Python | 完成 | 商务拓展成熟度实验，Assets→Data→Code→Docs 全管线，8 测试通过 |
| [knowl](knowl/) | Python (DeepSeek API) | 完成 | 知识工程实验室，LLM 从原始文档提取结构化知识，已验证输出 |
| [default](default/) | Python (jieba) | 完成 | 日志文本分析工具，日记 NLP（词频/趋势/突发词/共现/情感），含 PRD 和两份分析报告 |
| [delib](delib/) | Markdown | 概念 | 两院制议事机制设计文档，无代码实现 |

## 成熟度定义

| 等级 | 含义 |
|------|------|
| 完成 | 有可运行代码，核心功能已验证 |
| 进行中 | 有部分实现，待完善 |
| 概念 | 仅设计文档，无代码实现 |
