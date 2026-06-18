# 契约测试

本目录包含 CLI 与 Studio 之间共享数据的契约文件。

## 流程

```
CLI test_contract  — 验证契约 JSON 结构正确
        ↓
契约文件 (recruitment.json)  — 两端共同遵守的数据格式承诺
        ↓
Studio contract_test  — 验证 Dart 模型能正确反序列化契约
```

## 运行

```bash
# CLI 端
cd apps/qtadmin/src/cli
cargo test --test test_contract

# Studio 端
cd apps/qtadmin/src/studio
flutter test test/models/contract_test.dart
```

## 规则

- 修改任何一方的数据模型后，必须更新契约文件并跑通两端测试
- 契约文件由人工维护，但两端测试确保结构对齐
