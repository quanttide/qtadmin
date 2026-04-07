# Asset 模块：资产管理技术设计

基于 PRD [asset.md](../../prd/asset.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

资产管理模块采用分层架构：

- **前端**：Flutter studio 客户端（OSS 管理界面、验收工作台）
- **后端**：FastAPI provider（资产服务、验收流程）
- **存储**：本地文件系统 + 阿里云 OSS

### 1.2 数据资产管理

```
本地数据 → 处理脚本 → cleaned/ → 验收工作台 → final/ → OSS 同步
```

核心组件：
- 数据扫描器：扫描本地 `data/` 目录，构建元数据
- OSS 管理器：bucket CRUD、文件上传下载
- 验收引擎：质量检查、确认/驳回操作
- 同步服务：增量同步、版本对比

### 1.3 文档资产管理

```
Git 仓库 → 文档扫描 → 分类索引 → 元数据存储
```

核心组件：
- 文档扫描器：扫描 `docs/` 目录，识别 README/index.md
- 模板生成器：生成标准文档模板
- 结构检查器：验证文档目录结构

## 2. 数据结构

### 2.1 项目元数据

```python
class ProjectMeta(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    name: str
    path: str  # 项目路径
    data_status: dict  # {raw: 39, cleaned: 4, final: 4}
    oss_synced: bool
    last_sync: Optional[datetime]
    created_at: datetime
```

### 2.2 OSS Bucket 元数据

```python
class OSSBucket(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    name: str
    region: str
    storage_class: str  # Standard/IA/Archive
    size_bytes: int
    object_count: int
    created_at: datetime
```

### 2.3 验收记录

```python
class AcceptanceRecord(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    project_id: int
    file_path: str
    status: str  # pending/approved/rejected
    check_results: dict  # 检查项结果
    reviewer: Optional[str]
    reviewed_at: Optional[datetime]
    created_at: datetime
```

## 3. OSS 集成设计

### 3.1 SDK 选择

| 方案 | 优点 | 缺点 |
|------|------|------|
| 阿里云 CLI | 简单、成熟、已验证 | 需要外部进程调用 |
| OSS Python SDK | 直接集成、类型友好 | 需要额外依赖 |
| 自定义封装 | 可定制、统一接口 | 开发成本高 |

推荐：初期使用阿里云 CLI，后续迁移到 Python SDK。

### 3.2 操作映射

| 功能 | CLI 命令 | Python SDK |
|------|----------|------------|
| 创建 bucket | `aliyun oss mb` | `bucket.create()` |
| 列举文件 | `aliyun oss ls` | `bucket.list_objects()` |
| 上传文件 | `aliyun oss cp` | `bucket.put_object()` |
| 下载文件 | `aliyun oss cp` | `bucket.get_object()` |
| 删除 bucket | `aliyun oss rb --force` | `bucket.delete()` |

### 3.3 同步策略

增量同步逻辑：

```python
def sync_to_oss(local_path, oss_path):
    # 获取本地文件列表
    local_files = scan_local(local_path)
    
    # 获取 OSS 文件列表
    oss_files = list_oss_objects(oss_path)
    
    # 对比差异
    to_upload = compare_diff(local_files, oss_files)
    
    # 执行上传
    for file in to_upload:
        upload_file(file, oss_path)
```

## 4. 验收流程设计

### 4.1 验收检查项

| 检查类型 | 检查内容 | 实现方式 |
|----------|----------|----------|
| 完整性 | 文件数、大小 | 文件系统扫描 |
| 质量 | 格式正确、无缺失 | 文件解析验证 |
| 日志 | 错误数、警告数 | 日志文件解析 |

### 4.2 验收工作流

```
cleaned/ 文件生成 → 自动检查 → 待验收列表 → 人工确认 → 移动到 final/ → OSS 上传
```

API 设计：

```
POST /acceptance/check      # 执行自动检查
GET  /acceptance/pending    # 获取待验收列表
POST /acceptance/{id}/approve  # 确认验收
POST /acceptance/{id}/reject   # 驳回验收
```

## 5. API 设计

### 5.1 OSS 管理 API

```
GET  /oss/buckets          # 列举 bucket
POST /oss/buckets          # 创建 bucket
DELETE /oss/buckets/{name} # 删除 bucket
GET  /oss/buckets/{name}/objects  # 列举文件
POST /oss/buckets/{name}/sync     # 同步数据
```

### 5.2 项目管理 API

```
GET  /projects             # 列举项目
GET  /projects/{id}        # 获取项目详情
POST /projects/init        # 初始化项目结构
GET  /projects/{id}/status # 获取数据状态
```

### 5.3 验收 API

见第 4.2 节。

## 6. 技术栈

| 组件 | 技术选型 |
|------|----------|
| 后端框架 | FastAPI + SQLModel |
| 前端框架 | Flutter |
| OSS SDK | 阿里云 CLI → Python SDK |
| 本地存储 | 文件系统 + SQLite |
| 同步策略 | 增量同步、MD5 校验 |

## 7. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | OSS 基本操作（CLI 调用） | P0 |
| M2 | 项目扫描与元数据构建 | P1 |
| M3 | 验收工作台 | P1 |
| M4 | 增量同步服务 | P2 |
| M5 | 文档模板生成 | P2 |