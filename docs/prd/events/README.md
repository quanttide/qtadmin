# 领域事件

第二大脑当前关注以下最小事件集：

1. `KnowledgeCaptured`：知识输入已记录
2. `KnowledgeLinked`：对象关系已建立
3. `DecisionMade`：决策已形成
4. `ActionPlanned`：行动项已创建
5. `ActionCompleted`：行动项已完成
6. `ResultFedBack`：结果已回流知识库
7. `AuditLogged`：关键操作已审计

事件要求：

- 必须包含操作者身份（人类或智能体）
- 必须包含时间戳和对象 ID
- 关键事件支持按对象链路查询
