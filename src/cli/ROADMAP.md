# ROADMAP — qtadmin CLI

qtadmin CLI 围绕**第二大脑结构**组织：四个二级子命令 `entity` / `domain` / `adapter` / `category`，每个下面按第二大脑现有结构再挂下一级——以社区第二大脑结构为基准做 API、以它为数据源、**以名词为主**。

- 设计正本：[`../../docs/dev-guide/cli.md`](../../docs/dev-guide/cli.md)
- 动机实录：`data/journal/default/2026-11-06.md`（前中后台分工、先显性化、用实践冲刷结构）
- 当前状态：0.0.17 空壳——64 行、零子命令；职能模块（human / business / asset / connect / knowl / share）已全部迁出至产品线仓

## 命令结构

| 二级命令 | 下一级示例 | 说明 |
|:--------:|-----------|------|
| `entity` | founder / company / alliance / academy | 主体 |
| `domain` | `data/` 等 | 领域 |
| `adapter` | `feishu/` 等 | 适配 |
| `category` | 按范畴结构挂，示例待定 | 范畴 |

## 版本目标

| 版本载体 | 当前版本 | 下一版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `Cargo.toml`、`CHANGELOG.md` | 0.0.17 | **0.1.0-alpha.1** | 四命令骨架落地；Cargo.toml 升 `0.1.0-alpha.1`，CHANGELOG 补条目，tag `cli/v0.1.0-alpha.1` |

版本发布规范见 `CONTRIBUTING.md`：单一数据源 `Cargo.toml`，标签 `cli/v<version>`；预发布从 alpha 起步。

## 路线

### 0.1.0-alpha.1 —— 四命令骨架（起点）

- clap 落地四个二级子命令：entity / domain / adapter / category，名词为主
- 每级下按第二大脑结构挂下一级（示例见上表；category 以范畴轴结构为准）
- 先显性化：结构不求一步正确，临时的东西也先挂上来——沿创始人探索出来的道路先上线
- 升版本、补 CHANGELOG、发 `cli/v0.1.0-alpha.1`

### alpha 迭代 —— 用实践冲刷结构

- 吸收来自各个地方的实践进各命令层级，把社区真实完整结构显性化
- 验证社区层面结构的一致点在哪；跑过的数据先静态化（存档案、放静态站，再进后台）

### 0.1.0 —— 结构定型

- 四命令与层级经冲刷后稳定，版本收敛发 `cli/v0.1.0`，标志探索期结束、进入上线推进

### 结构之后 —— 分解到职能

- 冲刷出结构后，再分解到各个职能上；CLI 保留执行入口与跨领域交叉编排
- 管理后台沿此逐渐变轻 = 系统演化分工的过程（后台接混乱 → 领域层标准化 → 前台输出）

## 历史

- 职能模块迁出：human → qtcloud-human、business → qtcloud-business、asset → qtcloud-asset、connect → qtcloud-connect、knowl → qtcloud-knowl
- share 模块（v0.0.17）：私仓代码脱敏发布公仓的工具链（已移除，规划见 git 提交 `244aa09`）
