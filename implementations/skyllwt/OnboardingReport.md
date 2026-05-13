---
repo: skyllwt/OmegaWiki
---

# ΩmegaWiki Onboarding Report

## SYNOPSIS

### Implementation Identity

ΩmegaWiki is a **repo-local research workflow runtime** built around a persistent Markdown wiki rather than a server-side knowledge service. Durable state lives in `wiki/*.md` and `wiki/graph/*.jsonl`; structural rules live in `runtime/schema/*.yaml`; deterministic mutations live in `tools/research_wiki.py` and `tools/lint.py`; high-level behavior is largely defined in Claude Code skill contracts under `i18n/en/skills/*/SKILL.md`.

**Observed:** the runtime is file-backed, schema-driven, and invoked by CLI/scripts. `tools/serve.py` is a loopback helper server for a local SPA, not the main control plane.  
**Inference:** the dominant architecture is **LLM-orchestrated workflows over a typed local wiki database**.

The primary semantic center is the combination of:

1. `runtime/schema/*.yaml` and `runtime/policy/writers.yaml` for the contract.
2. `tools/research_wiki.py` for concrete state transitions and derived artifact rebuilds.
3. `i18n/en/skills/*/SKILL.md` for orchestration policy, sequencing, and operator-facing behavior.

### Quick Adaptation Assessment

The repo is customizable at the **contract and workflow** level, but less modular at the orchestration level.

| Area | Adaptability | Main change points | Main constraint |
|---|---|---|---|
| Entity/edge model | High | `runtime/schema/*.yaml`, `runtime/templates/*` | UI duplicates some schema constants |
| Deterministic state ops | Medium | `tools/research_wiki.py`, `tools/lint.py` | custom frontmatter logic is centralized here |
| Workflow semantics | High | `i18n/en/skills/*/SKILL.md` | guarantees are prompt-level, not engine-level |
| UI behavior | Medium | `tools/serve.py`, `app/modules/*` | SPA cannot execute skills directly |
| External integrations | Medium | `tools/fetch_*.py`, `tools/daily_arxiv.py`, `mcp-servers/llm-review/server.py` | each integration is bespoke, not plugin-registered |

### Fastest Path to First Successful Run

**Fastest intended path**

1. `./setup.sh --lang en` or `.\setup.ps1 -Lang en`
2. `claude login`
3. `claude`
4. `/setup`
5. Put papers in `raw/papers/`
6. `/init [topic]`

Evidence: `README.md`, `setup.sh`, `setup.ps1`, `config/setup-guide.md`, `i18n/en/skills/setup/SKILL.md`, `i18n/en/skills/init/SKILL.md`.

### Minimal Manual Setup Path

A meaningful manual path exists for the deterministic core, even without Claude Code skill orchestration:

1. Create `.venv` and install `requirements.txt`.
2. Copy `.env.example` to `.env` if needed.
3. Run `python tools/research_wiki.py init wiki/` to seed missing derived files.
4. Optionally run `python tools/serve.py` and open `http://127.0.0.1:8765/`.

This exercises the local wiki engine and UI, but **not** the repo’s main usage model, which depends on slash-skill orchestration in Claude Code.

### Operational Complexity Snapshot

- **Setup complexity:** moderate; local Python is simple, but full value depends on Claude Code and optional APIs.
- **Runtime coordination:** mostly synchronous and operator-driven; the exception is `/init` fan-out via git worktrees and `merge=union` accumulators.
- **Infrastructure:** local filesystem + Python + optional Claude Code + optional MCP review server + optional GitHub Actions + optional remote SSH target.
- **Fragility:** medium. Structural correctness is reasonably defended by `tools/lint.py`; workflow correctness often depends on skill prompt discipline.
- **Observability:** basic but usable: CLI JSON/text, wiki files, append-only log, `.checkpoints/`, SPA views, workflow artifacts.
- **Primary complexity:** maintaining semantic consistency across Markdown pages, graph JSONL, reverse links, and multi-step LLM workflows.

## 1. Repository Purpose

### Actual Implemented Purpose

**Observed:** ΩmegaWiki is a local research knowledge-base and workflow system that ingests papers into a typed wiki, maintains a semantic graph, compiles compressed context, tracks ideas and experiments, and supports downstream tasks such as discovery, review, experiment execution scaffolding, paper drafting, and daily recommendation (`README.md`, `tools/research_wiki.py`, `tools/lint.py`, `tools/discover.py`, `tools/daily_arxiv.py`, `i18n/en/skills/*`).

### Relationship to the Conceptual LLM-Wiki Idea

The user-provided concept describes an LLM-maintained persistent wiki sitting between raw sources and later questions. This repo implements that core idea, but specializes it heavily:

- from a general personal/team wiki pattern to a **research-paper-centric runtime**;
- from “maintain a wiki” to a **full research lifecycle** model covering ideas, experiments, writing, rebuttal, and recommendation;
- from generic schema guidance to an explicit **runtime contract** in `runtime/schema/*.yaml` plus skill contracts in `i18n/en/CLAUDE.md` and `i18n/en/skills/*`.

### What Problem the Repo Really Solves

It solves the problem of turning a pile of papers, notes, and queries into a **durable, queryable, cross-linked research workspace** that can be incrementally maintained by LLM-guided workflows instead of re-deriving context from raw sources every time.

### Target Use Cases

- Personal or lab-scale ML/AI literature tracking.
- Converting raw papers into a reusable local graph of papers, concepts, methods, ideas, and experiments.
- Reusing accumulated wiki state for research ideation, experiment planning, writing, and review.
- Running recommendation and ingestion loops over fresh arXiv papers.

### Scope Boundaries

**In scope:** local wiki state, ingestion, health checking, search/discovery, recommendation prep, experiment scaffolding, UI browsing, remote-GPU helper flows.  
**Out of scope:** multi-user server semantics, transactional state management, hard runtime write-permission enforcement, vector-database infrastructure, autonomous background agents independent of operator/Claude sessions.

## 2. High-Level System Model

ΩmegaWiki is best understood as a **schema-governed, file-backed research operating environment**.

At a systems level:

1. `runtime/schema/*.yaml` defines what kinds of entities and graph edges are legal.
2. `tools/research_wiki.py` treats the repo as a database and exposes the mutation/query primitives.
3. `tools/lint.py` audits the wiki for structural, cross-reference, and graph consistency.
4. `i18n/en/skills/*/SKILL.md` defines the task-level control logic for Claude Code.
5. `tools/serve.py` exposes a local HTTP API and SPA for inspection/editing, but explicitly refuses to fake skill execution.
6. Auxiliary tools fetch papers/metadata, run discovery/ranking, talk to a review LLM, or interact with remote GPUs.

The dominant architectural identity is **orchestration-centric and state-file-centric**:

- the wiki is the persistent state;
- deterministic scripts mutate that state;
- LLM skills decide when and how to call those scripts;
- derived views (`wiki/index.md`, `wiki/graph/context_brief.md`, `wiki/graph/open_questions.md`) are periodically rebuilt.

The project’s behavioral intelligence is split across three layers:

- **data semantics:** `runtime/schema/*.yaml`
- **deterministic mechanics:** `tools/research_wiki.py`, `tools/lint.py`
- **workflow policy and judgment:** `i18n/en/skills/*/SKILL.md`

This is not an event bus, service mesh, or workflow engine in the usual sense. It is closer to a **disciplined filesystem protocol for LLM-driven research work**.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Main implementation | Execution semantics | Limits / extension implications |
|---|---|---|---|---|
| Persistent interlinked wiki | Implemented | `wiki/`, `runtime/schema/entities.yaml`, templates | Markdown pages with YAML frontmatter and wikilinks | No DB transactions; consistency is post-hoc audited |
| Typed graph over the wiki | Implemented | `runtime/schema/edges.yaml`, `wiki/graph/edges.jsonl`, `research_wiki.py add-edge` | Semantic edges are separate from Markdown links | Edge types are schema-driven but storage is flat JSONL |
| Bibliographic citations | Implemented | `wiki/graph/citations.jsonl`, `research_wiki.py add-citation` | Distinct citation layer with its own contract | Citation freshness depends on ingest/daily flows |
| Reverse-link invariants | Implemented as contract + lint | `runtime/schema/xref.yaml`, `tools/lint.py` | Skills should write both directions; linter catches misses | Enforcement is not transactional |
| Incremental ingest | Implemented | `/ingest`, `tools/fetch_s2.py`, `tools/init_discovery.py`, `research_wiki.py` | One paper becomes pages + edges + citations + log/index updates | Much logic lives in skill prose rather than Python |
| Bootstrap from local sources | Implemented | `/init`, `tools/init_discovery.py`, worktree fan-out | Prepare raw inputs, plan, fetch, scaffold, parallel-ingest, merge, rebuild | Operationally sophisticated; assumes git workflows |
| Query against accumulated knowledge | Implemented | `/ask`, `research_wiki.py rebuild-context-brief`, `wiki/index.md` | Reads context pack + selected pages, can crystallize outputs back | Retrieval is index-driven, not embedding-backed |
| Wiki health checking | Implemented | `/check`, `tools/lint.py` | Structural audit + optional deterministic autofix | Content-quality checks remain shallow or LLM-assisted |
| Discovery / related-paper recommendation | Implemented | `tools/discover.py`, `tools/init_discovery.py` | Deterministic shortlist generation with ranking heuristics | No centralized search service; provider APIs are critical |
| Daily arXiv pipeline | Implemented | `tools/daily_arxiv.py`, `.github/workflows/daily-arxiv.yml` | Prepare context, optional Claude/LLM recommendation, optional ingest, digest/email | CI path is configuration-sensitive and secrets-heavy |
| Cross-model review | Implemented | `mcp-servers/llm-review/server.py`, `.mcp.json` | OpenAI-compatible MCP server mediates second-model review | Minimal server, no persistence beyond thread memory |
| Experiment execution | Partially implemented | `/exp-run`, `tools/remote.py`, `wiki/experiments/*.md` | Generates code, deploys locally/remotely, updates experiment state | More orchestration script than robust experiment platform |
| Local interactive UI | Implemented | `tools/serve.py`, `app/modules/*` | Same-origin SPA reads/writes wiki state and shows graph/dashboard | UI cannot execute skills; some schema is duplicated client-side |

## 4. Architecture and Component Analysis

### 4.1 Runtime Contract Layer

**Files:** `runtime/loader.py`, `runtime/schema/entities.yaml`, `runtime/schema/edges.yaml`, `runtime/schema/xref.yaml`, `runtime/schema/conventions.yaml`, `runtime/policy/writers.yaml`, `runtime/templates/*`

This layer defines the repo’s data model and invariants:

- entity kinds and fields (`entities.yaml`);
- edge kinds, endpoint types, direction, required attributes (`edges.yaml`);
- forward-to-reverse link obligations (`xref.yaml`);
- ownership and storage conventions (`conventions.yaml`);
- nominal writer permissions (`writers.yaml`);
- page body skeletons (`runtime/templates/*.md.tmpl`).

`runtime/loader.py` is the access API that derives reusable constants such as `ENTITY_DIRS`, `VALID_VALUES`, `VALID_EDGE_TYPES`, and lifecycle validation directly from YAML. This is the cleanest architectural boundary in the repo: data-model changes often require only YAML edits.

Important caveat: `runtime/policy/writers.yaml` explicitly says it is **“SPEC, NOT A RUNTIME GATE”**. Write restrictions are advisory for skill authors, not enforced by `research_wiki.py`.

### 4.2 Core Wiki Engine

**File:** `tools/research_wiki.py`

This is the core deterministic runtime. It owns:

- wiki initialization (`init`);
- slug generation (`slugify`);
- append-only logging (`append_log`);
- frontmatter read/write (`read_meta`, `set_meta`);
- semantic edge and citation append/dedup (`add_edge`, `add_citation`, `dedup_*`);
- graph queries (`neighbors`, `find_entities`);
- context compilation and gap extraction (`compile_context`, `rebuild_open_questions`);
- lifecycle transitions (`transition`);
- statistics and maturity scoring (`get_stats`, `get_maturity`);
- resumable workflow checkpoints (`checkpoint_*`);
- index rebuild and topic backfill (`rebuild_index`, `topic_backfill`).

Architecturally, this file turns the repo from “a directory of Markdown” into “a local database with a CLI protocol”.

Hidden coupling:

- skill docs assume exact command names and semantics from this file;
- `tools/serve.py` shells into this script for many API operations;
- derived file ownership rules in `i18n/en/CLAUDE.md` depend on this file being the only write path for `wiki/graph/`.

### 4.3 Validation Layer

**File:** `tools/lint.py`

The linter is the main guardrail against semantic drift. It checks:

- missing required fields;
- enum/range validity;
- conditional requirements like `ideas.failure_reason when status=failed`;
- broken wikilinks and link-field targets;
- xref asymmetry from `runtime/schema/xref.yaml`;
- graph/citation JSONL validity and endpoint correctness;
- basic content-quality heuristics.

It also contains a narrow auto-fix mechanism for deterministic repairs. In practice, this is the enforcement layer that compensates for the lack of hard runtime permissions.

### 4.4 Skill / Workflow Layer

**Files:** `i18n/en/CLAUDE.md`, `i18n/en/skills/*/SKILL.md`, `i18n/en/shared-references/*`

This layer defines what the system *means* operationally:

- `/init` describes planner-driven discovery, worktree fan-out, and merge cleanup.
- `/ingest` defines the paper-to-entity transformation and conservative dedup semantics.
- `/ask` defines retrieval + synthesis + crystallization.
- `/check` defines reporting expectations on top of the linter.
- `/exp-run`, `/paper-plan`, `/paper-draft`, `/review`, etc. define downstream research workflows.

This is a key architectural fact: **much of ΩmegaWiki’s real orchestration logic is prompt contract, not Python control code**.

### 4.5 Acquisition, Discovery, and Recommendation Tools

**Files:** `tools/init_discovery.py`, `tools/discover.py`, `tools/fetch_s2.py`, `tools/fetch_arxiv.py`, `tools/fetch_deepxiv.py`, `tools/prepare_paper_source.py`, `tools/daily_arxiv.py`

These tools own data acquisition and ranking heuristics:

- normalizing local PDFs/TeX into ingest-ready sources;
- recovering metadata and arXiv IDs;
- fetching related papers and citations;
- ranking discovery candidates;
- building recommendation context and digests for `/daily-arxiv`.

These are deterministic helpers around LLM judgment, not a generalized ingestion pipeline framework.

### 4.6 Local UI and API Layer

**Files:** `tools/serve.py`, `app/index.html`, `app/modules/*.js`

`tools/serve.py` runs a stdlib-only loopback server on `127.0.0.1` and exposes:

- read APIs for entity lists/pages, graph data, stats, maturity, logs, open questions;
- write APIs that call `research_wiki.py` for PATCH/POST operations;
- an `/api/intent/{skill}` endpoint that synthesizes slash commands rather than executing them;
- SSE live reload by polling `wiki/` mtimes.

The SPA has three main roles:

- Reader and editor over local wiki pages (`reader.js`, `api.js`);
- graph exploration (`graph.js`);
- dashboard/status views (`dashboard.js`, implied by README/changelog and app layout).

Notable leakage: `app/modules/schema.js` duplicates entity names and edge-workflow mappings from the runtime schema, and `graph.js` duplicates color config. This is an intentional convenience shortcut, but it creates schema drift risk.

### 4.7 Remote Execution and External Integration Layer

**Files:** `tools/remote.py`, `config/server.yaml.example`, `mcp-servers/llm-review/server.py`, `.mcp.json`, `.github/workflows/daily-arxiv.yml`

This layer connects the local wiki runtime to external systems:

- `tools/remote.py` wraps SSH/rsync/screen for remote GPU workflows.
- `mcp-servers/llm-review/server.py` exposes an OpenAI-compatible review LLM as an MCP server.
- `.github/workflows/daily-arxiv.yml` runs a scheduled recommendation pipeline in CI and can optionally auto-ingest.

This is integration glue, not a general platform abstraction. Each integration is narrowly purpose-built.

### 4.8 Repository Template / User-Data Boundary

**Files:** `.gitignore`, `.gitattributes`, `wiki/`, `raw/`

The repo is designed as a **template/scaffold**, not a canonical upstream knowledge base. `.gitignore` excludes nearly all generated wiki/raw content while preserving `.gitkeep` placeholders. Upstream tracks the toolchain and empty scaffold, while user-generated wiki state is intentionally local.

`/init` parallel fan-in relies on `.gitattributes` `merge=union` for `wiki/log.md`, `wiki/index.md`, and graph JSONL files, with post-merge dedup/rebuild cleaning up duplicates.

## 5. Execution Flow Analysis

### 5.1 Setup and Language Activation

**Observed flow**

1. `setup.sh` / `setup.ps1` checks Python and Claude Code.
2. Creates `.venv` and installs `requirements.txt`.
3. Copies `.env.example` to `.env` and `config/settings.local.json.example` to `.claude/settings.local.json`.
4. Copies the selected language pack from `i18n/<lang>/` into root `CLAUDE.md` and `.claude/skills/*`.
5. Verifies imports for key tools.

This setup flow is important because the active skill set is **generated from `i18n/`**, not edited directly at root.

### 5.2 Wiki Initialization and Base State

`tools/research_wiki.py init wiki/`:

1. Creates one directory per entity kind from `runtime.loader.ENTITY_DIRS`.
2. Creates `wiki/graph/` and `wiki/outputs/`.
3. Seeds `wiki/index.md`, `wiki/log.md`, `wiki/graph/edges.jsonl`, `wiki/graph/citations.jsonl`, `wiki/graph/context_brief.md`, `wiki/graph/open_questions.md` if missing.
4. Appends an init log entry.

Observed repo state: the checked-in scaffold has empty entity directories, tracked `wiki/index.md`, and a minimal `wiki/log.md`, but `wiki/graph/` only contains `.gitkeep`. This means a fresh checkout is **not fully initialized** until `research_wiki.py init` runs.

### 5.3 `/init` End-to-End Bootstrap Flow

The implemented `/init` path in `i18n/en/skills/init/SKILL.md` is the most architecturally dense runtime:

1. Resolve project root and choose the right Python interpreter, preferring `.venv`.
2. Initialize wiki structure.
3. Run `tools/init_discovery.py prepare` to normalize local papers and notes/web manifests.
4. Run `tools/init_discovery.py plan` to build a candidate shortlist, optionally including external discovery.
5. Run `tools/init_discovery.py fetch` to materialize selected external sources under `raw/discovered/`.
6. Create scaffold pages from notes/web before paper ingest.
7. Commit scaffold state, then fan out one-paper `/ingest` runs into linked git worktrees.
8. Merge worktree branches sequentially using `merge=union` accumulators.
9. Run `dedup-edges`, `dedup-citations`, `rebuild-index`, `rebuild-context-brief`, `rebuild-open-questions`, and `lint --fix`.
10. Regenerate visualization artifacts best-effort.

Control authority here resides mostly in the skill contract; Python tools provide the deterministic steps.

### 5.4 `/ingest` Flow

`/ingest` is the central knowledge-compilation flow:

1. Resolve source: arXiv URL, local TeX, prepared PDF, or init manifest handoff.
2. Generate slug via `research_wiki.py slug`.
3. Stop on duplicate paper identity if already present.
4. Enrich from Semantic Scholar and optionally DeepXiv.
5. Write the paper page using the runtime schema/template.
6. Deduplicate/create concepts, methods, and selective people pages.
7. Add citation and semantic edges; update `cited_by`.
8. Update related topics and `wiki/index.md`.
9. Append a log entry and rebuild derived context unless in init mode.

The important implementation nuance is that `/ingest` is designed to **write a bounded local transformation**, while `/check` is the later semantic audit pass.

### 5.5 `/ask` and `/check`

`/ask`:

1. Reads `wiki/graph/context_brief.md` and `wiki/graph/open_questions.md`.
2. Uses `wiki/index.md` as the retrieval catalog.
3. Reads selected pages and synthesizes an answer with `[[slug]]` citations.
4. Optionally crystallizes results into `wiki/outputs/` or existing pages, then rebuilds derived files.

`/check`:

1. Runs `tools/lint.py --wiki-dir wiki/ --json`.
2. Optionally runs `--fix`.
3. Produces a tiered health report and appends a log entry.

These two flows show the repo’s intended loop: **compile knowledge, query it, audit it, then fold useful outputs back in**.

### 5.6 Local SPA Flow

`tools/serve.py` runtime:

1. Serves static assets from `app/`.
2. On page load, `app/modules/main.js` fetches graph and all entity listings in parallel.
3. Builds in-memory indexes for slug resolution, backlinks, and forward edges.
4. Starts hash-based routing.
5. Opens `EventSource("/api/events")`; the backend watcher polls `wiki/` and broadcasts change events.
6. Writes from the SPA call back into `research_wiki.py` and append `frontend | ...` log lines.

The API intentionally draws a control boundary: skill-triggering UI buttons call `/api/intent/*`, which only returns a copyable slash command.

### 5.7 Daily arXiv CI Flow

`.github/workflows/daily-arxiv.yml` orchestrates:

1. Python environment setup on GitHub Actions.
2. Config resolution via `tools/daily_arxiv.py config`.
3. Feed/context generation via `tools/daily_arxiv.py prepare`.
4. If Claude auth exists, `anthropics/claude-code-action` reads the context, writes `llm-decisions.json`, and may invoke `/ingest`.
5. If Claude auth is absent but `LLM_*` exists and mode is `inform`, a fallback recommendation is generated.
6. Digest finalization and artifact upload.
7. Optional email sending and optional git commit/push of auto-ingested changes.

This is one of the few places where the repo becomes semi-automated rather than purely interactive.

### 5.8 Experiment Deployment Flow

`/exp-run` plus `tools/remote.py` implements a staged execution path:

1. Read the experiment page and linked idea.
2. Generate code under `experiments/code/<slug>/`.
3. Optionally review code with the review LLM.
4. Run a sanity check.
5. Deploy locally via `screen` or remotely via SSH + `screen`.
6. Update experiment frontmatter and logs.
7. Later `--collect` mode checks liveness, tails logs, detects anomalies, and updates completion/outcome fields.

This is operationally useful but still lightweight; it is not a scheduler or robust job-control platform.

## 6. State and Persistence Model

### Primary Persistent State

| State surface | Owner | Persistence form | Notes |
|---|---|---|---|
| `wiki/<kind>/*.md` | skills + `research_wiki.py` | Markdown with YAML frontmatter | canonical entity state |
| `wiki/graph/edges.jsonl` | `research_wiki.py` | append-only JSONL | semantic graph |
| `wiki/graph/citations.jsonl` | `research_wiki.py` | append-only JSONL | bibliographic graph |
| `wiki/index.md` | `research_wiki.py` / skills | YAML-like catalog | rebuildable from entity pages |
| `wiki/log.md` | `research_wiki.py` | append-only Markdown log | operational history |
| `wiki/graph/context_brief.md` | `research_wiki.py` | derived Markdown | compressed query pack |
| `wiki/graph/open_questions.md` | `research_wiki.py` | derived Markdown | extracted gap map |
| `wiki/.checkpoints/*.json` | `research_wiki.py` | JSON | resumable workflow state |
| `raw/*` | user + discovery tools | source files | raw inputs and generated staging |
| `experiments/code/*` | `/exp-run` | generated code tree | execution artifact, not wiki entity |
| `.daily-arxiv/` | workflow/tooling | local/CI scratch | ignored runtime state |

### Ownership and Mutability

- `raw/papers`, `raw/notes`, `raw/web` are treated as user-owned read-only inputs.
- `raw/discovered` and `raw/tmp` are tool-owned staging areas.
- `wiki/graph/` is derived/tool-owned.
- `wiki/log.md` is append-only by convention.
- most entity pages are mutable and updated incrementally.

### Derived vs Source State

The repo distinguishes:

- **source-like wiki entities**: entity pages and raw inputs;
- **accumulator state**: graph JSONL, log, index;
- **derived summaries**: context pack, gap map, visualizations.

This distinction matters operationally: if derived artifacts drift or disappear, they are expected to be rebuilt.

### Recovery Semantics

Recovery is pragmatic rather than transactional:

- `checkpoint_*` stores progress for resumable batch workflows;
- `dedup-*` and rebuild commands clean up shared accumulators after parallel work;
- `lint --fix` repairs deterministic structural issues;
- no rollback framework exists beyond git.

## 7. Coordination and Control Semantics

### Execution Authority

Execution authority is mostly **centralized in the active skill prompt**. Skills decide what tool calls to make and in what order. Deterministic tools do not plan workflows; they execute narrow commands.

### Coordination Topology

- **Directive, not reactive:** flows are initiated by the user or CI job, not by internal events.
- **Mostly synchronous:** commands run to completion and then update files.
- **Limited concurrency:** `/init` explicitly parallelizes ingest via git worktrees; everything else is mostly serial.
- **Pull-based knowledge reuse:** `/ask` and similar flows read the current wiki state on demand.

### Routing and Delegation

- workflow routing happens in skill docs (`/init`, `/ingest`, `/ask`, `/check`, etc.);
- low-level routing inside `research_wiki.py` is schema-driven for edge types, lifecycle transitions, and rebuild logic;
- UI buttons route to command synthesis rather than hidden execution.

### Failure Propagation

Failure handling is mostly explicit and local:

- tools usually emit JSON errors and exit nonzero;
- skills define when to continue, skip, or stop;
- CI workflow gates auto-ingest on auth/config availability;
- remote experiment support checks connectivity and free GPU before launch.

### Concurrency Model

The meaningful concurrency model is `/init` worktree fan-out:

- each paper ingests in its own git worktree;
- shared append-only files use `merge=union`;
- fan-in merges are sequential;
- final cleanup deduplicates graph accumulators and rebuilds index/context.

This is an unusual but deliberate coordination model: **git is being used as the concurrency substrate**.

## 8. Configuration and Environment Model

### Configuration Hierarchy

1. **Setup scripts:** `setup.sh`, `setup.ps1`
2. **Environment variables:** `.env`, `~/.env`, loaded by `tools/_env.py`
3. **Language packs:** `i18n/<lang>/...`, synced into root `CLAUDE.md` and `.claude/skills/*`
4. **Claude permission config:** `.claude/settings.local.json`
5. **Feature configs:** `config/daily-arxiv.yml`, `config/server.yaml`
6. **MCP config:** `.mcp.json`

### Required vs Optional Configuration

| Config | Required for core wiki | Enables |
|---|---|---|
| Python 3.9+ + deps | Yes | all deterministic tools |
| Claude Code | Yes for intended workflow | slash skills |
| `SEMANTIC_SCHOLAR_API_KEY` | No | faster/larger metadata and discovery |
| `DEEPXIV_TOKEN` | No | semantic search, briefs, trending |
| `LLM_API_KEY` + `LLM_BASE_URL` + `LLM_MODEL` | No | cross-model review and CI fallback recommendation |
| `config/daily-arxiv.yml` | No | scheduled daily recommendations |
| `config/server.yaml` | No | remote experiment execution |

### Operational Assumptions Encoded in Config

- local-first execution;
- same repo acts as code + runtime state container;
- operator can run Claude Code locally;
- optional provider APIs improve quality but are not always mandatory;
- UI and tools should prefer `.venv` when present.

### Notable Configuration Quirks

- both `.env.example` at repo root and `config/.env.example` exist;
- `config/README.md` references `config/.env.example`, while setup scripts copy the root `.env.example`;
- root `CLAUDE.md` is generated from `i18n/en/CLAUDE.md` or `i18n/zh/CLAUDE.md`, so direct edits to root are not canonical.

## 9. Operational Usage Model

### Canonical Workflow

1. Run setup and choose language.
2. Configure API keys via `/setup`.
3. Place user sources in `raw/`.
4. Bootstrap a wiki with `/init` or add a paper with `/ingest`.
5. Query the accumulated wiki with `/ask`.
6. Audit health with `/check`.
7. Discover more papers with `/discover` or `/daily-arxiv`.
8. Turn knowledge into ideas/experiments/writing with `/ideate`, `/exp-design`, `/exp-run`, `/paper-plan`, `/paper-draft`, `/rebuttal`.

### How Users Actually Interact

The intended operator loop is:

- Claude Code for workflow execution;
- optionally Obsidian or the local SPA for browsing/editing the wiki;
- git as local history and workspace management;
- raw source drops rather than API uploads.

### Session and Persistence Expectations

The system assumes that the wiki persists across sessions as local files, and that future LLM sessions will read those files rather than re-derive context from raw documents.

### Development vs Production Reality

This is fundamentally a **power-user local toolchain**, not a hosted production service. The GitHub Actions path is a scheduled extension of the same local-file model, not a separate deployment architecture.

## 10. Extension and Customization Architecture

### Data-Model Extension

For many schema changes, the intended path is:

1. edit `runtime/schema/*.yaml`;
2. add or update `runtime/templates/*.md.tmpl`;
3. restart tools.

`runtime/CLAUDE.md` explicitly documents when Python changes are not needed and when the schema language itself must be extended in `runtime/loader.py` or `tools/lint.py`.

### Workflow Extension

New behavior is often added by:

- editing or adding a skill in `i18n/en/skills/*`;
- adding shared references under `i18n/en/shared-references/*`;
- syncing with `setup.sh --lang en`.

### Tool Extension

Deterministic extensions usually mean adding or adjusting a Python tool in `tools/` and then referencing it from a skill.

### UI Extension

The UI can be extended by:

- adding a backend endpoint in `tools/serve.py`;
- adding a matching fetch wrapper in `app/modules/api.js`;
- wiring view logic in `app/modules/*`.

Because schema constants are duplicated in `app/modules/schema.js`, UI extensions that touch entity kinds or edge types must update both runtime and frontend code.

### Integration Extension

There is no formal plugin registry. New provider/tool integrations follow the existing pattern:

- one purpose-built `tools/fetch_*.py` or helper;
- optional config/env entries;
- skill-level instructions describing how to call it.

## 11. Key Architectural Decisions and Tradeoffs

### File-Backed State Instead of a Database

**Decision:** keep state in Markdown + JSONL under `wiki/`.  
**Why it likely exists:** interoperability with Obsidian/git, inspectability, easy manual editing, zero service dependency.  
**Tradeoff:** weak transactional guarantees and more repair/rebuild logic.

### Schema-Driven Contract, Prompt-Driven Orchestration

**Decision:** data shape is formalized, but workflows live in skill docs.  
**Tradeoff:** fast evolution and transparent rules, but enforcement is uneven and behavior can drift with prompt changes.

### Git Worktrees for Parallel Ingest

**Decision:** use git branches/worktrees and `merge=union` for `/init` parallelism.  
**Tradeoff:** clever reuse of existing tooling and merge semantics, but operationally advanced and fragile for casual users.

### Explicit UI/Skill Boundary

**Decision:** SPA synthesizes slash commands instead of silently emulating skills (`tools/serve.py`, `app/modules/intent.js`).  
**Tradeoff:** more honest behavior and fewer hidden divergences, but less seamless UX.

### Local-First Template Repository

**Decision:** generated user wiki/raw content is mostly gitignored.  
**Tradeoff:** clean upstream repo and per-user local knowledge bases, but collaboration and sharing are not first-class.

### Lightweight Parsers Over Heavier Dependencies

`research_wiki.py`, `lint.py`, `daily_arxiv.py`, and `remote.py` all implement custom YAML/frontmatter parsing instead of leaning fully on robust parsers. This reduces dependencies and keeps tools self-contained, but increases parser fragility and duplicated parsing logic.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### Prompt-Level Guarantees Are Not Runtime Guarantees

`runtime/policy/writers.yaml` explicitly says it is not enforced at runtime. Many core invariants depend on skill compliance plus later linting.

### Custom Parsing Is Reimplemented in Multiple Places

`tools/research_wiki.py`, `tools/lint.py`, `tools/daily_arxiv.py`, and `tools/remote.py` each contain bespoke parsing logic. This is a maintainability and correctness risk.

### Frontend Schema Drift Risk

`app/modules/schema.js` mirrors runtime entity and edge metadata instead of loading them dynamically. `graph.js` also duplicates visualization config comments and constants.

### Checked-In Runtime State Is Only Partially Initialized

The repo scaffold includes `wiki/index.md` and `wiki/log.md`, but `wiki/graph/` contains only `.gitkeep`. A fresh checkout therefore looks initialized but is missing derived files until `research_wiki.py init wiki/` runs.

### Testing Story Is Unclear

`CHANGELOG.md` claims “2125 tests”, but the repository contains no visible test files or test directories, and glob search for test files returned none. That suggests the documented testing maturity is not present in this checkout.

### Documentation Drift

- Two `.env.example` files exist.
- `config/README.md` and setup scripts refer to different source paths for `.env.example`.
- Root `CLAUDE.md` is generated, but casual contributors could edit the wrong copy.

### Experiment Execution Layer Is Useful but Thin

`/exp-run` and `tools/remote.py` provide deploy/check helpers, but not durable queueing, rich scheduling, resumable job objects, or strong failure recovery. It is workflow automation, not a full experiment platform.

### Multi-Phase Workflow Coupling

The repo heavily couples:

- skill prose,
- exact CLI tool behavior,
- expected file formats,
- git merge semantics.

This creates power, but also means small format changes can ripple across many layers.

## 13. Practical Usage Guide

### Minimal Viable Usage

If the goal is only to understand or lightly exercise the repo:

1. install dependencies;
2. run `python tools/research_wiki.py init wiki/`;
3. run `python tools/serve.py`;
4. inspect the empty scaffold in the browser.

If the goal is to use the system as intended:

1. run setup;
2. configure Claude Code;
3. add sources under `raw/`;
4. run `/init` or `/ingest`.

### Operational Assumptions

- operator is comfortable with git and local file workflows;
- wiki is moderate-scale, not huge-corpus enterprise scale;
- operator is willing to let LLMs edit many Markdown files;
- provider API outages are survivable but degrade discovery/review quality;
- local durability matters more than centralized service guarantees.

### Canonical Workflow

1. Seed sources.
2. Compile wiki state.
3. Run health checks.
4. Ask questions and crystallize durable outputs.
5. Use the accumulated graph for ideas, experiments, and writing.
6. Keep the corpus fresh with discovery and `/daily-arxiv`.

### Advanced Usage

- `/init` worktree-parallel ingest for bootstrapping a corpus.
- `/daily-arxiv setup` for CI scheduling.
- `/exp-run --env remote` with `config/server.yaml`.
- review workflows through `mcp-servers/llm-review/server.py`.
- local SPA plus Obsidian graph/canvas generation through `tools/visualize.py`.

### Extension Workflow

1. Change schema/template if the data model changes.
2. Change `research_wiki.py` / `lint.py` if deterministic behavior changes.
3. Change skill docs if orchestration or operator semantics change.
4. Sync the active language files with `setup.sh --lang en`.
5. Update SPA constants/endpoints if UI-visible schema changes.

### Debugging Workflow

Best inspection points:

- `wiki/log.md` for chronological actions;
- `wiki/index.md` for current catalog;
- `wiki/graph/*.jsonl` for graph-layer truth;
- `.checkpoints/` and `wiki/.checkpoints/` for resumable flow state;
- `tools/lint.py --json` for structural issues;
- `tools/research_wiki.py stats/maturity/neighbors` for derived introspection;
- workflow artifacts and step summaries for `/daily-arxiv`;
- temp MCP debug log from `mcp-servers/llm-review/server.py`.

### Observability

Observability is mostly file-based and CLI-based:

- JSON stdout from Python tools;
- append-only log entries;
- generated digest/context files;
- SPA graph/dashboard;
- CI artifact upload for `/daily-arxiv`.

There is no centralized metrics or tracing layer.

### Failure Modes

Most likely operational failures:

1. API auth/rate-limit issues in Semantic Scholar or DeepXiv.
2. Missing derived files in a fresh scaffold.
3. Reverse-link or graph drift caught by `lint.py`.
4. Skill instructions diverging from actual tool behavior.
5. `/init` worktree merge issues if branch state or `.gitattributes` assumptions are violated.
6. Remote experiment launch failures due to SSH/config/env issues.

### Performance Considerations

- Discovery and daily recommendation quality/performance are API-bound.
- Large wiki scans are filesystem-bound; many operations rescan directories.
- `compile_context` compresses state by simple heuristics and edge counts, not semantic indexing.
- SPA live reload polls the filesystem every 1.5s; acceptable locally, not designed for large remote deployments.

## 14. Project Navigation Guide

### Best Reading Order

1. `README.md`
2. `i18n/en/CLAUDE.md`
3. `runtime/CLAUDE.md`
4. `runtime/schema/entities.yaml`, `edges.yaml`, `xref.yaml`, `conventions.yaml`
5. `tools/research_wiki.py`
6. `tools/lint.py`
7. `i18n/en/skills/init/SKILL.md`, `ingest/SKILL.md`, `ask/SKILL.md`, `check/SKILL.md`
8. `tools/init_discovery.py`, `tools/discover.py`, `tools/daily_arxiv.py`
9. `tools/serve.py` and `app/modules/*`
10. `tools/remote.py`, `.github/workflows/daily-arxiv.yml`, `mcp-servers/llm-review/server.py`

### Highest-Value Entry Points

- **Data model:** `runtime/schema/entities.yaml`
- **Graph semantics:** `runtime/schema/edges.yaml`
- **Runtime helper API:** `runtime/loader.py`
- **State mutation engine:** `tools/research_wiki.py`
- **Consistency checker:** `tools/lint.py`
- **Bootstrap orchestration:** `i18n/en/skills/init/SKILL.md`
- **Paper ingest semantics:** `i18n/en/skills/ingest/SKILL.md`
- **UI boundary:** `tools/serve.py`, `app/modules/intent.js`

### Where Abstractions Become Concrete

- schema abstractions become concrete in `runtime/loader.py`;
- skill contracts become concrete in tool invocations inside `tools/`;
- wiki-as-database becomes concrete in `tools/research_wiki.py`;
- “interactive graph” becomes concrete in `tools/serve.py` + `app/modules/graph.js`;
- “cross-model review” becomes concrete in `mcp-servers/llm-review/server.py`.

## 15. Concise Deep Technical Synthesis

ΩmegaWiki is a **local, schema-governed research workspace in which an LLM acts as the maintainer of a persistent Markdown/JSONL knowledge graph**. Its most distinctive trait is not any single tool, but the way it composes three layers: a formal wiki contract, deterministic file-mutation utilities, and prompt-defined Claude Code skills. The result is a system that operationalizes the “LLM-wiki” idea as a research runtime rather than a generic note-taking assistant.

It is optimized for engineers or researchers who are comfortable with git, local files, and LLM-guided workflows, and who value inspectable persistent state over centralized service abstractions. The core tradeoff is deliberate: **human-readable local state and flexible prompt-driven workflows in exchange for weaker hard guarantees and heavier reliance on convention, linting, and careful tool usage**.
