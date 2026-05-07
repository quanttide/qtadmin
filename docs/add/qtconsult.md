# 量潮咨询模块数据模型

## 状态

草案

## 上下文

量潮咨询是量潮科技四条业务线之一，核心工作流是"梳理客户情况 → 制定咨询策略"的持续循环。同时，量潮咨询有**两个租户**：

- **客户租户**：量潮科技对外交付咨询项目，数据来源于客户沟通
- **内部租户**：创始人或量潮科技用量潮咨询观察自身，数据来源于量潮云

两个租户共享同一套交互框架和"发现→策略"机制，区别在于数据源和观察立场。内部租户是获得外部视角的结构化手段。

现有全景图仅展示决策卡片层级的信息，无法承载咨询项目所需的深度信息管理。

需要一个独立的数据模型来支撑咨询详情页的双栏联动（信息看板 + 策略看板），核心机制是发现自动触发策略审视。

## 设计驱动

1. **发现→策略强制联动**：每一条关键发现都应触达策略侧，不让信息沉淀在纪要里
2. **全程一致性**：同一数据模型贯穿接洽/方案/交付/复盘四个阶段，不退场
3. **离线可用**：初期以静态 JSON 加载，不依赖后端
4. **与全景图解耦**：咨询详情页的数据独立性，不侵入全景图的数据结构

## 设计

### 数据模型

```
QtConsultData
├── 租户信息        tenant: "customer" | "internal"
├── 项目元信息      projectName, phase, industry, scale, maturity
├── 策略内容        strategyGoal, strategyInsight, strategySteps, riskNote
├── discoveries[]  发现清单，可增删改，支持状态流转
├── communications[] 沟通记录，只读索引
├── revisions[]    策略修正历史，由发现自动触发追加
└── stakeholders[] 决策链路，每人含立场和应对策略
```

**tenant** 字段决定数据源行为：
- `customer`：发现和沟通记录由顾问手动输入（客户提供的信息）
- `internal`：发现清单初始来源于量潮云的领域层数据，创始人在此基础上做观察和判断。沟通记录为空（没有外部客户）

### 核心实体

**DiscoveryData（发现）**

| 字段 | 类型 | 约束 |
|------|------|------|
| id | String | PK |
| text | String | 描述具体事实 |
| type | DiscoveryType | risk / concern / opportunity / neutral |
| status | DiscoveryStatus | pending → confirmed / dismissed |
| source | String | 来源会议 |
| linkedToStrategy | bool | 高风险/需关注类型自动标记为 true |

**StrategyRevisionData（策略修正）**

| 字段 | 类型 | 约束 |
|------|------|------|
| id | String | PK |
| relatedDiscoveryId | String? | FK → DiscoveryData.id |
| isReviewed | bool | 默认 false，顾问确认后置 true |

### 数据流

```
assets/qtconsult.json
    │ QtConsultLoader.load()
    ▼
QtConsultScreen State
    │ discoveries: List<DiscoveryData>    ← mutable
    │ revisions:  List<StrategyRevisionData>  ← mutable
    │
    ├── addDiscovery(type=risk|concern)
    │   └── revisions.unshift(pending_review)
    │
    ├── confirmDiscovery / dismissDiscovery
    │   └── discovery.status = confirmed | dismissed
    │
    └── markRevisionReviewed
        └── revision.isReviewed = true
```

### 联动规则

```
发现类型         → 策略侧响应
──────────────────────────────
risk            → 追加待审视记录 + 统计栏 badge + 面板高亮
concern         → 追加待审视记录 + 提示
opportunity     → 仅记录，不触发策略审视
neutral         → 仅记录，不触发策略审视
```

### 状态流转

```
发现: 待确认(pending) → 已确认(confirmed)
                    ↘ 已驳回(dismissed)

修正: 待审视(isReviewed=false) → 已审视(isReviewed=true)
```

## 与量潮云的关系（内部租户）

内部租户的量潮咨询与量潮云的关系是**观察者与被观察者**：

- 量潮云提供公司运营的领域层数据（项目状态、财务指标、产能等），这是"被观察者"的自我陈述
- 量潮咨询（内部租户）读取这些数据作为"发现清单"的初始内容，创始人以此为基础做独立判断

两个平台共享同一套底层领域模型（项目、财务、人力等），但量潮咨询在其上叠加了"发现→策略"的咨询层数据结构。内观（量潮云）和外观（内部租户的量潮咨询）操作的是同一领域层，视角不同产生的偏差就是调整信号。

具体的数据关系：

```
量潮云领域层（公司自述）
    │  QtConsultLoader.load(tenant="internal")
    │  将量潮云数据投射为初始发现清单
    ▼
量潮咨询内部租户（独立观察）
    ├── discoveries[]  初始来源于量潮云，创始人可补充/修正
    ├── revisions[]    基于发现的策略审视记录
    └── stakeholders[] 公司内部利益相关者立场
```

## 备选方案

| 方案 | 选否理由 |
|------|----------|
| 将咨询数据嵌入 panorama.json | 全景图数据结构不同，混合后增加解析复杂度 |
| 使用后端 API 实时加载 | 当前无后端基础设施，静态 JSON 可先行验证交互 |
| 使用 SQLite 本地存储 | 原型阶段过度设计，JSON + 内存状态足够 |

## 影响

正面：
- 数据模型与 UI 联动逻辑一一对应，降低理解成本
- 发现→策略的强制联动在数据层面得到保障
- 静态 JSON 加载模式与全景图一致，开发心智负担小

限制：
- 运行时修改不持久化，刷新页面后重置（当前阶段可接受）
- 所有项目共享同一套字段结构，特殊项目无法扩展个性化字段
- 内部租户初始发现清单依赖量潮云的数据投射接口，该接口尚未定义
