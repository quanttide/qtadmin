"""邮件读取 — 通过 lark-cli 拉取飞书收件箱，或使用 demo 数据。"""

import json
import subprocess

from feishu_integration.classifier import classify
def _parse_from_field(from_field: str) -> tuple[str, str]:
    """解析 '+triage' 返回的 from 字段为 (name, email)。"""
    if "<" in from_field and ">" in from_field:
        name = from_field[: from_field.index("<")].strip()
        email = from_field[from_field.index("<") + 1 : from_field.index(">")].strip()
        return name, email
    return "", from_field.strip()


def fetch_from_lark_cli(mailbox: str = "", max_results: int = 50) -> list[dict]:
    """调用 lark-cli mail +triage 拉取收件箱邮件。

    需要预先安装并登录 lark-cli:
        pip install lark-cli
        lark login
    """
    cmd = [
        "lark-cli", "mail", "+triage",
        "--format", "json",
        "--max", str(max_results),
    ]
    if mailbox:
        cmd.extend(["--mailbox", mailbox])

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        result.check_returncode()
        raw = json.loads(result.stdout)
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        raise RuntimeError(f"lark-cli 调用失败: {e}") from e

    messages = raw.get("messages", [])
    result_list = []
    for msg in messages:
        sender_name, sender_email = _parse_from_field(msg.get("from", ""))
        result_list.append({
            "message_id": msg.get("message_id", ""),
            "subject": msg.get("subject", ""),
            "sender_name": sender_name,
            "sender_email": sender_email,
        })
    return result_list


def fetch_single_email(message_id: str, mailbox: str = "") -> dict:
    """通过 lark-cli mail +message 读取单封邮件完整内容（正文+附件）。"""
    cmd = [
        "lark-cli", "mail", "+message",
        "--message-id", message_id,
        "--format", "json",
    ]
    if mailbox:
        cmd.extend(["--mailbox", mailbox])

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        result.check_returncode()
        raw = json.loads(result.stdout)
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        raise RuntimeError(f"lark-cli 调用失败: {e}") from e

    data = raw.get("data", {})
    attachments = []
    for a in data.get("attachments", []):
        attachments.append({
            "id": a.get("id", ""),
            "filename": a.get("filename", ""),
            "size": a.get("size", 0),
            "content_type": a.get("content_type", ""),
            "is_inline": a.get("is_inline", False),
        })
    return {
        "body": data.get("body_html", ""),
        "body_plain_text": data.get("body_plain_text", ""),
        "attachments": attachments,
        "subject": data.get("subject", ""),
        "to": data.get("to", ""),
    }


def fetch_and_classify(mailbox: str = "") -> list[dict]:
    """拉取邮件并分类。

    Args:
        mailbox: 飞书邮箱地址

    Returns:
        分类结果列表
    """
    raw_emails = fetch_from_lark_cli(mailbox=mailbox)

    results = []
    for raw in raw_emails:
        result = classify(raw["subject"], raw.get("sender_name", ""), raw["sender_email"])
        results.append({
            "message_id": raw["message_id"],
            "subject": raw["subject"],
            "sender_name": raw.get("sender_name", ""),
            "sender_email": raw["sender_email"],
            "suggested_status": result.suggested_status,
            "confidence": result.confidence,
            "extracted_name": result.extracted_name,
            "extracted_email": result.extracted_email,
            "body_preview": raw.get("body_preview", ""),
        })

    return results
