---
repo: lucasastorian/llmwiki
---

# llmwiki Onboarding Report

## SYNOPSIS

### Implementation Identity

- **Observed:** `llmwiki` is a document workspace that compiles raw sources into a persistent wiki, exposed through both a human-facing web app and Claude-facing MCP tools rather than through a chat-only retrieval loop (`README.md`, `api/main.py`, `mcp/tools/guide.py`).
- **Observed:** The implementation is **dual-mode**:
  - **local mode**: filesystem + SQLite + stdio MCP + single-user synthetic auth (`api/main.py`, `shared/sqlite_schema.sql`, `mcp/local_server.py`)
  - **hosted mode**: Postgres + Supabase-style auth + S3 + TUS uploads + streamable HTTP MCP (`api/main.py`, `supabase/migrations/001_initial.sql`, `api/infra/tus.py`, `mcp/hosted.py`)
- **Observed:** The semantic center is the **document lifecycle**: ingest, extract, chunk, search, cite/link, and maintain wiki pages (`api/domain/local_processor.py`, `api/services/ocr.py`, `api/services/chunker.py`, `api/services/references.py`, `api/services/graph.py`, `mcp/tools/write.py`, `mcp/tools/read.py`, `mcp/tools/search.py`).
- **Inferred:** The repo is best understood as a **knowledge-compilation runtime** with two operator surfaces, not as a generic note app or generic RAG system.

### Quick Adaptation Assessment

- **Observed:** The code is structurally modular, but many changes must be mirrored across both the API service layer and the MCP `VaultFS` layer to keep local and hosted behavior aligned (`api/services/local.py`, `api/services/hosted.py`, `mcp/vaultfs/base.py`, `mcp/vaultfs/sqlite.py`, `mcp/vaultfs/postgres.py`).
- **Observed:** The most important extension seams are:
  - new file processing logic in `api/domain/local_processor.py` and `api/services/ocr.py`
  - new Claude behaviors in `mcp/tools/*.py`
  - new persistence/query behavior in `mcp/vaultfs/*.py`
- **Inferred:** Small UI tweaks are easy; cross-mode behavioral changes are moderate-to-high effort because persistence semantics are duplicated.

### Fastest Path to First Successful Run

**Manual local mode is the lowest-friction path.**

```bash
cd api
MODE=local WORKSPACE_PATH=/abs/workspace APP_URL=http://localhost:3000 API_URL=http://localhost:8000 uvicorn main:app --port 8000
```

```bash
cd web
NEXT_PUBLIC_MODE=local NEXT_PUBLIC_API_URL=http://localhost:8000 npm run dev
```

```bash
cd mcp
python -m local_server --workspace /abs/workspace
```

- **Observed:** This path matches the real entrypoints in `api/main.py`, `web/package.json`, and `mcp/local_server.py`.
- **Observed:** It avoids wrapper drift in `llmwiki`, which points at a missing schema path and an incorrect local MCP module path (`llmwiki`, `shared/sqlite_schema.sql`).

### Minimal Manual Setup Path

- **Required:** Python 3.11+, Node 20+, a workspace folder, API Python deps, web npm deps (`README.md`, `api/requirements.txt`, `web/package.json`).
- **Optional for richer local ingest:** LibreOffice for Office files and `MISTRAL_API_KEY` for better PDF OCR (`README.md`, `api/domain/local_processor.py`).
- **No meaningful extra infra is required for local mode.** SQLite is initialized automatically from `shared/sqlite_schema.sql`, and the workspace itself is the source of truth (`api/main.py`, `mcp/local_server.py`, `shared/sqlite_schema.sql`).

### Operational Complexity Snapshot

- **Setup complexity:** low in local mode, medium-to-high in hosted mode.
- **Runtime coordination complexity:** moderate; the system spans API, web UI, MCP server, indexing state, and reference graph maintenance.
- **Fragility:** hosted backend and MCP contracts are fairly mature; local wrapper/CLI and local SQLite parity have visible drift (`.github/workflows/test.yml`, `tests/integration/*`, `llmwiki`, `api/infra/db/sqlite.py`).
- **Debugging difficulty:** moderate. The semantic center is compact, but behavior is split across two persistence stacks and two product surfaces.
- **Observability maturity:** backend instrumentation hooks exist for Sentry/Logfire, but frontend has no test coverage and local-mode observability is lighter (`api/main.py`, `mcp/hosted.py`, `.github/workflows/test.yml`).

## 1. Repository Purpose

- **Observed:** The repository implements an LLM-maintained wiki over a document workspace. Users bring an existing folder of PDFs, notes, HTML, spreadsheets, images, or office files; the system indexes them, exposes them to Claude via MCP, and stores wiki pages under `/wiki/` (`README.md`, `api/routes/local_upload.py`, `mcp/tools/guide.py`).
- **Observed:** Raw sources are treated as durable inputs, while the wiki is treated as a compiled artifact Claude can create and revise (`README.md`, `mcp/tools/guide.py`, `mcp/tools/write.py`).
- **Relationship to the concept:** The implementation matches Karpathy’s “persistent wiki between user and raw documents” idea closely, but specializes it into:
  1. a **local-first single-workspace tool**, and
  2. a **hosted multi-tenant service** with auth, quotas, and cloud storage.
- **Actual problem solved:** reducing manual upkeep of a research/personal knowledge base by making ingestion, cross-linking, citation, and wiki maintenance machine-operable.
- **Scope boundaries:**
  - **Implemented:** ingest/index/search/read/write/delete/reference graph/wiki maintenance.
  - **Not implemented as a core runtime primitive:** semantic/vector local search, complex agent orchestration beyond Claude tool usage, strict schema enforcement for page structure.

## 2. High-Level System Model

- **Observed:** The system is fundamentally **orchestration-centric around document state**, not chat-centric. Documents are ingested into durable storage, transformed into extracted pages and searchable chunks, then surfaced through two execution planes: web UI and MCP.
- **Observed:** The dominant execution shape is:
  1. initialize mode-specific infrastructure,
  2. ingest or discover files,
  3. derive searchable/indexed state,
  4. let Claude operate through MCP tools,
  5. rebuild/update references and stale markers after wiki writes.
- **Observed:** Major subsystem split:
  - API lifecycle and services: `api/main.py`, `api/services/*`, `api/routes/*`
  - persistent data models: `shared/sqlite_schema.sql`, `supabase/migrations/*.sql`
  - Claude-facing runtime: `mcp/tools/*`, `mcp/vaultfs/*`, `mcp/local_server.py`, `mcp/hosted.py`
  - operator UI: `web/src/components/kb/KBDetail.tsx`, `web/src/hooks/useKBDocuments.ts`
- **Inferred:** The project’s behavioral intelligence lives mostly in the transformation and maintenance loop: extraction, chunking, reference parsing, stale propagation, and tool semantics.
- **Architectural identity:** **mode-switched knowledge-work runtime** with duplicated local/hosted persistence adapters and an MCP-first authoring model.

## 3. Conceptual Capability Mapping

| Capability | Status | Primary owner | Execution semantics | Limits / implications |
| --- | --- | --- | --- | --- |
| Persistent wiki over raw sources | **Implemented** | `mcp/tools/write.py`, `api/services/local.py`, `api/services/hosted.py` | Wiki files live under `/wiki/`; writes update storage plus index/reference state | Strongly encouraged by tool prompts; only partially enforced structurally |
| Incremental source ingest | **Implemented** | `api/routes/local_upload.py`, `api/domain/local_processor.py`, `api/infra/tus.py`, `api/services/ocr.py` | New files become `documents`; some are immediately chunked, others enter async processing | Local and hosted ingest paths differ materially |
| Search across corpus | **Implemented** | `api/services/chunker.py`, `mcp/tools/search.py`, `shared/sqlite_schema.sql`, `supabase/migrations/001_initial.sql` | Local uses SQLite FTS5; hosted uses PGroonga-backed Postgres indexes | Local mode is keyword/FTS only |
| Page-level reading with citations | **Implemented** | `mcp/tools/read.py`, `document_pages` tables | PDFs/Office/spreadsheets are read via stored pages and optional page ranges | Read semantics depend on successful extraction |
| Citation and wiki-link graph | **Implemented** | `api/services/references.py`, `api/services/graph.py`, `mcp/tools/references.py`, `document_references` schema | Wiki writes parse footnotes and internal links into graph edges | Citation syntax is convention-based, not schema-validated |
| Staleness propagation | **Implemented** | `mcp/vaultfs/sqlite.py`, `mcp/vaultfs/postgres.py`, `mcp/tools/search.py` | Updating a wiki page marks pages that link to it as stale | Only link-based staleness is tracked, not semantic invalidation |
| Real-time UI updates | **Partial but active** | `api/routes/ws.py`, `supabase/migrations/003_document_notify.sql`, `web/src/hooks/useKBDocuments.ts` | Hosted uses Postgres NOTIFY + WS; local uses polling | Local mode has lower fidelity |
| Multi-tenant hosted service | **Implemented** | `api/auth.py`, `api/deps.py`, `supabase/migrations/001_initial.sql`, `mcp/hosted.py` | User-scoped KBs, documents, quotas, JWT auth, RLS-aware reads | Requires Supabase-compatible auth and Postgres setup |
| One-command local CLI workflow | **Partially implemented / drifted** | `llmwiki` | Intended to init, serve, and expose MCP | Current script references stale paths/modules |
| Dynamic wiki tree index (`index.json`) | **Aspirational / optional** | `web/src/components/kb/KBDetail.tsx` | UI consumes it if present; otherwise builds tree from docs | No active producer found in API/MCP/CLI |

## 4. Architecture and Component Analysis

### 4.1 API lifecycle root

- **Observed:** `api/main.py` is the composition root. It decides local vs hosted mode, initializes mode-specific resources, and conditionally mounts different route sets.
- **Ownership:** app lifespan, shared middleware, and high-level service wiring.
- **Dependency direction:** routes depend on services via `app.state.factory`; services depend on mode-specific persistence/storage.
- **Architectural significance:** this file defines the project’s main bifurcation. Most runtime differences originate here.

### 4.2 Local mode subsystem

- **Observed:** Local mode treats the filesystem as source of truth and SQLite as a rebuildable index (`README.md`, `api/main.py`, `shared/sqlite_schema.sql`).
- **Key files:** `api/main.py`, `api/services/local.py`, `api/domain/local_processor.py`, `api/domain/watcher.py`, `api/infra/db/sqlite.py`, `mcp/local_server.py`, `mcp/vaultfs/sqlite.py`.
- **Ownership:**
  - workspace bootstrap and single synthetic user
  - direct file writes and file serving
  - local indexing/extraction
  - background watch-based sync for out-of-band filesystem edits
- **Boundary leak:** several local operations bypass generic storage abstractions and touch disk directly (`api/routes/local_upload.py`, `api/services/local.py`, `mcp/vaultfs/sqlite.py`).
- **Inferred:** local mode is the product’s conceptual core, but also the area where wrapper drift has accumulated.

### 4.3 Hosted mode subsystem

- **Observed:** Hosted mode converts the same knowledge-base model into a multi-tenant service using Postgres, Supabase-style auth, S3, quotas, and resumable uploads (`api/main.py`, `supabase/migrations/001_initial.sql`, `api/infra/tus.py`, `mcp/hosted.py`).
- **Key files:** `api/services/hosted.py`, `api/services/ocr.py`, `api/routes/ws.py`, `supabase/migrations/*.sql`, `mcp/vaultfs/postgres.py`.
- **Ownership:**
  - authenticated KB/document CRUD
  - quota enforcement
  - S3-backed source storage
  - async OCR/extraction
  - real-time client invalidation
- **Architectural significance:** this is the more production-shaped path and the one most directly supported by tests.

### 4.4 MCP runtime and VaultFS abstraction

- **Observed:** MCP is a primary product surface, not a debug utility. Claude is expected to work through `guide`, `search`, `read`, `write`, and `delete` (`mcp/tools/__init__.py`, `README.md`, `mcp/tools/guide.py`).
- **Observed:** `VaultFS` is the Claude-facing abstraction boundary (`mcp/vaultfs/base.py`). It owns document lookup, page access, chunk search, disk writes, and reference graph operations.
- **Semantic center:**
  - `mcp/tools/write.py`: authoring semantics and reference update trigger
  - `mcp/tools/read.py`: page/image/glob read semantics and backlink surfacing
  - `mcp/tools/search.py`: browse/search/reference-query semantics
- **Inferred:** if extending Claude’s operational behavior, start in MCP first; API/UI are secondary surfaces for the same corpus.

### 4.5 Document processing and indexing

- **Observed:** Ingestion is not just file storage; it immediately tries to create a searchable and page-addressable representation.
- **Key files:** `api/domain/local_processor.py`, `api/services/ocr.py`, `api/services/chunker.py`, `converter/main.py`.
- **Ownership:**
  - type-specific extraction routing
  - page storage
  - chunk generation
  - parser labeling
  - error/status transitions
- **Important distinction:** extraction is implemented twice:
  - local: direct filesystem processing
  - hosted: S3-backed async processing with optional converter service

### 4.6 Reference graph subsystem

- **Observed:** Graph logic is compact but architecturally important. It turns Markdown conventions into durable relation edges (`api/services/references.py`, `api/services/graph.py`, `supabase/migrations/002_document_references.sql`).
- **Ownership:** citation filename parsing, wiki-link path resolution, rebuilds, graph node/edge serialization, stale-page propagation.
- **Constraint:** the graph is only as accurate as page conventions and filenames/titles allow; there is no heavy semantic disambiguation layer.

### 4.7 Web application

- **Observed:** The web app is a control surface over the same knowledge base, not the primary place where semantic processing happens.
- **Key files:** `web/src/components/kb/KBDetail.tsx`, `web/src/hooks/useKBDocuments.ts`, `web/src/components/auth/AuthProvider.tsx`, `web/src/lib/api.ts`.
- **Ownership:**
  - KB navigation
  - files/wiki/graph tabs
  - uploads
  - document selection
  - local-vs-hosted client behavior
- **Architectural note:** `KBDetail.tsx` is the effective UI orchestrator and therefore the semantic center of the frontend.

### 4.8 Converter service

- **Observed:** `converter/main.py` is a standalone FastAPI service for PDF/Office extraction from S3 URLs only.
- **Role:** offloads LibreOffice and `opendataloader-pdf` work from the main hosted API.
- **Constraint:** it only accepts S3 URLs and optionally enforces a shared bearer secret.

## 5. Execution Flow Analysis

### 5.1 Local startup

1. `api/main.py` enters local lifespan.
2. It creates `wiki/`, `.llmwiki/`, and `.llmwiki/cache/`, initializes SQLite from `shared/sqlite_schema.sql`, and ensures a single `workspace` row exists.
3. It constructs `LocalServiceFactory` and starts the file watcher if `watchfiles` is installed (`api/main.py`).
4. In parallel, the web app runs in `NEXT_PUBLIC_MODE=local`; `AuthProvider` injects a fake local session and skips Supabase (`web/src/components/auth/AuthProvider.tsx`, `web/src/lib/api.ts`).
5. `mcp/local_server.py` separately initializes the same workspace, scaffolds overview/log docs if absent, then exposes MCP over stdio.

### 5.2 Local ingest path

1. UI uploads to `/v1/upload` using simple multipart (`web/src/components/kb/KBDetail.tsx`, `api/routes/local_upload.py`).
2. The route writes bytes directly into the workspace, inserts a SQLite `documents` row, and chooses whether the file is immediately ready or pending.
3. Simple text types are chunked immediately; PDFs, office files, spreadsheets, and HTML are scheduled through `domain.local_processor.process_document()`.
4. `local_processor` updates document status, extracts pages/chunks/content, and commits derived state back into SQLite.

### 5.3 Hosted upload and extraction path

1. Browser uploads through TUS (`api/infra/tus.py`, referenced from the web UI).
2. Finalization persists the document row and source file in S3.
3. `OCRService.process_document()` takes over, routing by extension and using Mistral OCR, converter, or local extraction fallbacks (`api/services/ocr.py`).
4. Extracted pages become `document_pages`, searchable chunks become `document_chunks`, and the document moves to `ready` or `failed`.
5. Postgres trigger `notify_document_change()` emits a NOTIFY event (`supabase/migrations/003_document_notify.sql`).
6. `api/routes/ws.py` rebroadcasts the change to connected clients, and `useKBDocuments()` refetches.

### 5.4 Wiki authoring through MCP

1. Claude is expected to call `guide` first (`mcp/tools/guide.py`).
2. `write` resolves KB/path, slugifies the target filename, writes to disk, then persists the document record (`mcp/tools/write.py`).
3. If the write targets a Markdown page under `/wiki/`, reference parsing runs and staleness propagation marks dependent pages (`mcp/tools/write.py`, `mcp/tools/references.py`, `mcp/vaultfs/sqlite.py`, `mcp/vaultfs/postgres.py`).
4. The response includes backlink/impact hints for further maintenance.

### 5.5 Read and search flow

1. `search` either lists docs, queries chunk search, or interrogates the reference graph (`mcp/tools/search.py`).
2. `read` resolves the document, decides between text/image/page/spreadsheet modes, optionally batches by glob, and appends backlink summaries (`mcp/tools/read.py`).
3. This means Claude’s working loop is designed around **broad search → scoped read → file write → graph-aware follow-up**.

### 5.6 Recovery and shutdown

- **Hosted:** on startup, stuck `pending`/`processing` documents are rescheduled (`api/main.py`).
- **Local:** there is no comparable persistent work queue; recovery is mostly “state is on disk, reindex/reprocess if needed”.
- **Shutdown:** hosted cancels cleanup/listener tasks and closes Postgres; local cancels the watcher and closes SQLite (`api/main.py`).

## 6. State and Persistence Model

### State ownership

- **Filesystem:** raw local sources and wiki files in local mode; effectively the durable human-visible workspace.
- **SQLite:** local derived metadata, pages, chunks, references, and search index (`shared/sqlite_schema.sql`).
- **Postgres:** hosted documents, KBs, chunks, pages, references, quotas, and auth-adjacent metadata (`supabase/migrations/001_initial.sql`, `002_document_references.sql`).
- **S3:** hosted source binaries and some converted artifacts (`api/services/ocr.py`).
- **Client state:** selected docs/view mode/tree state in `KBDetail.tsx`; auth and KB metadata in Zustand stores.

### Mutable state

- document status (`pending`, `processing`, `ready`, `failed`, and hosted `archived`)
- wiki content and version
- chunk tables
- reference edges
- stale markers

### Persistence semantics

- **Observed:** local mode is intentionally rebuildable: SQLite is derived from workspace files.
- **Observed:** hosted mode is database-primary for metadata and search state, with S3 for file blobs.
- **Observed asymmetry:** hosted archives wiki pages but hard-deletes sources; local deletes records/files directly (`api/services/hosted.py`, `api/services/local.py`, `api/infra/db/sqlite.py`).

### Recovery semantics

- **Hosted:** explicit stuck-document recovery exists.
- **Local:** relies on workspace durability and reindexability rather than robust queued recovery.

## 7. Coordination and Control Semantics

- **Control topology:** mostly centralized at the per-surface entrypoints:
  - API runtime controls ingest and UI-facing CRUD.
  - MCP tools control Claude-facing knowledge work.
- **Delegation model:** route/tool handlers delegate into service or `VaultFS` adapters rather than owning domain logic themselves.
- **Coordination style:** directive, synchronous at the API/MCP boundary, with asynchronous background processing for extraction and hosted notifications.
- **Concurrency model:**
  - hosted OCR uses an internal semaphore of 3 (`api/services/ocr.py`)
  - hosted WS listener runs as a long-lived LISTEN loop (`api/routes/ws.py`)
  - local watcher runs as a background task (`api/main.py`, `api/domain/watcher.py`)
- **Failure propagation:** most failures turn into document `failed` state or surfaced tool/API errors; there is little retry orchestration beyond OCR startup recovery.
- **Tool/provider selection:** file-type routing and config flags decide which parser/backend is used (`PDF_BACKEND`, `MISTRAL_API_KEY`, `CONVERTER_URL`, LibreOffice presence).

## 8. Configuration and Environment Model

### Required local configuration

- `MODE=local`
- `WORKSPACE_PATH`
- `APP_URL`, `API_URL` if not using defaults (`api/config.py`)

### Optional local configuration

- `MISTRAL_API_KEY` and `PDF_BACKEND=mistral` for better PDF OCR
- local LibreOffice install for Office conversion
- `LOGFIRE_TOKEN`, `SENTRY_DSN`

### Required hosted configuration

- `MODE=hosted`
- `DATABASE_URL`
- `SUPABASE_URL`
- web-side `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_API_URL`

### Optional hosted configuration

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET`
- `CONVERTER_URL`, `CONVERTER_SECRET`
- `MISTRAL_API_KEY`
- quota/global limit env vars from `api/config.py`

### Deployment assumptions

- web can be deployed separately (Netlify/Railway configs exist)
- API and MCP are independent deployables
- converter is a separate process if used
- root Docker Compose only provisions Postgres/test Postgres, not a full production stack

## 9. Operational Usage Model

### Canonical local workflow

1. Pick a research/workspace folder.
2. Start API + web in local mode.
3. Start stdio MCP for that same workspace.
4. Upload/drop sources.
5. Tell Claude to read the guide and begin ingesting/updating pages.
6. Browse the resulting wiki, graph, and files in the UI.

### Canonical hosted workflow

1. Authenticate.
2. Create a knowledge base.
3. Upload files through the UI.
4. Wait for extraction/indexing.
5. Use hosted MCP with authenticated Claude.
6. Iterate between UI browsing and Claude-authored wiki maintenance.

### Interaction model

- **Observed:** one workspace/KB is the operational unit.
- **Observed:** local mode maps this to one stdio MCP server per workspace (`README.md`, `mcp/local_server.py`).
- **Observed:** hosted mode maps it to one logical KB within a multi-tenant account.

## 10. Extension and Customization Architecture

### Main extension seams

1. **New source formats / extraction logic**
   - local: `api/domain/local_processor.py`
   - hosted: `api/services/ocr.py`
2. **New Claude behaviors**
   - `mcp/tools/*.py`
3. **New persistence/search capabilities**
   - `mcp/vaultfs/*.py`
   - API repositories/services as needed
4. **New UI modes or workflow affordances**
   - `web/src/components/kb/KBDetail.tsx`

### Extension constraints

- Cross-mode changes often require mirrored implementations.
- Wiki conventions are prompt-driven more than type-enforced, so tightening them likely requires both MCP tool guidance and backend validation changes.

## 11. Key Architectural Decisions and Tradeoffs

- **Filesystem-as-truth in local mode:** keeps the product inspectable and rebuildable, but requires watcher/index synchronization complexity.
- **Separate API and MCP surfaces:** lets humans and Claude work over the same corpus, but duplicates some orchestration.
- **Dual local/hosted stacks:** broadens usability, but increases maintenance burden and parity drift risk.
- **Prompt-enforced wiki discipline:** flexible and easy to evolve, but weakly enforced at storage boundaries.
- **Chunk/page materialization:** makes page-range reading and FTS practical, at the cost of ingestion complexity and duplicated state.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Local CLI drift

- **Observed:** `llmwiki` looks stale relative to the actual code:
  - expects `api/infra/db/sqlite_schema.sql`, but the real schema is `shared/sqlite_schema.sql`
  - launches `python -m local_server` from repo root even though the module lives under `mcp/local_server.py`
- **Impact:** manual startup is currently more trustworthy than the wrapper.

### 12.2 Local SQLite repository mismatch

- **Observed:** `SQLiteDocumentRepository.find_by_path()` queries `knowledge_base_id` and `archived`, but neither column exists in the SQLite schema (`api/infra/db/sqlite.py`, `shared/sqlite_schema.sql`).
- **Impact:** local note-creation paths that depend on this lookup are at risk of runtime failure.

### 12.3 README drift for hosted MCP

- **Observed:** README instructs `uvicorn server:app --port 8080`, but the actual hosted entrypoint is `mcp/hosted.py`.

### 12.4 `index.json` producer missing

- **Observed:** the UI explicitly consumes `/wiki/index.json` if present, but no generator was found in active code paths (`web/src/components/kb/KBDetail.tsx`).
- **Inferred:** this is aspirational or manually maintained rather than automated.

### 12.5 Uneven maturity

- **Observed:** backend and MCP have meaningful tests; frontend has none in CI (`.github/workflows/test.yml`, `web/package.json`).
- **Observed:** hosted mode is better-covered than local mode.

### 12.6 Branding/migration residue

- **Observed:** “Supavault” remains in names/logging/database references (`mcp/hosted.py`, `converter/main.py`, workflow/database names), indicating an incomplete rename rather than an architectural issue.

## 13. Practical Usage Guide

### Minimal Viable Usage

Run local API, local web, and local MCP against a workspace folder. This is the smallest fully useful setup.

### Operational Assumptions

- one user/workspace per local MCP process
- users are comfortable with filesystem-backed content and LLM-mediated editing
- source documents may be large, so page-level extraction/chunking is expected
- wiki quality depends on disciplined Claude usage, especially around citations and page structure

### Canonical Workflow

1. ingest sources
2. search/read sources and existing wiki
3. create/update wiki pages
4. inspect backlinks/stale pages/uncited sources
5. update overview/log

### Advanced Usage

- hosted mode with quotas, auth, and real-time UI updates
- converter-backed office extraction
- Mistral OCR for PDFs with better layout/table quality
- graph/staleness-based wiki maintenance via `search(mode="references", ...)`

### Extension Workflow

- start from the persistence/runtime surface you are changing
- mirror changes across local and hosted where feature parity matters
- update MCP semantics if Claude-facing behavior changes
- update tests in `tests/integration` or `tests/integration/mcp`

### Debugging Workflow

- start at the entrypoint in `api/main.py`, `mcp/local_server.py`, or `mcp/hosted.py`
- inspect document `status`, `page_count`, `parser`, chunks, and references in SQLite/Postgres
- use `search(..., mode="references")` and UI graph views to validate link/citation effects
- for extraction issues, trace through `local_processor.py` or `ocr.py` by file type

### Observability

- Sentry and Logfire hooks exist in API and hosted MCP (`api/main.py`, `mcp/hosted.py`)
- UI observability is mostly ad hoc
- document status fields are an important operational inspection point

### Failure Modes

- missing converter/LibreOffice causes Office processing failure
- missing `MISTRAL_API_KEY` with `PDF_BACKEND=mistral` causes PDF failure
- local wrapper startup may fail due to stale paths
- local SQLite note creation may fail on schema/query mismatch
- hosted search depends on PGroonga migration assumptions

### Performance Considerations

- OCR/extraction is the expensive path
- chunk search is cheap after indexing
- local batch reads have a 120k char budget in MCP (`mcp/tools/read.py`)
- hosted realtime refetches are debounced, indicating expected bursts during OCR completion (`web/src/hooks/useKBDocuments.ts`)

## 14. Project Navigation Guide

### Highest-value entry points

1. `api/main.py` — mode split and lifecycle
2. `shared/sqlite_schema.sql` and `supabase/migrations/001_initial.sql` — true data model
3. `api/services/local.py` and `api/services/hosted.py` — document/KB semantics
4. `api/domain/local_processor.py` and `api/services/ocr.py` — ingest/extraction core
5. `api/services/chunker.py`, `api/services/references.py`, `api/services/graph.py` — semantic center
6. `mcp/tools/write.py`, `read.py`, `search.py` — Claude behavior
7. `mcp/vaultfs/sqlite.py`, `mcp/vaultfs/postgres.py` — persistence concretization
8. `web/src/components/kb/KBDetail.tsx` — UI orchestration hub
9. `tests/integration/*` and `tests/integration/mcp/*` — behavioral contracts

### Best reading order

1. `README.md`
2. `api/main.py`
3. schemas/migrations
4. service implementations
5. extraction/chunk/reference logic
6. MCP tools
7. web KB view
8. tests

### Where abstractions become concrete

- `app.state.factory` becomes `LocalServiceFactory` or `HostedServiceFactory`
- `VaultFS` becomes `SqliteVaultFS` or `PostgresVaultFS`
- parser choice becomes concrete inside `local_processor.py` or `ocr.py`

## 15. Concise Deep Technical Synthesis

- **What it is:** a local-first, optionally hosted knowledge-compilation system that turns a document corpus into a maintained wiki rather than re-deriving answers from raw files on every query.
- **Architectural pattern:** dual-mode orchestration over shared domain semantics, with duplicated persistence adapters for API and MCP surfaces.
- **Operational model:** ingest sources into derived page/chunk state; let Claude search, read, and write persistent wiki pages; keep citations, links, and stale markers synchronized.
- **What makes it distinctive:** the MCP tool surface is first-class, the filesystem remains meaningful in local mode, and the wiki is treated as a compounding artifact.
- **What kind of team it suits:** engineers comfortable with LLM-assisted research tooling, modest infrastructure complexity, and a codebase where the real behavior lives in transformation/runtime semantics rather than in framework scaffolding.
