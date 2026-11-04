# Agent Guidelines for qtadmin

> **必读：** 先读 `CONTRIBUTING.md`、`README.md`、`ROADMAP.md`。README 定位段与本文件一致；`src/site/` 自述仍是旧定位，**以本文件定位节为准**。

## 定位：监控面板

qtadmin 是量潮体系的**对内监控面板**——以各种数据指标和验收方式为准，回答"我们跑得怎么样"。

四分边界（谁的归谁，本仓不越界收留）：

| 内容 | 归属 |
|------|------|
| 对外内容（公司是谁、业务、新闻、招聘） | qttech（官网 quanttide.com） |
| 制度与身份的档案文本 | 各主体仓（`defaults/*`） |
| 领域运营（人力、商务、资产、连接、知识……） | 产品线仓库（qtcloud-* 等，去向见 README 领域去向表） |
| **数据指标与验收状态** | **qtadmin** |

- **判断口径**：面板上的每个数都可追溯到指标来源或验收结论——数据指标与验收方式作数，叙事不作数
- **围绕的资产**：journal / profile 等记录与状态——住 quanttide-tech `data/` 数据层，**禁止移入本仓**；本仓是它们的只读展示窗
- **历史教训**：仪表盘曾因"无数据活水源"被整体移除（见 `src/studio/CHANGELOG.md`）——**数据活水源先于界面**，没有稳定指标来源不立面板

## 现状

- `src/studio/`：现存摩擦 / 任务 / 角色 / 评审四屏是旧治理操作台实体，与监控面板定位不同物，**去留未定**——未获指令前不动。开发原则与架构约定见 `src/studio/AGENTS.md`，在 studio 下工作必须先读
- `src/site/`：React 展示站（🟢，自述待修正）
- `src/provider/`：Go 壳（config / store / health）
- `src/cli/`：Rust 壳，待决策（connect 已迁 qtcloud-connect，其余模块未定）
- 领域已全部迁出，本仓**不回收**——领域去向表见 README

## 子模块操作注意事项

qtadmin 是 `quanttide-tech` 仓库的子模块。操作时可能遇到 detached HEAD 状态：

- 提交后推送用 `git push origin HEAD:main`
- 不要用 `git -C` 直接操作，优先用 `cd apps/qtadmin && git ...`
