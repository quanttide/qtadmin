# Agent Guidelines for qtadmin

> **必读：** 先读 `CONTRIBUTING.md`、`README.md`、`ROADMAP.md`。

## Project Overview

qtadmin 是 QuantTide 的第二大脑平台。当前重心在 Flutter 客户端（`src/studio/`），后端（`src/provider/`）处于维护状态。

## Studio

重心所在。所有开发原则、经验教训、架构约定见 `src/studio/AGENTS.md`。代理在 studio 下工作时必须先读。

```bash
cd src/studio
flutter run -d linux
flutter run -d chrome
dart analyze lib/ test/
flutter test
dart run build_runner build   # freezed codegen
```

## Provider（维护态，已重构为 Go）

```bash
cd src/provider
go run ./cmd/server            # 启动服务 (默认 :8000)
ADDR=:8000 go run ./cmd/server # 指定端口
go build ./cmd/server          # 编译
go test ./...                  # 测试
```

## 版本约定

- `v0.0.x` — 探索验证阶段，技术债清理、架构验证
- `v0.1.0` 起 — 进入上线推进阶段，标记探索期结束

主仓库与 studio 子标签版本号同步，升则同升。

### Release 标签格式

- CLI 发布用 `cli/vX.X.X` 标签，CHANGELOG 在 `src/cli/CHANGELOG.md`，版本号在 `src/cli/Cargo.toml`
- Studio 发布用 `studio/vX.X.X` 标签，CHANGELOG 在 `src/studio/CHANGELOG.md`
- 不修改项目根目录 `CHANGELOG.md` 记录 CLI/Studio 变更
- 不删除已有标签或 release，除非用户明确要求

## Documentation

- `docs/dev/` — 开发文档
- `docs/ops/` — 运维文档
- `src/studio/README.md` — studio 流程信息
