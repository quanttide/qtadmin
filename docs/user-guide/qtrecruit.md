# 量潮招聘

招聘业务模块，管理简历、面试和候选人流程。数据通过 Provider API 持久化。

## 简历管理

```bash
# 导入简历（CLI 从招聘平台获取数据后写入 Provider）
curl -s -X POST http://localhost:8000/api/v1/qtrecurit/resumes \
  -H 'Content-Type: application/json' \
  -d '{"candidate_name":"赵六","position":"Go工程师","source":"Boss直聘","stage":"new"}'
```

字段：`id`, `candidate_name`, `position`, `stage`, `feedback`, `created_at`

阶段流转通过 CLI 加工后 `PUT` 更新整个记录完成。

## 面试管理

```bash
# 创建面试
curl -s -X POST http://localhost:8000/api/v1/qtrecurit/interviews \
  -H 'Content-Type: application/json' \
  -d '{"candidate":"赵六","interviewer":"陈经理","type":"技术面","date":"2026-06-20"}'
```

字段：`id`, `resume_id`, `candidate`, `interviewer`, `time`, `feedback`, `created_at`
