import asyncio
import json
import os
import subprocess
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from datetime import datetime, timezone

import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import Column, DateTime, String, create_engine
from sqlalchemy.orm import sessionmaker

from fastapi_quanttide_hr.database import Base, get_db as lib_get_db
from fastapi_quanttide_hr.models.recruitment import Recruitment
from fastapi_quanttide_hr.routers import ai_config, applications, candidates, messages, pipeline, pool, recruitments
from fastapi_quanttide_hr.routers import ingest, materials, queue
from fastapi_quanttide_hr.routers import export

_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
_DATA_DIR = os.environ.get("QTADMIN_DATA_DIR", os.path.join(_PROJECT_ROOT, "data"))
_SQLITE_DIR = os.path.join(_DATA_DIR, "sqlite")
_ATTACHMENT_DIR = os.path.join(_DATA_DIR, "attachments")
_MATERIALS_DIR = os.path.join(_DATA_DIR, "materials")

DB_PATH = os.path.join(_SQLITE_DIR, "hr.sqlite3")
DATABASE_URL = f"sqlite:///{DB_PATH}"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class ProcessedMail(Base):
    __tablename__ = "processed_mails"
    message_id: str = Column(String(255), primary_key=True)
    processed_at: datetime = Column(DateTime, default=lambda: datetime.now(timezone.utc))


def seed_data():
    for d in [_SQLITE_DIR, _ATTACHMENT_DIR, _MATERIALS_DIR]:
        os.makedirs(d, exist_ok=True)
    Base.metadata.create_all(bind=engine)

    # Migration: add columns for outbox retry support
    with engine.connect() as conn:
        for col_sql in [
            "ALTER TABLE mail_messages ADD COLUMN retry_count INTEGER DEFAULT 0",
            "ALTER TABLE mail_messages ADD COLUMN last_retry_at DATETIME",
        ]:
            try:
                conn.execute(__import__("sqlalchemy").text(col_sql))
            except Exception:
                pass  # column already exists
        conn.commit()

    db = SessionLocal()
    try:
        if db.query(Recruitment).count() > 0:
            return
        r = Recruitment()
        db.add(r)
        db.commit()
    finally:
        db.close()


def app_get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


_poll_task: asyncio.Task | None = None


def _download_attachment(message_id: str, attachment: dict, mailbox: str) -> str | None:
    """Download attachment via lark-cli download_url, return local path."""
    att_id = attachment.get("message_attachment_id")
    if not att_id:
        return None

    cmd = [
        "lark-cli", "mail", "user_mailbox.message.attachments", "download_url",
        "--params", json.dumps({
            "user_mailbox_id": mailbox or "me",
            "message_id": message_id,
            "attachment_ids": [att_id],
        }),
        "--format", "json",
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        result.check_returncode()
        resp = json.loads(result.stdout)
        urls = resp.get("data", {}).get("download_urls", [])
        if not urls:
            return None
        download_url = urls[0].get("download_url", "")
        if not download_url:
            return None
    except Exception:
        return None

    storage_dir = os.path.join(_ATTACHMENT_DIR, message_id)
    os.makedirs(storage_dir, exist_ok=True)
    file_path = os.path.join(storage_dir, attachment["filename"])

    try:
        r = httpx.get(download_url, timeout=60, follow_redirects=True)
        r.raise_for_status()
        with open(file_path, "wb") as f:
            f.write(r.content)
        attachment["size"] = len(r.content)

        # Convert Word documents to PDF for inline preview
        fname_lower = attachment["filename"].lower()
        if fname_lower.endswith((".doc", ".docx")):
            _convert_to_pdf(file_path, storage_dir, attachment)

        return file_path
    except Exception:
        return None


def _convert_to_pdf(file_path: str, storage_dir: str, attachment: dict) -> None:
    """Convert Word document to PDF using LibreOffice for browser preview."""
    pdf_path = os.path.join(storage_dir, os.path.splitext(attachment["filename"])[0] + ".pdf")
    if os.path.isfile(pdf_path):
        attachment["preview_path"] = pdf_path
        return
    try:
        subprocess.run(
            ["libreoffice", "--headless", "--convert-to", "pdf", "--outdir", storage_dir, file_path],
            capture_output=True, text=True, timeout=60,
        )
        if os.path.isfile(pdf_path):
            attachment["preview_path"] = pdf_path
    except Exception:
        pass


async def _poll_mailbox():
    mailbox = os.environ.get("QTADMIN_MAILBOX", "")
    if not mailbox:
        return
    while True:
        try:
            items = await asyncio.to_thread(_fetch_mail, mailbox)
            db = SessionLocal()
            try:
                known = {row[0] for row in db.query(ProcessedMail.message_id).all()}
                new_items = [it for it in items if it["message_id"] not in known]
                for item in new_items:
                    db.add(ProcessedMail(message_id=item["message_id"]))
                db.commit()
            finally:
                db.close()
            if new_items:
                payload = {
                    "source": "feishu_api",
                    "items": [
                        {
                            "message_id": item["message_id"],
                            "subject": item["subject"],
                            "sender_name": item.get("sender_name", ""),
                            "sender_email": item["sender_email"],
                            "recipient_email": item.get("recipient_email", ""),
                            "suggested_status": item.get("suggested_status"),
                            "confidence": item.get("confidence", "low"),
                            "body": item.get("body"),
                            "body_text": item.get("body_text"),
                            "attachments": item.get("attachments"),
                        }
                        for item in new_items
                    ],
                }
                async with httpx.AsyncClient() as client:
                    resp = await client.post(
                        "http://localhost:8000/ingest",
                        json=payload,
                        timeout=30,
                    )
                    resp.raise_for_status()
        except Exception:
            pass
        await asyncio.sleep(300)


def _extract_embedded_attachments(body_text: str, body_html: str | None) -> list[dict]:
    """Extract webmail embedded attachment links (QQ mail large attachments, etc.) from email body."""
    import re
    combined = (body_html or "") + "\n" + body_text
    attachments = []

    # QQ mail large attachments: 总结.docx 从QQ邮箱发来的超大附件
    for m in re.finditer(r'(?P<filename>[^"<>/\n]+\.docx?)[^<>]*\n[^<>]*?(?P<url>https?://wx\.mail\.qq\.com/ftn/download\?[^\s<>"\'\]\)]+)', combined, re.IGNORECASE):
        attachments.append({
            "filename": m.group("filename"),
            "size": 0,
            "mime_type": "application/vnd.openxmlformats-officedocument.wordprocessingml.document" if m.group("filename").endswith(".docx") else "application/msword",
            "external_url": m.group("url"),
        })

    return attachments


def _fetch_mail(mailbox: str) -> list[dict]:
    from feishu_integration.mail_reader import fetch_and_classify, fetch_single_email
    items = fetch_and_classify(mailbox=mailbox)
    for item in items:
        try:
            detail = fetch_single_email(item["message_id"], mailbox=mailbox)
            item["body"] = detail.get("body", "")
            item["body_text"] = detail.get("body_plain_text", "")
            item["recipient_email"] = detail.get("to", "")
            attachments = []
            for a in detail.get("attachments", []):
                att = {
                    "filename": a.get("filename", ""),
                    "size": a.get("size", 0),
                    "mime_type": a.get("content_type", ""),
                    "message_attachment_id": a.get("message_attachment_id") or a.get("id", ""),
                }
                # Download attachments (PDF, Word docs, images)
                if att["mime_type"] in ("application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document") or \
                   att["filename"].lower().endswith((".pdf", ".doc", ".docx", ".png", ".jpg", ".jpeg")):
                    storage_path = _download_attachment(item["message_id"], att, mailbox)
                    if storage_path:
                        att["storage_path"] = storage_path
                attachments.append(att)
            # Also scan body for embedded webmail attachments (QQ large attachments, etc.)
            embedded = _extract_embedded_attachments(item.get("body_text", ""), item.get("body"))
            attachments.extend(embedded)
            item["attachments"] = attachments
        except Exception:
            pass
    return items


@asynccontextmanager
async def lifespan(application: FastAPI) -> AsyncGenerator:
    seed_data()
    global _poll_task
    _poll_task = asyncio.create_task(_poll_mailbox())
    yield
    if _poll_task:
        _poll_task.cancel()


app = FastAPI(title="Provider HR", description="招聘进度追踪示例", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:8080", "http://localhost:8080",
        "http://127.0.0.1:8081", "http://localhost:8081",
        "http://127.0.0.1:8082", "http://localhost:8082",
        "http://127.0.0.1:8000", "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.dependency_overrides[lib_get_db] = app_get_db
app.include_router(recruitments.router)
app.include_router(pipeline.router)
app.include_router(pool.router)
app.include_router(candidates.router)
app.include_router(applications.router)
app.include_router(ingest.router)
app.include_router(queue.router)
app.include_router(materials.router)
app.include_router(messages.router)
app.include_router(ai_config.router)
app.include_router(export.router)


@app.get("/attachments/{message_id}/{filename:path}")
def serve_attachment(message_id: str, filename: str):
    """Serve stored attachment files (PDF, images, etc.) for browser preview."""
    file_path = os.path.join(_ATTACHMENT_DIR, message_id, filename)
    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="Attachment not found")
    return FileResponse(file_path, filename=filename)


static_dir = os.path.join(os.path.dirname(__file__), "static")
app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("__main__:app", host="0.0.0.0", port=8000)
