# 代币薪酬

包括薪酬管理与代币交易两个部分。

系统预先存好可以计算的条目，然后员工自己提交申请，通过验收以后自动运行结算，然后再反馈到薪酬系统中。

## 需求

用户故事1：薪酬规则配置

故事描述

作为薪酬管理员，我希望预先配置可计算的代币奖励条目（如任务完成、绩效达标），包括规则、代币计算公式和生效条件，以便员工申请时系统能自动匹配计算逻辑。

划分理由

• 独立性：基础配置需与申请流程解耦，管理员操作无需依赖员工行为。

• 可扩展性：未来新增奖励类型（如创新提案、客户好评）只需扩展此故事，无需修改核心流程。


——

用户故事2：代币薪酬申请提交

故事描述

作为员工，我可以在系统中提交申请，关联预配置的奖励条目（如“完成季度销售目标”），上传证明材料，以便启动审批流程。

划分理由

• 用户角色分离：员工视角操作独立，降低流程复杂度（与审批/计算逻辑解耦）。

• 风险隔离：提交失败或材料错误仅影响单次申请，不波及整体系统。


——

用户故事3：自动化审批与验收

故事描述

作为部门经理，我需审核员工提交的代币申请，点击验收后系统自动验证材料完整性（如文件格式、数据匹配），并触发结算流程。

划分理由

• 流程边界：审批是人工决策节点，独立划分确保验收失败时可回退，避免脏数据进入结算。

• 职责清晰：经理只需关注合理性，无需理解后台计算规则。


——

用户故事4：代币结算与薪酬发放

故事描述

作为系统，当申请验收通过时，自动根据预配置规则计算代币数量，实时更新员工账户余额，并生成发放记录同步至薪酬总表。

划分理由

• 事务完整性：结算需保证原子性（计算+更新余额+记录日志），独立成故事便于事务管理。

• 失败隔离：若计算异常，可定位到结算模块，不影响前序审批流程。


——

用户故事5：代币交易与流通

故事描述

作为员工，我可将账户中的代币通过内部交易平台出售或转让给他人，交易成功后代币实时划转，价格由市场供需决定。

划分理由

• 功能解耦：交易是独立于薪酬发放的增值服务，需单独设计撮合引擎和账务体系。

• 安全隔离：交易涉及资金流动，需独立风控（如防欺诈检测），与薪酬发放逻辑分离。


——

用户故事6：通知与反馈

故事描述

作为员工，当申请状态变更（审批通过/拒绝/结算完成）或交易成功时，系统通过邮件/站内信通知我，并开放申诉入口。

划分理由

• 横切关注点：通知是全局能力，独立开发可复用于所有流程节点。

• 体验优化：集中处理反馈机制，避免分散在各故事中重复开发。


——

划分逻辑总结

1. 流程阶段拆解

  ◦ 配置 → 申请 → 审批 → 结算 → 交易，每个阶段输出明确（如审批输出验收结果），便于流程监控。

2. 角色职责分离

  ◦ 管理员、员工、经理、系统自动服务各司其职，避免故事跨角色混乱。

3. 技术风险隔离

  ◦ 结算需强一致性、交易需高并发，独立划分可针对性设计技术方案。

4. 增量交付价值

  ◦ 先实现薪酬发放闭环（故事1-4），再扩展交易功能（故事5），降低初期复杂度。

关键决策点：将“验收后自动结算”拆分为独立故事（故事4），而非合并到审批中，确保结算失败时可重试而不需重新审批，提升系统鲁棒性。

## 功能

下面以领域事件驱动设计(Event-Driven Design)的方式，重构”员工提交代币薪酬申请“功能的定义。领域事件是业务领域中的关键状态变更，准确捕捉这些事件能更好保证业务完整性和系统健壮性。


——

领域事件定义框架

graph LR
    A[业务动作] —> B[领域事件]
    B —> C[事件处理器]
    C —> D[系统响应]



——

功能重构：员工提交申请

核心领域事件

1. 代币申请单已创建(ClaimDraftCreated)

  ◦ 触发条件：员工开始填写申请表单

  ◦ 事件内容：

{
  ”eventId“: ”claim_draft_created“,
  ”timestamp“: ”2023-11-15T10:30:00Z“,
  ”payload“: {
    ”draftId“: ”DRAFT-20231115-001“,
    ”employeeId“: ”EMP-007“,
    ”rewardEntryId“: ”REWARD-Q3-SALES“,
    ”createdAt“: ”2023-11-15T10:30:00Z“,
    ”lastSaved“: ”2023-11-15T10:30:00Z“
  }
}


2. 申请材料已上传(SupportingMaterialUploaded)

  ◦ 触发条件：员工上传任何证明材料

  ◦ 事件内容：

{
  ”eventId“: ”material_uploaded“,
  ”timestamp“: ”2023-11-15T10:35:00Z“,
  ”payload“: {
    ”draftId“: ”DRAFT-20231115-001“,
    ”materialId“: ”MAT-Q3-REPORT-01“,
    ”fileType“: ”application/pdf“,
    ”fileHash“: ”sha256:abcd1234...“,
    ”ocrStatus“: ”PENDING“ // OCR处理状态
  }
}


3. 草稿已保存(ClaimDraftSaved)

  ◦ 触发条件：员工手动保存或自动保存草稿

  ◦ 事件内容：

{
  ”eventId“: ”draft_saved“,
  ”timestamp“: ”2023-11-15T10:40:00Z“,
  ”payload“: {
    ”draftId“: ”DRAFT-20231115-001“,
    ”savedData“: {
      ”kpiValues“: {”salesAmount“: 1500000},
      ”comments“: ”达成Q3销售目标“
    },
    ”ttl“: ”P7D“ // 草稿有效期7天
  }
}


4. 申请表单已提交(ClaimSubmitted)

  ◦ 触发条件：员工确认提交申请

  ◦ 事件内容：

{
  ”eventId“: ”claim_submitted“,
  ”timestamp“: ”2023-11-15T10:45:00Z“,
  ”payload“: {
    ”claimId“: ”CLAIM-20231115-007“,
    ”employeeId“: ”EMP-007“,
    ”rewardEntryId“: ”REWARD-Q3-SALES“,
    ”materials“: [”MAT-Q3-REPORT-01“],
    ”validationResult“: {
      ”isRulesCompliant“: true,
      ”missingItems“: []
    },
    ”submissionTime“: ”2023-11-15T10:45:00Z“
  }
}



——

事件消费与响应

1. 代币申请单已创建 → 启动草稿生命周期

flowchart LR
    A[事件: ClaimDraftCreated] —> B[创建草稿存储]
    A —> C[初始化表单状态]
    A —> D[启动自动保存计时器]


2. 申请材料已上传 → 触发后台处理

sequenceDiagram
    participant M as MaterialService
    participant O as OCRService
    participant V as ValidationService
    
    M->>M: 校验文件类型/大小
    M->>M: 计算哈希值
    M->>O: 发送OCR任务(MaterialUploaded事件)
    O->>V: 识别结果返回(OCRCompleted事件)
    V->>V: 比对预配置规则
    V->>M: 返回合规性状态(ValidationResult)


3. 草稿已保存 → 维持草稿状态

flowchart TB
    S[事件: DraftSaved] —> U[更新lastSaved时间]
    U —> P[持久化到数据库]
    P —> N[通知前端保存成功]
    P —> T[重置7天TTL计时器]


4. 申请表单已提交 → 启动审批流程

flowchart LR
    S[事件: ClaimSubmitted] —> C[校验事件完整性]
    C —>|通过| A[生成正式申请单]
    A —> P[持久化申请记录]
    P —> W[触发工作流引擎: StartApprovalProcess]
    W —> N[发送通知给审批人]
    
    C —>|失败| E[返回错误明细]
    E —> F[前端显示缺失项]



——

需求-事件映射验证

原始需求项	对应领域事件	消费处理器行为
关联预配置奖励条目	ClaimDraftCreated	加载条目配置，初始化表单
上传证明材料	SupportingMaterialUploaded	存储文件，启动OCR和合规性校验
材料完整性验证	ValidationResult (派生事件)	动态更新表单验证状态
启动审批流程	ClaimSubmitted	生成申请单实体，触发审批工作流
草稿暂存机制	ClaimDraftSaved	维持草稿状态，实施TTL管理
防重复申请	ClaimSubmitted	检查员工ID+奖励ID+时间窗口组合唯一性


——

领域模型关键设计

申请聚合根(Claim Aggregate)

class Claim {
  // 核心属性
  id: ClaimId
  employeeId: EmployeeId
  rewardEntry: RewardEntry
  materials: Material[]
  status: ’DRAFT‘ | ’SUBMITTED‘ | ’APPROVED‘ | ’REJECTED‘
  
  // 领域行为
  createDraft() { 
    this.registerEvent(new ClaimDraftCreated(...));
  }
  
  submit() {
    if (this.validate().isValid) {
      this.status = ’SUBMITTED‘;
      this.registerEvent(new ClaimSubmitted(...));
    }
  }
  
  // 内部校验规则
  private validate(): ValidationResult {
    // 检查材料完整性/历史重复等
  }
}


材料值对象(Material Value Object)

class Material {
  constructor(
    readonly id: MaterialId,
    readonly type: ’SALES_REPORT‘ | ’CERTIFICATE‘, // 预定义类型
    readonly storagePath: string,
    readonly hash: string,
    readonly ocrData?: OCRResult // OCR处理结果
  ) {}
  
  // 业务规则
  isCompliantWith(rule: RewardRule): boolean {
    // 验证是否符合当前奖励条目要求
  }
}



——

为什么领域事件更优？

1. 业务完整性

  ◦ 每个事件对应明确业务意义（如”已提交“≠”草稿保存“）

  ◦ 事件序列天然记录业务过程：创建→上传→保存→提交

2. 系统健壮性

flowchart LR
   故障点—>|系统崩溃| E[事件源]
   重新启动—> R[重放事件]
   恢复状态


  ◦ 事件溯源保证状态可重建

3. 扩展能力

新增审计需求时，只需监听已有事件：

eventBus.on(’ClaimSubmitted‘, (event) => {
  auditLog.record(
    `员工${event.employeeId}提交了${event.rewardEntryId}申请`
  );
});


4. 准确映射现实

  ◦ 与企业真实流程吻合：员工填写表单→系统创建记录→经理收到通知

  ◦ 事件时间戳精确记录业务发生时刻

这种定义方式使系统不再是CRUD操作的集合，而是对业务领域事件的精确反应，从根本上保证需求与实现的一致性和可追溯性。