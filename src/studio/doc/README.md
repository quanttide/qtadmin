# Studio 文档

## 目录

| 路径 | 内容 |
|---|---|
| `index.md` | 应用架构总览：加载管线、数据模型、组件、路由 |
| `views/navigation.md` | 导航实现：数据流、公开组件、设计决策、操作指南 |
| `screens/qtconsult.md` | 咨询详情页实现：联动规则、状态流转、与量潮云关系 |

数据 schema 定义在主仓库 `docs/drd/`，不在此目录。

## 边界

`src/studio/doc/` 只写 Studio Flutter 客户端的实现细节。不写跨模块共用机制（那些在主仓库 `docs/dev/`），不写架构决策记录（那些在主仓库 `docs/add/`）。
