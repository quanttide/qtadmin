# Studio 技术债务评估

使用 SQFD 框架评估。评级：**中**（2026-05-08）。

## 评估维度

| 维度 | 权重 | 评级 | 要点 |
|:-----|:----:|:----:|:-----|
| 测试覆盖 | 25% | 中 | 整体 ~44%（132/300 文件）。模型 100%，sources 100%，blocs 100%，screens 43%，views 13% |
| 架构耦合 | 25% | 中 | Freezed + BLoC + DataSource 显著解耦。God 类 951→867 行但仍偏大 |
| 错误韧性 | 20% | 中 | DataLoader 有 try/catch + DataResult，但 main.dart 仍强制 unwrap |
| 工具链一致 | 10% | 低 | 干净。freezed + json_serializable + flutter_bloc 都在用 |
| 可移植性 | 10% | 中 | BundleSource 已定义但 Web 编译未验证 |
| 可维护性 | 10% | 低 | BLoC + DataLoader 模式已建立，新增模块成本低 |

评级规则：取最高分维度。测试覆盖从「高」降至「中」，综合评级维持 **中**。

## 相比上次的变化

| 项目 | 之前 | 现在 |
|:-----|:----:|:----:|
| 死代码 | fixture_config.dart | 已删除 |
| 未用依赖 | 6 个 | 0 |
| 模型定义 | 手写 fromJson | freezed 生成 |
| `XxxData` 命名 | 全部 | 全部改掉 |
| 加载器 | 6 个文件复制粘贴 | DataLoader 通用 + 3 个 sources 文件 |
| 错误处理 | 无 | DataResult + try/catch |
| 状态管理 | setState 遍地 | AppBloc + ConsultBloc |
| lint 警告 | 1 | 0 |
| sources 测试 | 0% | 100%（9 用例） |
| bloc 测试 | 0% | 100%（9 用例） |

## 关键风险

- `main.dart` 对 `DataResult` 强制 unwrap，任一加载器失败全应用崩溃
- `BundleSource` 未在 Chrome 实测
- screens 层仍需更多测试覆盖
