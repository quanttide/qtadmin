# Changelog

## v0.1.0

### Refactor

- 路由系统迁移：纯 GoRouter 替代 AppRouter 字符串派发，redirect 统一管理 AppLifecycle
- P0 路由表合并：`Map<String, RouteConfig>` 自包含，消除 routeId→screen 双重映射
- P1 Section 缓存：`_SidebarShell` StatefulWidget 缓存子树，workspace 不变时减少 50%+ 无谓重建
- P2 ConsultBloc 生命周期提升至 ShellRoute，跨页面保持咨询状态
- 全模型 `XxxData` → `Xxx` 重命名（Dashboard、BusinessUnit、Thinking 等 20+ 模型）
- `NavItem` 构造参数 `builder` → `routeId`，与路由表解耦

### Added

- 166 测试全覆盖：sources（DataLoader/DataResult）、blocs（ConsultBloc）、screens（dashboard/business_detail/function_detail/qtconsult）、views（全部 7 个 widget 组件）
- `DataSource` 抽象 + `DataResult` sealed class + `DataLoader` 泛型类

### Fixed

- 切换工作空间 `_router` 重新赋值报错（`late final` → `late`）

### Chore

- pre-commit 仅 `dart analyze`，`flutter test` 由 CI 覆盖

## v0.0.7

### Docs

- 关键决策记录：14 项架构选型决策及理由
- 债务评估更新：P0-P2 全部完成，综合评级降至低
- 文档重组：拆分为 decision.md / refactor.md，新增 dev/README.md
- 删除 ROADMAP.md（P0-P2 全部达成）

## v0.0.6

### Refactor
- 重命名 租户(Tenant) → Workspace工作空间(Workspace)：中文文档、Dart 代码标识符、JSON fixture 键全量替换
  - `TenantType` → `WorkspaceType`，`TenantInfo` → `WorkspaceInfo`，`TenantSwitcher` → `WorkspaceSwitcher`
  - 所有相关字段/参数/变量同步更新
- 路由重构：metadata.json 的 items 改为纯 name 列表，移除 label/icon/pageType
  - 新增 `RouteConfig` 集中管理所有路由定义
  - `AppRouter.buildScreen()` 通过 `RouteConfig` 分发
- 数据加载改为缓存注入：移除 `rootBundle` 和 pubspec.yaml assets
  - 所有 Loader 添加 `inject()` 方法
  - fixture JSON 移至 `data/` 本地目录
- 组织管理代表改为多对多：`institutionId` → `institutionIds: List<String>`

### Added
- 组织管理页面（`OrgScreen`）：机构看板、代表履职（可展开详情）、职级流动
- 组织管理数据模型（`OrgDashboardData` / `OrgInstitutionData` / `OrgRepresentativeData` / `OrgRankData` / `OrgPromotionData`）
- `OrgLoader` fixture 加载 + 缓存注入
- 路由独立模块 `lib/router.dart`

### Fixed
- 修复数据加载完成前侧边栏空 `workspaces` 列表导致的 `RangeError`（预存 bug）
- 切换工作空间时 `_router` 重新赋值报错（`late final` → `late`）

### Tests
- 新增 `org_test.dart`（13 个模型测试）
- 新增 `org_screen_test.dart`（11 个 widget 测试）
- 更新 `metadata_test.dart` 适应新的纯 name 格式

## v0.0.5

### 新增
- `QtClassScreen`：量潮课堂独立页面，展示四个组成部分（校企合作/实训基地/内部教学/一对一）
- `QtClassData` 数据模型 + `qtclass.json` fixture + loader
- `ThinkingData` 数据模型 + `thinking.json` fixture + loader，思考页面数据抽取为 fixture 驱动
- 数据规范文档：`qtclass.md`、`thinking.md`、`dashboard.md`

### 重命名
- 全景图→仪表盘，全线英文 `panorama` → `dashboard`
  - `PanoramaScreen` → `DashboardScreen`，`PanoramaData` → `DashboardData`
  - `panorama_loader.dart` → `dashboard_loader.dart`，`panoramaPath` → `dashboardPath`
  - fixture 文件同步重命名，所有 import/变量名更新

### 测试
- 新增 `thinking_test.dart`、`thinking_screen_test.dart`（模型 + widget）
- 新增 `qtclass_test.dart`、`qtclass_screen_test.dart`（模型 + widget）
- 全部 94 个测试通过

## v0.0.4

### 新增
- 根 `metadata.json` 全局注册表：Workspace工作空间清单 + 段定义（dividerBefore 规则）
- `NavSidebar` 独立组件，封装侧边栏全部布局逻辑
- 数据规范文档目录（`docs/drd/`）：metadata schema + qtconsult schema

### 优化
- 导航组件从 `main.dart` 私有类提取为公开组件（NavIcon / WorkspaceSwitcher / NavSidebar）
- `lib/widgets/` → `lib/views/`，widget test 直接 import 公开组件，不再重复定义
- 新增Workspace工作空间只需写 fixture 文件，不再改 Dart 代码
- 文档结构重组：主仓库 dev / ADD / DRD / 子模块 doc 分工明确

## v0.0.3

### 新增
- 量潮咨询详情页：双栏联动面板（信息看板 + 策略看板），支持发现记录、策略修正、决策链路管理
- 咨询数据模型（DiscoveryData / StakeholderData / StrategyRevisionData）及 JSON 加载服务
- 发现→策略强制联动：高风险/需关注发现自动追加策略审视记录
- ADD 架构设计文档

### 优化
- 导航重构：`_workspaces` 改为实例字段，支持动态页面加载
- 资源注册：`qtconsult.json` 注册为 Flutter asset

## v0.0.2

### 新增
- 多Workspace工作空间架构：量潮创始人（全景图/思考/写作）与量潮科技（全景图/数据/课堂/咨询/云）
- 思考页面（ThinkingScreen）：认知建构与思维演进分析报告，包含阶段时间线、情绪统计、心智模型洞察
- Workspace工作空间切换器（PopupMenuButton），支持一键切换Workspace工作空间及对应导航

### 优化
- 全景图页面支持动态Workspace工作空间名称
- 侧边栏布局调优（减小间距，提升紧凑度）
- Flutter 依赖升级至最新兼容版本

## v0.0.1

### 新增
- 全景图主页面（今日看板），包含业务线决策卡片和职能线指标卡片
- 业务线详情页，支持按业务线查看决策事项
- 决策卡片交互（批准/驳回/附条件）
- 响应式布局（桌面多列 / 移动端单列+折叠）

### 架构
- 全平台应用名统一为 `qtadmin_studio` / 量潮管理后台
- 全景图数据抽离至 `assets/panorama.json`，支持热更新
- Model 层支持 JSON 反序列化
- Flutter 依赖升级至最新兼容版本
