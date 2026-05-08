# Studio 运维文档

## 环境要求

- Flutter SDK 3.x（stable channel）
- Dart SDK 3.8+

## 开发

```bash
# 首次
cd src/studio
flutter pub get
git config core.hooksPath .githooks    # 激活 pre-commit 检查

# 日常
flutter run -d linux                    # Linux 桌面
flutter run -d chrome                   # Web
dart analyze lib/ test/                 # 静态检查
flutter test                            # 运行测试

# 代码生成（freezed）
dart run build_runner build             # 修改模型后重新生成
```

## 测试

166 tests，分层覆盖：

| 层 | 文件数 | 覆盖 |
|:---|:------:|:----:|
| 模型 | 6/6 | 100% |
| sources | 3/3 | 100% |
| blocs | 2/2 | 100% |
| screens | 7/7 | 100% |
| views | 8/8 | 100% |

## CI

`.github/workflows/studio.yml`：push/PR 触发，`src/studio/**` 路径过滤。

- `flutter pub get`
- `dart analyze lib/ test/`
- `flutter test`

## pre-commit

`.githooks/pre-commit`：提交前自动运行 `dart analyze`，通过才允许提交。

激活：`git config core.hooksPath .githooks`

## Web 构建

```bash
flutter build web
```

输出在 `build/web/`。

## 项目结构

```
lib/
├── blocs/        # BLoC 状态管理（AppBloc + ConsultBloc）
├── models/       # freezed 数据模型
├── sources/      # 数据源抽象
│   ├── base.dart           # DataResult + DataSource + DataLoader
│   ├── file_source.dart    # 文件实现
│   └── bundle_source.dart  # Web 资源实现
├── screens/      # 页面（7 个）
├── views/        # 组件（8 个）
├── theme.dart    # 颜色工具
├── constants.dart# UI 映射常量
├── main.dart
└── router.dart   # RouteConfig + AppRouter
```
