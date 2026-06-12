"""HTTP client for qtadmin provider API."""

from collections.abc import Callable

import httpx


class ApiClient:
    """Client for communicating with the qtadmin provider (FastAPI) server."""

    def __init__(
        self,
        base_url: str = "http://127.0.0.1:8000",
        httpx_client: Callable | None = None,
    ) -> None:
        self._base_url = base_url.rstrip("/")
        self._httpx = httpx_client or httpx

    # ── Ingest ──

    def ingest(self, source: str, items: list[dict]) -> dict:
        """POST /ingest — push raw email data to pending queue.

        Each item supports fields:
            message_id, subject, sender_name, sender_email, recipient_email,
            body, body_text, attachments, extracted_name, extracted_email, extracted_phone,
            suggested_status, confidence, suggested_recruitment_title
        """
        body = {"source": source, "items": items}
        r = self._httpx.post(f"{self._base_url}/ingest", json=body)
        if r.status_code != 201:
            raise RuntimeError(f"Ingest failed (HTTP {r.status_code}): {r.text}")
        return r.json()

    # ── Queue stats ──

    def get_queue_stats(self) -> dict[str, int]:
        """GET /queue/stats — get pending/confirmed/ignored counts."""
        r = self._httpx.get(f"{self._base_url}/queue/stats")
        if r.status_code != 200:
            raise RuntimeError(f"Queue stats failed (HTTP {r.status_code}): {r.text}")
        return r.json()

    # ── Outbox / Send ──

    def claim_outbox(self) -> list[dict]:
        """POST /messages/outbox/claim — claim pending outbound messages.

        Returns list of {id, lease_id, subject, recipient_email}.
        """
        r = self._httpx.post(f"{self._base_url}/messages/outbox/claim")
        if r.status_code != 200:
            raise RuntimeError(f"Claim failed (HTTP {r.status_code}): {r.text}")
        data = r.json()
        return data.get("claimed", [])

    def get_outbox_message(self, message_id: int, lease_id: str) -> dict:
        """GET /messages/outbox/{id}?lease_id=... — get full message detail."""
        r = self._httpx.get(
            f"{self._base_url}/messages/outbox/{message_id}",
            params={"lease_id": lease_id},
        )
        if r.status_code != 200:
            raise RuntimeError(f"Get message failed (HTTP {r.status_code}): {r.text}")
        return r.json()

    def update_send_status(self, message_id: int, lease_id: str, send_status: str, **extra) -> dict:
        """PATCH /messages/{id}/send-status — update send result.

        Extra kwargs (platform_message_id, sent_at, failure_reason) are forwarded.
        """
        payload = {"lease_id": lease_id, "send_status": send_status}
        payload.update(extra)
        r = self._httpx.patch(f"{self._base_url}/messages/{message_id}/send-status", json=payload)
        if r.status_code not in (200, 409):
            raise RuntimeError(f"Update send status failed (HTTP {r.status_code}): {r.text}")
        return r.json()
