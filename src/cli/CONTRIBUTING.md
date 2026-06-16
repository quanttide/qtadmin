# 版本发布规范

## 版本管理

单一数据源：仅在 `Cargo.toml` 维护版本号。

## 版本标签

使用 `cli/v<version>` 格式：

```bash
git tag cli/v0.0.1
git push origin cli/v0.0.1
```

## 发布流程

1. 更新 `CHANGELOG.md` - 添加新版本和变更内容
2. 更新 `Cargo.toml` - 版本号
3. 提交 CHANGELOG 和 Cargo.toml
4. 创建标签 `git tag cli/v<version>`
5. 推送标签到远程 `git push origin cli/v<version>`
6. 创建 GitHub Release `gh release create cli/v<version> --title "qtadmin-cli v<version>" --generate-notes`

## 构建与测试

```bash
cargo build              # 编译
cargo test               # 运行测试
cargo build --release    # 发布构建
```

## 版本规范

遵循语义化版本（SemVer）：
- alpha: `v0.0.1-alpha.1`
- beta: `v0.0.1-beta.1`
- release: `v0.0.1`
