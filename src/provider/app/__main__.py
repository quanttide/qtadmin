# app/__main__.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import engine, init_db  # 使用 app. 开头的绝对导入
from app.api.v1 import employees
import uvicorn

# 生命周期事件处理器
@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    # 在应用启动时初始化数据库
    print("初始化数据库...")
    init_db()
    yield
    # 应用关闭时清理（可选）
    print("应用关闭")

app = FastAPI(
    title="qtadmin API",
    version="0.1.0",
    description="qtadmin 管理后台 API",
    lifespan=lifespan
)

# 包含路由
app.include_router(employees.router, prefix="/api/v1/employees", tags=["员工"])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)