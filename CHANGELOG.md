# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

## [0.1.1] - 2026-06-28

### Added

- feat(asset): add improvement directions section to quality report
- feat(asset): rewrite quality in Rust (port from p40)
- feat(asset): add evaluate command for handbook quality assessment
- feat: add a.txt
- feat: add feature
- feat(scene-graph): add scene-graph experiment and extraction type
- feat(knowl): add worldbuilding extraction type
- feat: translate Python extract.py to Rust and integrate as knowl extract subcommand
- feat: store classification rules in Provider, CLI loads via --provider
- feat: add e2e test fixture with Provider lifecycle
- ci: add CLI cargo build/test to pre-commit hook
- feat: add --provider mode to CLI (HTTP client)
- feat: implement v0.0.6 business domain API
- feat: implement v0.0.5 auth domain API
- feat: implement v0.0.4 connect domain API
- feat: implement v0.0.3 human domain CRUD API
- feat: add v0.0.2 infrastructure (config, logging, CI, error handling)
- feat: integrate connect/notice, auth/user, human/position into CLI
- feat: add connect examples (notice script and README)
- feat: 新增 business quote 报价计算命令
- feat: 增加法务实习生岗位识别规则
- feat: 新增 business/knowl/auth/delib/prototype 等实验示例
- feat: 新增 qtadmin-auth 和 qtadmin-org 示例
- feat: 招聘计划数据共享 - Studio 读取 CLI 同源 JSON
- feat: 实现 qtrecurit status 招聘数据统计命令
- feat: add recruitment stats script
- chore: 添加 Apache 2.0 协议
- chore: keep views directory with .gitkeep

### Changed

- chore: add contract.yaml defining scope→dir mapping
- chore: .gitignore 补充 examples/*/target/
- refactor(quality): load metrics from profile instead of hardcoding
- refactor(human): load classification rules from profile instead of hardcoding
- refactor(asset): output quality report to stdout
- chore: ignore generated p40 output files
- refactor(asset): status=结构合规, quality=语义评估
- refactor(asset): rename audit to quality
- refactor(asset): separate status from audit
- refactor(asset): merge evaluate into audit --quality
- refactor(asset): rename backup to archive
- refactor: move classification rules from human to connect domain
- refactor: extract auth module to libs/qtcloud-auth
- chore: update STORE_PATH to profile directory
- refactor: align CLI provider models with API; rename tests/contract to tests/fixtures
- chore: isolate qtadmin data to /home/iguo/data/qtadmin
- refactor: prefix env vars with QTADMIN_, add backward compatibility
- refactor: replace public register with pre-seeded admin user
- refactor: strip business logic and external integrations from provider
- refactor: replace db stub with file-based store layer
- refactor: convert provider from Python (FastAPI) to Go
- refactor: rename org to human, convert API to CLI
- refactor: 吸收 knowl 到 CLI
- refactor: 融合 quotation.rs 和 quote.rs
- refactor: 吸收 examples/business 到 CLI
- refactor: business 和 knowl 从 Python 转为 Rust
- chore: knowl/data 加入版本控制
- refactor: 将 data/ 不过滤规则移到本地 .gitignore 管理
- chore: 添加 business/data/ 到版本控制
- chore: 重命名命令为 qtadmin
- refactor: 转换 qtadmin-org 为 Rust（axum+sqlx），Port 3001
- refactor: 合并 qtadmin-auth 到 auth，Python FastAPI 改写为 Rust axum+sqlx
- refactor(asset): 遵循 12-factor 改造，提取 format_report 返回 String
- refactor(connect): 细分 lark 为 lark/mail 模块
- refactor: connect 提升为顶层职能域模块
- refactor: 提取 trait 接口提升可测试性，覆盖率 73%
- refactor: 拆分 qtrecurit 为 connect/human/status 三层
- refactor: rewrite Python CLI to Rust
- refactor: extract qtadmin-navigation package, decouple from WorkspaceInfo
- refactor: extract qtadmin-dashboard package
- refactor: extract DashboardBloc from AppBloc
- refactor: replace BundleSource with FileSource, remove data/ from pubspec assets
- ci: replace fixture copy with asset stubs for build
- ci: copy fixtures before test in studio workflow
- refactor: extract data_sources infrastructure package
- refactor: move domain constants and screens into packages
- refactor: move ConsultBloc into qtadmin-qtconsult package
- ci: change deploy trigger from push to release
- refactor: extract remaining domain packages (qtclass, think, org)
- refactor: extract qtadmin-qtconsult package from lib/models/
- Revert "docs: add profile-as-source-of-truth to ROADMAP"

### Fixed

- fix: studio CHANGELOG 改用 Keep a Changelog 格式 [0.1.3]
- fix(scene-graph): add excerpt fields for verbatim source text
- fix(worldbuilding): update prompt for romance fiction analysis
- fix: scope gitignore 'server' rule to root only
- fix: 取消过滤 examples/business/data/
- fix: 更新集成测试中二进制名称 qtadmin-cli → qtadmin
- fix(asset): rewrite status as current state reporter

### Removed

- refactor: 移除 SQLite 依赖和死代码，精简依赖至 profile 模式
- refactor: remove provider, move git_utils to asset, position reads from profile
- chore: remove ROADMAP.md (items completed or superseded)
- chore: remove src/provider/ROADMAP.md and TODO.md
- chore: remove src/cli/ROADMAP.md and TODO.md (superseded by root ROADMAP)
- chore: remove dead code (perm module, unused provider methods, load_rules)
- chore: remove cli CI workflow (covered by pre-commit hook)
- chore: remove redundant e2e_test.go (covered by integration_test.go)
- chore: remove unused upload_oss.py
- chore: 移除 tarpaulin 产物
- chore: 移除 tarpaulin 产物 lcov.info
- refactor: 移除 knowl ROADMAP.md 和 TODO.md
- refactor: 移除 delib 示例
- chore: remove default examples
- chore: 移除 examples/.gitignore（已由各示例独立管理）
- refactor: 移除旧的 Python qtadmin-org（已迁移到 Rust org）
- chore: remove prototype examples
- chore: 移除 Python CLI 遗留测试
- chore: remove qtrecurit examples, superseded by qtadmin-cli v0.0.5
- chore: 移除已废弃的产品文档技能（BRD/DRD/PRD）
- clean: remove old navigation.dart tracked by git
- clean: remove unused stat_item.dart from main project

## [0.1.0] - 2026-05-09

### Studio

独立发布 `v0.1.0`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.9] - 2026-05-09

### Studio

独立发布 `v0.0.7`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.8] - 2026-05-08

### Studio

独立发布 `v0.0.6`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.7] - 2026-05-08

### Added

- `docs/dev/pmd.md`：问题管理文档（业务问题 + 技术问题双维度记录）
- `.agents/skills/`：技能系统（从 quanttide-platform 同步）

### Changed

- `src/studio/` 租户(Tenant) → Workspace工作空间(Workspace) 全量重命名
  - `TenantType` → `WorkspaceType`，`TenantInfo` → `WorkspaceInfo`，`TenantSwitcher` → `WorkspaceSwitcher`
  - 所有相关字段/参数/变量同步更新
- `src/studio/` 文档、Dart 代码标识符、JSON fixture 键全量替换

### Fixed

- `src/studio/` 修复数据加载完成前侧边栏空 `workspaces` 列表导致的 `RangeError`
- `src/studio/` 修复 web 平台 fixture 加载（改用 HTTP asset loader）
- `src/studio/` 修复 Aliyun OSS 部署配置

### Docs

- `ROADMAP.md`：项目路线规划文档

### Studio

独立发布 `v0.0.6`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.6] - 2026-05-08

### Added

- `docs/add/qtclass.md`：量潮课堂架构设计文档（课程域/组织域分离）
- `docs/drd/dashboard.md`：仪表盘数据模型 schema
- `docs/drd/qtclass.md`：量潮课堂数据模型 schema
- `docs/drd/thinking.md`：思考页面数据模型 schema

### Changed

- `src/studio/` 全景图→仪表盘全面重命名（`panorama` → `dashboard`）
  - 侧边栏导航项"全景图"→"仪表盘"
  - 数据模型 `PanoramaData` → `DashboardData`，路由类型 `panorama` → `dashboard`
  - 所有 import、变量名、fixture 文件同步更新
- `src/studio/` 量潮课堂从通用业务详情页改为独立页面（`pageType: classroom`）
  - 新增 `QtClassScreen`：四个组成部分（校企合作/实训基地/内部教学/一对一）卡片展示
- `src/studio/` 思考页面数据抽取为 fixture 驱动
  - 新增 `ThinkingData` 模型 + `thinking.json` fixture
  - `ThinkingScreen` 从硬编码改为接收数据参数
- `src/studio/` 版本发布 v0.0.5
- `docs/drd/metadata.md`：路由表更新（`dashboard`/`classroom` 新增，`thinking` 数据源补充）

### Studio

独立发布 `v0.0.5`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.5] - 2026-05-08

### Added

- `assets/fixtures/metadata.json`：根注册表（Workspace工作空间清单 + 段定义）
- `NavSidebar` 独立组件，封装侧边栏全部布局逻辑
- `docs/drd/` 数据规范目录：metadata.json + qtconsult.json schema
- `docs/dev/README.md`：主仓库开发文档边界说明

### Changed

- `src/studio/` 导航重构：
  - 根 metadata + 每Workspace工作空间 metadata 两层分离，分隔线规则从 Dart 代码移到 JSON
  - `_NavItem`/`_NavIcon`/`_WorkspaceSwitcher` 从 `main.dart` 私有类提取为公开组件
  - `lib/widgets/` → `lib/views/`
  - `_buildSidebar` 替换为 `NavSidebar`，新增Workspace工作空间无需改 Dart 代码
- `src/studio/CHANGELOG.md`：独立维护 Studio 版本日志
- 文档结构重组：
  - `docs/dev/studio.md` → `src/studio/doc/index.md`（Studio 实现文档归入子模块）
  - `docs/add/qtconsult.md` → `src/studio/doc/screens/qtconsult.md`（降级为屏幕实现）
  - `docs/add/multi-workspace.md` 删除
  - `docs/drd/` 新增数据规范，与实现文档分离
  - `docs/myst.yml` 同步更新目录结构


## [0.0.4] - 2026-05-06

### Added

- `docs/`: 咨询业务线全套文档
  - BRD：信息-策略断层业务需求说明书
  - PRD：双栏联动设计 + 三层交互原则
  - IXD：信息看板+策略看板页面布局
  - ADD：咨询模块数据模型与架构设计文档
- `src/studio/`: 量潮咨询详情页（QtConsultScreen）
  - 双栏联动面板：信息看板（发现/沟通） + 策略看板（诉求/策略/决策链路）
  - 发现→策略强制联动：高风险发现自动追加审视记录
  - 完整 CRUD 交互（添加/确认/驳回/删除发现，标记审视）
  - 数据抽离至 `assets/qtconsult.json`
  - ADD 架构设计文档
- `examples/prototype/qtconsult.html`：咨询原型（本地存储 + 完整交互）

### Changed

- `src/studio/` 导航重构：`_workspaces` 改为实例字段，支持动态页面加载
- `src/studio/pubspec.yaml` 注册 `qtconsult.json` asset

### Studio

独立发布 `v0.0.3`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.3] - 2026-05-06

### Added

- `src/studio/`: 多Workspace工作空间架构
  - 量潮创始人：全景图 + 思考（认知演进报告）+ 写作（占位）
  - 量潮科技：全景图 + 量潮数据/课堂/咨询/云
  - Workspace工作空间切换器（PopupMenuButton），支持一键切换
  - 思考页面（ThinkingScreen）：认知建构与思维演进分析报告
- `examples/default/`：日志文本分析工具及报告
- `scripts/record-studio-linux.sh`：自动录屏脚本（ffmpeg + xdotool）
- `assets/videos/studio.mp4`：客户端演示视频（Git LFS 管理）
- `.gitattributes`：Git LFS 跟踪 `assets/videos/**`

### Changed

- Git LFS 管理大文件
- Flutter 依赖升级

## [0.0.2] - 2026-05-06

### Added

- `src/studio/`: 全景图今日看板（Flutter 实现）
  - 全景图主页面（业务线决策卡片 + 职能线指标卡片）
  - 业务线详情页（量潮数据/课堂/咨询/云）
  - 决策卡片交互（批准/驳回/附条件）
  - 响应式布局（桌面多列 / 移动端单列+折叠）
  - 数据抽离至 `assets/panorama.json`，支持热更新
- `scripts/run-studio-linux.sh`：Linux 编译运行脚本

### Changed

- 全平台应用名统一为 `qtadmin_studio` / 量潮管理后台
- Flutter 依赖升级至最新兼容版本
- 导航栏重构为自定义侧边栏（全景图 + 4 业务线）

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
