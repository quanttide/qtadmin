# ROADMAP — qtadmin 工作蓝图

qtadmin 是企业治理思想和制度的平台化载体，不是管理系统的集合。路线图服务于三支柱（asset 资产管理、delib 议事设计、strategy 战略发现）的落地，演进路径遵循「先集中、后分化、再连接」的阶段论。

## 阶段现状

实现停留在集中期，意图已走向连接期。集中期的形态是用广度试探深度：CLI 十二个领域命令覆盖全部业务域和部分职能域，Studio 完成分包但页面目录为空。差距分析见 `data/insight/qtadmin/intention-gap.md`，切换判据（领域已有自己的容器、堆功能边际成本超收益）已满足，下一步是分化。

## 版本目标

版本目标与 `qtcloud-devops` 工具对齐：无历史 tag 时工具候选版本为 `scope/v0.1.0`，有 tag 时候选为最新 tag 的 patch+1。已独立演进的 scope（studio）以现状版本对齐，不降版本。

| scope | 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:------|:--------:|:--------:|:--------:|----------|
| root | `pyproject.toml`、`CHANGELOG.md` | 0.1.1 | v0.1.1 | 已就绪，待发首个 tag |
| cli | `src/cli/Cargo.toml`、`src/cli/CHANGELOG.md` | 0.0.17 | cli/v0.1.0 | Cargo.toml 升 0.1.0，CHANGELOG 补 [0.1.0] 条目 |
| studio | `src/studio/pubspec.yaml`、`src/studio/CHANGELOG.md` | 0.1.3 | studio/v0.1.3 | 已就绪，待发首个 tag |
| provider | `src/provider/internal/version/version.go`、`src/provider/CHANGELOG.md` | 0.0.1 | provider/v0.1.0 | version.go 升 0.1.0，CHANGELOG 补 [0.1.0] 条目 |

版本规则：

- root 标签使用纯版本号 `vX.Y.Z`，不带 scope 前缀；scope 标签使用 `scope/vX.Y.Z` 格式
- root 目标定为 v0.1.1 而非 v0.1.0，因为版本载体已停在 0.1.1，发 tag 不做版本回退
- cli 与 provider 从 0.0.x 升到 0.1.0，标志探索期结束、进入上线推进阶段
- 发布命令：`qtcloud-devops release publish -v <目标版本>`

## 阶段规划

### 版本收敛（v0.1.x）

补齐 cli 与 provider 的 0.1.0 对齐（版本载体 + CHANGELOG），完成 root、cli、studio、provider 四个 scope 的首轮发布，让发布审计全绿。

### 分化（v0.2.x）

- 业务域移回各平台：qtclass、qtcloud、qtconsult、qtdata、qtrecurit 的状态能力归各自仓库
- 职能域下沉领域层：human、asset、connect 的规则与数据定义沉淀到领域档案与规格，CLI 只保留执行入口
- Studio 从 asset 起步：读取 CLI 数据文件做资产治理可视化，落地双端共享

### 连接（v0.3.x）

- delib 载体：议事记录与决策留痕的最小闭环
- strategy 载体：战略第二大脑，事实审计加反事实推演，假设库结构化
- 交叉编排：产教融合等跨平台思考方式，把各平台工作整合成学习进度
- 封装边界：AI 产出必须可落地，落不了地的产出是债务，不进入封装

## 各 scope 路线

### cli

- 现状：十二个领域命令，asset 三子命令（archive、status、quality）已成型
- 分化后仅保留跨领域交叉编排点与执行入口
- 版本：0.0.17 → 0.1.0，探索期结束

### studio

- 现状：领域分包完成（qtadmin-org、qtadmin-qtconsult 等），`lib/screens/` 页面目录为空
- 下一步：从 asset 治理可视化起步，再扩展 delib、strategy
- 版本：0.1.3 独立演进，首个 tag 与现状对齐

### provider

- 现状：维护态，Go 重构后无新功能规划
- 仅做版本对齐（0.0.1 → 0.1.0），不做功能扩展
