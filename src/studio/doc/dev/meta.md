# Meta 页面

## 概述

Meta 页面展示九宫格记忆模型，帮助用户理解组织知识管理的认知基础。该页面基于认知科学的记忆分类体系，将知识按时间维度（过去、现在、未来）和内容维度（事件、语义、自我）进行分类。

## 九宫格记忆模型

| | 事件类 | 语义类 | 自我类 |
|------|--------|--------|--------|
| **过去** | Archive（归档） | Tutorial（教程） | History（历史） |
| **现在** | Journal（日志） | Profile（档案） | Brochure（宣传） |
| **未来** | Report（报告） | Notice（公告） | Roadmap（路线图） |

## 技术实现

### 文件结构

```
lib/
├── main.dart              # 主应用入口，包含导航栏配置
└── screens/
    └── meta_screen.dart   # Meta 页面组件
```

### 页面组件

#### MetaScreen

主页面组件，包含以下结构：
- **AppBar**: 显示标题"九宫格记忆模型"
- **标题区域**: 显示"记忆分类框架"标题和描述文字
- **记忆网格**: 使用 `GridView.count` 实现 3×3 网格布局

#### _MemoryGrid

私有网格组件，负责渲染九宫格：
- **网格配置**: 3列布局，间距 12px
- **表头行**: 显示时间维度标签（过去、现在、未来）
- **数据行**: 每行代表一个内容维度（事件、语义、自我）

### 颜色方案

每个格子使用不同的背景色以区分类型：

| 类型 | 颜色 |
|------|------|
| Archive | `orange.shade100` |
| Journal | `blue.shade100` |
| Report | `green.shade100` |
| Tutorial | `purple.shade100` |
| Profile | `teal.shade100` |
| Notice | `cyan.shade100` |
| History | `red.shade100` |
| Brochure | `pink.shade100` |
| Roadmap | `indigo.shade100` |

### 导航集成

在 `main.dart` 中配置导航栏：
- 导航项：`_NavItem(icon: Icons.auto_stories_outlined, label: 'Meta')`
- 索引：4（第五个导航项）
- 页面映射：`case 4: return const MetaScreen()`

## 使用方式

1. 在底部导航栏点击 "Meta" 标签
2. 页面展示九宫格记忆模型的可视化图表
3. 每个格子显示英文类型名称和中文含义
4. 表头行显示时间维度（过去、现在、未来）
5. 数据行按内容维度（事件类、语义类、自我类）组织
