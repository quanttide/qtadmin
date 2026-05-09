# 分包方案

## 当前问题

`lib/models/` 下 6 个领域混在同一目录，随新增领域持续膨胀；同时对应的 blocs、screens、views 也散落在各自目录中，领域边界模糊，跨 app 复用只能靠复制。

| 领域 | 文件 | 跨应用潜力 |
|------|------|-----------|
| 组织管理 | `models/org.dart` + `screens/org_screen.dart` | 中 — `qtcloud-hr` 可能需要 |
| 咨询 | `models/qtconsult.dart` + `blocs/consult_bloc.dart` + `screens/qtconsult_screen.dart` | 高 — 与 `qtconsult` 重叠 |
| 课堂 | `models/qtclass.dart` + `screens/qtclass_screen.dart` | 高 — 与 `qtclass` 重叠 |
| 思考 | `models/thinking.dart` + `screens/thinking_screen.dart` | 中 — `qtcloud-think` 可能需要 |
| 仪表盘 | `models/dashboard.dart` + screens + views | 低 — qtadmin 专属 |
| 导航结构 | `models/metadata.dart` | 低 — qtadmin 专属 |

## 分包架构

按领域分包，每个包包含完整的领域层：模型、BLoC、页面、UI 组件、测试。

```
src/studio/
├── packages/
│   ├── qtadmin-org/           ← 组织管理
│   │   ├── lib/
│   │   │   ├── org.dart           (Freezed 模型)
│   │   │   └── src/
│   │   │       ├── blocs/         (OrgBloc)
│   │   │       ├── screens/       (OrgScreen)
│   │   │       └── views/         (小组件)
│   │   └── test/
│   ├── qtadmin-qtconsult/     ← 咨询
│   │   ├── lib/
│   │   │   ├── qtconsult.dart     (Freezed 模型)
│   │   │   └── src/
│   │   │       ├── blocs/         (ConsultBloc)
│   │   │       ├── screens/       (QtConsultScreen)
│   │   │       └── views/
│   │   └── test/
│   ├── qtadmin-qtclass/       ← 课堂
│   │   └── ...
│   └── qtadmin-think/         ← 思考
│       └── ...
├── lib/
│   ├── models/                ← 仅保留 dashboard + metadata
│   ├── blocs/                 ← 仅保留 AppBloc
│   ├── screens/               ← 仅保留 dashboard + 通用 screens
│   └── views/                 ← 仅保留通用 UI 组件
```

### 各包方案

| 领域 | 独立包 | 包含内容 | 复用目标 |
|------|-------|---------|---------|
| `qtconsult` | `packages/qtadmin-qtconsult` | 模型 + ConsultBloc + ConsultScreen + UI 组件 | `qtconsult` 项目，共享模型和业务逻辑 |
| `qtclass` | `packages/qtadmin-qtclass` | 模型 + QtClassScreen + UI 组件 | `qtclass` 项目，共享模型和业务逻辑 |
| `thinking` | `packages/qtadmin-think` | 模型 + ThinkingScreen | `qtcloud-think`，共享思考记录模型 |
| `org` | `packages/qtadmin-org` | 模型 + OrgScreen + UI 组件 | `qtcloud-hr`，共享组织架构模型 |
| `dashboard` | 留在主项目 | — | 专属聚合视图，无复用 |
| `metadata` | 留在主项目 | — | 导航配置，app 专属 |

### 提取原则

每个包独立开发、独立测试、独立版本。提取节奏按需进行，不搞大版本重构：

1. **先提取模型**（已完成）—— 解耦数据定义，获得立即的构建隔离
2. **逐步迁移业务逻辑和 UI** —— 随需求稳定，逐个搬入包内
3. **跨 app 复用前不强制** —— 等到第二个消费者出现时再补齐包内完整内容

## 与平台层的关系

通用项目模型（Board, BoardCard, Project）应从 pub.dev 引入 `quanttide_project`（来自 `packages/quanttide-project-toolkit`），不在 qtadmin 内重复定义。当通用模型无法满足管理后台需求时，在对应私有包内做适配，不修改通用模型。
