# CHANGELOG

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
