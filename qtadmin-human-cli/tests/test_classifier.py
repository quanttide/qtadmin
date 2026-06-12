"""Tests for the classifier module."""

from qtadmin.classifier import Classification, classify


def test_classify_application():
    """主题含应聘+职位 -> contacted, high."""
    result = classify(subject="应聘前端工程师-张三")
    assert result.suggested_status == "contacted"
    assert result.confidence == "high"


def test_classify_job_seeking():
    """主题含求职+职位 -> contacted, high."""
    result = classify(subject="求职-后端开发-李四")
    assert result.suggested_status == "contacted"
    assert result.confidence == "high"


def test_classify_exam_answer():
    """主题含笔试答案 -> exam_received, high."""
    result = classify(subject="笔试答案提交-前端岗位-王五")
    assert result.suggested_status == "exam_received"
    assert result.confidence == "high"


def test_classify_exam_answer_variant():
    """主题含答题 -> exam_received, high."""
    result = classify(subject="答题-前端-张三")
    assert result.suggested_status == "exam_received"


def test_classify_exam_paper():
    """主题含试卷 -> exam_received, high."""
    result = classify(subject="前端工程师入职试卷-王五")
    assert result.suggested_status == "exam_received"


def test_classify_interview_thanks():
    """主题含面试感谢 -> interview, medium."""
    result = classify(subject="面试感谢-张三-前端")
    assert result.suggested_status == "interview"
    assert result.confidence == "medium"


def test_classify_interview_feedback():
    """主题含面试反馈 -> interview, medium."""
    result = classify(subject="面试反馈-后端-李四")
    assert result.suggested_status == "interview"


def test_classify_interview_result():
    """主题含面试结果 -> interview, medium."""
    result = classify(subject="前端岗面试结果通知")
    assert result.suggested_status == "interview"


def test_classify_resign():
    """主题含辞 -> closed, medium."""
    result = classify(subject="辞职申请-张三")
    assert result.suggested_status == "closed"
    assert result.confidence == "medium"


def test_classify_abandon():
    """主题含放弃 -> closed, medium."""
    result = classify(subject="放弃入职-前端岗位")
    assert result.suggested_status == "closed"


def test_classify_quit():
    """主题含退出 -> closed, medium."""
    result = classify(subject="退出招聘流程-张三")
    assert result.suggested_status == "closed"


def test_classify_headhunter_in_body():
    """正文含推荐候选人 -> contacted, low."""
    result = classify(
        subject="推荐人才",
        body="推荐候选人-赵六-3年Java经验",
    )
    assert result.suggested_status == "contacted"
    assert result.confidence == "low"


def test_classify_headhunter_domain():
    """发件人域名含猎头特征 -> contacted, low."""
    result = classify(
        subject="候选人推荐-张三",
        sender_email="recruiter@liepin.com",
    )
    assert result.suggested_status == "contacted"
    assert result.confidence == "low"


def test_classify_no_match():
    """无法匹配 -> null suggestion, low confidence."""
    result = classify(
        subject="Fwd: Weekly Report",
        sender_email="internal@company.com",
    )
    assert result.suggested_status is None
    assert result.confidence == "low"


def test_classify_no_match_empty_subject():
    """空主题 -> null suggestion."""
    result = classify(subject="", sender_email="nobody@test.com")
    assert result.suggested_status is None


def test_classify_application_priority_over_headhunter():
    """应聘规则优先于猎头规则（主题匹配优先）。"""
    result = classify(
        subject="应聘-前端工程师-张三",
        body="推荐候选人信息",
    )
    assert result.suggested_status == "contacted"
    assert result.confidence == "high"


def test_classification_fields():
    """Classification has all expected fields."""
    result = classify(subject="应聘-岗位", sender_email="a@b.com", sender_name="张三")
    assert result.suggested_status is not None
    assert result.confidence in ("high", "medium", "low")
    assert isinstance(result.subject, str)
    assert result.sender_email == "a@b.com"
    assert result.sender_name == "张三"
