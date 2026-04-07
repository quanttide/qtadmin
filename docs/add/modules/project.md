# Project 模块：项目管理可视化技术设计

基于 PRD [qtdata.md](../../prd/qtdata.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

项目管理模块负责展示项目概览和依赖关系：

- **前端**：Flutter studio 客户端（项目视图）
- **后端**：FastAPI provider（项目服务）
- **存储**：SQLite/PostgreSQL（项目元数据）

### 1.2 数据流

```
Git 仓库扫描 → 项目元数据提取 → 数据库存储 → 依赖分析 → 前端可视化
```

核心组件：
- 项目扫描器：扫描根目录，识别项目结构
- 元数据提取器：提取项目信息、描述、状态
- 依赖分析器：分析项目间依赖关系

## 2. 数据结构

### 2.1 项目元数据

```python
class Project(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    name: str
    path: str
    description: Optional[str]
    status: str  # active/archived/deleted
    last_scan: datetime
    created_at: datetime
```

### 2.2 项目依赖关系

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
    # 读取项目名（目录名）
    name = project_path.name
    
    # 尝试从 README 获取描述
    description = None
    readme_path = project_path / "README.md"
    if readme_path.exists():
        # 读取第一行作为描述
        description = readme_path.read_text().split('\n')[0][:100]
    
    meta = ProjectMeta(
        name=name,
        path=str(project_path),
        description=description,
        status="active",
        last_scan=datetime.now()
    )
    
    return meta

def scan_all_projects(root_path: Path) -> list[Project]:
    """扫描所有项目"""
    projects = []
    
    # 扫描 data/ 目录下的子目录
    data_path = root_path / "data"
    if data_path.exists():
        for item in data_path.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                projects.append(scan_project(item))
    
    # 扫描 src/ 目录下的子目录
    src_path = root_path / "src"
    if src_path.exists():
        for item in src_path.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                # 跳过已有的 provider/studio/cli
                if item.name not in ["provider", "studio", "cli"]:
                    projects.append(scan_project(item))
    
    return projects
```

### 3.2 增量扫描

```python
def incremental_scan(root_path: Path, last_scan: datetime) -> list[Project]:
    """增量扫描，只处理变更的项目"""
    changed_projects = []
    
    for project_path in get_all_project_paths(root_path):
        # 检查目录修改时间
        mtime = datetime.fromtimestamp(project_path.stat().st_mtime)
        if mtime > last_scan:
            changed_projects.append(scan_project(project_path))
    
    return changed_projects
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
      "description": "隆昌制衣场数据清洗与合并工具",
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
  "description": "隆昌制衣场数据清洗与合并工具",
  "status": "active",
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
│ 隆昌制衣场数据清洗与合并工具      │
│ Status: active                  │
│ Last Scan: 2026-04-07 19:48     │
└─────────────────────────────────┘
```

### 6.2 依赖关系图

使用图可视化库展示项目间依赖：

```
[garment-factory-cleaner] → [garment-factory-analyzer]
         ↓
[garment-factory-report]
```

## 7. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | 项目扫描与列表展示 | P0 |
| M2 | 项目详情视图 | P1 |
| M3 | 依赖关系分析 | P2 |
| M4 | 依赖关系图可视化 | P2 |