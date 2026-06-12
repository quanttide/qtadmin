"""Wrapper around lark-cli subprocess (JSON output mode)."""

import dataclasses
import json
import subprocess
from collections.abc import Callable


@dataclasses.dataclass
class LarkEmail:
    """Parsed email from lark-cli output."""

    mail_id: str
    sender_name: str = ""
    sender_email: str = ""
    subject: str = ""
    date: str = ""


@dataclasses.dataclass
class LarkEmailDetail:
    """Full email detail including body and attachments."""

    mail_id: str
    sender_name: str = ""
    sender_email: str = ""
    subject: str = ""
    body: str = ""
    body_plain_text: str = ""
    attachments: list[dict] = dataclasses.field(default_factory=list)
    to: str = ""


def _parse_from_field(from_field: str) -> tuple[str, str]:
    """Parse '+triage' from field into (name, email)."""
    if "<" in from_field and ">" in from_field:
        name = from_field[: from_field.index("<")].strip()
        email = from_field[from_field.index("<") + 1 : from_field.index(">")].strip()
        return name, email
    return "", from_field.strip()


class LarkClient:
    """Wraps lark-cli commands via subprocess (JSON output)."""

    def __init__(
        self,
        lark_path: str = "lark-cli",
        run_cmd: Callable | None = None,
    ) -> None:
        self._lark_path = lark_path
        self._run_cmd = run_cmd or self._default_run

    def _default_run(self, cmd: list[str], **kwargs) -> str:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30, **kwargs)
        result.check_returncode()
        return result.stdout

    def list_emails(self, limit: int = 20, since: str = "7d", mailbox: str = "") -> list[LarkEmail]:
        """List recruitment emails from the inbox using JSON output."""
        cmd = [self._lark_path, "mail", "+triage", "--format", "json", "--max", str(limit)]
        if mailbox:
            cmd.extend(["--mailbox", mailbox])
        raw = self._run_cmd(cmd)
        return self._parse_list_json(raw)

    def read_email(self, mail_id: str, mailbox: str = "") -> LarkEmailDetail | None:
        """Read a single email's full content including body and attachments."""
        cmd = [self._lark_path, "mail", "+message", "--message-id", mail_id, "--format", "json"]
        if mailbox:
            cmd.extend(["--mailbox", mailbox])
        raw = self._run_cmd(cmd)
        return self._parse_read_json(mail_id, raw)

    def send_email(self, recipient: str, subject: str, body: str) -> dict:
        """Send an email via lark-cli. Returns parsed JSON response."""
        cmd = [
            self._lark_path, "mail", "+send",
            "--to", recipient,
            "--subject", subject,
            "--body", body,
            "--confirm-send",
            "--format", "json",
        ]
        raw = self._run_cmd(cmd, timeout=60)
        return json.loads(raw)

    def _parse_list_json(self, raw: str) -> list[LarkEmail]:
        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            return []

        emails: list[LarkEmail] = []
        messages = data.get("messages", [])
        for msg in messages:
            sender_name, sender_email = _parse_from_field(msg.get("from", ""))
            emails.append(LarkEmail(
                mail_id=msg.get("message_id", ""),
                sender_name=sender_name,
                sender_email=sender_email,
                subject=msg.get("subject", ""),
                date=msg.get("date", ""),
            ))
        return emails

    def _parse_read_json(self, mail_id: str, raw: str) -> LarkEmailDetail | None:
        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            return None

        msg_data = data.get("data", {})
        sender_name, sender_email = _parse_from_field(msg_data.get("from", ""))

        attachments = []
        for a in msg_data.get("attachments", []):
            attachments.append({
                "id": a.get("id", ""),
                "filename": a.get("filename", ""),
                "size": a.get("size", 0),
                "content_type": a.get("content_type", ""),
                "is_inline": a.get("is_inline", False),
            })

        return LarkEmailDetail(
            mail_id=mail_id,
            sender_name=sender_name,
            sender_email=sender_email,
            subject=msg_data.get("subject", ""),
            body=msg_data.get("body_html", ""),
            body_plain_text=msg_data.get("body_plain_text", ""),
            attachments=attachments,
            to=msg_data.get("to", ""),
        )
