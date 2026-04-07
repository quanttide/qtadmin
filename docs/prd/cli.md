# CLI 模块：命令行工具

提供简洁的命令行操作体验，作为第二大脑的外置程序性记忆。

## 1. 产品定位

命令行工具是外置的程序性记忆，用于：
- 快速执行重复性操作
- 记录操作历史，可追溯
- 与第二大脑仓库（陈述型记忆）配合使用

交互风格类似 opencode，简洁、高效、可组合。

## 2. 命令集定义

### 2.1 OSS 数据操作

```bash
# 下载数据
qt oss cp oss://qttech-data/data/<project>/ data/ -r

# 上传数据
qt oss cp data/final/ oss://qttech-data/data/<project>/final/ -r

# 列举文件
qt oss ls oss://qttech-data/data/<project>/

# 同步数据（双向）
qt oss sync oss://qttech-data/data/<project>/ data/ --direction download

# 删除文件
qt oss rm oss://qttech-data/data/<project>/raw/ -r

# 创建 bucket
qt oss mb oss://qttech-<name>

# 删除 bucket
qt oss rb oss://qttech-<name> --force

# 迁移 bucket
qt oss migrate oss://old-bucket oss://new-bucket
```

### 2.2 项目操作

```bash
# 列举项目
qt project ls

# 查看项目详情
qt project show <project>

# 初始化项目结构
qt project init <project>

# 查看项目数据状态
qt project status <project>
```

### 2.3 数据处理操作

```bash
# 运行处理脚本
qt run <project> --step 1

# 验收数据
qt accept <project> --file <filename>

# 查看处理日志
qt log <project>
```

### 2.4 文档操作

```bash
# 生成 README 模板
qt doc readme <project>

# 生成 index 模板
qt doc index <project>

# 检查文档结构
qt doc check <project>
```

## 3. 命令风格

### 3.1 设计原则

- 简洁：命令名短，参数直观
- 一致：类似 aliyun CLI、git 的风格
- 可组合：支持管道、脚本调用
- 有反馈：操作结果清晰展示

### 3.2 参数风格

```bash
# 短参数
qt oss ls -r

# 长参数
qt oss ls --recursive

# 布尔标志
qt oss rm --force

# 路径参数
qt oss cp <source> <dest>
```

### 3.3 输出格式

- 默认：表格形式，适合人类阅读
- JSON：`--output json`，适合脚本处理
- 安静：`--quiet`，只输出必要信息

## 4. 与第二大脑的关系

| 记忆类型 | 存储位置 | CLI 作用 |
|----------|----------|----------|
| 程序性记忆 | CLI 命令历史 | 记录操作流程、可复用 |
| 陈述型记忆 | 第二大脑仓库 | 提供知识、决策依据 |

CLI 记录每次操作，形成"操作记忆"，可：
- 回溯：查看历史操作
- 复用：重复执行相同操作
- 学习：从历史中总结模式

## 5. 用户故事

1. 作为数据管理员，我希望通过一条命令迁移 OSS bucket，以便快速完成存储调整。
2. 作为项目负责人，我希望通过命令查看项目数据状态，以便了解 raw/cleaned/final 情况。
3. 作为开发者，我希望 CLI 输出 JSON 格式，以便在脚本中调用。
4. 作为新成员，我希望通过 `qt project init` 快速创建标准项目结构，以便开始工作。

## 6. 技术实现

### 6.1 框架选择

推荐使用 Python CLI 框架：
- Typer：简洁、类型提示友好
- Rich：美化输出、表格展示
- 或 Click：成熟稳定

### 6.2 存储选择

操作历史存储：
- SQLite：轻量、本地存储
- Redis：快速、支持分布式

### 6.3 OSS 集成

- 调用阿里云 CLI（`aliyun oss`）
- 或直接使用 OSS Python SDK

## 7. 交互示例

```bash
$ qt oss ls oss://qttech-data/data/garment-factory/

LastModifiedTime        Size(B)    ObjectName
2026-04-07 19:28:24    38295446   final/产量数据_工序_返工_合并_test.xlsx
2026-04-07 19:28:24    39315762   final/产量数据_工序_返工_考勤_合并_test.xlsx
2026-04-07 19:28:24    33920714   final/产量数据_工序表合并.xlsx
Object Number is: 3

$ qt project status garment-factory

Project: garment-factory
Status: active

Data Status:
  raw/: 39 files (131MB)
  cleaned/: 4 files (109MB)
  final/: 4 files (109MB) ✓ synced to OSS

Last Run: 2026-04-07 19:28:24
```

## 8. 演进路线

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | OSS 基本操作（cp/ls/rm） | P0 |
| M2 | 项目管理（ls/init/status） | P1 |
| M3 | 数据处理（run/accept/log） | P1 |
| M4 | 文档生成（readme/index/check） | P2 |
| M5 | 操作历史追溯 | P2 |