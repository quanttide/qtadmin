"""Tests for the api_client module."""

from unittest.mock import MagicMock

from qtadmin.api_client import ApiClient


def test_ingest_queued():
    """ingest returns queued count from server response."""
    mock_httpx = MagicMock()
    mock_httpx.post.return_value.status_code = 201
    mock_httpx.post.return_value.json.return_value = {
        "queued": 3, "skipped": 1, "errors": [],
        "items": [
            {"message_id": "m1", "action": "queued", "queue_id": 1},
            {"message_id": "m2", "action": "queued", "queue_id": 2},
            {"message_id": "m3", "action": "queued", "queue_id": 3},
            {"message_id": "m4", "action": "skipped"},
        ],
    }
    client = ApiClient(base_url="http://test:8000", httpx_client=mock_httpx)
    result = client.ingest(source="feishu_api", items=[{"message_id": "m1", "subject": "S", "sender_email": "a@b.com"}])
    assert result["queued"] == 3
    assert result["skipped"] == 1


def test_ingest_posts_correct_url():
    """ingest posts to correct endpoint."""
    mock_httpx = MagicMock()
    mock_httpx.post.return_value.status_code = 201
    mock_httpx.post.return_value.json.return_value = {"queued": 0, "skipped": 0, "errors": [], "items": []}
    client = ApiClient(base_url="http://server:8000", httpx_client=mock_httpx)
    client.ingest(source="feishu_api", items=[])
    mock_httpx.post.assert_called_once()
    args, _ = mock_httpx.post.call_args
    assert args[0] == "http://server:8000/ingest"


def test_ingest_constructs_body():
    """ingest constructs correct JSON body."""
    mock_httpx = MagicMock()
    mock_httpx.post.return_value.status_code = 201
    mock_httpx.post.return_value.json.return_value = {"queued": 1, "skipped": 0, "errors": [], "items": []}
    client = ApiClient(base_url="http://test:8000", httpx_client=mock_httpx)
    items = [{"message_id": "m1", "subject": "应聘-前端", "sender_email": "a@b.com", "suggested_status": "contacted", "confidence": "high"}]
    client.ingest(source="feishu_api", items=items)
    _, kwargs = mock_httpx.post.call_args
    body = kwargs["json"]
    assert body["source"] == "feishu_api"
    assert len(body["items"]) == 1
    assert body["items"][0]["message_id"] == "m1"


def test_ingest_server_error():
    """ingest raises on non-201 response."""
    mock_httpx = MagicMock()
    mock_httpx.post.return_value.status_code = 500
    mock_httpx.post.return_value.text = "Internal Server Error"
    client = ApiClient(base_url="http://test:8000", httpx_client=mock_httpx)
    try:
        client.ingest(source="feishu_api", items=[])
        assert False, "Should have raised"
    except RuntimeError as e:
        assert "500" in str(e)


def test_get_queue_stats():
    """get_queue_stats returns parsed stats."""
    mock_httpx = MagicMock()
    mock_httpx.get.return_value.status_code = 200
    mock_httpx.get.return_value.json.return_value = {"pending": 5, "confirmed": 3, "ignored": 1}
    client = ApiClient(base_url="http://test:8000", httpx_client=mock_httpx)
    stats = client.get_queue_stats()
    assert stats["pending"] == 5
    assert stats["confirmed"] == 3
    assert stats["ignored"] == 1
