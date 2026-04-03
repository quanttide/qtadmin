# 版本发布规范

## 版本管理

单一数据源：仅在 `pyproject.toml` 维护版本号，代码中通过 `importlib.metadata.version()` 动态获取。

```python
from importlib.metadata import version

version("qtadmin-cli")
```

## 版本标签

使用 `cli/v<version>` 格式：

```bash
# 创建标签
git tag cli/v0.0.1-alpha.7

# 推送标签
git push origin cli/v0.0.1-alpha.7
```

## 发布流程

1. 更新 `CHANGELOG.md` - 添加新版本和变更内容
2. 提交 CHANGELOG
3. 创建标签
4. 推送标签到远程

## 版本规范

遵循语义化版本（SemVer）：
- alpha: `v0.0.1-alpha.1`
- beta: `v0.0.1-beta.1`
- release: `v0.0.1`