# Roadmap

## ✅ v0.0.3 — `qtrecurit status` 子命令（已完成）

**交付版本**：`cli/v0.0.3`  
**交付日期**：2026-06-16  
**标签**：https://github.com/quanttide/qtadmin/releases/tag/cli/v0.0.3

### 动机

- **业务扩展**：量潮招聘业务线（qtrecurit）需要 CLI 数据统计入口，集成到 qtadmin 统一入口
- **统一入口**：所有 QuantTide 业务线运维工具集中到 `qtadmin`，避免分散的独立 CLI

### 设计原则

以 `examples/qtrecurit/stats.py` 为蓝本，保留其优秀脚本思维，在 Rust 重写中强化以下亮点：

| 原亮点 | Rust 中继承 | 强化方向 |
|--------|-------------|----------|
| 调用 lark-cli 而非 SDK | `std::process::Command` | 保持工具链胶水思维，不引入飞书 SDK |
| 分页拉取 + 上限保护 | 同上 | 保持 range(20) 防死循环 |
| 区分可识别/不可识别投递 | 保留 identified 计算 | **强化**：输出未识别邮件样本，反哺分类规则 |
| Markdown 表格输出 | 保留 | **强化**：加入趋势标记（日均值、最高峰、环比箭头） |
| 职责单一的函数拆分 | 保持同样结构 | **强化**：分类规则从硬编码 if/elif 升级为配置化；再拆分为 connect/human/status 三层 |

### 完成内容

- `qtrecurit status` 命令：`--days` / `--start` / `--end` 日期筛选
- TOML 配置化的岗位分类规则（9 个岗位兜底），`QTRECURIT_CONFIG` 环境变量发现
- 两级匹配：`[岗位]` 提取 → 全主题关键词降级（exclude 排除词防误分）
- Markdown 报告：总量 + 岗位分布 + 投递趋势（环比箭头）+ 未识别样本
- 73 个测试（67 单元 + 6 集成）

### 项目结构（v0.0.3 实际）

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
│   │   ├── connect.rs      # 数据连接层（lark-cli，可复用）
│   │   ├── human.rs        # HR 领域层（分类 + 报告，可复用）
│   │   ├── status.rs       # 编排层
│   │   └── config.rs       # TOML 配置加载
├── tests/
│   ├── test_backup.rs
│   ├── test_audit.rs
│   └── test_qtrecurit.rs
├── CHANGELOG.md
├── CONTRIBUTING.md
└── ROADMAP.md
```

## 下一步规划

（v0.0.4 待定）
