# 量潮财务工具 — 部署与启动指南（Windows）

## 环境要求

- Python 3.12+
- 现代浏览器（Chrome / Edge / Firefox）

---

## 步骤

### 1. 创建虚拟环境并安装依赖

```powershell
cd packages\fastapi
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

### 2. 初始化演示数据

```powershell
cd demo
python seed.py --reset
```

预期输出：创建约 57 条 SourceRecords + NormalizedRecords + 分类数据。

### 3. 启动后端服务

```powershell
cd packages\fastapi
.venv\Scripts\Activate.ps1
$env:DEMO_DB="..\..\demo\demo.db"; uvicorn fastapi_quanttide_finance.app:app --reload
```

访问 `http://localhost:8000/health` 验证，返回 `{"status":"ok"}` 即正常。

### 4. 打开演示页面

在文件管理器中双击 `demo\index.html` 用浏览器打开。

---

## 演示流程

```
录入单据 → 确认标准化 → 系统自动分类 → 批量审核 → 统计看板
```

---

## 常见问题

| 问题 | 解决 |
|------|------|
| 端口被占用 | `uvicorn` 加 `--port 8001`，并修改 `index.html` 中 `API` 变量 |
| 数据为空 | 重新执行 `python seed.py --reset` |
| 页面无数据 | 确认 `$env:DEMO_DB` 指向了正确的 `demo.db` 路径 |
| 虚拟环境未激活 | `.venv\Scripts\Activate.ps1`（PowerShell）或 `.venv\Scripts\activate.bat`（CMD） |
