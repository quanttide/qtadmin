import csv
import io
from datetime import date

from fastapi_quanttide_finance.services.normalization import (
    NormalizeInput,
    NormalizeResult,
    Normalizer,
)

CSV_COLUMN_MAP = {
    "date": "business_date",
    "description": "description",
    "amount_cents": "amount_cents",
    "direction": "direction",
    "department": "department",
    "person": "person",
    "counterparty": "counterparty",
    "currency": "currency",
    "record_type": "record_type",
}

OPTIONAL_COLUMNS = {"department", "person", "counterparty", "currency", "record_type"}
REQUIRED_COLUMNS = {"date", "description", "amount_cents", "direction"}


def _parse_value(key: str, value: str) -> date | int | str | None:
    if value == "":
        return None
    if key == "amount_cents":
        return int(value)
    if key == "date":
        parts = value.split("-")
        return date(int(parts[0]), int(parts[1]), int(parts[2]))
    return value


class CsvRowNormalizer(Normalizer):
    def can_handle(self, source_type: str) -> bool:
        return source_type == "csv_row"

    def normalize(self, input: NormalizeInput) -> NormalizeResult:
        if not input.raw_text.strip():
            raise ValueError("CSV content is empty")

        reader = csv.DictReader(io.StringIO(input.raw_text))
        if reader.fieldnames is None or not reader.fieldnames:
            raise ValueError("CSV must have a header row")

        has_expected_header = any(col in reader.fieldnames for col in CSV_COLUMN_MAP)
        if not has_expected_header:
            raise ValueError("CSV header does not contain expected columns")

        result = NormalizeResult()
        for row in reader:
            norms = {
                "record_type": "expense",
                "business_date": date.today(),
                "amount_cents": 0,
                "currency": "CNY",
                "direction": "outflow",
                "department": None,
                "person": None,
                "counterparty": None,
                "description": "",
                "normalization_status": "draft",
            }

            for csv_col, model_field in CSV_COLUMN_MAP.items():
                if csv_col in row:
                    vals = _parse_value(csv_col, row[csv_col])
                    if vals is not None:
                        norms[model_field] = vals

            result.normalized_records.append(norms)
            result.links.append(
                {
                    "source_record_id": input.source_record_id,
                    "normalized_record_id": len(result.normalized_records) - 1,
                    "relation_type": "primary",
                }
            )

        return result


class ManualNormalizer(Normalizer):
    def can_handle(self, source_type: str) -> bool:
        return source_type == "manual"

    def normalize(self, input: NormalizeInput) -> NormalizeResult:
        record = {
            "record_type": "other",
            "business_date": date.today(),
            "amount_cents": 0,
            "currency": "CNY",
            "direction": "outflow",
            "department": None,
            "person": None,
            "counterparty": None,
            "description": input.raw_text,
            "normalization_status": "draft",
        }
        result = NormalizeResult(
            normalized_records=[record],
            links=[
                {
                    "source_record_id": input.source_record_id,
                    "normalized_record_id": 0,
                    "relation_type": "primary",
                }
            ],
        )
        return result
