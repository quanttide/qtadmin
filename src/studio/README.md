# qtadmin_studio

量潮管理后台客户端。

## 目录

```
lib/
├── blocs/        # BLoC 状态管理
├── models/       # freezed 数据模型
├── sources/      # 数据源抽象（base + file_source + bundle_source）
├── screens/      # 页面
├── views/        # 组件
├── theme.dart    # 颜色工具
├── constants.dart# UI 映射常量
├── main.dart
└── router.dart   # RouteConfig + AppRouter
```

## 开发

```bash
git config core.hooksPath .githooks   # 激活 pre-commit 检查（dart analyze）
flutter test                           # 运行全部 166 个测试
dart analyze lib/ test/               # 静态检查
```
