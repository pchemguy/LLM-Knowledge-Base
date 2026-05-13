# Repository Onboarding

## What this repo actually is

- `llmwiki` is a **knowledge-compilation system**: raw sources are ingested, indexed, chunked, and exposed to Claude so it can maintain a persistent wiki under `/wiki/`.
- The repo has **two real runtime modes**:
  - **local** = filesystem + SQLite + stdio MCP + single-user auth (`api/main.py`, `shared/sqlite_schema.sql`, `mcp/local_server.py`)
  - **hosted** = Postgres + Supabase-style auth + S3 + TUS + HTTP MCP (`api/main.py`, `supabase/migrations/*.sql`, `api/infra/tus.py`, `mcp/hosted.py`)

## Semantic centers

Read these first when changing behavior:

1. `api/main.py` - mode split and lifecycle root
2. `shared/sqlite_schema.sql` and `supabase/migrations/001_initial.sql` - actual state model
3. `api/domain/local_processor.py` and `api/services/ocr.py` - ingest/extraction pipeline
4. `api/services/chunker.py` - chunk semantics
5. `api/services/references.py` and `api/services/graph.py` - citation/link graph
6. `mcp/tools/write.py`, `mcp/tools/read.py`, `mcp/tools/search.py` - Claude-facing operational semantics
7. `mcp/vaultfs/sqlite.py` and `mcp/vaultfs/postgres.py` - persistence concretization
8. `web/src/components/kb/KBDetail.tsx` - main frontend orchestrator

## Core runtime model

- The system materializes documents into:
  - `documents`
  - `document_pages`
  - `document_chunks`
  - `document_references`
- Local mode treats the **workspace filesystem as source of truth** and SQLite as rebuildable derived state.
- Hosted mode treats **Postgres + S3** as the operational backing store.
- Wiki writes under `/wiki/` trigger:
  1. document persistence
  2. reference parsing
  3. backlink surface generation
  4. stale-page propagation

## Actual operator workflow

### Reliable local startup

Prefer manual startup over the `llmwiki` wrapper:

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

Why: `llmwiki` currently references a missing schema path and a stale local MCP module path.

### Canonical local usage

1. start API + web + local MCP for a workspace
2. upload or drop files into the workspace
3. Claude calls `guide`, then uses `search` + `read` + `write`
4. wiki pages accumulate in `/wiki/`
5. graph/search state updates from writes and ingestion

### Hosted usage

1. authenticated user creates a KB
2. uploads go through TUS
3. OCR/extraction populates pages/chunks
4. UI updates over Postgres NOTIFY + WebSocket
5. hosted MCP works against the same KB

## Important architectural constraints

- Local and hosted semantics are similar but **not identical**; many changes must be mirrored across both stacks.
- MCP is a **primary product surface**, not a helper. If Claude behavior changes, update MCP tools first.
- The wiki structure and citation discipline are mostly **prompt-enforced** (`mcp/tools/guide.py`), not strongly validated by the backend.
- `index.json` is consumed by the UI if present, but no active generator was found; the fallback tree builder in `KBDetail.tsx` is the real active path.

## Known sharp edges

- `llmwiki` wrapper drift:
  - wrong schema path (`llmwiki` vs `shared/sqlite_schema.sql`)
  - wrong local MCP module launch path
- Local SQLite mismatch:
  - `api/infra/db/sqlite.py` queries `knowledge_base_id` and `archived` in `find_by_path()`
  - those columns do not exist in `shared/sqlite_schema.sql`
- README hosted MCP startup command is stale; actual entrypoint is `mcp/hosted.py`
- Frontend has no CI test coverage; backend/MCP are much better covered

## Debugging guidance

- Start from entrypoints: `api/main.py`, `mcp/local_server.py`, `mcp/hosted.py`
- For ingest failures, inspect:
  - document `status`
  - `parser`
  - `page_count`
  - `error_message`
  - chunk/page rows
- For wiki maintenance issues, inspect:
  - `document_references`
  - stale markers
  - `search(mode="references", ...)`
- For local sync issues, include the file watcher and direct disk writes in your trace

## Useful behavioral files

- `tests/integration/test_kb_lifecycle.py` - hosted KB scaffolding and lifecycle
- `tests/integration/test_note_lifecycle.py` - hosted document semantics, chunking, archive/delete rules
- `tests/integration/mcp/test_tool_handlers.py` - real MCP tool behavior over SQLite
- `.github/workflows/test.yml` - what CI actually treats as important
