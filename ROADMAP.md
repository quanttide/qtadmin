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

- [ ] 分类规则从 `profile/connect/rules.json` 加载，移除 `human/config.rs` 硬编码

  **现状：** `human/config.rs` 中 `builtin_rules()` 硬编码了 12 个岗位规则。`profile/connect/rules.json` 已有同样的规则数据（含 id/name/keywords/exclude/priority），两边重复维护。

  **目标：** CLI 启动时从 `data/profile/connect/rules.json` 加载规则，移除硬编码。

  **步骤：**

  1. 新增 `ProfileRuleLoader`：接收 profile 仓库路径，读取并解析 `connect/rules.json`
  2. `load_config()` 的 fallback 链改为：`QTRECURIT_CONFIG` → `qtrecurit.toml` → `profile/connect/rules.json` → `builtin_rules()`（过渡期保留）
  3. 移除 `builtin_rules()` 中的 12 个规则，保留空列表作为最终 fallback
  4. 新增 `QTRECURIT_PROFILE` 环境变量，指向 profile 仓库路径（默认 `../../data/profile`）
  5. 更新测试：`test_builtin_rules_not_empty` → `test_profile_rules_loaded`
  6. 清理：删除 `qtrecurit.toml`（如果规则已全部迁移到 profile）
- [ ] 执行框架从 `profile/execute/` 加载，支持动态命令注册
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
