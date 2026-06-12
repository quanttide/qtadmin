import pytest

from feishu_integration.classifier import classify


def test_classify_contacted():
    result = classify("应聘前端工程师 - 张三", "张三", "zhangsan@email.com")
    assert result.suggested_status == "contacted"
    assert result.confidence == "medium"
    assert result.suggested_position == "前端工程师"


def test_classify_exam_received():
    result = classify("笔试答案提交 - 前端笔试题", "赵六", "zhaoliu@email.com")
    assert result.suggested_status == "exam_received"
    assert result.extracted_name == "赵六"


def test_classify_interview():
    result = classify("面试感谢信 - 感谢昨天的面试机会", "孙七", "sunqi@email.com")
    assert result.suggested_status == "interview"


def test_classify_closed():
    result = classify("放弃这次机会，谢谢", "周八", "zhouba@email.com")
    assert result.suggested_status == "closed"


def test_classify_offer():
    result = classify("offer 接受 - 前端工程师岗位", "郑十", "zhengshi@email.com")
    assert result.suggested_status == "offer"


def test_classify_low_confidence():
    result = classify("咨询招聘进度", "吴九", "wujiu@email.com")
    assert result.suggested_status is None
    assert result.confidence == "low"


def test_classify_position_extraction():
    result = classify("应聘Java后端开发", "李四", "lisi@email.com")
    assert result.suggested_position == "后端工程师"


def test_classify_no_sender_name():
    result = classify("求职后端开发岗位", "lisi@email.com", "lisi@email.com")
    assert result.extracted_name is None
    assert result.extracted_email == "lisi@email.com"
