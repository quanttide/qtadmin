"""服务端分类引擎 — 三层分类：快速过滤 → 历史关联 → 独立分类。"""

from dataclasses import dataclass

from sqlalchemy.orm import Session

from fastapi_quanttide_hr.services.ai_classifier import AiClassification, ai_classify
from fastapi_quanttide_hr.services.email_matcher import MatchResult, match_by_email

_INTERNAL_DOMAINS: list[str] = []
_AUTO_REPLY_KEYWORDS = ["自动回复", "外出", "休假", "out of office", "auto-reply"]

_STATUS_KEYWORDS: dict[str, list[str]] = {
    "contacted": ["应聘", "求职", "简历", "申请", "投递", "个人简历"],
    "exam_sent": ["笔试邀请", "笔试通知", "在线考试"],
    "exam_received": ["笔试答案", "答题", "笔试完成", "提交答卷", "作答", "试卷", "已完成"],
    "evaluating": ["评估", "审核简历", "简历评估"],
    "interview": ["面试感谢", "面试反馈", "面试安排", "面试邀请", "确认参加", "时间安排"],
    "offer": ["offer", "录用通知", "入职邀请", "薪酬确认", "接受 offer", "入职"],
    "closed": ["放弃", "退出", "拒绝", "不考虑", "辞职"],
}


@dataclass
class EmailClassification:
    suggested_status: str | None
    confidence: str
    classifier_source: str
    classifier_reason: str | None
    merge_result: str | None
    extracted_name: str | None = None
    match: MatchResult | None = None


def classify(
    subject: str,
    body_text: str | None,
    sender_name: str | None,
    sender_email: str,
    db: Session,
    attachments: list[dict] | None = None,
) -> EmailClassification:
    """三层分类入口。"""
    # Layer 1: 快速过滤
    filtered = _fast_filter(subject, sender_email)
    if filtered:
        return EmailClassification(
            suggested_status=None,
            confidence="reject",
            classifier_source="rule",
            classifier_reason=filtered,
            merge_result=None,
        )

    # Layer 2: 历史关联
    match = match_by_email(sender_email, db, subject=subject)

    # Layer 3: AI 分类（可插拔，未配置时回退到关键词）
    ai_result = ai_classify(
        subject=subject,
        body_text=body_text,
        sender_name=sender_name,
        sender_email=sender_email,
        attachments=attachments,
        match=match,
        db=db,
    )
    if ai_result is not None:
        return EmailClassification(
            suggested_status=ai_result.suggested_status,
            confidence=ai_result.confidence,
            classifier_source="ai",
            classifier_reason=ai_result.classifier_reason,
            extracted_name=ai_result.extracted_name,
            merge_result=ai_result.merge_result or match.merge_result,
            match=ai_result.match or match,
        )

    # Layer 4: 关键词分类（AI 回退）
    status, conf, reason = _keyword_classify(subject, body_text, attachments)

    return EmailClassification(
        suggested_status=status,
        confidence=conf,
        classifier_source="rule",
        classifier_reason=reason,
        merge_result=match.merge_result,
        match=match,
    )


def _fast_filter(subject: str, sender_email: str) -> str | None:
    subject_lower = subject.lower()
    for kw in _AUTO_REPLY_KEYWORDS:
        if kw in subject_lower:
            return f"自动回复邮件: 命中关键词 '{kw}'"
    for domain in _INTERNAL_DOMAINS:
        if sender_email.endswith(f"@{domain}"):
            return f"内部邮箱: {sender_email}"
    return None


def _keyword_classify(
    subject: str,
    body_text: str | None,
    attachments: list[dict] | None = None,
) -> tuple[str | None, str, str | None]:
    subject_lower = subject.lower()
    combined = subject_lower
    if body_text:
        combined += " " + body_text.lower()

    matched: list[tuple[str, str]] = []
    for status, keywords in _STATUS_KEYWORDS.items():
        for kw in keywords:
            if kw in combined:
                matched.append((status, kw))

    if not matched:
        return None, "low", None

    groups: dict[str, int] = {}
    for s, _ in matched:
        groups[s] = groups.get(s, 0) + 1
    best = max(groups, key=groups.get)
    cnt = groups[best]

    conf = "high" if cnt >= 2 else "medium"
    kw_str = ", ".join(f"{s}({kw})" for s, kw in matched)
    has_att = attachments and len(attachments) > 0
    att_note = "+附件" if has_att else ""
    reason = f"命中关键词: [{kw_str}]{att_note}"

    return best, conf, reason
