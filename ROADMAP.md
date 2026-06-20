# Roadmap

### 🏗️ 跨域：以 profile 为事实源

将 `data/profile/` 作为业务事实的权威来源，CLI 改为从 profile 加载数据而非硬编码：

- [ ] 质量评估标准定义在 profile 中，CLI 运行时读取而非代码硬编码

  **现状：** `quality.rs` 中 `METRICS` 常量硬编码了 7 个评估指标（3 维度，含评估提示词）。改维度定义或提示词需要修改 Rust 代码、重新编译。

  **目标：** 评估标准以 JSON 格式存放在 `profile/` 中，CLI 启动时加载，改标准只需改 profile。

  **步骤：**

  1. 定义评估标准 JSON Schema — 维度下嵌套指标（dimensions[narrative/knowledge/cognitive].metrics[]）
  2. ✅ 在 profile 仓库创建 `asset/quality.json`，内容与当前 `METRICS` 常量一致
  3. 新增 `QualityMetricsLoader`：从 profile 读取并解析 `asset/quality.json`（JSON 嵌套结构 → 拍平为 [&str;4] 数组）
  4. `quality.rs` 中的 `METRICS` 常量改为从 loader 加载，保留硬编码常量作为 fallback
  5. 复用 `QTRECURIT_PROFILE` 环境变量，默认指向 `../../data/profile`
  6. 更新测试：验证 JSON 嵌套结构 → 内部 `(&str,&str,&str,&str)` 元组转换正确
