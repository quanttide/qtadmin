# Agent Guidelines for qtadmin

> **必读：** 先读 `CONTRIBUTING.md`（团队公约）、`README.md`（项目概览）、`ROADMAP.md`（路线规划）。

## Project Overview

qtadmin 是 QuantTide 的第二大脑平台。当前重心在 Flutter 客户端（`src/studio/`），后端（`src/provider/`）处于维护状态。详见 `ROADMAP.md`。

## 常用命令

```bash
# Studio
cd src/studio
flutter run -d linux            # Linux 桌面
flutter run -d chrome           # Web
dart analyze lib/               # 静态检查

# Provider（维护态）
cd src/provider
pdm run uvicorn app:app --reload
pytest
```

## Documentation Workflow

- `docs/dev/` — 开发文档（技术规格、API）
- `docs/ops/` — 运维文档（部署、维护）
- `README.md` — 流程/操作信息
- `index.md` — 内容/摘要信息

## 多Workspace工作空间设计原则

详见 `docs/add/multi-workspace.md`。
**一句话：** 一套代码复用，差异由数据驱动。不要用 if-else / 枚举分支区分Workspace工作空间。新增Workspace工作空间只需 fixture + 一行配置，不改代码。

## Flutter 导航结构规范

详见 `docs/ixd/navigation.md`。
**要点：** 所有Workspace工作空间共享同一套 `_NavSection`（全景图 → 业务线 → 职能线 → 咨询），不允许硬编码差异。业务和职能之间必须用分隔线隔开。
