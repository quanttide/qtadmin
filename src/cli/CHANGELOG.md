# CHANGELOG

## [0.0.1-beta.2] - 2026-04-04

### Fixed
- `asset backup`: 递归扫描 journal 目录，支持任意嵌套层级
- `asset backup`: 归档后保持原始嵌套目录结构
- `asset audit`: 统一提交规范正则表达式
- `asset audit`: 子模块超时返回失败状态
- `asset audit`: AGENTS.md 行数阈值调整为 50 行

### Added
- `asset audit`: 版本发布规范一致性检查

### Documentation
- 添加 `docs/dev/asset_audit.md` 开发文档
- 添加 `docs/dev/asset_backup.md` 开发文档
- 更新 `docs/user/asset_backup.md` 用户文档
- 更新 CONTRIBUTING.md 发布流程

### Tests
- 更新单元测试支持递归扫描和嵌套目录
- 更新集成测试验证嵌套目录结构

## [0.0.1-beta.1] - 2026-04-03

### Changed
- 单一数据源：版本号仅在 pyproject.toml 维护，代码通过 importlib.metadata 动态获取

### Documentation
- 添加 CONTRIBUTING.md 版本发布规范

## [0.0.1-alpha.7] - 2026-04-02

### Added
- 动态获取子模块路径：从 `.gitmodules` 读取子模块列表
- AGENTS.md 增加了「自我更新说明」要求

### Fixed
- 添加 hatchling build 配置以支持 `uv pip install`
- 更新 `SUBMODULE_PATHS` 支持新增子模块（gallery, qtcloud-finance 等）

## [0.0.1-alpha.6] - 2026-04-01

### Fixed
- 添加 hatchling build 配置以支持 uv pip install

## [0.0.1-alpha.5] - 2026-04-01

### Added
- AGENTS.md 检查增加「自我更新说明」要求

## [0.0.1-alpha.4] - 2026-04-02

### Added
- 动态获取子模块路径：从 `.gitmodules` 读取子模块列表

### Fixed
- 更新 `SUBMODULE_PATHS` 支持新增子模块（gallery, qtcloud-finance 等）

## [0.0.1-alpha.3] - 2026-04-01

### Fixed
- 修复 CLI 入口点配置
- 添加 `typer` 和 `pyyaml` 依赖项到主 pyproject.toml

## [0.0.1-alpha.2] - 2026-04-01

### Added
- 新增 `asset backup` 命令用于日志归档
- 新增集成测试和单元测试

### Changed
- 重构包结构：将 `qtadmin_cli` 重命名为 `app`
- 重构命令组：将 `meta` 重命名为 `asset`（数字资产职能）
- 更新 ROADMAP

### Documentation
- 更新用户文档和开发文档

## [0.0.1-alpha.1] - 2026-03-28

### Added
- 新增 `qtadmin --help` 和 `qtadmin --version` 命令
- 新增 `qtadmin asset refresh` 命令，同步子模块并提交推送主仓库

### Structure
- 使用 typer 构建 CLI
- 雪花编程法：命令模块分离到 `app/asset/` 目录
