from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.database import get_db
from fastapi_quanttide_hr.models.ai_config import AIConfig

router = APIRouter(prefix="/ai", tags=["ai"])


class AIConfigRead(BaseModel):
    enabled: bool = False
    provider: str = "openai"
    base_url: str = ""
    api_key: str = ""
    model: str = ""
    prompt_template: str = ""
    timeout_seconds: int = 30
    retry_times: int = 2

    model_config = {"from_attributes": True}


class AIConfigUpdate(BaseModel):
    enabled: bool | None = None
    provider: str | None = None
    base_url: str | None = None
    api_key: str | None = None
    model: str | None = None
    prompt_template: str | None = None
    timeout_seconds: int | None = None
    retry_times: int | None = None


class AIConfigTestResult(BaseModel):
    success: bool
    message: str


def _mask_api_key(key: str) -> str:
    if len(key) <= 4:
        return "****"
    return key[:4] + "****"


def _get_or_create_config(db: Session) -> AIConfig:
    cfg = db.query(AIConfig).first()
    if not cfg:
        cfg = AIConfig()
        db.add(cfg)
        db.flush()
    return cfg


@router.get("/config", response_model=AIConfigRead)
def get_ai_config(db: Session = Depends(get_db)):
    cfg = _get_or_create_config(db)
    data = AIConfigRead.model_validate(cfg)
    if cfg.api_key_encrypted:
        data.api_key = _mask_api_key(cfg.api_key_encrypted)
    return data


@router.patch("/config", response_model=AIConfigRead)
def update_ai_config(body: AIConfigUpdate, db: Session = Depends(get_db)):
    cfg = _get_or_create_config(db)
    updates = body.model_dump(exclude_unset=True)
    if "api_key" in updates:
        cfg.api_key_encrypted = updates.pop("api_key")
    for field, val in updates.items():
        setattr(cfg, field, val)
    db.commit()
    db.refresh(cfg)

    data = AIConfigRead.model_validate(cfg)
    if cfg.api_key_encrypted:
        data.api_key = _mask_api_key(cfg.api_key_encrypted)
    return data


@router.post("/test", response_model=AIConfigTestResult)
def test_ai_config(db: Session = Depends(get_db)):
    import httpx

    cfg = db.query(AIConfig).first()
    if not cfg or not cfg.enabled:
        return AIConfigTestResult(success=False, message="AI 未启用")
    if not cfg.api_key_encrypted:
        return AIConfigTestResult(success=False, message="API Key 未配置")

    url = (cfg.base_url or "https://api.openai.com/v1").rstrip("/") + "/chat/completions"
    headers = {"Authorization": f"Bearer {cfg.api_key_encrypted}", "Content-Type": "application/json"}
    payload = {
        "model": cfg.model or "gpt-4o-mini",
        "messages": [{"role": "user", "content": "回复 OK 表示连接正常"}],
        "max_tokens": 10,
    }

    try:
        resp = httpx.post(url, headers=headers, json=payload, timeout=cfg.timeout_seconds or 30)
        resp.raise_for_status()
        return AIConfigTestResult(success=True, message="AI 连接成功")
    except httpx.TimeoutException:
        return AIConfigTestResult(success=False, message="连接超时")
    except httpx.HTTPStatusError as e:
        return AIConfigTestResult(success=False, message=f"HTTP {e.response.status_code}: {e.response.text[:200]}")
    except Exception as e:
        return AIConfigTestResult(success=False, message=f"连接失败: {str(e)[:200]}")
