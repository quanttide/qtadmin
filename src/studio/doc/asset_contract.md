# 数字资产契约页面

## 概述

数字资产契约页面展示量潮科技的资产注册表，基于记忆模型的多仓架构管理数字资产，与 `.gitmodules` 对齐。该页面按约束力层级（宪法层、法律层、法理层）对资产进行分类展示。

## 资产分类

| | 宪法层 | 法律层 | 法理层 |
|------|--------|--------|--------|
| **类型** | Bylaw（工作章程） | Handbook（工作手册） | Tutorial（工作教程） |
| **类型** | Specification（工程标准） | Gallery（工作案例） | Essay（工作札记） |
| **类型** | | Qtadmin（管理后台） | Library（图书馆） |
| **类型** | | Qtcloud（数据云） | |

## 技术实现

### 文件结构

```
lib/
├── main.dart              # 主应用入口，包含导航栏配置
└── screens/
    └── asset_contract_screen.dart   # 数字资产契约页面组件
```

### 页面组件

#### AssetContractScreen

主页面组件，包含以下结构：
- **AppBar**: 显示标题"数字资产契约"
- **标题区域**: 显示"资产注册表"标题和描述文字
- **资产网格**: 使用 `GridView.count` 实现 3×3 网格布局

#### _AssetGrid

私有网格组件，负责渲染资产网格：
- **网格配置**: 3列布局，间距 12px
- **表头行**: 显示约束力层级（宪法层、法律层、法理层）
- **数据行**: 每行代表一个资产类别

### 颜色方案

每个格子使用不同的背景色以区分类型：

| 资产 | 颜色 |
|------|------|
| Bylaw | `orange.shade100` |
| Handbook | `blue.shade100` |
| Tutorial | `green.shade100` |
| Specification | `purple.shade100` |
| Gallery | `teal.shade100` |
| Essay | `cyan.shade100` |
| Qtadmin | `red.shade100` |
| Qtcloud | `pink.shade100` |
| Library | `indigo.shade100` |

### 导航集成

在 `main.dart` 中配置导航栏：
- 导航项：`_NavItem(icon: Icons.auto_stories_outlined, label: 'Meta')`
- 索引：4（第五个导航项）
- 页面映射：`case 4: return const AssetContractScreen()`

## 使用方式

1. 在底部导航栏点击 "Meta" 标签
2. 页面展示资产注册表的可视化网格
3. 每个格子显示资产英文名称和中文含义
4. 表头行显示约束力层级（宪法层、法律层、法理层）
5. 数据行按资产类别组织
