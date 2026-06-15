# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

## [0.2.0] - 2026-06-14

### Added

#### Finance 模块

新增 `packages/finance/` 三层包结构，实现财务记录标准化、分类和统计的核心流程：

```
SourceRecord → NormalizedRecord → ClassificationResult → Statistics
                                     ↓ (可选)
                     Journal / JournalEntry / JournalEntryLine
```

##### `packages/finance/dart/`（版本 0.2.0）

Dart 领域模型与共享 DTO：
- `Journal` / `JournalEntry` / `JournalEntryLine` 凭证模型（freezed 不可变，`copyWith` + JSON 序列化）
- 8 个枚举：`SourceType` / `IngestionStatus` / `RecordType` / `Direction` / `NormalizationStatus` / `ClassifierKind` / `ReviewStatus` / `LineType`（`@JsonEnum` + `@JsonValue` 显式映射 + `unknown` 兜底）
- 测试：`journal_test.dart`

##### `packages/finance/fastapi/`（版本 0.1.0）

FastAPI 后端，Python 3.12+，SQLAlchemy 2.0 + SQLite：

- **4 个 ORM 模型**：
  - `SourceRecord`（`source_type` / `raw_text` / `evidence_refs` / `ingestion_status`）
  - `NormalizedRecord`（`amount_cents` / `direction` / `department` / `person` / `business_date`）
  - `RecordLink`（SourceRecord ←→ NormalizedRecord 多对多关联）
  - `ClassificationResult`（`category` / `classifier_kind` / `confidence` / `review_status` / `is_active`）

- **Pydantic schema 层**：Create/Read/Update 分离，字段约束：
  - `amount_cents >= 0`（`Field(ge=0)`）
  - `raw_text > 65535` → reject（422）
  - `description > 1000` → 静默截断

- **Alembic 迁移**：2 个脚本（M1 基础实体 + M2 tags JSON 修复）

- **3 组 REST 路由器**：
  - `source_records`：SourceRecord CRUD + NormalizedRecord CRUD + `POST /source-records/{id}/normalize`
  - `classifications`：创建 + 列表 + `PATCH` 审核/软删除
  - `statistics`：4 个统计端点 — `summary`（汇总卡片）、`breakdown?dimension=`（分组）、`trend?granularity=`（趋势）、`drilldown`（明细），支持 department / person / record_type / direction / currency / taxonomy+category 等多维度筛选

- **Normalizer 接口 + 注册机制**，内置 2 个实现：
  - `CsvRowNormalizer`：解析标准列 CSV（9 列自动映射，含 department / person / counterparty 可选列）
  - `ManualNormalizer`：手工录入兜底（raw_text → description）

- **测试**：7 个文件，30 项测试，涵盖 schema 验证、路由集成、normalizers、statistics 全端点
- **测试基础设施**：Alembic 自动迁移 + SQLite `PRAGMA foreign_keys=ON` + 每测试独立临时数据库

##### `packages/finance/flutter/`（版本 0.1.0）

Flutter API 适配层：
- `FinanceApiClient`：Dart HTTP 客户端，封装所有后端 REST 调用（CRUD + normalize + classify + 4 个 statistics 端点）
- Mockito 测试：`client_test.dart` + `client_test.mocks.dart`
- `main.dart`：独立验证壳（非 Studio 集成，仅用于单独启动测试）

##### `examples/finance/`

前端演示 Demo：
- `index.html`：HTML/CSS/JS 实现的完整 5 步产品流程（录入 → 标准化确认 → 关键词预分类 → 批量审核 → 统计看板）
- `seed.py`：种子数据脚本 + `demo.db` 预填充数据库
- `RUN_DEMO.md` / `README.md`：启动说明

#### Studio Finance 集成

在 `packages/finance/` 三层之上新增的 Studio 专属层：

- **新建 `src/studio/packages/qtadmin-finance/` 包**
  - `FinanceModuleConfig`：API base URL + `enableReviewQueue` / `enableStatistics` 功能开关
  - `FinanceWorkspaceScreen`：Flutter 工作区屏幕，包含：
    - 3 张统计卡片（record count / amount / classified count）
    - 手工录入表单（raw text / date / amount / department / person / description + record type + direction）
    - 审核队列（分类浏览、单条编辑、审核对话、多选批量确认）
    - 部门分布面板（top 5）+ 月度趋势面板（最近 6 期）
    - 加载 / 错误 / 空数据三种状态 UI，`¥1,234.56` 中文金额格式化
  - Widget 测试（表单验证、录入、编辑、批量审核）+ Route 测试

- **路由注册**：`src/studio/lib/router.dart` 新增 `finance` 路由（`label: '财务管理'`，icon `Icons.account_balance_outlined`），API base URL 通过 `ScreenContext.financeConfig` 注入
- **`ScreenContext`** 新增 `financeConfig` 字段
- **`src/studio/lib/blocs/app_bloc.dart`**：传递 `financeConfig` 至 `ScreenContext`
- **`src/studio/pubspec.yaml`**：新增 `qtadmin_finance` path 依赖

#### CI 与发布管线

- `.github/workflows/dart-check.yml`：push/PR 触发 `packages/finance/dart/**`，执行 `dart pub get` → `dart analyze` → `dart test`
- `.github/workflows/dart-publish.yml`：标签 `dart/` 前缀触发 pub.dev 自动发布

#### 文档

- `docs/dev/finance-integration-plan.md`：finance 模块集成策略、分期计划（P0–P4）
- `docs/user-guide/finance.md`：用户指南
- `docs/user-guide/human.md`：人力资源职能用户手册
- `docs/user-guide/asset.md`：资产职能用户手册
- `docs/user-guide/business.md`：业务线用户手册
- `docs/user-guide/index.md`：用户手册索引
- `docs/add/hr-email-import.md`：招聘邮箱导入程序架构设计
- `STATUS.md`：项目状态概览

### Changed

- `docs/myst.yml`：目录结构调整，保留 `user-guide` 目录
- 侧边栏导航：新增"财务管理"入口，使用 `RouteConfig.all` 统一迭代

### Removed

- `.agents/skills/product-brd/SKILL.md`
- `.agents/skills/product-drd/SKILL.md`
- `.agents/skills/product-prd/SKILL.md`

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
