# 量潮招聘

招聘业务模块，管理简历、面试和候选人流程。

> CLI provider 模式待接入

```bash
# 导入简历（当前通过 Provider API）
curl -s -X POST http://localhost:8000/api/v1/qtrecurit/resumes \
  -H 'Content-Type: application/json' \
  -d '{"candidate_name":"赵六","position":"Go工程师","source":"Boss直聘","stage":"new"}'

# 创建面试
curl -s -X POST http://localhost:8000/api/v1/qtrecurit/interviews \
  -H 'Content-Type: application/json' \
  -d '{"candidate":"赵六","interviewer":"陈经理","type":"技术面","date":"2026-06-20"}'
```

CLI 接入后：

```bash
qtadmin --provider qtrecurit resume import --candidate "赵六" --position "Go工程师"
qtadmin --provider qtrecurit interview create --candidate "赵六" --interviewer "陈经理"
```

## 简历管理

- 简历导入：CLI 从招聘平台获取数据，加工后写入 Provider
- 阶段流转：CLI 更新整个记录完成

字段：`id`, `candidate_name`, `position`, `stage`, `feedback`, `created_at`

## 面试管理

- 面试排期：CLI 创建面试记录
- 反馈录入：CLI 更新面试记录

字段：`id`, `resume_id`, `candidate`, `interviewer`, `time`, `feedback`, `created_at`
