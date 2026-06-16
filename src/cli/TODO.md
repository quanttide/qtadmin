# TODO

## 阶段一：`qtrecurit status` 核心功能

### 命令骨架
- [x] 创建 `src/qtrecurit/` 模块（mod.rs + status.rs）
- [x] 在 `main.rs` 添加 `mod qtrecurit;`
- [x] 在 `cli.rs` 注册 `Qtrecurit` 命令变体
- [x] 添加 `serde_json` 依赖到 Cargo.toml

### 数据获取
- [x] 实现 `fetch_all_mailbox` — 调用 `lark-cli mail` 分页拉取（上限20轮）
- [x] 超时处理（15s）
- [x] 错误处理：lark-cli 不可用时给出明确提示

### 岗位分类（TOML 配置化）
- [x] 创建 `src/qtrecurit/config.rs` — 配置加载模块
- [x] 添加 `toml` 依赖到 Cargo.toml
- [x] 定义 `PositionRule` 结构体（name / keywords / exclude / priority）
- [x] 定义 `QtrecuritConfig` 结构体（包裹 `Vec<PositionRule>`）
- [x] 实现配置发现：`QTRECURIT_CONFIG` 环境变量 → `./qtrecurit.toml` → `~/.config/qtadmin/qtrecurit.toml` → 内置默认规则
- [x] 内置 9 个岗位默认规则作为兜底
- [x] 实现两级分类
- [x] 规则文件变化无需重新编译，重启 CLI 即生效

### 日期筛选与解析
- [x] 实现 CLI 参数：`--days`、`--start`、`--end`
- [x] 默认值：本月
- [x] 健壮的日期解析：兼容 ISO 8601 / YYYY-MM-DD / 正则降级
- [x] 调用 `filter_by_date` 对邮件列表筛选

### 报告输出
- [x] 投递总量 + 可识别岗位占比
- [x] 岗位分布表格（按投递数降序）
- [x] 投递趋势表格（含环比箭头 ↑/↓/-）
- [x] 日均投递 + 最高峰日
- [x] 未识别邮件样本（前10条），辅助完善分类规则
- [x] 标题根据日期范围动态生成

## 阶段二：质量加固与发布

- [x] 单元测试覆盖 classify、filter_by_date、extract_date
- [x] 集成测试（assert_cmd + predicates）
- [x] 更新 CHANGELOG.md
- [x] 更新 Cargo.toml 版本号到 0.0.3
- [x] 标签发布 `cli/v0.0.3`
