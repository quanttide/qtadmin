"""Tests for M4 Statistics API — summary, breakdown, trend, drilldown."""


def _create_nr(client, raw_text=None):
    """Helper: create source record + normalize, return normalized_record_id."""
    if raw_text is None:
        raw_text = "date,description,amount_cents,direction\n2026-06-01,测试,1000,outflow"
    resp = client.post("/source-records", json={"source_type": "csv_row", "raw_text": raw_text})
    record_id = resp.json()["id"]
    norm_resp = client.post(f"/source-records/{record_id}/normalize")
    return norm_resp.json()[0]["id"]


def _create_classification(client, nr_id, category="办公用品"):
    """Helper: create classification (returns response)."""
    return client.post(
        f"/normalized-records/{nr_id}/classifications",
        json={"category": category, "classifier_kind": "manual"},
    )


def _create_accepted_classification(client, nr_id, category="办公用品"):
    """Helper: create + accept a classification."""
    resp = _create_classification(client, nr_id, category)
    cls_id = resp.json()["id"]
    client.patch(f"/classifications/{cls_id}", json={"review_status": "accepted"})


# ─── GET /statistics/summary ──────────────────────────────────────────────────


class TestSummary:
    def test_empty_db(self, client):
        response = client.get("/statistics/summary")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 0
        assert data["amount_cents"] == 0
        assert data["classified_count"] == 0
        assert "filters" in data

    def test_basic_summary(self, client):
        _create_nr(client)
        _create_nr(client, raw_text="date,description,amount_cents,direction\n2026-06-02,测试2,2000,outflow")
        response = client.get("/statistics/summary")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 2
        assert data["amount_cents"] == 3000
        assert data["classified_count"] == 0

    def test_classified_count(self, client):
        nr_id = _create_nr(client)
        _create_accepted_classification(client, nr_id)
        response = client.get("/statistics/summary")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 1
        assert data["classified_count"] == 1

    def test_classified_count_deduplicates_exist(self, client):
        """Multiple accepted classifications on same record -> count=1 (EXISTS dedup)."""
        nr_id = _create_nr(client)
        _create_accepted_classification(client, nr_id, "办公用品")
        _create_accepted_classification(client, nr_id, "差旅")
        response = client.get("/statistics/summary")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 1
        assert data["classified_count"] == 1

    def test_currency_star_returns_null_amount(self, client):
        _create_nr(client)
        response = client.get("/statistics/summary?currency=*")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 1
        assert data["amount_cents"] is None
        assert data["classified_count"] == 0

    def test_currency_cny_returns_amount(self, client):
        _create_nr(client)
        response = client.get("/statistics/summary?currency=CNY")
        assert response.status_code == 200
        data = response.json()
        assert data["amount_cents"] == 1000

    def test_taxonomy_category_filter_matches(self, client):
        nr_id = _create_nr(client)
        _create_accepted_classification(client, nr_id, "办公用品")
        response = client.get(
            "/statistics/summary?taxonomy=expense_type&category=%E5%8A%9E%E5%85%AC%E7%94%A8%E5%93%81"
        )
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 1

    def test_taxonomy_category_filter_no_match(self, client):
        nr_id = _create_nr(client)
        _create_accepted_classification(client, nr_id, "办公用品")
        response = client.get(
            "/statistics/summary?taxonomy=expense_type&category=%E5%B7%AE%E6%97%85"
        )
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 0

    def test_taxonomy_without_category_returns_422(self, client):
        response = client.get("/statistics/summary?taxonomy=expense_type")
        assert response.status_code == 422

    def test_category_without_taxonomy_returns_422(self, client):
        response = client.get("/statistics/summary?category=%E5%8A%9E%E5%85%AC%E7%94%A8%E5%93%81")
        assert response.status_code == 422

    def test_from_date_gt_to_date_returns_422(self, client):
        response = client.get(
            "/statistics/summary?from_date=2026-06-10&to_date=2026-06-01"
        )
        assert response.status_code == 422

    def test_invalid_record_type_returns_422(self, client):
        response = client.get("/statistics/summary?record_type=invalid")
        assert response.status_code == 422

    def test_invalid_currency_returns_422(self, client):
        response = client.get("/statistics/summary?currency=INVALID")
        assert response.status_code == 422

    def test_invalid_direction_returns_422(self, client):
        response = client.get("/statistics/summary?direction=nowhere")
        assert response.status_code == 422

    def test_department_filter(self, client):
        csv = "date,description,amount_cents,direction,department\n2026-06-01,研发支出,5000,outflow,研发部"
        _create_nr(client, csv)
        csv2 = "date,description,amount_cents,direction,department\n2026-06-01,市场费用,3000,outflow,市场部"
        _create_nr(client, csv2)
        response = client.get("/statistics/summary?department=%E7%A0%94%E5%8F%91%E9%83%A8")
        assert response.status_code == 200
        data = response.json()
        assert data["record_count"] == 1
        assert data["amount_cents"] == 5000


#  GET /statistics/breakdown


class TestBreakdown:
    def test_by_department(self, client):
        csv_rnd = "date,description,amount_cents,direction,department\n2026-06-01,研发,5000,outflow,研发部"
        csv_mkt = "date,description,amount_cents,direction,department\n2026-06-01,市场,3000,outflow,市场部"
        _create_nr(client, csv_rnd)
        _create_nr(client, csv_mkt)
        response = client.get("/statistics/breakdown?dimension=department")
        assert response.status_code == 200
        data = response.json()
        assert data["dimension"] == "department"
        assert len(data["rows"]) == 2
        keys = {r["key"] for r in data["rows"]}
        assert keys == {"研发部", "市场部"}

    def test_by_record_type(self, client):
        _create_nr(client)
        response = client.get("/statistics/breakdown?dimension=record_type")
        assert response.status_code == 200
        data = response.json()
        assert data["dimension"] == "record_type"
        assert len(data["rows"]) >= 1

    def test_null_dimension(self, client):
        """Department is NULL -> grouped as null key."""
        csv = "date,description,amount_cents,direction\n2026-06-01,无部门,1000,outflow"
        _create_nr(client, csv)
        response = client.get("/statistics/breakdown?dimension=department")
        assert response.status_code == 200
        data = response.json()
        null_rows = [r for r in data["rows"] if r["key"] is None]
        assert len(null_rows) >= 1

    def test_invalid_dimension_returns_422_with_allowed_list(self, client):
        response = client.get("/statistics/breakdown?dimension=invalid")
        assert response.status_code == 422
        body = response.json()
        assert "department" in body["detail"]

    def test_missing_dimension_returns_422(self, client):
        response = client.get("/statistics/breakdown")
        assert response.status_code == 422

    def test_currency_star_returns_null_amount(self, client):
        _create_nr(client)
        response = client.get("/statistics/breakdown?dimension=record_type&currency=*")
        assert response.status_code == 200
        data = response.json()
        assert data["dimension"] == "record_type"
        for row in data["rows"]:
            assert row["amount_cents"] is None


#  GET /statistics/trend


class TestTrend:
    def test_by_day(self, client):
        _create_nr(client)
        response = client.get("/statistics/trend?granularity=day")
        assert response.status_code == 200
        data = response.json()
        assert data["granularity"] == "day"
        assert len(data["rows"]) >= 1
        assert data["rows"][0]["date"] == "2026-06-01"
        assert data["rows"][0]["count"] == 1

    def test_by_month(self, client):
        _create_nr(client)
        response = client.get("/statistics/trend?granularity=month")
        assert response.status_code == 200
        data = response.json()
        assert data["granularity"] == "month"
        assert data["rows"][0]["date"] == "2026-06"
        assert data["rows"][0]["count"] == 1

    def test_invalid_granularity_returns_422(self, client):
        response = client.get("/statistics/trend?granularity=year")
        assert response.status_code == 422

    def test_default_granularity_is_day(self, client):
        _create_nr(client)
        response = client.get("/statistics/trend")
        assert response.status_code == 200
        data = response.json()
        assert data["granularity"] == "day"

    def test_currency_star_returns_null_amount(self, client):
        _create_nr(client)
        response = client.get("/statistics/trend?granularity=day&currency=*")
        assert response.status_code == 200
        data = response.json()
        for row in data["rows"]:
            assert row["amount_cents"] is None

    def test_no_empty_periods(self, client):
        """Periods with no data don't appear."""
        response = client.get("/statistics/trend?granularity=month")
        assert response.status_code == 200
        data = response.json()
        assert len(data["rows"]) == 0


#  GET /statistics/drilldown


class TestDrilldown:
    def test_basic_pagination(self, client):
        _create_nr(client)
        response = client.get("/statistics/drilldown")
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 1
        assert data["total"] == 1
        assert "id" in data["items"][0]
        assert "record_type" in data["items"][0]

    def test_items_use_normalized_record_response_schema(self, client):
        """Items should contain NormalizedRecordResponse fields."""
        _create_nr(client)
        response = client.get("/statistics/drilldown")
        data = response.json()
        item = data["items"][0]
        assert "id" in item
        assert "record_type" in item
        assert "business_date" in item
        assert "amount_cents" in item
        assert "direction" in item
        assert "created_at" in item

    def test_total_matches_record_count(self, client):
        _create_nr(client)
        _create_nr(client)
        response = client.get("/statistics/drilldown")
        data = response.json()
        assert data["total"] == 2
        assert len(data["items"]) == 2

    def test_skip_limit(self, client):
        _create_nr(client)
        _create_nr(client)
        _create_nr(client)
        response = client.get("/statistics/drilldown?skip=1&limit=1")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 3
        assert len(data["items"]) == 1
        assert data["skip"] == 1
        assert data["limit"] == 1

    def test_limit_exceeds_max_returns_422(self, client):
        response = client.get("/statistics/drilldown?limit=201")
        assert response.status_code == 422

    def test_limit_200_is_ok(self, client):
        response = client.get("/statistics/drilldown?limit=200")
        assert response.status_code == 200

    def test_skip_beyond_total(self, client):
        _create_nr(client)
        response = client.get("/statistics/drilldown?skip=100")
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
        assert data["total"] == 1

    def test_empty_db(self, client):
        response = client.get("/statistics/drilldown")
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
        assert data["total"] == 0

    def test_department_filter(self, client):
        csv = "date,description,amount_cents,direction,department\n2026-06-01,研发支出,5000,outflow,研发部"
        _create_nr(client, csv)
        csv2 = "date,description,amount_cents,direction,department\n2026-06-01,市场费用,3000,outflow,市场部"
        _create_nr(client, csv2)
        response = client.get("/statistics/drilldown?department=%E7%A0%94%E5%8F%91%E9%83%A8")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["amount_cents"] == 5000
