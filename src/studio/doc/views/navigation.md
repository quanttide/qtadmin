# 元数据驱动导航

**metadata.json 决定导航长什么样，panorama.json 决定页面内容是什么。** 两者分离，改导航不用动业务数据，反之亦然。

导航元数据分两层：

| 层级 | 文件 | 职责 |
|---|---|---|
| 全局 | `assets/fixtures/metadata.json` | Workspace工作空间注册表 + 段定义（分隔线规则） |
| 每Workspace工作空间 | `assets/fixtures/{dir}/metadata.json` | 该Workspace工作空间导航项内容 |

新增Workspace工作空间只需根 metadata 加一条 + 写 fixture 文件，不改 Dart 代码。

## 工作方式

```
assets/fixtures/metadata.json        ← 根
  │ MetadataLoader.loadRoot()
  │  → RootMetadata { workspaces[] , sections[] }
  ▼                         
  main.dart 根据根 workspaces 遍历加载每Workspace工作空间 metadata
  │ MetadataLoader.load(dir)
  │  → TenantMetadata { sections[{id, items[]}] }
  ▼
合并：用根 sections[id].dividerBefore + Workspace工作空间 sections[id].items
  │ main.dart:_buildSections → 为每项构建 page widget 闭包
  ▼
NavSidebar(sections, selectedIndex, ..., workspaces, ...)
  │ NavSidebar 内部：WorkspaceSwitcher → divider 规则 → NavIcon
  │ 点击 → onItemTap / onWorkspaceChanged
  ▼
main.dart:_buildScreenForItem → pageType 分发路由
```

根 metadata 在 `initState` 一次性加载，各Workspace工作空间 metadata 遍历加载并缓存。

## 公开组件（`lib/views/navigation.dart`）

整个侧边栏由 `NavSidebar` 一个组件封装，内部编排 `WorkspaceSwitcher`、分隔线、`NavIcon`，`main.dart` 只传数据。

| 组件 | 说明 |
|---|---|
| `NavSidebar` | 完整侧边栏，接收 sections / selectedIndex / onItemTap / workspaces / selectedWorkspace / onWorkspaceChanged |
| `WorkspaceSwitcher` | Workspace工作空间切换下拉菜单，`NavSidebar` 内部使用 |
| `NavIcon` | 图标按钮，`NavSidebar` 内部使用 |
| `NavItem` | 运行时导航项数据类 |
| `NavSection` | 导航段数据类 |

测试文件 `test/widgets/nav_widgets_test.dart` 直接 import 使用，不再重复定义。

## 设计决策

### 为什么 metadata 和 panorama 分开？

**之前：** 导航结构由 `PanoramaData.businessUnits + functionCards` 推导，调顺序必须改业务数据。

**现在：** metadata 独立控制导航，panorama 只提供页面内容。

### 为什么拆根 metadata + 每Workspace工作空间 metadata？

上一版每Workspace工作空间自己的 metadata.json 包含完整信息（workspace + sections），分隔线规则写在 Dart 代码的 if-else 里。拆为两层后：

- **根 = 注册表：** 有哪些Workspace工作空间、有哪些段、分隔线规则——这些都是全局不变的
- **每Workspace工作空间 = 内容：** 该Workspace工作空间用哪些段、段里放什么项——这些是Workspace工作空间间差异

新增Workspace工作空间只需要在根加一条注册 + 写内容文件，不再改 `fixture_config.dart`、`_loadData()`、`WorkspaceSwitcher` 三处 Dart。

### 为什么 sections 用 id 引用而不是位置？

第一版 sections 是位置数组（index 0 = 全景图，index 1 = 业务线）。positional 隐式依赖顺序，容易错位。id 引用显式声明了"我是什么段"，根和Workspace工作空间通过 id 匹配，顺序由根定义控制。

### 为什么 icon 用字符串？

JSON 没有枚举类型。字符串 + 集中 map 解析，fixture 可读且无 Dart 类型引用。

### 为什么 `NavItem.builder` 是零参数闭包？

之前 builder 接受 `(PanoramaData, String)` 且闭包在 `_buildSections()` 外部捕获，切换Workspace工作空间后 `_data` 变了但闭包未更新。现在 builder 在 `_buildSections()` 重建时生成，从 `_selectedPanorama` 取值，始终最新。

### 为什么提取公开组件？

`NavIcon`、`WorkspaceSwitcher` 等原为 `main.dart` 私有类，widget test 被迫重复定义。提取到 `views/navigation.dart` 后可直接 import，减少代码重复。

### 为什么 NavSidebar 封装完整侧边栏？

上一版布局逻辑（flatIndex 计算、divider 插入、WorkspaceSwitcher 排列）写在 `main.dart` 的 `_buildSidebar()` 里，不可独立测试、不可复用。`NavSidebar` 将其封装为一个 props-driven widget，`main.dart` 从编排布局降级为传数据。

## 操作指南

### 新增导航项

1. 对应Workspace工作空间的 metadata.json sections[].items 里加一项
2. 如果 pageType 是 `business_detail` 或 `function_detail`，panorama.json 也要加对应数据（label 一致）

### 新增图标

1. `NavItemData.resolveIcon()` 的 `const icons` map 加一条
2. metadata.json 对应项 icon 字段填这个名称

### 新增 pageType

1. `main.dart:_buildScreenForItem()` 加 case 分支
2. 需要新数据则在 `_loadData()` 的 `Future.wait` 添加加载

### 新增Workspace工作空间

1. 根 `metadata.json` 的 `workspaces[]` 加一条
2. `assets/fixtures/` 下按 `dir` 值新建目录
3. 写 `metadata.json` + `panorama.json`（以及可选 `qtconsult.json`）

不需要改任何 Dart 文件。

### 新增导航段

1. 根 `metadata.json` 的 `sections[]` 加一条（定义 `dividerBefore`）
2. 需要此段的Workspace工作空间在自己 metadata.json 里引用该 id

## 已知陷阱

| 陷阱 | 优先级 | 说明 |
|---|---|---|
| 咨询数据硬编码为 customer | 中 | `QtConsultLoader.load(workspace: WorkspaceType.customer)`，founder 若有 consulting 页会展示 company 数据 |
| per-workspace metadata.json 引用的 section id 必须在根存在 | 低 | 运行时 `_buildSections()` 查找不到会抛 StateError |
