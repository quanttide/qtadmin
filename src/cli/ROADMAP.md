# Roadmap: Python → Rust 重构

## 动机

- **分发简化**：Rust 编译为单二进制，消除 Python 运行时依赖和虚拟环境管理
- **性能**：审计模块需执行大量文件扫描和 git 操作，Rust 能显著降低延迟
- **类型安全**：Rust 所有权模型和类型系统从根本上消除整类运行时错误
- **统一技术栈**：项目内 Rust 经验可复用于其他工具链

## 版本策略

重构全程保持 `cli/v0.0.x` 版本线，不引入 API-breaking change。每阶段交付可独立 release。

## 阶段划分

### 阶段一：基础设施与 `asset backup`（1-2 周）

- 初始化 Rust 工作空间（Cargo workspace）
- 选择 CLI 框架（**clap** v4，derive 模式）
- 实现 `--help` / `--version` 回调
- 完整移植 `asset backup`：
  - `get_project_root` → 向上遍历查找 `docs/journal` + `docs/archive/journal`
  - 正则解析日期文件名
  - 递归扫描 + 分类 + 筛选 N 天前
  - 移动文件（dry-run 支持）
  - git 操作：status / add / commit / push（子模块 + 主仓库）
- 移植备份相关测试

**交付**：`qtadmin asset backup` 功能完整，与 Python 版命令兼容。

### 阶段二：`asset audit`（2-3 周）

- 移植 `GitRepoAuditor` 完整审计逻辑：
  - 必需文件检查
  - README / CONTRIBUTING / AGENTS / CHANGELOG / .gitignore 内容规范检查
  - 子模块状态检查
  - Conventional Commits 提交规范检查
  - 版本发布一致性检查
- 移植 `AuditReport` / `AuditResult` 数据模型及报告打印
- 移植审计相关测试

**交付**：`qtadmin asset audit` 功能完整，审计结果输出格式与 Python 版一致。

### 阶段三：质量加固与工程化（1 周）

- 集成测试：用 `assert_cmd` / `predicates` 测试 CLI 端到端行为
- CI 配置：`.github/workflows/` 添加 Rust 构建和测试
- 依赖审计：检查是否仍需 `pyyaml` 对应能力（如需要，选 `serde_yaml`）
- 错误处理统一：使用 `anyhow` + `thiserror`
- README 更新安装方式为 cargo install / 预编译二进制

### 阶段四：清理与收尾（0.5 周）

- 删除 Python 源码和依赖（`app/`, `pyproject.toml`, `tests/`）
- 更新 `CHANGELOG.md` 记录重构
- 确认标签命名 `cli/v0.0.x` 不变
- 文档更新：CONTRIBUTING.md 中构建/测试命令改为 Rust 方式

## 非目标

- 不引入新功能
- 不改变命令名、参数名、行为语义
- 不重构 audit 规则逻辑（仅移植）

## Rust 技术选型

| 领域         | 选型                             | 理由                             |
| ------------ | -------------------------------- | -------------------------------- |
| CLI 框架     | `clap` v4 (derive)               | 行业标准，对标 typer 体验        |
| 错误处理     | `anyhow` + `thiserror`           | 最小样板代码                     |
| Git 操作     | `git2` (libgit2 binding)         | 替代 subprocess，类型化 API      |
| 文件系统     | `std::fs` + `walkdir`            | 替代 shutil / pathlib.rglob      |
| 日期时间     | `chrono`                         | 日期解析和计算                   |
| 序列化       | `serde` + `serde_yaml`（按需）    | 仅当需要 YAML 解析时引入         |
| 测试         | `assert_cmd` + `predicates`      | CLI 端到端测试                   |

## 项目结构（目标）

```
cli/
├── Cargo.toml
├── src/
│   ├── main.rs          # CLI 入口
│   ├── cli.rs           # clap 定义
│   ├── asset/
│   │   ├── mod.rs
│   │   ├── backup.rs    # backup 命令逻辑
│   │   └── audit.rs     # audit 命令逻辑
│   └── git.rs           # git 操作封装
├── tests/
│   ├── backup.rs
│   └── audit.rs
├── CHANGELOG.md
├── CONTRIBUTING.md
└── ROADMAP.md
```
