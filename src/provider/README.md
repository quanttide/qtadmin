# Provider 壳（qtadmin-provider）

qtadmin provider 当前为**服务骨架**：config / store / health / 日志 / 优雅关闭。领域 handler 与模型已拆分迁移至各产品线仓库 `examples/`：

| 领域 | 去向 |
|:-----|:-----|
| human | `qtcloud-human/examples/human-api/` |
| connect | `qtcloud-connect/examples/connect-api/` |
| course | `qtcloud-course/examples/course-api/` |
| asset | `qtcloud-asset/examples/asset-api/` |
| data | `qtdata/examples/dataset-api/` |
| consult | `qtconsult/examples/consult-api/` |

领域不回收（四分边界见仓库根 `AGENTS.md`）。

## 启动

```bash
cd src/provider
go run ./cmd/server
```

## 环境变量

| 变量 | 默认值 | 说明 |
|:-----|:-------|:-----|
| `QTADMIN_ADDR` | `:8000` | 监听地址（兼容旧名 `ADDR`） |
| `QTADMIN_STORE_PATH` | `data` | 数据存储目录（兼容旧名 `STORE_PATH`） |
| `QTADMIN_STORE_DRIVER` | `file` | 存储驱动（`file` / `s3`） |
| `QTADMIN_LOG_LEVEL` | `info` | 日志级别 |
| `QTADMIN_LOG_FORMAT` | `text` | 日志格式（`text` / `json`） |
| `CONFIG_PATH` | — | 配置文件路径 |

## API

当前仅：

| 端点 | 鉴权 | 说明 |
|:-----|:-----|:-----|
| `GET /health` | 否 | 健康检查 |
