# CHANGELOG

## [0.0.16] - 2026-06-22

### Removed

- `auth` 模块整体移除（auth/user SQLite 用户 CRUD）
- `qtrecurit.toml` 配置文件移除（规则已迁移到 profile）
- `human/config.rs` 中 TOML 配置加载路径（config_paths/load_from_toml）
- `cli_config.rs` 中内联函数（profile_rules_path/profile_quality_path）
- `connect/mod.rs` 中的 `EmailFetcher` trait 和 `Message` 结构体
- `business/mod.rs` 中的 `OrderStore` trait
- 依赖：`sqlx`、`tokio`、`toml`、`thiserror`

### Changed

- `human/config.rs`：配置加载简化为仅从 profile 读取
- `cli_config.rs`：仅保留 `profile_root()` 和 `deepseek_api_key()`，其余内联到调用处
- `connect/email/lark.rs`：`fetch_all` 改为常规方法，直接返回 `MailItem`
- `qtrecurit/status.rs`：`format_status` 改为直接接收 `&[MailItem]`，移除 trait 依赖
- `business/status.rs`：`format_status` 改为直接接收 `&BusinessStatus`，移除 trait 依赖

### Tests

- 新增 `tests/contract/recruitment.json` 测试夹具
- 移除 auth 相关集成测试（test_auth_help/test_auth_user_help）
- 146 测试全部通过

## [0.0.15] - 2026-06-20

### Added

- `cli_config.rs`：集中管理环境变量和默认路径（QTRECURIT_PROFILE, DEEPSEEK_API_KEY 等）
- 测试覆盖：cli_config（4 测试）、quality metrics（3 测试）、position（3 测试）、connect notice（3 测试）、auth user（3 测试）

### Changed

- `git_utils.rs` 移入 `asset/git_utils.rs`
- `human/position.rs` 改为从 `profile/human/positions.json` 读取，移除 SQLite 依赖
- `human/config.rs` 使用 `cli_config` 代替硬编码环境变量
- `asset/quality.rs` 使用 `cli_config` 代替硬编码路径和 API Key

### Removed

- 移除 `provider.rs`（Provider API 客户端）
- 移除 `human/position.rs` 中的 SQLite + provider 模式代码

## [0.0.14] - 2026-06-20

### Added

- `asset archive`：将 journal 日志归档到 archive
- `asset quality`：Rust 实现的手册质量评估（叙事/知识/认知三维度）
- `asset status`：仓库结构合规检查（必需文件、格式、提交规范）

### Changed

- `asset backup` 重命名为 `asset archive`
- `asset audit` 重命名为 `asset quality`，结构检查移至 `asset status`
- `asset evaluate` 合并入 `asset quality`，移除 Python 脚本依赖

### Removed

- 移除 `p40-evaluate.py` 调用依赖，全部改用 Rust 实现

## [0.0.13] - 2026-06-18

### Added

- `knowl extract` 子命令：本体 YAML → 结构化产物，支持 cognition/todo/motif/annotate 四种抽取类型
- Schema 编译：从 YAML field 定义自动生成 JSON Schema，约束 LLM 输出格式

### Changed

- Python extract.py 翻译为 Rust，集成到 qtadmin CLI

## [0.0.12] - 2026-06-18

### Added

- 全局 `--provider` / `-p` 模式，通过 HTTP 调用 Provider API 替代本地文件
- `human position` 支持 `--provider` 模式（list/get/create）
- 分类规则从 Provider 加载（`POST /api/v1/connect/rules`），失败回退内置规则
- CLI 岗位模型与 Provider API 对齐（字符串 ID、status 字段）
- 端到端测试：CLI → Provider → 数据持久化验证

### Changed

- `position get` / `position delete` 的 ID 参数从数字改为字符串
- CLI 模型增加 `#[serde(default)]` 兼容 Provider JSON 格式

## [0.0.11] - 2026-06-18

### Added

- `auth user` 用户档案 CRUD 命令
- `auth::perm` 权限审计工具模块（含 7 个单元测试）
- `connect notice` 飞书群通知命令
- `human position` 岗位管理 CRUD 命令

### Changed

- examples/org → examples/human，从 Axum API 改为 CLI
- 已吸收的示例目录（auth、connect、human）全部清理

### Tests

- 新增 auth/perm 单元测试 7 个
- 新增新模块 help 集成测试 6 个

## [0.0.10] - 2026-06-17

## [0.0.9] - 2026-06-17

### Fixed

- 集成测试二进制名称未同步改名导致 CI 失败

## [0.0.8] - 2026-06-17

### Changed

- 命令名称从 `qtadmin-cli` 改为 `qtadmin`

## [0.0.7] - 2026-06-17

### Added

- 法务实习生岗位识别规则（关键词：法务/法律/合规），`human::config` 内置规则增至 12 个岗位

## [0.0.6] - 2026-06-16

### Added

- `project status` 命令：项目交付状态总览，五阶段流程（调研→谈判→执行→交付→复盘）
- `business status` 命令：商务拓展订单总览，四阶段流程（商机→报价→谈判→签约）
- `qtconsult status` / `qtclass status` / `qtcloud status` / `qtdata status` 命令：四个业务域各自的项目总览
- 业务域与职能域分层架构正式成型：4 职能域 + 5 业务域 = 9 个顶级命令

### Changed

- 项目总纲章程同步更新为五阶段（`docs/bylaw` v0.6.0）

## [0.0.5] - 2026-06-16

### Added
- XDG 规范支持：配置走 `QTRECURIT_CONFIG`（`~/.config/qtadmin/qtrecurit.toml`），数据走 `QTRECURIT_DATA`（`~/.local/share/qtadmin/`)
- `qtrecurit.toml` 配置文件，岗位规则可编辑无需重编译
- `dirs` 依赖用于 XDG 路径解析

### Changed
- 分类规则补充：`技术实习生`/`技术实习` 归入数据工程师
- CLI 描述更新：`qtrecurit` → 量潮招聘

## [0.0.4] - 2026-06-16

### Added
- `human status` 命令：月度招聘计划与进度管理，按岗位展示编制/已入职/进行中/空缺
- `connect::email::EmailFetcher` trait，支持 Lark Mail 等多渠道邮件接入

### Changed
- 架构重组：`human`/`connect` 独立为顶层职能域，`qtrecurit` 业务域通过 trait 注入复用
- `asset::audit` 遵循 12-factor 改造：`format_report` 返回 String，`run` 返回 Result，移除 `pyproject.toml` 硬编码
- 提升可测试性：提取 `PlanStore`/`EmailFetcher` 接口，覆盖率从 60% 提升至 73%
- 硬编码更新：`.gitignore` 规则适配当前技术栈，可选目录从 `meta` 改为 `.quanttide`

### Removed
- `asset::audit` 移除 `pyproject.toml` 版本检测优先逻辑（与 `Cargo.toml` 并列保留）

## [0.0.3] - 2026-06-16

### Added
- `qtrecurit status` 命令：招聘数据统计，支持 TOML 配置化的岗位分类规则
- 新增 `serde` / `serde_json` / `toml` 依赖

### Changed
- CLI 版本从 0.0.2 升到 0.0.3

## [0.0.2] - 2026-06-16

Rust 重构版本，Python → Rust 全量迁移。

### Changed
- 从 Python (typer) 重构为 Rust (clap)，单二进制分发
- `--version` 不再通过 Python importlib，由 clap 编译时常量提供

### Removed
- 移除 Python 源码（`app/`, `pyproject.toml`, `uv.lock`）

### Added
- CI 工作流（`.github/workflows/cli.yml`）
- 51 个单元测试 + 4 个集成测试，覆盖率 86%

## [0.0.1] - 2026-04-07

首个正式版本，提供数字资产管理工具集。

### Added
- CLI 基础框架：使用 typer 构建命令行工具，支持 `--help` 和 `--version`
- `asset backup` 命令：日志归档功能，支持递归扫描和嵌套目录结构
- `asset audit` 命令：资产审计功能
  - AGENTS.md 完整性检查（行数阈值、自我更新说明要求）
  - 版本发布规范一致性检查
  - 提交规范检查
- 动态获取子模块路径：从 `.gitmodules` 自动读取
- 测试套件：集成测试和单元测试
- 完整的用户文档和开发文档

### Changed
- 重构包结构：将 `qtadmin_cli` 重命名为 `app`
- 重构命令组：将 `meta` 重命名为 `asset`（数字资产职能）
- 版本号单一数据源：仅在 `pyproject.toml` 维护，代码动态获取

### Removed
- `asset refresh` 命令（功能已迁移至其他工具）

### Fixed
- CLI 入口点配置
- 构建配置支持 `uv pip install`

## [0.0.1-beta.5] - 2026-04-04

### Removed
- 移除 `asset refresh` 命令

## [0.0.1-beta.4] - 2026-04-04

### Fixed
- `asset refresh`: 修复无法识别云端更新的问题，改为比较父仓库记录的子模块 commit 与远程 HEAD
- `asset refresh`: 同步逻辑改用 `git submodule update --remote`

## [0.0.1-beta.3] - 2026-04-04

### Fixed
- `asset refresh`: 修复硬编码 `origin/main` 导致无法识别非 main 分支子模块的更新
- `asset refresh`: 同步逻辑改为动态获取子模块对应远程分支

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

## [0.0.1-alpha.4] - 2026-04-01

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
