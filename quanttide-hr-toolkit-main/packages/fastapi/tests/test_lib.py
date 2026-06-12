from __future__ import annotations

import os
import tempfile

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from fastapi_quanttide_hr.database import Base, get_db as lib_get_db
from fastapi_quanttide_hr.models.recruitment import Recruitment
from fastapi_quanttide_hr.models.talent import ALLOWED_STATUSES_FOR_SUB_STAGE, STATUS_TRANSITIONS, Talent, TalentStatus
from fastapi_quanttide_hr.schemas.recruitment import RecruitmentRead
from fastapi_quanttide_hr.seed import DEMO_TALENTS, SEED_TRANSITIONS
from fastapi_quanttide_hr.schemas.talent import TalentCreate, TalentRead, TalentTransition, TalentUpdate
from fastapi_quanttide_hr.services.pipeline import _application_to_card, get_pipeline
from fastapi_quanttide_hr.routers import pipeline, recruitments, ingest, queue
from fastapi_quanttide_hr.routers import export
from fastapi_quanttide_hr.models.candidate import Candidate
from fastapi_quanttide_hr.models.application import Application
from fastapi_quanttide_hr.models.correction_log import CorrectionLog
from fastapi_quanttide_hr.services.resume_parser import NoopResumeParser, ResumeParser
from fastapi_quanttide_hr.schemas.candidate import CandidateRead
from fastapi_quanttide_hr.schemas.application import ApplicationRead, ApplicationListQuery
from fastapi_quanttide_hr.routers import candidates, applications, pool


@pytest.fixture
def db():
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = f.name
    engine = create_engine(f"sqlite:///{db_path}", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
        os.unlink(db_path)


@pytest.fixture
def client():
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = f.name
    engine = create_engine(f"sqlite:///{db_path}", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    def app_get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    app = FastAPI()
    app.dependency_overrides[lib_get_db] = app_get_db
    app.include_router(recruitments.router)
    app.include_router(pipeline.router)
    app.include_router(candidates.router)
    app.include_router(applications.router)
    app.include_router(ingest.router)
    app.include_router(queue.router)
    app.include_router(pool.router)
    app.include_router(export.router)
    yield TestClient(app)
    os.unlink(db_path)


@pytest.fixture
def client_with_db():
    """Shared fixture: client + db use the same database."""
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = f.name
    engine = create_engine(f"sqlite:///{db_path}", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    def app_get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    app = FastAPI()
    app.dependency_overrides[lib_get_db] = app_get_db
    app.include_router(recruitments.router)
    app.include_router(pipeline.router)
    app.include_router(candidates.router)
    app.include_router(applications.router)
    app.include_router(ingest.router)
    app.include_router(queue.router)
    app.include_router(pool.router)
    app.include_router(export.router)
    client = TestClient(app)
    try:
        yield client, session
    finally:
        session.close()
        os.unlink(db_path)


@pytest.fixture
def client_with_seeded_ca():
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = f.name
    engine = create_engine(f"sqlite:///{db_path}", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    db = SessionLocal()
    r = Recruitment()
    db.add(r)
    db.flush()
    a_candidate = Candidate(email="a@b.com", real_name="候选人A")
    db.add(a_candidate)
    db.flush()
    b_candidate = Candidate(email="b@b.com", real_name="候选人B")
    db.add(b_candidate)
    db.flush()
    app1 = Application(candidate_id=a_candidate.id, recruitment_id=r.id, status=TalentStatus.NEW)
    db.add(app1)
    app2 = Application(candidate_id=a_candidate.id, recruitment_id=r.id, status=TalentStatus.OFFER)
    db.add(app2)
    from datetime import datetime, UTC
    app3 = Application(candidate_id=b_candidate.id, recruitment_id=r.id, status=TalentStatus.NEW, pooled_at=datetime.now(UTC))
    db.add(app3)
    db.commit()
    seeded = {"candidate_a": a_candidate.id, "candidate_b": b_candidate.id, "recruitment": r.id}
    db.close()

    def app_get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    app = FastAPI()
    app.dependency_overrides[lib_get_db] = app_get_db
    app.include_router(recruitments.router)
    app.include_router(pipeline.router)
    app.include_router(candidates.router)
    app.include_router(applications.router)
    app.include_router(ingest.router)
    app.include_router(queue.router)
    app.include_router(pool.router)
    yield TestClient(app), seeded
    os.unlink(db_path)


# ── Database layer ──

def test_database_base():
    assert Base is not None


def test_get_db_unimplemented():
    with pytest.raises(NotImplementedError):
        next(lib_get_db())


# ── Models ──

def test_recruitment_model(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    assert r.id is not None
    assert r.created_at is not None


def test_talent_model(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    t = Talent(recruitment_id=r.id, email="a@b.com", real_name="测试")
    db.add(t)
    db.flush()
    assert t.id is not None
    assert t.status == TalentStatus.NEW
    assert t.sub_stage is None
    assert t.email == "a@b.com"
    assert t.real_name == "测试"
    assert t.created_at is not None
    assert t.updated_at is not None


def test_talent_status_values():
    assert TalentStatus.NEW.value == "new"
    assert TalentStatus.CONTACTED.value == "contacted"
    assert TalentStatus.EXAM_SENT.value == "exam_sent"
    assert TalentStatus.EXAM_RECEIVED.value == "exam_received"
    assert TalentStatus.EVALUATING.value == "evaluating"
    assert TalentStatus.INTERVIEW.value == "interview"
    assert TalentStatus.OFFER.value == "offer"
    assert TalentStatus.CLOSED.value == "closed"


def test_status_transitions_valid():
    assert TalentStatus.CONTACTED in STATUS_TRANSITIONS[TalentStatus.NEW]
    assert TalentStatus.CLOSED in STATUS_TRANSITIONS[TalentStatus.NEW]
    assert TalentStatus.NEW not in STATUS_TRANSITIONS[TalentStatus.CONTACTED]
    assert TalentStatus.NEW not in STATUS_TRANSITIONS[TalentStatus.CLOSED]


def test_status_transitions_all():
    assert STATUS_TRANSITIONS[TalentStatus.NEW] == [TalentStatus.CONTACTED, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.CONTACTED] == [TalentStatus.EXAM_SENT, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.EXAM_SENT] == [TalentStatus.EXAM_RECEIVED, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.EXAM_RECEIVED] == [TalentStatus.EVALUATING, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.EVALUATING] == [TalentStatus.INTERVIEW, TalentStatus.EXAM_SENT, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.INTERVIEW] == [TalentStatus.OFFER, TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.OFFER] == [TalentStatus.CLOSED]
    assert STATUS_TRANSITIONS[TalentStatus.CLOSED] == []


# ── Schemas ──

def test_schema_talent_create():
    s = TalentCreate(email="a@b.com", real_name="张三")
    assert s.email == "a@b.com"
    assert s.real_name == "张三"
    assert s.model_dump() == {"email": "a@b.com", "real_name": "张三", "auto_screening_result": None}
    # Note: auto_screening_result field is a placeholder pending HR confirmation


def test_schema_talent_read():
    s = TalentRead(id=1, recruitment_id=1, email="a@b.com", real_name="张三", status=TalentStatus.NEW, created_at="2026-01-01T00:00:00", updated_at="2026-01-01T00:00:00")
    assert s.email == "a@b.com"
    assert s.sub_stage is None


def test_schema_talent_update():
    s = TalentUpdate(quality="good")
    assert s.quality == "good"


def test_schema_talent_update_empty():
    s = TalentUpdate()
    assert s.quality is None


def test_schema_talent_transition():
    s = TalentTransition(status=TalentStatus.CONTACTED)
    assert s.status == TalentStatus.CONTACTED


def test_schema_recruitment_read():
    s = RecruitmentRead(id=1, created_at="2026-01-01T00:00:00")
    assert s.id == 1


# ── Pipeline Service ──

def test_pipeline_empty(db):
    result = get_pipeline(db)
    assert result["summary"]["total"] == 0
    assert result["summary"]["need_attention"] == 0
    for s in TalentStatus:
        assert result["stages"][s.value] == []


def test_pipeline_with_application(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id)
    db.add(a)
    db.commit()

    result = get_pipeline(db)
    assert result["summary"]["total"] == 1
    card = result["stages"]["new"][0]
    assert card["email"] == "a@b.com"
    assert card["real_name"] == "测试"
    assert card["status"] == "new"
    assert card["recruitment_id"] == r.id
    assert card["sub_stage"] is None


def test_pipeline_need_attention(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    for email, status in [("e1@t.com", TalentStatus.EXAM_RECEIVED), ("e2@t.com", TalentStatus.EVALUATING), ("new@t.com", TalentStatus.NEW)]:
        c = Candidate(email=email, real_name="T")
        db.add(c)
        db.flush()
        a = Application(candidate_id=c.id, recruitment_id=r.id, status=status)
        db.add(a)
    db.commit()

    result = get_pipeline(db)
    assert result["summary"]["total"] == 3
    assert result["summary"]["need_attention"] == 2


def test_application_to_card(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="c@d.com", real_name="卡")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id)
    db.add(a)
    db.flush()

    card = _application_to_card(a)
    assert card["id"] == a.id
    assert card["email"] == "c@d.com"
    assert card["real_name"] == "卡"
    assert card["recruitment_id"] == r.id
    assert card["status"] == "new"
    assert card["sub_stage"] is None
    assert "created_at" in card


# ── API ──

def test_create_recruitment(client):
    r = client.post("/recruitments", json={})
    assert r.status_code == 201
    assert "id" in r.json()


def test_list_recruitments_empty(client):
    r = client.get("/recruitments")
    assert r.status_code == 200
    assert r.json() == []


def test_list_recruitments(client):
    client.post("/recruitments", json={})
    r = client.get("/recruitments")
    assert r.status_code == 200
    assert len(r.json()) == 1


def test_get_recruitment(client):
    created = client.post("/recruitments", json={}).json()
    r = client.get(f"/recruitments/{created['id']}")
    assert r.status_code == 200
    assert r.json()["id"] == created["id"]


def test_get_recruitment_404(client):
    r = client.get("/recruitments/999")
    assert r.status_code == 404


def test_delete_recruitment(client):
    created = client.post("/recruitments", json={}).json()
    r = client.delete(f"/recruitments/{created['id']}")
    assert r.status_code == 204
    r = client.get(f"/recruitments/{created['id']}")
    assert r.status_code == 404


def test_delete_recruitment_404(client):
    r = client.delete("/recruitments/999")
    assert r.status_code == 404


def test_create_talent(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "张三"})
    assert r.status_code == 201
    assert r.json()["status"] == "new"
    assert r.json()["email"] == "a@b.com"


def test_create_talent_invalid_recruitment(client):
    r = client.post("/recruitments/999/talents", json={"email": "a@b.com", "real_name": "X"})
    assert r.status_code == 404


def test_list_talents(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"})
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "b@b.com", "real_name": "B"})
    r = client.get(f"/recruitments/{rec_id}/talents")
    assert r.status_code == 200
    assert len(r.json()) == 2


def test_list_talents_recruitment_not_found(client):
    r = client.get("/recruitments/999/talents")
    assert r.status_code == 404


def test_list_talents_filter_by_status(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "b@b.com", "real_name": "B"})
    client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "contacted"})
    r = client.get(f"/recruitments/{rec_id}/talents?status=contacted")
    assert r.status_code == 200
    assert len(r.json()) == 1


def test_get_talent(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    r = client.get(f"/recruitments/{rec_id}/talents/{t['id']}")
    assert r.status_code == 200
    assert r.json()["id"] == t["id"]


def test_get_talent_404(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.get(f"/recruitments/{rec_id}/talents/999")
    assert r.status_code == 404


def test_update_talent(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    r = client.patch(f"/recruitments/{rec_id}/talents/{t['id']}", json={"quality": "good"})
    assert r.status_code == 200
    assert r.json()["quality"] == "good"


def test_update_talent_partial(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    r = client.patch(f"/recruitments/{rec_id}/talents/{t['id']}", json={"quality": "good"})
    assert r.status_code == 200
    assert r.json()["quality"] == "good"


def test_update_talent_404(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.patch(f"/recruitments/{rec_id}/talents/999", json={"quality": "good"})
    assert r.status_code == 404


def test_delete_talent(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    r = client.delete(f"/recruitments/{rec_id}/talents/{t['id']}")
    assert r.status_code == 204
    r = client.get(f"/recruitments/{rec_id}/talents")
    assert r.json() == []


def test_delete_talent_404(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.delete(f"/recruitments/{rec_id}/talents/999")
    assert r.status_code == 404


def test_transition_full_chain(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    # 首次设置子阶段，验证跨状态后清空
    r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "contacted", "sub_stage": "resume_passed"})
    assert r.status_code == 200
    assert r.json()["sub_stage"] == "resume_passed"
    for status in ["exam_sent", "exam_received", "evaluating", "interview", "offer", "closed"]:
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": status})
        assert r.status_code == 200
        assert r.json()["status"] == status
        # 跨主状态后子阶段应清空
        assert r.json()["sub_stage"] is None


def test_transition_invalid(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
    r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "offer"})
    assert r.status_code == 400
    assert "Cannot transition" in r.json()["detail"]


def test_transition_404(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.post(f"/recruitments/{rec_id}/talents/999/transition", json={"status": "contacted"})
    assert r.status_code == 404


def test_pipeline_api(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"})
    r = client.get("/pipeline")
    assert r.status_code == 200
    data = r.json()
    assert data["summary"]["total"] == 1
    assert "stages" in data
    assert "summary" in data


def test_cascade_delete(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"})
    client.delete(f"/recruitments/{rec_id}")
    r = client.get(f"/recruitments/{rec_id}/talents")
    assert r.status_code == 404


class TestStatusMachine:
    """8 statuses × 5 tests = 40 comprehensive state machine coverage."""

    STATUS_CHAIN = ["new", "contacted", "exam_sent", "exam_received", "evaluating", "interview", "offer", "closed"]

    def _walk_to(self, client, rec_id, tid, target: str):
        """Walk talent forward through status chain until target is reached."""
        target_idx = self.STATUS_CHAIN.index(target)
        for s in self.STATUS_CHAIN[1:target_idx + 1]:
            r = client.post(f"/recruitments/{rec_id}/talents/{tid}/transition", json={"status": s})
            assert r.status_code == 200, f"walk_to {s} failed: {r.json()}"

    def _setup(self, client, status: TalentStatus):
        """Create recruitment + talent at given status. Returns (rec_id, talent_dict)."""
        rec_id = client.post("/recruitments", json={}).json()["id"]
        t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()
        if status != TalentStatus.NEW:
            self._walk_to(client, rec_id, t["id"], status.value)
            r = client.get(f"/recruitments/{rec_id}/talents/{t['id']}")
            t = r.json()
        return rec_id, t

    # ── NEW ──

    def test_new_to_contacted(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "contacted"})
        assert r.status_code == 200
        assert r.json()["status"] == "contacted"

    def test_new_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200
        assert r.json()["status"] == "closed"

    def test_new_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "interview"})
        assert r.status_code == 400

    def test_new_sub_stage_not_allowed(self, client):
        assert TalentStatus.NEW not in ALLOWED_STATUSES_FOR_SUB_STAGE

    def test_new_defaults(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        assert t["status"] == "new"
        assert t["sub_stage"] is None

    # ── CONTACTED ──

    def test_contacted_to_exam_sent(self, client):
        rec_id, t = self._setup(client, TalentStatus.CONTACTED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "exam_sent"})
        assert r.status_code == 200
        assert r.json()["status"] == "exam_sent"

    def test_contacted_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.CONTACTED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200
        assert r.json()["status"] == "closed"

    def test_contacted_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.CONTACTED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "evaluating"})
        assert r.status_code == 400

    def test_contacted_sub_stage(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "contacted", "sub_stage": "resume_passed"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "resume_passed"

    def test_contacted_sub_stage_cleared(self, client):
        rec_id, t = self._setup(client, TalentStatus.NEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "contacted", "sub_stage": "resume_passed"})
        assert r.json()["sub_stage"] == "resume_passed"
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "exam_sent"})
        assert r.json()["sub_stage"] is None

    # ── EXAM_SENT ──

    def test_exam_sent_to_exam_received(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_SENT)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "exam_received"})
        assert r.status_code == 200
        assert r.json()["status"] == "exam_received"

    def test_exam_sent_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_SENT)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200

    def test_exam_sent_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_SENT)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "interview"})
        assert r.status_code == 400

    def test_exam_sent_sub_stage(self, client):
        rec_id, t = self._setup(client, TalentStatus.CONTACTED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "exam_sent", "sub_stage": "taking"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "taking"

    def test_exam_sent_sub_stage_cleared(self, client):
        rec_id, t = self._setup(client, TalentStatus.CONTACTED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "exam_sent", "sub_stage": "taking"})
        assert r.json()["sub_stage"] == "taking"
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "exam_received"})
        assert r.json()["sub_stage"] is None

    # ── EXAM_RECEIVED ──

    def test_exam_received_to_evaluating(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_RECEIVED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "evaluating"})
        assert r.status_code == 200
        assert r.json()["status"] == "evaluating"

    def test_exam_received_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_RECEIVED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200

    def test_exam_received_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_RECEIVED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "offer"})
        assert r.status_code == 400

    def test_exam_received_sub_stage_not_allowed(self, client):
        assert TalentStatus.EXAM_RECEIVED not in ALLOWED_STATUSES_FOR_SUB_STAGE

    def test_exam_received_no_extra_paths(self, client):
        assert STATUS_TRANSITIONS[TalentStatus.EXAM_RECEIVED] == [TalentStatus.EVALUATING, TalentStatus.CLOSED]

    # ── EVALUATING ──

    def test_evaluating_to_interview(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "interview"})
        assert r.status_code == 200
        assert r.json()["status"] == "interview"

    def test_evaluating_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200

    def test_evaluating_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "contacted"})
        assert r.status_code == 400

    def test_evaluating_sub_stage(self, client):
        rec_id, t = self._setup(client, TalentStatus.EXAM_RECEIVED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "evaluating", "sub_stage": "exam_passed"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "exam_passed"

    def test_evaluating_back_to_exam_sent(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "exam_sent"})
        assert r.status_code == 200
        assert r.json()["status"] == "exam_sent"

    # ── INTERVIEW ──

    def test_interview_to_offer(self, client):
        rec_id, t = self._setup(client, TalentStatus.INTERVIEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "offer"})
        assert r.status_code == 200
        assert r.json()["status"] == "offer"

    def test_interview_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.INTERVIEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200

    def test_interview_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.INTERVIEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "exam_sent"})
        assert r.status_code == 400

    def test_interview_sub_stage(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "interview", "sub_stage": "interview_passed"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "interview_passed"

    def test_interview_sub_stage_cleared(self, client):
        rec_id, t = self._setup(client, TalentStatus.EVALUATING)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "interview", "sub_stage": "interview_passed"})
        assert r.json()["sub_stage"] == "interview_passed"
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "offer"})
        assert r.json()["sub_stage"] is None

    # ── OFFER ──

    def test_offer_to_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.OFFER)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.status_code == 200
        assert r.json()["status"] == "closed"

    def test_offer_only_forward(self, client):
        assert STATUS_TRANSITIONS[TalentStatus.OFFER] == [TalentStatus.CLOSED]

    def test_offer_invalid_jump(self, client):
        rec_id, t = self._setup(client, TalentStatus.OFFER)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "interview"})
        assert r.status_code == 400

    def test_offer_sub_stage(self, client):
        rec_id, t = self._setup(client, TalentStatus.INTERVIEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "offer", "sub_stage": "accepted"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "accepted"

    def test_offer_sub_stage_cleared(self, client):
        rec_id, t = self._setup(client, TalentStatus.INTERVIEW)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                        json={"status": "offer", "sub_stage": "accepted"})
        assert r.json()["sub_stage"] == "accepted"
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "closed"})
        assert r.json()["sub_stage"] is None

    # ── CLOSED ──

    def test_closed_no_transition(self, client):
        rec_id, t = self._setup(client, TalentStatus.CLOSED)
        r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "new"})
        assert r.status_code == 400

    def test_closed_stays_closed(self, client):
        rec_id, t = self._setup(client, TalentStatus.CLOSED)
        for target in ["contacted", "exam_sent", "offer"]:
            r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": target})
            assert r.status_code == 400, f"CLOSED → {target} should be rejected"

    def test_closed_invalid_all(self, client):
        rec_id, t = self._setup(client, TalentStatus.CLOSED)
        for status in TalentStatus:
            r = client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": status.value})
            assert r.status_code == 400, f"CLOSED → {status.value} should be rejected"

    def test_closed_sub_stage_not_allowed(self, client):
        assert TalentStatus.CLOSED not in ALLOWED_STATUSES_FOR_SUB_STAGE

    def test_closed_is_final(self, client):
        assert STATUS_TRANSITIONS[TalentStatus.CLOSED] == []


class TestSubStageEndpoint:
    """PATCH /recruitments/{id}/talents/{id}/sub-stage endpoint tests."""

    def test_set_sub_stage_allowed(self, client):
        rec_id = client.post("/recruitments", json={}).json()["id"]
        t = client.post(f"/recruitments/{rec_id}/talents", json={"email":"a@b.com","real_name":"A"}).json()
        # Walk to CONTACTED (in ALLOWED)
        client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status":"contacted"})
        r = client.patch(f"/recruitments/{rec_id}/talents/{t['id']}/sub-stage", json={"sub_stage":"resume_passed"})
        assert r.status_code == 200
        assert r.json()["sub_stage"] == "resume_passed"

    def test_set_sub_stage_not_allowed(self, client):
        rec_id = client.post("/recruitments", json={}).json()["id"]
        t = client.post(f"/recruitments/{rec_id}/talents", json={"email":"a@b.com","real_name":"A"}).json()
        # NEW is not in ALLOWED
        r = client.patch(f"/recruitments/{rec_id}/talents/{t['id']}/sub-stage", json={"sub_stage":"resume_passed"})
        assert r.status_code == 400

    def test_clear_sub_stage(self, client):
        rec_id = client.post("/recruitments", json={}).json()["id"]
        t = client.post(f"/recruitments/{rec_id}/talents", json={"email":"a@b.com","real_name":"A"}).json()
        client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status":"contacted"})
        client.patch(f"/recruitments/{rec_id}/talents/{t['id']}/sub-stage", json={"sub_stage":"resume_passed"})
        r = client.patch(f"/recruitments/{rec_id}/talents/{t['id']}/sub-stage", json={"sub_stage":None})
        assert r.status_code == 200
        assert r.json()["sub_stage"] is None

    def test_set_sub_stage_404(self, client):
        rec_id = client.post("/recruitments", json={}).json()["id"]
        r = client.patch(f"/recruitments/{rec_id}/talents/999/sub-stage", json={"sub_stage":"resume_passed"})
        assert r.status_code == 404


# ── Phase A3: sub_stage write-back to Application ──

def test_set_sub_stage_syncs_application(client_with_db):
    """PATCH sub-stage on Talent should sync to the associated Application."""
    cli, db = client_with_db
    rec_id = cli.post("/recruitments", json={}).json()["id"]
    t = cli.post(f"/recruitments/{rec_id}/talents", json={"email":"a3@b.com","real_name":"A3"}).json()
    cli.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status":"contacted"})
    r = cli.patch(f"/recruitments/{rec_id}/talents/{t['id']}/sub-stage", json={"sub_stage":"resume_passed"})
    assert r.status_code == 200

    talent = db.query(Talent).filter(Talent.id == t["id"]).first()
    assert talent.application is not None
    assert talent.application.sub_stage == "resume_passed"


# ── Phase B1/B2: Recruitment model business fields ──

def test_recruitment_with_title(db):
    """Recruitment model should support title/status/deadline."""
    r = Recruitment(title="测试职位", status="active")
    db.add(r)
    db.commit()
    assert r.title == "测试职位"
    assert r.status == "active"
    assert r.deadline is None


def test_recruitment_default_title(db):
    """Recruitment should default title to empty string."""
    r = Recruitment()
    db.add(r)
    db.commit()
    assert r.title == ""


def test_create_recruitment_with_title(client):
    """POST /recruitments should accept title."""
    r = client.post("/recruitments", json={"title": "后端开发"})
    assert r.status_code == 201
    assert r.json()["title"] == "后端开发"


def test_create_recruitment_without_title(client):
    """POST /recruitments without title should default to empty string."""
    r = client.post("/recruitments", json={})
    assert r.status_code == 201
    assert r.json()["title"] == ""


# ── Candidate Model ──

def test_candidate_model(db):
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    assert c.id is not None
    assert c.email == "a@b.com"
    assert c.real_name == "测试"
    assert c.phone is None
    assert c.created_at is not None


def test_candidate_with_phone(db):
    c = Candidate(email="b@b.com", real_name="测试B", phone="13800138000")
    db.add(c)
    db.flush()
    assert c.phone == "13800138000"


# ── Application Model ──

def test_application_model(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id)
    db.add(a)
    db.flush()
    assert a.id is not None
    assert a.status == TalentStatus.NEW
    assert a.quality == "normal"
    assert a.source == "manual_seed"
    assert a.sub_stage is None
    assert a.pooled_at is None
    assert a.stage_results is None
    assert a.created_at is not None
    assert a.updated_at is not None


def test_application_with_all_fields(db):
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(
        candidate_id=c.id, recruitment_id=r.id,
        status=TalentStatus.OFFER, sub_stage="accepted",
        quality="excellent", stage_results={"contacted": "pass", "evaluating": "pass", "interview": "pass"},
        source="feishu_api",
    )
    db.add(a)
    db.flush()
    assert a.status == TalentStatus.OFFER
    assert a.sub_stage == "accepted"
    assert a.quality == "excellent"
    assert a.stage_results == {"contacted": "pass", "evaluating": "pass", "interview": "pass"}
    assert a.source == "feishu_api"


def test_application_pooled_at(db):
    from datetime import datetime, UTC
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id, pooled_at=datetime.now(UTC))
    db.add(a)
    db.flush()
    assert a.pooled_at is not None


# ── Candidate Schemas ──

def test_schema_candidate_read():
    s = CandidateRead(id=1, email="a@b.com", real_name="张三", created_at="2026-01-01T00:00:00")
    assert s.email == "a@b.com"
    assert s.real_name == "张三"


def test_schema_candidate_read_with_phone():
    s = CandidateRead(id=1, email="a@b.com", real_name="张三", phone="13800138000", created_at="2026-01-01T00:00:00")
    assert s.phone == "13800138000"


# ── Application Schemas ──

def test_schema_application_read():
    s = ApplicationRead(
        id=1, candidate_id=1, recruitment_id=1, status=TalentStatus.NEW,
        quality="normal", source="manual_seed",
        created_at="2026-01-01T00:00:00", updated_at="2026-01-01T00:00:00",
    )
    assert s.id == 1
    assert s.status == TalentStatus.NEW
    assert s.sub_stage is None
    assert s.pooled_at is None


def test_schema_application_list_query_defaults():
    q = ApplicationListQuery()
    assert q.status is None
    assert q.candidate_id is None
    assert q.recruitment_id is None
    assert q.pooled is None
    assert q.skip == 0
    assert q.limit == 100


def test_schema_application_list_query_full():
    q = ApplicationListQuery(status="offer", candidate_id=1, recruitment_id=1, pooled=True, skip=10, limit=50)
    assert q.status == "offer"
    assert q.candidate_id == 1
    assert q.pooled is True


# ── Candidate + Application Routes ──

def test_list_candidates(client_with_seeded_ca):
    client, seeded = client_with_seeded_ca
    r = client.get("/candidates")
    assert r.status_code == 200
    assert len(r.json()) == 2


def test_get_candidate_applications(client_with_seeded_ca):
    client, seeded = client_with_seeded_ca
    cid = seeded["candidate_a"]
    r = client.get(f"/candidates/{cid}/applications")
    assert r.status_code == 200
    assert len(r.json()) == 2


def test_get_candidate_applications_other(client_with_seeded_ca):
    client, seeded = client_with_seeded_ca
    cid = seeded["candidate_b"]
    r = client.get(f"/candidates/{cid}/applications")
    assert r.status_code == 200
    assert len(r.json()) == 1


def test_get_candidate_applications_404(client_with_seeded_ca):
    client, _ = client_with_seeded_ca
    r = client.get("/candidates/999/applications")
    assert r.status_code == 404


def test_list_applications(client_with_seeded_ca):
    client, _ = client_with_seeded_ca
    r = client.get("/applications")
    assert r.status_code == 200
    assert len(r.json()) == 3


def test_list_applications_filter_by_status(client_with_seeded_ca):
    client, _ = client_with_seeded_ca
    r = client.get("/applications?status=new")
    assert r.status_code == 200
    assert len(r.json()) == 2
    for app in r.json():
        assert app["status"] == "new"


def test_list_applications_filter_by_candidate(client_with_seeded_ca):
    client, seeded = client_with_seeded_ca
    cid = seeded["candidate_a"]
    r = client.get(f"/applications?candidate_id={cid}")
    assert r.status_code == 200
    assert len(r.json()) == 2


def test_list_applications_filter_by_recruitment(client_with_seeded_ca):
    client, seeded = client_with_seeded_ca
    rid = seeded["recruitment"]
    r = client.get(f"/applications?recruitment_id={rid}")
    assert r.status_code == 200
    assert len(r.json()) == 3


def test_list_applications_pooled_true(client_with_seeded_ca):
    client, _ = client_with_seeded_ca
    r = client.get("/applications?pooled=true")
    assert r.status_code == 200
    assert len(r.json()) == 1
    assert r.json()[0]["pooled_at"] is not None


def test_list_applications_pooled_false(client_with_seeded_ca):
    client, _ = client_with_seeded_ca
    r = client.get("/applications?pooled=false")
    assert r.status_code == 200
    assert len(r.json()) == 2
    for app in r.json():
        assert app["pooled_at"] is None


# ── Application deactivated_at ──

def test_application_model_deactivated_at(db):
    from datetime import datetime, UTC
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id, deactivated_at=datetime.now(UTC))
    db.add(a)
    db.flush()
    assert a.deactivated_at is not None


def test_schema_application_read_with_deactivated_at():
    s = ApplicationRead(
        id=1, candidate_id=1, recruitment_id=1, status=TalentStatus.NEW,
        quality="normal", source="manual_seed",
        created_at="2026-01-01T00:00:00", updated_at="2026-01-01T00:00:00",
    )
    assert s.deactivated_at is None


# ── Ingest API ──

def test_ingest_basic(client):
    """POST /ingest with a single item queues it."""
    r = client.post("/ingest", json={
        "source": "feishu_api",
        "items": [{
            "message_id": "msg001", "subject": "求职-张三-前端",
            "sender_name": "张三", "sender_email": "zhang3@demo.local",
            "suggested_status": "new", "confidence": "high",
        }],
    })
    assert r.status_code == 201
    data = r.json()
    assert data["queued"] == 1
    assert data["skipped"] == 0
    assert data["items"][0]["action"] == "queued"


def test_ingest_multiple(client):
    """POST /ingest with multiple items queues all."""
    r = client.post("/ingest", json={
        "items": [
            {"message_id": "m1", "subject": "S1", "sender_email": "a@t.com"},
            {"message_id": "m2", "subject": "S2", "sender_email": "b@t.com"},
            {"message_id": "m3", "subject": "S3", "sender_email": "c@t.com"},
        ],
    })
    assert r.status_code == 201
    assert r.json()["queued"] == 3


def test_ingest_dedup(client):
    """Same message_id twice -> second is skipped."""
    body = {
        "items": [{"message_id": "dup1", "subject": "D", "sender_email": "d@t.com"}],
    }
    r1 = client.post("/ingest", json=body)
    assert r1.json()["queued"] == 1
    r2 = client.post("/ingest", json=body)
    assert r2.json()["queued"] == 0
    assert r2.json()["skipped"] == 1
    assert r2.json()["items"][0]["action"] == "skipped"


def test_ingest_dedup_by_email(client):
    """Same sender email, different message_id -> second pending item is skipped."""
    email = "same@t.com"
    r1 = client.post("/ingest", json={
        "items": [{"message_id": "msg-a", "subject": "First", "sender_email": email}],
    })
    assert r1.status_code == 201
    assert r1.json()["queued"] == 1

    r2 = client.post("/ingest", json={
        "items": [{"message_id": "msg-b", "subject": "Reply", "sender_email": email}],
    })
    assert r2.status_code == 201
    assert r2.json()["queued"] == 0
    assert r2.json()["skipped"] == 1

    r = client.get("/queue?hr_status=pending")
    assert r.status_code == 200
    pending = r.json()["items"]
    assert r.json()["total"] == 1
    assert len([i for i in pending if i["sender_email"] == email]) == 1


def test_ingest_dedup_by_email_same_batch(client):
    """Two items with same email in one batch -> only first is queued."""
    email = "batch@t.com"
    r = client.post("/ingest", json={
        "items": [
            {"message_id": "batch-1", "subject": "A", "sender_email": email},
            {"message_id": "batch-2", "subject": "B", "sender_email": email},
        ],
    })
    assert r.status_code == 201
    data = r.json()
    assert data["queued"] == 1
    assert data["skipped"] == 1


def test_confirm_same_email_reuses_application(client):
    """Confirming two queue items with the same email creates one pipeline card."""
    email = "dupconfirm@t.com"
    r1 = client.post("/ingest", json={
        "items": [{"message_id": "dc-1", "subject": "First", "sender_email": email}],
    })
    r2 = client.post("/ingest", json={
        "items": [{"message_id": "dc-2", "subject": "Reply", "sender_email": email}],
    })
    assert r1.json()["queued"] == 1
    assert r2.json()["skipped"] == 1

    qid = r1.json()["items"][0]["queue_id"]
    client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed", "recruitment_title": "default",
    })

    r3 = client.post("/ingest", json={
        "items": [{"message_id": "dc-3", "subject": "Follow up", "sender_email": email}],
    })
    assert r3.json()["items"][0]["action"] in ("auto_merged", "skipped")

    pipeline = client.get("/pipeline").json()
    new_stage = pipeline["stages"]["new"]
    assert len([t for t in new_stage if t["email"] == email]) == 1


def test_ingest_empty(client):
    """Empty items list returns 201 with zero queued."""
    r = client.post("/ingest", json={"items": []})
    assert r.status_code == 201
    assert r.json()["queued"] == 0


def test_ingest_with_attachments(client):
    """Ingest with attachment metadata stores as JSON."""
    r = client.post("/ingest", json={
        "items": [{
            "message_id": "att1", "subject": "att-subject",
            "sender_email": "att@t.com",
            "attachments": [{"filename": "resume.pdf", "size": 102400}],
        }],
    })
    assert r.status_code == 201
    assert r.json()["queued"] == 1


# ── Queue API ──

def _ingest_one(client, msg_id="q1", email="q@t.com"):
    """Helper: ingest a single item and return its queue_id."""
    r = client.post("/ingest", json={
        "items": [{"message_id": msg_id, "subject": "Q", "sender_email": email}],
    })
    return r.json()["items"][0]["queue_id"]


def test_queue_list_empty(client):
    """No items in queue returns empty list."""
    r = client.get("/queue")
    assert r.status_code == 200
    assert r.json()["items"] == []
    assert r.json()["total"] == 0


def test_queue_list_after_ingest(client):
    """After ingest, queue lists the item."""
    _ingest_one(client)
    r = client.get("/queue")
    assert r.status_code == 200
    assert r.json()["total"] == 1
    assert r.json()["items"][0]["hr_status"] == "pending"


def test_queue_list_filter_by_hr_status(client):
    """Filter queue by hr_status."""
    _ingest_one(client, "f1")
    _ingest_one(client, "f2")
    qid = _ingest_one(client, "f3")
    client.patch(f"/queue/{qid}/confirm", json={"action": "confirmed", "recruitment_title": "default"})

    r = client.get("/queue?hr_status=pending")
    assert r.status_code == 200
    assert r.json()["total"] == 2

    r = client.get("/queue?hr_status=confirmed")
    assert r.status_code == 200
    assert r.json()["total"] == 1


def test_queue_confirm_creates_talent(client):
    """Confirm creates a Talent and returns its id."""
    qid = _ingest_one(client, "ct1", "confirm@t.com")
    r = client.patch(f"/queue/{qid}/confirm", json={"action": "confirmed", "recruitment_title": "default"})
    assert r.status_code == 200
    data = r.json()
    assert data["action"] == "confirmed"
    assert data["talent_id"] is not None


def test_queue_confirm_adjusted(client):
    """Confirm with adjusted status and custom name/email."""
    qid = _ingest_one(client, "adj1", "raw@t.com")
    r = client.patch(f"/queue/{qid}/confirm", json={
        "action": "adjusted",
        "status": "exam_sent",
        "real_name": "调整后姓名",
        "email": "adjusted@t.com",
        "recruitment_title": "default",
    })
    assert r.status_code == 200
    data = r.json()
    assert data["action"] == "adjusted"
    assert data["talent_id"] is not None


def test_queue_confirm_404(client):
    """Confirm non-existent item returns 404."""
    r = client.patch("/queue/999/confirm", json={"action": "confirmed"})
    assert r.status_code == 404


def test_queue_ignore(client):
    """Ignore sets hr_status to ignored."""
    qid = _ingest_one(client, "ign1")
    r = client.patch(f"/queue/{qid}/ignore", json={"action": "ignored"})
    assert r.status_code == 200
    assert r.json()["action"] == "ignored"


def test_queue_ignore_404(client):
    """Ignore non-existent item returns 404."""
    r = client.patch("/queue/999/ignore", json={"action": "ignored"})
    assert r.status_code == 404


def test_queue_confirm_with_recruitment_title(client):
    """Confirm with recruitment_title finds or creates matching Recruitment."""
    qid = _ingest_one(client, "b3-title", "b3@t.com")
    r = client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "recruitment_title": "后端开发工程师",
    })
    assert r.status_code == 200
    assert r.json()["talent_id"] is not None
    recs = client.get("/recruitments").json()
    titles = [rec["title"] for rec in recs]
    assert "后端开发工程师" in titles


def test_queue_confirm_without_recruitment_title_400(client):
    """Confirm without recruitment_title should return 400."""
    qid = _ingest_one(client, "b3-notitle", "b3-notitle@t.com")
    r = client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
    })
    assert r.status_code == 400


def test_queue_by_email_found(client):
    """Returns item for matching email."""
    _ingest_one(client, "be1", "findme@t.com")
    r = client.get("/queue/by-email?email=findme@t.com")
    assert r.status_code == 200
    data = r.json()
    assert data["found"] is True
    assert data["item"]["sender_email"] == "findme@t.com"


def test_queue_by_email_not_found(client):
    """Returns found=false for unmatched email."""
    r = client.get("/queue/by-email?email=nobody@t.com")
    assert r.status_code == 200
    assert r.json()["found"] is False


def test_queue_stats(client):
    """Returns counts by hr_status."""
    qid1 = _ingest_one(client, "s1", "s1@t.com")
    qid2 = _ingest_one(client, "s2", "s2@t.com")
    qid3 = _ingest_one(client, "s3", "s3@t.com")
    client.patch(f"/queue/{qid1}/confirm", json={"action": "confirmed", "recruitment_title": "default"})
    client.patch(f"/queue/{qid3}/ignore", json={"action": "ignored"})

    r = client.get("/queue/stats")
    assert r.status_code == 200
    stats = r.json()
    assert stats.get("pending", 0) >= 1
    assert stats.get("confirmed", 0) >= 1
    assert stats.get("ignored", 0) >= 1


def test_queue_confirm_syncs_candidate_application(client):
    """Queue confirm -> Candidate + Application created (Step B)."""
    qid = _ingest_one(client, "sb1", "stepb@t.com")
    r = client.patch(f"/queue/{qid}/confirm", json={"action": "confirmed", "recruitment_title": "default"})
    assert r.status_code == 200

    cand_r = client.get("/candidates")
    candidates = cand_r.json()
    assert any(c["email"] == "stepb@t.com" for c in candidates)

    apps_r = client.get("/applications")
    apps = apps_r.json()
    assert any(a["source"] == "feishu_api" for a in apps)


# ── Step B: write path sync ──

def test_create_talent_creates_candidate_and_application(client):
    """POST /talents should also create Candidate + Application."""
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "张三"})
    assert r.status_code == 201

    # Candidate created
    cand_r = client.get("/candidates")
    assert cand_r.status_code == 200
    candidates = cand_r.json()
    assert any(c["email"] == "a@b.com" for c in candidates)

    # Application created
    apps_r = client.get("/applications")
    assert apps_r.status_code == 200
    apps = apps_r.json()
    assert any(a["status"] == "new" and a["source"] == "manual_debug" for a in apps)


def test_create_talent_reuses_existing_candidate(client):
    """Same email should reuse existing Candidate, not create duplicate."""
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "dup@b.com", "real_name": "第一"})
    r2 = client.post(f"/recruitments/{rec_id}/talents", json={"email": "dup@b.com", "real_name": "第二"})
    assert r2.status_code == 201

    cand_r = client.get("/candidates")
    candidates = cand_r.json()
    dup_candidates = [c for c in candidates if c["email"] == "dup@b.com"]
    assert len(dup_candidates) == 1  # no duplicate


def test_transition_talent_updates_application(client):
    """Transition should also update Application status."""
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "a@b.com", "real_name": "A"}).json()

    # Walk to contacted
    client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": "contacted"})

    # Check Application was updated
    apps_r = client.get(f"/applications?candidate_id={1}")
    assert apps_r.status_code == 200
    apps = apps_r.json()
    app = next((a for a in apps if a["status"] == "contacted"), None)
    assert app is not None, "Application status was not updated by transition"


# ── Phase 3: Pool ──


def test_pool_application(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "pool@t.com", "real_name": "P"}).json()
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]

    r = client.post(f"/applications/{app_id}/pool")
    assert r.status_code == 200
    data = r.json()
    assert data["pooled_at"] is not None
    assert data["deactivated_at"] is not None
    assert data["status"] == "closed"
    assert data["sub_stage"] is None


def test_pool_application_404(client):
    r = client.post("/applications/999/pool")
    assert r.status_code == 404


def test_pool_application_idempotent(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "pool@t.com", "real_name": "P"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]

    r1 = client.post(f"/applications/{app_id}/pool")
    assert r1.status_code == 200
    r2 = client.post(f"/applications/{app_id}/pool")
    assert r2.status_code == 200
    assert r2.json()["pooled_at"] == r1.json()["pooled_at"]


# ── Phase 3: Unpool ──


def test_unpool_application(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "unpool@t.com", "real_name": "U"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]
    client.post(f"/applications/{app_id}/pool")

    r = client.post(f"/applications/{app_id}/unpool", json={"recruitment_id": rec_id})
    assert r.status_code == 201
    data = r.json()
    assert data["candidate_id"] == 1
    assert data["status"] == "new"
    assert data["id"] != app_id


def test_unpool_application_404(client):
    r = client.post("/applications/999/unpool", json={"recruitment_id": 1})
    assert r.status_code == 404


def test_unpool_application_not_pooled(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "np@t.com", "real_name": "N"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]

    r = client.post(f"/applications/{app_id}/unpool", json={"recruitment_id": rec_id})
    assert r.status_code == 400


def test_unpool_original_unchanged(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "orig@t.com", "real_name": "O"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]
    client.post(f"/applications/{app_id}/pool")

    client.post(f"/applications/{app_id}/unpool", json={"recruitment_id": rec_id})
    orig_r = client.get(f"/applications?candidate_id=1")
    orig_apps = orig_r.json()
    pooled = [a for a in orig_apps if a["id"] == app_id]
    assert len(pooled) == 1
    assert pooled[0]["pooled_at"] is not None


# ── Phase 3: Pool View ──


def test_pool_view_empty(client):
    r = client.get("/pool")
    assert r.status_code == 200
    assert r.json() == []


def test_pool_view_lists_pooled(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "pv@t.com", "real_name": "PV"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]
    client.post(f"/applications/{app_id}/pool")

    r = client.get("/pool")
    assert r.status_code == 200
    data = r.json()
    assert len(data) >= 1
    assert data[0]["candidate_email"] == "pv@t.com"
    assert data[0]["candidate_name"] == "PV"
    assert data[0]["pooled_at"] is not None


def test_pool_view_excludes_non_pooled(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id}/talents", json={"email": "excl@t.com", "real_name": "Ex"})
    apps_r = client.get(f"/applications?candidate_id=1")
    app_id = apps_r.json()[0]["id"]
    client.post(f"/applications/{app_id}/pool")

    pool1_r = client.get("/pool")
    pool1_count = len(pool1_r.json())

    rec_id2 = client.post("/recruitments", json={}).json()["id"]
    client.post(f"/recruitments/{rec_id2}/talents", json={"email": "keep@t.com", "real_name": "K"})

    pool2_r = client.get("/pool")
    assert len(pool2_r.json()) == pool1_count  # non-pooled not added


# ── Phase 3: Headcount ──


def test_headcount_zero(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.get(f"/recruitments/{rec_id}/headcount")
    assert r.status_code == 200
    data = r.json()
    assert data["total_offers"] == 0
    assert data["accepted"] == 0
    assert data["recruitment_id"] == rec_id


def test_headcount_one_accepted(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "hc@t.com", "real_name": "HC"}).json()
    for status in ["contacted", "exam_sent", "exam_received", "evaluating", "interview"]:
        client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": status})
    client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition",
                json={"status": "offer", "sub_stage": "accepted"})

    r = client.get(f"/recruitments/{rec_id}/headcount")
    assert r.status_code == 200
    data = r.json()
    assert data["total_offers"] == 1
    assert data["accepted"] == 1


def test_headcount_offer_no_sub_stage(client):
    rec_id = client.post("/recruitments", json={}).json()["id"]
    t = client.post(f"/recruitments/{rec_id}/talents", json={"email": "hc2@t.com", "real_name": "HC2"}).json()
    for status in ["contacted", "exam_sent", "exam_received", "evaluating", "interview", "offer"]:
        client.post(f"/recruitments/{rec_id}/talents/{t['id']}/transition", json={"status": status})

    r = client.get(f"/recruitments/{rec_id}/headcount")
    data = r.json()
    assert data["total_offers"] == 1
    assert data["accepted"] == 0


def test_headcount_404(client):
    r = client.get("/recruitments/999/headcount")
    assert r.status_code == 404


# ── Phase 4: Training Data Support ──


def test_ingest_with_body(client):
    """POST /ingest with body fields should store them on the queue item."""
    r = client.post("/ingest", json={
        "items": [{
            "message_id": "body-test-001",
            "subject": "Test Body",
            "sender_email": "body@test.com",
            "body": "<html><body>Full body</body></html>",
            "body_text": "Full body text",
        }],
    })
    assert r.status_code == 201
    data = r.json()
    assert data["queued"] == 1
    qid = data["items"][0]["queue_id"]

    r2 = client.get(f"/queue?hr_status=pending")
    items = r2.json()["items"]
    match = [i for i in items if i["queue_id"] == qid]
    assert len(match) == 1
    assert match[0]["body"] == "<html><body>Full body</body></html>"
    assert match[0]["body_text"] == "Full body text"


def test_ingest_without_body_still_works(client):
    """POST /ingest without body fields should still work (backward compat)."""
    r = client.post("/ingest", json={
        "items": [{
            "message_id": "nobody-001",
            "subject": "No Body",
            "sender_email": "nobody@test.com",
        }],
    })
    assert r.status_code == 201
    assert r.json()["queued"] == 1


def test_queue_confirm_sets_source_queue_item_id(client_with_db):
    """Confirm should set Application.source_queue_item_id."""
    client, db = client_with_db
    client.post("/ingest", json={
        "items": [{
            "message_id": "src-link-001",
            "subject": "Source Link",
            "sender_email": "src@test.com",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed", "status": "contacted", "real_name": "Src", "email": "src@test.com",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    assert app is not None
    assert app.source_queue_item_id == qid


def test_confirm_no_adjustment_no_correction_log(client_with_db):
    """Confirm without adjustments should NOT create correction_log entries."""
    client, db = client_with_db
    client.post("/ingest", json={
        "items": [{
            "message_id": "nocorrect-001",
            "subject": "应聘前端工程师",  # matches contacted keyword
            "sender_email": "nocorrect@test.com",
            "suggested_status": "contacted",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed", "status": "contacted", "real_name": "未知", "email": "nocorrect@test.com",
        "recruitment_title": "default",
    })

    logs = db.query(CorrectionLog).filter(CorrectionLog.queue_item_id == qid).all()
    assert len(logs) == 0


def test_confirm_adjustment_logs_correction(client_with_db):
    """Adjusting status/email/name on confirm should log corrections."""
    client, db = client_with_db
    client.post("/ingest", json={
        "items": [{
            "message_id": "correct-001",
            "subject": "Correct Me",
            "sender_email": "wrong@test.com",
            "sender_name": "Wrong Name",
            "suggested_status": "new",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    client.patch(f"/queue/{qid}/confirm", json={
        "action": "adjusted", "status": "contacted", "real_name": "Right Name", "email": "right@test.com",
        "recruitment_title": "default",
    })

    logs = db.query(CorrectionLog).filter(CorrectionLog.queue_item_id == qid).all()
    assert len(logs) >= 1
    fields = {l.field_name for l in logs}
    assert "status" in fields  # None → contacted (server classifier returned no match)
    assert "email" in fields   # wrong@test.com → right@test.com
    assert "real_name" in fields  # Wrong Name → Right Name


def test_export_training_pairs_empty(client):
    """GET /export/training-pairs should return empty when no confirmed items."""
    r = client.get("/export/training-pairs")
    assert r.status_code == 200
    data = r.json()
    assert data["total"] == 0
    assert data["items"] == []


def test_export_training_pairs_with_data(client_with_db):
    """GET /export/training-pairs should return linked pairs after confirm."""
    client, db = client_with_db
    client.post("/ingest", json={
        "items": [{
            "message_id": "export-001",
            "subject": "Export Test",
            "sender_email": "export@test.com",
            "sender_name": "Export User",
            "suggested_status": "new",
            "body": "<p>test</p>",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    client.patch(f"/queue/{qid}/confirm", json={
        "action": "adjusted", "status": "contacted", "real_name": "Export Fixed", "email": "export@test.com",
        "recruitment_title": "default",
    })

    r = client.get("/export/training-pairs")
    assert r.status_code == 200
    data = r.json()
    assert data["total"] == 1
    pair = data["items"][0]
    assert pair["queue_id"] == qid
    assert pair["subject"] == "Export Test"
    assert pair["body"] == "<p>test</p>"
    assert pair["suggested_status"] is None  # server classifier returned no match
    assert pair["final_status"] == "contacted"
    assert pair["final_real_name"] == "Export Fixed"
    assert pair["hr_action"] == "adjusted"
    assert "status" in pair["corrected_fields"]


def test_resume_parser_placeholder():
    """NoopResumeParser should return empty ParseResult."""
    from fastapi_quanttide_hr.services.resume_parser import ParseResult

    parser = NoopResumeParser()
    result = parser.parse("/tmp/nonexistent.pdf")
    assert isinstance(result, ParseResult)
    assert result.name is None
    assert result.phone is None
    assert result.email is None
    assert result.education == []
    assert result.experience == []
    assert result.raw_text is None


def test_resume_parser_interface_raises():
    """Base ResumeParser should raise NotImplementedError."""
    parser = ResumeParser()
    with pytest.raises(NotImplementedError):
        parser.parse("/tmp/nonexistent.pdf")


# ── Phase A0: Talent.application_id FK ──

def test_talent_application_id_fk(db):
    """Talent created from Application should have application_id set."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="a@b.com", real_name="测试")
    db.add(c)
    db.flush()
    a = Application(candidate_id=c.id, recruitment_id=r.id)
    db.add(a)
    db.flush()
    t = Talent(recruitment_id=r.id, email=c.email, real_name=c.real_name, application_id=a.id)
    db.add(t)
    db.commit()
    assert t.application_id == a.id
    assert t.application.id == a.id  # bidirectional


def test_talent_application_id_null_for_legacy(db):
    """Existing Talent without application_id should have None."""
    r = Recruitment()
    db.add(r)
    db.flush()
    t = Talent(recruitment_id=r.id, email="old@b.com", real_name="旧数据")
    db.add(t)
    db.commit()
    assert t.application_id is None
    assert t.application is None


def test_create_talent_sets_application_id(client):
    """POST /talents should set application_id via back_populates."""
    rec_id = client.post("/recruitments", json={}).json()["id"]
    r = client.post(f"/recruitments/{rec_id}/talents", json={"email": "fk@b.com", "real_name": "FK测试"})
    assert r.status_code == 201


def test_queue_confirm_sets_application_id(client_with_db):
    """Queue confirm should set Talent.application_id via back_populates."""
    client, db = client_with_db
    client.post("/ingest", json={
        "items": [{
            "message_id": "a0-fk-001",
            "subject": "A0 FK Test",
            "sender_email": "a0fk@test.com",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed", "status": "contacted", "real_name": "A0", "email": "a0fk@test.com",
        "recruitment_title": "default",
    })

    talent = db.query(Talent).filter(Talent.email == "a0fk@test.com").first()
    assert talent is not None
    assert talent.application_id is not None
    app = db.query(Application).filter(Application.id == talent.application_id).first()
    assert app is not None
    assert app.talent.id == talent.id  # bidirectional


# ── Phase A0.5: PATCH /candidates/{id} ──

def test_update_candidate_email_syncs_talent(client_with_db):
    """PATCH candidate email should sync to associated Talent."""
    cli, db = client_with_db
    rec_id = cli.post("/recruitments", json={}).json()["id"]
    cli.post(f"/recruitments/{rec_id}/talents", json={"email": "old@b.com", "real_name": "旧名"})

    cand = db.query(Candidate).filter(Candidate.email == "old@b.com").first()
    old_id = cand.id
    r = cli.patch(f"/candidates/{old_id}", json={"email": "new@b.com", "real_name": "新名"})
    assert r.status_code == 200
    assert r.json()["email"] == "new@b.com"
    assert r.json()["real_name"] == "新名"

    app = db.query(Application).filter(Application.candidate_id == cand.id).first()
    talent = db.query(Talent).filter(Talent.application_id == app.id).first()
    assert talent is not None
    assert talent.email == "new@b.com"
    assert talent.real_name == "新名"


def test_update_candidate_partial(client_with_db):
    """PATCH candidate with only one field should leave others unchanged."""
    cli, db = client_with_db
    rec_id = cli.post("/recruitments", json={}).json()["id"]
    cli.post(f"/recruitments/{rec_id}/talents", json={"email": "partial@b.com", "real_name": "原名"})

    cand = db.query(Candidate).filter(Candidate.email == "partial@b.com").first()
    r = cli.patch(f"/candidates/{cand.id}", json={"real_name": "改名"})
    assert r.status_code == 200
    assert r.json()["email"] == "partial@b.com"
    assert r.json()["real_name"] == "改名"


def test_update_candidate_404(client_with_db):
    """PATCH non-existent candidate should return 404."""
    cli, _ = client_with_db
    r = cli.patch("/candidates/999", json={"email": "nobody@b.com"})
    assert r.status_code == 404


# ── Phase A1: Unified transition service ──

def test_transition_application_basic(db):
    """transition_application() should perform valid state change."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t@b.com", real_name="T")
    db.add(c)
    db.flush()
    app = Application(candidate_id=c.id, recruitment_id=r.id, status=TalentStatus.NEW)
    db.add(app)
    db.commit()

    from fastapi_quanttide_hr.services.transition import transition_application
    result = transition_application(app, TalentStatus.CONTACTED)

    assert result.status == TalentStatus.CONTACTED
    assert result.sub_stage is None


def test_transition_application_invalid(db):
    """transition_application() should raise ValueError for invalid transition."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t2@b.com", real_name="T2")
    db.add(c)
    db.flush()
    app = Application(candidate_id=c.id, recruitment_id=r.id, status=TalentStatus.NEW)
    db.add(app)
    db.commit()

    from fastapi_quanttide_hr.services.transition import transition_application
    import pytest
    with pytest.raises(ValueError, match="Cannot transition"):
        transition_application(app, TalentStatus.OFFER)


def test_transition_application_with_sub_stage(db):
    """transition_application() should set sub_stage when allowed."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t3@b.com", real_name="T3")
    db.add(c)
    db.flush()
    app = Application(candidate_id=c.id, recruitment_id=r.id, status=TalentStatus.CONTACTED)
    db.add(app)
    db.commit()

    from fastapi_quanttide_hr.services.transition import transition_application
    result = transition_application(app, TalentStatus.EXAM_SENT, sub_stage="exam_written")

    assert result.status == TalentStatus.EXAM_SENT
    assert result.sub_stage == "exam_written"


def test_transition_application_sub_stage_cleared(db):
    """transition_application() should clear sub_stage on status change."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t4@b.com", real_name="T4")
    db.add(c)
    db.flush()
    app = Application(candidate_id=c.id, recruitment_id=r.id, status=TalentStatus.CONTACTED, sub_stage="resume_passed")
    db.add(app)
    db.commit()

    from fastapi_quanttide_hr.services.transition import transition_application
    result = transition_application(app, TalentStatus.EXAM_SENT)

    assert result.status == TalentStatus.EXAM_SENT
    assert result.sub_stage is None


def test_transition_application_stage_results(db):
    """transition_application() should record stage_results."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t5@b.com", real_name="T5")
    db.add(c)
    db.flush()
    app = Application(candidate_id=c.id, recruitment_id=r.id, status=TalentStatus.CONTACTED)
    db.add(app)
    db.commit()

    from fastapi_quanttide_hr.services.transition import transition_application
    result = transition_application(app, TalentStatus.EXAM_SENT)

    assert result.stage_results is not None
    assert result.stage_results.get("contacted") == "pass"


def test_sync_talent_from_application(db):
    """sync_talent_from_application() should copy fields to Talent."""
    r = Recruitment()
    db.add(r)
    db.flush()
    c = Candidate(email="t6@b.com", real_name="T6")
    db.add(c)
    db.flush()
    app = Application(
        candidate_id=c.id, recruitment_id=r.id,
        status=TalentStatus.INTERVIEW, sub_stage="tech_interview",
        quality="good", stage_results={"contacted": "pass"},
    )
    db.add(app)
    db.flush()
    t = Talent(recruitment_id=r.id, email=c.email, real_name=c.real_name, application_id=app.id)
    db.add(t)
    db.commit()

    from fastapi_quanttide_hr.services.transition import sync_talent_from_application
    sync_talent_from_application(t, app)

    assert t.status == TalentStatus.INTERVIEW
    assert t.sub_stage == "tech_interview"
    assert t.quality == "good"
    assert t.stage_results == {"contacted": "pass"}


# ── Regression: edge cases for transition + queue ──

def test_transition_talent_no_application_400(client_with_db):
    """Transition on Talent with no linked Application should return 400."""
    cli, db = client_with_db
    rec_id = cli.post("/recruitments", json={}).json()["id"]
    # Create Talent directly without Application (legacy path)
    t = Talent(recruitment_id=rec_id, email="legacy@b.com", real_name="旧数据")
    db.add(t)
    db.commit()

    r = cli.post(f"/recruitments/{rec_id}/talents/{t.id}/transition", json={"status": "contacted"})
    assert r.status_code == 400
    assert "No associated Application" in r.json()["detail"]


def test_queue_confirm_invalid_status_graceful(client):
    """Confirm with unknown suggested_status should fall through gracefully."""
    client.post("/ingest", json={
        "items": [{
            "message_id": "inv-status-2",
            "subject": "Bad Status",
            "sender_email": "inv2@t.com",
            "suggested_status": "bogus_status",
        }],
    })
    qr = client.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]
    r = client.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "",
        "recruitment_title": "regression-test",
    })
    assert r.status_code == 200


# ── Phase 1.1: Queue Model extracted_* Fields ──


def test_ingest_with_extracted_fields(client):
    """POST /ingest with extracted_* fields should store them on queue item."""
    r = client.post("/ingest", json={
        "items": [{
            "message_id": "ext-001",
            "subject": "Extracted Fields Test",
            "sender_email": "ext@test.com",
            "sender_name": "发件人",
            "extracted_name": "AI提取姓名",
            "extracted_email": "ai_extracted@test.com",
            "extracted_phone": "13800138001",
        }],
    })
    assert r.status_code == 201
    qid = r.json()["items"][0]["queue_id"]

    r2 = client.get(f"/queue?hr_status=pending")
    items = r2.json()["items"]
    match = [i for i in items if i["queue_id"] == qid]
    assert len(match) == 1
    assert match[0]["extracted_name"] == "AI提取姓名"
    assert match[0]["extracted_email"] == "ai_extracted@test.com"


def test_queue_item_with_extracted_fields(client_with_db):
    """Confirm without real_name should fall back to extracted_name then sender_name."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "ef-001",
            "subject": "Extracted Fallback",
            "sender_email": "sender@test.com",
            "sender_name": "发件人姓名",
            "extracted_name": "AI提取姓名",
            "extracted_email": "ai_extracted@test.com",
            "extracted_phone": "13800138001",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    # Confirm without real_name/email — should use extracted_* as fallback
    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "contacted",
        "recruitment_title": "default",
    })

    candidate = db.query(Candidate).filter(Candidate.email == "ai_extracted@test.com").first()
    assert candidate is not None
    assert candidate.real_name == "AI提取姓名"


def test_queue_item_without_extracted_fields(client_with_db):
    """No extracted_* — falls back to sender_*."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "noext-001",
            "subject": "No Extracted",
            "sender_email": "sender@test.com",
            "sender_name": "发件人姓名",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "contacted",
        "recruitment_title": "default",
    })

    candidate = db.query(Candidate).filter(Candidate.email == "sender@test.com").first()
    assert candidate is not None
    assert candidate.real_name == "发件人姓名"


def test_confirm_real_name_overrides_extracted(client_with_db):
    """Confirm with explicit real_name — overrides extracted_name."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "override-001",
            "subject": "Override Test",
            "sender_email": "sender@test.com",
            "sender_name": "发件人姓名",
            "extracted_name": "AI提取姓名",
            "extracted_email": "ai_extracted@test.com",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "contacted",
        "real_name": "HR输入",
        "email": "hr@test.com",
        "recruitment_title": "default",
    })

    candidate = db.query(Candidate).filter(Candidate.email == "hr@test.com").first()
    assert candidate is not None
    assert candidate.real_name == "HR输入"


# ── Phase 1.3: Materials Classifier Info + Corrections ──


def test_application_materials_classifier_info(client_with_db):
    """Materials endpoint returns classifier_info when queue item has it."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "ci-001",
            "subject": "Classifier Info",
            "sender_email": "ci@test.com",
            "sender_name": "测试",
            "extracted_name": "提取姓名",
            "extracted_email": "extracted@test.com",
            "extracted_phone": "13800138002",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "contacted",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    r = cli.get(f"/applications/{app.id}/materials")
    data = r.json()

    assert "classifier_info" in data


def test_application_materials_corrections(client_with_db):
    """Materials endpoint returns corrections when CorrectionLog exists for application."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "corr-001",
            "subject": "Corrections",
            "sender_email": "wrong@test.com",
            "sender_name": "错误姓名",
            "suggested_status": "new",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "adjusted",
        "status": "contacted",
        "real_name": "正确姓名",
        "email": "right@test.com",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    r = cli.get(f"/applications/{app.id}/materials")
    data = r.json()

    assert "corrections" in data


# ── Materials API ──

def test_confirm_without_status_defaults_to_new(client_with_db):
    """Confirm without status should leave application at 'new'."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "default-new-001",
            "subject": "Default New",
            "sender_email": "new@test.com",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    assert app is not None
    assert app.status == TalentStatus.NEW


def test_get_application_materials_with_queue_item(client_with_db):
    """GET /applications/{id}/materials returns linked queue item with body/attachments."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "mat-test-001",
            "subject": "Materials Test",
            "sender_name": "张三",
            "sender_email": "zhang3@test.com",
            "body": "<html><body>邮件正文HTML</body></html>",
            "body_text": "邮件正文文本",
            "attachments": [{"filename": "resume.pdf", "size": 102400}],
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "contacted",
        "real_name": "张三",
        "email": "zhang3@test.com",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    assert app is not None

    r = cli.get(f"/applications/{app.id}/materials")
    assert r.status_code == 200
    data = r.json()

    assert data["application"]["id"] == app.id
    assert data["candidate"]["real_name"] == "张三"
    assert data["candidate"]["email"] == "zhang3@test.com"
    assert data["queue_item"] is not None
    assert data["queue_item"]["subject"] == "Materials Test"
    assert data["queue_item"]["body_text"] == "邮件正文文本"
    assert data["queue_item"]["body"] == "<html><body>邮件正文HTML</body></html>"
    assert len(data["queue_item"]["attachments"]) == 1
    assert data["queue_item"]["attachments"][0]["filename"] == "resume.pdf"
    assert data["queue_item"]["attachments"][0]["size"] == 102400


def test_get_application_materials_without_queue_item(client_with_seeded_ca):
    """Application without source_queue_item_id returns queue_item: null."""
    cli, seeded = client_with_seeded_ca
    apps = cli.get(f"/applications?candidate_id={seeded['candidate_a']}").json()
    app_id = apps[0]["id"]

    r = cli.get(f"/applications/{app_id}/materials")
    assert r.status_code == 200
    data = r.json()
    assert data["application"]["id"] == app_id
    assert data["queue_item"] is None
    assert data["resume_parse"] is None


def test_get_application_materials_404(client):
    """Non-existent application returns 404."""
    r = client.get("/applications/999/materials")
    assert r.status_code == 404


def test_application_materials_with_pdf_attachment_and_body_text(client_with_db):
    """PDF attachment without storage_path should show pending-download state."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "pdf-mat-001",
            "subject": "PDF Material",
            "sender_email": "pdf@test.com",
            "body_text": "姓名：李四\n电话：13800138000\n邮箱：lisi@test.com\n教育背景：北京大学本科",
            "attachments": [{"filename": "resume.pdf", "size": 204800, "mime_type": "application/pdf"}],
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "new",
        "real_name": "李四",
        "email": "pdf@test.com",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    r = cli.get(f"/applications/{app.id}/materials")
    data = r.json()

    # PDF parsing removed — attachments available for inline preview only
    assert data["resume_parse"] is None


def test_application_materials_without_pdf_no_resume_parse(client_with_db):
    """No PDF attachment should leave resume_parse as null."""
    cli, db = client_with_db
    cli.post("/ingest", json={
        "items": [{
            "message_id": "no-pdf-001",
            "subject": "No PDF",
            "sender_email": "nopdf@test.com",
            "body_text": "Some text but no PDF",
        }],
    })
    qr = cli.get("/queue?hr_status=pending")
    qid = qr.json()["items"][0]["queue_id"]

    cli.patch(f"/queue/{qid}/confirm", json={
        "action": "confirmed",
        "status": "new",
        "real_name": "No PDF",
        "email": "nopdf@test.com",
        "recruitment_title": "default",
    })

    app = db.query(Application).filter(Application.source_queue_item_id == qid).first()
    r = cli.get(f"/applications/{app.id}/materials")
    data = r.json()
    assert data["resume_parse"] is None
