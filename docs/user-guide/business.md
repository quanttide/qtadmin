# 业务域

业务域包括量潮咨询、量潮课堂、量潮云、量潮数据四个板块。所有数据通过 Provider API 持久化。

## 通用操作

所有业务域支持以下操作：

- `POST` 创建资源
- `GET /{id}` 查询单个
- `GET` 列出全部
- `PUT /{id}` 更新
- `DELETE /{id}` 删除

## 量潮咨询 (qtconsult)

```bash
# 创建项目
curl -s -X POST http://localhost:8000/api/v1/qtconsult/projects \
  -H 'Content-Type: application/json' \
  -d '{"name":"数字化转型咨询","client":"某制造企业","stage":"调研","status":"active"}'

# 项目阶段流转（更新整个资源）
curl -s -X PUT http://localhost:8000/api/v1/qtconsult/projects/{id} \
  -H 'Content-Type: application/json' \
  -d '{"name":"...","client":"...","stage":"方案设计","status":"active"}'
```

字段：`id`, `name`, `stage`, `client`, `status`, `created_at`

## 量潮课堂 (qtclass)

```bash
# 创建课程
curl -s -X POST http://localhost:8000/api/v1/qtclass/courses \
  -H 'Content-Type: application/json' \
  -d '{"name":"Rust 实战班","teacher":"王教授","max_students":30,"status":"active"}'

# 报名（仅创建记录）
curl -s -X POST http://localhost:8000/api/v1/qtclass/enrollments \
  -H 'Content-Type: application/json' \
  -d '{"course_id":"c1","student":"小明"}'
```

字段：`id`, `name`, `teacher`, `schedule`, `max_students`, `status`

## 量潮云 (qtcloud)

```bash
# 创建资源
curl -s -X POST http://localhost:8000/api/v1/qtcloud/resources \
  -H 'Content-Type: application/json' \
  -d '{"name":"生产ECS-01","type":"ecs","region":"cn-east","status":"running"}'

# 更新状态
curl -s -X PUT http://localhost:8000/api/v1/qtcloud/resources/{id} \
  -H 'Content-Type: application/json' \
  -d '{"name":"...","type":"ecs","region":"cn-east","status":"stopped"}'
```

字段：`id`, `name`, `type`, `region`, `status`, `created_at`

## 量潮数据 (qtdata)

```bash
# 创建数据集
curl -s -X POST http://localhost:8000/api/v1/qtdata/datasets \
  -H 'Content-Type: application/json' \
  -d '{"name":"销售数据集","description":"Q2销售数据","version":"1.0","status":"ready"}'
```

字段：`id`, `name`, `description`, `version`, `status`, `created_at`
