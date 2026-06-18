# 业务域

业务域包括量潮咨询、量潮课堂、量潮云、量潮数据四个板块。

## 量潮咨询 (qtconsult)

> CLI provider 模式待接入

```bash
# 创建项目（通过 Provider API）
curl -s -X POST http://localhost:8000/api/v1/qtconsult/projects \
  -H 'Content-Type: application/json' \
  -d '{"name":"数字化转型咨询","client":"某制造企业","stage":"调研","status":"active"}'
```

CLI 接入后：

```bash
qtadmin --provider qtconsult project create --name "..." --client "..." --stage "调研"
```

字段：`id`, `name`, `stage`, `client`, `status`, `created_at`

## 量潮课堂 (qtclass)

> CLI provider 模式待接入

```bash
# 创建课程
curl -s -X POST http://localhost:8000/api/v1/qtclass/courses \
  -H 'Content-Type: application/json' \
  -d '{"name":"Rust 实战班","teacher":"王教授","max_students":30,"status":"active"}'
```

字段：`id`, `name`, `teacher`, `schedule`, `max_students`, `status`

## 量潮云 (qtcloud)

> CLI provider 模式待接入

```bash
# 创建资源
curl -s -X POST http://localhost:8000/api/v1/qtcloud/resources \
  -H 'Content-Type: application/json' \
  -d '{"name":"生产ECS-01","type":"ecs","region":"cn-east","status":"running"}'
```

字段：`id`, `name`, `type`, `region`, `status`, `created_at`

## 量潮数据 (qtdata)

> CLI provider 模式待接入

```bash
# 创建数据集
curl -s -X POST http://localhost:8000/api/v1/qtdata/datasets \
  -H 'Content-Type: application/json' \
  -d '{"name":"销售数据集","description":"Q2销售数据","version":"1.0","status":"ready"}'
```

字段：`id`, `name`, `description`, `version`, `status`, `created_at`
