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
- `_toc.yml`：文档导航（root 为 `index.md`）

## 维护规则

1. `index.md` 必须作为 PRD 内容入口，并在 `_toc.yml` 中作为 root
2. 新增需求优先合并到 `index.md` 的对应章节
3. 每次结构调整同步更新 `_toc.yml` 与 `index.md`
