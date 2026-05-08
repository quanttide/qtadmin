# Agent Guidelines for qtadmin_studio

## 原则

### 1. 模型归模型，工具归工具

`models/` 只放 freezed 数据类。颜色工具（`theme.dart`）、UI 映射函数（`constants.dart`）与模型解耦，放在根目录。

### 2. 不提前抽象

6 个 loader 没写测试前，不要先做 DataLoader。先做可工作的简单实现，等重复模式出现再抽象。

### 3. 少即是多

文件宁可大一点也不要拆碎。一个 base 模块（`sources/base.dart`）包含 DataResult + DataSource + DataLoader，而不是三个单独文件。

同类原则：`theme.dart` 和 `constants.dart` 直接放在 `lib/` 根目录，不建子目录。

### 4. freezed 没有替代品

手写 `fromJson` 不安全，freezed 从第一天就该上。字段默认值用 `@Default`，枚举 fallback 用 `@JsonKey(fromJson:)`。

### 5. 自定义方法用 extension，不在 freezed 类里写

`._()` 构造器 + `implements` vs `extends` 问题过多。自定义 getter/method 写成 `extension XxxX on Xxx` 更干净。

### 6. 命名即设计

`XxxData` 后缀是噪音，改为 `Xxx`。`route_config` 独立文件没意义，合并到 `router.dart`。

### 7. BLoC 解决的是架构问题

不是状态管理工具。用它拆 God 类（`qtconsult_screen`）和 God State（`main.dart`），而不是替代 `setState` 做 UI 切换。

### 8. pre-commit 与 CI 互补

pre-commit 快跑 `dart analyze`，CI 跑完整 `flutter test`。两层的原因不是功能重复，而是环境依赖性不同。

### 9. 第一次就要想清楚数据源抽象

`dart:io` + `File` 方便但堵死 Web。`DataSource` 接口 + `FileSource`/`BundleSource` 双实现从一开始就做，不然后面整片重写。

### 10. 结构服从调用方

`lib/theme.dart` 和 `lib/constants.dart` 拍平到根目录，调用方少敲一层路径。`sources/` 按来源类型分（base/file/bundle），不按模型分。

### 11. go_router 的引入条件是 URL

不是 string switch 的问题。`screenType` 字符串派发确实不安全，但 go_router 解决的是路径匹配，不是类型安全。如果需求已明确 URL 路由即将到来，提前引入是对的；如果只是为了消灭 switch，sealed class 更轻。
