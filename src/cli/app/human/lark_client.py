"""Wrapper around lark-cli subprocess."""
import logging
import subprocess
from dataclasses import dataclass

logger = logging.getLogger(__name__)


@dataclass
class LarkEmail:
    mail_id: str
    sender_name: str = ""
    sender_email: str = ""
    subject: str = ""
    body: str = ""
    date: str = ""


class LarkClient:
    """Wraps lark-cli commands via subprocess."""

    def __init__(self, lark_path: str = "lark-cli") -> None:
        self._lark_path = lark_path

    def _run(self, cmd: list[str]) -> str:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        result.check_returncode()
        return result.stdout

    def list_emails(self, limit: int = 20, since: str = "7d") -> list[LarkEmail]:
        cmd = [self._lark_path, "mail", "list", "--limit", str(limit), "--since", since]
        raw = self._run(cmd)
        return self._parse_list_output(raw)

    def read_email(self, mail_id: str) -> LarkEmail | None:
        cmd = [self._lark_path, "mail", "read", mail_id]
        raw = self._run(cmd)
        return self._parse_read_output(mail_id, raw)

    def _parse_list_output(self, raw: str) -> list[LarkEmail]:
        emails: list[LarkEmail] = []
        for line in raw.strip().splitlines():
            parts = line.strip().split(maxsplit=3)
            if len(parts) >= 2:
                emails.append(LarkEmail(
                    mail_id=parts[0],
                    sender_name=parts[1] if len(parts) > 1 else "",
                    subject=parts[2] if len(parts) > 2 else "",
                    date=parts[3] if len(parts) > 3 else "",
                ))
        return emails

    def _parse_read_output(self, mail_id: str, raw: str) -> LarkEmail | None:
        if not raw.strip():
            return None
        sender_name = ""
        sender_email = ""
        subject = ""
        body = ""
        in_body = False
        for line in raw.splitlines():
            if line.startswith("From:"):
                rest = line[5:].strip()
                if "<" in rest and ">" in rest:
                    sender_name = rest.split("<")[0].strip()
                    sender_email = rest.split("<")[1].rstrip(">").strip()
                else:
                    sender_name = rest
            elif line.startswith("Subject:"):
                subject = line[8:].strip()
            elif line.startswith("Body:"):
                in_body = True
            elif in_body:
                body += line + "\n"
        return LarkEmail(
            mail_id=mail_id,
            sender_name=sender_name,
            sender_email=sender_email,
            subject=subject,
            body=body.strip(),
        )
