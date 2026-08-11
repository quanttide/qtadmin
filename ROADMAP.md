# ROADMAP — qtadmin 工作蓝图

qtadmin 是企业治理思想和制度的平台化载体，展示的不是功能，是治理方法。路线图服务于治理主题（asset、delib、execute、strategy）的落地，当前重点是执行环节的评审闭环。

## 阶段现状

分化已完成：业务域（qtclass、qtcloud、qtconsult、qtdata、qtrecurit）全部归位各平台仓库，CLI 收敛为五个职能域命令（asset、business、connect、human、knowl）。asset 已落地，delib 与 strategy 仍零实现。Studio 有 org、qtconsult、recruitment 三个历史业务屏，router 存在死引用，治理可视化空白。

## 版本目标

版本目标与 `qtcloud-devops` 工具对齐：无历史 tag 时工具候选版本为 `scope/v0.1.0`，有 tag 时候选为最新 tag 的 patch+1。已独立演进的 scope（studio）以现状版本对齐，不降版本。

| scope | 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:------|:--------:|:--------:|:--------:|----------|
| root | `pyproject.toml`、`CHANGELOG.md` | 0.1.1 | v0.1.1 | 已就绪，待发首个 tag |
| cli | `src/cli/Cargo.toml`、`src/cli/CHANGELOG.md` | 0.0.17 | cli/v0.1.0 | Cargo.toml 升 0.1.0，CHANGELOG 补 [0.1.0] 条目 |
| studio | `src/studio/pubspec.yaml`、`src/studio/CHANGELOG.md` | 0.1.3 | studio/v0.1.3 | 已就绪，待发首个 tag |
| provider | `src/provider/internal/version/version.go`、`src/provider/CHANGELOG.md` | 0.0.1 | provider/v0.1.0 | version.go 升 0.1.0，CHANGELOG 补 [0.1.0] 条目 |

版本规则：

- root 标签使用纯版本号 `vX.Y.Z`，不带 scope 前缀；scope 标签使用 `scope/vX.Y.Z` 格式
- cli 与 provider 从 0.0.x 升到 0.1.0，标志探索期结束、进入上线推进阶段
- 发布命令：`qtcloud-devops release publish -v <目标版本>`

## 阶段规划

### 版本收敛（v0.1.x）

补齐 cli 与 provider 的 0.1.0 对齐（版本载体 + CHANGELOG），完成 root、cli、studio、provider 四个 scope 的首轮发布，让发布审计全绿。

### 执行环节（v0.2.x）

- 评审闭环 MVP：角色槽位分配、评审节点、评审留痕、摩擦登记（对齐意图 execute 演化近期与 insight review-path）
- 评审即制度修订：打回原因聚类、标准库（摩擦生成标准）

### 治理可视化（v0.3.x）

- 清理 router 死引用，确认可构建
- asset 可视化起步：读取 CLI 数据文件做资产治理可视化，落地双端共享
- 评审工作台与责任链看板可视化

### 支柱补齐（v0.4.x）

- delib 载体：议事记录与决策留痕的最小闭环
- strategy 载体：假设库结构化，事实审计加反事实推演
- 封装边界：AI 产出必须可落地，落不了地的产出是债务，不进入封装

## 各 scope 路线

- cli：版本目标与执行入口见 [src/cli/ROADMAP.md](./src/cli/ROADMAP.md)
- studio：版本目标与可视化路线见 [src/studio/ROADMAP.md](./src/studio/ROADMAP.md)
- provider：维护态，版本目标见 [src/provider/ROADMAP.md](./src/provider/ROADMAP.md)
