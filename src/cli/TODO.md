# TODO

## 阶段一：基础设施与 `asset backup`

- [x] 初始化 Cargo 工作空间
- [x] 选择并配置 CLI 框架（clap v4 derive）
- [x] 实现 `--help` / `--version` 回调
- [x] 移植 `get_project_root`：向上遍历查找 `docs/journal` + `docs/archive/journal`
- [x] 移植日期文件名解析（正则）
- [x] 移植递归扫描 + 分类 + 筛选 N 天前逻辑
- [x] 移植文件移动（含 dry-run 支持）
- [x] 移植 git 操作：status / add / commit / push（子模块 + 主仓库）
- [x] 移植备份相关测试

## 阶段二：`asset audit`

- [x] 移植必需文件检查
- [x] 移植 README 内容规范检查
- [x] 移植 CONTRIBUTING 内容规范检查
- [x] 移植 AGENTS 内容规范检查
- [x] 移植 CHANGELOG 格式规范检查
- [x] 移植 .gitignore 内容规范检查
- [x] 移植子模块状态检查
- [x] 移植 Conventional Commits 提交规范检查
- [x] 移植版本发布一致性检查
- [x] 移植审计报告数据模型及打印

## 阶段三：质量加固与工程化

- [x] 集成测试：`assert_cmd` / `predicates`
- [x] CI 配置：GitHub Actions Rust 构建 + 测试
- [x] 依赖审计（`serde_yaml` 按需引入）
- [x] 错误处理统一（`anyhow` + `thiserror`）
- [x] 更新 README 安装方式（无需额外操作：项目无独立 README，安装见 CONTRIBUTING.md）

## 阶段四：清理与收尾

- [x] 删除 Python 源码（`app/`, `pyproject.toml`, `tests/`）
- [x] 更新 CHANGELOG.md
- [x] 更新 CONTRIBUTING.md 构建/测试命令
- [x] 确认标签命名策略不变
