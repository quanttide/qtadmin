# TODO

## v0.0.2 — 基础设施

### 配置管理

- [ ] 创建 `internal/config/config.go`，加载 YAML 文件 + 环境变量
- [ ] 支持 `CONFIG_PATH` 环境变量指定配置文件路径
- [ ] 基础配置结构：`server.addr`、`database.url`、`log.level`

### 日志

- [ ] 使用 `log/slog` 替代 `log` 包
- [ ] 支持 `LOG_LEVEL` 环境变量（debug/info/warn/error）
- [ ] JSON 格式输出用于生产环境，文本格式用于开发

### 数据库

- [ ] 调研并选定：GORM vs sqlc vs sqlx
- [ ] 创建 `internal/db/db.go`，封装连接管理
- [ ] SQLite 起步，支持 `DATABASE_URL` 环境变量切换驱动
- [ ] 自动迁移 / 初始化 Schema

### CI

- [ ] 创建 `.github/workflows/provider.yml`
- [ ] `go build ./cmd/server` 编译检查
- [ ] `go vet ./...` 静态检查
- [ ] `go test ./...` 运行测试

### 错误处理

- [ ] 统一错误响应结构：`{"error": {"code": "...", "message": "..."}}`
- [ ] 创建 `internal/api/error.go`，定义错误码和 HTTP 映射
- [ ] 中间件或 helper 函数处理 panic 和验证错误

## v0.0.3 — human 域 API

### 数据模型

- [ ] `internal/model/employee.go`：员工模型（姓名、部门、岗位、入职日期、状态）
- [ ] `internal/model/department.go`：部门模型
- [ ] `internal/model/position.go`：岗位模型
- [ ] `internal/model/attendance.go`：考勤记录模型
- [ ] 数据库迁移脚本

### Handler

- [ ] `GET /api/v1/employees` — 员工列表（支持分页、搜索）
- [ ] `POST /api/v1/employees` — 创建员工
- [ ] `GET /api/v1/employees/{id}` — 员工详情
- [ ] `PUT /api/v1/employees/{id}` — 更新员工
- [ ] `DELETE /api/v1/employees/{id}` — 删除员工
- [ ] `GET /api/v1/departments` — 部门列表（树形结构）
- [ ] `POST /api/v1/departments` — 创建部门
- [ ] `PUT /api/v1/departments/{id}` — 更新部门
- [ ] `GET /api/v1/positions` — 岗位列表
- [ ] `POST /api/v1/positions` — 创建岗位
- [ ] `PUT /api/v1/positions/{id}` — 更新岗位
- [ ] `GET /api/v1/attendance` — 考勤记录查询（按日期范围、员工）
- [ ] `POST /api/v1/attendance` — 打卡记录导入/录入

### 数据迁移

- [ ] CLI 本地数据格式分析：`~/.local/share/qtadmin/` 目录结构
- [ ] 导入命令或启动时自动迁移
- [ ] 迁移后的数据校验

### 测试

- [ ] `internal/model/` 模型单元测试
- [ ] `internal/api/human_test.go` handler 集成测试（内存数据库）
- [ ] 测试覆盖率 ≥ 60%

## v0.0.4 — connect 域 API

### 飞书集成

- [ ] 飞书应用凭证配置（App ID / App Secret）
- [ ] 获取 tenant_access_token
- [ ] 消息通知：发送文本消息到群聊或用户
- [ ] 审批回调：接收飞书审批事件 Webhook

### 邮件通道

- [ ] Lark Mail 配置（邮箱地址、SMTP/API）
- [ ] 邮件发送接口 `POST /api/v1/connect/email`
- [ ] 邮件接收 Webhook

### 通知记录

- [ ] `internal/model/notification.go`：通知记录模型
- [ ] `GET /api/v1/notifications` — 通知历史查询
- [ ] `GET /api/v1/notifications/{id}` — 通知详情

### 测试

- [ ] handler 集成测试
- [ ] 外部服务 mock（飞书 API、邮件服务器）

## v0.0.5 — auth 域 API

### 用户认证

- [ ] 用户模型：`internal/model/user.go`
- [ ] `POST /api/v1/auth/login` — 用户名密码登录，返回 JWT
- [ ] JWT 签发与验证工具函数
- [ ] `POST /api/v1/auth/refresh` — 刷新 token

### 权限管理

- [ ] 角色模型：`internal/model/role.go`
- [ ] 权限模型：`internal/model/permission.go`
- [ ] RBAC 核心逻辑：角色-权限关联、用户-角色关联
- [ ] 权限校验中间件

### API 鉴权

- [ ] JWT 认证中间件（从 Authorization header 提取 token）
- [ ] 路由权限声明机制：每个路由标记所需权限
- [ ] 未认证 401、无权限 403 统一响应

### 测试

- [ ] 认证流程端到端测试
- [ ] RBAC 逻辑单元测试
- [ ] 中间件测试

## v0.0.6 — 业务域 API

### qtconsult

- [ ] 咨询项目模型：项目信息、阶段、交付物
- [ ] `GET /api/v1/qtconsult/projects` — 项目列表
- [ ] `POST /api/v1/qtconsult/projects` — 创建项目
- [ ] `PUT /api/v1/qtconsult/projects/{id}/stage` — 阶段流转
- [ ] `GET /api/v1/qtconsult/projects/{id}/deliverables` — 交付物管理
- [ ] `POST /api/v1/qtconsult/projects/{id}/deliverables` — 上传交付物

### qtclass

- [ ] 课程模型：课程信息、排课、报名
- [ ] `GET /api/v1/qtclass/courses` — 课程列表
- [ ] `POST /api/v1/qtclass/courses` — 创建课程
- [ ] `GET /api/v1/qtclass/schedules` — 排课查询
- [ ] `POST /api/v1/qtclass/enrollments` — 报名

### qtcloud

- [ ] 云资源模型
- [ ] `GET /api/v1/qtcloud/resources` — 资源列表
- [ ] `POST /api/v1/qtcloud/resources` — 创建资源
- [ ] `PUT /api/v1/qtcloud/resources/{id}/status` — 更新资源状态

### qtdata

- [ ] 数据集模型
- [ ] `GET /api/v1/qtdata/datasets` — 数据集列表
- [ ] `POST /api/v1/qtdata/datasets` — 创建数据集
- [ ] 数据上传与版本管理

### qtrecurit

- [ ] 简历模型：解析、存储
- [ ] 面试流程模型：阶段、反馈
- [ ] `POST /api/v1/qtrecurit/resumes` — 简历导入
- [ ] `PUT /api/v1/qtrecurit/resumes/{id}/stage` — 阶段流转
- [ ] `POST /api/v1/qtrecurit/interviews` — 面试排期
- [ ] `POST /api/v1/qtrecurit/interviews/{id}/feedback` — 面试反馈

## v0.1.0 — 稳定版

### 集成

- [ ] CLI 支持 `--provider` 模式：HTTP 客户端封装，调用 Provider API
- [ ] Studio 数据源切换：`DataLoader` 新增 `ApiSource` 实现
- [ ] 数据迁移工具：CLI 本地数据 → Provider 数据库

### 质量

- [ ] 测试覆盖率 ≥ 70%
- [ ] OpenAPI 文档（swagger/ags）
- [ ] CI 通过方可合入
- [ ] 性能基准测试：关键 API 响应时间 P99 < 200ms

### 部署

- [ ] Dockerfile
- [ ] docker-compose.yml（provider + 数据库）
- [ ] 部署文档 `docs/ops/provider.md`
