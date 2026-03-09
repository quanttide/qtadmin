# 产品需求文档

## 用途

本目录用于管理 qtadmin 的产品需求，当前聚焦 QuantTide 第二大脑方向。

## 工作流

`docs/default -> docs/prd -> docs/meta`

- `default`：收集想法
- `prd`：重组为可执行需求
- `meta`：项目级总结与阶段判断

## 目录约定

- `README.md`：流程与维护规则
- `index.md`：当前 PRD 内容总览
- `archive/`：历史版本或已降级内容

## 维护规则

1. 新增需求先落在 `second_brain_mvp.md` 或 `second_brain_module_requirements.md`
2. 可交付故事统一放到 `stories/`
3. 不再作为当前范围的内容移动到 `archive/`
4. 每次结构调整同步更新 `_toc.yml` 与 `index.md`
