# CONTRIBUTING

## 保密规范

**禁止在公开文档、代码、示例中泄漏客户敏感信息**，包括但不限于：客户/公司名称、业务数据、真实案例内容。示例用通用描述（如"文件1"、"数据清洗"）。

## 运行命令

### Provider
```bash
cd src/provider
pdm install
pdm run uvicorn app:app --reload
pytest
```

### Studio
```bash
cd src/studio
flutter run -d linux
flutter run -d chrome
dart analyze lib/
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

### Dart / Flutter

| 约定 | 规则 |
|------|------|
| 命名 | `camelCase` 变量/函数，`PascalCase` 类/Widget |
| 导入顺序 | Dart SDK → Flutter → third-party → local |
| Widget | `const` 优先，`StatefulWidget` 只在需要状态时用 |
| 文件 | `snake_case.dart` |

## Git 规范

使用 `cz commit`（commitizen）生成 Conventional Commits。

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `refactor` | 代码重构 |
| `docs` | 文档更新 |
| `test` | 测试相关 |
| `chore` | 构建/工具/配置 |

## 发布规范

monorepo 标签格式：`{项目}/v{版本}`，如 `studio/v0.1.0`。

流程：更新版本号 → 更新 CHANGELOG → commit → tag → push → GitHub Release。

## Pull Request

1. 确保通过 lint：`dart analyze lib/`（studio）或 `ruff check .`（provider）
2. 确保测试通过：`pytest`（provider）
3. 用 `cz commit` 提交
4. PR 标题概括变更，说明附上动机和影响范围
