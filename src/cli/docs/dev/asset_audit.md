# Asset Audit 开发文档

## 模块概述

Git 仓库资产审计模块，检查仓库是否符合标准资产体系规范。

## 检查项目

| 检查项 | 说明 |
|--------|------|
| 必需文件 | README.md, CONTRIBUTING.md, AGENTS.md, CHANGELOG.md, .gitignore |
| 可选目录 | meta/ |
| README 内容 | 项目简介、目录结构、快速开始 |
| CONTRIBUTING 内容 | 项目结构、开发环境、提交规范、发布流程 |
| AGENTS 内容 | 简洁（≤50行）、使用场景表格、快速索引、自我更新说明 |
| CHANGELOG 格式 | 语义化版本格式，有版本号和分类标题 |
| .gitignore 规则 | 至少包含 2 个常见规则 |
| 子模块状态 | 配置正确且已推送 |
| 提交规范 | 最近 10 条提交至少 50% 符合 Conventional Commits |
| 版本发布一致性 | CHANGELOG 和 pyproject.toml 版本一致，且有版本提交 |

## 提交规范正则

```python
r'^(feat|fix|docs|test|refactor|chore|style|perf)(\([a-z0-9-]+\))?:\s.+'
```

支持格式：
- `type: description`
- `type(scope): description`

## 版本发布一致性检查

检查逻辑：
1. 提取 `pyproject.toml` 中的版本号
2. 验证 `CHANGELOG.md` 中是否有对应版本记录
3. 检查最近提交中是否有版本发布相关提交（bump/version tag）

## 已知问题

| 问题 | 状态 |
|------|------|
| 默认路径处理 | 待修复 |
| 缺少自动修复功能 | 待开发 |
