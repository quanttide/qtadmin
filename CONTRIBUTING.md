# CONTRIBUTING

## 保密规范

**禁止在公开文档、代码、示例中泄漏客户敏感信息**，包括但不限于：客户/公司名称、业务数据、真实案例内容。示例用通用描述（如"文件1"、"数据清洗"）。

## 运行命令

### CLI

```bash
cd src/cli
cargo build                    # 编译
cargo run -- asset quality     # 运行子命令
cargo test                     # 运行测试
```

### Provider（维护态，已重构为 Go）

```bash
cd src/provider
go run ./cmd/server            # 启动服务 (默认 :8000)
ADDR=:8000 go run ./cmd/server # 指定端口
go build ./cmd/server          # 编译
go test ./...                  # 测试
```

### Studio（当前重心）

```bash
cd src/studio
flutter run -d linux
flutter run -d chrome
dart analyze lib/ test/
flutter test
dart run build_runner build   # freezed codegen
```

## 代码规范

### Python

| 约定 | 规则 |
|------|------|
| 版本 | 3.10+ |
| 命名 | `snake_case` 函数/变量，`PascalCase` 类 |
| 类型标注 | 全部参数和返回值必须标注 |
| 导入顺序 | stdlib → third-party → local，每组空行分隔 |
| 文档 | 中文 docstring |
| 行宽 | 100 字符以内 |

### Rust

| 约定 | 规则 |
|------|------|
| 命名 | `snake_case` 函数/变量，`PascalCase` 类型/trait |
| 错误处理 | anyhow::Result，context 附加上下文信息 |
| 测试 | 单元测试内联到文件底部 `#[cfg(test)] mod tests` |

### Dart / Flutter

| 约定 | 规则 |
|------|------|
| 命名 | `camelCase` 变量/函数，`PascalCase` 类/Widget |
| 导入顺序 | Dart SDK → Flutter → third-party → local |
| Widget | `const` 优先，`StatefulWidget` 只在需要状态时用 |
| 文件 | `snake_case.dart` |

## Git 规范

使用 Conventional Commits。

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `refactor` | 代码重构 |
| `docs` | 文档更新 |
| `test` | 测试相关 |
| `chore` | 构建/工具/配置 |

## 发布规范

### 版本约定

- `v0.0.x` — 探索验证阶段，技术债清理、架构验证
- `v0.1.0` 起 — 进入上线推进阶段，标记探索期结束

主仓库与 studio 子标签版本号同步，升则同升。

### Release 标签格式

monorepo 标签格式：`{项目}/v{版本}`。

- CLI 发布用 `cli/vX.X.X` 标签
- Studio 发布用 `studio/vX.X.X` 标签

### 发布流程

1. 更新版本号（`src/cli/Cargo.toml` 或 `src/pubspec.yaml`）
2. 更新对应 CHANGELOG（`src/cli/CHANGELOG.md` 或 `src/studio/CHANGELOG.md`）
3. 不修改项目根目录 `CHANGELOG.md`
4. commit → tag → push → GitHub Release
5. 不删除已有标签或 release

## Pull Request

1. 确保通过 lint
2. 确保测试通过
3. 用 Conventional Commits 提交
4. PR 标题概括变更，说明附上动机和影响范围
