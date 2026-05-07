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

## Multi-Tenant 设计原则

**核心：一套代码复用，差异由数据驱动。** 不要用 if-else / 枚举分支区分租户。

**反例（本次踩坑）：**
```dart
// ❌ 两套列表 + TenantType 分支
_founderSections = _buildSections(TenantType.internal);
_companySections = _buildSections(TenantType.customer);
```

**正例（重构后）：**
```dart
// ✓ 单份 sections，无分支
void _buildSections() { /* 仅从 _data 构建 */ }
_TenantConfig(name: '量潮创始人', consultLabel: '咨询（自观）')
_TenantConfig(name: '量潮科技', consultLabel: '量潮咨询')
```

**判断标准：** 新增租户只需 fixture 数据文件 + 一行配置，不改代码。同构 = 代码结构同构，不只是 UI 像。

## Flutter 导航结构规范

所有租户共享同一套 `_NavSection`：

```
[全景图]         ← 概览
───────
[业务线条目...]   ← PanoramaData.businessUnits
───────
[职能线条目...]   ← PanoramaData.functionCards
───────
[咨询模块]       ← QtConsultData，标签由租户配置
```

- 不允许在不同租户间硬编码不同的导航项
- 业务和职能之间必须有分隔线
- 图标映射集中管理（`_iconForName`），不分散在 JSON 或租户配置中
