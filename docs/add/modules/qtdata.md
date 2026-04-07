# QtData 模块：数据可视化技术设计

基于 PRD [qtdata.md](../../prd/qtdata.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

数据可视化模块采用前后端分离架构：

- **前端**：Flutter studio 客户端（可视化界面）
- **后端**：FastAPI provider（元数据服务）
- **存储**：SQLite/PostgreSQL（元数据） + 文件系统（实际数据）

### 1.2 数据流

```
文件系统扫描 → 元数据提取 → 数据库存储 → API 暴露 → 前端可视化
```

核心组件：
- 项目扫描器：扫描根目录，识别项目结构
- 元数据提取器：提取项目信息、数据状态、依赖关系
- 依赖分析器：分析项目间依赖关系
- 可视化服务：提供项目列表、详情、依赖图 API

## 2. 数据结构

### 2.1 项目元数据

```python
class Project(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    name: str
    path: str
    description: Optional[str]
    status: str  # active/archived/deleted
    data_summary: dict  # {raw: {count: 39, size: 131MB}, ...}
    last_scan: datetime
    created_at: datetime
```

### 2.2 文件元数据

```python
class FileMeta(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    project_id: int = Field(foreign_key="project.id")
    path: str
    stage: str  # raw/processed/final
    size_bytes: int
    file_type: str  # xlsx/csv/dta
    checksum: Optional[str]  # MD5
    modified_at: datetime
    created_at: datetime
```

### 2.3 项目依赖关系

```python
class ProjectDependency(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    source_project_id: int = Field(foreign_key="project.id")
    target_project_id: int = Field(foreign_key="project.id")
    dependency_type: str  # data/script/doc
    description: Optional[str]
    created_at: datetime
```

## 3. 项目扫描器

### 3.1 扫描逻辑

```python
def scan_project(project_path: Path) -> ProjectMeta:
    """扫描单个项目"""
    meta = ProjectMeta(
        name=project_path.name,
        path=str(project_path),
        data_summary=scan_data_dir(project_path / "data"),
        last_scan=datetime.now()
    )
    
    # 扫描文档目录
    scan_docs_dir(project_path / "docs")
    
    # 扫描源码目录
    scan_src_dir(project_path / "src")
    
    return meta

def scan_data_dir(data_path: Path) -> dict:
    """扫描数据目录"""
    summary = {}
    for stage in ["raw", "processed", "final"]:
        stage_path = data_path / stage
        if stage_path.exists():
            files = list(stage_path.rglob("*"))
            summary[stage] = {
                "count": len([f for f in files if f.is_file()]),
                "size": sum(f.stat().st_size for f in files if f.is_file())
            }
    return summary
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

## 4. 依赖关系分析

### 4.1 数据依赖

分析脚本中的数据引用：

```python
def analyze_data_dependencies(project_path: Path) -> list[Dependency]:
    """分析数据依赖"""
    dependencies = []
    
    # 扫描所有 Python 脚本
    for script in (project_path / "src").glob("*.py"):
        content = script.read_text()
        
        # 查找数据文件引用
        for match in re.finditer(r'data/(\w+)/(.+\.\w+)', content):
            stage, filename = match.groups()
            dependencies.append(Dependency(
                type="data",
                target=f"{stage}/{filename}"
            ))
    
    return dependencies
```

### 4.2 项目间依赖

基于 README 和文档中的项目引用：

```python
def analyze_project_dependencies(project: Project) -> list[ProjectDependency]:
    """分析项目间依赖"""
    dependencies = []
    
    # 读取 README
    readme_path = Path(project.path) / "README.md"
    if readme_path.exists():
        content = readme_path.read_text()
        
        # 查找项目引用
        for match in re.finditer(r'projects?/([\w-]+)', content):
            target_name = match.group(1)
            target = get_project_by_name(target_name)
            if target:
                dependencies.append(ProjectDependency(
                    source_project_id=project.id,
                    target_project_id=target.id,
                    dependency_type="doc"
                ))
    
    return dependencies
```

## 5. API 设计

### 5.1 项目列表 API

```
GET /projects
Response: {
  "projects": [
    {
      "id": 1,
      "name": "garment-factory-cleaner",
      "status": "active",
      "data_summary": {
        "raw": {"count": 39, "size": 131072000},
        "processed": {"count": 4, "size": 109051904},
        "final": {"count": 4, "size": 109051904}
      },
      "last_scan": "2026-04-07T19:48:00"
    }
  ]
}
```

### 5.2 项目详情 API

```
GET /projects/{id}
Response: {
  "id": 1,
  "name": "garment-factory-cleaner",
  "path": "/path/to/project",
  "data_summary": {...},
  "files": [
    {
      "path": "data/raw/工序表/15F0189-润丰.xlsx",
      "stage": "raw",
      "size": 404888,
      "modified_at": "2026-04-07T19:19:18"
    }
  ],
  "dependencies": [
    {
      "target_project": "garment-factory-analyzer",
      "type": "data"
    }
  ]
}
```

### 5.3 依赖关系图 API

```
GET /projects/dependency-graph
Response: {
  "nodes": [
    {"id": 1, "name": "garment-factory-cleaner"},
    {"id": 2, "name": "garment-factory-analyzer"}
  ],
  "edges": [
    {"source": 1, "target": 2, "type": "data"}
  ]
}
```

## 6. 可视化设计

### 6.1 项目列表视图

展示所有项目卡片：

```
┌─────────────────────────────────┐
│ garment-factory-cleaner         │
│ Status: active                  │
│ Data: raw(39) processed(4) final(4) │
│ Last Scan: 2026-04-07 19:48     │
└─────────────────────────────────┘
```

### 6.2 项目详情视图

展示单个项目完整信息：

```
Project: garment-factory-cleaner
Path: /path/to/project

Data Status:
  raw/: 39 files (131MB)
  processed/: 4 files (104MB)
  final/: 4 files (104MB) ✓ synced to OSS

Dependencies:
  → garment-factory-analyzer (data)

Recent Files:
  data/final/产量数据_工序_返工_考勤_合并_test.xlsx (39MB)
```

### 6.3 依赖关系图

使用图可视化库（如 GraphView）展示项目间依赖：

```
[garment-factory-cleaner] → [garment-factory-analyzer]
         ↓
[garment-factory-report]
```

## 7. 技术栈

| 组件 | 技术选型 |
|------|----------|
| 后端框架 | FastAPI + SQLModel |
| 前端框架 | Flutter |
| 数据库 | SQLite（开发）→ PostgreSQL（生产） |
| 图可视化 | Flutter graph_widget 或第三方库 |
| 元数据存储 | 文件系统扫描 + 数据库索引 |

## 8. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | 项目扫描与列表展示 | P0 |
| M2 | 数据状态展示（raw/processed/final） | P1 |
| M3 | 项目详情视图 | P1 |
| M4 | 依赖关系分析 | P2 |
| M5 | 依赖关系图可视化 | P2 |