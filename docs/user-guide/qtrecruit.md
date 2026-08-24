# 量潮招聘

招聘业务模块，管理简历、面试和候选人流程。

> CLI 能力已落地 [qtrecurit](https://github.com/quanttide/qtrecurit)（招聘域）；qtadmin provider 集成待接入

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

招聘域 CLI（qtrecurit）当前可用命令：

```bash
# 凭证化人才推荐（凭证号 REF-YYYYMMDD-NNN → 推荐信 → 草稿 → 确认 → 发送 → 台账）
qtrecurit referral send --name "赵六" --candidate-email zhaoliu@example.com --company "智元"

# 招聘沟通邮件（话术模板：referral / training / exam）
qtrecurit mail send --to "赵六@example.com" --template exam
```

## 简历管理

- 简历导入：CLI 从招聘平台获取数据，加工后写入 Provider
- 阶段流转：CLI 更新整个记录完成

字段：`id`, `candidate_name`, `position`, `stage`, `feedback`, `created_at`

## 面试管理

- 面试排期：CLI 创建面试记录
- 反馈录入：CLI 更新面试记录

字段：`id`, `resume_id`, `candidate`, `interviewer`, `time`, `feedback`, `created_at`
