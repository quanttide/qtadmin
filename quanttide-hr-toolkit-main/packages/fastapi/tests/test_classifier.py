"""服务端分类引擎测试。"""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from fastapi_quanttide_hr.database import Base
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.recruitment import Recruitment
from fastapi_quanttide_hr.models.talent import TalentStatus
from fastapi_quanttide_hr.services.classifier import classify


def _db():
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(bind=engine)
    db = TestingSessionLocal()
    return db


def test_classify_new_application():
    db = _db()
    try:
        result = classify(
            subject="应聘前端工程师-张三",
            body_text="您好，我是张三...",
            sender_name="张三",
            sender_email="zhangsan@example.com",
            db=db,
        )
        assert result.merge_result == "new"
        assert result.classifier_source == "rule"
        assert result.confidence in ("high", "medium", "low")
    finally:
        db.close()


def test_classify_exam_received():
    db = _db()
    try:
        result = classify(
            subject="笔试答案-前端-张三",
            body_text="",
            sender_name="张三",
            sender_email="zhangsan@example.com",
            db=db,
        )
        assert result.suggested_status == "exam_received"
        assert result.classifier_reason is not None
        assert "笔试答案" in (result.classifier_reason or "")
    finally:
        db.close()


def test_classify_auto_merge():
    db = _db()
    try:
        r = Recruitment(title="前端工程师")
        db.add(r)
        db.flush()
        c = Candidate(email="zhangsan@example.com", real_name="张三")
        db.add(c)
        db.flush()
        app = Application(candidate_id=c.id, recruitment_id=r.id, source="feishu_api")
        db.add(app)
        db.commit()

        result = classify(
            subject="Re: 面试时间确认",
            body_text="我可以参加面试",
            sender_name="张三",
            sender_email="zhangsan@example.com",
            db=db,
        )
        assert result.merge_result == "existing_auto"
        assert result.match is not None
        assert result.match.active_application_id == app.id
    finally:
        db.close()


def test_classify_existing_candidate_no_active():
    db = _db()
    try:
        c = Candidate(email="lisi@example.com", real_name="李四")
        db.add(c)
        db.commit()

        result = classify(
            subject="应聘后端工程师",
            body_text="",
            sender_name="李四",
            sender_email="lisi@example.com",
            db=db,
        )
        assert result.merge_result == "existing_review"
        assert result.match is not None
        assert result.match.exists is True
    finally:
        db.close()


def test_classify_auto_reply():
    db = _db()
    try:
        result = classify(
            subject="自动回复: 应聘前端工程师",
            body_text="",
            sender_name="张三",
            sender_email="zhangsan@example.com",
            db=db,
        )
        assert result.confidence == "reject"
        assert result.classifier_reason is not None
        assert "自动回复" in (result.classifier_reason or "")
    finally:
        db.close()


def test_classify_no_match():
    db = _db()
    try:
        result = classify(
            subject="周末聚餐通知",
            body_text="这周六晚上一起吃饭",
            sender_name="同事",
            sender_email="同事@company.com",
            db=db,
        )
        assert result.suggested_status is None
        assert result.confidence == "low"
    finally:
        db.close()
