"""Keyword-based email classifier for recruitment emails.

Rules are maintained here for local preview only.
The authoritative classification happens server-side.
"""

import dataclasses
import re


@dataclasses.dataclass
class Classification:
    """Result of classifying an email."""

    subject: str
    sender_name: str | None = None
    sender_email: str | None = None
    suggested_status: str | None = None
    confidence: str = "low"
    suggested_position: str | None = None
    extracted_name: str | None = None
    extracted_email: str | None = None
    extracted_phone: str | None = None

    def __bool__(self) -> bool:
        return self.suggested_status is not None


# Priority-ordered rules: (status, [keywords], confidence)
# Earlier rules take precedence over later ones.
_STATUS_RULES: list[tuple[str, list[str], str]] = [
    ("contacted", ["应聘", "求职", "简历"], "high"),
    ("exam_received", ["笔试答案", "答题", "笔试完成", "提交答卷", "试卷"], "high"),
    ("interview", ["面试感谢", "面试反馈", "面试安排", "面试邀请", "面试结果"], "medium"),
    ("closed", ["放弃", "退出", "拒绝", "不考虑", "辞职", "离职"], "medium"),
    ("exam_sent", ["笔试邀请", "笔试通知", "在线考试"], "high"),
    ("evaluating", ["评估", "审核简历", "简历评估"], "medium"),
    ("offer", ["offer", "录用通知", "入职邀请", "薪酬确认"], "medium"),
    ("contacted", ["申请"], "medium"),
]

POSITION_KEYWORDS: dict[str, list[str]] = {
    "前端工程师": ["前端", "web前端", "h5"],
    "后端工程师": ["后端", "服务端", "java", "python", "go"],
    "全栈工程师": ["全栈"],
    "产品经理": ["产品经理", "产品"],
    "设计师": ["设计", "ui", "ux"],
}

_HEADHUNTER_DOMAINS = ["liepin", "zhaopin", "51job", "hunter", "猎聘"]
_HEADHUNTER_BODY_KEYWORDS = ["推荐候选人"]

_PHONE_PATTERN = re.compile(r"1[3-9]\d{9}")


def classify(
    subject: str,
    body: str = "",
    sender_name: str | None = None,
    sender_email: str | None = None,
) -> Classification:
    """Classify a recruitment email by its subject, body, and sender.

    Rules are evaluated in priority order. The first match wins.
    This is a local preview only — the server makes the authoritative decision.
    """
    subject_lower = subject.lower()

    # --- Status classification (first-match-wins by priority) ---
    suggested_status: str | None = None
    confidence = "low"

    for status, keywords, rule_confidence in _STATUS_RULES:
        for kw in keywords:
            if kw in subject_lower:
                suggested_status = status
                confidence = rule_confidence
                break
        if suggested_status:
            break

    if not suggested_status:
        # Fallback: headhunter domain/keyword detection
        if sender_email:
            domain = sender_email.split("@")[-1].lower() if "@" in sender_email else ""
            for hd in _HEADHUNTER_DOMAINS:
                if hd in domain:
                    suggested_status = "contacted"
                    confidence = "low"
                    break

        if not suggested_status:
            for kw in _HEADHUNTER_BODY_KEYWORDS:
                if kw in body:
                    suggested_status = "contacted"
                    confidence = "low"
                    break

    # --- Position classification ---
    suggested_position: str | None = None
    for pos, keywords in POSITION_KEYWORDS.items():
        for kw in keywords:
            if kw in subject_lower:
                suggested_position = pos
                break
        if suggested_position:
            break

    # --- Field extraction ---
    extracted_name: str | None = None
    if sender_name and sender_name != sender_email:
        extracted_name = sender_name
    extracted_email = sender_email

    extracted_phone: str | None = None
    phone_match = _PHONE_PATTERN.search(body)
    if phone_match:
        extracted_phone = phone_match.group(0)

    return Classification(
        subject=subject,
        sender_name=sender_name,
        sender_email=sender_email,
        suggested_status=suggested_status,
        confidence=confidence,
        suggested_position=suggested_position,
        extracted_name=extracted_name,
        extracted_email=extracted_email,
        extracted_phone=extracted_phone,
    )
