# Provider 部署与使用

## 启动

```bash
cd src/provider
ADMIN_PASSWORD=your-password JWT_SECRET=any-random-string go run ./cmd/server
```

也可用 JSON 配置文件：

```json
{
  "server": { "addr": ":8000" },
  "store": { "driver": "file", "path": "data" },
  "auth": {
    "jwt_secret": "any-random-string",
    "admin_password": "your-password"
  }
}
```

```bash
CONFIG_PATH=config.json go run ./cmd/server
```

默认监听 `:8000`，可通过 `ADDR` 或配置文件的 `server.addr` 修改。

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

所有端点见 `docs/openapi.yaml`，概览：

| 域 | 端点 | 鉴权 | 说明 |
|:---|:-----|:-----|:-----|
| Health | `GET /health` | 否 | 健康检查 |
| Human | `GET/POST /api/v1/employees` | 否 | 员工列表/创建 |
| Human | `GET/PUT/DELETE /api/v1/employees/{id}` | 否 | 员工详情/更新/删除 |
| Human | `GET/POST /api/v1/departments` | 否 | 部门 |
| Human | `GET/POST /api/v1/positions` | 否 | 岗位 |
| Auth | `POST /api/v1/auth/login` | 否 | 登录 |
| Auth | `POST /api/v1/auth/refresh` | 是 | 刷新 token |
| Auth | `GET /api/v1/auth/me` | 是 | 当前用户 |
| Connect | `GET /api/v1/connect/notifications` | 否 | 通知历史 |
| Business | `GET/POST/PUT/DELETE` / 各业务域 | 否 | CRUD |

提示：生产环境建议对业务端点加鉴权，通过反向代理或 Provider 的 `AuthMiddleware` 实现。

## 架构说明

Provider 只做两件事：

1. **持久化** — 接收 CLI 加工后的数据，存入本地 JSON 文件（S3 接口预留）
2. **认证** — JWT 签发与校验，admin 账号启动时自动创建

CLI 负责调用第三方工具获取数据、加工整理，然后通过 HTTP 写入 Provider。外部集成（飞书、邮件等）也由 CLI 直接调用，Provider 不涉及。
