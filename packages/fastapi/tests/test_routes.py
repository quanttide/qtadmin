"""Integration tests for M2 routes."""
import pytest


class TestListSourceRecords:
    def test_list_empty(self, client):
        response = client.get("/source-records")
        assert response.status_code == 200
        assert response.json() == []

    def test_list_with_records(self, client):
        client.post("/source-records", json={"source_type": "csv_row", "raw_text": "a"})
        client.post("/source-records", json={"source_type": "manual", "raw_text": "b"})
        response = client.get("/source-records")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2


class TestGetSourceRecord:
    def test_get_existing(self, client):
        create_resp = client.post(
            "/source-records", json={"source_type": "csv_row", "raw_text": "test"}
        )
        record_id = create_resp.json()["id"]
        response = client.get(f"/source-records/{record_id}")
        assert response.status_code == 200
        assert response.json()["id"] == record_id

    def test_get_nonexistent(self, client):
        response = client.get("/source-records/99999")
        assert response.status_code == 404


class TestListNormalizedRecords:
    def test_list_empty(self, client):
        response = client.get("/normalized-records")
        assert response.status_code == 200
        assert response.json() == []

    def test_list_after_normalize(self, client):
        create_resp = client.post(
            "/source-records",
            json={
                "source_type": "csv_row",
                "raw_text": "date,description,amount_cents,direction\n2026-06-01,测试,1000,outflow",
            },
        )
        record_id = create_resp.json()["id"]
        client.post(f"/source-records/{record_id}/normalize")
        response = client.get("/normalized-records")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["description"] == "测试"

    def test_list_filter_by_source(self, client):
        create_resp = client.post(
            "/source-records",
            json={
                "source_type": "csv_row",
                "raw_text": "date,description,amount_cents,direction\n2026-06-01,filter test,1000,outflow",
            },
        )
        record_id = create_resp.json()["id"]
        client.post(f"/source-records/{record_id}/normalize")
        response = client.get(f"/normalized-records?source_record_id={record_id}")
        assert response.status_code == 200
        assert len(response.json()) >= 1


class TestGetNormalizedRecord:
    def test_get_existing(self, client):
        create_resp = client.post(
            "/source-records",
            json={
                "source_type": "csv_row",
                "raw_text": "date,description,amount_cents,direction\n2026-06-01,get测试,1000,outflow",
            },
        )
        record_id = create_resp.json()["id"]
        norm_resp = client.post(f"/source-records/{record_id}/normalize")
        norm_id = norm_resp.json()[0]["id"]
        response = client.get(f"/normalized-records/{norm_id}")
        assert response.status_code == 200
        assert response.json()["description"] == "get测试"

    def test_get_nonexistent(self, client):
        response = client.get("/normalized-records/99999")
        assert response.status_code == 404


class TestCreateSourceRecord:
    def test_creates_source_record(self, client):
        response = client.post(
            "/source-records",
            json={"source_type": "csv_row", "raw_text": "a,b\n1,2"},
        )
        assert response.status_code == 201
        data = response.json()
        assert data["source_type"] == "csv_row"
        assert data["id"] is not None

    def test_rejects_invalid_source_type(self, client):
        response = client.post(
            "/source-records",
            json={"source_type": "invalid_type"},
        )
        assert response.status_code == 422


class TestNormalizeSourceRecord:
    def test_normalize_csv_row(self, client):
        create_resp = client.post(
            "/source-records",
            json={
                "source_type": "csv_row",
                "raw_text": (
                    "date,description,amount_cents,direction\n"
                    "2026-06-01,办公用品,120000,outflow"
                ),
            },
        )
        record_id = create_resp.json()["id"]

        response = client.post(f"/source-records/{record_id}/normalize")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["description"] == "办公用品"
        assert data[0]["amount_cents"] == 120000
        assert data[0]["direction"] == "outflow"

    def test_normalize_manual(self, client):
        create_resp = client.post(
            "/source-records",
            json={
                "source_type": "manual",
                "raw_text": "购买办公用品A4纸",
            },
        )
        record_id = create_resp.json()["id"]

        response = client.post(f"/source-records/{record_id}/normalize")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["description"] == "购买办公用品A4纸"
        assert data[0]["record_type"] == "other"
        assert data[0]["normalization_status"] == "draft"

    def test_normalize_nonexistent_record(self, client):
        response = client.post("/source-records/99999/normalize")
        assert response.status_code == 404

    def test_normalize_unsupported_type(self, client):
        create_resp = client.post(
            "/source-records",
            json={"source_type": "image", "raw_text": "some image text"},
        )
        record_id = create_resp.json()["id"]

        response = client.post(f"/source-records/{record_id}/normalize")
        assert response.status_code == 400
        assert "No Normalizer" in response.json()["detail"]
