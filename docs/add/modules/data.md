# Data 模块：数据可视化技术设计

基于 PRD [qtdata.md](../../prd/qtdata.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

数据可视化模块负责展示数据目录结构和状态：

- **前端**：Flutter studio 客户端（数据视图）
- **后端**：FastAPI provider（数据服务）
- **存储**：SQLite/PostgreSQL（元数据） + 文件系统（实际数据）

### 1.2 数据流

```
文件系统扫描 → 元数据提取 → 数据库存储 → API 暴露 → 前端可视化
```

核心组件：
- 目录扫描器：扫描 data/ 目录结构
- 文件元数据提取：提取文件信息、大小、类型
- 数据状态计算：统计 raw/processed/final 数量和大小

## 2. 数据结构

### 2.1 文件元数据

```python
class FileMeta(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    project_id: int = Field(foreign_key="project.id")
    path: str
    stage: str  # raw/processed/final
    size_bytes: int
    file_type: str  # xlsx/csv/dta/md
    checksum: Optional[str]  # MD5
    modified_at: datetime
    created_at: datetime
```

### 2.2 数据状态

```python
class DataStatus(SQLModel, table=True):
    project_id: int = Field(foreign_key="project.id")
    stage: str  # raw/processed/final
    file_count: int
    total_size_bytes: int
    last_updated: datetime
```

## 3. 目录扫描器

### 3.1 扫描逻辑

```python
def scan_data_dir(project_path: Path) -> DataStatus:
    """扫描数据目录"""
    summary = {}
    for stage in ["raw", "processed", "final"]:
        stage_path = project_path / "data" / stage
        if stage_path.exists():
            files = list(stage_path.rglob("*"))
            summary[stage] = {
                "count": len([f for f in files if f.is_file()]),
                "size": sum(f.stat().st_size for f in files if f.is_file())
            }
    return summary

def scan_files(project_path: Path, stage: str) -> list[FileMeta]:
    """扫描单个 stage 下的所有文件"""
    files = []
    stage_path = project_path / "data" / stage
    
    for file in stage_path.rglob("*"):
        if file.is_file():
            files.append(FileMeta(
                project_id=project.id,
                path=str(file.relative_to(project_path)),
                stage=stage,
                size_bytes=file.stat().st_size,
                file_type=file.suffix[1:],  # 去掉点号
                modified_at=datetime.fromtimestamp(file.stat().st_mtime)
            ))
    
    return files
```

### 3.2 增量扫描

```python
def incremental_scan(project_path: Path, last_scan: datetime) -> list[FileMeta]:
    """增量扫描，只处理变更文件"""
    changed_files = []
    for file in project_path.rglob("*"):
        if file.is_file() and file.stat().st_mtime > last_scan.timestamp():
            changed_files.append(extract_file_meta(file))
    return changed_files
```

## 4. API 设计

### 4.1 项目数据状态 API

```
GET /projects/{id}/data-status
Response: {
  "project_id": 1,
  "stages": {
    "raw": {"count": 39, "size": 137499484},
    "processed": {"count": 4, "size": 114155916},
    "final": {"count": 4, "size": 114155916}
  }
}
```

### 4.2 文件列表 API

```
GET /projects/{id}/files?stage=raw
Response: {
  "files": [
    {
      "path": "raw/工序表/15F0189-润丰.xlsx",
      "stage": "raw",
      "size": 404888,
      "file_type": "xlsx",
      "modified_at": "2026-04-07T19:19:18"
    }
  ],
  "total": 39
}
```

### 4.3 数据目录树 API

```
GET /projects/{id}/data-tree
Response: {
  "path": "data",
  "children": [
    {
      "path": "raw",
      "type": "directory",
      "children": [
        {"path": "raw/工序表", "type": "directory"},
        {"path": "raw/半年产量数据", "type": "directory"}
      ]
    },
    {
      "path": "processed",
      "type": "directory"
    },
    {
      "path": "final",
      "type": "directory"
    }
  ]
}
```

## 5. 可视化设计

### 5.1 数据状态卡片

```
┌─────────────────────────────────┐
│ Data Status                     │
├─────────────────────────────────┤
│ raw:       39 files (131 MB)    │
│ processed:  4 files (104 MB)     │
│ final:      4 files (104 MB) ✓  │
└─────────────────────────────────┘
```

### 5.2 文件浏览器

按 stage 分组展示文件列表，支持：
- 文件名搜索
- 类型过滤
- 大小排序

## 6. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | 数据目录扫描与状态展示 | P0 |
| M2 | 文件列表与搜索 | P1 |
| M3 | 数据目录树可视化 | P2 |
| M4 | 增量扫描优化 | P2 |