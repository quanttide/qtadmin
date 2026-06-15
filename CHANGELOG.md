# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

## [0.1.0] - 2026-05-09

### Human

独立发布 `v0.9.0`，详见 [CHANGELOG-human.md](CHANGELOG-human.md)。

- **Admin CLI**: 命令行工具集（API 客户端、分类器、邮件发送、飞书集成）
- **飞书集成**: 邮件读取/发送循环、管道看板推送

### Studio

独立发布 `v0.1.0`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.9] - 2026-05-09

### Human

独立发布 `v0.7.0` — Headcount Planning & Export。

- **人数规划**: 招聘编制规划与跟踪服务
- **数据导出**: 候选人数据导出端点与生成服务

### Studio

独立发布 `v0.0.7`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.8] - 2026-05-08

### Human

独立发布 `v0.6.0` — AI 配置与设置页面。

- **AI 配置模型与路由**: 供应商、模型、API 密钥、温度、提示词模板
- **Flutter 设置页面**: AI 配置表单、服务端地址切换、连接测试
- **主题系统**: `HrThemeExtension`，8 种状态色彩、间距/字号 token、深色主题

### Studio

独立发布 `v0.0.6`，详见 [src/studio/CHANGELOG.md](src/studio/CHANGELOG.md)。

## [0.0.7] - 2026-05-08

### Human

独立发布 `v0.5.0` — 申请中心与邮件往来。

- **Application 模型/路由**: Candidate + Recruitment 关联、人才池、来源追踪
- **Candidate 模型/路由**: 候选人实体、邮箱唯一约束、更新同步
- **消息系统**: MailMessage 模型、邮件往来列表、时间线、回复、发件箱、死信队列
- **素材服务**: 简历附件关联与查询
- **修正日志**: 字段级人工修正追踪
- **Flutter 详情面板**: 邮件正文展示、附件预览、分类器信息、修正记录、时间线

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

### Human

独立发布 `v0.4.0` — Flutter 看板（Pipeline + Queue + Pool）。

- **Flutter 看板**: 响应式布局（NavigationRail/NavigationBar）、3 标签导航
- **管道看板**: 候选人状态分组、停留天数、搜索、拖拽流转、详情面板
- **队列**: 待处理邮件列表、置信度标签、确认/调整/忽略
- **人才池**: 候选人池管理、重新入池分配
- **Flutter 通用组件**: StatusBadge、EmptyState、ErrorView、InfoRow

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

### Human

独立发布 `v0.3.0` — 邮件筛选网关。

- **待处理队列**: PendingQueueItem 模型、邮件元数据/AI 提取字段/分类结果
- **队列路由**: 列表（按邮箱去重）、确认/忽略/调整
- **邮箱导入路由**: 批量导入、message_id 去重、自动匹配候选人
- **分类器服务**: 关键词规则分类 + LLM AI 分类（可配置供应商/模型/回退）
- **邮件匹配服务**: 邮箱规范化、去重检查、候选人匹配

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

### Human

独立发布 `v0.2.0` — FastAPI 人才管道。

- **Talent 状态机**: 8 状态（NEW→CONTACTED→EXAM_SENT→EXAM_RECEIVED→EVALUATING→INTERVIEW→OFFER→CLOSED）
- **Recruitment 模型/路由**: 招聘项目 CRUD、Talent CRUD、状态流转校验
- **管道路由**: 按状态聚合的管道视图
- **种子数据**: DEMO_TALENTS 常量

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

### Human

独立发布 `v0.1.0` — 领域模型与筛选引擎。

- **Dart 招聘筛选**: Resume/JobPosition/ScreeningRules 模型、通过/优先/拒绝三态决策
- **Dart 薪酬计算**: 净薪公式（base + overtime + bonus - deductions）、可配置规则
- **FastAPI 后端骨架**: SQLAlchemy + SQLite、抽象 get_db 依赖

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
