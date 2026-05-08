# ROADMAP

## P0 加载失败防护

`main.dart` 对 `DataResult` 强制 unwrap，任一加载器失败整个应用白屏。

- 在 `AppBloc._onLoad` 中检查每个 `DataResult`，遇到 `DataError` 提前 `emit(AppError(...))` 而不是继续 unwrap

## P1 Web 兼容验证

`BundleSource` 已定义但未在 Chrome 实测。

- pubspec assets 注册所有 `data/` JSON 文件
- `flutter run -d chrome` 编译通过
- 确认数据加载正常

## P2 screens 测试覆盖

当前 screens 43%（3/7），views 13%（1/8）。

- 补 `qtconsult_screen` 测试（BI 最高，已有 ConsultBloc 支撑）
- 补 `thinking_screen` 测试
- 补 `qtclass_screen` 测试
