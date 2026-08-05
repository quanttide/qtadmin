# ROADMAP — qtadmin Provider

qtadmin Provider 处于维护态（Go）。定位、三支柱与阶段划分见仓库根目录 `ROADMAP.md`。

## 版本目标

| 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `internal/version/version.go`、`CHANGELOG.md` | 0.0.1 | provider/v0.1.0 | CHANGELOG 补 [0.1.0] 条目，version.go 由发布工具更新 |

## 路线

维护态，仅版本对齐，不做功能扩展。

现有能力：health 检查、配置管理、存储层（FileStore，S3 预留）、Human / Connect / Business 域 API。
