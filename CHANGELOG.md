# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

## [0.0.1] - 2026-04-30

### Added

- `src/provider/`: 基于 FastAPI + uv 的空后端项目骨架
- `tests/cli/`: CLI 集成测试目录

### Removed

- `src/provider/` 历史代码：薪资模块、员工 CRUD、数据库、旧测试
- `src/studio/lib/screens/` 和 `src/studio/lib/models/`（旧 Flutter UI）
- `examples/` 和 `tests/` 中的零散实验脚本
- 根目录 `pyproject.toml`（CLI 由 `src/cli/pyproject.toml` 独立管理）
- `src/provider/` 的 PDM 构建配置，替换为 uv

### Moved

- 薪资计算代码 → `qtcloud-hr/examples/salary/`
- 资产契约 UI 代码 → `qtcloud-asset/`
- `src/cli/integrated_tests/` → `tests/cli/`

### Fixed

- uv workspace 污染：`.venv` 和 `uv.lock` 现位于 `src/provider/` 内部
