# 客户端

## 技术债务

使用 SQFD 框架评估。评级：**高**。

### 评估维度

| 维度 | 权重 | 评级 | 要点 |
|:-----|:----:|:----:|:-----|
| 测试覆盖 | 25% | 高 | 服务层 0%，屏幕层 43%，视图层 14%，整体 33% |
| 架构耦合 | 25% | 高 | `qtconsult_screen.dart` 951 行 God 类，代码重复 |
| 错误韧性 | 20% | 高 | 所有加载器无 try/catch，缺文件直接崩 |
| 工具链一致 | 10% | 高 | `provider`/`freezed`/`mockito`/`flutter_dotenv` 声明未用 |
| 可移植性 | 10% | 高 | `dart:io` 堵死 Web 编译 |
| 可维护性 | 10% | 中 | 新建模块需改 6 处，但无编译器保护 |

评级规则：取最高分维度而非平均。服务层零测试 + God 类两处达「高」，综合评级为高。

### 关键风险

- 服务层零测试 + 无错误处理：任何 JSON 缺失或损坏都导致白屏崩溃
- `qtconsult_screen.dart` God 类：UI、状态、业务逻辑未分离，修改脆弱
- 加载器全部使用 `dart:io`，无法编译 Web 目标
- `fixture_config.dart` 死代码，6 个加载器复制粘贴无抽象
- `_statItem` 等 UI 模式在 3 个屏幕中重复实现

### 快速修复

1. 加载器加 try/catch + inject 测试（2-3 小时，堵最大风险）
2. 删除死代码和未用依赖（10 分钟）
3. 提取共享 `_statItem` 组件（20 分钟）
4. 合并重复的 `hexColor` 解析函数（5 分钟）

### 结构性修复

1. 抽象数据源接口，支持 `File` 和 `rootBundle` 双实现（1-2 天）
2. 拆分 `qtconsult_screen.dart` 为 ViewModel + UI（2-3 天）
3. 迁移 `main.dart` God State 到 Provider 多 ChangeNotifier（1-2 天）
4. 添加 `DataResult<T>` 错误处理层（3-4 天）
