"""通过 POST /ingest 向服务端推送分类结果。"""

import httpx

SERVER_URL = "http://localhost:8000"


def ingest_to_server(
    items: list[dict],
    server_url: str = SERVER_URL,
    batch_id: str | None = None,
) -> dict:
    """将分类后的邮件结果推送到服务端 /ingest。

    Args:
        items: classify() 返回的分类结果列表
        server_url: 服务端地址
        batch_id: 批次标识，同 batch_id 重复请求幂等

    Returns:
        服务端返回的 IngestResponse JSON
    """
    payload = {
        "source": "feishu_api",
        "batch_id": batch_id,
        "items": [
            {
                "message_id": item["message_id"],
                "subject": item["subject"],
                "sender_name": item.get("sender_name", ""),
                "sender_email": item["sender_email"],
                "suggested_status": item.get("suggested_status"),
                "confidence": item.get("confidence", "low"),
            }
            for item in items
        ],
    }

    resp = httpx.post(f"{server_url}/ingest", json=payload, timeout=30)
    resp.raise_for_status()
    return resp.json()
