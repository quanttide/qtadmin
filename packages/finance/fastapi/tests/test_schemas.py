import pytest
from pydantic import ValidationError

from fastapi_quanttide_finance.schemas.source_record import (
    SourceRecordCreate,
)
from fastapi_quanttide_finance.schemas.normalized_record import (
    NormalizedRecordCreate,
)
from fastapi_quanttide_finance.schemas.record_link import RecordLinkCreate
from fastapi_quanttide_finance.schemas.classification_result import (
    ClassificationResultCreate,
    ClassificationResultUpdate,
)


class TestSourceRecordSchema:
    def test_valid_minimal(self):
        data = SourceRecordCreate(source_type="csv_row")
        assert data.source_type == "csv_row"
        assert data.ingestion_status == "pending"

    def test_valid_full(self):
        data = SourceRecordCreate(
            source_type="image",
            source_channel="upload",
            external_id="ext_001",
            raw_text="报销单图片文字",
            ingestion_status="parsed",
        )
        assert data.source_type == "image"

    def test_invalid_source_type(self):
        with pytest.raises(ValidationError):
            SourceRecordCreate(source_type="invalid_type")

    def test_invalid_ingestion_status(self):
        with pytest.raises(ValidationError):
            SourceRecordCreate(source_type="csv_row", ingestion_status="invalid_status")

    def test_raw_text_overflow_rejected(self):
        with pytest.raises(ValidationError) as excinfo:
            SourceRecordCreate(
                source_type="csv_row",
                raw_text="x" * 65536,
            )
        errors = excinfo.value.errors()
        assert any("raw_text" in str(e["loc"]) for e in errors)


class TestNormalizedRecordSchema:
    def test_valid_minimal(self):
        data = NormalizedRecordCreate(
            record_type="expense",
            business_date="2026-06-01",
            amount_cents=120000,
            direction="outflow",
        )
        assert data.amount_cents == 120000
        assert data.currency == "CNY"
        assert data.normalization_status == "draft"

    def test_amount_cents_negative_rejected(self):
        with pytest.raises(ValidationError):
            NormalizedRecordCreate(
                record_type="expense",
                business_date="2026-06-01",
                amount_cents=-1,
                direction="outflow",
            )

    def test_amount_cents_zero_allowed(self):
        data = NormalizedRecordCreate(
            record_type="expense",
            business_date="2026-06-01",
            amount_cents=0,
            direction="outflow",
        )
        assert data.amount_cents == 0

    def test_invalid_record_type(self):
        with pytest.raises(ValidationError):
            NormalizedRecordCreate(
                record_type="invalid",
                business_date="2026-06-01",
                amount_cents=100,
                direction="outflow",
            )

    def test_invalid_direction(self):
        with pytest.raises(ValidationError):
            NormalizedRecordCreate(
                record_type="expense",
                business_date="2026-06-01",
                amount_cents=100,
                direction="invalid",
            )

    def test_description_truncated_at_1000(self):
        data = NormalizedRecordCreate(
            record_type="expense",
            business_date="2026-06-01",
            amount_cents=100,
            direction="outflow",
            description="x" * 1001,
        )
        assert len(data.description) == 1000

    def test_invalid_normalization_status(self):
        with pytest.raises(ValidationError):
            NormalizedRecordCreate(
                record_type="expense",
                business_date="2026-06-01",
                amount_cents=100,
                direction="outflow",
                normalization_status="invalid",
            )


class TestRecordLinkSchema:
    def test_valid(self):
        data = RecordLinkCreate(
            source_record_id=1,
            normalized_record_id=2,
            relation_type="primary",
        )
        assert data.relation_type == "primary"

    def test_invalid_relation_type(self):
        with pytest.raises(ValidationError):
            RecordLinkCreate(
                source_record_id=1,
                normalized_record_id=2,
                relation_type="invalid",
            )


class TestClassificationResultSchema:
    def test_valid_minimal(self):
        data = ClassificationResultCreate(
            normalized_record_id=1,
            taxonomy="expense_type",
            category="办公用品",
            classifier_kind="manual",
        )
        assert data.review_status == "candidate"
        assert data.is_active is True

    def test_invalid_taxonomy(self):
        with pytest.raises(ValidationError):
            ClassificationResultCreate(
                normalized_record_id=1,
                taxonomy="invalid_taxonomy",
                category="办公用品",
                classifier_kind="manual",
            )

    def test_invalid_classifier_kind(self):
        with pytest.raises(ValidationError):
            ClassificationResultCreate(
                normalized_record_id=1,
                taxonomy="expense_type",
                category="办公用品",
                classifier_kind="invalid",
            )

    def test_invalid_review_status(self):
        with pytest.raises(ValidationError):
            ClassificationResultCreate(
                normalized_record_id=1,
                taxonomy="expense_type",
                category="办公用品",
                classifier_kind="manual",
                review_status="invalid",
            )


class TestClassificationCreateRequestSchema:
    def test_valid_minimal(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationCreateRequest,
        )

        data = ClassificationCreateRequest(
            category="办公用品",
            classifier_kind="manual",
        )
        assert data.taxonomy == "expense_type"
        assert data.category == "办公用品"

    def test_valid_full(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationCreateRequest,
        )

        data = ClassificationCreateRequest(
            taxonomy="expense_type",
            category="采购",
            tags={"project": "A001"},
            classifier_kind="ai",
            confidence=0.95,
            model_version="v1.0",
        )
        assert data.taxonomy == "expense_type"
        assert data.confidence == 0.95

    def test_invalid_taxonomy(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationCreateRequest,
        )

        with pytest.raises(ValidationError):
            ClassificationCreateRequest(
                taxonomy="business_tag",
                category="采购",
                classifier_kind="manual",
            )

    def test_invalid_classifier_kind(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationCreateRequest,
        )

        with pytest.raises(ValidationError):
            ClassificationCreateRequest(
                category="办公用品",
                classifier_kind="invalid",
            )

    def test_extra_fields_rejected(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationCreateRequest,
        )

        with pytest.raises(ValidationError):
            ClassificationCreateRequest(
                category="办公用品",
                classifier_kind="manual",
                normalized_record_id=1,
            )


class TestClassificationReviewSchema:
    def test_valid_review_status_accepted(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationReviewSchema,
        )

        data = ClassificationReviewSchema(review_status="accepted")
        assert data.review_status == "accepted"

    def test_valid_review_status_rejected(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationReviewSchema,
        )

        data = ClassificationReviewSchema(review_status="rejected")
        assert data.review_status == "rejected"

    def test_invalid_review_status(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationReviewSchema,
        )

        with pytest.raises(ValidationError):
            ClassificationReviewSchema(review_status="invalid")

    def test_empty_body_allowed(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationReviewSchema,
        )

        data = ClassificationReviewSchema()
        assert data.review_status is None
        assert data.is_active is None

    def test_extra_fields_rejected(self):
        from fastapi_quanttide_finance.schemas.classification_result import (
            ClassificationReviewSchema,
        )

        with pytest.raises(ValidationError):
            ClassificationReviewSchema(category="办公用品")


class TestClassificationResultUpdateSchema:
    def test_update_invalid_review_status(self):
        with pytest.raises(ValidationError):
            ClassificationResultUpdate(
                review_status="invalid",
            )
