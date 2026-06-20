# Provider 部署与使用

## 启动

```bash
cd src/provider
go run ./cmd/server
```

配置通过环境变量设定（见下方说明），代码自动读取。

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
