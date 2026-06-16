# Human Module Changelog

> QtCloud HR — 招聘人力资源模块（human）功能更新日志，从 v0 开始记录。

---

## v0.1.0 — Domain Models & Screening Engine (Dart)

Initial domain logic library, pure Dart with zero Flutter dependency.

### Added

- **Recruitment Screening** (`packages/dart/lib/src/models/recruitment.dart`)
  - `Resume`, `JobPosition`, `ScreeningRules`, `ScreeningResult` models
  - `Decision` enum: `pass`, `priority`, `reject`
  - `EducationLevel` enum: `high_school`, `associate`, `bachelor`, `master`, `doctorate`
- **Screening Service** (`packages/dart/lib/src/services/recruitment_service.dart`)
  - `RecruitmentService.screen(Resume, JobPosition) → ScreeningResult`
  - Three-outcome decision logic: education, experience, required skills
  - Hard requirements must all be met for `pass`; bonus skills elevate to `priority`
- **Compensation Calculation** (`packages/dart/lib/src/models/compensation.dart`)
  - `CompensationParams`, `CompensationResult`, `CompensationRuleConfig` models
  - Non-negative validation via `assert`
- **Compensation Service** (`packages/dart/lib/src/services/compensation_service.dart`)
  - `CompensationService.calculate(CompensationParams) → CompensationResult`
  - Formula: `netSalary = baseSalary + overtimePay + performanceBonus - deductions`
  - Configurable overtime multiplier and performance bonus ratio
- **Tests** (`packages/dart/test/`)
  - Full test coverage for recruitment screening and compensation services

---

## v0.2.0 — FastAPI Backend: Talent Pipeline

First backend release with SQLAlchemy + SQLite, focusing on talent lifecycle management.

### Added

- **Database** (`packages/fastapi/src/fastapi_quanttide_hr/database.py`)
  - `DeclarativeBase`, `get_db` dependency (abstract — must be overridden by app)
- **Talent Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/talent.py`)
  - 8-state state machine: `NEW -> CONTACTED -> EXAM_SENT -> EXAM_RECEIVED -> EVALUATING -> INTERVIEW -> OFFER -> CLOSED`
  - Strict `STATUS_TRANSITIONS` dict enforcing valid transitions
- **Recruitment Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/recruitment.py`)
  - Basic recruitment entity with title
- **Talent Schemas** (`packages/fastapi/src/fastapi_quanttide_hr/schemas/talent.py`)
  - `TalentCreate`, `TalentRead`, `TalentUpdate`, `TalentTransition`
- **Recruitment Schemas** (`packages/fastapi/src/fastapi_quanttide_hr/schemas/recruitment.py`)
  - `RecruitmentCreate`, `RecruitmentRead`
- **Recruitment Routers** (`packages/fastapi/src/fastapi_quanttide_hr/routers/recruitments.py`)
  - CRUD: list, create, get recruitments
  - Talent CRUD: list/create talents under recruitment
  - Talent transition with state validation
- **Pipeline Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/pipeline.py`)
  - Aggregated pipeline view grouped by status
- **Pipeline Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/pipeline.py`)
  - `get_pipeline()` query logic with `_talent_to_card` mapping
- **Seed Data** (`packages/fastapi/src/fastapi_quanttide_hr/seed.py`)
  - `DEMO_TALENTS` constant for demo/testing
- **Tests** (`packages/fastapi/tests/test_lib.py`)
  - Full model, schema, service, and API test suite

---

## v0.3.0 — Email Screening Gateway

Added pending email queue, classifier, and mail ingestion — the recruitment email screening gateway.

### Added

- **Pending Queue Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/pending_queue.py`)
  - `PendingQueueItem` with email metadata, attachments, extracted fields, classifier results
- **Pending Queue Schemas** (`packages/fastapi/src/fastapi_quanttide_hr/schemas/pending_queue.py`)
  - `QueueItemRead`, `ConfirmRequest/Response`, `IgnoreRequest`, `IngestItem/Request/Response`
- **Queue Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/queue.py`)
  - List queue items (with dedup by email), confirm/ignore/adjust items
- **Ingest Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/ingest.py`)
  - Batch ingest emails, dedup by message_id, auto-match candidates
- **Classifier Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/classifier.py`)
  - Keyword-based rule classification for suggested status
- **AI Classifier Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/ai_classifier.py`)
  - LLM-powered classification with configurable provider/model
  - Fallback: keyword rules when AI unavailable
- **Email Matcher Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/email_matcher.py`)
  - `effective_email()`, `has_pending_queue_for_email()`, `match_by_email()`, `find_active_application()`
- **Transition Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/transition.py`)
  - Application/Talent dual-state management with sync
- **Example Provider App** (`packages/examples/provider/app.py`)
  - Full FastAPI app wiring example with dependency overrides

---

## v0.4.0 — Flutter Kanban UI (Pipeline + Queue + Pool)

First Flutter UI release — responsive kanban board for recruitment pipeline management.

### Added

- **App Shell** (`packages/flutter/lib/main.dart`)
  - `MaterialApp` with custom HR theme
  - `MainShell` responsive layout: `NavigationRail` (>600px) / `NavigationBar` (<=600px)
  - 3-tab navigation: Pipeline, Queue, Pool
  - `IndexedStack` for tab state preservation
- **Pipeline Screen** (`packages/flutter/lib/screens/pipeline_screen.dart`)
  - Kanban-style pipeline grouped by TalentStatus (new -> closed)
  - Candidate cards with name, email, sub-stage, wait-days badge
  - Wait-days color coding: yellow (7+), orange (14+)
  - Drag-and-drop status transitions
  - Candidate detail bottom sheet with email, attachments, timeline
- **Queue Screen** (`packages/flutter/lib/screens/queue_screen.dart`)
  - Pending email queue list with confidence badges
  - Confirm/ignore/adjust actions
  - Recruitment title assignment on confirm
- **Pool Screen** (`packages/flutter/lib/screens/pool_screen.dart`)
  - Pooled (reserve) candidate list
  - Unpool with recruitment reassignment
- **API Service** (`packages/flutter/lib/services/api_service.dart`)
  - Full REST client for all backend endpoints
  - Mutable `baseUrl` for runtime server switching
- **Widgets**
  - `StatusBadge`: Color-coded status pill using theme colors
  - `EmptyState`, `ErrorView`: Reusable state views
  - `InfoRow`: Label-value detail row

---

## v0.5.0 — Recruitment Applications + Materials

Replaced Talent-centric model with Application-centric architecture.

### Added

- **Application Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/application.py`)
  - `Application` entity linking Candidate + Recruitment
  - Pooling support (pooled_at timestamp)
  - Source queue item reference for traceability
- **Candidate Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/candidate.py`)
  - `Candidate` entity (name, email, phone)
  - Unique constraint on email
- **Application Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/applications.py`)
  - List applications with filters (status, candidate, recruitment, pooled)
  - Transition applications (status + sub-stage)
  - Pool/unpool applications
  - Get application materials (queue source, attachments, classifier info, corrections)
- **Candidate Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/candidates.py`)
  - CRUD: list, get, update candidates
  - Update syncs changes to associated talents
- **Material Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/material_service.py`)
  - Artifact management (by queue, by candidate)
- **Mail Message Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/mail_message.py`)
  - Full email thread tracking (inbound/outbound, send status, attachments)
- **Messages Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/messages.py`)
  - List messages by candidate/application
  - Timeline events
  - Reply-to-candidate
  - Outbox management with send status
  - Dead letter detection and requeue
- **Correction Log Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/correction_log.py`)
  - Field-level correction tracking
- **Application Materials (Flutter)** (`packages/flutter/lib/models/application_materials.dart`)
  - `ApplicationMaterials`, `QueueItemMaterials`, `AttachmentInfo`, `ResumeParseResult`, `CorrectionEntry`
- **Mail Message Models (Flutter)** (`packages/flutter/lib/models/mail_message.dart`)
  - `MailMessage`, `TimelineItem` with direction badges
- **Detail Panel** — Enhanced candidate detail in pipeline:
  - Email body display (HTML/text)
  - Clickable attachment preview via `url_launcher`
  - Classifier info (rule vs AI source)
  - Correction history
  - Message thread with direction indicators
  - Timeline with type-specific icons (transition/reply/note/system)
  - Reply dialog for outbound messages
- **Resume Parser Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/resume_parser.py`)
  - PDF/text resume parsing

---

## v0.6.0 — AI Configuration & Settings

Added AI provider configuration UI and server address management.

### Added

- **AI Config Model** (`packages/fastapi/src/fastapi_quanttide_hr/models/ai_config.py`)
  - Provider, model, API key, base URL, temperature, prompt template
- **AI Config Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/ai_config.py`)
  - GET/PUT config, test connection endpoint
- **Settings Screen** (Flutter) (`packages/flutter/lib/screens/settings_screen.dart`)
  - AI config form: provider dropdown, model, API key (obscured), URL, temperature slider, prompt template
  - Server URL field with inline save
  - Connection test with loading state
- **Theme System** (`packages/flutter/lib/theme/hr_theme.dart`)
  - `HrThemeExtension` (ThemeExtension): 8 status colors, spacing tokens, font tokens
  - `buildHrTheme()` — dark theme with `ColorScheme.dark`
  - `HrThemeContext` extension with `statusColor(String status)` lookup

---

## v0.7.0 — Headcount Planning & Export

### Added

- **Headcount Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/headcount.py`)
  - Headcount planning and tracking
- **Export Router** (`packages/fastapi/src/fastapi_quanttide_hr/routers/export.py`)
  - Data export endpoints
- **Export Service** (`packages/fastapi/src/fastapi_quanttide_hr/services/export.py`)
  - Export data generation
- **Export Schema** (`packages/fastapi/src/fastapi_quanttide_hr/schemas/export.py`)
  - Export request/response models

---

## v0.8.0 — Feishu/Lark Email Integration

### Added

- **Mail Reader** (`integrations/feishu/src/feishu_integration/mail_reader.py`)
  - Feishu mail API reader for ingesting recruitment emails
- **Mail Ingest Loop** (`integrations/feishu/src/feishu_integration/mail_ingest_loop.py`)
  - Polling loop: fetch -> classify -> ingest
- **Mail Sender** (`integrations/feishu/src/feishu_integration/mail_sender.py`)
  - Outbound mail via Feishu API
- **Mail Sender Loop** (`integrations/feishu/src/feishu_integration/mail_sender_loop.py`)
  - Outbox polling and sending loop
- **Pipeline Writer** (`integrations/feishu/src/feishu_integration/pipeline_writer.py`)
  - Write pipeline updates to Feishu documents
- **Feishu Classifier** (`integrations/feishu/src/feishu_integration/classifier.py`)
  - Feishu-specific classification integration
- **Tests** (`integrations/feishu/tests/`)
  - Classifier integration tests

---

## v0.9.0 — Admin CLI

### Added

- **CLI App** (`qtadmin-human-cli/src/qtadmin/cli.py`)
  - Command-line interface for HR operations
- **API Client** (`qtadmin-human-cli/src/qtadmin/api_client.py`)
  - HTTP client for all backend endpoints
- **Config** (`qtadmin-human-cli/src/qtadmin/config.py`)
  - Configuration management
- **Classifier** (`qtadmin-human-cli/src/qtadmin/classifier.py`)
  - Rule-based email classification
- **Mail Sender** (`qtadmin-human-cli/src/qtadmin/mail_sender.py`)
  - Outbound email sending via API
- **Lark Client** (`qtadmin-human-cli/src/qtadmin/lark_client.py`)
  - Feishu API integration
- **Tests** (`qtadmin-human-cli/tests/`)
  - Unit tests for CLI, API client, classifier, config, lark client
