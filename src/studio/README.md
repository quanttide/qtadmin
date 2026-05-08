# 客户端重构记录

## 目录

```
lib/
├── blocs/
│   ├── app_bloc.dart       # AppBloc：数据加载生命周期
│   └── consult_bloc.dart   # ConsultBloc：咨询发现业务逻辑
├── models/                 # 纯 freezed 数据模型
├── sources/
│   ├── base.dart           # DataResult + DataSource + DataLoader
│   ├── file_source.dart    # 文件实现
│   └── bundle_source.dart  # Web 资源实现
├── screens/                # 页面
├── views/                  # 组件
├── theme.dart              # 颜色工具
├── constants.dart          # UI 映射常量
├── main.dart               # BlocProvider + AppShell
└── router.dart             # RouteConfig + AppRouter
```

## 已完成

- 模型类 `XxxData` → `Xxx` 重命名（全仓库）
- 全部 7 个模型迁移为 freezed（`fromJson` / `copyWith` / `==` / `hashCode` 自动生成）
- 字段默认值改用 `@Default`，枚举 fallback 用 `@JsonKey(fromJson:)`
- 自定义方法从 freezed 类移至 extension
- 非 freezed 内容移出 `models/`：`theme.dart`（颜色）、`constants.dart`（映射）
- `route_config` 合并到 `router.dart`
- `services/` → `sources/` 数据源抽象（`DataResult` + `DataSource` + `DataLoader`）
- 引入 `flutter_bloc`，`main.dart` 加载逻辑迁移至 `AppBloc`
- `qtconsult_screen.dart` 业务逻辑拆分至 `ConsultBloc`（新增/确认/驳回/删除发现，策略审视）

## 剩余风险

- `main.dart` `AppShell` 仍保留导航状态（workspace/index）
- `consult_bloc.dart` 零测试
- `bundle_source.dart` 未验证 Web 编译

## 待做

- `sources/` 单元测试
- `consult_bloc` 单元测试
- Web 兼容验证（`flutter run -d chrome`）
