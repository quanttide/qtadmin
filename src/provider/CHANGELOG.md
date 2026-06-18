# CHANGELOG

## [0.0.1] - 2026-06-18

Go 重构版本，Python FastAPI → Go 全量迁移。

### Added

- `GET /health` 健康检查端点
- `ADDR` 环境变量支持端口配置
- 配置管理：JSON 文件 + 环境变量覆盖
- 日志：`log/slog`，支持 text/json 格式和级别配置
- 存储层：`internal/store` — Store 接口 + FileStore（本地 JSON 文件），S3 预留
- 统一错误响应：`{"error": {"code": "...", "message": "..."}}`
- CI: `.github/workflows/provider.yml`（build + vet + test）

#### Human 域

- 员工管理：GET/POST/PUT/DELETE `/api/v1/employees`
- 部门管理：GET/POST/PUT/DELETE `/api/v1/departments`
- 岗位管理：GET/POST/PUT/DELETE `/api/v1/positions`

#### Connect 域

- 通知历史：GET `/api/v1/connect/notifications`
- 分类规则：GET/POST/PUT/DELETE `/api/v1/connect/rules`

#### Business 域

- 咨询项目 CRUD：`/api/v1/qtconsult/projects`
- 课程管理 + 排课 + 报名：`/api/v1/qtclass/courses`
- 云资源管理：`/api/v1/qtcloud/resources`
- 数据集管理：`/api/v1/qtdata/datasets`
- 简历导入：`/api/v1/qtrecurit/resumes`
- 面试创建：`/api/v1/qtrecurit/interviews`

### Tests

- 集成测试 8 组（httptest 启动完整 server，覆盖全部域）
- 单元测试覆盖：JWT、Config、Store、Model（共 12 个模型）
- Python 端到端测试（`tests/test_human.py`，17 个测试）

### Infrastructure

- 预提交 hook：CLI 变更触发 `cargo build + test`
- OpenAPI 契约：`docs/api-reference/provider.yaml`
- 用户指南：`docs/user-guide/`
