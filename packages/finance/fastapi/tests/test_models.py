from datetime import date, datetime

import pytest
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError

from fastapi_quanttide_finance.database import Base
from fastapi_quanttide_finance.models.source_record import SourceRecord
from fastapi_quanttide_finance.models.normalized_record import (
    NormalizedRecord,
)
from fastapi_quanttide_finance.models.record_link import RecordLink
from fastapi_quanttide_finance.models.classification_result import (
    ClassificationResult,
)


class TestSourceRecordModel:
    def test_create_and_read(self, db_session):
        record = SourceRecord(
            source_type="csv_row",
            raw_text="test,data,123",
        )
        db_session.add(record)
        db_session.commit()

        fetched = db_session.get(SourceRecord, record.id)
        assert fetched is not None
        assert fetched.source_type == "csv_row"
        assert fetched.ingestion_status == "pending"

    def test_default_ingestion_status(self, db_session):
        record = SourceRecord(source_type="manual")
        db_session.add(record)
        db_session.commit()

        assert record.ingestion_status == "pending"

    def test_timestamps_set_on_create(self, db_session):
        record = SourceRecord(source_type="csv_row")
        db_session.add(record)
        db_session.commit()

        assert record.created_at is not None
        assert record.updated_at is not None


class TestNormalizedRecordModel:
    def test_create_and_read(self, db_session):
        record = NormalizedRecord(
            record_type="expense",
            business_date=date(2026, 6, 1),
            amount_cents=120000,
            direction="outflow",
        )
        db_session.add(record)
        db_session.commit()

        fetched = db_session.get(NormalizedRecord, record.id)
        assert fetched is not None
        assert fetched.amount_cents == 120000
        assert fetched.currency == "CNY"
        assert fetched.normalization_status == "draft"

    def test_default_currency_and_status(self, db_session):
        record = NormalizedRecord(
            record_type="income",
            business_date=date(2026, 6, 1),
            amount_cents=50000,
            direction="inflow",
        )
        db_session.add(record)
        db_session.commit()

        assert record.currency == "CNY"
        assert record.normalization_status == "draft"


class TestRecordLinkModel:
    def test_create_and_read(self, db_session):
        sr = SourceRecord(source_type="csv_row")
        nr = NormalizedRecord(
            record_type="expense",
            business_date=date(2026, 6, 1),
            amount_cents=120000,
            direction="outflow",
        )
        db_session.add_all([sr, nr])
        db_session.commit()

        link = RecordLink(
            source_record_id=sr.id,
            normalized_record_id=nr.id,
            relation_type="primary",
        )
        db_session.add(link)
        db_session.commit()

        fetched = db_session.get(RecordLink, link.id)
        assert fetched is not None
        assert fetched.relation_type == "primary"

    def test_fk_violation_on_invalid_source(self, db_session):
        link = RecordLink(
            source_record_id=99999,
            normalized_record_id=99999,
            relation_type="primary",
        )
        db_session.add(link)
        with pytest.raises(IntegrityError):
            db_session.commit()
        db_session.rollback()


class TestClassificationResultModel:
    def test_create_and_read(self, db_session):
        sr = SourceRecord(source_type="csv_row")
        nr = NormalizedRecord(
            record_type="expense",
            business_date=date(2026, 6, 1),
            amount_cents=120000,
            direction="outflow",
        )
        db_session.add_all([sr, nr])
        db_session.commit()

        cr = ClassificationResult(
            normalized_record_id=nr.id,
            taxonomy="expense_type",
            category="办公用品",
            classifier_kind="manual",
        )
        db_session.add(cr)
        db_session.commit()

        fetched = db_session.get(ClassificationResult, cr.id)
        assert fetched is not None
        assert fetched.review_status == "candidate"
        assert fetched.is_active is True

    def test_default_review_status_and_is_active(self, db_session):
        sr = SourceRecord(source_type="csv_row")
        nr = NormalizedRecord(
            record_type="expense",
            business_date=date(2026, 6, 1),
            amount_cents=120000,
            direction="outflow",
        )
        db_session.add_all([sr, nr])
        db_session.commit()

        cr = ClassificationResult(
            normalized_record_id=nr.id,
            taxonomy="expense_type",
            category="差旅",
            classifier_kind="rule",
        )
        db_session.add(cr)
        db_session.commit()

        assert cr.review_status == "candidate"
        assert cr.is_active is True
