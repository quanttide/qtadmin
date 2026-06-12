import re

from dataclasses import dataclass, field


@dataclass
class ParseResult:
    name: str | None = None
    phone: str | None = None
    email: str | None = None
    education: list[dict] = field(default_factory=list)
    experience: list[dict] = field(default_factory=list)
    raw_text: str | None = None


class ResumeParser:
    """Interface for resume parsing. Override `parse` to implement actual parsing."""

    def parse(self, file_path: str) -> ParseResult:
        raise NotImplementedError


class NoopResumeParser(ResumeParser):
    """Placeholder parser that returns an empty result."""

    def parse(self, file_path: str) -> ParseResult:
        return ParseResult()


class PdfPlumberResumeParser(ResumeParser):
    """PDF resume parser using pdfplumber.

    Extracts text from text-based PDFs and applies regex patterns to
    extract structured fields (name, phone, email, education, experience).
    """

    _PHONE_RE = re.compile(r"1[3-9]\d{9}")
    _EMAIL_RE = re.compile(r"[\w.+-]+@[\w-]+\.[\w.]+")
    _NAME_RE = re.compile(r"姓名[：:]\s*(\S+)")
    _EDU_KEYWORDS = ("大学", "学院", "本科", "硕士", "博士", "毕业", "专业", "学位")
    _EXP_KEYWORDS = ("公司", "任职", "担任", "工作经历", "工作")

    def parse(self, file_path: str) -> ParseResult:
        try:
            import pdfplumber

            with pdfplumber.open(file_path) as pdf:
                raw_text = "\n".join(
                    page.extract_text() or "" for page in pdf.pages
                )
        except Exception as exc:
            import logging

            logging.warning("PdfPlumberResumeParser: failed to parse %s: %s", file_path, exc)
            return ParseResult(raw_text=None)

        if not raw_text.strip():
            return ParseResult(raw_text=None)

        name = self._extract_name(raw_text)
        phone = self._extract_phone(raw_text)
        email = self._extract_email(raw_text)
        education = self._extract_education(raw_text)
        experience = self._extract_experience(raw_text)

        return ParseResult(
            name=name,
            phone=phone,
            email=email,
            education=education,
            experience=experience,
            raw_text=raw_text,
        )

    def _extract_name(self, text: str) -> str | None:
        m = self._NAME_RE.search(text)
        if m:
            return m.group(1)
        return None

    def _extract_phone(self, text: str) -> str | None:
        m = self._PHONE_RE.search(text)
        return m.group(0) if m else None

    def _extract_email(self, text: str) -> str | None:
        m = self._EMAIL_RE.search(text)
        return m.group(0) if m else None

    def _extract_education(self, text: str) -> list[dict]:
        lines = text.split("\n")
        items = []
        for line in lines:
            line = line.strip()
            if any(kw in line for kw in self._EDU_KEYWORDS):
                items.append({"raw": line})
        return items

    def _extract_experience(self, text: str) -> list[dict]:
        lines = text.split("\n")
        items = []
        for line in lines:
            line = line.strip()
            if any(kw in line for kw in self._EXP_KEYWORDS):
                items.append({"raw": line})
        return items
