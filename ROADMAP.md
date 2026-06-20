# Roadmap

## 定位

qtadmin 是量潮管理后台，覆盖公司内部各业务线与职能领域。

## 版本策略

- `v0.0.x` — 探索验证期，逐步补齐各领域最小可用能力
- `v0.1.0` — 首个稳定版本，覆盖足够支撑日常管理

## ✅ 已完成（v0.0.3 ~ v0.0.14）

- `qtrecurit status` — 招聘数据统计
- `human status` — 月度招聘计划与进度管理
- `connect` — 沟通连接职能域，`email/lark` 邮件通道
- 架构分层：业务域（qt-前缀）与职能域（无前缀）分离
- XDG 规范：`QTRECURIT_CONFIG` / `QTRECURIT_DATA` 环境变量
- `asset archive` — 日志归档
- `asset status` — 结构合规检查
- `asset quality` — 语义质量评估（叙事/知识/认知三维度）

## v0.1.0 目标

### 🏗️ 跨域：以 profile 为事实源

将 `data/profile/` 作为业务事实的权威来源，CLI 改为从 profile 加载数据而非硬编码：

- [ ] 执行框架从 `profile/execute/` 加载，支持动态命令注册

  **现状：** 每个 CLI 子命令（`asset archive`、`asset status`、`asset quality`）都在 Rust 代码中硬编码注册。领域增减需要修改代码、重新编译。

  **目标：** CLI 读取 `profile/execute/` 下的领域定义，自动注册对应命令，新增领域只需在 profile 加目录。

  **步骤：**

  1. 定义执行框架格式：调研 `profile/execute/` 现有结构，设计命令描述规范（命令名、参数、执行逻辑引用）
  2. 新增 `ExecuteFramework` 加载器：从 `profile/execute/` 读取领域定义，解析为结构化配置
  3. 实现动态派发器：根据加载的领域定义，在 CLI 中动态生成子命令树
  4. 迁移现有命令：将 `asset archive` 等现有命令的执行逻辑改为可被框架引用的形式
  5. 新增领域流程：从 `profile/execute/` 加一个新目录 → 重新运行 CLI 即可看到新命令
  6. 更新测试：验证动态命令注册和派发正确性
- [ ] 质量评估标准定义在 profile 中，CLI 运行时读取而非代码硬编码

### human — 人力资源职能域

- [ ] 人事档案：员工信息增删查改
- [ ] 考勤管理：打卡记录、请假审批
- [ ] 绩效管理：考核周期、评分录入

### asset — 数字资产职能域

- [ ] 资产生命周期：领用、归还、报废

### connect — 沟通连接职能域

- [ ] `email/wecom` — 企业微信邮件通道
- [ ] `message/lark` — Lark IM 通知

### 质量要求

- [ ] 测试覆盖率 ≥ 85%
- [ ] 所有命令有 `--help` 完整文档
