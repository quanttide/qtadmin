# CHANGELOG

## [0.0.1-alpha.1] - 2026-03-28

### Added
- 新增 `qtadmin --help` 和 `qtadmin --version` 命令
- 新增 `qtadmin meta refresh` 命令，同步子模块并提交推送主仓库

### Structure
- 使用 typer 构建 CLI
- 雪花编程法：命令模块分离到 `qtadmin_cli/meta/` 目录
