# ROADMAP

评级 **中**，上限来自测试覆盖（低）。以下按优先级排列。

## P0 补齐 screens 测试

screens 当前 57%（4/7），缺失：

- `dashboard_screen_test`（读取 AppData，验证两个 workspace 视图）
- `business_detail_screen_test`（验证业务单元详情渲染）
- `function_detail_screen_test`（验证职能卡片详情渲染）

## P1 补齐 views 测试

views 当前 13%（1/8），策略：每个 view 文件至少一个渲染测试。

- `biz_unit_widget`、`business_section_widget`、`decision_card_widget`
- `func_card_widget`、`function_section_widget`、`section_header`、`stat_item`

## P2 CI 接入

- 增加 GitHub Actions 或类似 CI，`flutter test` + `dart analyze` 必过
- 可选：`flutter build web` 验证 assets 完整性
