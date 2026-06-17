# QtCloud Auth — 身份认证系统

用户档案（UserProfile）的权威数据源。全系统的身份信息统一在此管理。

## API

| 端点 | 方法 | 说明 |
|------|------|------|
| `/user-profiles` | GET/POST | 列出（支持 q/email 过滤）/创建 |
| `/user-profiles/{id}` | GET/PATCH/DELETE | 详情/更新/删除 |

## UserProfile 字段

| 字段 | 说明 |
|------|------|
| `real_name` | 真实姓名 |
| `email` | 邮箱（唯一） |
| `phone` | 电话 |
| `school` | 学校 |
| `major` | 专业 |
| `avatar_url` | 头像 |
| `resume_url` | 简历地址 |

## 与其他系统的关系

Auth 提供身份数据，HR/Project/Finance 等业务系统通过 `user_profile_id` 引用。
