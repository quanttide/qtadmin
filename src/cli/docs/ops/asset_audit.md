# Asset Audit 问题排查

## 2026-04-01 审计结果

运行 `qtadmin asset audit` 在 quanttide-tech 仓库的审计结果：

```
============================================================
Git 仓库资产审计报告
============================================================
仓库路径：/home/iguo/repos/quanttide-tech
审计结果：7/10 通过 (70.0%)
------------------------------------------------------------

❌ 未通过项目:

  [必需文件：CONTRIBUTING.md]
  缺少 CONTRIBUTING.md

  [必需文件：.gitignore]
  缺少 .gitignore

  [AGENTS.md 内容规范]
  需要优化 (共19行)

  [提交规范符合度]
  0/10 符合 Conventional Commits (0%)

============================================================
⚠️  审计未通过，请根据建议修复问题
```

## 问题分析

### 1. 缺少 CONTRIBUTING.md

**原因**: 项目早期未创建贡献指南文档。

**影响**: 贡献者不知道如何参与项目開發。

### 2. 缺少 .gitignore

**原因**: 项目未配置 Git 忽略规则。

**影响**: 可能提交不必要的文件（如 .pyc, .venv/, .env）。

### 3. AGENTS.md 内容不规范

**当前内容**（共 19 行）:
- 只有工作原则
- 缺少使用场景表格
- 缺少快速索引
- 缺少「如何更新 AGENTS.md」说明

### 4. 提交规范符合度 0%

检查最近 10 条提交：
- 无符合 Conventional Commits 格式的提交

## 解决方案

### 1. 创建 CONTRIBUTING.md

已在主仓库创建 `CONTRIBUTING.md`，包含：
- 项目结构（子模块列表）
- 提交规范
- 子模块操作指南
- 工作流程

### 2. 创建 .gitignore

已在主仓库创建 `.gitignore`，包含：
- Python 忽略规则
- IDE 忽略规则
- OS 忽略规则
- 日志和临时文件

### 3. 优化 AGENTS.md

已扩展 AGENTS.md：
- 添加快速索引表格
- 添加使用场景说明
- 添加「如何更新 AGENTS.md」说明
- 目标：约 50 行

### 4. 提交规范

后续提交使用 Conventional Commits：
```bash
cz commit  # 使用 commitizen
```

或手动遵循格式：
```
<type>: <description>
```

示例：
- `docs: add CONTRIBUTING.md`
- `chore: update submodule`
- `fix: resolve issue`

## 验证

Auditor 代码本身存在的问题：

| 检查项 | 代码实现 | 问题 |
|--------|---------|------|
| 提交规范检测 | 硬编码 `conventional_pattern` | 仅匹配有限类型 |
| AGENTS.md 行数 | 阈值 100 行 | 建议应更严格（50 行） |
| 子模块检查 | 依赖 git submodule status | 超时会跳过检查 |

## 待办

- [x] 创建 CONTRIBUTING.md
- [x] 创建 .gitignore
- [x] 优化 AGENTS.md
- [ ] 审计工具本身需要优化
- [ ] 添加 CI 自动审计