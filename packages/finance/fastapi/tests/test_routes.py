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


def _create_normalized_record(client):
    """Helper to create a normalized record via the normalize flow."""
    create_resp = client.post(
        "/source-records",
        json={"source_type": "manual", "raw_text": "办公用品采购"},
    )
    record_id = create_resp.json()["id"]
    norm_resp = client.post(f"/source-records/{record_id}/normalize")
    return norm_resp.json()[0]["id"]


def _create_classification(client, normalized_record_id, category="办公用品", **extra):
    """Helper to create a classification."""
    body = {"category": category, "classifier_kind": "manual", **extra}
    return client.post(
        f"/normalized-records/{normalized_record_id}/classifications",
        json=body,
    )


class TestCreateClassification:
    def test_create_candidate(self, client):
        nr_id = _create_normalized_record(client)
        response = _create_classification(client, nr_id)
        assert response.status_code == 201
        data = response.json()
        assert data["review_status"] == "candidate"
        assert data["is_active"] is True
        assert data["category"] == "办公用品"

    def test_create_invalid_category(self, client):
        nr_id = _create_normalized_record(client)
        response = _create_classification(client, nr_id, category="无效类别")
        assert response.status_code == 400

    def test_create_nonexistent_normalized_record(self, client):
        response = _create_classification(client, normalized_record_id=99999)
        assert response.status_code == 404

    def test_create_rejects_extra_fields_in_body(self, client):
        nr_id = _create_normalized_record(client)
        response = client.post(
            f"/normalized-records/{nr_id}/classifications",
            json={
                "category": "办公用品",
                "classifier_kind": "manual",
                "normalized_record_id": 999,
            },
        )
        assert response.status_code == 422


class TestListClassifications:
    def test_list_after_create(self, client):
        nr_id = _create_normalized_record(client)
        _create_classification(client, nr_id)
        response = client.get(f"/normalized-records/{nr_id}/classifications")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["category"] == "办公用品"

    def test_list_empty(self, client):
        nr_id = _create_normalized_record(client)
        response = client.get(f"/normalized-records/{nr_id}/classifications")
        assert response.status_code == 200
        assert response.json() == []

    def test_list_filter_by_review_status(self, client):
        nr_id = _create_normalized_record(client)
        resp_a = _create_classification(client, nr_id, category="办公用品")
        cls_a_id = resp_a.json()["id"]
        _create_classification(client, nr_id, category="办公用品")
        # PATCH one to "accepted"
        client.patch(f"/classifications/{cls_a_id}", json={"review_status": "accepted"})
        # Filter: should return 1 accepted
        response = client.get(
            f"/normalized-records/{nr_id}/classifications?review_status=accepted"
        )
        assert response.status_code == 200
        assert len(response.json()) == 1
        assert response.json()[0]["review_status"] == "accepted"

    def test_list_filter_invalid_status_returns_422(self, client):
        nr_id = _create_normalized_record(client)
        response = client.get(
            f"/normalized-records/{nr_id}/classifications?review_status=invalid_typo"
        )
        assert response.status_code == 422

    def test_list_nonexistent_normalized_record(self, client):
        response = client.get("/normalized-records/99999/classifications")
        assert response.status_code == 404


class TestReviewClassification:
    def test_review_accept(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(
            f"/classifications/{cls_id}", json={"review_status": "accepted"}
        )
        assert response.status_code == 200
        assert response.json()["review_status"] == "accepted"

    def test_review_reject(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(
            f"/classifications/{cls_id}", json={"review_status": "rejected"}
        )
        assert response.status_code == 200
        assert response.json()["review_status"] == "rejected"

    def test_review_soft_delete(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(f"/classifications/{cls_id}", json={"is_active": False})
        assert response.status_code == 200
        assert response.json()["is_active"] is False

    def test_review_invalid_status(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(
            f"/classifications/{cls_id}", json={"review_status": "invalid"}
        )
        assert response.status_code == 422

    def test_review_category_not_accepted(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(f"/classifications/{cls_id}", json={"category": "采购"})
        assert response.status_code == 422

    def test_review_nonexistent(self, client):
        response = client.patch(
            "/classifications/99999", json={"review_status": "accepted"}
        )
        assert response.status_code == 404

    def test_review_is_active_null_rejected(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(
            f"/classifications/{cls_id}", json={"is_active": None}
        )
        assert response.status_code == 422

    def test_review_noop_empty_body(self, client):
        nr_id = _create_normalized_record(client)
        create_resp = _create_classification(client, nr_id)
        cls_id = create_resp.json()["id"]
        response = client.patch(f"/classifications/{cls_id}", json={})
        assert response.status_code == 200
        data = response.json()
        assert data["review_status"] == "candidate"
        assert data["is_active"] is True
