# Auth — 身份认证系统

包含权限体系验证和用户档案 CRUD API。

## 模块

| 文件 | 说明 |
|------|------|
| `src/auth.rs` | Role 枚举、权限表、审计日志模块 |
| `src/main.rs` | 用户档案 REST API（axum + sqlx + sqlite） |

## API

| 端点 | 方法 | 说明 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/user-profiles` | GET | 列出（支持 q/email 过滤） |
| `/user-profiles` | POST | 创建 |
| `/user-profiles/{id}` | GET | 详情 |
| `/user-profiles/{id}` | PATCH | 更新 |
| `/user-profiles/{id}` | DELETE | 删除 |

## 运行

```bash
cargo run
```

监听 `http://0.0.0.0:3000`，数据存储在 `qtcloud-auth.db`。

## 权限体系

验证剩余权限原则和三轨审计。`auth.rs` 定义了 `SuperAdmin` 和 `Operator` 两种角色，通过权限表控制命令访问，审计日志写入本地文件。

## 字段

| 字段 | 说明 |
|------|------|
| `real_name` | 真实姓名 |
| `email` | 邮箱（唯一） |
| `phone` | 电话 |
| `school` | 学校 |
| `major` | 专业 |
| `avatar_url` | 头像 |
| `resume_url` | 简历地址 |
