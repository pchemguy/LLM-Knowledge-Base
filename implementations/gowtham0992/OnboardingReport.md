---
repo: gowtham0992/link
---

# Link Onboarding Report

## SYNOPSIS

### Implementation Identity

**Observed:** Link is a **local, filesystem-backed memory/wiki runtime for external LLM agents**, not a hosted knowledge service. The shared behavioral core lives in `mcp_package/link_core/`; three adapters expose it through the CLI (`link.py`), a local-only HTTP/UI server (`serve.py`), and an MCP server (`mcp_package/link_mcp/server.py`).

**Observed:** The dominant architectural style is **adapter-over-shared-core, request-driven orchestration**. Runtime intelligence lives primarily in `mcp_package/link_core/memory.py`, `query.py`, `wiki.py`, `ingest.py`, `validation.py`, and `status.py`, not in the UI or installer layer.

**Inference:** The repo is best understood as a **local memory substrate** for agents: persistent Markdown state, bounded retrieval packets, and explicit human-reviewable memory writes.

### Quick Adaptation Assessment

The repo is reasonably modular at the core level, but not fully cleanly layered. New behavior should usually land in `mcp_package/link_core/` and then be surfaced through `link.py`, `serve.py`, and `mcp_package/link_mcp/server.py`. The main coupling constraints are:

- page-format and directory conventions enforced by `mcp_package/link_core/validation.py`;
- request/response contracts enforced by `scripts/check_tool_contract.py`;
- anti-duplication pressure across runtimes enforced by `scripts/check_runtime_duplication.py`.

Modifying retrieval, memory lifecycle, ingest guidance, or validation is straightforward once inside the core. Modifying the public protocol is higher-friction because CLI, MCP, docs, tests, and smoke checks are intentionally kept aligned.

### Fastest Path to First Successful Run

**Observed in `README.md` and `link.py:create_demo`:**

```bash
python link.py demo
python link.py serve link-demo
```

Then open:

- `http://127.0.0.1:3000`
- `http://127.0.0.1:3000/graph`

This is the shortest path because `demo` creates a fully populated sample wiki, raw sources, backlinks, starter memory, and guidance files without needing an external agent to ingest anything.

### Minimal Manual Setup Path

The manual path is distinct from the bash installers and is the most direct way to run Link on a machine where the installer workflow is inconvenient.

```bash
python link.py init my-link
python link.py status --validate my-link
python link.py serve my-link
```

For MCP without the installer:

```bash
python -m pip install .\mcp_package
python -m link_mcp --wiki .\my-link\wiki
```

Minimum requirements:

1. A Link root containing `raw/`, `wiki/`, `link.py`, `serve.py`, `LINK.md`, and `link_core/` (`link.py init` scaffolds this).
2. A valid `wiki/` structure with `index.md`, `log.md`, `_backlinks.json`, and category folders.
3. Python 3.10+; actual package metadata is in `mcp_package/pyproject.toml`, while the repo root `pyproject.toml` is Ruff-only.

### Operational Complexity Snapshot

Setup is moderate, but runtime behavior is intentionally simple: no database, no broker, no daemon swarm, no remote APIs. Operational fragility is concentrated in local file correctness, page-format correctness, cache freshness, and explicit repair loops (`doctor`, `rebuild-index`, `rebuild-backlinks`, `validate`, `status --validate`). Observability is decent for a local tool through diagnostics and tests, but there is no telemetry, no metrics pipeline, and no structured distributed tracing.

### Evidence Markers

- **Observed:** directly grounded in repository files, symbols, tests, or docs.
- **Inference:** likely architectural intent inferred from repeated implementation patterns.
- **Speculative:** plausible but not strongly enforced; treat carefully.

## 1. Repository Purpose

**Observed:** The implemented purpose is narrower and more operational than the abstract “LLM wiki” idea. Link stores:

- raw source documents under `raw/`;
- source-backed wiki pages under `wiki/`;
- explicit cross-session agent memory under `wiki/memories/`;
- derived search/backlink/cache state next to that filesystem content.

`README.md`, `LINK.md`, `mcp_package/README.md`, and `mcp_package/link_core/query.py` consistently frame the product as **local personal memory for agents**, with the wiki acting as inspectable storage and the MCP/CLI/UI acting as access surfaces.

**Conceptual mapping to the provided LLM Wiki idea:**

- The repo **does implement** the raw/wiki/schema layering (`raw/`, `wiki/`, `LINK.md`).
- It **extends** the idea with a separate, explicit memory subsystem (`wiki/memories/`) and a review/audit lifecycle.
- It **constrains** the idea by not automating ingestion end-to-end. Link tells an external agent what to ingest, validates the result, and provides retrieval after ingest, but the source-to-page authoring step is intentionally left to the agent/human workflow rather than internal code.

**Real problem being solved:** agents repeatedly forget local context across sessions. Link turns local context into inspectable Markdown state with retrieval, validation, and explicit memory persistence.

**Target use cases:**

- persistent agent context for one user;
- project-scoped memory for a repo;
- source-backed local knowledge bases browsed through CLI/UI/MCP;
- safe capture of “remember this later” material before durable memory approval.

**Scope boundaries:**

- not a hosted multi-user wiki;
- not an automatic ingestion pipeline;
- not a general-purpose notes app;
- not a remote/vector database service;
- not a background sync engine.

## 2. High-Level System Model

Link behaves like a **local agent memory runtime with a Markdown knowledge store**, organized around three concerns:

1. **Read-side retrieval**: search, graph traversal, memory recall, and bounded context packets (`wiki.py`, `search.py`, `query.py`).
2. **Write-side memory control**: explicit durable memory creation, updates, review, archival, deletion, capture, and audit (`memory.py`, `capture.py`, `files.py`).
3. **Operational readiness**: ingest guidance, validation, backups, schema migration, status, and repair (`ingest.py`, `validation.py`, `status.py`, `backup.py`, `schema.py`).

The dominant architectural identity is **orchestration-light but protocol-heavy**:

- control is centralized per request in the adapter calling shared core functions;
- state lives in the filesystem, not in a service or process manager;
- coordination is mostly synchronous and direct;
- the main semantics come from **how Link constrains reads and writes**, not from a complex scheduler.

The behavioral intelligence lives primarily in:

- `mcp_package/link_core/memory.py` for deciding what counts as durable memory and how safe memory mutation works;
- `mcp_package/link_core/query.py` for producing budgeted packets rather than dumping the wiki;
- `mcp_package/link_core/ingest.py` for turning filesystem state into guided next actions;
- `mcp_package/link_core/validation.py` for enforcing page shape and link consistency.

**Inference:** this shape exists to keep Link inspectable and local-first. The repo prefers conservative, auditable file operations over clever automation.

## 3. Conceptual Capability Mapping

| Conceptual capability | Implementation status | Primary owner | Execution semantics | Limits / tradeoffs |
|---|---|---|---|---|
| Persistent wiki over raw sources | **Implemented** | `raw/`, `wiki/`, `LINK.md`, `mcp_package/link_core/wiki.py` | Raw files are immutable inputs; wiki pages are Markdown outputs; cache/search/backlinks are derived from wiki content. | Link does not itself synthesize wiki pages from raw files. |
| Source-backed retrieval | **Implemented** | `query.py`, `wiki.py`, `search.py` | `query_link` merges memory recall, ranked wiki results, and graph neighborhood into bounded packets with provenance and follow-up actions. | Bounded by design; full answers are external agent responsibility. |
| Explicit durable memory | **Implemented** | `memory.py` | `write_memory_page`, `update_memory_page`, `set_memory_status`, `forget_memory_page`, `mark_memory_reviewed` manage memory as Markdown under `wiki/memories/`. | Conservative writes; duplicates/conflicts are blocked unless explicitly overridden. |
| Memory proposal workflow | **Implemented** | `memory.py:propose_memories_from_text`, `capture.py` | Text is segmented/classified into candidate memories, but proposals are non-persistent until explicitly accepted. | Heuristic, regex-based classification; not a semantic planner. |
| Session capture before approval | **Implemented** | `capture.py`, CLI/MCP/UI adapters | Long notes are stored under `raw/memory-captures/`; durable memory remains proposal-only until approval. | Adds review steps; intentionally not one-shot automation. |
| Ingest management | **Partially implemented** | `ingest.py`, docs, adapters | Link detects pending/stale/blocked raw sources, suggests prompts, and recommends post-ingest repair steps. | No internal `ingest` command that authoritatively writes source pages. |
| Graph exploration | **Implemented** | `wiki.py`, `web_graph.py`, `serve.py`, MCP tools | Wikilinks become forward/backlink graphs; bounded summaries exist for agent-safe use; full graph export exists for explicit requests. | Large graphs are intentionally summarized first. |
| Validation/linting of wiki pages | **Implemented** | `validation.py` | Enforces frontmatter, directory/type alignment, required sections, dead links, and backlink freshness. | Validation is structural; it does not judge factual correctness. |
| Local web UI | **Implemented** | `serve.py`, `web_*` core modules | Loopback-only UI for browsing, reviewing, querying, and limited local mutations. | Not intended for internet exposure or multi-user deployment. |
| MCP integration | **Implemented** | `mcp_package/link_mcp/server.py` | Exposes the shared core as tool calls with a strong usage contract in the server instructions. | Server resolves wiki path and exits at import time if missing. |
| Installer/setup automation | **Implemented, Unix-centric** | `integrations/`, `_shared/scaffold.sh` | Shell scripts scaffold `~/link` or project-local Link, install `link-mcp`, add light agent instructions, and print next commands. | Bash-centric; manual Python path is the simpler cross-platform route. |

## 4. Architecture and Component Analysis

### 4.1 Shared Core (`mcp_package/link_core/`)

This directory is the actual product runtime.

| Module | Responsibility | Architectural significance |
|---|---|---|
| `memory.py` | durable memory records, recall ranking, duplicate/conflict checks, review lifecycle, profile/audit/explanation, proposal heuristics | Highest semantic density in the repo |
| `query.py` | answer-ready packet construction, budgets, provenance trimming, follow-up planning | Defines how agents should consume Link |
| `wiki.py` | wiki scanning, persistent cache, page metadata extraction, context assembly, backlinks and graph data | Core read model |
| `search.py` | token search and optional in-memory SQLite FTS5 acceleration | Performance-critical support layer |
| `ingest.py` | raw/source scanning, safety/access checks, stale detection, guided action plan | Encodes operational ingest semantics |
| `validation.py` | schema/section/link correctness gates | Safety rail after agent edits |
| `status.py` | compact readiness summary and next actions | Entry-point diagnostic model |
| `files.py` | atomic writes, lock files, append-under-lock | Local durability primitive |
| `capture.py` | raw capture files and proposal review | Separation of capture from durable memory |
| `backup.py`, `schema.py`, `benchmark.py`, `raw.py`, `security.py`, `prompts.py` | maintenance/support concerns | Operational infrastructure |

**Observed:** the core owns almost all business semantics. The adapters mostly translate command-line arguments, HTTP parameters, or MCP tool calls into these functions.

### 4.2 CLI Adapter (`link.py`)

`link.py` is both:

- a public command surface (`main`);
- a thin orchestrator for init/demo/serve/status/query/memory/repair flows.

Key responsibilities:

- scaffolding a new wiki (`init_wiki`);
- generating a proof/demo wiki (`create_demo`);
- exposing memory/query/status/repair commands;
- verifying installed MCP environment (`verify_mcp`).

**Observed:** `link.py` still contains meaningful orchestration, especially around demo/init/setup and some operational flows. The anti-duplication guard and changelog suggest an ongoing migration of shared logic into `link_core`, but the CLI is not merely a trivial wrapper yet.

### 4.3 Local HTTP/UI Adapter (`serve.py`)

`serve.py` is a local control plane, not a general web app. It:

- binds only to `127.0.0.1`;
- rejects host/bind flags;
- validates `Host`, `Origin`, and `Referer` for mutations;
- requires `X-Link-Local-Action`;
- rate-limits writes;
- serves HTML pages plus JSON APIs over the same core functions.

Important role boundaries:

- UI rendering and HTTP routing remain here;
- Markdown rendering, layout, graph helpers, memory cards, and security header helpers were split into `link_core.web_*` modules.

**Observed:** the web layer is intentionally trusted-local and browser-hardened, but still monolithic in routing terms (`Handler` in `serve.py`).

### 4.4 MCP Adapter (`mcp_package/link_mcp/server.py`)

The MCP server is a contract-heavy adapter:

- parses `--wiki` at module import time;
- exits early if the wiki is missing or the MCP SDK is unavailable;
- creates one `FastMCP` instance with extensive usage instructions;
- exposes tools that mirror the core and public product language.

Architecturally, this is the surface that turns Link from “local files” into “agent memory infrastructure”.

### 4.5 Installers and Integration Layer (`integrations/`)

The integration scripts do not add runtime semantics; they operationalize setup:

- scaffold Link into `~/link` or a project directory;
- install/upgrade `link-mcp`;
- write lightweight agent instructions;
- optionally add a `link` wrapper under `~/.local/bin`.

**Inference:** installers are productization glue. They matter operationally, but not as the semantic center of the system.

### 4.6 Docs, Guards, and Tests

The repo treats docs and public contracts as part of the implementation:

- `scripts/check_tool_contract.py` asserts CLI/MCP/doc parity;
- `scripts/check_runtime_duplication.py` pressures contributors to move shared logic into the core;
- `scripts/check_release_hygiene.py` enforces local-first/no-secret release rules;
- the test suite covers CLI, MCP, serve, status, ingest, validation, large-wiki smoke, and docs site consistency.

This is strong evidence that Link is being maintained as a coherent product rather than as a loose script collection.

## 5. Execution Flow Analysis

### 5.1 Startup and Initialization

#### New wiki

1. `link.py init` calls `init_wiki`.
2. Runtime files are copied into the target (`serve.py`, `link.py`, `LINK.md`, `.linkignore`, `link_core/`, logos).
3. Structural fixes are applied through the doctor/fix path.
4. The user is guided toward `status --validate`, `serve`, and raw ingestion.

This is not just folder creation; it creates a self-contained runnable Link root.

#### Demo wiki

1. `link.py demo` creates a guarded demo directory.
2. Bundled runtime files and demo Markdown payloads are written.
3. Backlinks are rebuilt and schema markers written.
4. The user is given a value loop: `query`, `brief`, `memory-audit`, `serve`.

Tests (`tests/test_demo_snapshot.py`) treat the demo as the canonical proof state.

### 5.2 Cache Build / Read Path

1. Adapter asks for wiki data.
2. `wiki.py:build_wiki_cache` scans Markdown pages, optionally reuses `.link-cache/wiki-cache-v1.json`, parses frontmatter/body, computes tokens/snippets/forward links, and optionally builds an in-memory SQLite FTS index.
3. The adapter caches that data in-process:
   - CLI and MCP cache per invocation/on-demand;
   - `serve.py` keeps a global cache invalidated by wiki mtime with a short poll interval.

**State mutation:** none; this is a derived read model.

### 5.3 Query / Retrieval Flow

1. Adapter normalizes query input.
2. `query.py:query_link` chooses a budget (`small|medium|large`).
3. It recalls relevant memories via `memory.py`.
4. It performs ranked wiki search via `search.py`.
5. It expands the best wiki match into a graph neighborhood via `wiki.py:context_for_topic`.
6. It compacts everything into `context_packet`, `budget_report`, and `follow_up`.

This is the primary execution path for user-facing “what does Link know?” questions. The design goal is bounded, provenance-rich retrieval, not direct answer generation.

### 5.4 Memory Write Flow

1. CLI/MCP/UI receives a memory request.
2. Adapter sanitizes/normalizes inputs and project scope.
3. `memory.py:write_memory_page` or `update_memory_page` checks duplicates/conflicts against current memory records.
4. On success, it writes Markdown under `wiki/memories/`, updates `wiki/index.md`, appends to `wiki/log.md`, and optionally rebuilds backlinks.
5. Adapters clear their caches.

**Observed invariant:** durable memory writes are explicit, logged, and review-gated. New/updated memory returns to `review_status: pending`.

### 5.5 Memory Review / Archive / Forget Flow

`mark_memory_reviewed`, `set_memory_status`, and `forget_memory_page` all resolve the target page, mutate frontmatter or delete the file, update supporting indexes/logs, and return structured status. `forget` requires explicit confirmation and deliberately does not log memory body contents.

### 5.6 Capture Flow

1. Long notes are passed to `capture_session`.
2. A raw capture file is written under `raw/memory-captures/`.
3. Proposals are generated from the captured text.
4. Human review is expected before `accept_capture` writes durable memory.

This separates “preserve the conversation locally” from “make it durable recallable memory”.

### 5.7 Ingest Readiness Flow

1. `ingest.py:collect_ingest_status` scans `raw/` excluding `raw/memory-captures/`.
2. It scans source pages under `wiki/sources/`.
3. It matches raw file references, compares mtimes, checks secret-looking values, checks read failures, and checks backlink health.
4. It emits:
   - `guidance.state`;
   - safety diagnostics;
   - a stepwise ingest plan;
   - completion summaries;
   - an exact next prompt for an external agent when appropriate.

**Observed:** this is a control plane for ingestion, not the ingest worker itself.

### 5.8 HTTP Mutation Flow

1. `serve.py` validates loopback `Host`.
2. For writes, it requires `X-Link-Local-Action` and validates `Origin`/`Referer`.
3. It enforces a local rate limit.
4. It reads bounded JSON payloads and dispatches to shared core functions.
5. Responses carry no-store headers and API version information.

### 5.9 Shutdown / Recovery

There is no complex shutdown phase. Recovery is operational:

- rebuild backlinks if stale;
- rebuild index if drifted;
- validate after edits;
- run doctor/fix for structural repair;
- restore from `.link-backups/` if needed.

## 6. State and Persistence Model

### Durable state

- `raw/`: immutable source inputs plus `raw/memory-captures/`
- `wiki/`: authoritative Markdown knowledge and memory
- `wiki/_backlinks.json`: derived graph index
- `wiki/index.md`: human-oriented catalog
- `wiki/log.md`: append-only operation log
- `wiki/_link_schema.json`: schema marker
- `.link-backups/*.tar.gz`: local backups
- `.link-cache/wiki-cache-v1.json`: derived persistent cache
- `.link-mcp-python`: installer-selected Python executable marker
- `.link-demo`: marker used to safely overwrite demo directories only

### State ownership

- source knowledge state: `wiki/sources/`, `wiki/concepts/`, `wiki/entities/`, etc.
- explicit durable memory state: `wiki/memories/`
- operational metadata: backlinks, schema marker, log, index
- derived ephemeral runtime state: in-process caches in `serve.py` and `link_mcp.server`

### Mutation model

`files.py` provides:

- per-target lock files;
- temp-file write plus `os.replace`;
- `fsync` for files;
- append-under-lock for logs.

**Inference:** this is safe enough for single-machine local usage, but it is not a transaction manager. A multi-file write can still leave index/backlinks/log temporarily out of sync if interrupted between steps.

### Serialization model

- primary business state is Markdown with YAML frontmatter;
- auxiliary indexes are JSON;
- backups are tar.gz archives.

There is no database migration burden beyond the lightweight schema marker.

## 7. Coordination and Control Semantics

Link’s control topology is **centralized per request, distributed by surface**:

- CLI controls one-off command execution.
- HTTP server controls per-request UI/API execution.
- MCP server controls per-tool-call execution.
- Shared core functions govern semantics.

### Where authority resides

- write safety authority: `memory.py`, `raw.py`, `security.py`
- read-budget authority: `query.py`, `wiki.py`
- ingest readiness authority: `ingest.py`
- structural correctness authority: `validation.py`
- readiness authority: `status.py`

### Delegation pattern

Adapters sanitize input, resolve root/wiki paths, and delegate to core. Core does not know whether it was called by CLI, HTTP, or MCP except via command-name strings used in hints/messages.

### Concurrency model

- no async event loop;
- no job queue;
- no actor/message bus;
- local write serialization only at file level;
- read caches invalidated by mtime.

### Failure propagation

Most failures are surfaced as structured error payloads or CLI exit codes rather than swallowed. The system prefers explicit degraded states:

- `link_status` returns warnings and `ready: false`;
- `ingest_status` returns blocked states;
- validation returns structured findings;
- backups and file-read failures are surfaced, not hidden.

### Routing semantics

Routing is mostly static:

- command name -> CLI function;
- URL path -> serve handler branch;
- MCP tool name -> decorated function.

The more dynamic routing occurs inside search/retrieval and memory conflict resolution, not at the transport layer.

## 8. Configuration and Environment Model

### Required configuration

- a Link root with `wiki/` and `raw/`;
- Python 3.10+;
- for MCP, a readable wiki path.

### Path and mode configuration

- `link.py` commands accept `target`, defaulting to `.`;
- `serve.py` accepts `--root` and `--port`;
- `link_mcp.server` accepts `--wiki`, defaulting to `~/link/wiki`;
- installers support global vs `--project` mode.

### Project scoping

Memory scoping is mostly data-level, not deployment-level:

- `scope: user | project | global`
- normalized project keys filter recall and duplicate/conflict checks.

### Packaging split

- repo root `pyproject.toml`: lint config only
- `mcp_package/pyproject.toml`: actual build/installable package metadata

This is an operational nuance that matters for builds and installs.

### Advanced setup knobs

Installer scripts use environment variables such as `LINK_CLI_DIR` and `LINK_MCP_VENV` to control wrapper/venv placement. Runtime itself is light on environment-variable configuration; path arguments dominate.

## 9. Operational Usage Model

### Canonical workflow

1. **Scaffold** a Link root (`init` or installer).
2. **Check readiness** with `status --validate` / `link_status`.
3. **Ask for starter prompts** if needed.
4. **Add raw files** under `raw/`.
5. **Use ingest guidance** (`ingest-status`) to determine the next safe ingest prompt.
6. **Have an external agent create/update wiki pages** according to `LINK.md`.
7. **Repair and validate** with `rebuild-index`, `rebuild-backlinks`, `validate`, `status --validate`.
8. **Use retrieval** with `query`, `brief`, search, graph summary, MCP tools, or the UI.
9. **Persist durable memory explicitly** only when the user approves remembering something.
10. **Review/audit** pending or stale memory via inbox/profile/audit/explain workflows.

### User interaction semantics

The human is expected to:

- curate raw sources;
- approve durable memories;
- inspect generated wiki pages when needed;
- use Link as a trusted local store, not as a black box.

The agent is expected to:

- ask Link for bounded context first;
- avoid direct whole-wiki reads unless needed;
- treat reviewed memory differently from pending memory;
- validate after edits;
- avoid unapproved durable memory writes.

### Development workflow

Contributors are expected to run:

- Ruff;
- `python -m unittest discover -s tests`;
- release hygiene;
- runtime duplication guard;
- tool contract guard.

Tests and CI make public-surface drift expensive by design.

## 10. Extension and Customization Architecture

Link is **not** a runtime plugin platform. Extension happens through controlled seams:

### 10.1 Shared-core extension

Add logic in `mcp_package/link_core/` when behavior should be shared across CLI, HTTP, and MCP.

### 10.2 Adapter extension

Expose new behavior through:

- `link.py` for CLI;
- `serve.py` for HTTP/UI;
- `mcp_package/link_mcp/server.py` for MCP.

Public changes should also update:

- docs (`docs/`, `README.md`, `mcp_package/README.md`);
- contract guards;
- tests.

### 10.3 Schema and page-shape extension

`LINK.md` defines page templates and agent workflow conventions. `validation.py` codifies the enforceable subset. If page shapes evolve, both need coordinated changes.

### 10.4 Integration extension

New agent integrations follow the pattern in `integrations/`: scaffold Link, install `link-mcp`, and upsert a lightweight instruction block.

### 10.5 Real extension boundary

The true reusable API is the **core module set plus the CLI/MCP protocol**, not a plugin registry or DI container.

## 11. Key Architectural Decisions and Tradeoffs

### Local-first over hosted convenience

**Observed:** no telemetry, no backend, no auth service, no network calls in the main runtime. This makes the system inspectable and privacy-preserving, but pushes all reliability and persistence concerns onto the local filesystem model.

### Markdown and JSON over a database

This maximizes inspectability and git-friendliness, but makes consistency repair an explicit concern (`rebuild-index`, `rebuild-backlinks`, validation).

### Explicit memory separate from source-backed wiki

This is the repo’s most important specialization beyond the generic LLM Wiki pattern. It creates a distinction between:

- factual/source-backed wiki knowledge;
- personalized durable memory with lifecycle and review semantics.

The benefit is trust and controllability; the cost is extra workflow.

### Bounded retrieval over maximal recall

`query_link`, `graph_summary`, and paginated page/link APIs are deliberately context-budget aware. The system optimizes for agent usability, not exhaustive dumps.

### Safety rails over full automation

Secret detection, duplicate/conflict blocking, archive-before-forget defaults, and web write restrictions all favor conservative behavior. This reduces accidental corruption but increases ceremony.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Ingest is operationally important but not internally automated

The docs and workflow heavily emphasize ingest, but the repo does not contain a first-class command that transforms raw files into source pages. Link governs ingest readiness and post-ingest validation, but an external agent still performs the actual synthesis.

### 12.2 `.linkignore` appears more aspirational than enforced

It is scaffolded and documented, but active runtime enforcement is not evident in the shared ingest/search code. Treat it as a convention unless implementation is added.

### 12.3 Root `wiki/` is scaffold state, not a trustworthy content snapshot

`README.md` explicitly says the tracked root wiki is scaffold-only. The checked-in `wiki/index.md` and `wiki/log.md` reference content that is not present in the tracked directories, so engineers should not treat the repo-root wiki as representative runtime data.

### 12.4 MCP server has import-time side effects

`mcp_package/link_mcp/server.py` parses CLI args and exits during module import if the wiki or MCP SDK is missing. This simplifies packaging but makes the module less composable and explains why tests import it carefully.

### 12.5 Adapter boundary is improving but still leaky

The repo has explicit guardrails against runtime duplication, yet `link.py` and `serve.py` still contain meaningful orchestration. The architectural direction is clear, but the separation is not fully complete.

### 12.6 Multi-file writes are not transactional

Atomic per-file writes reduce corruption risk, but cross-file state such as memory page + index + log + backlinks can still momentarily diverge.

### 12.7 Observability is local and manual

There are many diagnostics, but no metrics, no tracing, and no persistent runtime logs beyond `wiki/log.md`. Debugging depends on local commands and tests.

### 12.8 Installer path is Unix-biased

The repo’s installer experience is shell-script-first. The Python runtime is cross-platform, but the “official” integration path is friendlier on Unix-like machines than on Windows.

## 13. Practical Usage Guide

### Minimal Viable Usage

Use the demo for fastest success:

```bash
python link.py demo
python link.py serve link-demo
python link.py query "why does Link help agents?" link-demo --budget small
```

For a real workspace:

```bash
python link.py init my-link
python link.py status --validate my-link
python link.py serve my-link
```

### Operational Assumptions

- single-user or tightly controlled local usage;
- local filesystem is the durability layer;
- operator can inspect Markdown and run repair commands;
- agent has either CLI or MCP access;
- human approval is available for durable memory writes and destructive actions.

### Canonical Workflow

1. Start with `status --validate` or `link_status(include_validation=true)`.
2. Add raw sources.
3. Use `ingest-status` / `ingest_status` to get the exact next action.
4. Have the agent ingest externally according to `LINK.md`.
5. Run `rebuild-index`, `rebuild-backlinks`, `validate`, then `status --validate`.
6. Use `brief` / `memory_brief` and `query` / `query_link` during work.
7. Use `remember`, `update-memory`, or capture/propose/accept flows only when memory persistence is intended.

### Advanced Usage

- large-wiki evaluation with `benchmark` and `scripts/smoke_large_wiki.py` semantics;
- bounded graph orientation via `graph-summary` / `get_graph_summary`;
- project-scoped memory via `--project` / `project=...`;
- browser-first local workflows via `/ingest`, `/brief`, `/audit`, `/captures`, `/propose`, `/graph`.

### Extension Workflow

1. Put shared behavior in `mcp_package/link_core/`.
2. Add transport exposure in CLI/HTTP/MCP.
3. Update docs and contract checks.
4. Add tests in `tests/`.

### Debugging Workflow

Best diagnostic sequence:

1. `status --validate`
2. `doctor`
3. `ingest-status`
4. `rebuild-index`
5. `rebuild-backlinks`
6. `validate --strict`
7. `memory-audit` / `memory-inbox` / `explain-memory`
8. `benchmark` for large-wiki symptoms

### Observability

Primary inspection surfaces:

- `wiki/log.md`
- `status` / `link_status`
- `validate`
- `doctor`
- `memory-audit`
- `memory-inbox`
- `explain-memory`
- `/api/status`, `/api/validate`, `/api/query-link`, `/api/memory-*`
- unit tests and smoke scripts

### Failure Modes

- stale or invalid `_backlinks.json`;
- unreadable wiki pages causing degraded cache state;
- secret-looking values blocking raw-source or capture workflows;
- duplicate/conflicting memory creation attempts;
- missing/old schema marker;
- large wiki using token fallback instead of SQLite FTS;
- MCP package version drift caught by `verify-mcp`.

### Performance Considerations

- Search headroom is better when SQLite FTS5 is available; otherwise Link falls back to token indexing.
- Large wikis are expected to use bounded graph and page-list views first.
- Cache warmup cost is dominated by local file reads; persistent cache reduces repeated scans.
- `benchmark.py` encodes interactive thresholds; the large-wiki smoke suite expects the system to remain bounded at around 1000 synthetic pages.

## 14. Project Navigation Guide

### Best reading order

1. `README.md`
2. `link.py` (`init_wiki`, `create_demo`, `main`)
3. `mcp_package/link_mcp/server.py`
4. `mcp_package/link_core/memory.py`
5. `mcp_package/link_core/query.py`
6. `mcp_package/link_core/wiki.py`
7. `mcp_package/link_core/ingest.py`
8. `mcp_package/link_core/validation.py`
9. `serve.py`
10. `tests/test_demo_snapshot.py`, `tests/test_mcp_contract.py`, `tests/test_link_cli.py`, `tests/test_ingest_core.py`, `tests/test_status_core.py`, `tests/test_serve.py`

### High-value entry points

| Path / symbol | Why it matters |
|---|---|
| `link.py:main` | full CLI contract |
| `link.py:init_wiki` | real scaffolding semantics |
| `link.py:create_demo` | proof/demo generation and expected first-run experience |
| `mcp_package/link_mcp/server.py` | agent-facing tool contract and adapter behavior |
| `mcp_package/link_core/query.py:query_link` | core retrieval product |
| `mcp_package/link_core/memory.py:write_memory_page` | safe durable memory creation |
| `mcp_package/link_core/memory.py:update_memory_page` | memory lifecycle mutation |
| `mcp_package/link_core/memory.py:propose_memories_from_text` | proposal heuristics |
| `mcp_package/link_core/wiki.py:build_wiki_cache` | read model and cache construction |
| `mcp_package/link_core/wiki.py:context_for_topic` | graph-neighborhood expansion |
| `mcp_package/link_core/ingest.py:collect_ingest_status` | ingest control semantics |
| `mcp_package/link_core/validation.py:validate_wiki` | enforceable schema and link correctness |
| `mcp_package/link_core/status.py:link_status` | readiness model |
| `serve.py:Handler` | local HTTP API and mutation guards |

### Where abstractions become concrete

- abstract “memory” becomes Markdown files in `wiki/memories/`
- abstract “query” becomes a bounded JSON packet in `query.py`
- abstract “graph” becomes `_backlinks.json` plus derived page links in `wiki.py`
- abstract “ingest” becomes readiness state and prompts in `ingest.py`
- abstract “safety” becomes concrete secret scans, header checks, rate limits, and validation findings

## 15. Concise Deep Technical Synthesis

Link is fundamentally a **local agent memory operating layer built on Markdown**, not a chatbot, not a hosted memory API, and not an auto-ingesting wiki engine. Its architecture embodies a simple but disciplined pattern: keep authoritative user knowledge on disk, make retrieval bounded and inspectable, make durable memory explicit and reviewable, and expose the same core semantics consistently through CLI, HTTP, and MCP.

It is optimized for engineers and agent-heavy workflows that value local control, auditability, and protocol clarity over automation magic. The repo’s most distinctive move is splitting **source-backed wiki knowledge** from **explicit durable agent memory**, then wrapping both in conservative operational guardrails.
