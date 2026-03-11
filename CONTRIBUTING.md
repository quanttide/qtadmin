# CONTRIBUTING

我来为你解释 Python 项目中 `scripts/` 和 `examples/` 这两个常见目录的用途和最佳实践：

## `scripts/` 文件夹

**用途**：存放**项目相关的工具脚本和自动化脚本**，通常是开发/维护用的辅助程序。

**典型内容**：

| 类型 | 示例 |
|------|------|
| 构建/部署脚本 | `build.sh`, `deploy.py`, `release.py` |
| 数据迁移/处理 | `migrate_db.py`, `seed_data.py` |
| 代码生成工具 | `generate_api.py`, `create_migration.py` |
| 维护/清理脚本 | `clean_cache.py`, `update_deps.py` |
| 开发辅助 | `run_tests.sh`, `setup_dev_env.py` |

**特点**：
- 通常**不随包一起发布**（`setup.py` 中排除）
- 可能依赖项目内部代码，但用户不需要直接运行
- 常包含 shebang (`#!/usr/bin/env python`) 可直接执行

---

## `examples/` 文件夹

**用途**：存放**面向用户的示例代码和用法演示**，展示如何使用你的库/框架。

**典型内容**：

| 类型 | 示例 |
|------|------|
| 基础用法示例 | `basic_usage.py`, `quickstart.py` |
| 完整场景演示 | `train_model.py`, `web_server.py` |
| 教程配套代码 | `tutorial_01_hello.py`, `tutorial_02_advanced.py` |
| 集成示例 | `flask_integration.py`, `docker_example/` |

**特点**：
- **随文档一起提供**，帮助用户快速上手
- 代码应该**可独立运行**（或注明依赖）
- 通常包含详细注释说明
- 可能作为文档的一部分被引用

---

## 对比总结

| 维度 | `scripts/` | `examples/` |
|------|-----------|-------------|
| **目标用户** | 开发者/维护者 | 终端用户/学习者 |
| **是否发布** | 通常否 | 通常随包发布 |
| **代码性质** | 工具、自动化 | 教程、演示 |
| **依赖关系** | 可能依赖内部工具 | 依赖公开的 API |
| **运行频率** | 开发时频繁使用 | 用户学习时运行 |

---

## 典型项目结构示例

```
my_project/
├── my_package/          # 主包代码
│   ├── __init__.py
│   └── core.py
├── scripts/             # 开发/维护脚本
│   ├── build_docs.py
│   ├── run_lint.sh
│   └── bump_version.py
├── examples/            # 用户示例
│   ├── 01_basic_usage.py
│   ├── 02_advanced_features.py
│   └── README.md
├── tests/               # 测试代码
├── docs/                # 文档
├── setup.py
└── README.md
```
