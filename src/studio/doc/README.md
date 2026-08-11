# Studio 文档

## 目录

| 路径 | 内容 |
|---|---|
| `index.md` | 应用架构总览：加载管线、数据模型、组件、路由 |

数据 schema 定义在主仓库 `docs/drd/`，不在此目录。

## 边界

`src/studio/doc/` 只写 Studio Flutter 客户端的实现细节。不写跨模块共用机制（那些在主仓库 `docs/dev/`），不写架构决策记录（那些在主仓库 `docs/add/`）。
