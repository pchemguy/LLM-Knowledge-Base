---
repo: rohitg00/agentmemory
---

# agentmemory Onboarding Report

## SYNOPSIS

### Implementation Identity

**Observed:** this repository is a long-lived **memory service for coding agents**, not a markdown-first wiki manager. The dominant runtime is `src/index.ts`, which registers a large set of iii-engine functions/triggers, attaches HTTP + MCP surfaces, loads/persists search indexes, and starts a local viewer. The semantic center is the path **hook/event ingestion -> observation normalization/compression -> search/context retrieval -> optional summarization/consolidation** (`src/functions/observe.ts`, `compress.ts`, `search.ts`, `smart-search.ts`, `summarize.ts`, `consolidation-pipeline.ts`).

**Inference:** architecturally this is best understood as an **iii-engine worker that exposes a memory runtime**, with optional agent-facing conveniences (CLI bootstrap, Claude plugin hooks, MCP shim, viewer, first-party integrations). It operationalizes Karpathy-style compounding knowledge, but replaces the wiki layer with structured KV state plus optional Obsidian export.

### Quick Adaptation Assessment

The codebase is modular at the function/trigger boundary, but behavior is tightly coupled around iii-engine primitives and shared KV scopes. Safe extensions usually require wiring through multiple surfaces: iii function registration in `src/index.ts`, REST endpoints in `src/triggers/api.ts`, MCP definitions/handlers in `src/mcp/tools-registry.ts` and `src/mcp/server.ts`, and often tests. Retrieval and capture code are the highest-risk change points because they feed most other features.

### Fastest Path to First Successful Run

The quickest full-path run is the published CLI:

```bash
npx @agentmemory/agentmemory
```

That path exists because `src/cli.ts` is responsible for locating or bootstrapping the pinned iii-engine runtime, then the worker in `dist/index.mjs` exposes REST on `:3111`, streams on `:3112`, and the viewer on `:3113`. If you only need tools and not the full service, the fastest path is the standalone MCP path:

```bash
npx -y @agentmemory/agentmemory mcp
```

### Minimal Manual Setup Path

There is a meaningful manual path for **tool-only** usage: run `dist/standalone.mjs` / `@agentmemory/mcp`, which uses `src/mcp/standalone.ts`. That mode either proxies to a reachable server or falls back to a local JSON-backed `InMemoryKV`.

For the **full server**, there is no truly script-free path independent of iii-engine because `src/index.ts` is a worker that expects an iii engine and state/stream workers behind it. The nearest manual route is:

1. provide iii-engine v0.11.2 (explicitly pinned in `src/cli.ts` and `README.md`);
2. use the repo’s iii config (`iii-config.yaml`) or Docker compose to start engine services;
3. run the built worker (`node dist/index.mjs`) or `tsx src/index.ts`.

### Operational Complexity Snapshot

Core operation is moderate complexity: one Node worker, but it depends on iii-engine, local KV/file stores, hook clients, and optional LLM/embedding providers. Core search/capture paths are well-tested; advanced orchestration features are broader and more optional. Debugging support is above average: viewer, health endpoint, config-flags endpoint, CLI `status`/`doctor`, stderr logs, OTEL/iii console integration. The most fragile areas are environment/runtime mismatches (notably iii-engine version pinning), provider configuration, and optional feature-flag interactions.

## 1. Repository Purpose

**Actual implemented purpose:** agentmemory provides persistent, queryable memory for AI coding agents across sessions and across clients. It captures session events and tool activity through hooks or direct API calls, compresses them into structured observations, indexes them for retrieval, optionally synthesizes higher-order summaries/facts/procedures, and exposes that state through REST, MCP, a viewer, and integrations.

**Relationship to the conceptual description:** the supplied “LLM Wiki” concept describes a persistent intermediary knowledge artifact between raw sources and future answers. agentmemory implements the same compounding-memory goal, but **not** as a directory of canonical markdown pages. Its primary artifact is structured iii-engine KV state (`src/state/schema.ts`, `src/types.ts`), not a mutable wiki tree. The closest wiki-like output is the optional `mem::obsidian-export` bridge in `src/functions/obsidian-export.ts`.

**Problem actually being solved:** preserving coding-session context and learned patterns so agents do not restart from zero each session. The repo is optimized for coding-agent telemetry, recall, and coordination rather than generic document ingestion.

**Target use cases:**

1. persistent recall of prior code changes, decisions, errors, and file history;
2. background session capture through Claude/plugin-style hooks;
3. agent-agnostic access through REST and MCP;
4. optional multi-agent coordination primitives (actions, leases, routines, signals, checkpoints, mesh sync);
5. exporting selected memory state to Markdown/Obsidian.

**Scope boundaries:**

- It is **not** primarily a raw-document repository manager.
- It is **not** a general agent runtime in the Letta/MemGPT sense.
- It does **not** treat markdown files as the source of truth.
- It does **not** persist a clean immutable raw-source layer; observations are normalized into KV records, and compressed observations overwrite raw entries in `KV.observations(...)` after capture (`src/functions/observe.ts`, `compress.ts`).

## 2. High-Level System Model

This project is fundamentally an **orchestration-centric memory worker** hosted inside iii-engine. The dominant pattern is:

1. **ingest runtime signals** from hooks, REST calls, imported transcripts, or integrations;
2. **normalize and persist** them into typed KV scopes;
3. **derive retrieval artifacts** (BM25 index, optional vector index, optional graph edges, session summaries, semantic/procedural memories);
4. **serve retrieval and coordination APIs** back to agents and operators.

The project’s behavioral intelligence lives primarily in:

- `src/functions/observe.ts` and `compress.ts` for turning agent telemetry into reusable observations;
- `src/state/hybrid-search.ts`, `src/functions/search.ts`, and `smart-search.ts` for retrieval;
- `src/functions/summarize.ts`, `consolidation-pipeline.ts`, `graph.ts`, `reflect.ts`-adjacent features for memory evolution;
- `src/triggers/api.ts`, `src/mcp/server.ts`, and hook scripts for exposing the runtime to clients.

The repo’s secondary identity is a **surface aggregator**: one memory kernel is exposed simultaneously as iii functions, REST endpoints, MCP tools/resources/prompts, CLI commands, hook scripts, viewer pages, and a standalone MCP shim.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status here | Concrete implementation | Semantics / limitations |
|---|---|---|---|
| Persistent intermediary knowledge artifact | **Implemented, but structured rather than markdown-first** | KV scopes in `src/state/schema.ts`, typed in `src/types.ts` | Primary state is not a wiki tree; observations, memories, summaries, semantic/procedural memories are stored in iii-backed KV. |
| Incremental ingestion of new sources | **Implemented for agent events and some external feeds** | Hooks in `src/hooks/`, `/agentmemory/observe` in `src/triggers/api.ts`, JSONL import in CLI, filesystem connector in `integrations/filesystem-watcher/` | Optimized for coding-agent telemetry, not generic article/paper ingestion. |
| Cross-document/source synthesis | **Partially implemented** | `summarize.ts`, `consolidation-pipeline.ts`, `graph.ts`, lessons/crystals/reflect features | Syntheses are summaries/facts/procedures/graph nodes, not curated prose pages. |
| Query against accumulated knowledge | **Implemented centrally** | `mem::search`, `mem::smart-search`, `mem::context`, HybridSearch, REST + MCP surfaces | BM25 is always available; vector/graph are optional and best-effort. |
| Health/lint pass over knowledge base | **Implemented in system form, not wiki lint form** | health monitor, diagnostics, verify/governance/audit, doctor/status | Focuses on service health, provenance, governance, and stale operational state rather than wiki link quality. |
| Human-browsable persistent knowledge layer | **Partially implemented** | viewer (`src/viewer/server.ts`), optional Obsidian export (`obsidian-export.ts`) | Viewer is API-backed runtime UI, not canonical storage. Obsidian export is derived output. |
| Schema-guided maintenance discipline | **Implemented** | `AGENTS.md`, config loading in `src/config.ts`, tool registries, strong function/trigger wiring conventions | Discipline is code/runtime-centric, not markdown-schema-centric. |
| Shared multi-client memory | **Implemented** | REST, MCP, standalone proxy, integrations, team memory, mesh sync | One running server can serve many clients; standalone MCP local fallback is limited. |

## 4. Architecture and Component Analysis

### 4.1 Runtime kernel: iii-engine worker composition

**Owned responsibility:** boot the worker, choose providers, register all functions/triggers/endpoints, restore indexes, and manage periodic jobs.

**Key files:** `src/index.ts`, `iii-config.yaml`, `src/config.ts`.

`src/index.ts` is the actual composition root. It:

- creates the iii worker via `registerWorker(...)`;
- wraps iii state with `StateKV`;
- instantiates search/index objects;
- registers every memory function;
- attaches REST triggers, event subscribers, and MCP endpoints;
- restores persisted BM25/vector indexes through `IndexPersistence`;
- starts health monitoring and the viewer;
- installs in-process timers for auto-forget, lesson/insight decay, and consolidation.

This is the most important file for understanding what is truly “live” in the system.

### 4.2 State and search infrastructure

**Owned responsibility:** durable storage abstraction, scope naming, BM25/vector persistence, hybrid retrieval.

**Key files:** `src/state/kv.ts`, `schema.ts`, `search-index.ts`, `vector-index.ts`, `index-persistence.ts`, `hybrid-search.ts`, `memory-utils.ts`.

Important boundaries:

- `StateKV` is only a thin iii `state::*` wrapper, so persistence semantics belong to iii-engine.
- `KV` in `schema.ts` is the real namespace map; it reveals the data model more accurately than directory names.
- BM25 and vector indexes are in-memory indexes with serialized persistence back into KV (`KV.bm25Index`), not separate databases.
- `HybridSearch` fuses BM25/vector/graph via weighted reciprocal-rank fusion and then diversifies by session.

**Hidden coupling:** saved `Memory` objects must be coercible to `CompressedObservation` for retrieval surfaces to work. The recent changelog and `memoryToObservation` fallback logic show this is a recurring integration edge.

### 4.3 Capture and normalization pipeline

**Owned responsibility:** turn session/tool events into structured observations suitable for recall.

**Key files:** `src/functions/observe.ts`, `compress.ts`, `compress-synthetic.ts`, `privacy.ts`, `dedup.ts`, hook scripts in `src/hooks/`.

Observed behavior:

- payloads arrive as `HookPayload`;
- secrets/private markers are stripped before storage;
- deduplication is applied per session/tool-input pattern;
- images are optionally extracted to managed disk storage and embedded;
- raw observations are first written, session counters updated, and stream events emitted;
- then either LLM compression (`mem::compress`) or synthetic compression rewrites the stored observation into compressed form.

This pipeline is the repo’s main semantic gateway. Everything downstream assumes the compressed observation shape.

### 4.4 Retrieval and context generation

**Owned responsibility:** expose recall to agents in different formats and budgets.

**Key files:** `src/functions/search.ts`, `smart-search.ts`, `context.ts`, `src/state/hybrid-search.ts`.

There are two distinct retrieval surfaces:

- `mem::search`: returns full/compact/narrative result shapes over the BM25 index, optionally token-budgeted and session-filtered.
- `mem::smart-search`: returns compact hybrid-ranked IDs or expanded observations, acting as the main MCP/REST recall tool.

`mem::context` is separate from search: it constructs an XML-wrapped context block from project profile + recent summaries + fallback high-importance observations. That is the main “inject memory into future session” path.

### 4.5 Memory evolution subsystems

**Owned responsibility:** move from per-event traces to longer-lived abstractions.

**Key files:** `summarize.ts`, `consolidation-pipeline.ts`, `remember.ts`, `graph.ts`, lesson/crystal/reflect-related modules.

Sub-layers:

- **session summaries**: episodic condensation at session stop;
- **saved memories**: explicit durable facts/patterns/preferences/workflows with versioning/supersession;
- **semantic/procedural memory**: optional consolidation from summaries and recurrent patterns;
- **graph extraction**: optional entity/relation extraction from observations;
- **lessons/crystals/insights**: richer derived layers beyond the original core capture/search path.

**Maturity observation:** summaries, remember/save, and graph extraction are wired into live flows. Deeper reflective layers exist and are tested, but are not as central to baseline operation.

### 4.6 Coordination/orchestration primitives

**Owned responsibility:** use memory storage as a shared coordination substrate for multiple agents or structured workflows.

**Key files:** `actions.ts`, `leases.ts`, `routines.ts`, `signals.ts`, `checkpoints.ts`, `mesh.ts`, `frontier.ts`, `sentinels.ts`, `sketches.ts`.

Semantically:

- `Action` + `ActionEdge` model work items and dependencies;
- leases prevent two agents from actively claiming the same action;
- routines instantiate action graphs from reusable step templates;
- signals form lightweight inter-agent messaging threads with receipts/expiry;
- mesh sync replicates selected scopes to remote peers over authenticated HTTP.

These features are architecturally interesting because they stretch the repo from “memory service” toward “shared agent coordination substrate”, but they are not on the critical path for ordinary memory capture/retrieval.

### 4.7 Client surfaces and operator tooling

**Owned responsibility:** expose the kernel to humans and external agents.

**Key files:** `src/triggers/api.ts`, `src/mcp/server.ts`, `src/mcp/tools-registry.ts`, `src/mcp/standalone.ts`, `src/cli.ts`, `src/viewer/server.ts`, `plugin/.claude-plugin/plugin.json`, `integrations/*`.

Surfaces:

- REST API: main programmable HTTP interface, with 100+ endpoints registered in `registerApiTriggers`;
- MCP server: server-backed tool list/call surface with tool visibility modes;
- standalone MCP shim: proxy-first, local-fallback second;
- CLI: bootstrap/status/doctor/demo/import/upgrade/orchestration helper;
- viewer: local HTML shell plus proxy to REST API;
- first-party integrations: Claude plugin, Hermes/OpenClaw/pi extensions, filesystem watcher.

### 4.8 Supporting infrastructure

**Owned responsibility:** health, observability, metrics, logging, testing.

**Key files:** `src/health/monitor.ts`, `src/telemetry/setup.ts`, `src/logger.ts`, `iii-config.yaml`, `test/`.

This is more than boilerplate. The project relies on:

- periodic health snapshots persisted to KV;
- OTEL/iii observability worker configuration;
- structured stderr logs;
- very broad Vitest coverage across core and advanced features;
- a separate integration test requiring a live running server.

## 5. Execution Flow Analysis

### 5.1 Startup and initialization

1. `src/cli.ts` is the normal entry point for users (`package.json` bin `agentmemory`).
2. CLI resolves base URLs/ports, can auto-start iii-engine or Docker, and offers helper commands (`status`, `doctor`, `demo`, `mcp`, `import-jsonl`, `upgrade`).
3. The worker process enters `src/index.ts:main()`.
4. `loadConfig()` / embedding/fallback config select provider strategy from `~/.agentmemory/.env` + process env.
5. `registerWorker(...)` connects to iii-engine.
6. `StateKV`, metrics store, dedup map, and optional vector index are created.
7. All memory functions are registered.
8. REST triggers, durable event subscribers, and MCP endpoints are registered.
9. `IndexPersistence.load()` restores BM25/vector state; if absent, `rebuildIndex()` walks sessions and memories.
10. Viewer and health monitor start; periodic timers are armed; signal handlers save indexes and shut down cleanly.

### 5.2 Session start / context injection

1. A hook or client posts to session-start APIs/events.
2. `event::session::started` (`src/triggers/events.ts`) creates a `Session` entry in `KV.sessions`.
3. It immediately calls `mem::context`.
4. `mem::context` loads project profile, recent summaries, and important observations from prior sessions in the same project, trims to budget, and returns XML-wrapped context.
5. Hook scripts may or may not emit that context into the agent conversation depending on `AGENTMEMORY_INJECT_CONTEXT`.

Important nuance: the code comments in `src/hooks/pre-tool-use.ts` and config logic show context injection is now **opt-in and disabled by default** for cost/safety reasons.

### 5.3 Observation ingestion

1. Hook scripts such as `src/hooks/post-tool-use.ts` POST `HookPayload` JSON to `/agentmemory/observe`.
2. The API layer validates/authenticates and routes to `mem::observe`.
3. `mem::observe` validates payload shape, deduplicates, strips secrets, extracts tool/prompt/image fields, and writes the raw observation.
4. Session counters and first prompt metadata are updated.
5. Raw events are emitted to iii streams for live viewer updates.
6. Compression path diverges:
   - if `AGENTMEMORY_AUTO_COMPRESS=true`, `mem::compress` runs asynchronously through the configured provider;
   - otherwise synthetic compression is built immediately and written back.
7. The compressed observation is added to the search index and emitted to streams.

### 5.4 Session stop / summarization / optional graph extraction

1. A stop event triggers `event::session::stopped`.
2. It calls `mem::summarize` over compressed observations for the session.
3. If slot reflection is enabled, it fire-and-forgets `mem::slot-reflect`.
4. If graph extraction is enabled, it loads compressed observations and fire-and-forgets `mem::graph-extract`.
5. A later end event marks the session completed with `endedAt`.

This split between “stopped” and “ended” matters: summarization and graph extraction happen during stop handling, while final status mutation happens in `event::session::ended`.

### 5.5 Retrieval flow

For `memory_smart_search` / `/agentmemory/smart-search`:

1. client hits REST or MCP surface;
2. routing code validates arguments and triggers `mem::smart-search`;
3. `HybridSearch` runs BM25, optional vector embedding/search, optional graph/entity retrieval;
4. results are fused via weighted RRF and session-diversified;
5. result IDs are rehydrated from `KV.observations(...)`, with fallback to `KV.memories`;
6. compact results or expansions are returned and access logs updated.

For `mem::search`, the flow is similar but BM25-centric and supports narrative/full modes plus token budgeting.

### 5.6 Periodic maintenance flow

The worker itself owns several `setInterval(...).unref()` timers in `src/index.ts`:

- auto-forget;
- lesson decay sweep;
- insight decay sweep;
- optional consolidation pipeline.

This is notable: not all lifecycle work is outsourced to iii cron. Some maintenance semantics are process-local timers, meaning a dead worker means paused maintenance until restart.

### 5.7 Standalone MCP flow

1. `src/mcp/standalone.ts` starts a stdio MCP transport.
2. On first use it tries to resolve a live server handle (`rest-proxy` path).
3. If the server is reachable, tool calls are proxied to the running server (`/sessions`, `/smart-search`, `/mcp/call`, etc.).
4. If unreachable, only a small local subset is serviced by `InMemoryKV`.

The changelog and tests make clear that proxying to the server is the intended modern behavior; local fallback is compatibility/survivability, not feature parity.

## 6. State and Persistence Model

### State ownership

State is owned primarily by iii-engine KV scopes, not by in-process classes. `StateKV` is only a transport. Major scopes include:

- session lifecycle: `KV.sessions`, per-session `KV.observations(sessionId)`, `KV.summaries`;
- durable memories: `KV.memories`, `KV.semantic`, `KV.procedural`, `KV.lessons`, `KV.crystals`, `KV.insights`;
- retrieval artifacts: `KV.bm25Index`, `KV.embeddings(...)`, `KV.imageEmbeddings`, `KV.graphNodes`, `KV.graphEdges`;
- coordination state: `KV.actions`, `KV.actionEdges`, `KV.leases`, `KV.routines`, `KV.routineRuns`, `KV.signals`, `KV.checkpoints`, `KV.mesh`, `KV.sentinels`, `KV.sketches`, `KV.facets`;
- operational state: `KV.health`, `KV.metrics`, `KV.audit`, `KV.accessLog`, `KV.state`.

### Mutable vs immutable behavior

Most state is mutable last-write-wins KV data. Notable cases:

- observations are overwritten from raw to compressed form;
- saved memories are versioned and supersede earlier versions rather than updating in place semantically, though both are mutable records;
- mesh sync applies last-write-wins timestamp merges;
- vector/BM25 indexes are mutable in-memory caches serialized back to KV.

### Persistence mechanisms

`iii-config.yaml` configures iii-state and iii-stream with file-based stores:

- `./data/state_store.db` for KV-backed state;
- `./data/stream_store` for streams.

Indexes are persisted as serialized blobs in KV via `IndexPersistence`, not via separate index files.

### Recovery semantics

- on startup, persisted indexes are loaded;
- if BM25 is absent, `rebuildIndex()` reconstructs it from sessions and memories;
- vector persistence has a strong dimension guard and may refuse startup if stored vectors mismatch the active provider;
- standalone MCP fallback persists local memory to a JSON file path from `getStandalonePersistPath()`.

## 7. Coordination and Control Semantics

The control topology is mostly **centralized and directive**:

- iii-engine owns trigger dispatch and function invocation;
- the agentmemory worker owns almost all business semantics;
- clients are mostly thin producers/consumers.

### Who controls whom

- hook scripts, integrations, and clients do **not** perform memory logic themselves; they submit payloads to REST/MCP.
- `src/index.ts` decides which features exist at runtime through registration and config gating.
- event subscribers in `src/triggers/events.ts` coordinate session lifecycle.
- `withKeyedLock(...)` is the main in-process synchronization primitive for conflicting writes (remember, actions, leases, routines, mesh merges).

### Task/work routing

- external requests route through REST or MCP handlers;
- both surfaces mostly translate into `sdk.trigger({ function_id: "mem::..." })`;
- higher-level functions then manipulate KV or trigger additional async work.

### Concurrency model

- request handling is async Node I/O with selective locking;
- capture/search is mostly synchronous request/response plus some fire-and-forget side effects;
- compression/graph extraction/viewer stream publishing often run as non-blocking secondary work;
- periodic maintenance uses process-local timers.

### Failure propagation

- many advanced/optional features are best-effort and intentionally non-fatal (graph search fallback, stream publish failures, health worker listing, viewer proxy failures);
- provider calls are wrapped in `ResilientProvider` with a circuit breaker;
- persistence failures are throttled and logged, often preserving in-memory state until later save;
- standalone MCP invalidates proxy handles and falls back locally when the server disappears.

## 8. Configuration and Environment Model

### Configuration hierarchy

`src/config.ts` merges:

1. `~/.agentmemory/.env`;
2. process environment;
3. explicit runtime overrides.

### Required vs optional configuration

**Required for full server:** iii-engine runtime. The repo is explicitly pinned to iii-engine `0.11.2` in `src/cli.ts` and README/changelog because newer engine architecture is incompatible with the current worker model.

**Optional for baseline functionality:** LLM provider keys. Without them, provider selection falls back to `noop`, and the system still supports synthetic compression/BM25 recall.

**Optional for richer features:**

- embedding provider or local transformers for vector search;
- `GRAPH_EXTRACTION_ENABLED=true`;
- `CONSOLIDATION_ENABLED=true`;
- `AGENTMEMORY_AUTO_COMPRESS=true`;
- `AGENTMEMORY_INJECT_CONTEXT=true`;
- slots/reflect/team/snapshot/mesh-related envs;
- `AGENTMEMORY_SECRET` for auth-protected surfaces and mesh sync.

### Runtime modes

1. **Full server mode:** CLI + iii-engine + REST + streams + viewer.
2. **Standalone MCP mode:** stdio MCP, proxying to full server if available.
3. **No-op provider mode:** default safe mode with capture and BM25 recall but no LLM-backed summarization/compression.

## 9. Operational Usage Model

### Canonical workflow

1. start agentmemory in a separate terminal;
2. connect an agent via plugin hooks, MCP config, or REST;
3. let hooks capture session activity automatically;
4. query via `memory_smart_search`, `memory_recall`, file history, timeline, etc.;
5. optionally save explicit memories, lessons, or actions;
6. inspect the viewer / health / doctor output;
7. optionally export or sync derived state.

### What actual users/operators interact with

- developers/operators start it with CLI commands, inspect status/doctor output, and browse `http://localhost:3113`;
- agents interact through hooks and MCP tools;
- power users may call REST endpoints or iii console directly;
- external systems can ingest through `/agentmemory/observe` or connector packages.

### Session/task lifecycle

The intended lifecycle is session-centric, not document-centric:

- session starts -> contextual recall;
- tool/prompt/subagent events accumulate observations;
- session stop/end triggers summarization and status finalization;
- future sessions search across accumulated history.

## 10. Extension and Customization Architecture

### Primary extension boundaries

1. **iii functions/triggers:** add new runtime behavior through `sdk.registerFunction` / `sdk.registerTrigger`.
2. **REST:** expose new functionality through `src/triggers/api.ts`.
3. **MCP:** add tools in `src/mcp/tools-registry.ts` and implement handlers in `src/mcp/server.ts`.
4. **Hook scripts/integrations:** add new event producers that POST valid `HookPayload` JSON.
5. **Providers:** extend LLM/embedding support in `src/providers/`.
6. **iii workers:** compose new engine capabilities through iii rather than custom infra (`README` “Powered by iii” section).

### How the system expects to evolve

The repo strongly prefers **adding new behavior as more iii functions on shared state** rather than introducing separate services. Even external packages like the filesystem watcher are thin producers that target the existing observe endpoint rather than defining parallel ingestion systems.

### Clean vs leaky boundaries

Function/trigger registration is a clean boundary. The leakiest parts are cross-surface consistency requirements: one feature often must be updated in registration, REST, MCP, docs, plugin metadata, and tests.

## 11. Key Architectural Decisions and Tradeoffs

1. **iii-engine as the sole substrate.** This eliminates bespoke infra layers but tightly couples the repo to iii’s worker/state/trigger model and currently to a specific engine version.
2. **Structured state over markdown-as-source.** Better for query/runtime coordination, worse if you wanted a human-authored canonical wiki.
3. **Synthetic compression by default.** Safer and cheaper out of the box; less semantically rich than always-on LLM compression.
4. **One worker, many surfaces.** Great reach (REST/MCP/hooks/viewer), but increases consistency burden.
5. **In-memory search indexes with KV persistence.** Simple and local, but implies moderate scale assumptions and startup/rebuild complexity.
6. **Optional advanced layers instead of strict core.** Graph, consolidation, lessons, routines, mesh, slots, etc. can all be enabled incrementally, but the system becomes cognitively wide.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### Evidence-grounded issues

1. **Engine-version pin as architectural debt.** `src/cli.ts` and changelog explicitly state agentmemory has not been refactored for iii-engine’s newer sandbox worker model.
2. **Documentation/stat drift exists.** `AGENTS.md` still contains old counts/version stats, while README/plugin/package are newer. Tool-count enforcement in tests is loose (`>=41`) compared with README/plugin claims of 50/51 tools.
3. **Raw-source immutability is weaker than the conceptual LLM-wiki pattern.** Observations are transformed in place rather than retaining a canonical immutable raw layer.
4. **Advanced subsystems appear broader than their integration depth.** Actions/leases/routines/signals/mesh/sketches/sentinels are implemented and tested, but core product identity and runtime flow still center on capture/search. These look like an expanding platform rather than a uniformly mature surface.
5. **Process-local timers for maintenance.** Some lifecycle work depends on the worker staying alive, rather than fully durable scheduling.
6. **Standalone MCP local mode is intentionally partial.** Good for survival, but users can misread it as feature-equivalent unless they notice proxy-vs-local semantics.

### Inferred risks

- Search/vector infrastructure is local-memory-centric; very large corpora may stress startup, rebuild, and scan-time behavior.
- Cross-surface wiring makes feature work easy to miss in one place.
- The project’s breadth increases onboarding cost even though the central path is conceptually narrower.

## 13. Practical Usage Guide

### Minimal Viable Usage

**Tool-only:** run standalone MCP (`npx -y @agentmemory/agentmemory mcp`).

**Full memory service:** run the CLI with iii-engine available (`npx @agentmemory/agentmemory`), then connect an agent through MCP or plugin hooks.

### Operational Assumptions

- Node 20+ environment.
- Localhost-only service by default (`iii-config.yaml`, viewer binding).
- Users are comfortable with environment-variable configuration and running a background service.
- Moderate memory scale rather than massive corpus/search-cluster scale.
- Agents or integrations will emit reasonably structured session/tool events.

### Canonical Workflow

1. start server;
2. connect agent/client;
3. let hooks auto-capture;
4. query with smart search/recall/context;
5. inspect viewer/doctor/health when needed;
6. optionally export to Obsidian or add higher-order memory features.

### Advanced Usage

- enable graph extraction and consolidation with provider keys;
- run filesystem watcher against repos or notes directories;
- use actions/leases/routines/signals for multi-agent coordination;
- use mesh sync for peer replication;
- use iii console for direct function/state inspection.

### Extension Workflow

Read in this order:

1. `src/index.ts`
2. target function module in `src/functions/`
3. `src/triggers/api.ts`
4. `src/mcp/tools-registry.ts` and `src/mcp/server.ts`
5. matching tests in `test/`

Then wire the feature through every relevant surface.

### Debugging Workflow

- `agentmemory doctor` / `agentmemory status` from CLI;
- `GET /agentmemory/health` and `/agentmemory/config/flags`;
- viewer on `:3113`;
- iii console on `:3114`;
- stderr logs emitted by `src/logger.ts`;
- integration tests for live server behavior.

### Observability

Observed support includes:

- persisted health snapshots;
- OTEL metrics initialization;
- iii observability worker in `iii-config.yaml`;
- viewer live stream updates;
- audit log scopes for state-changing operations.

### Failure Modes

- iii-engine version mismatch / startup failure;
- missing provider keys leading to noop summarization/compression;
- embedding-dimension mismatch blocking vector index restore;
- unreachable REST server causing standalone MCP fallback;
- optional feature flags producing “empty” functionality until enabled.

### Performance Considerations

- vector search is an in-memory cosine scan over stored embeddings;
- indexes are serialized/deserialized as blobs;
- graph retrieval and reranking are optional add-on costs;
- per-observation LLM compression and context injection are deliberately off by default because of token/runtime cost.

## 14. Project Navigation Guide

### Highest-value entry points

1. `src/index.ts` — actual live system composition.
2. `src/config.ts` — runtime mode/feature/provider selection.
3. `src/functions/observe.ts` — ingestion gateway.
4. `src/functions/compress.ts` and `src/functions/search.ts` — core memory formation/retrieval.
5. `src/state/hybrid-search.ts` — retrieval fusion logic.
6. `src/triggers/api.ts` — concrete external API surface.
7. `src/mcp/server.ts` + `src/mcp/tools-registry.ts` — MCP exposure.
8. `src/cli.ts` — operational entry point and engine bootstrap logic.

### Best reading order

1. `README.md` sections “How it Works”, “MCP Server”, “Configuration”.
2. `src/index.ts`
3. `src/types.ts` + `src/state/schema.ts`
4. `observe.ts`, `compress.ts`, `search.ts`, `smart-search.ts`, `context.ts`
5. `summarize.ts`, `remember.ts`, `consolidation-pipeline.ts`, `graph.ts`
6. `triggers/api.ts`, `triggers/events.ts`
7. `cli.ts`, `mcp/standalone.ts`, `viewer/server.ts`
8. tests for the relevant subsystem

### Semantic centers

- **capture/compression:** `src/functions/observe.ts`, `compress.ts`
- **retrieval:** `src/functions/search.ts`, `smart-search.ts`, `src/state/hybrid-search.ts`
- **session evolution:** `summarize.ts`, `consolidation-pipeline.ts`
- **surface translation:** `triggers/api.ts`, `mcp/server.ts`

### Where abstractions become concrete

- iii abstractions become concrete in `src/index.ts` and `src/triggers/*`;
- provider abstractions become concrete in `src/providers/index.ts`;
- conceptual “memory” becomes concrete in `src/types.ts` and `src/state/schema.ts`;
- external integrations become concrete in hook scripts and `integrations/filesystem-watcher/`.

## 15. Concise Deep Technical Synthesis

agentmemory is a **persistent memory worker for coding agents built as an iii-engine application**. Its real architecture is not “wiki software” but **event capture + typed memory formation + hybrid retrieval + multi-surface exposure**. It embodies a compounding-knowledge model similar in spirit to the LLM Wiki idea, but specializes it for coding-session telemetry and operational reuse rather than for human-curated markdown as the primary artifact.

The project is strongest where capture, search, and operator tooling meet: hook ingestion, recall, context generation, REST/MCP access, viewer/doctor/health, and compatibility across multiple agent clients. It appears optimized for small teams or power users who want one local memory substrate shared across agents. Engineers modifying it should think in iii primitives and KV scopes first, not in web-framework or plugin-framework terms.
