# 分包方案

## 当前问题

`lib/models/` 下 6 个领域混在同一目录，随新增领域持续膨胀：

| 文件 | 领域 | 跨应用潜力 |
|------|------|-----------|
| `org.dart` | 组织管理 | 中 — `qtcloud-hr` 可能需要 |
| `qtconsult.dart` | 咨询 | 高 — 与 `qtconsult` 重叠 |
| `qtclass.dart` | 课堂 | 高 — 与 `qtclass` 重叠 |
| `thinking.dart` | 思考 | 中 — `qtcloud-think` 可能需要 |
| `dashboard.dart` | 仪表盘 | 低 — qtadmin 专属 |
| `metadata.dart` | 导航结构 | 低 — qtadmin 专属 |

不分包的问题：每增加一个功能域都在已有目录里追加文件，领域边界模糊，跨 app 复用只能靠复制。

## 分包架构

按领域分包，参考 `qtconsult` 的三层模式：

```
src/studio/
├── packages/
│   ├── qtadmin-org/         ← 组织管理（Freezed 模型）
│   ├── qtadmin-qtconsult/   ← 咨询（Freezed 模型 + UI 组件？）
│   ├── qtadmin-qtclass/     ← 课堂
│   └── qtadmin-think/       ← 思考
├── lib/
│   ├── models/              ← 仅保留 dashboard + metadata
│   └── ...
```

### 各包方案

| 领域 | 是否独立包 | 理由 | 与 `quanttide-project-toolkit` 关系 |
|------|-----------|------|-----------------------------------|
| `qtconsult.dart` | `packages/qtadmin-qtconsult` | 与 qtconsult 共享领域模型，未来应统一引用 `quanttide_project` | 引入 `quanttide_project`，私有适配层覆盖 OODA 特化 |
| `qtclass.dart` | `packages/qtadmin-qtclass` | 与 qtclass 共享，模型独立无外部依赖 | 不依赖，纯领域模型 |
| `thinking.dart` | `packages/qtadmin-think` | 跨 app 思考记录模型 | 不依赖 |
| `org.dart` | `packages/qtadmin-org` | 组织架构模型，hr 等场景复用 | 不依赖 |
| `dashboard.dart` | 留在 `lib/models/` | 专属聚合视图，无复用 | — |
| `metadata.dart` | 留在 `lib/models/` | 导航配置，app 专属 | — |

### 提取原则

每个包独立开发、独立测试（测试随包一起提取）、独立版本。提取节奏按需进行，不搞大版本重构：

1. 先提取 `qtadmin-qtconsult`（与 qtconsult 重叠最多，复用收益最高）
2. 按需提取 `qtadmin-qtclass` 和 `qtadmin-think`（需求稳定再动）
3. `qtadmin-org` 待第二个消费者出现再提取

## 与平台层的关系

通用项目模型（Board, BoardCard, Project）应从 pub.dev 引入 `quanttide_project`（来自 `packages/quanttide-project-toolkit`），不在 qtadmin 内重复定义。当通用模型无法满足管理后台需求时，在对应私有包内做适配，不修改通用模型。
