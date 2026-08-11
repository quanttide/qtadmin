# Provider 壳（qtadmin-provider）

qtadmin provider 当前为**服务骨架**：config / store / health / 日志 / 优雅关闭。
领域 handler 与模型已拆分迁移至各产品线仓库 `examples/`：

| 领域 | 路由 | 去向 |
|:-----|:-----|:-----|
| human | `/api/v1/employees`、`/departments`、`/positions`、`/qtrecurit/*` | `qtcloud-human/examples/human-api/` |
| connect | `/api/v1/connect/rules`、`/notifications` | `qtcloud-connect/examples/connect-api/` |
| course | `/api/v1/qtclass/courses`、`/schedules`、`/enrollments` | `qtcloud-course/examples/course-api/` |
| asset | `/api/v1/qtcloud/resources` | `qtcloud-asset/examples/asset-api/` |
| data | `/api/v1/qtdata/datasets` | `qtdata/examples/dataset-api/` |
| consult | `/api/v1/qtconsult/projects` | `qtconsult/examples/consult-api/` |

恢复领域服务：从对应 `examples/` 引入 handler 与 model，在 `cmd/server/main.go` 的路由注册点挂载。

## 启动

```bash
cd src/provider
go run ./cmd/server
```

当前仅 `GET /health` 可用；配置通过环境变量设定（见下方说明），代码自动读取。

## 数据存储

Provider 的数据文件存放在 `/home/iguo/data/`，通过 `STORE_PATH` 环境变量指定。

### 系统环境变量配置

编辑 `~/.bashrc`，加入以下内容：

```bash
# qtadmin provider
export QTADMIN_STORE_PATH=/home/iguo/repos/quanttide/default/quanttide-tech/data/profile
export QTADMIN_JWT_SECRET=your-secret
export QTADMIN_ADMIN_PASSWORD=your-password
```

```bash
source ~/.bashrc
cd src/provider
go run ./cmd/server
```

所有命令行副本共用同一份环境变量，数据统一读写 `/home/iguo/repos/quanttide/default/quanttide-tech/data/profile/`。

| 变量 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `QTADMIN_ADDR` | `:8000` | 监听地址 |
| `QTADMIN_STORE_PATH` | `data` | 数据存储目录 |
| `QTADMIN_STORE_DRIVER` | `file` | 存储驱动（`file` / `s3`） |
| `QTADMIN_JWT_SECRET` | — | JWT 签名密钥 |
| `QTADMIN_ADMIN_PASSWORD` | — | 管理员密码，启动时自动创建 admin 用户 |
| `QTADMIN_LOG_LEVEL` | `info` | 日志级别 |
| `QTADMIN_LOG_FORMAT` | `text` | 日志格式，`text` 或 `json` |

> 兼容旧名称：`ADDR`、`STORE_PATH`、`JWT_SECRET`、`ADMIN_PASSWORD` 等仍可用。`QTADMIN_*` 优先级更高。

### 备份到对象存储

```bash
cd /home/iguo/repos/quanttide/default/quanttide-tech
tar czf profile-$(date +%Y%m%d).tar.gz data/profile/
aws s3 cp profile-*.tar.gz s3://my-bucket/profile/
```

## 认证

Provider 使用 JWT（HMAC-SHA256）认证，无外部依赖。

### 管理员账号

服务启动时检测 `auth.admin_password` 配置项，若管理员用户不存在则自动创建。

| 配置项 | 环境变量 | 说明 |
|:-------|:---------|:-----|
| `auth.jwt_secret` | `JWT_SECRET` | JWT 签名密钥 |
| `auth.admin_password` | `ADMIN_PASSWORD` | 管理员登录密码，用于初始创建 |

### 登录

```bash
curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"your-password"}'
```

返回：

```json
{
  "token": "eyJ...",
  "user": { "id": "...", "username": "admin" }
}
```

### 使用 Token

后续请求在 Header 中携带：

```bash
curl -s http://localhost:8000/api/v1/auth/me \
  -H 'Authorization: Bearer eyJ...'
```

### Token 刷新

```bash
curl -s -X POST http://localhost:8000/api/v1/auth/refresh \
  -H 'Authorization: Bearer eyJ...'
```

返回新的 24 小时有效 token。

## API

领域端点已随拆分迁移（见顶部去向表），当前仅：

| 端点 | 鉴权 | 说明 |
|:-----|:-----|:-----|
| `GET /health` | 否 | 健康检查 |

## 架构说明

Provider 只做两件事：

1. **持久化** — 接收 CLI 加工后的数据，存入本地 JSON 文件（S3 接口预留）
2. **认证** — JWT 签发与校验，admin 账号启动时自动创建

CLI 负责调用第三方工具获取数据、加工整理，然后通过 HTTP 写入 Provider。外部集成（飞书、邮件等）也由 CLI 直接调用，Provider 不涉及。
