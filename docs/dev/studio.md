# 客户端

## 技术债务

使用 SQFD 框架评估。评级：**高**。（2026-05-08 更新：4 项快速修复已执行，见下方）

### 评估维度

| 维度 | 权重 | 评级 | 要点 |
|:-----|:----:|:----:|:-----|
| 测试覆盖 | 25% | 高 | 服务层 0%，屏幕层 43%，视图层 14%，整体 33% |
| 架构耦合 | 25% | 中 | `qtconsult_screen.dart` 951 行 God 类仍存；重复模式已消除 |
| 错误韧性 | 20% | 高 | 所有加载器无 try/catch，缺文件直接崩 |
| 工具链一致 | 10% | 低 | 已清理：移除了 6 个未用依赖，44 个间接依赖 |
| 可移植性 | 10% | 高 | `dart:io` 堵死 Web 编译 |
| 可维护性 | 10% | 中 | 新建模块需改 6 处，但无编译器保护 |

评级规则：取最高分维度而非平均。测试覆盖 + 错误韧性 + 可移植性维持「高」。

### 关键风险

- 服务层零测试 + 无错误处理：任何 JSON 缺失或损坏都导致白屏崩溃
- `qtconsult_screen.dart` God 类：UI、状态、业务逻辑未分离，修改脆弱
- 加载器全部使用 `dart:io`，无法编译 Web 目标

### 已执行

- 删除 `fixture_config.dart` 死代码（2026-05-08）
- 清理 pubspec 未用依赖：`provider`/`freezed_annotation`/`flutter_dotenv`/`mockito`/`freezed`/`build_runner`（2026-05-08）
- 提取 `StatItem` 共享组件，消除 3 处 `_statItem` 重复（2026-05-08）
- 合并 `hexColor`/`_parseHexColor` 到 `app_colors.dart`（2026-05-08）
- 移除 `main.dart` 未使用 `theme` 变量（2026-05-08）
- 优化模型层 import：`dashboard.dart` 移除 `flutter/material.dart`，`qtconsult.dart` 改用 `dart:ui`

### 结构性修复（待做）

1. 加载器加 try/catch + inject 测试（2-3 小时）
2. 抽象数据源接口，支持 `File` 和 `rootBundle` 双实现（1-2 天）
3. 拆分 `qtconsult_screen.dart` 为 ViewModel + UI（2-3 天）
4. 迁移 `main.dart` God State 到 ChangeNotifier 拆分（1-2 天）
5. 添加 `DataResult<T>` 错误处理层（3-4 天）
