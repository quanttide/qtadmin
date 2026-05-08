# qtclass 架构设计

## 问题

量潮课堂有四个组成部分（校企合作、实训基地、内部教学、一对一），当前数据模型中它们只是四个并列的 `ComponentType` 枚举值。这导致：

1. **外部实体无法建模**——学员、合作院校、企业客户这些真实参与者没有对应的数据实体
2. **内部视角缺失**——B2B 企业、B2C 个人、高校合作方等不同客户群体的生命周期无法区分
3. **内外割裂**——一个"杭电 Python 实训"项目同时关联了学员（外部）和客户合同（内部），但当前模型无法表达这种关联

## 可选方案

### 方案 A：独立双模型（学员 + 客户各一套）

```
Student (外部)              Customer (内部)
├── id                      ├── id
├── name                    ├── type (b2b/b2c/university/internal)
├── contact                 ├── contractValue
└── ...                     └── ...

 无直接关联 ←── 靠人工对账 ──→ 无直接关联
```

- 学员和客户各自独立 CRUD
- 内外通过人工报表对账，代码中无关联
- 四个 ComponentType 作为枚举字段散落在两边

### 方案 B：客户归附属性的扁平模型

```
class Project {
  String name;
  ComponentType type;
  List<String> studentNames;  // 学员名字列表（非独立实体）
  String customerType;
  int contractValue;
}
```

- 学员信息直接挂在项目上，不独立建模
- 客户类型是项目上的一个枚举字段

### 方案 C：Program 桥接模型（选定方案）

```
Student ──enrollment──▶ Program ──customerAccount──▶ CustomerAccount
```

- Program 居中，分别关联 Student（外部）和 CustomerAccount（内部）
- 内外通过 Program 打通，但数据结构分离

## 方案对比

| 维度 | A：独立双模型 | B：扁平属性 | C：Program 桥接 |
|---|---|---|---|
| **内外关联能力** | 无，人工对账 | 隐式（学员在项目字段里） | 显式（Program 双向关联） |
| **学员独立性** | ✓ 可跨项目跟踪 | ✗ 学员不是独立实体 | ✓ 可跨项目跟踪 |
| **客户类型扩展** | ✓ 可独立演进 | ✗ 新增类型改 schema | ✓ 通过 CustomerAccount |
| **实现成本** | 高（两套 CRUD） | 低（字段堆叠） | 中（三个核心模型） |
| **查询复杂度** | 内外分开查简单，合起来难 | 单表简单 | 三表关联，中等 |
| **冗余风险** | 低 | 高（学员数据重复） | 低 |
| **阶段可交付** | 必须一次性完整实现 | 可逐步加字段 | 可分阶段落地 |

## 选定方案：C（Program 桥接）

**理由：**

1. **学员独立性是业务刚需**——一个人可以先后参加校企合作实训、一对一辅导、实训营，方案 B 无法表达这种跨项目的学员轨迹
2. **内外不需要统一 schema**——学员的关注点（学习记录、成绩）和客户的关注点（合同、金额）完全不同，方案 A 试图统一是过度设计
3. **Program 是天然的连接点**——业务流转的真实聚合根是"项目"而非"学员"或"客户"，以 Program 为中心符合业务认知
4. **可分阶段落地**——先落 Program + Student，再落 CustomerAccount，不会阻塞业务

### 数据模型

```
Program:
  id, name, componentType (enum), startDate, endDate, status
  customerAccountId (FK → CustomerAccount, nullable)

Student:
  id, name, contact, source, createdAt

Enrollment:
  id, studentId (FK → Student), programId (FK → Program)
  enrollDate, status (active/completed/dropped)

Organization:
  id, name, type (university/enterprise/government)
  contactPerson, contactInfo
  // 外部实体，不区分客户类型

CustomerAccount:
  id, organizationId (FK → Organization, nullable)
  customerType (b2b/b2c/university/internal)
  contractValue, lifetimeValue, status
  // 内部视角，与 Organization 解耦
```

## Trade-offs 与边界

### 已知取舍

| 取舍 | 选择 | 代价 |
|---|---|---|
| 学员独立性 vs 项目封闭 | 学员独立建模，跨项目可追踪 | 查询时需要 join Enrollment 中间表 |
| 组织与客户解耦 vs 简化 | Organization（外）与 CustomerAccount（内）分开 | 同一所大学作为合作方+采购方时需要两条记录 |
| 阶段交付 vs 一步到位 | 先落 Program+Student，CustomerAccount 后补 | v0.6 阶段无法做客户维度分析 |

### 不解决的问题

- **支付与订单**：不涉及学员付费、企业开票等资金流，这部分由财务模块覆盖
- **课程内容管理**：课件、教材、作业等教学内容的建模不在本设计范围内
- **实时数据同步**：学员进度、出勤等实时数据不在 fixture JSON 的范畴内，需要时引入数据库
- **权限与租户隔离**：学员数据是否按租户隔离、合作院校是否可以查看自己学员的进度——这些是后续的权限设计问题

### 重新审视时机

当以下条件之一满足时，应重新评估此设计：

- 需要做学员端的独立 App/小程序
- 需要接入支付系统
- 单项目学员数超过 1000 人，fixture JSON 加载模式无法满足

## 演进路线

| 阶段 | 内容 | 交付物 |
|---|---|---|
| **v0.5** | 四个组成部分卡片展示 | QtClassScreen + fixture（已实现） |
| **v0.6** | Program + Student 模型落地 | 学员 CRUD、Program 管理界面 |
| **v0.7** | Enrollment + Organization 打通 | 内外关联可视化 |
| **v1.0** | CustomerAccount + 分析仪表盘 | 客户群体下钻、LTV 分析 |

## 相关文档

- `docs/drd/qtclass.md` — QtClassData / QtClassComponentData 数据 schema
- `docs/drd/metadata.md` — pageType 路由表
