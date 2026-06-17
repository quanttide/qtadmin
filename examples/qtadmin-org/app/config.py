from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "sqlite:///./qtcloud-org.db"
    debug: bool = True

    model_config = {"env_prefix": "QTCLOUD_ORG_"}
