---
repo: swarmclawai/swarmvault
---

# SwarmVault Onboarding Report

## SYNOPSIS

### Implementation Identity

SwarmVault is **not primarily a chat app or a thin RAG wrapper**. The implementation is a **local, file-backed knowledge compiler** centered in `packages/engine/src/vault.ts`, `ingest.ts`, and `analysis.ts`. Its dominant runtime pattern is:

1. **ingest immutable source material into `raw/` and `state/`**
2. **compile that material into markdown pages plus a typed graph**
3. **query, inspect, review, export, or automate against those persisted artifacts**

The CLI in `packages/cli/src/index.ts` is mostly a command router over engine functions. The viewer in `packages/engine/src/viewer.ts` + `packages/viewer/src/App.tsx` is a local control plane over the same engine APIs. The Obsidian plugin in `packages/obsidian-plugin/src/main.ts` is a shell-out wrapper around the CLI, not an independent runtime.

### Quick Adaptation Assessment

The repo is **customizable but highly centralized**. Most extensions are meant to happen through configuration and provider hooks, not by replacing the core architecture:

| Area | How extensible | Where to modify |
| --- | --- | --- |
| Provider/model behavior | High | `swarmvault.config.json`, `packages/engine/src/providers/registry.ts` |
| Vault semantics/schema | High | `swarmvault.schema.md`, `packages/engine/src/schema.ts`, `config.ts` |
| New runtime workflows | Medium | `packages/cli/src/index.ts`, `packages/engine/src/vault.ts`, `viewer.ts` |
| Core compile graph semantics | Medium/Hard | `packages/engine/src/analysis.ts`, `vault.ts`, code-analysis files |
| UI behavior | Medium | `packages/viewer/src/App.tsx`, components/, viewer server routes |
| Obsidian integration | Medium | `packages/obsidian-plugin/src/commands/*` |

The biggest coupling constraint is that **many features assume the canonical workspace layout and page/frontmatter contracts** defined in `config.ts`, `types.ts`, and `STABILITY.md`.

### Fastest Path to First Successful Run

The shortest realistic user path is the published CLI:

```bash
npm install -g @swarmvaultai/cli
swarmvault quickstart ./some-directory
```

That path works offline with the default heuristic provider because `defaultVaultConfig()` in `packages/engine/src/config.ts` wires all core tasks to the built-in `local` heuristic provider.

### Minimal Manual Setup Path

Without the published package, the repo can still be run directly after building the workspace packages:

```bash
pnpm install
pnpm build
node packages/cli/dist/index.js demo --no-serve
node packages/cli/dist/index.js quickstart ./target --no-serve
```

This works because the CLI is just a built Node entry point (`packages/cli/package.json`) over engine functions, and the engine build copies the built viewer bundle into `packages/engine/dist/viewer` (`packages/engine/package.json`).

### Operational Complexity Snapshot

- **Setup complexity:** moderate for end users, higher for maintainers
- **Runtime model:** single-machine, file-backed, mostly synchronous orchestration with local watchers/schedulers
- **Critical dependencies:** Node `>=24`, local filesystem, `node:sqlite` for retrieval, optional provider credentials/runtimes, optional `ffmpeg`/`yt-dlp`/Neo4j/Ollama
- **Debugging difficulty:** moderate; strong persisted artifacts help, but `vault.ts` is large and central
- **Observability maturity:** good for a local tool; sessions, jobs, doctor, viewer workbench, approval bundles, chat transcripts, context packs, and task ledgers are all first-class artifacts
- **Stability:** core engine/CLI looks mature; some feature families are explicitly experimental (`custom` providers, web-search adapters, local-whisper setup, richer PDF vision path)

## 1. Repository Purpose

### Actual Implemented Purpose

Observed: this repository implements a **local-first LLM Wiki runtime** that turns files, URLs, codebases, transcripts, and recurring sources into:

- persisted raw source copies under `raw/`
- generated markdown pages under `wiki/`
- a typed graph in `state/graph.json`
- a local retrieval index in `state/retrieval/`
- auxiliary review, export, chat, task, context-pack, schedule, and MCP artifacts

This is visible in the workspace path resolver in `packages/engine/src/config.ts`, the engine exports in `packages/engine/src/index.ts`, and the quickstart/scan path in `packages/cli/src/index.ts`.

### Relationship to the Conceptual Description

The user-provided concept describes Karpathy's three-layer LLM Wiki pattern. SwarmVault is a **fully operationalized implementation** of that idea:

- **raw sources** → `raw/` plus `state/manifests/` and `state/extracts/`
- **wiki** → generated and human-authored markdown in `wiki/`
- **schema** → `swarmvault.schema.md`, optionally combined with per-project schemas via `config.projects.*.schemaPath`

It extends the idea substantially with:

- typed graph compilation
- local SQLite retrieval
- review queues and candidate promotion
- persisted chat, task, and context-pack workflows
- watch loops, schedules, git hooks, agent instruction installers, MCP exposure, and graph export/push features

### What Problem the Repo Is Really Solving

The actual problem is **turning ongoing source accumulation into a persistent, inspectable, automation-friendly local knowledge workspace**, instead of re-deriving answers from raw documents each time.

SwarmVault solves four adjacent problems at once:

1. **source normalization and extraction**
2. **knowledge compilation into markdown + graph**
3. **operational workflows for review, query, and agent handoff**
4. **local interfaces for humans and agents**

### Target Use Cases

Observed from README, CLI surface, and test corpus:

- personal/research vaults
- codebase knowledge compilation
- recurring docs/repo source sync
- transcript/media ingestion
- agent handoff and durable task memory
- graph exploration/export/push

### Scope Boundaries

Observed boundaries:

- storage is **local filesystem first**, not hosted SaaS
- retrieval is **local SQLite FTS plus optional embeddings**, not distributed search infrastructure
- coordination is **single-process local orchestration**, not distributed job execution
- richer PDF vision/OCR remains explicitly not wired into the default path (`docs/pdf-extraction.md`)
- the Obsidian plugin is a convenience shell, not a second engine

## 2. High-Level System Model

SwarmVault is best understood as an **orchestration-centric local compiler for durable knowledge work**.

The behavioral center is not the UI and not the provider adapters. It is the engine's ability to **take a normalized source corpus plus a schema, derive analyses, synthesize canonical pages, construct a graph, and then keep the resulting workspace operationally usable**.

Architecturally, the system behaves like:

- a **workspace runtime** with fixed artifact roots (`config.ts`)
- an **incremental compiler** (`vault.ts`, `analysis.ts`, `ingest.ts`)
- a **graph-and-search serving layer** (`viewer.ts`, `search.ts`, `retrieval.ts`)
- an **automation shell** for local agents, watch loops, schedules, MCP, and task/context handoff (`watch.ts`, `schedule.ts`, `mcp.ts`, `memory.ts`, `context-packs.ts`, `agents.ts`)

The dominant concern is **stateful orchestration over persistent artifacts**. The most important question in this repo is usually not "what class owns this?" but "which artifact gets written, invalidated, reviewed, queried, or refreshed next?"

The primary semantic centers are:

1. `packages/engine/src/vault.ts` — compile/query/explore/graph semantics
2. `packages/engine/src/ingest.ts` — input normalization, extraction, manifests
3. `packages/engine/src/analysis.ts` — source analysis and code-aware extraction
4. `packages/engine/src/config.ts` + `schema.ts` — workspace and schema contract
5. `packages/engine/src/viewer.ts` — live control plane over engine operations

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Owning subsystem | Concrete implementation | Limits / notes |
| --- | --- | --- | --- | --- |
| Three-layer LLM Wiki | Implemented | `config.ts`, `vault.ts`, CLI init flow | `raw/`, `wiki/`, `swarmvault.schema.md`; `resolvePaths()` and `initVault()` create/manage them | Strongly enforced by file layout assumptions |
| Incremental knowledge accumulation | Implemented | `vault.ts` | `compile-state.json` dirty checking, source semantic hashes, schema hashes | Centralized in large `compileVault()` path |
| Persistent wiki maintenance | Implemented | `vault.ts`, `pages.ts`, sync helpers | compile rewrites/updates canonical pages and outputs | Review mode can stage instead of applying |
| Query against compiled wiki | Implemented | `vault.ts`, `search.ts`, `retrieval.ts` | `executeQuery()` searches local index, loads page/raw excerpts, calls provider | Heuristic mode is lower quality but offline |
| Persistent query artifacts | Implemented | `vault.ts`, output helpers | `queryVault()` saves outputs in `wiki/outputs/` by default | `--no-save` disables persistence |
| Multi-step exploration | Implemented | `vault.ts`, orchestration roles | `exploreVault()` chains query steps, follow-up generation, saved step pages, optional staged approval | More exploratory than deterministic |
| Source ingest | Implemented | `ingest.ts` | local files, directories, URLs, Slack exports, media, many document types | Some paths depend on helper binaries/providers |
| Code-aware knowledge graph | Implemented | `analysis.ts`, code-analysis files, `vault.ts` | source/module/symbol/rationale nodes and import/call relations | Language support uneven; R explicitly diagnostic-only in skill docs |
| Contradiction detection / evidence classes | Implemented | `analysis.ts`, graph build | claims carry polarity/status; contradiction detection compares claim token overlap | Heuristic contradiction logic is approximate |
| Reviewable compile flow | Implemented | `vault.ts`, review commands, viewer | `compile --approve`, approvals in `state/approvals/`, review accept/reject | Not every post-pass writes through approval staging |
| Candidate staging/promotion | Implemented | candidate logic exported in engine | candidate pages live under `wiki/candidates/`, CLI + viewer actions promote/archive | Auto-promotion is config-gated |
| Managed recurring sources | Implemented | `sources.ts` | registry in `state/sources.json`, reload/review/guide/session flows | More complex than one-off ingest |
| Context packs for agents | Implemented | `context-packs.ts` | graph query + search + budget fit writes JSON + markdown packs | Budgeting is heuristic token estimation |
| Task ledger / agent memory | Implemented | `memory.ts` | JSON state + markdown pages in `wiki/memory/` and `state/memory/tasks/` | Name still shows legacy "memory" compatibility layer |
| Persisted chat over vault | Implemented | `chat.ts` | `state/chat-sessions/` + `wiki/outputs/chat-sessions/` | Reuses query path rather than bespoke dialogue model |
| Local graph viewer | Implemented | `viewer.ts`, `packages/viewer` | HTTP server + React/Cytoscape UI | Local only; same machine assumptions |
| MCP exposure | Implemented | `mcp.ts` | stdio server exposes pages, search, tasks, doctor, retrieval, graph tools | Central engine functions reused |
| Watch / schedule / git hooks | Implemented | `watch.ts`, `schedule.ts`, `hooks.ts` | local loops and git hook integration | No external supervisor or durable queue |
| Neo4j sink | Implemented | `graph-push.ts`, CLI docs/tests | push compiled graph to Neo4j | Optional and config-driven |
| Vision-based PDF understanding | Partial / aspirational | documented extension point | `docs/pdf-extraction.md` says not wired into 1.0 default path | Explicitly experimental / roadmap |

## 4. Architecture and Component Analysis

### 4.1 Engine (`packages/engine`)

This is the actual product runtime. `packages/engine/src/index.ts` exports the public surface, but the meaningful behavior is concentrated in a few files.

#### Workspace and schema infrastructure

- `config.ts` owns workspace defaults, config parsing, artifact path resolution, init profiles, and schema template generation.
- `schema.ts` loads the root schema plus optional per-project schemas, then composes effective schemas used during compile/query.

This layer owns **where state lives** and **which schema applies**. Most higher-level behavior depends on it.

#### Ingest subsystem

- `ingest.ts` is the source normalization and persistence layer.
- It resolves local files, directories, URLs, captured articles, DOI/arXiv/Twitter-like inputs, Slack exports, and many document/media types into prepared inputs and manifests.
- It writes to `raw/`, `state/manifests/`, and `state/extracts/`.

This subsystem owns **source identity**, **stored provenance**, and **text extraction**. It is the repo's ingestion boundary.

#### Analysis and compile subsystem

- `analysis.ts` turns extracted text into source analyses: summary, concepts, entities, claims, questions, tags, rationales, and code metadata.
- `vault.ts` turns manifests + analyses + saved human/system pages into the compiled wiki and graph.

This is the main semantic center. It owns:

- dirty/clean incremental compile semantics
- project scoping
- graph construction
- candidate/review behavior
- query/explore behavior
- benchmark, freshness, and consolidation passes

#### Retrieval and search

- `search.ts` builds and queries a local SQLite FTS index from generated pages and, for source/module pages, augments search text with source excerpts.
- `retrieval.ts` manages freshness metadata, rebuilds, and doctor flow.

This layer is not a general vector database. It is a **local retrievability maintenance layer** over the compiled wiki.

#### Automation and integration surfaces

- `watch.ts` handles inbox/repo watch cycles and pending semantic refresh tracking.
- `schedule.ts` runs local scheduled jobs with simple per-job lock files.
- `mcp.ts` exposes engine capabilities to external agents over stdio.
- `memory.ts`, `chat.ts`, and `context-packs.ts` create durable agent/operator workflow artifacts.
- `agents.ts` writes project- and tool-specific instruction files and hook bundles.

These are not peripheral utilities; they define how SwarmVault expects to live inside broader human/agent workflows.

### 4.2 CLI (`packages/cli`)

`packages/cli/src/index.ts` is a very large Commander-based shell over engine exports.

Architecturally it is thin in logic but broad in surface area:

- one-shot flows: `quickstart`, `demo`, `scan`, `ingest`, `compile`, `query`, `explore`
- operational tooling: `doctor`, `retrieval`, `watch`, `schedule`, `hook`, `migrate`
- knowledge workflows: `source`, `context`, `task`, `chat`, `review`, `candidate`
- integration workflows: `graph`, `export`, `install`, `mcp`

The CLI is important because it defines the **practical usage model**. The repo is intentionally operated through commands, even though the engine could be embedded directly.

### 4.3 Viewer (`packages/viewer` + engine `viewer.ts`)

The viewer is split across:

- `packages/engine/src/viewer.ts` — local HTTP server and API/controller layer
- `packages/viewer/src/App.tsx` — React UI over those APIs

It is more than a graph renderer. It is a **local workbench** exposing:

- graph/search/page inspection
- approvals and candidates
- doctor and retrieval repair
- context-pack creation
- task creation and updates
- source reloads
- lint findings
- memory dashboard
- activity stream over SSE
- browser clipper/bookmarklet capture

This makes the viewer a human control surface over the same file-backed engine, not a separate application backend.

### 4.4 Obsidian plugin (`packages/obsidian-plugin`)

The plugin is intentionally shallow:

- `main.ts` detects workspace root, probes CLI version, shows freshness in the status bar, and registers commands
- `commands/execute.ts` shells out to the CLI and streams results into a run log view
- `commands/query.ts` and `commands/processes.ts` translate Obsidian actions into CLI operations

The semantic boundary is clear: **Obsidian hosts the UX, but SwarmVault CLI stays authoritative**.

### 4.5 Skills and agent-install layer

- `skills/swarmvault/*` is a published skill bundle with command references, examples, and troubleshooting
- `packages/engine/src/agents.ts` installs instruction blocks or skill files into many agent ecosystems

This subsystem operationalizes SwarmVault's assumption that **future agents should consult compiled artifacts before broad repo search**.

## 5. Execution Flow Analysis

### 5.1 Workspace initialization

Observed flow:

1. CLI `init` / `quickstart` / `scan` / many engine functions call `initVault()` or `initWorkspace()`.
2. `initWorkspace()` in `config.ts` creates the canonical directories and writes default config/schema if missing.
3. `initVault()` in `vault.ts` writes seeded pages like `wiki/insights/index.md`, `wiki/projects/index.md`, and `wiki/candidates/index.md`.
4. `initVault()` may install configured agent instructions and optionally create `.obsidian/`.

Runtime effect: initialization is both **filesystem bootstrap** and **workflow bootstrap**.

### 5.2 One-command quickstart / scan

Observed in `runScanCommand()` (`packages/cli/src/index.ts`):

1. initialize workspace
2. if input is a URL, register as a managed source via `addManagedSource()`
3. otherwise ingest directory via `ingestDirectory()`
4. compile immediately
5. emit share artifacts paths
6. either launch graph server or start MCP server

This is the clearest expression of the product philosophy: **first-run should end with a compiled, navigable workspace, not just imported files**.

### 5.3 Ingest flow

Observed in `ingestInputDetailed()` / `ingestDirectory()`:

1. initialize workspace
2. normalize ingest options, including redaction
3. detect repo root when relevant
4. prepare inputs differently for URLs vs files/directories
5. persist prepared inputs into manifests, extracted text, and raw source storage

Important semantics:

- URLs may be captured into markdown-like artifacts before persistence
- `addInput()` tries richer capture paths for arXiv/DOI/tweets/articles, then falls back to generic ingest
- directory ingest has special handling for structured exports like Slack

### 5.4 Compile flow

Observed in `compileVault()`:

1. load config, effective schemas, compile provider, manifests, projects, stored output/insight/memory pages
2. compare against `compile-state.json` and source semantic hashes to detect dirty sources
3. reuse cached analyses for clean sources; analyze dirty sources
4. build a code index and enrich code analyses
5. ensure wiki category directories exist
6. call artifact-sync logic to rewrite pages/graph and maybe stage approvals
7. optionally run configured orchestration roles for a compile post-pass
8. optionally persist decay/freshness updates
9. optionally run consolidation
10. run benchmark and refresh search/retrieval
11. record a session artifact
12. optionally trim to token budget
13. optionally auto-promote candidates

Two especially important execution properties:

- **incrementality is a first-class compile concern**
- **compile is not just page generation**; it also refreshes retrieval, benchmark, freshness, review state, and related operator artifacts

### 5.5 Query flow

Observed in `executeQuery()` + `queryVault()`:

1. ensure graph/search artifacts exist, compiling if necessary
2. resolve optional web gap-fill adapter
3. search local retrieval index
4. load generated page excerpts and raw source excerpts for top hits
5. compose an effective schema from root + relevant project schemas
6. answer heuristically or through the configured query provider
7. persist output page/assets by default, or stage them for review
8. record the query session and optionally attach it to a task ledger entry

So query is **save-first and artifact-oriented**, not ephemeral by default.

### 5.6 Explore flow

Observed in `exploreVault()`:

1. execute repeated query steps up to a step limit
2. accumulate related page/node/source ids and token usage
3. run configured orchestration roles (`research`, `context`, `safety`) on each step when configured
4. save or stage each step page
5. generate follow-up questions and continue
6. synthesize a hub output page summarizing the exploration

This makes explore a **multi-artifact research loop**, not just "query with more tokens".

### 5.7 Watch flow

Observed in `runWatchCycle()` / `watchVault()`:

1. import inbox contents
2. optionally sync tracked repos
3. compile the vault, possibly `codeOnly`
4. merge pending semantic refresh entries
5. mark affected pages stale
6. optionally lint
7. persist session, watch run log, and watch status artifact

The long-running watcher uses `chokidar`, debouncing, adaptive retry/backoff, and reason tracking.

### 5.8 Schedule flow

Observed in `schedule.ts`:

1. resolve configured jobs from `swarmvault.config.json`
2. compute next due run from `cron` or `every`
3. acquire a lock file per job
4. run `compile`, `lint`, `query`, `explore`, or `consolidate`
5. record session and job log
6. persist next-run state

This is a **local polling scheduler**, not a distributed scheduler.

### 5.9 Viewer flow

Observed in `viewer.ts` + `App.tsx`:

1. `graph serve` starts a local HTTP server
2. the React app fetches graph, approvals, candidates, memory tasks, watch status, lint, and doctor state
3. user actions POST back to the same engine-backed endpoints for repair, capture, context packs, tasks, review, candidate promotion, or source reload
4. an SSE event stream triggers UI refresh

So the viewer is effectively a **browser-based engine console**.

### 5.10 Obsidian flow

Observed in plugin code:

1. plugin detects workspace root and CLI availability
2. commands invoke the global CLI binary via `CliRunner`
3. stdout/stderr are streamed into a run log view
4. results are surfaced in notices/status bar, not reimplemented locally

This means Obsidian integration depends operationally on an external CLI install and compatible version.

## 6. State and Persistence Model

SwarmVault is heavily persistent. Most important runtime state is written to disk.

### State ownership by layer

| State | Owner | Persistence |
| --- | --- | --- |
| Raw source copies and assets | ingest | `raw/` |
| Source manifests and extracts | ingest | `state/manifests/`, `state/extracts/` |
| Analyses and compile incrementality | compile | `state/analyses/`, `state/compile-state.json` |
| Compiled graph | compile | `state/graph.json` |
| Retrieval index and manifest | retrieval | `state/retrieval/` |
| Generated pages and outputs | compile/query/explore | `wiki/` |
| Review bundles | compile/review flows | `state/approvals/` |
| Candidate pages | compile/candidate flows | `wiki/candidates/` |
| Sessions, jobs, watch state | operational tooling | `state/sessions/`, `state/jobs.ndjson`, `state/watch/` |
| Context packs | context subsystem | `state/context-packs/`, `wiki/context/` |
| Task ledger | memory subsystem | `state/memory/tasks/`, `wiki/memory/` |
| Chat sessions | chat subsystem | `state/chat-sessions/`, `wiki/outputs/chat-sessions/` |

### Key state semantics

- `raw/` is treated as immutable source truth.
- `wiki/` contains both generated pages and explicitly human-managed areas like `wiki/insights/`.
- generated pages carry strong frontmatter identity and provenance (`page_id`, `source_ids`, `schema_hash`, `source_hashes`, freshness metadata).
- compile invalidation is driven by **schema hashes, source semantic hashes, project config hash, and saved output/insight/memory hashes**.

### Persistence style

Observed persistence style is deliberately simple:

- JSON artifacts for machine state
- markdown for human-facing persistent outputs
- SQLite FTS for retrieval/search only

There is no central database for the overall system model; the filesystem is the canonical store.

## 7. Coordination and Control Semantics

SwarmVault has a **centralized control topology**.

### Execution authority

The engine owns execution authority. Everything else delegates to it:

- CLI delegates directly to engine exports
- viewer endpoints call engine exports
- Obsidian plugin shells out to CLI, which then calls engine
- MCP tools call engine exports

### Coordination style

- mostly **directive**, not reactive
- mostly **synchronous request/operation flows**
- selectively concurrent inside compile/orchestration role execution
- local background loops for watch and schedules

### Concurrency boundaries

- `compileVault()` parallelizes analysis work across dirty and clean sources
- orchestration roles use a configurable parallel limit (`orchestration.maxParallelRoles`)
- watcher and scheduler loops serialize their own cycles and use simple flags/locks to avoid overlap

### Failure propagation

- CLI paths usually throw and surface failures directly
- viewer/MCP convert many failures to structured responses instead of crashing the server
- compile intentionally swallows some post-pass failures (decay/consolidation) so core compile succeeds even when auxiliary maintenance fails

That last behavior is observed, not inferred, from `compileVault()` try/catch blocks around decay and consolidation.

## 8. Configuration and Environment Model

### Configuration hierarchy

Primary configuration sources:

1. `swarmvault.config.json`
2. `swarmvault.schema.md`
3. optional project schemas via `config.projects.*.schemaPath`
4. selected environment variables, especially provider secrets and `SWARMVAULT_OUT`

### Required vs optional

Required for a basic local run:

- Node `>=24`
- workspace config/schema (created by init)

Optional for higher-quality or extended flows:

- API keys or local model endpoints for non-heuristic providers
- embedding provider for semantic retrieval
- audio provider for transcription
- `ffmpeg`, `yt-dlp`, local whisper, Neo4j, Ollama depending on workflows

### Important config domains

- `providers.*` and `tasks.*` route execution to providers
- `profile.*` changes vault defaults and guided behavior
- `projects.*` defines per-project roots and schema overlays
- `orchestration.*` enables role-based post-pass behavior
- `retrieval.*`, `graph.*`, `freshness.*`, `consolidation.*`, `watch.*`, `schedules.*` tune operational behavior

### Output root override

`SWARMVAULT_OUT` is operationally important: config/schema stay at the project root, but generated directories resolve under the override directory (`config.ts`).

## 9. Operational Usage Model

### Canonical user workflow

Observed canonical loop:

1. initialize or quickstart a vault
2. ingest one-off inputs or register recurring managed sources
3. compile
4. inspect via viewer, graph report, or `next`
5. query / explore / review / promote
6. keep the vault fresh with watch, reload, lint, and doctor

### Managed-source workflow

This is an important practical specialization absent from the original concept description:

- `source add` registers local files, directories, public GitHub repos, or crawlable docs hubs
- source state lives in `state/sources.json`
- reload/review/guide/session flows treat sources as durable refreshable inputs

SwarmVault therefore supports both **one-shot ingest** and **ongoing source maintenance**.

### Agent-facing workflow

Observed agent workflow is unusually explicit:

- install instructions into agent ecosystems
- compile/query before broad search
- build context packs for bounded handoff
- track work through task ledgers
- optionally expose the whole vault through MCP

This makes the repo operationally closer to an **agent workbench for curated knowledge** than a pure end-user note app.

### Maintainer workflow

`docs/live-testing.md` shows a strong published-package validation path:

- package preflight
- installed-package smoke tests
- browser smoke
- provider lanes
- corpus tests
- skill publish/inspect

This indicates maintainers care about the **real installed path**, not just workspace tests.

## 10. Extension and Customization Architecture

### Main extension seams

1. **Provider adapters** — built-in plus `custom` module loading in `providers/registry.ts`
2. **Web search adapters** — config-driven, including custom modules
3. **Schema overlays** — root and project schema composition
4. **Orchestration roles** — provider-backed or command-backed role executors
5. **Agent installers** — many target ecosystems supported in `agents.ts`
6. **Graph sinks / exports** — file exports and Neo4j push

### What is actually stable vs aspirational

Observed stable extension seams:

- providers
- project schemas
- schedules
- agent installs
- MCP tools
- graph export/push

Explicitly experimental or less hardened:

- custom provider modules
- custom web-search modules
- orchestration command executors
- local-whisper setup flow
- richer PDF vision path

### Architectural expectation for evolution

Inference grounded in config and skill surfaces: the project expects to grow by **adding new artifact-producing workflows and new integrations around the same workspace contract**, not by replacing the compiler core.

## 11. Key Architectural Decisions and Tradeoffs

### File-backed over service-backed

Decision: persist almost everything as files.

Tradeoff:

- simpler local operation, debuggability, versioning, and agent interoperability
- weaker transactional guarantees and more dependence on path conventions

### Compile-first over query-time-only retrieval

Decision: durable compile artifacts are first-class.

Tradeoff:

- better accumulation, reviewability, graph analytics, and reuse
- more moving parts than a simple RAG stack

### Thin interfaces over a fat engine

Decision: CLI, viewer, MCP, and plugin all reuse engine logic.

Tradeoff:

- consistent semantics across surfaces
- large central files (`vault.ts`, `ingest.ts`, CLI index) accumulate responsibility

### Heuristic offline default

Decision: `defaultVaultConfig()` points all core tasks to the heuristic provider.

Tradeoff:

- zero-key first run and offline usability
- lower-quality synthesis/extraction until the operator configures better providers

### Reviewable mutation paths

Decision: approvals, candidate pages, source guides, and review commands are built in.

Tradeoff:

- better control over compounding artifacts
- more workflow complexity than "just rewrite the wiki"

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### Central-file complexity

Observed: `packages/engine/src/vault.ts` is extremely large and contains multiple concerns: compile orchestration, graph building, query, explore, validation, clustering, candidate behavior, benchmarking, and more. This is the main maintainability risk.

### Surface accretion and compatibility layers

Observed in CLI and docs:

- hidden aliases like `scan`, `clone`, `update`, `cluster-only`, `tree`, `merge-graphs`, `watch-status`
- stable compatibility alias `memory` for `task`
- deprecated `search.*` config retained and migrated to `retrieval.*`

This suggests an actively evolving surface with accumulated compatibility burden.

### Partial error swallowing

Observed:

- compile swallows decay/consolidation failures
- viewer `/api/lint` returns empty findings on failure
- schedule loop isolates per-job crashes and continues

These choices are operationally practical, but they can hide degraded behavior.

### Documentation/version drift

Observed:

- current repo version is `3.14.0`
- `docs/pdf-extraction.md` still frames some decisions as "1.0 default" resolution

That is not necessarily wrong, but it shows historical layering in documentation.

### Not all ambitious features are equally complete

Examples:

- vision-based PDF understanding is explicitly not wired
- some advanced provider and web-search paths are experimental
- Obsidian plugin is still private and depends on external CLI install

### Tested scale is bounded

`SCALE.md` documents tested ceilings and recommends splitting vaults or using Neo4j beyond the large tier. This is a real implementation boundary, not just a generic disclaimer.

## 13. Practical Usage Guide

### Minimal Viable Usage

```bash
npm install -g @swarmvaultai/cli
mkdir my-vault
cd my-vault
swarmvault quickstart ../some-source-dir --no-serve
swarmvault next
swarmvault query "What are the key concepts?"
```

### Operational Assumptions

- single operator or small team
- local filesystem is trustworthy and durable enough
- operator is comfortable with generated artifacts under version control
- higher-quality results require provider setup discipline
- large corpora may require tuning or splitting

### Canonical Workflow

1. `swarmvault next`
2. `swarmvault init` or `quickstart`
3. edit `swarmvault.schema.md`
4. `swarmvault ingest ...` or `swarmvault source add ...`
5. `swarmvault compile`
6. inspect `wiki/graph/report.md`, viewer, and review queues
7. `swarmvault query` / `explore`
8. use `doctor`, `watch`, `schedule`, `source reload`, `candidate`, and `review` as maintenance loop

### Advanced Usage

- managed recurring public GitHub repos or docs hubs
- context-pack generation for bounded agent handoff
- task ledger tracking
- persisted chat sessions
- graph export/push
- MCP server
- agent instruction installation
- scheduled compile/query/explore/lint/consolidate jobs

### Extension Workflow

For new behavior, prefer this order:

1. schema/config change
2. provider config/adapters
3. engine extension
4. CLI command surface
5. viewer/plugin affordance

### Debugging Workflow

Best first inspection points:

- `swarmvault doctor`
- `swarmvault retrieval status` / `doctor`
- `wiki/graph/report.md` and `state/graph.json`
- `state/manifests/`, `state/extracts/`, `state/analyses/`
- `state/sessions/` and `state/jobs.ndjson`
- viewer workbench and activity feed

### Observability

Observed built-in observability:

- doctor report and prioritized recommendations
- session artifacts for operations
- watch status and run logs
- retrieval health/manifest
- saved chat, task, and context artifacts
- review diffs and candidate lists
- live viewer SSE event stream

### Failure Modes

Most likely operational failures:

- missing or stale graph/retrieval artifacts
- provider misconfiguration or unsupported capability
- ingestion helper dependency gaps (`ffmpeg`, `yt-dlp`, whisper runtime, API keys)
- graph shrink guard blocking repo refresh
- oversized vault performance degradation

### Performance Considerations

Grounded in `SCALE.md`:

- retrieval stays local but has practical row ceilings
- compile keeps the graph in memory
- similarity edges and community detection are scaling pressure points
- viewer interactivity has visible-node limits
- audio ingestion cost scales per source

## 14. Project Navigation Guide

### Best reading order

1. `README.md`
2. `packages/cli/src/index.ts`
3. `packages/engine/src/config.ts`
4. `packages/engine/src/ingest.ts`
5. `packages/engine/src/analysis.ts`
6. `packages/engine/src/vault.ts`
7. `packages/engine/src/viewer.ts`
8. `packages/engine/src/sources.ts`, `watch.ts`, `context-packs.ts`, `memory.ts`, `chat.ts`, `mcp.ts`
9. `packages/viewer/src/App.tsx` and `hooks/workspaceStore.ts`
10. `packages/obsidian-plugin/src/main.ts` and `commands/*`
11. representative tests in `packages/engine/test/`

### Highest-value files

| Path | Why it matters |
| --- | --- |
| `packages/engine/src/vault.ts` | core compile/query/explore/graph semantics |
| `packages/engine/src/ingest.ts` | source normalization and persistence |
| `packages/engine/src/analysis.ts` | analysis semantics, heuristics, code/non-code extraction |
| `packages/engine/src/config.ts` | workspace contract and defaults |
| `packages/engine/src/schema.ts` | schema composition and project scoping |
| `packages/engine/src/viewer.ts` | local control-plane API |
| `packages/engine/src/sources.ts` | managed-source lifecycle |
| `packages/engine/src/watch.ts` | automation refresh semantics |
| `packages/engine/src/context-packs.ts` | agent handoff packaging |
| `packages/engine/src/memory.ts` | durable task ledger |
| `packages/cli/src/index.ts` | practical product surface |
| `packages/viewer/src/App.tsx` | what the UI actually exposes |

### Semantic centers

The real behavioral intelligence lives in:

- compile invalidation and artifact sync
- query context assembly
- graph construction from analyses
- managed-source orchestration
- task/context/chat persistence

Boilerplate package scaffolding matters much less than those flows.

## 15. Concise Deep Technical Synthesis

SwarmVault is a **local knowledge-compilation runtime** that turns curated inputs into a durable markdown/wiki/graph workspace and then layers operational tooling around that workspace so humans and agents can keep using and evolving it safely.

Its architecture is dominated by a **central engine with persistent artifact ownership**, surrounded by thin surfaces: CLI, viewer, MCP, Obsidian plugin, and agent installers. The mental model is closer to **"incremental compiler + local workbench + agent handoff system"** than to "notes app" or "RAG chatbot."

What makes it distinctive is that it operationalizes the LLM Wiki idea all the way down into:

- file layout contracts
- incremental invalidation
- graph semantics
- review queues
- local search maintenance
- task/context/chat persistence
- local browser and editor interfaces
- explicit agent integration

It appears optimized for engineers and technically fluent operators who want **durable, inspectable, local knowledge workflows** rather than opaque hosted retrieval.
