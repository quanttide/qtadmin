# activity qtclass —— 量潮课堂管理单元 API

量潮课堂管理单元的命令行 API。业务需求正本：[`docs/intro/activity/qtclass.md`](../../../../../docs/intro/activity/qtclass.md)（业务意图、核心痛点、业务愿景、业务边界四节），本文是它的 API 形态。

状态：0.1.0-alpha.2 骨架——`qtadmin activity qtclass` 已挂，数据源（飞书多维表格）未接。

## 定位

过渡期的数据抽离与状态映射通道：把飞书多维表格的报名与支付数据原样搬进量潮后台，生成内部订单；自研收款系统上线后原地切换数据源，从「同步工具」升级为「订单管理中心」。

它是「神经中枢」的第一段，不是业务系统本身——只做数据抽离，不做业务篡改。

## 命令

| 命令 | 说明 | 对应断点 |
|------|------|----------|
| `qtadmin activity qtclass sync` | 飞书多维表格报名/支付 → 内部订单，只读抽离 | 数据孤岛 |
| `qtadmin activity qtclass order list` | 内部订单列表（状态、金额、来源单号） | 状态黑盒 |
| `qtadmin activity qtclass order get <id>` | 单笔订单详情与状态轨迹 | 状态黑盒 |
| `qtadmin activity qtclass delivery check` | 飞书群链接有效期检查，输出将过期清单 | 交付割裂 |
| `qtadmin activity qtclass status` | 管理单元总览：最近一次同步、订单状态分布、待处理提醒 | 神经中枢 |

当前骨架只挂到 `qtadmin activity qtclass`（输出诚实标注）；上表子命令为设计稿，随数据源接入逐个落地。

## 数据对象

| 对象 | 来源 | 去向 | 说明 |
|------|------|------|------|
| enrollment（报名） | 飞书多维表格 | 内部订单行 | 学员、班次、报名时间，原样搬运 |
| payment（支付） | 飞书多维表格 | 内部订单行 | 金额、支付时间、退款标记 |
| order（订单） | 本系统生成 | `order` 查询 | enrollment + payment 经字段映射后的内部表示 |
| delivery_link（交付链接） | 飞书群 | `delivery check` | 群链接与有效期，仅检查与提醒 |

## 状态映射（设计稿）

内部订单状态：

| 状态 | 含义 | 触发 |
|------|------|------|
| `pending` | 已报名未支付 | 报名记录存在、无支付记录 |
| `paid` | 已支付 | 飞书多维表格支付成功 |
| `refunded` | 已退款 | 飞书多维表格退款完成 |

飞书多维表格侧字段取值待接入时以实际接口为准。映射只做翻译，不推断、不补写——拿不到的状态进 `unknown` 并报警，不猜。

## API 承诺（对应业务边界）

- **只读不写**：过渡期只从飞书多维表格拉数据，不向飞书多维表格写任何东西，避免数据冲突
- **原样搬运 + 字段映射**：不修改原始业务逻辑，映射规则只翻译不改义
- **容错优先**：网络超时、字段缺失记日志并报警，单条失败不中断整体；跑完输出失败汇总

## 数据源

飞书多维表格（接入方式待定，当前未接；接入路径经 `adapter feishu` 轴）。自研收款系统上线后在此切换数据源，命令面不变。

## 相关

- 设计正本：[`docs/dev-guide/cli.md`](../../../../../docs/dev-guide/cli.md)
- 路线：[`src/cli/ROADMAP.md`](../../../ROADMAP.md)
- 业务需求正本：[`docs/intro/activity/qtclass.md`](../../../../../docs/intro/activity/qtclass.md)
