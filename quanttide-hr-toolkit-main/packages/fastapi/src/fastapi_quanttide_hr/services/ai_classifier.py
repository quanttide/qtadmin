"""AI分类器 — 可插拔，未配置时返回 None 回退到规则分类。"""

import json
import logging
from dataclasses import dataclass

import httpx
from sqlalchemy.orm import Session

from fastapi_quanttide_hr.models.ai_config import AIConfig
from fastapi_quanttide_hr.services.email_matcher import MatchResult

logger = logging.getLogger(__name__)

_DEFAULT_PROMPT = """你是一个招聘邮件分类助手。根据邮件内容判断候选人处于招聘管道的哪个阶段，并提取候选人真实姓名。

规则：
1. suggested_status 必须是以下英文值之一（不能是中文）：
   new — 新投递简历/新应聘
   contacted — 回复了HR的联系邮件/普通咨询
   exam_sent — 询问笔试相关/笔试通知
   exam_received — 提交笔试答案/完成笔试
   evaluating — 询问评估进度/审核中
   interview — 面试相关沟通/面试感谢信
   offer — Offer沟通/接受Offer
   closed — 放弃机会/拒绝offer
2. extracted_name：从邮件正文或署名中提取候选人真实姓名，找不到则返回null"""


@dataclass
class AiClassification:
    suggested_status: str | None = None
    confidence: str = "low"
    classifier_reason: str | None = None
    extracted_name: str | None = None
    merge_result: str | None = None
    match: MatchResult | None = None


def ai_classify(
    subject: str,
    body_text: str | None,
    sender_name: str | None,
    sender_email: str,
    attachments: list[dict] | None = None,
    match: MatchResult | None = None,
    db: Session | None = None,
) -> AiClassification | None:
    """AI分类入口。读取 DB 中的 AI 配置，调用 AI 接口分类。

    当 AI 未配置或调用失败时返回 None，由 classifier.py 的回退机制接管。
    """
    if db is None:
        return None

    cfg = db.query(AIConfig).first()
    if not cfg or not cfg.enabled or not cfg.api_key_encrypted:
        return None

    body_text_truncated = (body_text or "")[:2000]
    user_prompt = cfg.prompt_template or _DEFAULT_PROMPT

    # Inject email context — this works whether or not the prompt template has placeholders
    email_context = (
        f"\n\n---\n邮件信息：\n"
        f"发件人: {sender_name or ''} <{sender_email}>\n"
        f"主题: {subject}\n"
        f"正文: {body_text_truncated}\n"
        f"---\n"
        f"请根据邮件内容选择最匹配的阶段值（必须用英文值）并提取候选人姓名。尽量给出判断而非null。\n"
        f'仅返回以下JSON格式：\n'
        f'{{"suggested_status": "...", "confidence": "high/medium/low", "reason": "...", "extracted_name": "姓名或null"}}'
    )
    full_content = user_prompt + email_context

    messages = [
        {
            "role": "user",
            "content": full_content,
        }
    ]

    url = (cfg.base_url or "https://api.openai.com/v1").rstrip("/") + "/chat/completions"
    headers = {
        "Authorization": f"Bearer {cfg.api_key_encrypted}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": cfg.model or "gpt-4o-mini",
        "messages": messages,
        "temperature": 0.1,
        "max_tokens": 300,
    }

    last_error: Exception | None = None
    for attempt in range(max(1, cfg.retry_times + 1)):
        try:
            resp = httpx.post(
                url,
                headers=headers,
                json=payload,
                timeout=cfg.timeout_seconds or 30,
            )
            logger.warning("AI API response status=%d body_preview=%s", resp.status_code, resp.text[:500])
            resp.raise_for_status()
            data = resp.json()
            content = data["choices"][0]["message"]["content"].strip()
            # Reasoning models (DeepSeek-R1, deepseek-v4-flash etc.) may return
            # reasoning_content before content — only the final content is in "content".
            # Try to extract JSON from the content (find first { and last })
            if "{" in content and "}" in content:
                json_start = content.index("{")
                json_end = content.rindex("}") + 1
                content = content[json_start:json_end]
            # Strip markdown code fence if present
            if content.startswith("```"):
                content = content.split("\n", 1)[-1] if "\n" in content else content[3:]
                content = content.rsplit("```", 1)[0].strip()
            result = json.loads(content)
            status = result.get("suggested_status")
            confidence = result.get("confidence", "low")
            reason = result.get("reason", "")
            extracted_name = result.get("extracted_name")

            if status and status not in _VALID_STATUSES:
                # Try fuzzy match — map Chinese/creative labels to valid statuses
                status_lower = status.lower()
                fuzzy_map = {
                    "新投递": "new", "新应聘": "new", "求职": "new", "投递": "new",
                    "面试结束": "interview", "面试": "interview", "面试反馈": "interview",
                    "笔试提交": "exam_received", "笔试": "exam_received",
                    "笔试发送": "exam_sent", "笔试通知": "exam_sent",
                    "评估": "evaluating",
                    "offer": "offer", "录用": "offer",
                    "放弃": "closed", "拒绝": "closed",
                }
                mapped = None
                for k, v in fuzzy_map.items():
                    if k in status or k in status_lower:
                        mapped = v
                        break
                if mapped:
                    status = mapped
                else:
                    logger.warning("AI returned unknown status: %s", status)
                    status = None
                    confidence = "low"

            return AiClassification(
                suggested_status=status,
                confidence=confidence or "low",
                classifier_reason=reason,
                extracted_name=extracted_name,
                merge_result=match.merge_result if match else None,
                match=match,
            )

        except httpx.TimeoutException as e:
            last_error = e
            logger.warning("AI request timeout (attempt %d/%d)", attempt + 1, cfg.retry_times + 1)
        except (httpx.HTTPStatusError, json.JSONDecodeError, KeyError, IndexError) as e:
            last_error = e
            logger.warning("AI request failed (attempt %d/%d): %s", attempt + 1, cfg.retry_times + 1, e)
            break  # Don't retry on HTTP errors or parse errors

    logger.error("AI classification failed after %d attempts: %s", cfg.retry_times + 1, last_error)
    return None


_VALID_STATUSES = {
    "new", "contacted", "exam_sent", "exam_received",
    "evaluating", "interview", "offer", "closed",
}
