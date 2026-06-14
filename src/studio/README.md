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

## Finance 联调

Studio 中的 finance 工作区通过 `QTADMIN_FINANCE_API_BASE_URL` 注入后端地址。

默认值：

```bash
http://localhost:8000
```

本地联调示例：

```bash
flutter run --dart-define=QTADMIN_FINANCE_API_BASE_URL=http://127.0.0.1:8000
```

finance 路由不会再在代码里写死 API 地址，统一通过 `AppData.financeConfig` 透传。
