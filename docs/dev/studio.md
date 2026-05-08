# Studio 技术债务评估

使用 SQFD 框架评估。评级：**低**（2026-05-09）。

## 评估维度

| 维度 | 权重 | 评级 |
|:-----|:----:|:----:|
| 测试覆盖 | 25% | 低 |
| 架构耦合 | 25% | 低 |
| 错误韧性 | 20% | 低 |
| 工具链一致 | 10% | 低 |
| 可移植性 | 10% | 低 |
| 可维护性 | 10% | 低 |

全部六项 **低**，综合评级 **低**。

## 测试覆盖

166 tests，全分层 100%：

| 层 | 文件 | 用例 |
|:---|:----:|:----:|
| 模型 | 6/6 | 78 |
| views | 8/8 | 13 |
| screens | 7/7 | 47 |
| sources | 3/3 | 9 |
| blocs | 2/2 | 9 |
| 导航 | 1/1 | 10 |

## 变化总结

| 阶段 | 评级 | 主要工作 |
|:-----|:----:|:---------|
| 初始 | 高 | 手写 fromJson、setState 遍地、6 个重复 loader、零测试 |
| 第一轮 | 高→中 | freezed 迁移、数据源抽象、BLoC 引入、死代码清理 |
| 第二轮 | 中→低 | 加载失败防护、Web 兼容、全量测试、CI + pre-commit |
| P0-P2 | 低维持 | 纯 GoRouter、路由表合并、Section 缓存、ConsultBloc 生命周期提升 |

## 关键决策

| 决策 | 替代方案 | 理由 |
|:-----|:---------|:-----|
| freezed 迁移至 models/ 专用目录 | 继续手写 fromJson/copyWith/== | copyWith/== 手写风险高，fromJson 随字段增多极易遗漏 |
| 非 freezed 工具函数移出 models/ | 混放于 models/ | .fromJson 工厂和 @Default 约束下，工具函数无法兼容 freezed 生成代码 |
| DataResult sealed class + DataSource 抽象 | freezed union + riverpod | 无需 build_runner，跨平台数据源（bundled asset vs 文件）可替换 |
| DataLoader 泛型类替代 6 个 loader | 每 model 一个 loader | 消除重复，builder 注入解析函数即可 |
| flutter_bloc 替代 setState | Provider/riverpod | 事件驱动适合 consult_screen 的添加/确认/驳回/删除操作链 |
| go_router 替代手写路由 | auto_route | 纯 GoRouter 无需 codegen，redirect 统一管理 AppLifecycle |
| Map<String, RouteConfig> 替代 buildScreen switch | 字符串 switch/Map | 路由表自包含，消除 routeId→screen 双重映射 |
| _SidebarShell StatefulWidget 缓存 | 无缓存每次都 rebuild | workspace 不变时完全复用子树，减少 50%+ 无谓重建 |
| ConsultBloc 提升至 ShellRoute | 跟随页面创建/销毁 | 跨页面保持咨询状态，避免退出页面丢数据 |
| BundleSource 替代 FileSource 为默认 | FileSource 作为唯一实现 | Web 无 dart:io，rootBundle 跨所有平台可用 |
| AppData 单次创建 + Section 按 workspace 缓存 | 每次切换 workspace 重新加载 | 导航三栏数据（projects/workspaces/sections）生命周期由 AppBloc 统一管理 |
| ScreenContext 单 source 传递 screen 参数 | 每个 screen 各自从 blob 拆解 raw json | builder callback 用 ScreenContext 统一解析，消除 6 处重复的 json 拆解逻辑 |
| pre-commit 仅 dart analyze | dart analyze + flutter test | flutter test 依赖 Flutter SDK 版本文件解析，非交互 shell 不稳定 |
| Redirect-based GoRouter 模式 | ShellRoute 内嵌判断 AppState | redirect 天然覆盖所有路由导航，ShellRoute 方式需要每个子路由手动检查 |
