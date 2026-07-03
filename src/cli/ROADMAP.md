# ROADMAP — Share (opensource)

> 将内部私有仓库代码脱敏后发布到公开仓库的工具链。

## 现状 (Current)

`examples/share/opensource.py` — Python 脚本，功能完整但未集成到 CLI：

| 步骤 | 说明 |
|------|------|
| LLM 判断目标位置 | 扫描源码结构，LLM 决定放入 public repo 的哪个 examples/ 子目录 |
| rsync 复制 | 按 exclude 规则复制源码到目标路径 |
| LLM 脱敏 | 批量检测邮箱、域名、API Key、内网地址等敏感信息并替换 |
| 编译验证 | 执行 build 命令确保代码公开后可编译 |
| Git commit & tag | 自动 stage → LLM 决定是否 commit → 打版本 tag |

## 阶段一：Rust 翻译 (v0.0.17)

将 Python 脚本翻译为 Rust，集成到 CLI 作为新命令。

### 命令设计

```text
qtadmin share <project> [version]
```

参数从 `share.conf` 的 `[project]` 段读取：

| 配置字段 | 用途 |
|----------|------|
| `private_src` | 私仓源码路径 |
| `public_dst` | 公仓目标路径 |
| `sync_src` | 指定同步的子目录/文件 |
| `sync_dst` | 指定同步到公仓的子路径 |
| `build_cmd` | 编译验证命令 |
| `exclude` | 额外排除模式 |

### 模块拆分

| 模块 | 职责 | 复用已有设施 |
|------|------|-------------|
| `share/copy.rs` | rsync 复制逻辑 | `asset/git_utils.rs` |
| `share/sanitize.rs` | LLM 脱敏 | `cli_config::deepseek_api_key()` |
| `share/decide.rs` | LLM 判断目标位置 | `quanttide-agent` crate |
| `share/commit.rs` | Git commit & tag | `asset/git_utils.rs` |
| `share/config.rs` | 配置文件解析 | — |

### 交付物

- [ ] 配置解析：TOML 替代 INI（`share.toml`），与 CLI 现有风格一致
- [ ] `rsync_copy`：spawn `rsync` 进程，支持 exclude 规则
- [ ] `llm_decide_destination`：调用 DeepSeek API，解析 JSON 决策
- [ ] `llm_sanitize`：批量文件扫描 + LLM 敏感内容检测 + 替换
- [ ] `run_build`：spawn build 命令，失败中止
- [ ] `git_commit`：stage → diff → LLM 决策 → commit → tag
- [ ] 集成测试：模拟私仓→公仓全流程

| 特性 | 说明 |
|------|------|
| 静态脱敏规则 | 内置正则规则（邮箱、域名、IP、API Key 模式），脱敏不依赖 LLM |
| 差异脱敏 | 仅处理 LLM 返回的新增敏感模式，避免重复扫描全量文件 |
| 脱敏预览 | `--dry-run` 模式，仅打印替换内容不写入文件 |
| 敏感模式缓存 | 项目级别的脱敏记录缓存，增量更新 |
