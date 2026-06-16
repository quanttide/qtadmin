"""qtadmin CLI — HR recruitment email classification tool.

Supports: mail list, mail classify, mail ingest, mail send, status.
"""

import json
import logging
import os
import sys
import time

import click

from qtadmin.api_client import ApiClient
from qtadmin.classifier import classify
from qtadmin.config import ConfigManager
from qtadmin.lark_client import LarkClient
from qtadmin.mail_sender import send_pending

__version__ = "2.0.0"

_CONFIG_PATH = os.path.expanduser("~/.config/qtadmin/config.json")
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s")


def _eprint(*args: object, **kwargs: object) -> None:
    print(*args, file=sys.stderr, **kwargs)


def _get_cfg() -> ConfigManager:
    return ConfigManager(_CONFIG_PATH)


def _get_api(cfg: ConfigManager) -> ApiClient:
    url = cfg.get("provider_url")
    if not url:
        _eprint("Provider URL not configured. Run: qtadmin config set-provider <url>")
        sys.exit(1)
    return ApiClient(base_url=url)


def _get_lark(cfg: ConfigManager) -> LarkClient:
    return LarkClient(lark_path=cfg.get("lark_path"))


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.version_option(version=__version__, prog_name="qtadmin", message="qtadmin %(version)s")
def cli() -> None:
    """qtadmin — HR recruitment email classification tool.

    Wraps lark-cli to pull recruitment emails, classify them,
    and push to the qtadmin provider pending queue.

    Note: Local classification is for preview only.
    The authoritative classification happens server-side.
    """


@cli.group()
def config() -> None:
    """Manage configuration (stored in ~/.config/qtadmin/config.json)."""


@config.command(name="set-provider")
@click.argument("url")
def config_set_provider(url: str) -> None:
    """Set provider server URL. Example: http://localhost:8000"""
    _get_cfg().set("provider_url", url)
    _eprint(f"✓ Provider URL set to {url}")


@config.command(name="set-lark-path")
@click.argument("path")
def config_set_lark_path(path: str) -> None:
    """Set lark-cli path (if not in PATH)."""
    _get_cfg().set("lark_path", path)
    _eprint(f"✓ lark-cli path set to {path}")


@config.command(name="set-mailbox")
@click.argument("email")
def config_set_mailbox(email: str) -> None:
    """Set Feishu mailbox address."""
    _get_cfg().set("mailbox", email)
    _eprint(f"✓ Mailbox set to {email}")


@config.command()
def show() -> None:
    """Show current configuration."""
    data = _get_cfg().show()
    click.echo(json.dumps(data, indent=2, ensure_ascii=False))


@cli.group()
def human() -> None:
    """HR business operations."""


@human.group()
def mail() -> None:
    """Mail operations: list, classify, ingest, send."""


@mail.command(name="list")
@click.option("-n", "--limit", default=20, show_default=True, help="Max emails to list")
@click.option("--json", "as_json", is_flag=True, help="Output as JSON (for piping)")
def mail_list(limit: int, as_json: bool) -> None:
    cfg = _get_cfg()
    lark = _get_lark(cfg)
    emails = lark.list_emails(limit=limit, mailbox=cfg.get("mailbox"))

    if not emails:
        _eprint("No emails found. Make sure lark-cli is installed and logged in.")
        return

    if as_json:
        click.echo(
            json.dumps(
                [
                    {
                        "mail_id": e.mail_id,
                        "subject": e.subject,
                        "sender": e.sender_name,
                        "sender_email": e.sender_email,
                        "date": e.date,
                    }
                    for e in emails
                ],
                ensure_ascii=False,
            )
        )
        return

    click.echo(" ⚠  以下分类结果为本地预览，最终分类以服务端为准\n")
    click.echo(f" {'#':>3} │ {'发件人':<8} │ {'主题':<40} │ {'建议状态':<14} │ {'置信度':<6}")
    click.echo("─────┼──────────┼──────────────────────────────────────────┼────────────────┼────────")
    for i, email in enumerate(emails, 1):
        result = classify(subject=email.subject, sender_name=email.sender_name, sender_email=email.sender_email)
        status = result.suggested_status or "待确认"
        click.echo(f" {i:>3} │ {email.sender_name:<8} │ {email.subject:<40} │ {status:<14} │ {result.confidence:<6}")


@mail.command(name="classify")
@click.argument("mail_id")
@click.option("--json", "as_json", is_flag=True, help="Output as JSON")
def mail_classify(mail_id: str, as_json: bool) -> None:
    cfg = _get_cfg()
    lark = _get_lark(cfg)
    email = lark.read_email(mail_id, mailbox=cfg.get("mailbox"))
    if not email:
        _eprint(f"Email '{mail_id}' not found. Verify the ID with 'qtadmin human mail list'.")
        sys.exit(1)

    result = classify(
        subject=email.subject,
        body=email.body_plain_text or email.body,
        sender_name=email.sender_name,
        sender_email=email.sender_email,
    )

    if as_json:
        click.echo(
            json.dumps(
                {
                    "mail_id": mail_id,
                    "subject": email.subject,
                    "sender_name": email.sender_name,
                    "sender_email": email.sender_email,
                    "suggested_status": result.suggested_status,
                    "confidence": result.confidence,
                    "suggested_position": result.suggested_position,
                    "extracted_name": result.extracted_name,
                    "extracted_email": result.extracted_email,
                    "extracted_phone": result.extracted_phone,
                },
                ensure_ascii=False,
            )
        )
        return

    click.echo(f"  发件人: {email.sender_name} <{email.sender_email}>")
    click.echo(f"  主题:   {email.subject}")
    click.echo(f"  建议状态: {result.suggested_status or '无法自动分类'} (置信度: {result.confidence})")
    if result.suggested_position:
        click.echo(f"  建议职位: {result.suggested_position}")
    if result.extracted_name:
        click.echo(f"  提取姓名: {result.extracted_name}")
    if result.extracted_phone:
        click.echo(f"  提取电话: {result.extracted_phone}")
    click.echo("\n  ⚠ 本地预览，最终分类以服务端为准")


@mail.command(name="ingest")
@click.option("-n", "--limit", default=20, show_default=True, help="Max emails to process")
@click.option("--dry-run", is_flag=True, help="Preview what would be pushed")
@click.option("--status", default=None, help="Only push emails matching this status")
@click.option("--with-content", is_flag=True, default=True, help="Fetch full body + attachments")
@click.option("--json", "as_json", is_flag=True, help="Output result as JSON")
def mail_ingest(dry_run: bool, limit: int, status: str | None, with_content: bool, as_json: bool) -> None:
    cfg = _get_cfg()
    api = _get_api(cfg)
    lark = _get_lark(cfg)
    mailbox = cfg.get("mailbox")

    emails = lark.list_emails(limit=limit, mailbox=mailbox)

    items = []
    for email in emails:
        detail = lark.read_email(email.mail_id, mailbox=mailbox)

        body_text = detail.body_plain_text if detail else ""
        body_html = detail.body if detail else ""
        attachments = detail.attachments if detail else []

        result = classify(
            subject=email.subject,
            body=body_text or body_html,
            sender_name=email.sender_name,
            sender_email=email.sender_email,
        )

        if status and result.suggested_status != status:
            continue

        raw_attachments = []
        for attachment in attachments:
            raw_attachments.append(
                {
                    "filename": attachment.get("filename", ""),
                    "size": attachment.get("size", 0),
                    "mime_type": attachment.get("content_type"),
                    "message_attachment_id": attachment.get("id"),
                }
            )

        item = {
            "message_id": email.mail_id,
            "subject": email.subject,
            "sender_name": email.sender_name,
            "sender_email": email.sender_email,
            "body": body_html,
            "body_text": body_text,
            "attachments": raw_attachments,
            "extracted_name": result.extracted_name,
            "extracted_email": result.extracted_email,
            "extracted_phone": result.extracted_phone,
        }

        suggested_recruitment_title = result.suggested_position
        if suggested_recruitment_title:
            item["suggested_recruitment_title"] = suggested_recruitment_title

        items.append(item)

    if dry_run or not items:
        if as_json:
            click.echo(json.dumps({"dry_run": True, "count": len(items), "items": items}, ensure_ascii=False))
            return
        click.echo("\n  ⚠ 以下为本地预览，最终分类以服务端为准\n")
        click.echo(f"  {'发件人':<8} │ {'主题':<30} │ {'附件':<6}")
        click.echo("  ─────────┼─────────────────────────────────┼────────")
        for item in items:
            click.echo(f"  {item['sender_name']:<8} │ {item['subject']:<30} │ {len(item.get('attachments', []))}")
        if dry_run:
            _eprint(f"\n  Preview: {len(items)} items ready. Remove --dry-run to push.")
        else:
            _eprint("No matching emails to push.")
        return

    result = api.ingest(source="feishu_api", items=items)

    if as_json:
        click.echo(json.dumps(result, ensure_ascii=False))
        return

    _eprint(f"  Queued: {result['queued']}, Skipped: {result['skipped']}")
    if result.get("errors"):
        _eprint(f"  Errors: {len(result['errors'])}")
    _eprint(f"  Total: {len(items)}")
    _eprint("  Data is now in the pending queue. Confirm via API or studio.")


@mail.command(name="send")
@click.option("--loop", is_flag=True, help="Run in continuous polling loop")
@click.option("-i", "--interval", default=30, show_default=True, help="Polling interval in seconds (--loop only)")
def mail_send(loop: bool, interval: int) -> None:
    cfg = _get_cfg()
    api = _get_api(cfg)
    lark = _get_lark(cfg)

    if loop:
        _eprint(f"Mail sender loop started (interval={interval}s)")
        while True:
            try:
                sent = send_pending(api, lark)
                if sent:
                    _eprint(f"Sent {sent} messages this cycle")
            except Exception as exc:
                _eprint(f"Send cycle failed: {exc}")
            time.sleep(interval)

    sent = send_pending(api, lark)
    _eprint(f"Sent {sent} messages")


class StatusGroup(click.MultiCommand):
    def list_commands(self, ctx: click.Context) -> list[str]:
        return ["pending", "last-ingest"]

    def get_command(self, ctx: click.Context, name: str) -> click.Command | None:
        if name == "pending":
            return _status_pending
        if name == "last-ingest":
            return _status_last_ingest
        return None


@click.command(name="pending", help="Show pending queue counts")
@click.option("--json", "as_json", is_flag=True, help="Output as JSON")
def _status_pending(as_json: bool) -> None:
    cfg = _get_cfg()
    api = _get_api(cfg)
    stats = api.get_queue_stats()

    if as_json:
        click.echo(json.dumps(stats, ensure_ascii=False))
        return

    _eprint(f"  Pending:   {stats.get('pending', 0)}")
    _eprint(f"  Confirmed: {stats.get('confirmed', 0)}")
    _eprint(f"  Ignored:   {stats.get('ignored', 0)}")


@click.command(name="last-ingest", help="Show last ingest result")
def _status_last_ingest() -> None:
    _eprint("Not yet implemented. Requires server-side batch tracking.")
    sys.exit(1)


human.add_command(StatusGroup(name="status", help="Check server status."))


def main() -> None:
    cli()


if __name__ == "__main__":
    main()
