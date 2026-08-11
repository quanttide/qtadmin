# ROADMAP — qtadmin Studio

qtadmin Studio 是治理思想的展示与执行载体（Flutter 客户端）。定位、主题与阶段规划见仓库根目录 `ROADMAP.md`。

## 版本目标

| 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `pubspec.yaml`、`CHANGELOG.md` | 0.1.3 | studio/v0.1.4 | 清理 router 死引用并确认可构建 |

版本规则：有 tag 时候选版本为最新 tag 的 patch+1；发布命令 `qtcloud-devops release publish -v studio/v0.1.4`。

## 路线

### 清理与起步（studio/v0.1.4）

- 移除 router 死引用：dashboard、think、qtclass 的 import 与路由条目，主项目只保留治理相关页面
- 确认 `flutter analyze` 与构建通过
- asset 可视化起步：读取 CLI 数据文件（`~/.local/share/qtadmin/`），落地双端数据共享
- 业务规则走 `FileSource` 配置化，不编入 freezed

完成标准：无死引用可构建；asset 页面能展示 CLI 数据文件内容。

### 执行环节可视化（studio/v0.2.0）

评审闭环 MVP，对齐意图 execute 的近期演化与洞察 review-path 四步路径：

- 摩擦登记：一次摩擦一条标准（条件 + 动作 + 证据）
- 角色槽位：任务类型 → 默认评审人
- 评审节点：执行完成后必须有明确评审人接收结果，通过 / 打回留痕
- 评审质量视图：打回原因聚类、标准库展示——评审即制度修订的可视化

### 治理可视化扩展（studio/v0.3.x）

- knowl 链路：acquire / extract / summary，状态承载（settled / evolving / draft）可视化
- delib 议事记录与决策留痕展示
- strategy 战略洞察展示（方向、张力、假设库）
- 责任链看板：分配 → 执行 → 评审 → 负责

## 原则

- 主项目只做路由聚合，页面由领域包承载；分包由人类决策
- 业务规则走配置化，不编入 freezed
- AI 产出必须可落地，落不了地的产出是债务，不进入封装
