# 技术架构设计

qtadmin 第二大脑平台的整体技术架构。

## 1. 系统架构

### 1.1 整体架构

采用前后端分离 + 多工作空间架构：

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Flutter   │────▶│   FastAPI    │────▶│  Storage    │
│   Studio    │     │   Provider   │     │  (OSS/DB)   │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  CLI Tool    │
                    │  (Typer)     │
                    └──────────────┘
```

### 1.2 模块架构

```
qtadmin/
├── src/
│   ├── provider/       # FastAPI 后端服务
│   ├── studio/         # Flutter 客户端
│   └── cli/            # 命令行工具
├── data/               # 数据工作空间
│   └── <project>/
│       ├── data/       # 数据文件
│       ├── docs/       # 项目文档
│       └── src/        # 处理脚本
└── docs/               # 平台文档
    ├── prd/            # 产品需求
    └── add/            # 架构设计
```

## 2. 核心模块

### 2.1 Provider（后端服务）

**技术栈**：FastAPI + SQLModel + Uvicorn

**职责**：
- 提供 RESTful API
- 管理数据库模型
- 协调各模块服务
- 处理业务逻辑

**核心服务**：
- 项目服务：项目管理、扫描、元数据
- 资产服务：OSS 管理、验收流程、同步
- 知识服务：碎片记录、工作协议、Meta 模块

### 2.2 Studio（前端客户端）

**技术栈**：Flutter + Dart

**职责**：
- 提供用户界面
- 调用后端 API
- 本地状态管理
- 可视化展示

**核心页面**：
- Default 页面：碎片记录、快速检索
- Work 页面：协议定义、双智能体协作
- Asset 页面：OSS 管理、验收工作台
- QtData 页面：项目列表、依赖关系图

### 2.3 CLI（命令行工具）

**技术栈**：Typer + Rich

**职责**：
- 命令行操作
- OSS 数据操作
- 项目管理
- 操作历史记录

**核心命令**：
- `qt oss`：OSS 操作
- `qt project`：项目管理
- `qt run`：数据处理
- `qt doc`：文档生成

## 3. 数据架构

### 3.1 数据库设计

**主数据库**（SQLite → PostgreSQL）：

| 表名 | 说明 |
|------|------|
| projects | 项目元数据 |
| files | 文件元数据 |
| fragments | 碎片记录 |
| work_protocols | 工作协议 |
| work_sessions | 工作会话 |
| acceptance_records | 验收记录 |
| command_history | 命令历史 |

### 3.2 存储架构

| 存储类型 | 技术 | 用途 |
|----------|------|------|
| 结构化数据 | SQLite/PostgreSQL | 元数据、业务数据 |
| 文件数据 | 阿里云 OSS | 数据文件、文档 |
| 本地缓存 | SQLite | CLI 历史记录、配置 |
| 向量数据 | Chroma/Qdrant | Meta 模块经验记忆 |

## 4. 接口设计

### 4.1 API 规范

- 遵循 RESTful 风格
- 使用 OpenAPI 文档
- 统一错误处理
- 支持 JWT 认证

### 4.2 命名约定

- 使用复数名词：`/projects`, `/fragments`
- 嵌套资源：`/projects/{id}/files`
- 过滤参数：`?status=active&stage=raw`

## 5. 部署架构

### 5.1 开发环境

```
本地开发
├── FastAPI (localhost:8000)
├── Flutter (调试模式)
├── SQLite (本地数据库)
└── 阿里云 OSS (测试 bucket)
```

### 5.2 生产环境

```
云端部署
├── FastAPI (云服务器 + Uvicorn)
├── Flutter (Web/桌面/移动端)
├── PostgreSQL (云数据库)
└── 阿里云 OSS (生产 bucket)
```

## 6. 技术选型原则

1. **成熟稳定**：优先选择社区活跃、文档完善的框架
2. **类型安全**：使用 SQLModel、Typer 等支持类型提示的工具
3. **渐进式**：从简单方案开始，逐步增强（如 SQLite → PostgreSQL）
4. **可测试**：所有模块支持单元测试和集成测试

## 7. 相关文档

- [modules/default.md](modules/default.md)：知识工作模块技术设计
- [modules/asset.md](modules/asset.md)：资产管理模块技术设计
- [modules/cli.md](modules/cli.md)：CLI 模块技术设计
- [modules/data.md](modules/data.md)：数据可视化模块技术设计
- [modules/project.md](modules/project.md)：项目管理可视化模块技术设计