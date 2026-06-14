"""Tests for CsvRowNormalizer + ManualNormalizer (M2)."""

import pytest

from fastapi_quanttide_finance.services.normalization import (
    NormalizeInput,
    NormalizeResult,
    Normalizer,
)
from fastapi_quanttide_finance.services.normalizers import (
    CsvRowNormalizer,
    ManualNormalizer,
)


class TestCsvRowNormalizer:
    def setup_method(self):
        self.normalizer = CsvRowNormalizer()

    def test_can_handle_csv_row(self):
        assert self.normalizer.can_handle("csv_row") is True
        assert self.normalizer.can_handle("manual") is False

    def test_normalize_full_row(self):
        csv_text = (
            "date,description,amount_cents,direction,department,person,"
            "counterparty,currency,record_type\n"
            "2026-06-01,办公用品采购,120000,outflow,研发部,张三,京东,CNY,expense"
        )
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=1, raw_text=csv_text, source_type="csv_row")
        )
        assert len(result.normalized_records) == 1
        record = result.normalized_records[0]
        from datetime import date

        assert record["business_date"] == date(2026, 6, 1)
        assert record["description"] == "办公用品采购"
        assert record["amount_cents"] == 120000
        assert record["direction"] == "outflow"
        assert record["department"] == "研发部"
        assert record["person"] == "张三"
        assert record["counterparty"] == "京东"
        assert record["currency"] == "CNY"
        assert record["record_type"] == "expense"

    def test_normalize_multiple_rows(self):
        csv_text = (
            "date,description,amount_cents,direction\n"
            "2026-06-01,item1,1000,outflow\n"
            "2026-06-02,item2,2000,inflow"
        )
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=1, raw_text=csv_text, source_type="csv_row")
        )
        assert len(result.normalized_records) == 2
        assert result.normalized_records[0]["description"] == "item1"
        assert result.normalized_records[1]["description"] == "item2"

    def test_generates_links_for_each_row(self):
        csv_text = (
            "date,description,amount_cents,direction\n"
            "2026-06-01,item1,1000,outflow\n"
            "2026-06-02,item2,2000,inflow"
        )
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=1, raw_text=csv_text, source_type="csv_row")
        )
        assert len(result.links) == 2
        for link in result.links:
            assert link["source_record_id"] == 1
            assert link["relation_type"] == "primary"

    def test_uses_defaults_for_missing_fields(self):
        csv_text = (
            "date,description,amount_cents,direction\n2026-06-01,test,500,outflow"
        )
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=1, raw_text=csv_text, source_type="csv_row")
        )
        record = result.normalized_records[0]
        assert record["currency"] == "CNY"
        assert record["record_type"] == "expense"
        assert record["department"] is None
        assert record["person"] is None
        assert record["counterparty"] is None
        assert record["normalization_status"] == "draft"

    def test_rejects_empty_csv(self):
        with pytest.raises(ValueError, match="empty"):
            self.normalizer.normalize(
                NormalizeInput(source_record_id=1, raw_text="", source_type="csv_row")
            )

    def test_rejects_csv_without_header(self):
        with pytest.raises(ValueError, match="header"):
            self.normalizer.normalize(
                NormalizeInput(
                    source_record_id=1,
                    raw_text="data_only,without,header",
                    source_type="csv_row",
                )
            )


class TestManualNormalizer:
    def setup_method(self):
        self.normalizer = ManualNormalizer()

    def test_can_handle_manual(self):
        assert self.normalizer.can_handle("manual") is True
        assert self.normalizer.can_handle("csv_row") is False

    def test_normalize_sets_raw_text_as_description(self):
        result = self.normalizer.normalize(
            NormalizeInput(
                source_record_id=1,
                raw_text="购买办公用品A4纸5包",
                source_type="manual",
            )
        )
        assert len(result.normalized_records) == 1
        record = result.normalized_records[0]
        assert record["description"] == "购买办公用品A4纸5包"

    def test_normalize_sets_sensible_defaults(self):
        result = self.normalizer.normalize(
            NormalizeInput(
                source_record_id=1,
                raw_text="test manual entry",
                source_type="manual",
            )
        )
        record = result.normalized_records[0]
        assert record["record_type"] == "other"
        assert record["direction"] == "outflow"
        assert record["amount_cents"] == 0
        assert record["normalization_status"] == "draft"

    def test_generates_link(self):
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=42, raw_text="test", source_type="manual")
        )
        assert len(result.links) == 1
        link = result.links[0]
        assert link["source_record_id"] == 42
        assert link["normalized_record_id"] == 0
        assert link["relation_type"] == "primary"

    def test_handles_empty_text(self):
        result = self.normalizer.normalize(
            NormalizeInput(source_record_id=1, raw_text="", source_type="manual")
        )
        assert len(result.normalized_records) == 1
        assert result.normalized_records[0]["description"] == ""
