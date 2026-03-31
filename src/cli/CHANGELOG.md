# CHANGELOG

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
