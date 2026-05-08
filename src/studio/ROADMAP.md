# ROADMAP

## 已完成

- 模型类 `XxxData` → `Xxx` 重命名
- 全部 7 个模型迁移为 freezed（`fromJson` / `copyWith` / `==` / `hashCode` 自动生成）
- 字段默认值改用 `@Default`，枚举 fallback 用 `@JsonKey(fromJson:)`
- 自定义方法从 freezed 类移至 extension
- 非 freezed 内容移出 `models/`：`theme.dart`、`constants.dart`
- `route_config` 合并到 `router.dart`
- `services/` → `sources/` 数据源抽象（`DataResult` + `DataSource` + `DataLoader`）
- 引入 `flutter_bloc`，`main.dart` 加载逻辑迁移至 `AppBloc`
- `qtconsult_screen.dart` 业务逻辑拆分至 `ConsultBloc`

## 待做

### 测试
- `sources/` 单元测试（DataResult + DataLoader）✓
- `consult_bloc` 单元测试 ✓

### 架构
- `bundle_source.dart` Web 兼容验证（`flutter run -d chrome`）

### 业务
- Workspace 类型定义模糊（`internal`/`customer` → `founder`/`company`）
- Fixture 路径映射分散
- 图标字符串无校验
- 页面路由表硬编码
- Fixture JSON 缺少构建时校验
- Widget 树在数据就绪前渲染
