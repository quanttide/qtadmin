# qtclass 架构设计

## 问题

量潮课堂的四个组成部分（校企合作、实训基地、内部教学、一对一）在数据模型中只是四个枚举值。没有课程、没有学员、没有合作方——只有几张卡片和硬编码的统计数字。

之前的方案设计了 Program 作为连接内外视角的桥接实体，但 Program 试图同时承载课程属性、客户属性、合作方属性，导致职责不清：

```
// 旧方案：Program 承担了太多职责
Program:
  name              ← 课程名称
  componentType     ← 交付模式
  customerType      ← 客户类型（跨领域）
  partnerOrgId      ← 合作方（跨领域）
  startDate         ← 课程时间
  studentCount      ← 学员统计
  revenue           ← 财务数据
```

一个实体横跨课程、组织、财务三个领域，既不是课程、也不是合同、也不是学员——什么都不是。

## 领域拆分

将课堂业务划分为两个独立领域，通过**交付模式**建立关联：

```
┌─────────────────────────────────────────────────┐
│                  课程领域                          │
│  (教什么、怎么教、谁来教)                           │
│                                                   │
│  Course ──has──▶ Class ──has──▶ Session           │
│    │              │                                │
│    └── syllabus   └── teacher, schedule            │
└────────────────────┬──────────────────────────────┘
                     │ 交付模式
                     ▼ (校企/实训/内部/一对一)
┌────────────────────┴──────────────────────────────┐
│                  组织领域                          │
│  (谁学、谁合作、谁付费)                            │
│                                                   │
│  Student ──enrolls──▶ Enrollment                    │
│  Organization ──partners──▶ Partnership            │
│  Customer ──contracts──▶ Contract                  │
└─────────────────────────────────────────────────┘
```

### 课程领域（Course Context）

关注教学内容和交付过程，不关心谁来买单：

| 实体 | 职责 | 示例 |
|---|---|---|
| **Course** | 课程定义，稳定的教学单元 | "Python 数据分析" |
| **Class** | 课程的一次具体开课 | "杭电 2026 春 Python 实训班" |
| **Session** | 单次授课 | "3月15日 14:00-16:00 函数式编程" |
| **Teacher** | 授课人 | "王老师" |
| **Syllabus** | 教学大纲，知识点结构 | 8 个章节、3 个实践项目 |

### 组织领域（Organization Context）

关注参与者关系和商业合同，不关心教学细节：

| 实体 | 职责 | 示例 |
|---|---|---|
| **Student** | 学员个人信息与学习轨迹 | 可跨多个 Class 跟踪 |
| **Organization** | 外部合作机构（院校/企业） | "杭州电子科技大学" |
| **CustomerAccount** | 内部客户视图，关联合同 | B2B / B2C / 高校 / 内部 |
| **Contract** | 商业合同，约定金额与交付范围 | "杭电 Python 实训合同 ¥120,000" |

## 交付模式：两个领域的连接点

四个组成部分不是领域实体，而是**交付模式（DeliveryMode）**——描述课程以何种方式交付给组织侧的参与者：

```
                  课程端                              组织端
    ┌─────────────────────────┐         ┌─────────────────────────┐
    │  Course: Python 数据分析  │         │  Organization: 杭电      │
    │  Class: 2026春实训班     │──交付模式──│  Student: 张三、李四...   │
    │  Teacher: 王老师         │  校企合作  │  Contract: ¥120,000     │
    └─────────────────────────┘         └─────────────────────────┘
```

### DeliveryMode 的定义

```
DeliveryMode:
  id, name                  // 如 "校企合作"
  code                      // schoolEnterprise / trainingBase / internalTeaching / oneOnOne
  constraints:              // 该模式的约束规则
    - requiresPartner       // 是否需要合作方
    - maxStudents           // 最大学员数
    - billingModel          // 按项目 / 按课时 / 按人头
```

交付模式是一个**配置级的枚举**，不是实体——它不单独存储业务数据，而是为 Class 和 Contract 提供约束规则。新增交付模式只需加一行配置 + fixture，不改代码。

## 关键关系

```
组织侧                                    课程侧
Organization ──▶ Contract ──▶ Class ──▶ Course
                    │            │
                    │            └── DeliveryMode(code)
                    │
                    ▼
              Enrollment
                    │
                    ▼
                Student
```

- **Contract 连接组织与课程**：一份合同约定了一个 Org 对某个 Class 的购买。合同上有金额、交付物、时间线
- **Enrollment 连接学员与课程**：学员报名某个 Class。一个学员可以报名不同的 Class
- **DeliveryMode 是 Contract 上的一个属性**：合同签订时即确定以什么模式交付
- **Class 本身不感知组织**：同一个 Class 可以被不同的 Contract 覆盖（如企业包班 + 个人散招混合）

## 与之前方案的区别

| | 旧方案（Program 桥接） | 新方案（领域分离） |
|---|---|---|
| 核心实体 | Program（模糊聚合） | Course / Class / Contract（职责明确） |
| 领域边界 | 无，所有字段揉在一个模型里 | 课程域 ↔ 组织域通过 Contract 连接 |
| 交付模式 | ComponentType 是枚举，无约束 | DeliveryMode 是配置，可约束行为 |
| 学员跟踪 | 通过 Enrollment 挂在 Program 下 | 通过 Enrollment 挂在 Class 下，更细粒度 |
| 合同管理 | 无独立 Contract 实体 | Contract 显式建模，连接组织与课程 |
| 扩展性 | 新增模式改枚举 | 新增模式加 DeliveryMode 配置行 |

## 设计规则

1. **课程域不引用组织域**——Class 不知道谁买单，Course 不知道谁在学习。课程只关心教学本身。
2. **组织域不引用课程内容**——Contract 不知道 syllabus 是什么，Student 不关心教学大纲。组织只关心参与关系和商业条款。
3. **交付模式是配置，不是实体**——四种交付模式的定义从 fixture 加载，不编译在代码里。新增模式只需加 JSON。
4. **数据驱动 + 惰性演进**——当前 v0.5 仍是卡片展示。v0.6 先落 Course + Class（课程域），v0.7 再落 Contract + Enrollment（组织域）。两个领域可以不同步上线。

## Trade-offs

| 取舍 | 选择 | 代价 |
|---|---|---|
| 领域独立 vs 查询便利 | 两域物理分离 | 跨域查询需要关联 Contract |
| Contract 作为连接点 vs Enrollment 直接连接 | Contract 居中，更贴近真实业务 | 多一次 join |
| 交付模式配置化 vs 硬编码 | JSON 配置，运行时加载 | 校验逻辑需提前定义 |
| 分领域落地 vs 一次性建模 | 课程域优先，组织域延后 | 短期无法回答"这个客户赚了多少钱" |

## 不解决的问题

- **教学质量管理**：评分、反馈、作业批改——这些属于教学评估领域，不在课程域和组织域内
- **排课与资源调度**：教室、设备、时间冲突检测——独立的排课模块
- **支付与发票**：资金流不属于课堂的领域边界
- **学员端**：学员查看课程表、成绩的独立入口——需要时作为独立 bounded context 引入

## 演进路线

| 阶段 | 课程域 | 组织域 | 交付物 |
|---|---|---|---|
| **v0.5** | 卡片展示 | — | QtClassScreen（已实现） |
| **v0.6** | Course + Class + Session | — | 课程管理 CRUD |
| **v0.7** | — | Student + Organization | 学员与机构管理 |
| **v0.8** | — | Contract + Enrollment | 内外关联打通 |
| **v1.0** | Teacher + Syllabus | CustomerAccount | 教学管理与客户分析 |
