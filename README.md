# 量潮管理后台

对内监控面板——以各种数据指标和验收方式为准，回答"我们跑得怎么样"。四分边界见 [AGENTS.md](AGENTS.md)。

围绕 journal / profile 等范畴与资产做指标展示——资产住 quanttide-tech `data/` 数据层，**禁止移入本仓**，本仓只作只读展示窗。

## 架构：业务域与职能域

| 层级 | 命名 | 例子 | 说明 |
|------|------|------|------|
| **业务域** | 带 `qt` 前缀 | `qtrecurit`（招聘）、`qtcloud`、`qtclass` | 面向具体业务线，内部复用多个职能域并编排组合 |
| **职能域** | 不带 `qt` 前缀 | `human`（人力资源）、`asset`（数字资产）、`connect`（沟通连接） | 可复用的职能能力层，被所有业务域调用 |

## 项目结构

| 模块 | 技术栈 | 状态 |
|------|--------|------|
| `src/studio/` | Flutter | 🟡 四屏（任务/评审/摩擦/角色，旧实体与定位不同物，去留未定） |
| `src/cli/` | Rust | 🟡 待决策（connect 已迁 qtcloud-connect，其余模块未定） |
| `src/provider/` | Go | 🟡 壳（config/store/health，领域 handler 已拆分至各仓 examples/） |
| `src/site/` | React + TypeScript | 🟢 展示站（定位与架构分层） |

## 领域去向

| 领域 | 产品线仓库 | 去向 |
|------|-----------|------|
| asset | `qtcloud-asset` | 产品线已有 CLI（scanner/workflow/validate） |
| business | `qtcloud-business` | 已迁（报价计算/商务总览） |
| connect | `qtcloud-connect` | 已迁（飞书邮件/聊天/通知 + extract 增强），本仓已移除 |
| human | `qtcloud-human` | 已迁（招聘计划/岗位管理） |
| knowl | `qtcloud-knowl` | 已合并至 `qtcloud-knowl/src/cli`（Rust 重构，含 acquire/extract-by-type/summary） |
| org | `qtcloud-org` | 已迁 |

