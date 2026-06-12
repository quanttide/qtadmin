"""Tests for the lark_client module."""

from unittest.mock import MagicMock

from qtadmin.lark_client import LarkClient


def _fake_list_json() -> str:
    return """{"messages": [{"message_id": "mail_id_001", "from": "张三 <zhangs@example.com>", "subject": "应聘前端工程师-张三", "date": "2026-06-01 10:00"}, {"message_id": "mail_id_002", "from": "李四 <lisi@example.com>", "subject": "求职-后端开发-李四", "date": "2026-06-02 14:30"}, {"message_id": "mail_id_003", "from": "王五 <wangw@example.com>", "subject": "笔试答案提交-前端岗位", "date": "2026-06-03 09:15"}]}"""


def _fake_read_json(mail_id: str) -> str:
    return f"""{{"data": {{"from": "张三 <zhangs@example.com>", "subject": "应聘前端工程师-张三", "body_html": "<p>您好</p>", "body_plain_text": "您好，我应聘前端工程师岗位...", "to": "hr@company.com", "attachments": []}}}}"""


def test_list_emails():
    """list_emails returns parsed email list."""
    mock_run = MagicMock(return_value=_fake_list_json())
    client = LarkClient(lark_path="lark-cli", run_cmd=mock_run)
    emails = client.list_emails(limit=10)
    assert len(emails) == 3
    assert emails[0].mail_id == "mail_id_001"
    assert emails[0].sender_name == "张三"
    assert emails[0].subject == "应聘前端工程师-张三"


def test_list_emails_passes_limit():
    """list_emails passes --limit to lark-cli."""
    mock_run = MagicMock(return_value=_fake_list_json())
    client = LarkClient(lark_path="lark-cli", run_cmd=mock_run)
    client.list_emails(limit=5)
    cmd = mock_run.call_args[0][0]
    assert "--max" in cmd
    assert "5" in cmd


def test_read_email():
    """read_email returns parsed email content."""
    mock_run = MagicMock(return_value=_fake_read_json("mail_id_001"))
    client = LarkClient(lark_path="lark-cli", run_cmd=mock_run)
    email = client.read_email("mail_id_001")
    assert email is not None
    assert email.mail_id == "mail_id_001"
    assert email.sender_name == "张三"
    assert email.sender_email == "zhangs@example.com"
    assert email.subject == "应聘前端工程师-张三"


def test_lark_path_from_config():
    """LarkClient uses the lark_path from config."""
    mock_run = MagicMock(return_value="")
    client = LarkClient(lark_path="/custom/lark", run_cmd=mock_run)
    client.list_emails(limit=5)
    cmd = mock_run.call_args[0][0]
    assert cmd[0] == "/custom/lark"
