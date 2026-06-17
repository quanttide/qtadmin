# Org — 组织架构系统

定义公司岗位的权威数据源。Rust 版（axum + sqlx + sqlite）。

## API

| 端点 | 方法 | 说明 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/positions` | GET | 列出（支持 q/department/active 过滤） |
| `/positions` | POST | 创建 |
| `/positions/{id}` | GET | 详情 |
| `/positions/{id}` | PATCH | 更新 |
| `/positions/{id}` | DELETE | 删除 |

## 运行

```bash
cargo run
```

监听 `http://0.0.0.0:3001`，数据存储在 `qtcloud-org.db`。

## 字段

| 字段 | 说明 |
|------|------|
| `name` | 岗位名称（唯一） |
| `department` | 所属部门 |
| `level` | 职级 |
| `description` | 岗位描述 |
| `responsibilities` | 职责 |
| `requirements` | 任职要求 |
| `active` | 是否启用 |

## 与 HR 系统的关系

Org 定义岗位，HR 引用岗位创建招聘需求（Requisition），两者通过 `org_position_id` 关联。
