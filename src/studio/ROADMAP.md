# ROADMAP — qtadmin Studio

qtadmin Studio 是量潮管理后台客户端。领域功能已全部移交各 qtcloud-* 产品线，当前为最小壳（导航框架 + 写作占位）。状态快照见 [STATUS.md](./STATUS.md)。

## 版本目标

| 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `pubspec.yaml`、`CHANGELOG.md` | 0.1.3 | 待定 | 方向确认后重新定义（当前无在途功能） |

版本规则：有 tag 时候选版本为最新 tag 的 patch+1；发布命令 `qtcloud-devops release publish -v studio/vX.Y.Z`。

## 路线

### 领域下线移交（已完成）

- dashboard、qtclass、think、qtconsult、org、recruitment 全部下线
- 参考实现与示例数据移交至对应产品线 `examples/`：qtcloud-asset、qtcloud-course、qtcloud-think、qtcloud-org、qtcloud-human
- 主项目精简为最小壳：无数据层、无状态机、无领域包，路由仅写作占位

### 方向选项（待决策）

1. **维持壳状态**：仅承载导航框架，领域功能持续由产品线提供，qtadmin 作为聚合入口
2. **恢复领域展示**：从产品线 `examples/` 引入参考实现（如组织管理、招聘计划），恢复治理可视化
3. **治理执行功能回归**：评审闭环等治理概念（角色槽位、评审节点、评审留痕、摩擦登记）由 qtadmin 承接，或由产品线承载

### 决策后的规划

方向确认后，本路线更新为对应阶段规划。

## 原则

- 领域实现从产品线引入，qtadmin 不做独立领域开发
- 恢复展示时优先复用产品线 `examples/` 参考实现，不重复造
- 业务规则走配置化，不编入模型
- AI 产出必须可落地，落不了地的产出是债务，不进入封装
