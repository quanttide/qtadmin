# app/schemas/base.py
from pydantic import BaseModel

class BaseModel(BaseModel):
    """所有模型的基础类"""
    class Config:
        # 允许ORM模式
        orm_mode = True
        # 允许任意类型
        arbitrary_types_allowed = True