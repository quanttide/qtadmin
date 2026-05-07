# 导航栏实现检查记录

检查日期：2026-05-07

## 整体评价

核心原则均遵守：
- ✅ 数据驱动：导航项由 `PanoramaData.businessUnits` + `functionCards` 动态生成
- ✅ 共享 `_NavSection`：所有租户共用同一套 `_buildSections()`，无 if-else 分支
- ✅ `screenType` 路由正确：`detail` / `consulting` / `thinking` / `writing` 四种类型均已覆盖

## 发现的问题

### 1. `_iconForName()` 硬编码图标映射

**文件：** `main.dart:69-96`
**级别：** 低

```dart
IconData _iconForName(String name) {
    switch (name) {
      case '量潮数据': return Icons.storage_outlined;
      case '量潮课堂': return Icons.school_outlined;
      // ... 新增名称若不在 switch 中，静默降级为 circle_outlined
      default: return Icons.circle_outlined;
    }
}
```

**建议：** 在 `BusinessUnitData` / `FuncCardData` 的 fixture JSON 中加入 `icon` 字段，由数据驱动图标选择。

### 2. 咨询数据硬编码为客户租户

**文件：** `main.dart:149`
**级别：** 中

```dart
QtConsultLoader.load(tenant: TenantType.customer),  // 始终加载 customer
```

当前 founder 没有 `consulting` 类型，暂不触发。但如果 founder fixture 引入了咨询类型，会错误展示 company 的咨询数据。

**建议：** 按 `_selectedTenant` 加载对应的 consult data。

### 3. 死代码 `navigation_widget.dart`

**文件：** `lib/widgets/navigation_widget.dart`
**级别：** 低

旧版导航组件，使用 `Navigator.pushNamed` + 路由表方案，未被任何文件引用。

**建议：** 删除该文件。

### 4. 多余分隔线

**文件：** `main.dart:_buildSidebar()`
**级别：** 低

全景图上方多了一个 `_buildDivider()`，与 `docs/ixd/navigation.md` 规格图不符（规格图全景图上无分隔线）。

**建议：** 调整 divider 逻辑，移除全景图上方的分隔线。
