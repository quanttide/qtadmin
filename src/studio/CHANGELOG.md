# Changelog

## v0.0.4

### 新增
- 根 `metadata.json` 全局注册表：租户清单 + 段定义（dividerBefore 规则）
- `NavSidebar` 独立组件，封装侧边栏全部布局逻辑
- 数据规范文档目录（`docs/drd/`）：metadata schema + qtconsult schema

### 优化
- 导航组件从 `main.dart` 私有类提取为公开组件（NavIcon / TenantSwitcher / NavSidebar）
- `lib/widgets/` → `lib/views/`，widget test 直接 import 公开组件，不再重复定义
- 新增租户只需写 fixture 文件，不再改 Dart 代码
- 文档结构重组：主仓库 dev / ADD / DRD / 子模块 doc 分工明确

## v0.0.3

### 新增
- 量潮咨询详情页：双栏联动面板（信息看板 + 策略看板），支持发现记录、策略修正、决策链路管理
- 咨询数据模型（DiscoveryData / StakeholderData / StrategyRevisionData）及 JSON 加载服务
- 发现→策略强制联动：高风险/需关注发现自动追加策略审视记录
- ADD 架构设计文档

### 优化
- 导航重构：`_tenants` 改为实例字段，支持动态页面加载
- 资源注册：`qtconsult.json` 注册为 Flutter asset

## v0.0.2

### 新增
- 多租户架构：量潮创始人（全景图/思考/写作）与量潮科技（全景图/数据/课堂/咨询/云）
- 思考页面（ThinkingScreen）：认知建构与思维演进分析报告，包含阶段时间线、情绪统计、心智模型洞察
- 租户切换器（PopupMenuButton），支持一键切换租户及对应导航

### 优化
- 全景图页面支持动态租户名称
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
