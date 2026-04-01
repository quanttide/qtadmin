# Asset Audit 运维文档

## 命令

```bash
# 审计当前目录
qtadmin asset audit

# 审计指定仓库
qtadmin asset audit /path/to/repo

# 显示详细信息（包含通过的项目）
qtadmin asset audit -v
```

## 检查项目

### 1. 必需文件检查

| 文件 | 说明 |
|------|------|
| README.md | 项目概述、目录结构 |
| CONTRIBUTING.md | 贡献指南、工作流、环境变量 |
| AGENTS.md | Agent 导航 |
| CHANGELOG.md | 版本历史 |
| .gitignore | Git 忽略规则 |

### 2. 可选目录检查

| 目录 | 说明 |
|------|------|
| meta/ | 元数据目录 |

### 3. 内容规范检查

#### README.md
- 项目简介
- 目录结构
- 快速开始指南

#### CONTRIBUTING.md
- 项目结构
- 开发环境
- 提交规范
- 发布流程

#### AGENTS.md
- 行数 ≤ 100 行（建议 ~50 行）
- 包含使用场景表格
- 包含快速索引
- 包含「如何更新 AGENTS.md」说明

#### CHANGELOG.md
- # Changelog 标题
- 语义化版本号 (vX.Y.Z)
- 分类标题 (### Added/Changed/Fixed/Removed)

#### .gitignore
- 至少包含 2 个常见规则
- 推荐：.venv, __pycache__/*.pyc, .env 等

### 4. 子模块检查
- 检查 .gitmodules 配置
- 检查是否有未推送的子模块提交

### 5. 提交规范检查
- 最近 10 条提交信息
- 符合 Conventional Commits 格式（至少 50%）
- 格式：`<type>: <description>`

## 输出示例

```
============================================================
Git 仓库资产审计报告
============================================================
仓库路径：/path/to/repo
审计结果：7/10 通过 (70.0%)
------------------------------------------------------------

❌ 未通过项目:

  [必需文件：CONTRIBUTING.md]
  缺少 CONTRIBUTING.md
  💡 建议：创建 CONTRIBUTING.md 文件

  [必需文件：.gitignore]
  缺少 .gitignore
  💡 建议：创建 .gitignore 文件

  [AGENTS.md 内容规范]
  需要优化 (共19行)
  💡 建议：保持简洁 (~50 行)，添加使用场景表格、快速索引，以及「如何更新 AGENTS.md」的说明

  [提交规范符合度]
  0/10 符合 Conventional Commits (0%)
  💡 建议：使用 `cz commit` 创建规范提交，或手动遵循 <type>: <description> 格式

============================================================
⚠️  审计未通过，请根据建议修复问题
```

## 修复建议

### 创建 CONTRIBUTING.md

```markdown
# CONTRIBUTING

## 项目结构

## 开发环境

## 提交规范

## 发布流程
```

### 创建 .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
.venv/
.env

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

### 优化 AGENTS.md

参考模板：

```markdown
# AGENTS.md - Agent 工作指南

## 快速索引

| 场景 | 命令/操作 |
|------|----------|
| ... | ... |

## 使用场景

### 1. 文档更新
...

## 工作原则

1. **最小干预**: ...
...

## 如何更新 AGENTS.md

...
```