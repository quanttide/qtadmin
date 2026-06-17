# QtCloud Org — 组织架构系统

定义公司岗位（Position）的权威数据源。

## API

| 端点 | 方法 | 说明 |
|------|------|------|
| `/positions` | GET/POST | 列出（支持 q/department/active 过滤）/创建 |
| `/positions/{id}` | GET/PATCH/DELETE | 详情/更新/删除 |

## Position 字段

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
