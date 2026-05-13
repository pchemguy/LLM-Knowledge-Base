---
repo: axoviq-ai/synthadoc
---

# Synthadoc Onboarding Report

---

## SYNOPSIS

### Implementation Identity

Synthadoc is a **local-first, ingest-time LLM knowledge compilation engine** (v0.3.0, AGPL-3.0). Its dominant architectural identity is **orchestration-centric**: a single `Orchestrator` governs all work through a persistent SQLite job queue, dispatching specialized agents (`IngestAgent`, `QueryAgent`, `LintAgent`, `ScaffoldAgent`) that produce durable Markdown wiki pages as their primary artifact.

The semantic center is the **ingest pipeline** in `synthadoc/agents/ingest_agent.py`: it classifies each incoming source as `create/update/flag/skip`, uses an LLM to synthesize content with cross-references, and writes structured Markdown pages with YAML frontmatter to `wiki/`. Knowledge is compiled once at ingest time — not re-synthesized on every query. This is the core architectural inversion from RAG systems.

Access layer: CLI (Typer), HTTP REST API (FastAPI/Uvicorn on `127.0.0.1:7070`), MCP server, and an Obsidian plugin client. All four access paths share the same `Orchestrator` + agent logic.

**Maturity**: the core ingest/query/storage pipeline and CLI are production-leaning with meaningful test coverage and CI across Linux/Windows/macOS. The MCP server, cost guard enforcement, and parallel queue execution have implementation gaps described below.

### Quick Adaptation Assessment

- **Extending skills**: cleanest and most stable extension path; add a folder with `SKILL.md` + `scripts/main.py` inheriting from `BaseSkill`; zero core changes needed.
- **Extending providers**: Apache-licensed `LLMProvider` base in `synthadoc/providers/base.py`; implement `complete()` async method and register in `synthadoc/providers/__init__.py`.
- **Core agent logic**: modification concentrated in `synthadoc/agents/ingest_agent.py` (decision prompts) and `synthadoc/agents/query_agent.py` (retrieval/gap detection); high semantic density — approach carefully.
- **Prompt engineering**: all decision prompts are string constants at top of `ingest_agent.py` (`_ANALYSIS_PROMPT`, `_DECISION_PROMPT`); easily tuned without touching logic.
- **Major coupling constraint**: most CLI commands are thin HTTP clients (`synthadoc/cli/_http.py`); they require the server to be running, making "server-less" use of many CLI commands impossible.

### Fastest Path to First Successful Run

```bash
pip install -e ".[dev]"
export GEMINI_API_KEY=<your-key>   # free tier works
synthadoc install my-wiki --target ~/wikis --domain "your domain"
synthadoc use my-wiki
synthadoc serve -w my-wiki &
synthadoc ingest ~/wikis/my-wiki/raw_sources/some-file.pdf -w my-wiki
synthadoc query "What is in my wiki?" -w my-wiki
```

Minimum: Python 3.11+, one LLM API key (or local Ollama), pip. No databases, no Docker, no cloud services beyond the LLM API.

### Minimal Manual Setup Path

There is **not** a meaningful raw-uvicorn/manual path beyond the CLI. `create_app()` requires a concrete `wiki_root` argument (`synthadoc/integration/http_server.py:245`), while `synthadoc serve` also performs wiki resolution, provider/API-key checks, port checks, logging setup, and background-process wiring (`synthadoc/cli/serve.py:162-268`).

The shortest practical "manual" path is therefore still the CLI, just without helper workflows:

```bash
pip install -e .
synthadoc install my-wiki --target ~/wikis --domain "..."
export GEMINI_API_KEY=...
synthadoc serve -w my-wiki
```

### Operational Complexity Snapshot

| Dimension | Assessment |
|---|---|
| Setup complexity | Low — pip install + one API key + one command |
| Runtime dependencies | Only LLM API key + Python; SQLite is embedded |
| Operational fragility | Medium — server process must stay alive; job queue survives restart; rate limit backoff is implemented |
| Debugging | Medium — structured error codes, JSONL traces, audit DB, `log.md`; no structured dashboard |
| Observability maturity | Basic — OpenTelemetry JSONL traces at `.synthadoc/logs/traces.jsonl`; audit DB queryable via CLI |
| Infrastructure requirements | None beyond the Python process and LLM API access |

---

## 1. Repository Purpose

### Actual Implemented Purpose

Synthadoc compiles raw heterogeneous source documents (PDFs, DOCX, PPTX, XLSX, images, web pages, YouTube videos, web search results) into a persistent, structured Markdown wiki using LLM synthesis. The critical design decision is **ingest-time compilation**: the LLM synthesizes, cross-references, and evaluates contradictions once when a source is ingested — not on every query. The wiki artifact (plain Markdown + YAML frontmatter) persists on disk and remains readable without any tool running.

Evidence: `docs/design.md:36-44` and `synthadoc/agents/ingest_agent.py:58-83` confirm the create/update/flag/skip decision logic at ingest time.

### Relationship to Conceptual Description

The pyproject.toml description ("Domain-agnostic LLM knowledge compilation engine", `pyproject.toml:8`) maps precisely to the implementation. The "agnostic" aspect is realized by the skill registry (`synthadoc/skills/`) that handles source-type detection separately from wiki logic.

### Problem Being Solved

1. **RAG conflates contradictions** — Synthadoc surfaces them via the `flag` action during ingest and tracks them in YAML frontmatter (`contradiction_note` field in `WikiPage`, `storage/wiki.py:38`).
2. **RAG re-synthesizes every query** — Synthadoc pre-compiles once, so queries hit structured, already-synthesized knowledge.
3. **Knowledge bases decay** — LintAgent scans for orphan pages and contradictions on demand or schedule.
4. **Vendor lock-in** — plain Markdown output + pluggable provider system.

### Scope Boundaries

- **In scope**: local single-node operation; CLI + HTTP + Obsidian client; ingest → compile → query → lint lifecycle.
- **Out of scope**: multi-user concurrency (worker is sequential); hosted cloud service; real-time collaborative editing.

---

## 2. High-Level System Model

Synthadoc is an **orchestration-centric, ingest-time wiki compiler**. The machine has three layers:

```
Access Layer:    CLI ──── HTTP REST API ──── Obsidian Plugin ──── MCP Server
                  │              │                    │                 │
Orchestration:   └──────────────┴────────────────────┘
                              Orchestrator
                         (queue, cache, audit, hooks)
                                   │
Agent Layer:      IngestAgent  QueryAgent  LintAgent  ScaffoldAgent  SkillAgent
                                   │
State Layer:      wiki/ (Markdown pages)  .synthadoc/ (SQLite DBs)
```

**Runtime topology**: a single `Orchestrator` instance lives in the FastAPI server process (`synthadoc/core/orchestrator.py`). It owns all runtime state: `JobQueue` (SQLite), `AuditDB` (SQLite), `CacheManager` (SQLite), `WikiStorage` (Markdown filesystem), `HybridSearch` (BM25 + optional fastembed vectors), `LogWriter` (Markdown log), `CostGuard`, `HookExecutor`.

**Control shape**: strictly pull-based sequential queue. The `_worker_loop()` in `http_server.py:199-242` polls `jobs.db` every 2 seconds, dequeues one job at a time, and dispatches it. Jobs survive server restarts because they persist in SQLite.

**Behavioral intelligence location**: the primary semantic complexity lives in:
1. `IngestAgent.ingest()` — the LLM-driven create/update/flag/skip decision pipeline
2. `QueryAgent.query()` — subquestion decomposition, parallel retrieval, gap detection, synthesis
3. The prompt constants in `ingest_agent.py` — `_ANALYSIS_PROMPT`, `_DECISION_PROMPT` — encode the wiki maintenance semantics

**Architectural rationale**: ingest-time compilation means expensive LLM calls happen once per source, not per query. The queue model handles rate limits gracefully (backoff on 429). Local-first + localhost-only binding addresses privacy. Markdown-as-artifact makes the system browsable without the server.

---

## 3. Conceptual Capability Mapping

| Capability | Status | Location | Semantics |
|---|---|---|---|
| Multi-format ingest | Implemented | `synthadoc/skills/` + `IngestAgent` | Skill registry dispatches by extension/intent; 9 built-in skills |
| LLM synthesis at ingest | Implemented | `ingest_agent.py:_DECISION_PROMPT` | LLM produces action + content; cached in `cache.db` |
| Contradiction detection (flag) | Implemented | `ingest_agent.py:58-83` | Rule 1 in `_DECISION_PROMPT`; sets `contradiction_note` YAML field |
| Page create/update/skip | Implemented | `ingest_agent.py:489-659` | Three code paths; all write YAML frontmatter Markdown |
| Cross-reference wikilinks | Implemented | `_DECISION_PROMPT` wikilinks instruction | LLM instructed to produce `[[slug]]` links; BM25 matches provide candidate slugs |
| Query with gap detection | Implemented | `query_agent.py:162-356` | Multiple heuristics: BM25 score, content overlap, entity check |
| Query subquestion decomposition | Implemented | `query_agent.py:99-137` + `search_decompose_agent.py` | LLM decomposes into up to 4 subquestions |
| Hybrid search (BM25 + vector) | Implemented (BM25 always; vector optional) | `storage/search.py` | `fastembed` optional; falls back to BM25 |
| Lint (orphan + contradiction scan) | Implemented | `agents/lint_agent.py` | Scans all pages; auto-resolve via LLM if `auto_resolve=True` |
| Wiki scaffold | Implemented | `agents/scaffold_agent.py` + `cli/scaffold.py` | Generates `index.md`, `AGENTS.md`, `purpose.md` via LLM |
| Job queue with retry | Implemented | `core/queue.py` + `http_server.py:199-242` | SQLite-backed; max 3 retries; rate-limit backoff |
| Hook system | Implemented | `core/hooks.py` + `[hooks]` config | Fires on `on_ingest_complete`, `on_lint_complete` |
| LLM response cache | Implemented | `core/cache.py` | MD5-keyed SQLite cache with versioned invalidation |
| Cost estimation | Implemented (logging only) | `core/cost_guard.py` + `providers/pricing.py` | Logs cost; `CostGuard` object constructed but not enforced at runtime |
| Per-agent provider routing | Implemented | `config.py:AgentsConfig.resolve()` | Each agent slot (`ingest`, `query`, `lint`, `skill`) can use different provider |
| Routing/branching index | Implemented in agent; **not wired to normal queries** | `agents/_routing.py`, `core/routing.py` | `QueryAgent` accepts `routing_path` but `Orchestrator.query()` does not pass one |
| Parallel queue processing | Config only; **sequential at runtime** | `config.py:QueueConfig` | `max_parallel_ingest=4` exists but worker processes one job at a time |
| MCP server | Partial / buggy | `integration/mcp_server.py` | Tool signatures mismatch orchestrator API; stale |
| Cost enforcement (hard gate) | Not wired | `core/cost_guard.py` | Object exists; no `check()` call in ingest/query paths |
| `query --save` | Not implemented | `cli/query.py:39` flag exists | Flag accepted but no save logic |

---

## 4. Architecture and Component Analysis

### 4.1 Orchestrator (`synthadoc/core/orchestrator.py`)

**Semantic responsibility**: the single stateful runtime object. Owns all subsystems; coordinates agents; fires hooks; records audit events; manages the job lifecycle.

**Constructed at server startup** in `http_server.py:260`: `Orchestrator(wiki_root=wiki_root, config=cfg)`.

Key owned state:
- `_queue`: `JobQueue` → `.synthadoc/jobs.db`
- `_audit`: `AuditDB` → `.synthadoc/audit.db`
- `_cache`: `CacheManager` → `.synthadoc/cache.db`
- `_store`: `WikiStorage` → `wiki/` directory
- `_search`: `HybridSearch` → BM25 (always) + `embeddings.db` (optional)
- `_log`: `LogWriter` → `log.md`
- `_cost`: `CostGuard` → cost tracking (not enforced)
- `_hooks`: `HookExecutor` → shell hooks

**Key methods**:
- `_run_ingest()` — main ingest pipeline (builds `IngestAgent`, executes, fans out child jobs, fires hook)
- `query()` — builds `QueryAgent`, executes, records audit
- `_run_lint()` — builds `LintAgent`, executes
- `_run_scaffold()` — builds `ScaffoldAgent`, executes
- `ingest()` / `lint()` — thin job-enqueue wrappers

**Extension implication**: adding a new operation type requires adding a method here + a dispatch case in `_worker_loop()`.

### 4.2 IngestAgent (`synthadoc/agents/ingest_agent.py`)

**Semantic center of the project**. Encodes the wiki maintenance semantics in its decision prompts.

**Key flow** (traced in §5):
1. Source validation + dedup (hash check against existing `SourceRef` lists)
2. Web-search special case detection + decomposition
3. Content extraction via `SkillAgent`
4. LLM content analysis (entities/tags/summary) with cache
5. BM25 search for top matching existing pages
6. LLM decision: create/update/flag/skip (with `_DECISION_PROMPT`)
7. Write/update/flag page to `WikiStorage`
8. Overview regeneration via `scaffold_agent.py`
9. Audit + log recording

**Prompt constants** at top of file: `_ANALYSIS_PROMPT`, `_ENTITY_PROMPT`, `_DECISION_PROMPT`. The decision prompt encodes the priority-ordered rules (FLAG > UPDATE > CREATE > SKIP) with wikilink instructions.

**LLM response caching**: every LLM call goes through `CacheManager.get_or_set()` keyed on MD5 of prompt + model; cache version `"4"` (`config.py:72`).

### 4.3 QueryAgent (`synthadoc/agents/query_agent.py`)

**Knowledge retrieval with gap intelligence**.

Key behaviors:
- Expands query aliases (`_routing_branch_pick`, dead in practice)
- Decomposes question into ≤4 subquestions via `SearchDecomposeAgent`
- Runs BM25 retrieval per subquestion (parallel coroutines)
- Multi-heuristic gap detection: BM25 score threshold, content overlap (key-term extraction minus stopwords), entity presence check
- Synthesizes final answer with citations or advises on knowledge gap

**Gap detection heuristic** (`gap_score_threshold=2.0` by default): if BM25 top score is below threshold, gap is declared. Additional content-overlap check uses extracted key terms against page content.

### 4.4 SkillAgent (`synthadoc/agents/skill_agent.py`)

**Content extraction dispatcher**. Resolves the correct `BaseSkill` implementation for each source type.

**Discovery order** (lazy, cached registry):
1. Extra dirs passed at construction time
2. Wiki-local `skills/` directory
3. `~/.synthadoc/skills/`
4. `entry_points("synthadoc.skills")` — pip-installable community skills
5. Built-in skills at `synthadoc/skills/`

**Matching logic**: skills declare `triggers.extensions` (e.g., `.pdf`) and `triggers.intents` (e.g., `search for`) in `SKILL.md` frontmatter. `SkillAgent.detect_skill()`/`extract()` match the source string against these.

**Built-in skills**: `markdown`, `pdf`, `docx`, `pptx`, `xlsx`, `image`, `url`, `web_search`, `youtube`.

### 4.5 WikiStorage (`synthadoc/storage/wiki.py`)

**Durable artifact layer**. Manages `wiki/` directory as a filesystem of YAML-frontmatter Markdown files.

**`WikiPage` dataclass** (`wiki.py:27-40`): `title`, `tags`, `content`, `status`, `confidence`, `sources` (list of `SourceRef`), `categories`, `aliases`, `contradiction_note`, `unresolved_note`.

**Page lifecycle**: `write_page(slug, page)` → `wiki/{slug}.md`; `read_page(slug)` → parsed `WikiPage`; `list_pages()` → slug list; `delete_page(slug)`.

**Thread safety**: `FileLock` per file; threading lock on registry dict.

**Status/confidence fields**: `WikiStorage` itself does not enforce a closed status enum, but the active runtime paths currently write `status="active"` for normal pages (`ingest_agent.py:614-623`), `status="contradicted"` when ingest flags a dispute (`ingest_agent.py:527-540`), and `status="auto"` for generated overview pages (`ingest_agent.py:264-268`). `confidence` is used conventionally as `{low, medium, high}`.

### 4.6 HybridSearch (`synthadoc/storage/search.py`)

**Retrieval layer**. BM25 via `rank_bm25.BM25Okapi` (always active) + optional `fastembed` vector store in `embeddings.db`.

**BM25 corpus**: cached in memory per server process (`HybridSearch._cached_corpus`) and invalidated after writes (`invalidate_index()`); there is still **no persistent BM25 index**, so the first query after startup or after page writes rebuilds from disk (`storage/search.py:95-164`).

**Vector path**: opt-in via `[search] vector = true` in config. Requires `pip install synthadoc[vectors]`. On first start, a background task embeds all existing pages (`_run_vector_migration()` in `orchestrator.py:67-94`). Uses BAAI/bge-small-en-v1.5 model via fastembed.

**Hybrid merge**: vector mode is really BM25 candidate fetch + cosine-similarity re-ranking of those candidates, not RRF (`storage/search.py:195-232`).

### 4.7 HTTP API (`synthadoc/integration/http_server.py`)

**Orchestration gateway**. FastAPI application; created via `create_app(wiki_root)` factory.

**Key endpoints**:
- `POST /jobs/ingest` — enqueues ingest job, returns job ID
- `POST /query` — synchronous query (no job queue)
- `POST /jobs/lint` — enqueues lint job
- `POST /jobs/scaffold` — enqueues scaffold job
- `POST /analyse` — runs ingest analysis only, no writes
- `GET /jobs/{id}` — job status + result
- `GET /jobs` — list jobs
- `DELETE /jobs/{id}` — delete completed/dead job
- `POST /jobs/{id}/retry` — reset a job to pending
- `POST /jobs/cancel-pending` — cancel all pending jobs
- `DELETE /jobs` — purge old completed/dead jobs
- `GET /status` — server + wiki health
- `GET /lint/report` — offline orphan/contradiction summary
- `GET /audit/history|costs|queries|events` — audit surfaces
- `POST /context/build` — token-budgeted evidence pack

**Security**: `ContentSizeLimitMiddleware` (10 MB max body); CORS restricted to `app://obsidian.md`, `localhost`, `127.0.0.1`.

**Worker loop**: single asyncio background task; polls every 2s; rate-limit-aware backoff.

### 4.8 Providers (`synthadoc/providers/`)

**LLM backend abstraction**. `LLMProvider` ABC in `providers/base.py` requires only `async complete(messages, system, temperature, max_tokens) → CompletionResponse`.

**Implemented backends**:
- `anthropic.py`: Anthropic SDK direct
- `openai.py`: OpenAI SDK, also used for Gemini/Groq/MiniMax/DeepSeek via base_url override
- `ollama.py`: httpx-based direct REST calls to local Ollama
- `coding_tool.py`: subprocess-based providers (`claude-code`, `opencode`) — spawns CLI processes, parses JSON output

**Factory** `make_provider(cfg)` in `providers/__init__.py`: dispatches on `cfg.provider` string.

**Vision support**: `LLMProvider.supports_vision: bool = True`; Ollama overrides to `False` unless model supports it.

### 4.9 CLI (`synthadoc/cli/`)

**Thin client layer**. Most commands resolve the wiki path, check server is running, proxy to HTTP. Some commands work without server.

**Commands requiring server**: `ingest`, `query`, `lint run`, `status`, `jobs list/status/delete/cancel`, `scaffold`, `context`.

**Commands working without server** (direct disk/DB access): `lint report`, `audit`, `routing`, `candidates`, `cache clear`, `plugin install/uninstall`.

**Wiki resolution**: `_wiki.py` checks `SYNTHADOC_WIKI` env var → `~/.synthadoc/default_wiki` → `-w` argument. `resolve_wiki_path()` reads `~/.synthadoc/wikis.json`.

**HTTP proxy utility**: `_http.py` wraps all server calls with structured error codes (`ERR-SRV-*`).

### 4.10 Skills (`synthadoc/skills/`)

**Content extraction extension layer**. Each skill is a directory containing `SKILL.md` (metadata) + `scripts/main.py` (entry class).

**`SKILL.md` frontmatter**: `name`, `description`, `version`, `entry_script`, `entry_class`, `triggers.extensions`, `triggers.intents`, `requires`.

**`BaseSkill`** (Apache-2.0): defines `async extract(source: str) → ExtractedContent`. `ExtractedContent` carries `text`, `source_path`, `metadata`.

**Community skills**: discoverable via `entry_points("synthadoc.skills")` in `pyproject.toml` or placed in `~/.synthadoc/skills/`.

### 4.11 Config System (`synthadoc/config.py`)

**Layered TOML config**. Merges global (`~/.synthadoc/config.toml`) and project (`<wiki>/.synthadoc/config.toml`) with project winning. Parsed into typed dataclasses.

**Key config sections**: `[agents]`, `[cost]`, `[ingest]`, `[query]`, `[queue]`, `[logs]`, `[server]`, `[schedule]`, `[web_search]`, `[wiki]`, `[search]`, `[hooks]`.

**Default provider**: Gemini Flash Lite scaffolded into new wikis (`cli/_init.py:29-47`).

---

## 5. Execution Flow Analysis

### 5.1 Server Startup

```
synthadoc serve -w my-wiki
  → cli/serve.py:162-268
      resolve wiki path
      load config (cli/_init.py + config.py)
      validate wiki dir, check .synthadoc/config.toml
      check provider env var (exits if missing key)
      configure logging (core/logging_config.py)
      optionally daemonize (subprocess re-exec with --background)
      find free port (cli/_port.py)
      uvicorn.run(create_app(wiki_root), host="127.0.0.1", port=...)
        → http_server.create_app(wiki_root)
            load_config(wiki_root/.synthadoc/config.toml)
            lifespan():
              Orchestrator(wiki_root, config)  ← constructs all subsystems
              await orch.init()  ← creates SQLite tables, optionally init vectors
              asyncio.create_task(_worker_loop(orch))  ← background poll loop
              yield  ← FastAPI serves requests
              worker.cancel()
```

### 5.2 Ingest Flow

```
synthadoc ingest raw_sources/paper.pdf -w my-wiki
  → cli/ingest.py:42-105
      check server running (_http.check_server)
      POST /jobs/ingest {source: "raw_sources/paper.pdf"}
        → http_server: normalize path, enqueue job to jobs.db
        → return {job_id: "uuid-..."}
      poll GET /jobs/{job_id} until complete
      display result

_worker_loop (background):
  dequeue job from jobs.db
  await orch._run_ingest(job_id, source, auto_confirm=True, force=False)
    → core/orchestrator.py:123-199
        make_provider(cfg.agents.resolve("ingest"))
        IngestAgent(provider, wiki_root, store, search, audit, cache, log, cfg)
        result = await agent.ingest(source, force=False, max_results=None)
          → ingest_agent.py
              (1) validate + dedup: hash check vs SourceRef.hash in all pages
              (2) web-search intent? → SearchDecomposeAgent → child job fanout
              (3) SkillAgent.extract(source) → ExtractedContent
              (4) CacheManager.get_or_set(analysis_prompt) → LLM analysis JSON
              (5) BM25 search top-8 existing pages
              (6) CacheManager.get_or_set(decision_prompt) → {action, ...}
              (7a) action=create: WikiStorage.write_page(new_slug, page)
              (7b) action=update: WikiStorage.read_page + append + write_page
              (7c) action=flag: read_page + set contradiction_note + write_page
              (7d) action=skip: no-op
              (8) scaffold_agent.regenerate_overview(...)
              (9) audit.record_ingest() + log.append()
        queue.complete(job_id, result)
        hooks.fire("on_ingest_complete", result)
```

### 5.3 Query Flow

```
synthadoc query "How did ENIAC influence modern CPUs?" -w my-wiki
  → cli/query.py:36-52
      POST /query {question: "...", top_n: 8}
        → http_server:334-342
            await orch.query(question, top_n=8)
              → orchestrator.py:302-330
                  make_provider(cfg.agents.resolve("query"))
                  QueryAgent(provider, store, search, top_n, gap_score_threshold)
                  result = await agent.query(question)
                    → query_agent.py
                        (1) alias expansion (routing, dormant)
                        (2) SearchDecomposeAgent → sub_questions list
                        (3) parallel: search.bm25_search(sq) for sq in sub_questions
                        (4) gap detection: score threshold + content overlap + entity check
                        (5a) gap=False: CacheManager.get_or_set(synthesis_prompt) → answer
                        (5b) gap=True: return gap advice + suggested_searches
                  audit.record_query()
        return QueryResult JSON
      display answer + citations
```

### 5.4 Lint Flow

```
synthadoc lint run -w my-wiki
  → cli/lint.py:72-86
      POST /jobs/lint {scope: "all", auto_resolve: false}
      poll until complete

_worker_loop:
  await orch._run_lint(job_id, scope, auto_resolve)
    → orchestrator.py:358-386
        LintAgent(provider, store, search, cfg)
        report = await agent.lint(scope, auto_resolve)
          → lint_agent.py:125-206
              scan all pages: find flagged (contradiction_note set) + orphans
              for flagged: if auto_resolve → LLM resolution attempt
              return LintReport
        queue.complete(job_id, report)
        hooks.fire("on_lint_complete", report)
```

### 5.5 Schedule Flow

Scheduling is **OS-scheduler integration**, not an in-process background loop. `synthadoc schedule add/list/remove/apply` wraps `core/scheduler.py`, which writes crontab entries on Unix or `schtasks` entries on Windows (`core/scheduler.py:20-115`, `cli/schedule.py:36-92`). The config shape is `[schedule].jobs = [{ op, cron }, ...]`; `synthadoc schedule apply -w <wiki>` materializes those entries into the host scheduler. `serve.py` does **not** start its own scheduler.

---

## 6. State and Persistence Model

### State Ownership

| State | Owner | Location | Persistence |
|---|---|---|---|
| Wiki pages | `WikiStorage` | `wiki/*.md` | Markdown + YAML frontmatter on filesystem |
| Job queue | `JobQueue` | `.synthadoc/jobs.db` | SQLite; survives restarts |
| Audit events | `AuditDB` | `.synthadoc/audit.db` | SQLite; append-only |
| LLM cache | `CacheManager` | `.synthadoc/cache.db` | SQLite; keyed on MD5(prompt+model); versioned |
| Vector embeddings | `VectorStore` | `.synthadoc/embeddings.db` | SQLite BLOB; optional |
| Human-readable log | `LogWriter` | `log.md` | Markdown append |
| OTEL traces | telemetry | `.synthadoc/logs/traces.jsonl` | JSONL append |
| Wiki registry | CLI | `~/.synthadoc/wikis.json` | JSON |
| Default wiki | CLI | `~/.synthadoc/default_wiki` | Plain text |
| Global config | CLI | `~/.synthadoc/config.toml` | TOML |
| Per-wiki config | CLI/`init_wiki` | `.synthadoc/config.toml` | TOML |
| Blocked domains | URL skill | `.synthadoc/blocked_domains.json` | JSON; auto-updated on 403 |

### State Transitions

`WikiPage.status` is convention-driven rather than type-enforced. The currently used transitions are `active` → `contradicted` during ingest conflict flagging, then `contradicted` → `active` if lint auto-resolves or a human edits the page (`ingest_agent.py:527-540`, `lint_agent.py:135-185`). Auto-generated overview content uses `status: auto`. `orphan: true` is maintained by lint when no other content page links to the slug.

`Job.status` transitions: `pending` → `in_progress` → `completed|failed|dead|skipped|cancelled`.

### Mutable vs Immutable

- **Immutable after write**: audit records, OTEL trace events, `log.md` entries.
- **Mutable**: wiki pages (update/flag/delete), job status, cache entries, embeddings.

### Cache Semantics

Cache version `"4"` (`config.py:72`). Any change to this string invalidates all cached LLM responses. All analysis and decision prompts are cached. Queries are **not** cached (synthesis happens per-call).

---

## 7. Coordination and Control Semantics

### Execution Authority

`Orchestrator` is the single authority. It owns all subsystems and is the only object that:
- creates and destroys agents
- reads/writes the job queue
- fires hooks
- records audit events

No agent has direct access to the job queue or hook system.

### Worker Loop (Sequential Polling)

The `_worker_loop()` (`http_server.py:199-242`) is an asyncio coroutine that:
1. Polls `JobQueue.dequeue()` every 2 seconds
2. Processes one job at a time (sequential, despite `max_parallel_ingest=4` config)
3. On 429 rate limit: parses retry-after, sleeps that long
4. On daily quota exhaustion: logs and continues polling (job is already dead)
5. On other exceptions: logs and continues

**Job persistence across restart**: SQLite-backed queue means in-progress jobs at shutdown are retried (up to `max_retries`) on next startup.

### Concurrency Model

- HTTP request handling: asyncio (FastAPI/uvicorn event loop)
- `query` endpoint: directly awaited in request context (no queue)
- `ingest`/`lint`/`scaffold`: enqueued, executed by worker loop
- File I/O in `WikiStorage`: `threading.Lock` + `FileLock` for safe concurrent reads/writes
- No `max_parallel_ingest` enforcement at runtime

### Hook Execution

`HookExecutor.fire(event, data)` executes configured shell scripts. Synchronous subprocess execution. No async, no retry, no timeout enforcement documented. Scripts receive JSON data via stdin or environment.

---

## 8. Configuration and Environment Model

### Config Hierarchy

1. Hard defaults in dataclass field defaults (`config.py`)
2. Global overrides: `~/.synthadoc/config.toml`
3. Project overrides: `<wiki>/.synthadoc/config.toml` (wins on conflict)

Loaded via `load_config(project_config=...)` at startup.

### Required Environment Variables

At minimum one of:
- `ANTHROPIC_API_KEY` — for `anthropic` provider
- `OPENAI_API_KEY` — for `openai` provider
- `GEMINI_API_KEY` — for `gemini` provider (free tier available)
- `GROQ_API_KEY` — for `groq` provider (free tier available)
- `MINIMAX_API_KEY`, `DEEPSEEK_API_KEY` — for respective providers
- No API key needed for `ollama`, `claude-code`, `opencode`

Optional:
- `TAVILY_API_KEY` — for `web_search` skill; without it, web search intent fails
- `SYNTHADOC_WIKI` — override default wiki selection
- `SYNTHADOC_WIKI_ROOT` — set by server process for skills to read blocked domains

### Important Config Keys

```toml
[agents]
default = { provider = "gemini", model = "gemini-2.0-flash-lite" }
ingest  = { provider = "anthropic", model = "claude-3-5-haiku-20241022" }  # optional override

[ingest]
max_pages_per_ingest = 15
chunk_size = 1500
staging_policy = "off"   # "off" | "all" | "threshold"

[query]
gap_score_threshold = 2.0
context_token_budget = 4000

[search]
vector = false   # set true + pip install synthadoc[vectors] for hybrid

[server]
port = 7070

[schedule]
jobs = [
  { op = "lint", cron = "0 2 * * *" },
]
```

### Runtime Modes

- **Normal**: `synthadoc serve` (foreground)
- **Background**: `synthadoc serve --background` (subprocess re-exec with `--no-daemon` suppressed)
- **HTTP-only**: `synthadoc serve --http-only`
- **MCP-only**: `synthadoc serve --mcp-only` (partial/buggy)
- **Demo install**: `synthadoc install history-of-computing --target <dir> --demo`

---

## 9. Operational Usage Model

### Canonical Workflow

```
1. Install:     pip install -e .
2. Create wiki: synthadoc install <name> --target <dir> --domain "My Domain"
3. Set default: synthadoc use <name>
4. Start server: synthadoc serve -w <name>   [or --background]
5. Ingest:      synthadoc ingest <path/url> -w <name>
                synthadoc ingest "search for: topic to research" -w <name>
6. Query:       synthadoc query "What do I know about X?" -w <name>
7. Lint:        synthadoc lint run -w <name>
                synthadoc lint report -w <name>
8. Inspect:     synthadoc jobs list -w <name>
                synthadoc audit -w <name>
9. Maintain:    synthadoc scaffold -w <name>  (regenerate index/overview)
                synthadoc routing view -w <name>  (optional thematic routing)
```

### Multi-Wiki Pattern

Synthadoc supports multiple named wikis registered in `~/.synthadoc/wikis.json`. Run separate server instances on different ports per wiki. `synthadoc use` switches default; `-w <name>` overrides per-command.

### Obsidian Integration

```
1. synthadoc plugin install <wiki>  (copies plugin to wiki/.obsidian/plugins/)
2. Open wiki dir as Obsidian vault
3. Plugin settings: server URL (default: http://127.0.0.1:7070), raw_sources folder
4. Use plugin commands: Ingest Active File, Ingest Folder, Query Wiki, etc.
```

### Scheduled Maintenance

Declare jobs in config, then apply them into the host scheduler:

```toml
[schedule]
jobs = [
  { op = "lint", cron = "0 2 * * *" },
]
```

```bash
synthadoc schedule apply -w <name>
synthadoc schedule list -w <name>
```

---

## 10. Extension and Customization Architecture

### Adding a Skill

1. Create `my_skill/` directory with `SKILL.md` + `scripts/main.py`
2. Implement `BaseSkill.extract(source) → ExtractedContent` (Apache-2.0 base)
3. Place in `~/.synthadoc/skills/` (global) or `<wiki>/skills/` (wiki-local) or publish on PyPI with `entry_points("synthadoc.skills")`
4. No restart needed; registry is rebuilt per dispatch

`SKILL.md` frontmatter:
```yaml
---
name: my_skill
description: Extracts content from .xyz files
version: "1.0"
entry_script: scripts/main.py
entry_class: MySkillSkill
triggers:
  extensions: [".xyz"]
  intents: []
requires: []
---
```

### Adding a Provider

1. Subclass `LLMProvider` (Apache-2.0 base, `providers/base.py`)
2. Implement `async complete(messages, system, temperature, max_tokens) → CompletionResponse`
3. Register in `providers/__init__.py:make_provider()` + add to `KNOWN_PROVIDERS` set in `config.py`
4. Add env var check in `cli/serve.py` provider validation block

### Hooks

Config in `.synthadoc/config.toml`:
```toml
[hooks]
on_ingest_complete = "hooks/git-auto-commit.py"
on_lint_complete   = ""
```

Hook scripts receive event data as JSON. The repo ships `hooks/git-auto-commit.py` as a reference implementation.

### Entry-Point Skills (PyPI-distributable)

```toml
# in third-party package's pyproject.toml
[project.entry-points."synthadoc.skills"]
my_skill = "/absolute/path/to/my_skill_folder"
```

---

## 11. Key Architectural Decisions and Tradeoffs

### Ingest-Time Compilation

**Decision**: LLM synthesis happens once per source at ingest, not per query.
**Benefit**: contradictions are permanently recorded; queries hit structured knowledge; offline browsability.
**Cost**: ingest is expensive (LLM calls); re-ingestion required when prompts or models change.
**Evidence**: `_DECISION_PROMPT` in `ingest_agent.py`; `WikiPage.contradiction_note` field.

### SQLite for All Operational State

**Decision**: jobs, audit, cache, embeddings all live in SQLite files under `.synthadoc/`.
**Benefit**: zero-dependency persistence; survives restarts; transactional; easy to inspect.
**Cost**: single-writer contention; no built-in replication.
**Evidence**: `core/queue.py`, `storage/log.py`, `core/cache.py`, `storage/search.py`.

### Sequential Worker Loop

**Decision**: single worker coroutine, one job at a time.
**Benefit**: simple; eliminates LLM API concurrency issues; predictable cost.
**Cost**: queue throughput bottleneck for batch ingest.
**Evidence**: `http_server.py:199-242`; `max_parallel_ingest=4` in config has no runtime effect.

### Markdown-as-Artifact

**Decision**: output is plain Markdown readable without any tool.
**Benefit**: Obsidian integration; git-friendly; portable.
**Cost**: schema changes require file migration; no query optimization from structured storage.
**Evidence**: `WikiStorage.write_page()` in `storage/wiki.py`.

### AGPL + Apache-2.0 Split

**Decision**: engine is AGPL-3.0; extension interfaces (`providers/base.py`, `skills/base.py`) are Apache-2.0.
**Intent**: lets third parties write skills/providers under any license while keeping the engine copyleft.
**Evidence**: license headers in `providers/base.py:1-2`, `skills/base.py:1-2`.

### BM25-First Search

**Decision**: BM25 always available; vectors are an opt-in extra dependency (`fastembed`, requires Rust).
**Benefit**: works out of the box; warm queries reuse an in-memory corpus cache.
**Cost**: there is still no persistent index, so process restarts and post-write invalidations force a full corpus rebuild from disk.

---

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 1. CostGuard Not Enforced at Runtime

`CostGuard` (`core/cost_guard.py`) is constructed in `Orchestrator.__init__` and cost is estimated post-ingest (`providers/pricing.py`), but no `check()` or `gate()` call exists in `_run_ingest()` or `query()`. Cost config (`soft_warn_usd`, `hard_gate_usd`) has no runtime effect.

**Risk**: unbounded LLM spend during automated ingestion.

### 2. MCP Server Has Mismatched API Calls

`integration/mcp_server.py:21-26`: `o.ingest(source, auto_confirm=True)` — but `Orchestrator.ingest(source, force=False)` has no `auto_confirm` parameter. `mcp_server.py:35-41`: treats `o.lint()` return value as a report object, but it returns a `str` job ID.

**Risk**: MCP tools silently fail or raise exceptions.

### 3. Query Routing Not Wired

`QueryAgent` has `routing_path` parameter and `_routing_branch_pick()` implementation, but `Orchestrator.query()` never passes a routing path. The `ROUTING.md` feature appears fully implemented in isolation but is never engaged during normal operation.

### 4. Parallel Queue is Config-Only

`QueueConfig.max_parallel_ingest = 4` is never read by the worker loop. The worker loop is strictly sequential.

### 5. `query --save` Flag Not Implemented

CLI accepts `--save` option; HTTP endpoint accepts `save: bool` in request body; neither has save logic.

### 6. BM25 Has No Persistent Index

`HybridSearch` keeps an in-memory `_cached_corpus`, so warm queries do **not** rebuild the corpus every time. However, there is no persisted BM25 index on disk; startup and any post-write invalidation force a full `list_pages()` + `read_page()` + tokenize rebuild (`storage/search.py:150-164`).

**Risk**: query latency degrades with wiki size.

### 7. `web_search` SKILL.md Says Stub

`synthadoc/skills/web_search/SKILL.md:35-49` describes the skill as a stub, but `scripts/main.py` has a full Tavily API implementation. Documentation is stale.

### 8. Design Doc Storage Schema Stale

`docs/design.md:478-515` describes storage schema field names that don't match actual column names in `storage/log.py:60-90`.

### 9. README Version Mismatch

`VERSION` file says `0.3.0`; `README.md` badge says `v0.4.0 in progress`. The released version is 0.3.0.

---

## 13. Practical Usage Guide

### Minimal Viable Usage

```bash
pip install -e .
export GEMINI_API_KEY=<free-tier-key>
synthadoc install demo-wiki --target ~/wikis --domain "AI research"
synthadoc use demo-wiki
synthadoc serve -w demo-wiki &
sleep 3
synthadoc ingest "search for: history of neural networks" -w demo-wiki
synthadoc query "When were transformer models introduced?" -w demo-wiki
```

### Operational Assumptions

- **Local machine only**: server binds `127.0.0.1`; not exposed on network.
- **Single writer**: no multi-process concurrency guarantees beyond `FileLock`.
- **LLM API required**: unless using `ollama` or `claude-code`/`opencode` CLI providers.
- **Source files inside wiki root**: `IngestAgent` rejects local paths outside `wiki_root`. Place documents in `raw_sources/`.
- **Long-running server**: CLI commands for ingest/query require the server to be running.

### Canonical Workflow

See §9.

### Advanced Usage

```bash
# Parallel multi-source ingest via job queue
synthadoc ingest raw_sources/ -w my-wiki --batch

# Forced re-ingest ignoring dedup
synthadoc ingest raw_sources/paper.pdf -w my-wiki --force

# Web search with custom result count
synthadoc ingest "search for: quantum computing 2025" -w my-wiki --max-results 10

# Auto-resolve contradictions during lint
synthadoc lint run -w my-wiki --auto-resolve

# Per-agent provider override
# Edit .synthadoc/config.toml:
# [agents]
# ingest = { provider = "anthropic", model = "claude-3-5-haiku-20241022" }

# Enable vector search
pip install synthadoc[vectors]
# Add to .synthadoc/config.toml: [search] vector = true
# Restart server; background migration embeds all pages

# Git hook on every ingest
# Add to .synthadoc/config.toml:
# [hooks]
# on_ingest_complete = "hooks/git-auto-commit.py"
```

### Extension Workflow

1. **New skill**: create `my_skill/SKILL.md` + `scripts/main.py`, inherit `BaseSkill`, place in `~/.synthadoc/skills/my_skill/` or wiki-local `skills/` directory.
2. **New provider**: subclass `LLMProvider`, register in `providers/__init__.py`, add to `KNOWN_PROVIDERS`.
3. **Custom prompts**: modify `_ANALYSIS_PROMPT` / `_DECISION_PROMPT` constants in `ingest_agent.py` (careful — changes invalidate cache and alter all ingest behavior).

### Debugging Workflow

```bash
# Check server health
synthadoc status -w my-wiki

# List jobs with status
synthadoc jobs list -w my-wiki

# View job details
synthadoc jobs status <job-id> -w my-wiki

# View audit trail
synthadoc audit history -w my-wiki
synthadoc audit cost -w my-wiki
synthadoc audit queries -w my-wiki
synthadoc audit events -w my-wiki

# View human-readable log
cat ~/my-wiki/log.md

# Increase log verbosity
# Set in .synthadoc/config.toml: [logs] level = "DEBUG"
synthadoc serve -w my-wiki --verbose

# Clear LLM cache (force fresh LLM calls)
synthadoc cache clear -w my-wiki

# Inspect OTEL traces
cat ~/my-wiki/.synthadoc/logs/traces.jsonl | python -m json.tool

# Inspect jobs DB directly
sqlite3 ~/my-wiki/.synthadoc/jobs.db "SELECT id, operation, status, error FROM jobs ORDER BY created_at DESC LIMIT 20;"
```

### Observability

| Signal | Location | Format |
|---|---|---|
| Structured traces | `.synthadoc/logs/traces.jsonl` | JSONL (OpenTelemetry) |
| Human-readable log | `log.md` (wiki root) | Markdown |
| Job audit | `.synthadoc/audit.db` | SQLite |
| Job history | `.synthadoc/jobs.db` | SQLite |
| Console logs | stdout/stderr | Structured with `rich` |

### Failure Modes

| Failure | Behavior |
|---|---|
| LLM API key missing | Server refuses to start (`ERR-CFG-001`) |
| LLM 401 (bad key) | HTTP 401 returned with actionable message; job fails |
| LLM 429 (rate limit) | Worker backs off (parses retry-after); job retried up to max_retries |
| LLM daily quota | Job permanently failed; worker logs and continues |
| Domain returns 403 | Auto-added to `.synthadoc/blocked_domains.json`; job skipped (no retry) |
| Source outside wiki_root | Ingest immediately rejected with error |
| Server not running | CLI commands return `ERR-SRV-001` |
| Source already ingested | Dedup check skips (returns `skipped=True`) unless `--force` |

### Performance Considerations

- **BM25 warm/cold split**: warm queries reuse the in-memory corpus; startup and post-write invalidation still pay an O(n pages) rebuild.
- **LLM cache hit rate**: repeat ingests of identical content are free after first run; cache version bump invalidates all.
- **Vector init migration**: on first start with vector search enabled, embeds all pages in background; initial queries still use BM25 during migration.
- **Sequential worker**: ingest throughput capped at ~1 job per LLM-call-duration (typically 2-10 seconds per page).
- **Chunk size**: `ingest.chunk_size = 1500` controls text sent per LLM call; larger chunks = more context but more tokens.

---

## 14. Project Navigation Guide

### Critical Files

| File | Role |
|---|---|
| `synthadoc/agents/ingest_agent.py` | **Semantic center**: wiki compilation logic, decision prompts |
| `synthadoc/agents/query_agent.py` | Knowledge retrieval, gap detection, synthesis |
| `synthadoc/core/orchestrator.py` | Runtime authority: owns all subsystems, dispatches agents |
| `synthadoc/integration/http_server.py` | FastAPI app, worker loop, endpoint definitions |
| `synthadoc/storage/wiki.py` | WikiPage data model, Markdown I/O |
| `synthadoc/storage/search.py` | BM25 + vector search |
| `synthadoc/config.py` | All config dataclasses, known providers |
| `synthadoc/cli/main.py` | CLI entry point, all command registration |
| `synthadoc/providers/base.py` | LLMProvider ABC (Apache-2.0) |
| `synthadoc/skills/base.py` | BaseSkill ABC (Apache-2.0) |
| `synthadoc/errors.py` | Error code registry |

### Best Reading Order

1. `docs/design.md` — conceptual overview (some stale details but good mental model)
2. `synthadoc/core/orchestrator.py` — runtime topology
3. `synthadoc/agents/ingest_agent.py` — semantic center (focus on `_DECISION_PROMPT` and `ingest()`)
4. `synthadoc/storage/wiki.py` — data model
5. `synthadoc/integration/http_server.py` — API surface + worker loop
6. `synthadoc/agents/query_agent.py` — retrieval semantics
7. `synthadoc/config.py` — all configurable knobs
8. `synthadoc/skills/base.py` + any skill in `synthadoc/skills/` — extension pattern
9. `synthadoc/providers/base.py` + `providers/openai.py` — provider pattern

### Highest-Value Execution Paths

- **Ingest decision logic**: `ingest_agent.py:ingest()` → `_DECISION_PROMPT` → `WikiStorage.write_page()`
- **Query gap detection**: `query_agent.py:query()` → `_detect_knowledge_gap()` → BM25 score vs threshold
- **Job lifecycle**: `http_server.py:_worker_loop()` → `orchestrator._run_ingest()` → `queue.complete()`
- **Skill dispatch**: `skill_agent.py:detect_skill()` / `extract()` → registry lookup → `BaseSkill.extract()`

### Semantic Centers

1. `ingest_agent.py` — where wiki maintenance intelligence lives
2. `_DECISION_PROMPT` constant — where LLM behavioral policy is encoded
3. `orchestrator.py` — where execution authority resides
4. `storage/wiki.py:WikiPage` — the central data structure of the artifact

---

## 15. Concise Deep Technical Synthesis

Synthadoc is a **local-first, queue-driven, ingest-time LLM wiki compiler** that inverts the RAG model: rather than synthesizing on every query, it synthesizes once at ingest time and stores the result as structured plain-Markdown knowledge. The primary artifact — `wiki/*.md` files with YAML frontmatter — is both the output and the persistence layer.

**Architectural pattern**: a single orchestrator-owned, SQLite-backed, sequential job queue drives all expensive operations through specialized agents. The runtime is a FastAPI/asyncio process with a polling worker loop. Access is via CLI (thin HTTP proxy), REST API, and Obsidian plugin.

**What makes it distinctive**: the ingest-time compilation model with explicit `create/update/flag/skip` decision semantics, automatic contradiction detection persisted in page frontmatter, and the Markdown-as-artifact philosophy (wiki readable without any tool running).

**Mental model**: think of it as a **personal knowledge compiler with a persistent typed IR** (the wiki pages). Raw sources are the input program; LLM synthesis is the compilation step; Markdown pages with YAML are the compiled IR; query agents read the IR rather than the raw source.

**Optimized for**: solo researchers, small teams, and knowledge workers who want an autonomous, locally-controlled knowledge base that grows incrementally as new documents are ingested, without cloud lock-in or RAG-style query-time synthesis costs.
