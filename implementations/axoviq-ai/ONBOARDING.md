# Synthadoc — ONBOARDING

> Compact operational knowledge layer for agents and developers working in this repository.
> Full analysis: `OnboardingReport.md`

---

## What This Project Is

**Local-first, ingest-time LLM knowledge compilation engine** (v0.3.0, AGPL-3.0).

Reads raw source documents (PDF, DOCX, PPTX, XLSX, images, URLs, YouTube, web search), uses an LLM to synthesize them into a persistent **Markdown wiki**. Synthesis happens **once at ingest time**, not per query. The wiki pages (`wiki/*.md`) are the primary artifact — readable without any tool running.

This is the core architectural inversion from RAG: knowledge is compiled at ingest, not synthesized on every query.

---

## Dominant Architectural Identity

**Orchestration-centric, queue-driven wiki compiler.**

```
CLI / Obsidian Plugin / HTTP
         │
    Orchestrator  (core/orchestrator.py)
         │
  JobQueue (SQLite) → _worker_loop → Agents
         │
  WikiStorage (wiki/*.md) + AuditDB + CacheDB (SQLite)
```

- Single `Orchestrator` owns all state and dispatches all agents.
- `_worker_loop()` (`http_server.py:199-242`) polls `jobs.db` every 2s; **sequential, one job at a time**.
- Queries are synchronous (no queue); ingest/lint/scaffold are queued.
- Jobs survive server restarts (SQLite-backed).

---

## Entry Points

| Surface | Entry |
|---|---|
| CLI | `synthadoc` → `synthadoc.cli.main:app` (`pyproject.toml:49`) |
| HTTP server | `synthadoc serve` → FastAPI via `synthadoc/integration/http_server.py:create_app()` |
| Server bind | `127.0.0.1:7070` (localhost-only) |
| MCP server | `synthadoc serve --mcp-only` → `integration/mcp_server.py` (**partially broken** — see gaps) |

---

## Semantic Centers

| File | Role |
|---|---|
| `synthadoc/agents/ingest_agent.py` | **Primary semantic center** — create/update/flag/skip decision pipeline |
| `_ANALYSIS_PROMPT`, `_DECISION_PROMPT` constants | LLM behavioral policy for wiki maintenance |
| `synthadoc/core/orchestrator.py` | Runtime authority — owns all subsystems |
| `synthadoc/integration/http_server.py` | FastAPI app + worker loop |
| `synthadoc/storage/wiki.py` | `WikiPage` data model + Markdown I/O |
| `synthadoc/agents/query_agent.py` | Retrieval, gap detection, synthesis |
| `synthadoc/config.py` | All config dataclasses + `KNOWN_PROVIDERS` |

---

## Key Data Structures

**`WikiPage`** (`storage/wiki.py:27-40`): `title`, `tags`, `content`, `status` (observed normal values: `active|contradicted`; auto-generated pages may use `auto`), `confidence` (`low|medium|high`), `sources: list[SourceRef]`, `aliases`, `contradiction_note`, `unresolved_note`.

**`Job`** (`core/queue.py:24-34`): `id`, `operation`, `payload`, `status` (`pending|in_progress|completed|failed|dead|skipped|cancelled`), `retries`, `error`, `result`.

**`IngestResult`** (`ingest_agent.py:30-42`): `source`, `pages_created`, `pages_updated`, `pages_flagged`, `tokens_used`, `cost_usd`, `skipped`.

---

## State Locations

| State | Path |
|---|---|
| Wiki pages | `<wiki>/wiki/*.md` |
| Job queue | `<wiki>/.synthadoc/jobs.db` |
| Audit events | `<wiki>/.synthadoc/audit.db` |
| LLM cache | `<wiki>/.synthadoc/cache.db` |
| Vector embeddings | `<wiki>/.synthadoc/embeddings.db` (optional) |
| OTEL traces | `<wiki>/.synthadoc/logs/traces.jsonl` |
| Human-readable log | `<wiki>/log.md` |
| Wiki registry | `~/.synthadoc/wikis.json` |
| Default wiki | `~/.synthadoc/default_wiki` |
| Global config | `~/.synthadoc/config.toml` |
| Per-wiki config | `<wiki>/.synthadoc/config.toml` |
| Blocked domains | `<wiki>/.synthadoc/blocked_domains.json` |

---

## Setup & Run

```bash
# Install (dev mode)
pip install -e ".[dev]"
pip install -e ".[dev,vectors]"  # optional: for vector search (requires Rust)

# Minimum: one API key
export GEMINI_API_KEY=<key>   # free tier; or ANTHROPIC_API_KEY, OPENAI_API_KEY, GROQ_API_KEY, etc.

# Create wiki
synthadoc install my-wiki --target ~/wikis --domain "My Domain"
synthadoc use my-wiki

# Start server (required for most CLI commands)
synthadoc serve -w my-wiki
synthadoc serve -w my-wiki --background  # background mode

# Core operations
synthadoc ingest raw_sources/paper.pdf -w my-wiki
synthadoc ingest "search for: neural networks 2025" -w my-wiki
synthadoc query "What do I know about X?" -w my-wiki
synthadoc lint run -w my-wiki
synthadoc lint report -w my-wiki

# Inspect
synthadoc jobs list -w my-wiki
synthadoc audit history -w my-wiki
synthadoc status -w my-wiki
```

---

## Tests

```bash
# Python tests (unit + integration)
pytest --ignore=tests/performance/ -q

# With coverage (as in CI)
pytest --cov=synthadoc --cov-report=term-missing -v

# Performance benchmarks
pytest tests/performance/ -v --benchmark-disable

# Skip external-API tests
pytest -m "not integration"

# Obsidian plugin tests
cd obsidian-plugin && npm install && npm test
```

`asyncio_mode = "auto"` is set in `pyproject.toml`. Tests are in `tests/` organized by subsystem: `agents/`, `cli/`, `core/`, `integration/`, `providers/`, `skills/`, `storage/`, `security/`, `performance/`.

---

## Configuration Quick Reference

Config is TOML, merged from `~/.synthadoc/config.toml` (global) → `<wiki>/.synthadoc/config.toml` (project wins).

```toml
[agents]
# Per-agent provider/model override; falls back to default
default = { provider = "gemini", model = "gemini-2.0-flash-lite" }
ingest  = { provider = "anthropic", model = "claude-3-5-haiku-20241022" }

[ingest]
max_pages_per_ingest = 15
chunk_size = 1500
staging_policy = "off"     # "off" | "all" | "threshold"

[query]
gap_score_threshold = 2.0  # BM25 score below = knowledge gap detected
context_token_budget = 4000

[search]
vector = false             # true = fastembed hybrid; requires pip install synthadoc[vectors]

[server]
port = 7070

[logs]
level = "INFO"             # DEBUG for verbose

[schedule]
jobs = [
  { op = "lint", cron = "0 2 * * *" },
]

[hooks]
on_ingest_complete = ""
on_lint_complete = ""
```

---

## Extension Points

### Skills (Content Extraction)

- **Base class** (Apache-2.0): `synthadoc/skills/base.py:BaseSkill` — implement `async extract(source) → ExtractedContent`
- **Discovery order**: extra dirs → wiki-local `skills/` → `~/.synthadoc/skills/` → `entry_points("synthadoc.skills")` → built-ins
- **Metadata**: `SKILL.md` frontmatter with `triggers.extensions` / `triggers.intents`
- **Built-ins**: `markdown`, `pdf`, `docx`, `pptx`, `xlsx`, `image`, `url`, `web_search`, `youtube`

### Providers (LLM Backends)

- **Base class** (Apache-2.0): `synthadoc/providers/base.py:LLMProvider` — implement `async complete(messages, system, temperature, max_tokens) → CompletionResponse`
- **Register**: add to `providers/__init__.py:make_provider()` and `config.py:KNOWN_PROVIDERS`

### Hooks

- Configure in `[hooks]` section; scripts receive JSON event data
- Events: `on_ingest_complete`, `on_lint_complete`
- Example: `hooks/git-auto-commit.py`

---

## Ingest Decision Logic (Core Semantics)

`IngestAgent.ingest()` applies these rules in priority order (encoded in `_DECISION_PROMPT`):

1. **FLAG**: source disputes a factual claim in existing page → sets `contradiction_note` YAML field
2. **UPDATE**: source adds info to existing page topic → appends new `##` sections
3. **CREATE**: source covers topic not in any page → creates new `wiki/{slug}.md`
4. **SKIP**: source already ingested (hash dedup) or no useful content

All decisions use BM25 to find top-8 candidate existing pages as context for the LLM decision.

---

## Known Implementation Gaps

| Gap | Severity | Location |
|---|---|---|
| `CostGuard` constructed but never enforced — no spend limits at runtime | High | `core/orchestrator.py:46`, `core/cost_guard.py` |
| MCP server `ingest`/`lint` tool signatures mismatch Orchestrator API | High | `integration/mcp_server.py:21-41` |
| `query --save` flag accepted but not implemented | Medium | `cli/query.py:39` |
| Query routing (`ROUTING.md`) fully implemented but never wired in normal query path | Medium | `core/routing.py`, `agents/_routing.py`, `orchestrator.py:302-309` |
| `max_parallel_ingest=4` config never read; worker is always sequential | Low | `core/queue.py`, `http_server.py:199-242` |
| BM25 uses only an in-memory corpus cache; no persistent index, so cold start and post-write queries rebuild from disk | Perf | `storage/search.py` |
| `web_search/SKILL.md` says "stub" but implementation is complete | Docs | `skills/web_search/SKILL.md:35-49` |

---

## Architectural Invariants

- Local paths sent to ingest **must be inside `wiki_root`** (`ingest_agent.py:316-327`). Place source files in `raw_sources/`.
- Server always binds `127.0.0.1` only (`cli/serve.py:261-264`). Not exposed on network.
- LLM cache version `"4"` (`config.py:72`). Bumping this string invalidates all cached LLM responses.
- Wiki pages are Markdown with YAML frontmatter. The `_FRONTMATTER_FIELDS` tuple in `storage/wiki.py:14` defines the canonical field set.
- All async SQLite I/O uses `aiosqlite`. File I/O in `WikiStorage` uses `threading.Lock` + `FileLock`.
- `SPDX-License-Identifier: AGPL-3.0-or-later` on engine code; `Apache-2.0` on extension interfaces (`providers/base.py`, `skills/base.py`).

---

## Navigation for Common Tasks

| Task | Where to look |
|---|---|
| Change ingest decision behavior | `ingest_agent.py:_DECISION_PROMPT`, `_ANALYSIS_PROMPT` |
| Add new source format | `synthadoc/skills/` — new skill directory |
| Add new LLM backend | `synthadoc/providers/` — subclass `LLMProvider` |
| Change query gap threshold | `config.py:QueryConfig.gap_score_threshold` or `[query]` config |
| Add a new CLI command | `synthadoc/cli/` + register in `cli/main.py` |
| Add new API endpoint | `synthadoc/integration/http_server.py` + orchestrator method |
| Debug a stuck job | `sqlite3 <wiki>/.synthadoc/jobs.db` + `synthadoc jobs list` |
| Trace LLM call | `.synthadoc/logs/traces.jsonl` (OTEL JSONL) |
| Understand wiki page schema | `storage/wiki.py:WikiPage` |
| Understand config options | `config.py` dataclasses, all sections |
