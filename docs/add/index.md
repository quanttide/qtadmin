# 架构设计总览

qtadmin 第二大脑平台的架构设计文档索引。

## 1. 系统架构

详见 [architecture.md](architecture.md)

- 整体架构设计
- 模块架构
- 数据架构
- 接口设计
- 部署架构

## 2. 技术栈

详见 [tech-stack.md](tech-stack.md)

- 后端技术栈
- 前端技术栈
- CLI 技术栈
- 开发工具
- 部署工具

## 3. 模块设计

| 模块 | 文档 | 说明 |
|------|------|------|
| 知识工作 | [modules/default.md](modules/default.md) | Default 模式、Work 模式、Meta 模块 |
| 资产管理 | [modules/asset.md](modules/asset.md) | 数据、文档、代码资产管理 |
| 命令行工具 | [modules/cli.md](modules/cli.md) | CLI 命令设计与实现 |
| 数据可视化 | [modules/qtdata.md](modules/qtdata.md) | 项目扫描、依赖关系可视化 |

## 4. 基础设施

| 主题 | 文档 | 说明 |
|------|------|------|
| 数据库设计 | infrastructure/database.md | 表结构设计 |
| API 规范 | infrastructure/api.md | RESTful API 设计规范 |
| OSS 集成 | infrastructure/oss.md | 阿里云 OSS 集成方案 |

## 5. 设计原则

1. **分层架构**：前端、后端、存储分离
2. **模块化**：各模块独立设计、松耦合
3. **类型安全**：使用类型提示、静态检查
4. **渐进式**：从简单方案开始，逐步增强

## 6. 与 PRD 的关系

| PRD 内容 | ADD 内容 |
|----------|----------|
| 产品需求、用户故事 | 技术方案、接口设计 |
| 业务流程、场景描述 | 数据结构、API 规范 |
| 验收标准 | 实现细节、性能要求 |

## 7. 维护规则

1. PRD 变更后，及时更新对应的 ADD 文档
2. 技术选型变更需更新 tech-stack.md
3. 新增模块需在 modules/ 下创建对应文档
4. 架构调整需更新 architecture.md