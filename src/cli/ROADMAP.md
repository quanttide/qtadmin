# Roadmap: v0.0.3 — `qtrecurit status` 子命令

## 动机

- **业务扩展**：量潮招聘业务线（qtrecurit）需要 CLI 数据统计入口，集成到 qtadmin 统一入口
- **统一入口**：所有 QuantTide 业务线运维工具集中到 `qtadmin`，避免分散的独立 CLI

## 设计原则

以 `examples/qtrecurit/stats.py` 为蓝本，保留其优秀脚本思维，在 Rust 重写中强化以下亮点：

| 原亮点 | Rust 中继承 | 强化方向 |
|--------|-------------|----------|
| 调用 lark-cli 而非 SDK | `std::process::Command` | 保持工具链胶水思维，不引入飞书 SDK |
| 分页拉取 + 上限保护 | 同上 | 保持 range(20) 防死循环 |
| 区分可识别/不可识别投递 | 保留 identified 计算 | **强化**：输出未识别邮件样本，反哺分类规则 |
| Markdown 表格输出 | 保留 | **强化**：加入趋势标记（日均值、最高峰、环比箭头） |
| 职责单一的函数拆分 | 保持同样结构 | **强化**：分类规则从硬编码 if/elif 升级为配置化 |

## 版本策略

保持 `cli/v0.0.x` 版本线，每阶段交付独立 release。v0.0.3 仅聚焦 `qtrecurit status` 一个子命令。

## 阶段划分

### 阶段一：`qtrecurit status` 核心功能（3-5天）

基于 `examples/qtrecurit/stats.py` 功能升级为 Rust 子命令：

- 创建 `src/qtrecurit/` 模块目录（mod.rs + status.rs）
- 在 `main.rs` / `cli.rs` 注册 `qtrecurit` 顶级子命令
- 实现 `qtrecurit status` 命令，包含以下功能：

**1. 数据获取**
- `fetch_all_mailbox` — 调用 `lark-cli mail` 分页拉取 HR 邮箱邮件
- 设置分页上限（20轮）防止死循环
- 超时处理（15s）

**2. 岗位分类（TOML 配置化）**
- 岗位规则定义为 TOML 配置文件（`[[rules]]` 表数组），而非 `if/elif` 硬编码
- 配置发现顺序：`QTRECURIT_CONFIG` 环境变量 → 项目根目录 `qtrecurit.toml` → `~/.config/qtadmin/qtrecurit.toml` → 内置默认规则（8个岗位兜底）
- 每条规则：`name` / `keywords`（匹配关键词） / `exclude`（排除词） / `priority`（优先级权重）
- 支持两级匹配：先尝试从 `[岗位]` 或 `岗位：` 格式中提取，再全主题降级匹配
- 新增岗位只需改 TOML 文件，无需重新编译

**3. 日期筛选**
- `--days <N>` — 最近 N 天
- `--start <YYYY-MM-DD>` — 起始日期
- `--end <YYYY-MM-DD>` — 结束日期
- 默认：本月
- 日期解析需兼容多种格式（ISO、RFC 2822 等），确保健壮性

**4. 报告输出（Markdown）**
- 投递总量 + 可识别岗位占比
- 岗位分布表格（按投递数降序）
- 投递趋势表格（含环比箭头 `↑` / `↓` / `-`）
- 日均投递 + 最高峰日
- 未识别邮件样本（前10条），辅助完善分类规则

### 阶段二：质量加固与发布（2天）

- 集成测试（assert_cmd + predicates）
- 更新 CHANGELOG.md
- 更新 Cargo.toml 版本号到 0.0.3
- 标签发布 `cli/v0.0.3`

## 非目标

- 不引入数据库依赖
- 不实现简历管理、面试管理、职位 CRUD
- 不替代 `lark-cli`（保持 subprocess 胶水模式）
- 不引入飞书 SDK / OAuth 认证

## Rust 技术选型

| 领域 | 选型 | 理由 |
| --- | --- | --- |
| CLI 框架 | `clap` v4 (derive) | 已有，保持一致 |
| 子进程 | `std::process::Command` | 调用 lark-cli |
| JSON 解析 | `serde_json` | 解析 lark-cli 输出 |
| 配置格式 | `toml` | 加载岗位规则配置文件 |
| 日期时间 | `chrono` | 已有，强类型避免 Python 版日期陷阱 |
| 错误处理 | `anyhow` + `thiserror` | 已有 |
| 测试 | `assert_cmd` + `predicates` | 已有 |

## 项目结构（v0.0.3 目标）

```
cli/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── cli.rs
│   ├── git_utils.rs
│   ├── asset/
│   │   ├── mod.rs
│   │   ├── backup.rs
│   │   └── audit.rs
│   ├── qtrecurit/
│   │   ├── mod.rs          # 命令枚举 + dispatch
│   │   ├── status.rs       # status 命令全量逻辑
│   │   └── config.rs       # TOML 配置加载 + PositionRule 数据结构
├── tests/
│   ├── test_backup.rs
│   ├── test_audit.rs
│   └── test_qtrecurit.rs
├── CHANGELOG.md
├── CONTRIBUTING.md
└── ROADMAP.md
```
