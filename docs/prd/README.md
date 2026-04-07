# 产品需求文档

## 用途

本目录用于管理 qtadmin 的产品需求，当前聚焦 QuantTide 第二大脑方向。

## 产品工作流程

`prd -> add -> qa`

- **prd**：产品需求定义
- **add**：架构设计与实现
- **qa**：验收确认

## 目录约定

- `README.md`：流程与维护规则
- `index.md`：当前 PRD 内容总览
- `<module>.md`：各模块详细需求
- `_toc.yml`：文档导航（root 为 `index.md`）

## 维护规则

1. `index.md` 必须作为 PRD 内容入口，并在 `_toc.yml` 中作为 root
2. 新增需求优先合并到 `index.md` 的对应章节
3. 每次结构调整同步更新 `_toc.yml` 与 `index.md`

## 文档规范

其他文档按角色分类：
- `docs/dev/`：开发文档（技术规范、API 文档）
- `docs/ops/`：运维文档（部署、维护）