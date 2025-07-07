# app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import engine, init_db  # 使用 app. 开头的绝对导入
from app.api.v1 import employees, salary  # 同样改为绝对导入
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
    title="薪资管理系统",
    version="0.1.0",
    description="薪资计算和管理API服务",
    lifespan=lifespan  # 使用新的lifespan事件处理器
)

# 包含路由
app.include_router(salary.router, prefix="/api/v1/salary", tags=["薪资"])
app.include_router(employees.router, prefix="/api/v1/employees", tags=["员工"])

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)