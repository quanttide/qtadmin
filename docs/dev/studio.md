# 客户端整体重构方案

## 当前风险

- 6 个加载器无 try/catch，缺文件直接白屏崩溃
- `qtconsult_screen.dart` 951 行 God 类
- 加载器全部使用 `dart:io`，无法编译 Web
- 主模块 14 字段 God State 集中加载
- 6 个加载器复制粘贴无抽象
- 服务层零测试

## 已完成

- 模型类 `XxxData` → `Xxx` 重命名（全仓库）
- 全部 7 个模型文件迁移为 freezed（含 `fromJson` / `copyWith` / `==` / `hashCode` 自动生成）
- `build_runner` + `freezed` + `json_serializable` 配置就绪
- 字段默认值改用 `@Default`，枚举 fallback 用自定义 `@JsonKey(fromJson:)`
- 自定义方法从 freezed 类移至 extension（避免 `._()` 构造器 + `implements` 问题）

## 工作分解

### 1. 数据层抽象（8）

| 子任务 | SP |
|--------|----|
| 1a. `DataResult<T>` sealed class + `DataSource` 接口 | 2 |
| 1b. `FileDataSource` 实现 + `rootBundle` 兼容开关 | 2 |
| 1c. 通用 `loadData()` + 每个 model 挂 `static load/inject` | 3 |
| 1d. `main.dart` 改调 `Model.load()` 并处理 `DataError` | 1 |

### 2. 补加载器测试（5）

| 子任务 | SP |
|--------|----|
| 2a. `DataResult` + `DataSource` 单元测试 | 2 |
| 2b. 用 `inject()` 为每个 model 写加载测试（正常 / 坏 JSON） | 3 |

### 3. BLoC 迁移（8/屏幕，可选）

| 子任务 | SP |
|--------|----|
| 3a. 引入 `flutter_bloc`，配置 `MultiBlocProvider` | 2 |
| 3b. 拆分 `main.dart` God State 为 6 个 `ScreenBloc` | 3 |
| 3c. 迁移 `qtconsult_screen` 为 Bloc + Event + State | 3 |

### 4. Web 兼容验证（3）

| 子任务 | SP |
|--------|----|
| 4a. 确认数据文件在 pubspec assets 注册 | 1 |
| 4b. `flutter run -d chrome` 编译通过 | 2 |
