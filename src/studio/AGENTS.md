# Agent Guidelines for qtadmin_studio

详见 [CONTRIBUTING.md](CONTRIBUTING.md) 了解完整的开发原则和本地开发流程。

## AI 上下文

- 项目已完成领域分包：模型、BLoC、页面、视图已按领域提取为独立包
- `packages/` 下 7 个包，主项目仅保留导航加载 + 路由 + 入口
- 数据加载使用 `data_sources` 包的 `DataLoader` + `FileSource`
- 测试使用 `DataLoader.inject()` 注入数据，不依赖真实文件

## 维护工作流

### 已有领域

直接改对应包，包内独立开发测试。例如咨询加新功能：改 `packages/qtadmin-qtconsult/`，跑它的测试，主项目只需更新版本引用。

### 新领域

建新包，参考 `qtadmin-org` 模式：
1. `packages/qtadmin-xxx/pubspec.yaml`（依赖 `data_sources` 等基础设施）
2. 模型（freezed）→ BLoC（可选）→ 页面 → 视图
3. 主项目 `pubspec.yaml` 加 `path:` 依赖
4. `router.dart` 加路由定义

### 跨领域

主项目 glue 层处理，不交叉依赖包。

### 改基础设施

改 `data_sources` 等底层包，所有依赖它的包重新 `pub get`。

### 提交流程

改代码 → `dart analyze` → 跑改动的包测试 → 跑主项目测试 → 提交
