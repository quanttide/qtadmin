# 客户端重构记录

## 目录

```
lib/
├── models/           # 纯 freezed 数据模型
├── sources/
│   ├── base.dart          # DataResult + DataSource + DataLoader
│   ├── file_source.dart   # 文件实现
│   └── bundle_source.dart # Web 资源实现
├── screens/          # 页面
├── views/            # 组件
├── theme.dart        # 颜色工具
├── constants.dart    # UI 映射常量
├── main.dart
└── router.dart       # RouteConfig + AppRouter
```

## 已完成

- 模型类 `XxxData` → `Xxx` 重命名（全仓库）
- 全部 7 个模型迁移为 freezed（`fromJson` / `copyWith` / `==` / `hashCode` 自动生成）
- 字段默认值改用 `@Default`，枚举 fallback 用 `@JsonKey(fromJson:)`
- 自定义方法从 freezed 类移至 extension（避免 `._()` + `implements` 问题）
- 非 freezed 内容移出 `models/`：`theme.dart`（颜色工具）、`constants.dart`（UI 映射）
- `route_config.dart` 合并到 `router.dart`
- `services/` → `sources/` 数据源抽象：`DataResult` + `DataSource` + `DataLoader`
- 6 个 loader 文件归并为 `base.dart` + `file_source.dart` + `bundle_source.dart`

## 剩余风险

- `qtconsult_screen.dart` 951 行 God 类
- `main.dart` 14 字段 God State 集中加载
- 数据源零测试
- `bundle_source.dart` 未验证 Web 编译

## 待做

- `sources/` 单元测试（`DataResult` + `DataSource` + `DataLoader`）
- 拆 `qtconsult_screen.dart`（BLoC 或其他）
- 拆 `main.dart` God State
- Web 兼容验证（`flutter run -d chrome`）
