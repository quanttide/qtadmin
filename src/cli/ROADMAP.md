# ROADMAP — qtadmin CLI

qtadmin CLI 是数字资产管理工具与职能域执行入口。各职能域已迁移至产品线仓库（qtcloud-connect/human/business 的 src/cli、qtcloud-knowl 重构、qtcloud-asset examples），本 CLI 为空壳。

## 版本目标

| 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `Cargo.toml`、`CHANGELOG.md` | 0.0.17 | cli/v0.1.0 | Cargo.toml 升 0.1.0，CHANGELOG 补 [0.1.0] 条目 |

版本发布规范见 `CONTRIBUTING.md`：单一数据源 `Cargo.toml`，标签 `cli/v<version>`。

## 路线

### 版本收敛（0.1.0）

- `Cargo.toml` 升 0.1.0，`CHANGELOG.md` 补 [0.1.0] 条目
- 发布 `cli/v0.1.0`，标志探索期结束、进入上线推进阶段

### 分化（0.2.x）

- 业务域移回各平台：qtclass、qtcloud、qtconsult、qtdata、qtrecurit 状态能力归各自仓库
- 职能域下沉领域层：human、asset、connect 的规则与数据定义沉淀到领域档案与规格
- CLI 只保留执行入口与跨领域交叉编排点

## 历史

- share 模块（v0.0.17 已完成）：私仓代码脱敏发布公仓的工具链，规划见 git 提交 `244aa09`
