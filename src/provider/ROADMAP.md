# ROADMAP

## 定位

Provider 是 qtadmin 的后端 API 服务。它处于 CLI 和 Studio 之下，提供统一的数据持久化、业务逻辑和外部系统集成能力。

| 组件 | 角色 | 与 Provider 关系 |
|:-----|:-----|:-----------------|
| CLI | 命令行接口 | 当前直接操作本地文件，已支持 `--provider` 模式调用 Provider API |
| Studio | Flutter 客户端 | 通过 HTTP 调用 Provider 获取和写入数据（待打通） |
| Provider | 后端 API | 本地 JSON 文件存储，S3 接口预留，零外部依赖 |

## 版本策略

- `v0.0.x` — 探索验证期，逐步补齐各域 API
- `v0.1.0` — 首个稳定版本，覆盖 CLI v0.1.0 和 Studio 主要域的 API 需求

版本号与主仓库同步（见 `AGENTS.md` 版本约定）。

---

## v0.0.1 — 骨架搭建 ✅

- [x] Go 项目初始化（`cmd/server/main.go` + `internal/` 分层）
- [x] `GET /health` 健康检查端点
- [x] `ADDR` 环境变量支持端口配置

## v0.0.2 — 基础设施 ✅

- [x] 存储层：`internal/store/` — Store 接口 + FileStore（本地 JSON 文件）
- [x] S3 驱动接口预留（`store.New("s3", ...)` 返回 "not yet implemented"）
- [x] 配置管理：JSON 文件 + `STORE_DRIVER` / `STORE_PATH` 环境变量
- [x] 日志：`slog`，JSON/text 格式，`LOG_LEVEL` 可配
- [x] 错误处理：统一 `{"error": {"code": "...", "message": "..."}}` 格式
- [x] CI：`.github/workflows/provider.yml`（build + vet + test）

## v0.0.3 — human 域 API ✅

- [x] 员工管理：`GET/POST/PUT/DELETE /api/v1/employees`
- [x] 组织架构：`/api/v1/departments`
- [x] 岗位管理：`/api/v1/positions`
- [ ] 考勤管理：`/api/v1/attendance`（挂起）
- [ ] 数据迁移：CLI 本地数据导入 Provider（挂起）

## v0.0.4 — connect 域 API ✅

- [x] 飞书集成 mock：消息通知、审批回调 Webhook
- [x] 邮件 mock：SMTP 配置预留
- [x] 通知记录：`GET /api/v1/connect/notifications` 历史查询
- [ ] 接真实飞书 API（mock → real）
- [ ] 接真实 SMTP（mock → real）

## v0.0.5 — auth 域 API ✅

- [x] 用户注册 + 登录：`POST /api/v1/auth/register`, `/auth/login`
- [x] 自定义 JWT（HMAC-SHA256，stdlib only）
- [x] API 鉴权中间件：`AuthMiddleware`（Bearer token → context）
- [x] Token 刷新：`POST /api/v1/auth/refresh`
- [x] 当前用户：`GET /api/v1/auth/me`
- [ ] RBAC 权限模型（role/permission 模型已定义，逻辑待实现）

## v0.0.6 — 业务域 API ✅

- [x] `qtconsult` — 咨询项目 CRUD + 阶段流转
- [x] `qtclass` — 课程 CRUD + 排课 + 报名
- [x] `qtcloud` — 云资源 CRUD + 状态更新
- [x] `qtdata` — 数据集 CRUD
- [x] `qtrecurit` — 简历导入 + 阶段流转 + 面试 + 反馈

## 测试覆盖 ✅

- [x] JWT 工具测试（sign/verify/expired/bad sig）
- [x] Store 测试（CRUD/concurrency/排序）
- [x] Human handler 测试（employee/department/position CRUD + validation）
- [x] Auth handler 测试（register/login/middleware）
- [x] Connect handler 测试（notify/list/get/webhook）
- [x] Business handler 测试（5 个域，CRUD + 阶段/状态流转）
- [x] Model 测试（12 个模型，marshal/unmarshal）
- [x] Connect 包测试（lark/email mock）
- [x] Config 测试（加载/默认值/环境变量覆盖/异常 — 100% 覆盖）
- [ ] 测试覆盖率 ≥ 70%（当前 54%，缺集成测试和 error path）

## 契约 ✅

- [x] `docs/openapi.yaml` — OpenAPI 3.0.3，31 端点，14 模型，Bearer auth

## CLI — Provider 打通 ✅

- [x] CLI 全局 `--provider` / `-p` flag
- [x] `provider.rs` — Rust HTTP 客户端（ProviderClient）
- [x] human domain 已接入 Provider 模式

---

## v0.1.0 目标

### 集成
- [ ] CLI 全部域支持 `--provider` 模式（connect / auth / business）
- [ ] Studio 数据源切换：`DataLoader` 新增 `ApiSource` 实现
- [ ] 数据迁移工具：CLI 本地数据 → Provider

### 质量
- [ ] 测试覆盖率 ≥ 70%
- [ ] 集成测试（httptest 启动完整 server）
- [ ] OpenAPI 契约与代码同步（API 变更时更新 openapi.yaml）
- [ ] CI 通过方可合入
- [ ] 性能基准测试：关键 API 响应时间 P99 < 200ms

### 部署
- [ ] Dockerfile
- [ ] docker-compose.yml（provider 单服务）
- [ ] 部署文档 `docs/ops/provider.md`
- [ ] S3 存储驱动（`store.New("s3", ...)` 实现）

### 外部集成
- [ ] 飞书 API（真实 token 获取 + 消息发送）
- [ ] SMTP 邮件发送（真实, mock → real）
