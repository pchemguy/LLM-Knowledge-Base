---
repo: jp-carrilloe/pulseOS-lite
---

# PulseOS-Lite Onboarding Report

## 1. Repository Purpose

### Actual implemented purpose

PulseOS-Lite is **not primarily a generic multi-agent runtime**. The implemented core is a **local Markdown company-memory runtime** centered on `cli/`: it scans `000_Company_Memory`, stores document metadata plus lightweight retrieval artifacts in a workspace-local SQLite database, exposes that state through a daemon-backed chat/UI/MCP surface, and optionally uses LLMs to bootstrap template documents from source intake material (`cli\index.ts`, `cli\daemon.ts`, `cli\retrieval.ts`, `cli\bootstrap.ts`).

### Relationship to the conceptual LLM-wiki pattern

The repo operationalizes the “persistent wiki maintained by an LLM” idea in a specialized business setting:

- **Raw sources**: `001_Data_Souces\...` and external reference notes parsed by `cli\bootstrap-intake.ts`.
- **Persistent wiki**: `000_Company_Memory\...`, treated as the canonical curated knowledge layer by both bootstrap and retrieval.
- **Schema / operating rules**: `AGENTS.md`, `CLAUDE.md`, numbered domain folders, and metadata conventions extracted by the indexer (`cli\retrieval.ts`).

Unlike a pure ingest-and-maintain wiki system, the implementation is **specialized around a pre-authored business operating-system template** and a **bootstrap flow that fills placeholders in numbered domain documents** rather than incrementally synthesizing arbitrary new pages by default.

### What problem the repo is really solving

It solves three tightly related problems:

1. **Structuring company knowledge** into a fixed domain ontology (`000_Company_Memory\101...502...`).
2. **Making that knowledge operable locally** through retrieval-backed chat, a graph/editor UI, and an MCP server.
3. **Seeding template documents** from intake materials so a new company brain can be generated quickly.

### Target use cases

- Seed a company memory from raw docs via `cd cli && npm run bootstrap`.
- Chat against the indexed company memory via `cd cli && npm run chat`.
- Browse/edit the indexed graph and documents via `cd cli && npm run ui`.
- Expose retrieval/status/rebuild operations to external agent tooling through `cd cli && npm run mcp`.

### Scope boundaries

Observed boundaries:

- Retrieval and indexing only cover `000_Company_Memory` and explicitly exclude source intake and the sample memory (`cli\retrieval.ts`).
- The UI editor only reads/writes Markdown under `000_Company_Memory` (`cli\daemon.ts`).
- Bootstrap only fills existing numbered template docs; it does not design a new ontology (`cli\bootstrap.ts`).
- The `502_Execution_Engine\ark-engine` subtree exists, but the active runtime does not depend on it.

## 2. High-Level System Model

PulseOS-Lite is fundamentally an **orchestration-centric local knowledge-base runtime** with three coupled loops:

1. **Index loop**: scan Markdown under `000_Company_Memory`, summarize it, infer metadata, extract links, chunk content, embed summaries, and persist everything in SQLite (`cli\retrieval.ts`).
2. **Access loop**: serve that indexed state through a daemon that powers chat commands, the React graph/editor UI, and the MCP server (`cli\daemon.ts`, `cli\mcp-server.ts`).
3. **Generation loop**: bootstrap unfilled template docs in dependency order using intake evidence plus already-generated docs as context, then immediately refresh the index (`cli\bootstrap.ts`).

The dominant architectural identity is therefore:

- **knowledge-base/index-runtime first**
- **daemon-mediated access second**
- **LLM generation/bootstrap third**

The project’s behavioral intelligence lives mainly in:

- `cli\retrieval.ts`: what counts as indexed knowledge, how summaries/vectors/links/chunks are derived, how rebuild drift is detected, and how graph state is materialized.
- `cli\daemon.ts`: how access is controlled, how UI/chat/terminal features are exposed, and how retrieval context is turned into runtime behavior.
- `cli\bootstrap.ts` + `cli\bootstrap-intake.ts`: how source intake is interpreted and how template generation is ordered and grounded.

This is **not** a distributed agent swarm at runtime. The “agent” framing in docs is mostly a semantic/document-governance layer over a local single-process daemon plus a batch bootstrap routine.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Owning implementation | Execution semantics | Limits / tradeoffs |
| --- | --- | --- | --- | --- |
| Persistent curated wiki | **Implemented** | `000_Company_Memory`, `cli\retrieval.ts` | Markdown is canonical; SQLite is a derived operational index | Editing outside `000_Company_Memory` is out of scope |
| Raw-source intake | **Implemented** | `cli\bootstrap-intake.ts` | Reads local intake files, legacy intake fallback, external reference notes, curated memory evidence | Only `.md`, `.txt`, `.json`, `.csv`; helper/readme-like files filtered |
| Template seeding / bootstrap | **Implemented** | `cli\bootstrap.ts` | Finds unfilled numbered docs, sorts by section dependency order, fills via provider, writes in place | Works on existing templates; does not synthesize schema |
| Retrieval-backed Q&A | **Implemented** | `cli\retrieval.ts`, `cli\daemon.ts` | Retrieves top docs by vector similarity with keyword prefilter; injects summaries + up to 4 full docs into prompt | No chunk-level semantic retrieval; summary embeddings dominate recall |
| Graph of folder + doc references | **Implemented** | `cli\retrieval.ts`, `cli\frontend\src\lib\graph-snapshot.ts` | Builds folder/document nodes and Markdown-link reference edges from SQLite | Relationship graph only sees resolvable Markdown links |
| Browser editing of company memory | **Implemented** | `cli\daemon.ts`, `cli\frontend\src\App.tsx` | UI reads/writes Markdown files and reindexes immediately on save | Restricted to Markdown in `000_Company_Memory` |
| Rebuild health / drift advisor | **Implemented** | `cli\retrieval.ts` | Compares filesystem hashes against indexed state, persists change log optionally | Advises full rebuild; no partial incremental embedding update path |
| MCP access | **Implemented** | `cli\mcp-server.ts` | JSON-RPC tools expose status, rebuild, file list, and retrieval context | Narrow tool surface, no write/edit tools |
| Generic CRM sync model | **Schema implemented; runtime sync absent here** | `crm_objects`, `crm_sync_runs` in `cli\retrieval.ts` | Tables are created in the main SQLite DB | No active sync jobs in `cli/` |
| Execution-engine workflows in `502` | **Mostly aspirational / scaffold** | `000_Company_Memory\502_Execution_Engine\ark-engine\...` | Separate Express boilerplate with health route and stub DB/connectors | Not integrated with main CLI/daemon runtime |

## 4. Architecture and Component Analysis

### 4.1 `cli\` as the actual product runtime

This is the real implementation center. `cli\package.json` defines all working entrypoints:

- `chat`, `status`, `daemon:*`, `ui`, `index`, `bootstrap`, `mcp`, `test`.

Everything operationally important routes through this subtree.

### 4.2 CLI entry and command shell (`cli\index.ts`)

Responsibility:

- top-level command parsing
- workspace preparation
- daemon start/stop/status
- chat-mode REPL startup
- UI URL bootstrapping
- workflow status reporting

Architectural significance:

- It is the **operator-facing façade** for the runtime.
- It decides when the daemon must exist and when workspace storage must be prepared.

Notable behavior:

- `chat`, `ui`, `status`, and `daemon start` all force workspace preparation first.
- The daemon is treated as reusable infrastructure; `ensureRuntime` restarts it if version or health is stale.

### 4.3 Workspace state and storage layout (`cli\shared.ts`, `cli\workspace-storage.ts`)

Responsibility:

- resolve workspace-root location outside the repo
- maintain daemon/bootstrap state files
- support migration from earlier repo-local state directories
- create snapshots/log/cache directories

State ownership:

- runtime state is **explicitly externalized from the repo** into `~\.pulseos\workspaces\<workspace-id>\...` unless overridden.

Architectural meaning:

- the repo is intended to remain a durable Markdown source tree, while mutable operational state lives outside it.
- this keeps the git repo cleaner and allows multiple workspace instances.

Important files:

- `cli\workspace-storage.ts`
- `cli\workspace-storage.test.ts`
- `cli\shared.ts`

### 4.4 Knowledge-base index and graph engine (`cli\retrieval.ts`)

This is the primary semantic center.

Responsibilities:

- scan `000_Company_Memory`
- infer document metadata (`title`, `status`, `owner_agent`, `ontology_domain`)
- summarize docs
- generate embeddings (OpenAI or heuristic fallback)
- store vectors, references, chunks, run history, CRM tables, rebuild-change log
- answer retrieval queries
- materialize graph snapshots
- detect drift and rebuild need

Key ownership boundaries:

- **Markdown files are source of truth**
- **SQLite is a cached operational model**

Internal model:

- `documents`: one row per indexed Markdown doc
- `knowledge_vectors`: one vector per document summary
- `document_references`: resolved Markdown link edges
- `document_chunks`: paragraph-ish chunks for full-document prompt reconstruction
- `index_runs`: rebuild history
- `rebuild_change_log`: persistent drift log
- `crm_objects` / `crm_sync_runs`: normalized CRM landing schema

Where abstractions are real vs nominal:

- `WorkspaceStore` in `cli\workspace-store.ts` is currently just a thin wrapper over one concrete SQLite implementation. It is an abstraction boundary in shape, not in behavioral diversity.

### 4.5 Daemon and API surface (`cli\daemon.ts`)

Responsibility:

- host the Hono HTTP daemon on localhost
- serve chat, status, rebuild, file, terminal, and UI endpoints
- manage in-memory chat sessions
- enforce access via bearer token or bootstrapped UI cookie
- keep daemon alive until idle timeout

Control topology:

- centralized: the daemon owns access to the index, UI, and chat surface.
- synchronous/directive: requests call into `KnowledgeBaseIndex` directly; there is no queue or job system.

Important boundary:

- the daemon is the only place where retrieval becomes an interactive system rather than a library.

### 4.6 Bootstrap pipeline (`cli\bootstrap.ts`, `cli\bootstrap-intake.ts`)

Responsibility:

- detect which template docs remain unfilled
- enforce intake readiness
- merge curated-memory evidence with raw intake and external references
- choose the first usable provider (OpenAI -> Anthropic -> Gemini)
- generate documents in dependency order
- refresh index after generation

Semantic design choice:

- bootstrap prefers **existing curated Company Memory docs over raw intake when conflicting**. This turns bootstrap into an **incremental refinement pass** as well as initial seeding.

Hidden coupling:

- template ordering assumes the numbered domain taxonomy encodes dependency direction.
- file contents are expected to use specific placeholder and metadata conventions.

### 4.7 Auth/provider abstraction (`cli\auth.ts`)

Responsibility:

- provider auth discovery and validation
- model execution via API keys or local CLI sessions

Meaningful behavior:

- OpenAI can run via `OPENAI_API_KEY` or `codex login`.
- Claude can run via `ANTHROPIC_API_KEY` or `claude auth login`.
- Gemini is API-key only here.
- Embeddings are separate: OpenAI summary embeddings require `OPENAI_API_KEY`; otherwise retrieval falls back to heuristic vectors.

Important tradeoff:

- chat/bootstrap may succeed without provider API keys through local CLI sessions, but retrieval quality can degrade if embeddings fall back to heuristic mode.

### 4.8 React UI (`cli\frontend\src\...`)

Responsibility:

- visualize the indexed knowledge graph
- browse folder hierarchy
- open/edit Markdown docs
- expose rebuild controls
- expose a docked local terminal

Behavioral center inside UI:

- `App.tsx` orchestrates state, data loading, document tabs, rebuild actions, and layout.
- `lib\graph-snapshot.ts` defines the two view semantics: ontology view vs documents-only view.
- `components\graph\GraphCanvas.tsx` handles Cytoscape rendering and incremental relayout.

The UI is **not the source of truth**; it is a live editor/visualizer over the daemon’s SQLite snapshot and filesystem writes.

### 4.9 MCP server (`cli\mcp-server.ts`)

Responsibility:

- expose a narrow machine-facing tool layer over the same workspace index

Implemented tools:

- `repo_status`
- `rebuild_advisor`
- `rebuild_now`
- `list_files`
- `retrieve_context`

Architecturally, this is an adapter over `KnowledgeBaseIndex`, not an independent subsystem.

### 4.10 `000_Company_Memory\502_Execution_Engine`

Observed reality:

- documentation in `README_Execution_Engine.md` describes a richer GTM automation server.
- the checked-in `ark-engine` implementation is mostly boilerplate: Express app, system health route, simple SQLite tables `records` and `task_queue`, and placeholder connectors.

Inference:

- this subtree appears to be **domain content plus early scaffold**, not the runtime that powers PulseOS-Lite today.

## 5. Execution Flow Analysis

### 5.1 Startup: `npm run chat`

1. `cli\index.ts` parses `chat`.
2. `loadRepoEnv` reads `.env`/`.env.local`.
3. `ensureCliWorkspaceReady` resolves external workspace storage and performs migration if needed.
4. `ensureRuntime` checks daemon-state health/version and starts `cli\daemon.ts` if needed.
5. `startDaemonServer` opens `KnowledgeBaseIndex`, allocates localhost port/token, writes daemon state, and immediately runs `kbIndex.ensureCurrent()` plus rebuild inspection.
6. The chat loop then sends commands to the daemon `/command` endpoint; daemon-side `handleCommand("chat")` builds retrieval context and invokes the selected model.

Critical transition:

- the daemon is usable before indexing completes, but many routes gate on `awaitReady()`, so retrieval-backed operations wait for the initial index pass.

### 5.2 Startup: `npm run ui`

1. `cli\index.ts` ensures workspace + daemon runtime.
2. `buildUiBundle` runs Vite build.
3. `ensureUiReady` checks two daemon-side probes: `/ui?token=...` bootstrap and `/api/ui-capabilities`.
4. User opens the printed URL containing a one-time token.
5. `daemon.ts` converts the query token into an HTTP-only cookie and redirects to clean `/ui`.
6. React app loads and requests:
   - `/api/ui-capabilities`
   - `/api/files/tree`
   - `/api/graph-data`
   - `/api/rebuild-advisor`

Security semantics:

- UI access becomes cookie-based after the first tokenized launch; refresh thereafter does not need the token in the URL.

### 5.3 Indexing flow: `KnowledgeBaseIndex.sync()`

1. Create `index_runs` row with `running`.
2. Scan all Markdown files under `000_Company_Memory`.
3. Summarize each file and infer metadata.
4. Create one embedding per summary.
5. Upsert `documents` and `knowledge_vectors`.
6. Recompute all references for each doc from Markdown links.
7. Rebuild chunk rows for each doc.
8. Delete stale rows for removed files.
9. Commit transaction.
10. Mark `index_runs` completed, clear graph cache, resolve rebuild log.

Failure behavior:

- wraps DB mutation in explicit transaction; on failure, roll back and mark `index_runs` failed.

### 5.4 Retrieval flow

1. User asks a question through chat or MCP `retrieve_context`.
2. Query is embedded with the currently stored embedding model (or heuristic fallback).
3. Retrieval first tries a keyword-based SQL prefilter over titles, summaries, ontology, paths, status, and owner.
4. Candidate rows are reranked by cosine similarity against stored summary vectors.
5. `buildPromptContext` formats:
   - retrieved summaries for up to 8 docs
   - full chunk-reconstructed content for up to 4 docs within a global char budget
6. Daemon injects that context into a provider-specific system prompt and executes the selected model.

Important implementation choice:

- retrieval is **document-summary-vector-based**, not chunk-vector-based. Chunks are only used to stuff full document bodies into the final prompt.

### 5.5 Bootstrap flow

1. Scan repo for numbered Markdown files still containing placeholders/template markers.
2. Collect intake evidence from active or legacy intake folders plus curated `000_Company_Memory` docs.
3. Block if raw intake is absent; hand off into chat instead of just exiting.
4. Ask for company name and whether to proceed.
5. Optionally delete `000_Acme_Sample_Company_Memory`.
6. Validate bootstrap provider availability in priority order.
7. For each template file in dependency order:
   - build evidence block
   - build accumulated context from already-generated docs
   - call provider
   - write filled Markdown back to file
8. Refresh the knowledge-base index (via daemon if running, otherwise directly).
9. Build UI bundle and surface UI URL if a healthy daemon exists.
10. Persist bootstrap-state summary externally.

### 5.6 UI document edit flow

1. UI opens document via `/api/files/read?path=...`.
2. Daemon validates that the path is Markdown under `000_Company_Memory`.
3. User edits in a local tab.
4. Save calls `/api/files/write`.
5. Daemon writes file contents to disk, then immediately runs `kbIndex.sync()`.
6. Updated graph/index state becomes available to future UI and chat requests.

This is a strong consistency bias: save implies reindex.

### 5.7 Shutdown / lifecycle

- daemon idle timeout defaults to one hour (`shared.ts`).
- any authorized or UI-session request resets the idle timer.
- shutdown closes server, terminal sessions, SQLite handle, removes daemon-state file, and exits process.

## 6. State and Persistence Model

### Source-of-truth state

- Markdown docs under `000_Company_Memory`
- source intake docs under `001_Data_Souces` for bootstrap only

### Derived persistent state

Stored outside repo in workspace root:

- `knowledge-base.sqlite`
- `daemon-state.json`
- `bootstrap-state.json`
- `snapshots\`
- `logs\`
- `cache\`

### Mutable state classes

1. **Filesystem content state**: Markdown documents.
2. **Operational index state**: SQLite tables derived from Markdown.
3. **Session state**: in-memory daemon chat sessions.
4. **Lifecycle state**: daemon/bootstrap JSON state files.

### State transitions

- Markdown change -> index drift -> rebuild advisor flags change -> explicit `sync()` refreshes SQLite.
- UI save -> immediate filesystem write -> immediate `sync()`.
- bootstrap generation -> file overwrites -> index refresh -> optional UI serving.

### Recovery semantics

- daemon-state and bootstrap-state files are atomically rewritten using temp files + rename.
- workspace-storage includes one-time migration from older repo-local state and verifies copied SQLite integrity.
- no durable persistence exists for chat conversation history beyond daemon lifetime.

## 7. Coordination and Control Semantics

### Execution authority

Central authority resides in **one daemon process** plus direct library calls from standalone commands.

### Coordination style

- **centralized**
- mostly **synchronous/directive**
- **request-driven**, not event-stream-driven internally
- **state-derived** for rebuild advice, not message-bus-driven

### Delegation model

- CLI entry delegates to daemon or to direct index/bootstrap functions.
- daemon delegates to:
  - `KnowledgeBaseIndex` for index/retrieval/graph operations
  - provider wrappers for LLM calls
  - `TerminalSessionManager` for UI terminal

### Concurrency boundaries

- daemon can serve multiple requests, but indexing operations call directly into a single SQLite-backed object.
- no explicit job queue, lock manager, or partial-update scheduler exists.
- `sync()` is full-rebuild oriented rather than incremental-by-document.

### Failure propagation

- provider/auth failures surface as command errors.
- indexing failures mark daemon retrieval readiness false until fixed.
- file access validation failures are returned as JSON 400s in UI routes.

### Cancellation / retries

- no general retry framework.
- daemon reuse logic retries startup health polling.
- provider fallback exists only at provider-selection time for bootstrap, not per-document multi-provider retry after validation.

## 8. Configuration and Environment Model

### Required / core configuration

At least one usable model path for chat/bootstrap:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY` or `GOOGLE_API_KEY`
- or local `codex login` / `claude auth login` depending on provider

### Workspace / storage config

- `PULSEOS_HOME`: preferred root for workspace data
- `PULSEOS_WORKSPACE_ID`: explicit workspace selector
- `PULSEOS_LITE_OPEN_SOURCE_CLI_HOME` / `PULSEOS_CLI_HOME`: legacy direct workspace-root overrides

### Daemon config

- `PULSEOS_LITE_OPEN_SOURCE_CLI_DAEMON_IDLE_MS` / `PULSEOS_CLI_DAEMON_IDLE_MS`
- `PULSEOS_LITE_OPEN_SOURCE_CLI_PORT` / `PULSEOS_CLI_PORT`

### Model config

- `PULSEOS_CHAT_OPENAI_MODEL`
- `PULSEOS_CHAT_ANTHROPIC_MODEL`
- `PULSEOS_CHAT_GEMINI_MODEL`
- `PULSEOS_BOOTSTRAP_OPENAI_MODEL`
- `PULSEOS_BOOTSTRAP_ANTHROPIC_MODEL`
- `PULSEOS_BOOTSTRAP_GEMINI_MODEL`

### Auth-mode config

- `PULSEOS_OPENAI_AUTH_MODE=auto|api_key|codex_cli_session`
- `PULSEOS_OPENAI_CODEX_BIN`
- `PULSEOS_CLAUDE_AUTH_MODE=auto|api_key|claude_cli_session`
- `PULSEOS_CLAUDE_BIN`

### Retrieval / embedding config

- `PULSEOS_CLI_EMBEDDING_MODEL`
- `PULSEOS_CLI_EMBEDDING_TIMEOUT_MS`

### Operational prerequisite assumptions

- local filesystem access to repo
- local SQLite support via Node `node:sqlite`
- working Node/npm toolchain
- for UI terminal specifically: a Unix-like shell environment with `python3`, `pty`, and `SHELL` semantics; current implementation is not Windows-native (`cli\daemon.ts`, `cli\terminal_bridge.py`)

## 9. Operational Usage Model

### Canonical workflows

#### Bootstrap a new company

1. Add real source docs under `001_Data_Souces`.
2. `cd cli && npm install`
3. `npm run bootstrap`
4. Review generated docs.
5. Use `npm run chat` and/or `npm run ui`.

#### Use as a maintained company brain

1. Keep `000_Company_Memory` as canonical docs.
2. Run `npm run chat` for retrieval-backed questions.
3. Use `/reload` or `npm run index` after out-of-band Markdown edits.
4. Use `npm run ui` for graph browsing and in-place editing.

#### Use as an MCP-backed retrieval service

1. `cd cli && npm run mcp`
2. Use tool calls for status, rebuild, files, and retrieval context.

### Expected interaction patterns

- Markdown editing is expected to continue outside the UI as well as inside it.
- Rebuild discipline is part of normal operation; docs repeatedly emphasize that graph/index are snapshot-based rather than live-parsed on every refresh.

### Production vs development reality

This repo feels optimized for **local operator use** rather than a deployed multi-user service:

- localhost daemon
- local filesystem assumptions
- local browser token handoff
- no auth/user model beyond local daemon token and cookie

## 10. Extension and Customization Architecture

### Real extension surfaces

1. **Markdown ontology/content**: add docs/folders under `000_Company_Memory`.
2. **Prompt/provider behavior**: modify `cli\auth.ts`, `cli\bootstrap.ts`, `AGENTS.md`, `CLAUDE.md`.
3. **Daemon API surface**: add routes or daemon commands in `cli\daemon.ts`.
4. **MCP tools**: extend `cli\mcp-server.ts`.
5. **Index semantics**: alter metadata extraction, reference parsing, drift logic, or retrieval in `cli\retrieval.ts`.
6. **UI capabilities**: extend React components under `cli\frontend\src`.

### Weak / aspirational extension surfaces

- `WorkspaceStoreProvider` suggests pluggable backends but currently only SQLite exists.
- `crm_objects` / `crm_sync_runs` define a neutral landing schema, but sync providers are not implemented in `cli/`.
- `502_Execution_Engine\ark-engine` documents a richer connector/workflow model, but the checked-in code is scaffold-level.

## 11. Key Architectural Decisions and Tradeoffs

### Markdown-first, SQLite-derived

Why likely chosen:

- keeps the knowledge base transparent, git-friendly, and editable by humans or agents
- allows lightweight retrieval/graph operations without making the DB authoritative

Tradeoff:

- requires explicit rebuild discipline and derived-state synchronization

### Full-document summary vectors instead of chunk vectors

Why likely chosen:

- simpler schema
- cheaper indexing
- easier prompt assembly

Tradeoff:

- weaker fine-grained retrieval for large documents

### External workspace state

Why likely chosen:

- avoid polluting repo with daemon/db artifacts
- support multiple workspaces and migration

Tradeoff:

- operational state becomes less visible to a casual repo reader

### CLI-session auth fallback for OpenAI/Claude

Why likely chosen:

- reduce API-key friction
- allow subscription-backed interactive use

Tradeoff:

- chat/bootstrap and embedding capabilities can diverge operationally

### Immediate reindex on UI save

Why likely chosen:

- strongest user mental model: save means graph/chat are current

Tradeoff:

- potentially expensive for larger knowledge bases

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Cross-platform mismatch in terminal subsystem

Observed:

- `daemon.ts` spawns `python3` and defaults shell to `/bin/zsh`.
- `terminal_bridge.py` relies on `fcntl`, `pty`, and `termios`.

Implication:

- the docked terminal is Unix-centric and likely broken on Windows despite the broader repo being otherwise Node-based.

### 12.2 Retrieval abstraction is simpler than documentation tone suggests

Observed:

- one summary embedding per document
- chunks are stored but not vector-indexed

Implication:

- “vector retrieval” exists, but semantic recall is materially more limited than a chunked RAG system.

### 12.3 `502_Execution_Engine` is mostly aspirational in code

Observed:

- docs describe connectors, workflows, SSE, file API, and GTM pipelines
- actual `ark-engine` code exposes only a health route and boilerplate DB/connectors

Implication:

- there is significant divergence between documented architecture and active code in that subtree.

### 12.4 Rebuild model is coarse

Observed:

- `ensureCurrent()` and `sync()` perform whole-index refreshes rather than selective document updates.

Risk:

- growth in `000_Company_Memory` size will increase latency and embedding cost.

### 12.5 Chat session persistence is ephemeral

Observed:

- daemon stores chat sessions only in memory.

Implication:

- restarting daemon loses conversational state even though knowledge-base state persists.

### 12.6 Domain-agent model is governance-heavy but runtime-light

Observed:

- AGENTS/CLAUDE docs strongly emphasize routing through specialist agents
- main code does not implement a runtime agent-router across those domain files

Inference:

- the “agents” are mainly prompt/governance conventions for external coding assistants and bootstrap semantics, not first-class executing runtime components.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. `cd cli`
2. `npm install`
3. `npm run chat`

This creates or refreshes workspace storage, starts the daemon, and ensures the SQLite knowledge-base index exists.

### Operational Assumptions

- single operator or local-team use on a developer machine
- markdown-first workflow discipline
- willingness to rebuild index after file-level KB changes
- tolerance for heuristic embeddings when no OpenAI embedding key is available
- directory taxonomy in `000_Company_Memory` is treated as meaningful ontology, not arbitrary organization

### Canonical Workflow

1. add or edit Markdown docs under `000_Company_Memory`
2. rebuild (`/reload`, `npm run index`, or UI rebuild action) if edit happened outside the UI
3. query with `npm run chat`
4. inspect/edit in `npm run ui`
5. use bootstrap only when generating/filling template docs from intake

### Advanced Usage

- run `npm run mcp` to expose retrieval/status tools to another agent host
- override workspace IDs to isolate environments
- switch providers/models with `/model ...`
- use rebuild advisor to detect stale graph/index state before paying embedding cost

### Extension Workflow

- change indexing/retrieval semantics in `cli\retrieval.ts`
- add daemon commands/routes in `cli\daemon.ts`
- add UI capabilities in `cli\frontend\src`
- extend bootstrap ordering/prompt rules in `cli\bootstrap.ts`
- update `AGENTS.md` / `CLAUDE.md` when domain conventions evolve

### Debugging Workflow

Best inspection points:

- `npm run status`
- daemon `/status` data path via CLI
- workspace files under `~\.pulseos\workspaces\<workspace-id>\...`
- `index_runs` and `rebuild_change_log` inside `knowledge-base.sqlite`
- browser UI compatibility failures via `/api/ui-capabilities`

### Observability

- CLI commands print structured status text
- daemon writes basic startup/indexing logs to stdout
- SQLite tables provide durable operational evidence (`index_runs`, `rebuild_change_log`)
- UI errors surface as explicit messages when daemon/UI versions drift

### Failure Modes

- missing provider credentials -> chat/bootstrap provider validation failure
- missing intake -> bootstrap blocks and hands off to chat
- stale daemon -> CLI restarts daemon
- missing UI build -> daemon serves “UI is not built yet”
- path violations in editor -> daemon rejects read/write outside `000_Company_Memory`
- embedding provider failure -> retrieval silently falls back to heuristic embedding mode during provider creation

### Performance Considerations

- full `sync()` cost scales with count and size of Markdown docs
- provider embeddings add network latency and possible API cost
- graph rendering complexity is handled with Cytoscape incremental layout logic, suggesting the UI has already encountered larger-graph pressure

## 14. Project Navigation Guide

### Best reading order

1. `README.md`
2. `01_RUNME.md`
3. `cli\package.json`
4. `cli\index.ts`
5. `cli\daemon.ts`
6. `cli\retrieval.ts`
7. `cli\bootstrap.ts`
8. `cli\bootstrap-intake.ts`
9. `cli\shared.ts` and `cli\workspace-storage.ts`
10. `cli\frontend\src\App.tsx` and `cli\frontend\src\lib\graph-snapshot.ts`
11. tests under `cli\*.test.ts`

### Critical files / semantic centers

- `cli\retrieval.ts` — index schema, retrieval, graph generation, rebuild advisor
- `cli\daemon.ts` — runtime control topology and all API surfaces
- `cli\bootstrap.ts` — generation pipeline and provider selection
- `cli\bootstrap-intake.ts` — evidence selection and intake rules
- `cli\auth.ts` — provider execution/auth semantics
- `cli\workspace-storage.ts` — externalized state layout and migration

### Highest-value execution paths

- `index.ts -> ensureRuntime -> daemon.ts -> KnowledgeBaseIndex.ensureCurrent()`
- `daemon.ts /command chat -> buildPromptContext -> provider call`
- `bootstrap.ts -> collectBootstrapIntake -> fillTemplate loop -> refreshCompanyMemoryIndex`
- `frontend App -> /api/files/write -> kbIndex.sync()`

### Where abstractions become concrete

- `WorkspaceStore` becomes `KnowledgeBaseIndex` in `cli\workspace-store.ts`
- provider-neutral chat/bootstrap interfaces become OpenAI/Claude/Gemini execution in `cli\auth.ts` / `cli\bootstrap.ts`
- graph “ontology” becomes concrete folder/document/reference nodes in `cli\retrieval.ts`

## 15. Concise Deep Technical Synthesis

PulseOS-Lite is best understood as a **local company-brain operating runtime**: a Markdown knowledge base under `000_Company_Memory`, a SQLite-derived retrieval/graph cache outside the repo, and a daemon that turns that cache into chat, graph UI, file editing, and MCP tools. Its distinctive pattern is not “multi-agent execution” so much as **LLM-assisted maintenance of a structured business wiki with an opinionated domain ontology and bootstrap flow**.

Architecturally it embodies a **Markdown-first, daemon-mediated, retrieval-backed workspace**. The repo is optimized for engineers or operators who are comfortable treating documents like code: edit Markdown, rebuild derived state, query through a local toolchain, and evolve prompt/schema conventions alongside the content model. The strongest implemented systems are the index/rebuild/graph/access layers in `cli/`; the broader “agent OS” and `502` execution-engine narrative extends beyond what is fully realized in code today.
