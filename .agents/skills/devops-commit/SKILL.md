---
name: devops-commit
description: Git 提交技能，用于提交代码变更时，包括主仓库和子模块提交。
---

# Git 提交技能

## 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>: <description>
```

### 提交类型

- **feat**：新功能
- **fix**：修复 bug
- **docs**：文档更新
- **test**：测试相关
- **refactor**：代码重构
- **chore**：构建/工具

### 提交示例

```bash
git commit -m "feat: 添加新功能"
git commit -m "fix: 修复登录问题"
git commit -m "docs: 更新 README"
```

## 提交流程

### 1. 检查状态

```bash
git status
```

查看未提交的变更，包括：
- 未暂存的修改（Changes not staged for commit）
- 已暂存的修改（Changes to be committed）

### 2. 添加文件

```bash
# 添加单个文件
git add <file>

# 添加所有修改
git add -A
```

### 3. 提交

```bash
git commit -m "<type>: <description>"
```

### 4. 确认并推送

```bash
git status
git push
```

确认提交成功并推送到远端。除非用户明确说"只提交不推"，否则默认推送。

## 子模块提交

### 1. 子模块内提交

```bash
# 进入子模块目录
cd docs/handbook

# 检查状态
git status

# 添加并提交
git add -A
git commit -m "docs: 更新文档"

# 推送到远程
git push
```

### 2. 主仓库更新子模块引用

```bash
# 返回主仓库
cd ../..

# 添加子模块引用
git add docs/handbook

# 提交
git commit -m "chore: update handbook submodule"

# 推送
git push
```

## 常见场景

### 场景一：普通代码提交

```bash
git add -A
git commit -m "feat: 添加用户认证功能"
git push
```

### 场景二：文档更新

```bash
git add docs/README.md
git commit -m "docs: 更新使用说明"
git push
```

### 场景三：子模块更新

```bash
cd docs/gallery
git add -A
git commit -m "docs: 添加新示例"
git push
cd ..
git add docs/gallery
git commit -m "chore: update gallery submodule"
git push
```
