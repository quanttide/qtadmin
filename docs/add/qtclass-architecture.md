# qtclass 架构设计：内外部视角的统一

## 问题

量潮课堂目前有四个组成部分（校企合作、实训基地、内部教学、一对一），但在数据模型中它们只是四个并列的 `ComponentType` 枚举值。随着业务深化，这种扁平结构暴露出两个问题：

1. **外部实体无法建模**：学员、合作院校、企业客户这些真实世界的参与者没有对应的数据实体
2. **内部视角缺失**：不同客户群体（B2B 企业、B2C 个人、高校合作方）的需求和生命周期无法区分

## 内外视角的界定

### 外部视角：学员与机构

课堂的价值链两端是两类外部实体：

| 实体 | 定义 | 示例 |
|---|---|---|
| **学员 (Student)** | 直接接受教学/培训的个人 | 杭电参训学生、一对一学员、实训营学员 |
| **机构 (Organization)** | 与课堂有合作关系的组织 | 杭州电子科技大学、某企业客户、合作实训基地 |

外部实体是课堂服务的目标对象，它们**不登录 qtadmin**，但在课堂的业务流转中是被追踪的主体。

### 内部视角：客户群体

从内部管理角度，客户可按合作模式分层：

| 客户群体 | 典型特征 | 对应组成部分 |
|---|---|---|
| **B2B 企业** | 企业采购定制培训、按项目结算 | 校企合作、实训基地 |
| **B2C 个人** | 个人报名课程、按课时/课程付费 | 一对一、实训基地（个人通道） |
| **高校合作方** | 院校共建课程/专业、批量学生输送 | 校企合作 |
| **内部团队** | 公司内部知识分享、新人培训 | 内部教学 |

## 连接模型：Program 作为纽带

内外视角不应独立存在——孤立的学员列表和客户分组没有意义。关键在于**建立联系**。

引入 **Program（教学项目）** 作为核心连接实体：

```
外部实体                    Program                    内部视角
┌─────────┐              ┌──────────────┐            ┌──────────┐
│ 学员 A   │──────────▶   │              │            │ B2B 企业  │
├─────────┤   enrollment  │  Python实训   │────────▶  ├──────────┤
│ 学员 B   │──────────▶   │  (杭电校企)    │  contract │ 高校合作   │
├─────────┤   enrollment  │              │            ├──────────┤
│ 学员 C   │──────────▶   │              │            │ 个人学员   │
└─────────┘              └──────────────┘            └──────────┘
                              │
                              │ belongs_to
                              ▼
                     ┌──────────────────┐
                     │  ComponentType    │
                     │ (校企/实训/教学/一对一) │
                     └──────────────────┘
```

### 关键关系

- **Program 属于一个 ComponentType**：一条 Program 只能属于四个组成部分之一（如"杭电 Python 实训"属于"校企合作"）
- **Program 关联一个客户群体**：内部视角通过 Program 上的 `customerType` 字段标记
- **学员通过 Enrollment 加入 Program**：一个学员可参与多个 Program，一个 Program 有多个学员
- **机构通过 Partnership 关联 Program**：一个机构可合作多个 Program

### 数据模型示意

```
Program:
  id, name, componentType, customerType,
  startDate, endDate, status,
  partnerOrgId (FK → Organization),
  studentCount, revenue

Student:
  id, name, contact, source,
  createdAt

Enrollment:
  id, studentId (FK → Student), programId (FK → Program),
  enrollDate, status (active/completed/dropped)

Organization:
  id, name, type (university/enterprise/government),
  contactPerson, contactInfo

CustomerAccount (内部):
  id, organizationId (FK → Organization, nullable),
  customerType (b2b/b2c/university/internal),
  contractValue, lifetimeValue, status
```

## 设计原则

1. **一套模型，双重视角**：不分裂为两套 schema。Program 是桥接点，同时携带 componentType（外）和 customerType（内）。
2. **学员是独立实体，不是附属属性**：学员不属于某个机构或某个项目——一个学员可以先后参与校企合作、一对一、实训营。
3. **组织与客户解耦**：Organization（外部）和 CustomerAccount（内部）分开。同一个清华大学可以是校企合作方（external），也可以同时是企业采购方（internal B2B）。
4. **惰性演进**：当前阶段不需要完整的 CRM。先保证 Program + Student + Enrollment 可用，CustomerAccount 可以在有分析需求时再补。

## 当前边界

此设计是数据架构的蓝图。在当前版本的 UI 中（即已实现的 `QtClassScreen`），四个 ComponentType 仍然是并列展示的卡片。演进路线：

| 阶段 | 内容 |
|---|---|
| **v0.5（当前）** | 四个组成部分卡片展示，硬编码统计数据 |
| **v0.6** | Program 实体引入，学员管理界面 |
| **v0.7** | Enrollment 与 Organization 模型落地，内外关联打通 |
| **v1.0** | 客户群体分析仪表盘，Program 维度下钻 |

## 与现有架构的关系

- **多租户原则**：学员和机构数据不按租户分，所有租户共享同一套学员库（量潮的数据底座原则）
- **数据驱动**：新的 Program/Student/Organization 模型沿用 fixture JSON + Loader 模式，不引入数据库
- **不与 dashboard 耦合**：课堂的数据独立演进，不侵入 `DashboardData` / `dashboard.json`
