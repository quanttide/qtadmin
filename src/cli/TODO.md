# TODO

## 阶段一：`qtrecurit status` 核心功能

### 命令骨架
- [ ] 创建 `src/qtrecurit/` 模块（mod.rs + status.rs）
- [ ] 在 `main.rs` 添加 `mod qtrecurit;`
- [ ] 在 `cli.rs` 注册 `Qtrecurit` 命令变体
- [ ] 添加 `serde_json` 依赖到 Cargo.toml

### 数据获取
- [ ] 实现 `fetch_all_mailbox` — 调用 `lark-cli mail` 分页拉取（上限20轮）
- [ ] 超时处理（15s）
- [ ] 错误处理：lark-cli 不可用时给出明确提示

### 岗位分类（TOML 配置化）
- [ ] 创建 `src/qtrecurit/config.rs` — 配置加载模块
- [ ] 添加 `toml` 依赖到 Cargo.toml
- [ ] 定义 `PositionRule` 结构体（name / keywords / exclude / priority）
- [ ] 定义 `QtrecuritConfig` 结构体（包裹 `Vec<PositionRule>`）
- [ ] 实现配置发现：`QTRECURIT_CONFIG` 环境变量 → `./qtrecurit.toml` → `~/.config/qtadmin/qtrecurit.toml` → 内置默认规则
- [ ] 内置 8 个岗位默认规则作为兜底（全栈工程师、数据工程师、新媒体运营、商务经理、项目经理、产品经理、课程助教、销售经理、人事经理）
- [ ] 实现两级分类：
  - 优先从 `[岗位]` / `岗位：` 格式提取
  - 降级：全主题关键词匹配（注意 exclude 排除词，避免"数据运营"误分）
- [ ] 规则文件变化无需重新编译，重启 CLI 即生效

### 日期筛选与解析
- [ ] 实现 CLI 参数：`--days`、`--start`、`--end`
- [ ] 默认值：本月
- [ ] 健壮的日期解析：兼容 ISO 8601 / RFC 2822 / 正则降级
- [ ] 调用 `filter_by_date` 对邮件列表筛选

### 报告输出
- [ ] 投递总量 + 可识别岗位占比
- [ ] 岗位分布表格（按投递数降序）
- [ ] 投递趋势表格（含环比箭头 ↑/↓/-）
- [ ] 日均投递 + 最高峰日
- [ ] 未识别邮件样本（前10条），辅助完善分类规则
- [ ] 标题根据日期范围动态生成

## 阶段二：质量加固与发布

- [ ] 单元测试覆盖 classify、filter_by_date、extract_date
- [ ] 集成测试（assert_cmd + predicates）
- [ ] 更新 CHANGELOG.md
- [ ] 更新 Cargo.toml 版本号到 0.0.3
- [ ] 标签发布 `cli/v0.0.3`
