# Agent Guidelines for qtadmin_studio

详见 [CONTRIBUTING.md](CONTRIBUTING.md) 了解完整的开发原则和本地开发流程。

## AI 上下文

- 项目已完成领域分包：模型、BLoC、页面、视图已按领域提取为独立包
- `packages/` 下 7 个包，主项目仅保留导航加载 + 路由 + 入口
- 数据加载使用 `data_sources` 包的 `DataLoader` + `FileSource`
- 测试使用 `DataLoader.inject()` 注入数据，不依赖真实文件
