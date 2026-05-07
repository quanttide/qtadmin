# 多租户架构原则

## 状态

已采纳（2026-05 本次重构确定）

## 上下文

qtadmin 当前有两个租户（量潮创始人、量潮科技），未来可能继续增加。最初的导航实现为每个租户硬编码了一套导航项列表，并在 `_buildSections` 中通过 `TenantType` 枚举分支区分行为。

这导致：

- 新增租户需要改代码（加 if-else 分支）
- 两套列表带来维护负担，容易不同步
- 代码无法复用，违背 DRY

## 决策

**一套代码复用，差异由数据驱动。**

- 导航结构由 `PanoramaData`（业务线 + 职能线）动态生成，所有租户共用
- 租户间的差异（如咨询模块的标签）放在配置层（`_TenantConfig`），不进入业务逻辑
- 不允许在代码中使用 `TenantType` 枚举分支来区分租户行为

### 反例（本次踩坑）

```dart
// ❌ 两套列表 + TenantType 分支
_founderSections = _buildSections(TenantType.internal);
_companySections = _buildSections(TenantType.customer);

List<_NavSection> _buildSections(TenantType type) {
  if (type == internal) { ... } else { ... }
}
```

### 正例（重构后）

```dart
// ✓ 单份 sections，无分支
void _buildSections() { /* 仅从 _data 构建 */ }

// 差异在配置层
_TenantConfig(name: '量潮创始人', consultLabel: '咨询（自观）')
_TenantConfig(name: '量潮科技', consultLabel: '量潮咨询')
```

## 判断标准

- 新增一个租户是否需要改代码（加 if-else、加枚举值）？需要则说明设计有问题
- 新增租户应只需要: (1) 新增 fixture 数据文件 (2) 新增一行配置
- "同构" = 代码结构同构，不只是 UI 长得像

## 影响

正面：

- 新增租户成本极低，不改核心代码
- 所有租户的导航结构自动一致（同构）
- 业务线和职能线的展现自动跟随数据

约束：

- 配置层必须覆盖所有租户间差异，无法处理的差异需要重新审视设计
- 数据文件（fixture）是所有租户行为差异的唯一来源
