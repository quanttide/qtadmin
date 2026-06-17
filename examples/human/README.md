# Human — 组织架构岗位管理 CLI

定义公司岗位的权威数据源，Rust CLI（clap + sqlx + sqlite）。

## 命令

| 命令 | 说明 |
|------|------|
| `human list` | 列出岗位（支持 `--department`、`--active`、`--search` 过滤） |
| `human get <id>` | 查询单个岗位 |
| `human create --name <name>` | 创建岗位 |
| `human update <id>` | 更新岗位 |
| `human delete <id>` | 删除岗位 |

## 运行

```bash
cargo run -- list
cargo run -- create --name "前端工程师" --department "产品研发"
cargo run -- get 1
```

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

Human 定义岗位，HR 引用岗位创建招聘需求（Requisition），两者通过 `org_position_id` 关联。
