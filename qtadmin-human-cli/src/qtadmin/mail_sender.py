"""Send pending outbox messages via lark-cli."""

import logging
import subprocess

from qtadmin.api_client import ApiClient
from qtadmin.lark_client import LarkClient

logger = logging.getLogger(__name__)


def send_pending(api: ApiClient, lark: LarkClient) -> int:
    """Claim and send pending outbox messages.

    Returns the number of messages successfully sent.
    """
    claimed = api.claim_outbox()
    if not claimed:
        logger.info("No pending messages to send.")
        return 0

    sent_count = 0
    for msg in claimed:
        mid = msg["id"]
        lease_id = msg["lease_id"]
        recipient = msg.get("recipient_email", "")

        if not recipient:
            logger.warning("Message %d has no recipient_email, skipping", mid)
            continue

        detail = api.get_outbox_message(mid, lease_id)
        body = detail.get("body_text") or detail.get("body") or ""

        try:
            logger.info("Sending message %d to %s: %s", mid, recipient, msg.get("subject", ""))
            lark_resp = lark.send_email(recipient, msg.get("subject", ""), body)

            platform_id = ""
            if isinstance(lark_resp, dict):
                platform_id = lark_resp.get("data", {}).get("id", "")
            if not platform_id:
                platform_id = lark_resp.get("id", str(lark_resp))

            result = api.update_send_status(
                mid, lease_id, "sent",
                platform_message_id=platform_id,
                sent_at=None,
            )
            if isinstance(result, dict) and result.get("ok"):
                sent_count += 1
                logger.info("Message %d sent successfully (platform_id=%s)", mid, platform_id)

        except subprocess.CalledProcessError as e:
            err_msg = e.stderr or str(e)
            logger.error("lark-cli failed for message %d: %s", mid, err_msg)
            api.update_send_status(mid, lease_id, "failed", failure_reason=err_msg[:500])

        except Exception as e:
            logger.error("Unexpected error for message %d: %s", mid, str(e))
            api.update_send_status(mid, lease_id, "failed", failure_reason=str(e)[:500])

    return sent_count
