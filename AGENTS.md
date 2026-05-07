# Agent Guidelines for qtadmin

> **必读：** 先读 `CONTRIBUTING.md`（团队公约）、`README.md`（项目概览）、`ROADMAP.md`（路线规划）。

## Project Overview

qtadmin is evolving from a payroll-focused backend into QuantTide's second-brain platform.

Current implementation is still centered on a Python FastAPI backend (`src/provider/`) with a Flutter client
(`src/studio/`).

## Documentation Workflow

Documentation follows role-based structure:

- `docs/dev/` - Development documentation (technical specs, API docs)
- `docs/ops/` - Operations documentation (deployment, maintenance)

Rules:
- `README.md` files are for **workflow/process** information.
- `index.md` files are for **content/summary** information.
- If a workflow rule changes, update the relevant `README.md` first.

## Multi-Tenant 设计原则

### 核心：一套代码复用，差异由数据驱动

多租户场景下，**不要用 if-else / 枚举分支 去区分租户行为**。差异应放在数据层（fixture / 配置），代码层只复用一套逻辑。

**反例（本次踩坑）：**
```dart
// ❌ 两套列表 + TenantType 分支
_founderSections = _buildSections(TenantType.internal);
_companySections = _buildSections(TenantType.customer);

List<_NavSection> _buildSections(TenantType type) {
  if (type == internal) { ... } else { ... }
}
```

**正例（重构后）：**
```dart
// ✓ 单份 sections，无分支
void _buildSections() { /* 仅从 _data 构建 */ }

// 差异在配置层
_TenantConfig(name: '量潮创始人', consultLabel: '咨询（自观）')
_TenantConfig(name: '量潮科技', consultLabel: '量潮咨询')
```

### 判断标准
- 如果新增一个租户需要改代码（加 if-else、加枚举值），说明设计有问题
- 新增租户应只需要新增 fixture 数据文件 + 一行配置
- "同构" = 代码结构同构，不只是 UI 长得像

## Flutter / Studio 开发

### 导航结构规范

导航栏采用数据驱动分组结构，所有租户共享同一套 `_NavSection`：

```
[全景图]         ← 概览
───────
[业务线条目...]   ← 来自 PanoramaData.businessUnits
───────
[职能线条目...]   ← 来自 PanoramaData.functionCards
───────
[咨询模块]       ← 来自 QtConsultData，标签由租户配置
```

- 不允许在不同租户间硬编码不同的导航项集合
- 业务和职能两个域必须用分隔线隔开
- 导航项图标映射集中管理（`_iconForName`），而非分散在 JSON 或各租户配置中

## Utilities

### Taking Screenshots
Use Python with Pillow:
```python
from PIL import ImageGrab
img = ImageGrab.grab()
img.save('docs/user/screenshot.png')
```
Requires `pip install Pillow`.
