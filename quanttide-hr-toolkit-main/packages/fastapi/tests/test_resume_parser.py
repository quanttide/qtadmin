"""Tests for PdfPlumberResumeParser."""

from pathlib import Path

import pytest

from fastapi_quanttide_hr.services.resume_parser import (
    NoopResumeParser,
    ParseResult,
    PdfPlumberResumeParser,
    ResumeParser,
)

FIXTURES_DIR = Path(__file__).parent / "fixtures"
FIXTURE_PDF = FIXTURES_DIR / "sample-resume.pdf"


# --- PdfPlumberResumeParser ---

class TestPdfPlumberResumeParser:
    """Integration tests using the English fixture PDF + Chinese regex unit tests."""

    def test_extract_from_pdf_fixture(self):
        """pdfplumber extracts text from the fixture PDF."""
        parser = PdfPlumberResumeParser()
        result = parser.parse(str(FIXTURE_PDF))
        assert result.raw_text is not None
        assert "13800138000" in result.raw_text
        assert "zhang.san@test.com" in result.raw_text

    def test_extract_phone_from_pdf(self):
        """Phone number is extracted from English fixture."""
        parser = PdfPlumberResumeParser()
        result = parser.parse(str(FIXTURE_PDF))
        assert result.phone == "13800138000"

    def test_extract_email_from_pdf(self):
        """Email is extracted from English fixture."""
        parser = PdfPlumberResumeParser()
        result = parser.parse(str(FIXTURE_PDF))
        assert result.email == "zhang.san@test.com"

    def test_name_is_none_for_english_fixture(self):
        """Name is None for English text (parser targets Chinese 姓名: prefix)."""
        parser = PdfPlumberResumeParser()
        result = parser.parse(str(FIXTURE_PDF))
        assert result.name is None

    def test_extract_chinese_name(self):
        """Chinese 姓名: prefix is extracted."""
        parser = PdfPlumberResumeParser()
        text = "姓名：张三\n电话：13800138000"
        assert parser._extract_name(text) == "张三"

    def test_extract_chinese_education(self):
        """Education lines containing keyword 大学 are extracted."""
        parser = PdfPlumberResumeParser()
        text = "教育经历：北京大学 计算机科学"
        items = parser._extract_education(text)
        assert len(items) >= 1
        assert any("大学" in item["raw"] for item in items)

    def test_extract_chinese_experience(self):
        """Experience lines containing keyword 公司 are extracted."""
        parser = PdfPlumberResumeParser()
        text = "工作经历：ABC公司 软件工程师"
        items = parser._extract_experience(text)
        assert len(items) >= 1
        assert any("公司" in item["raw"] for item in items)

    def test_parse_returns_empty_on_missing_file(self, caplog):
        """Parser returns empty ParseResult and logs warning on missing file."""
        parser = PdfPlumberResumeParser()
        result = parser.parse("/nonexistent/file.pdf")
        assert result.name is None
        assert result.raw_text is None
        assert "failed to parse" in caplog.text

    def test_parse_empty_text_returns_empty(self):
        """Parser returns empty ParseResult when PDF has no extractable text."""
        parser = PdfPlumberResumeParser()

        header = b"%PDF-1.4\n"
        obj1 = b"1 0 obj\n<</Type/Catalog/Pages 2 0 R>>\nendobj\n"
        obj2 = b"2 0 obj\n<</Type/Pages/Kids[3 0 R]/Count 1>>\nendobj\n"
        obj3 = b"3 0 obj\n<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]>>\nendobj\n"
        xref = b"xref\n0 4\n0000000000 65535 f \n" + b"0000000009 00000 n \n" + b"0000000058 00000 n \n" + b"0000000115 00000 n \n"
        trailer = b"trailer\n<</Size 4/Root 1 0 R>>\nstartxref\n"
        trailer += str(len(header + obj1 + obj2 + obj3 + xref + trailer)).encode() + b"\n%%EOF"
        empty_pdf_bytes = header + obj1 + obj2 + obj3 + xref + trailer

        import tempfile
        with tempfile.NamedTemporaryFile(suffix=".pdf") as f:
            f.write(empty_pdf_bytes)
            f.flush()
            result = parser.parse(f.name)

        assert result.raw_text is None
        assert result.name is None


# --- NoopResumeParser (regression) ---

class TestNoopResumeParser:
    def test_returns_empty(self):
        parser = NoopResumeParser()
        result = parser.parse("/any/path.pdf")
        assert result == ParseResult()


# --- ResumeParser interface (regression) ---

class TestResumeParserInterface:
    def test_raises_not_implemented(self):
        parser = ResumeParser()
        with pytest.raises(NotImplementedError):
            parser.parse("/any/path.pdf")
