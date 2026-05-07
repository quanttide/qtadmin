# 导航结构规范

## 布局

72px 宽的左侧导航栏，竖向排列，从上到下依次为：

```
┌────────────┐
│  租户切换器  │  PopupMenuButton，点击切换租户
├────────────┤
│  全景图      │
├────────────┤
│  量潮数据    │  业务线（来自 PanoramaData.businessUnits）
│  量潮课堂    │
│  量潮咨询    │
│  量潮云      │
├────────────┤
│  人力资源    │  职能线（来自 PanoramaData.functionCards）
│  财务管理    │
│  组织管理    │
│  战略管理    │
│  新媒体      │
├────────────┤
│  咨询（自观）│  咨询模块，标签由租户配置决定
├────────────┤
│  空白占位    │
└────────────┘
```

## 设计规则

### 数据驱动

- 导航项由 `PanoramaData` 动态生成，不硬编码
- 所有租户共享同一套 `_NavSection` 结构
- 业务线和职能线的顺序、内容完全由数据决定

### 区域分隔

- 业务线和职能线之间必须有分隔线（Divider）
- 每个区域之间都必须有分隔线
- 不允许删除或合并分隔线

### 图标管理

- 导航项图标集中映射在 `_iconForName()` 中
- 不允许在 JSON fixture 或租户配置中指定图标
- 新增业务/职能名称时必须先在 `_iconForName()` 中添加映射

## 导航结构

```dart
class _NavSection {
  final List<_NavItem> items;
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget Function(PanoramaData, String tenantName) builder;
}
```

四个固定区域：

| 区域 | 数据源 | 说明 |
|------|--------|------|
| 全景图 | 固定 | 概览页，始终第一个 |
| 业务线 | `PanoramaData.businessUnits` | 每个 unit 一个导航项 |
| 职能线 | `PanoramaData.functionCards` | 每个 card 一个导航项 |
| 咨询模块 | 租户配置 | 标签和页面数据源由租户决定 |
