"""飞书邮件分类引擎 — 基于关键字规则。

classification-flow.md 定义的分类规则由宿主应用维护，本模块提供默认规则实现。
"""

from dataclasses import dataclass


STATUS_KEYWORDS: dict[str, list[str]] = {
    "contacted": ["应聘", "求职", "简历", "申请"],
    "exam_sent": ["笔试邀请", "笔试通知", "在线考试"],
    "exam_received": ["笔试答案", "答题", "笔试完成", "提交答卷"],
    "evaluating": ["评估", "审核简历", "简历评估"],
    "interview": ["面试感谢", "面试反馈", "面试安排", "面试邀请"],
    "offer": ["offer", "录用通知", "入职邀请", "薪酬确认"],
    "closed": ["放弃", "退出", "拒绝", "不考虑"],
}

POSITION_KEYWORDS: dict[str, list[str]] = {
    "前端工程师": ["前端", "web前端", "h5"],
    "后端工程师": ["后端", "服务端", "java", "python", "go"],
    "全栈工程师": ["全栈"],
    "产品经理": ["产品经理", "产品"],
    "设计师": ["设计", "ui", "ux"],
}


@dataclass
class ClassificationResult:
    suggested_status: str | None
    confidence: str
    suggested_position: str | None
    extracted_name: str | None
    extracted_email: str | None
    extracted_phone: str | None


def classify(subject: str, sender_name: str, sender_email: str) -> ClassificationResult:
    subject_lower = subject.lower()

    suggested_status = None
    confidence = "low"
    matched_keywords = []

    for status, keywords in STATUS_KEYWORDS.items():
        for kw in keywords:
            if kw in subject_lower:
                matched_keywords.append((status, kw))

    if matched_keywords:
        status_groups: dict[str, int] = {}
        for s, _ in matched_keywords:
            status_groups[s] = status_groups.get(s, 0) + 1
        suggested_status = max(status_groups, key=status_groups.get)
        confidence = "high" if status_groups[suggested_status] >= 2 else "medium"
    else:
        confidence = "low"

    suggested_position = None
    for pos, keywords in POSITION_KEYWORDS.items():
        for kw in keywords:
            if kw in subject_lower:
                suggested_position = pos
                break
        if suggested_position:
            break

    extracted_name = sender_name if sender_name and sender_name != sender_email else None
    extracted_email = sender_email
    extracted_phone = None

    return ClassificationResult(
        suggested_status=suggested_status,
        confidence=confidence,
        suggested_position=suggested_position,
        extracted_name=extracted_name,
        extracted_email=extracted_email,
        extracted_phone=extracted_phone,
    )
