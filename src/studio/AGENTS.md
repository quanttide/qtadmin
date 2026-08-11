# Agent Guidelines for qtadmin_studio

详见 [CONTRIBUTING.md](CONTRIBUTING.md) 了解完整的开发原则和本地开发流程。

## 原则

### 架构决策归人，AI 不主动分包

分包是战略决策（边界在哪、复用价值够不够），由人类主导。AI 不主动建包或移动代码。

新功能和跨域逻辑先写在主项目里，稳定后人类决定是否分包。AI 在以下时机提醒，但不执行：
- 模块错误明显增加
- 单次改动涉及大量文件
- 功能趋于稳定且边界清晰
- 出现第二个潜在消费者

已验证的模式才能固化。先跑通、再稳定、最后才考虑分包。

## AI 上下文

- 单项目结构：全部代码内聚于 `lib/`（`data_sources/`、`navigation.dart`、`models/`、`screens/`、`views/`、`blocs/`），无领域分包
- 数据加载使用 `lib/data_sources/` 的 `DataLoader` + `FileSource`
- 测试使用 `DataLoader.inject()` 注入数据，不依赖真实文件

## 维护工作流

### 已有领域

直接改 `lib/` 下对应模块（models / screens / views / blocs），开发测试一体化。

### 新领域 / 跨领域

先写在主项目里，不建新包。跨领域 glue 在主项目处理。

分包由人类控制，AI 不主动分包。当出现以下信号时，AI 应提醒人类考虑分包：
- 模块错误明显增加，测试维护困难
- 单次改动涉及大量文件
- 功能趋于稳定，边界清晰
- 出现第二个潜在消费者

### 改基础设施

改 `lib/data_sources/` 等基础设施，涉及加载管线的改动需跑全量测试。

### 提交流程

改代码 → `dart analyze` → `flutter test` → 提交
