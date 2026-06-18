# ROADMAP

## 定位

Provider 是 qtadmin 的后端 API 服务。它处于 CLI 和 Studio 之下，提供统一的数据持久化、业务逻辑和外部系统集成能力。

| 组件 | 角色 | 与 Provider 关系 |
|:-----|:-----|:-----------------|
| CLI | 命令行接口 | 当前直接操作本地文件，未来可调用 Provider API |
| Studio | Flutter 客户端 | 通过 HTTP 调用 Provider 获取和写入数据 |
| Provider | 后端 API | 对接数据库和外部服务（飞书、企业微信等） |

## 版本策略

- `v0.0.x` — 探索验证期，逐步补齐各域 API
- `v0.1.0` — 首个稳定版本，覆盖 CLI v0.1.0 和 Studio 主要域的 API 需求

版本号与主仓库同步（见 `AGENTS.md` 版本约定）。

## v0.0.1 — 骨架搭建

- [x] Go 项目初始化（`cmd/server/main.go` + `internal/` 分层）
- [x] `GET /health` 健康检查端点
- [x] `ADDR` 环境变量支持端口配置

## v0.0.2 — 基础设施

- [ ] 配置管理：YAML/环境变量加载（`internal/config/`）
- [ ] 日志：结构化日志（slog）
- [ ] 数据库：SQLite 起步，GORM 或 sqlc，支持 `DATABASE_URL` 环境变量切换
- [ ] CI: 构建、lint、测试流程
- [ ] 错误处理：统一的 JSON 错误响应格式

## v0.0.3 — human 域 API

对应 CLI `human` 职能域和 Studio `org` 包。

- [ ] 员工管理：`GET/POST/PUT/DELETE /api/v1/employees`
- [ ] 组织架构：`/api/v1/departments`
- [ ] 岗位管理：`/api/v1/positions`
- [ ] 考勤管理：`/api/v1/attendance`
- [ ] 数据迁移：CLI 本地数据（`~/.local/share/qtadmin/`）可导入 Provider

## v0.0.4 — connect 域 API

对应 CLI `connect` 职能域。

- [ ] 飞书集成：消息通知、审批回调
- [ ] 邮件通道：Lark Mail 发送和接收
- [ ] 通知记录：`/api/v1/notifications` 历史查询

## v0.0.5 — auth 域 API

- [ ] 用户认证：JWT 登录
- [ ] 权限管理：RBAC
- [ ] API 鉴权中间件

## v0.0.6 — 业务域 API

对应 CLI 五大业务域和 Studio `qtconsult` 等包。

- [ ] `qtconsult` — 咨询项目：阶段流转、交付物管理
- [ ] `qtclass` — 课程业务：排课、报名
- [ ] `qtcloud` — 云业务：资源管理
- [ ] `qtdata` — 数据业务：数据集管理
- [ ] `qtrecurit` — 招聘：简历、面试流程

## v0.1.0 目标

- [ ] 覆盖上述所有域的核心 CRUD + 业务 API
- [ ] 测试覆盖率 ≥ 70%
- [ ] OpenAPI 文档（swagger）
- [ ] CLI 支持 `--provider` 模式，调用 Provider API 替代本地文件
- [ ] Studio 全部数据源切换为 Provider API
- [ ] CI 通过方可合入
