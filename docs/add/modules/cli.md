# CLI 模块：命令行工具技术设计

基于 PRD [cli.md](../../prd/cli.md) 的技术实现方案。

## 1. 系统架构

### 1.1 整体架构

命令行工具采用独立进程架构：

- **CLI 进程**：Python 应用，处理用户命令
- **配置存储**：SQLite 本地数据库
- **历史记录**：SQLite 操作日志
- **OSS 交互**：调用阿里云 CLI 或 Python SDK

### 1.2 命令解析流程

```
用户输入 → 解析器 → 参数验证 → 命令执行 → 输出格式化 → 结果展示
```

核心组件：
- 命令解析器：Typer 框架，支持类型提示
- 参数验证器：自动类型转换、范围检查
- 命令执行器：调用后端服务或 OSS SDK
- 输出格式化器：表格、JSON、安静模式

## 2. 框架选型

### 2.1 CLI 框架对比

| 框架 | 优点 | 缺点 |
|------|------|------|
| Typer | 简洁、类型提示友好、现代 | 依赖 Click，相对新 |
| Click | 成熟稳定、社区大 | 代码稍冗长 |
| argparse | 标准库、无依赖 | 代码冗长、不够现代 |

**推荐：Typer**（简洁、类型安全）

### 2.2 输出美化框架

| 框架 | 优点 |
|------|------|
| Rich | 表格、颜色、进度条 |
| colorama | 简单颜色输出 |
| tabulate | 表格输出 |

**推荐：Rich**（功能全面、美观）

## 3. 数据结构

### 3.1 命令历史记录

```python
class CommandHistory(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    command: str  # 完整命令
    args: dict  # 参数字典
    status: str  # success/failed
    output: Optional[str]  # 输出结果
    duration_ms: int  # 执行时长
    created_at: datetime
```

### 3.2 项目配置

```python
class ProjectConfig(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    name: str
    path: str
    oss_bucket: Optional[str]
    oss_prefix: Optional[str]
    created_at: datetime
```

## 4. 命令实现

### 4.1 OSS 命令

```python
import typer
from rich.console import Console
from rich.table import Table

app = typer.Typer()
console = Console()

@app.command()
def ls(oss_path: str, recursive: bool = False):
    """列举 OSS 文件"""
    objects = oss_client.list_objects(oss_path, recursive)
    
    # 表格输出
    table = Table(title=f"Objects in {oss_path}")
    table.add_column("LastModifiedTime")
    table.add_column("Size(B)")
    table.add_column("ObjectName")
    
    for obj in objects:
        table.add_row(
            obj.last_modified,
            str(obj.size),
            obj.name
        )
    
    console.print(table)

@app.command()
def cp(source: str, dest: str, recursive: bool = False):
    """复制文件"""
    with console.status("[bold green]Copying..."):
        result = oss_client.copy(source, dest, recursive)
    console.print(f"[green]Succeed:[/] {result}")
```

### 4.2 项目命令

```python
@app.command()
def init(project_name: str):
    """初始化项目结构"""
    template = {
        "data/": ["raw/", "processed/", "final/"],
        "docs/": ["index.md"],
        "src/": [],
        "README.md": DEFAULT_README,
        "pyproject.toml": DEFAULT_PYPROJECT
    }
    
    create_project_structure(project_name, template)
    console.print(f"[green]Project {project_name} initialized[/]")
```

### 4.3 数据处理命令

```python
@app.command()
def run(project: str, step: int):
    """运行处理脚本"""
    project_path = get_project_path(project)
    script_path = project_path / "src" / f"{step}.py"
    
    if not script_path.exists():
        console.print(f"[red]Script not found: {script_path}[/]")
        raise typer.Exit(1)
    
    with console.status(f"[bold green]Running step {step}..."):
        result = subprocess.run(
            ["python", str(script_path)],
            cwd=project_path
        )
    
    if result.returncode == 0:
        console.print(f"[green]Step {step} completed[/]")
    else:
        console.print(f"[red]Step {step} failed[/]")
        raise typer.Exit(1)
```

## 5. 输出格式

### 5.1 表格格式（默认）

```
$ qt oss ls oss://qttech-data/data/garment-factory/

LastModifiedTime        Size(B)    ObjectName
2026-04-07 19:28:24    38295446   final/产量数据_工序_返工_合并_test.xlsx
2026-04-07 19:28:24    39315762   final/产量数据_工序_返工_考勤_合并_test.xlsx
Object Number is: 2
```

### 5.2 JSON 格式

```
$ qt oss ls oss://qttech-data/data/garment-factory/ --output json

{
  "objects": [
    {
      "last_modified": "2026-04-07 19:28:24",
      "size": 38295446,
      "name": "final/产量数据_工序_返工_合并_test.xlsx"
    }
  ],
  "count": 2
}
```

## 6. 配置管理

### 6.1 配置文件位置

```
~/.qt/
├── config.toml    # 全局配置
├── history.db     # 命令历史（SQLite）
└── projects.db    # 项目配置（SQLite）
```

### 6.2 配置示例

```toml
# ~/.qt/config.toml
[oss]
default_bucket = "qttech-data"
region = "oss-cn-hangzhou"

[output]
default_format = "table"  # table/json/quiet
```

## 7. 与 OSS 交互

### 7.1 集成方案

**初期**：调用阿里云 CLI（`aliyun oss`）

```python
def call_oss_cli(args: list[str]) -> str:
    result = subprocess.run(
        ["aliyun", "oss"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout
```

**后期**：迁移到 Python SDK

```python
import oss2

def upload_to_oss(local_path: str, oss_path: str):
    bucket = oss2.Bucket(auth, endpoint, bucket_name)
    bucket.put_object_from_file(oss_path, local_path)
```

## 8. 技术栈

| 组件 | 技术选型 |
|------|----------|
| CLI 框架 | Typer |
| 输出美化 | Rich |
| 配置解析 | toml |
| 本地存储 | SQLite |
| OSS 交互 | 阿里云 CLI → Python SDK |

## 9. 实现优先级

| 阶段 | 功能 | 优先级 |
|------|------|--------|
| M1 | OSS 基本命令（ls/cp/rm） | P0 |
| M2 | 项目管理命令（ls/init/status） | P1 |
| M3 | 数据处理命令（run/accept/log） | P1 |
| M4 | 文档生成命令（readme/index） | P2 |
| M5 | 操作历史与配置管理 | P2 |