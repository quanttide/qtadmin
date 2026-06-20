# Agent Guidelines for qtadmin

> **必读：** 先读 `CONTRIBUTING.md`、`README.md`、`ROADMAP.md`。

## Project Overview

qtadmin 是 QuantTide 的第二大脑平台。当前重心在 Flutter 客户端（`src/studio/`），后端（`src/provider/`）处于维护状态。CLI（`src/cli/`）是数字资产管理工具，持续迭代。

## CLI — asset 模块结构

`src/cli/src/asset/` 当前有三个子命令，AI 需要理解它们的区别：

| 命令 | 功能 | 性质 |
|------|------|------|
| `archive` | 将 journal 日志归档到 archive | 操作 |
| `status` | 结构合规检查（文件是否存在、格式正确、提交规范） | pass/fail |
| `quality` | 语义质量评估（叙事/知识/认知三维度，调用 LLM 打分） | 评分 |

注意不要混淆：`status` 做结构检查（规则驱动），`quality` 做语义评估（LLM 驱动）。

## quality 命令的来源

quality 的逻辑最初在实验室 `examples/default/examples/p40-evaluate.py`（Python + DeepSeek API）验证，后移植为 Rust 实现。AI 应直接修改 Rust 代码（`src/cli/src/asset/quality.rs`），不再依赖 Python 脚本。

## Studio

重心所在。所有开发原则、经验教训、架构约定见 `src/studio/AGENTS.md`。代理在 studio 下工作时必须先读。

## Provider（维护态，已重构为 Go）

## 子模块操作注意事项

qtadmin 是 `quanttide-tech` 仓库的子模块。操作时可能遇到 detached HEAD 状态：

- 提交后推送用 `git push origin HEAD:main`
- 不要用 `git -C` 直接操作，优先用 `cd apps/qtadmin && git ...`

## 实验→工程化管线

从可用到结构化的标准路径：

1. **实验** → `examples/default/examples/`（Python，验证概念）
2. **工程化** → `apps/qtadmin/src/cli/`（Rust，稳定实现）
3. **文档化** → `docs/handbook/asset/`（方法手册，不写工具细节）

AI 在接手新功能时，应优先确认是否有实验室代码可移植，而非从零实现。
