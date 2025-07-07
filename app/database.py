'''# app/database.py
from sqlmodel import SQLModel, create_engine, Session
from dotenv import load_dotenv
import os

# 加载环境变量
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///database.db")
engine = create_engine(DATABASE_URL, echo=True)

def get_session():
    with Session(engine) as session:
        yield session

def init_db():
    """初始化数据库，创建所有表"""
    SQLModel.metadata.create_all(engine)

# 明确导出
__all__ = ["engine", "init_db", "get_session"]'''
# app/database.py
from sqlmodel import SQLModel, create_engine, Session
from dotenv import load_dotenv
import os

# 加载环境变量
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///database.db")
engine = create_engine(DATABASE_URL, echo=True, connect_args={"check_same_thread": False})


def get_session():
    with Session(engine) as session:
        yield session


def init_db():
    """初始化数据库，创建所有表"""
    # 显式导入所有模型以确保SQLModel发现它们
    from app.models.employee import Employee
    from app.models.salary import SalaryCalculation

    SQLModel.metadata.create_all(engine)
    print("数据库表已创建")