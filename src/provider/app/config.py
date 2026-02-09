# app/config.py
import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    # 从环境变量获取配置，提供默认值
    APP_NAME: str = os.getenv("APP_NAME", "Salary Management API")
    DEBUG: bool = os.getenv("DEBUG", "False") == "True"
    ENV: str = os.getenv("ENV", "development")


settings = Settings()