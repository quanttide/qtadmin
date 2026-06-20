# 用户指南

量潮管理后台分为业务和职能两类，以创始人视角统一管理公司各项事务。

## 架构

```
CLI (qtadmin) ── --provider ──→ Provider (Go API) ──→ 本地 JSON 文件
                                      │
                                      └── 手动备份 → 对象存储
```

- **CLI** 负责调用第三方工具获取数据、加工整理，通过 `--provider` 模式写入 Provider
- **Provider** 负责数据持久化和身份认证，按集合分文件存储
- **外部集成**（飞书、邮件）由 CLI 直接调用，Provider 不涉及

## 业务域

| 域 | 文件 | 说明 |
|:---|:-----|:-----|
| 量潮咨询 | 咨询项目 CRUD | `docs/user-guide/business.md` |
| 量潮课堂 | 课程 + 排课 + 报名 | |
| 量潮云 | 云资源管理 | |
| 量潮数据 | 数据集管理 | |

## 职能域

| 域 | 文件 | 说明 |
|:---|:-----|:-----|
| 人力资源 | 员工 / 部门 / 岗位 | `docs/user-guide/human.md` |
| 量潮招聘 | 简历 / 面试 | `docs/user-guide/qtrecruit.md` |
| 数字资产 | Git 仓库审计与日志归档 | `docs/user-guide/asset.md`（纯 CLI） |

## 启动

```bash
# 一次性
cd src/provider
QTADMIN_STORE_PATH=/home/iguo/data/qtadmin go run ./cmd/server

# 或配到 ~/.bashrc 后直接
cd src/provider
go run ./cmd/server
```
