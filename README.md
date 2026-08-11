# 量潮管理后台

公司内部全面管理工具，覆盖各业务线与职能领域。

## 架构：业务域与职能域

| 层级 | 命名 | 例子 | 说明 |
|------|------|------|------|
| **业务域** | 带 `qt` 前缀 | `qtrecurit`（招聘）、`qtcloud`、`qtclass` | 面向具体业务线，内部复用多个职能域并编排组合 |
| **职能域** | 不带 `qt` 前缀 | `human`（人力资源）、`asset`（数字资产）、`connect`（沟通连接） | 可复用的职能能力层，被所有业务域调用 |

## 项目结构

| 模块 | 技术栈 | 状态 |
|------|--------|------|
| `src/studio/` | Flutter | 🟡 壳（导航框架 + 写作占位，领域已移交产品线） |
| `src/cli/` | Rust | 🟡 待决策（connect 已迁 qtcloud-connect，其余模块未定） |
| `src/provider/` | Go | 🟡 壳（config/store/health，领域 handler 已拆分至各仓 examples/） |

## 领域去向

| 领域 | 产品线仓库 | 去向 |
|------|-----------|------|
| asset | `qtcloud-asset` | 产品线已有 CLI（scanner/workflow/validate）；参考实现见 `examples/asset-api/` |
| business | `qtcloud-business` | CLI 已迁移至 `src/cli`（报价计算/商务总览） |
| connect | `qtcloud-connect` | CLI 已迁移至 `src/cli`（生产验证的飞书邮件/聊天/通知 + extract 增强），qtadmin 侧已移除 |
| human | `qtcloud-human` | CLI 已迁移至 `src/cli`（招聘计划/岗位管理）；参考实现见 `examples/human-api/`、`examples/recruitment-plan/` |
| knowl | `qtcloud-knowl` | 已合并至 `qtcloud-knowl/src/cli`（Rust 重构，含 acquire/extract-by-type/summary） |
| org | `qtcloud-org` | 参考实现见 `examples/org-implementation/` |

