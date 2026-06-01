# M0 + M1 + M2 完成总结

## 交付物

| 阶段 | 文件 | 通过标准 |
|:-----|:-----|:--------|
| **M0** | `packages/fastapi/` 骨架（`pyproject.toml`、`database.py`、Alembic、测试夹具） | 数据库烟雾测试 + 健康检查 |
| **文档** | `doc/entities.md` 锁定约束分层、枚举值域、raw_text 拒绝规则、测试策略；`CLAUDE.md` 版本对齐 | 所有字段规格以 `doc/entities.md` 为准 |
| **M1** | 4 ORM + 4 Schema + Alembic 迁移（含桥接修复：`tags` → JSON、独立 Response schema、session rollback） | 30 测试全部通过 |
| **M2** | `Normalizer` 接口 + 注册机制 + `CsvRowNormalizer` + `ManualNormalizer` + 标准化路由 + `GET /source-records` + `GET /normalized-records` + `GET /source-records/{id}` + `GET /normalized-records/{id}` | 57 测试全部通过 |

## 测试覆盖（57 tests）

| 测试类别 | 数量 | 覆盖内容 |
|:---------|:----:|:---------|
| Schema 单测 | 18 | 字段类型、必填校验、枚举值域、raw_text 超限拒绝（422）、description 截断、amount_cents 负值拒绝 |
| ORM 集成测试 | 9 | CRUD 基本操作、默认值注入、时间戳自动赋值、FK IntegrityError 验证（另 3 条来自 database + health 烟雾测试） |
| Normalizer 单元测试 | 12 | Normalizer 注册与选择、CSV 解析成功/失败路径、Manual 直接映射 |
| 集成测试（路由） | 15 | 创建、标准化、列表/详情 GET、过滤查询、错误路径 |

## M0 遗留项状态

| 项 | 状态 | 说明 |
|:---|:----|:-----|
| `fastapi-check.yml` CI 流水线 | ⬜ backlog | M2 路由已就绪后加，此时 CI 才有校验价值 |
| Docker Compose | ⬜ backlog | 当前仅 SQLite，compose 贡献为零 |

## 下一步

**M3：分类服务**

- V1 硬编码 Taxonomy + 分类 API + 审核状态流转（`candidate → accepted/rejected`）
- `POST /normalized-records/{id}/classifications`
- `PATCH /classifications/{id}`（审核）
