# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

## [0.0.3] - 2026-05-06

### Added

- `src/studio/`: 多租户架构
  - 量潮创始人：全景图 + 思考（认知演进报告）+ 写作（占位）
  - 量潮科技：全景图 + 量潮数据/课堂/咨询/云
  - 租户切换器（PopupMenuButton），支持一键切换
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
