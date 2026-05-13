# SwarmVault Onboarding

## What this repo actually is

SwarmVault is a **local, file-backed knowledge compiler** that operationalizes the LLM Wiki pattern. The runtime takes sources in `raw/`, compiles them into markdown pages in `wiki/`, builds a typed graph in `state/graph.json`, maintains a local retrieval index in `state/retrieval/`, and then exposes those artifacts through CLI, viewer, MCP, agent-install, watch, schedule, chat, context-pack, and task-ledger workflows.

The repo is **engine-first**:

- `packages/engine` owns real behavior
- `packages/cli` is the main operator surface over engine exports
- `packages/viewer` + `packages/engine/src/viewer.ts` is the local browser workbench
- `packages/obsidian-plugin` shells out to the CLI rather than reimplementing engine logic

## Semantic centers

Read these first:

1. `packages/engine/src/config.ts` — workspace contract, defaults, `SWARMVAULT_OUT`, init profiles, path resolution
2. `packages/engine/src/schema.ts` — root + per-project schema composition
3. `packages/engine/src/ingest.ts` — source normalization, extraction, manifests, raw storage
4. `packages/engine/src/analysis.ts` — concept/entity/claim/rationale/code analysis semantics
5. `packages/engine/src/vault.ts` — compile, query, explore, graph build, candidate/review, benchmark, clustering
6. `packages/engine/src/viewer.ts` — local HTTP API for graph/search/page/review/task/doctor/capture flows
7. `packages/engine/src/sources.ts`, `watch.ts`, `context-packs.ts`, `memory.ts`, `chat.ts`, `mcp.ts`
8. `packages/cli/src/index.ts` — actual operational surface

## Dominant runtime model

The system is organized around **persistent artifact ownership**, not ephemeral chat.

- `raw/` = immutable source truth
- `wiki/` = generated + human-authored markdown
- `state/` = machine state, graph, retrieval, analyses, approvals, sessions, watch data, task/context/chat artifacts
- `swarmvault.schema.md` = vault operating contract

Compile is the central act:

1. load manifests + schema(s) + provider
2. detect dirty sources via `state/compile-state.json`
3. analyze dirty sources, reuse cached clean analyses
4. rebuild wiki pages + graph
5. refresh retrieval/search
6. optionally stage approvals, run post-pass roles, decay, consolidation, benchmark, and auto-promotion

## Core execution paths

### Quickstart / scan

`packages/cli/src/index.ts::runScanCommand()`

- init workspace
- ingest directory **or** register managed URL source
- compile immediately
- optionally launch graph server or MCP

### Ingest

`packages/engine/src/ingest.ts`

- persists manifests and extracted text under `state/`
- copies/captures source material into `raw/`
- supports many file/document/media/url forms
- one-off ingest and managed recurring source workflows are separate concepts

### Query

`packages/engine/src/vault.ts::executeQuery()` / `queryVault()`

- ensure graph + retrieval exist
- local search via SQLite FTS
- load wiki excerpts + raw source excerpts
- optionally add web gap-fill evidence
- answer with heuristic or configured provider
- save output page by default into `wiki/outputs/`

### Explore

`packages/engine/src/vault.ts::exploreVault()`

- repeated query loop with follow-up question generation
- optional orchestration roles (`research`, `context`, `safety`)
- saves step artifacts and a hub artifact

### Watch

`packages/engine/src/watch.ts`

- imports inbox
- optionally syncs tracked repos
- compiles, marks stale pages, updates watch status/session logs
- `--code-only` is a fast-path refresh mode

## Important invariants

- **Do not treat `raw/` as mutable working state.**
- **Do not break generated page frontmatter contracts** (`page_id`, `source_ids`, `node_ids`, `schema_hash`, `source_hashes`, freshness fields).
- **Schema changes are operational changes.** Compile/query behavior depends on `swarmvault.schema.md` and optional project schemas.
- **Most interfaces are thin wrappers over engine behavior.** Fix semantics in engine first, then surface them in CLI/viewer/plugin.
- **Managed sources and one-off ingest are different workflows.** `source add` is registry-backed; `ingest` is not.
- **The viewer is a control plane, not just a renderer.** It can repair retrieval, create context packs/tasks, review approvals, reload sources, and capture clips.

## Key state locations

- `state/manifests/` — source identities and metadata
- `state/extracts/` — extracted text + sidecars
- `state/analyses/` — cached source analyses
- `state/compile-state.json` — incremental compile invalidation state
- `state/graph.json` — compiled graph
- `state/retrieval/` — SQLite FTS index + retrieval manifest
- `state/approvals/` — review bundles
- `state/sources.json` + `state/sources/` — managed source registry and sync state
- `state/watch/` + `state/jobs.ndjson` — watch health and history
- `state/sessions/` — operation/session artifacts
- `state/context-packs/` — saved context packs
- `state/memory/tasks/` — task ledger JSON
- `state/chat-sessions/` — persisted chat session state

Human-facing persisted outputs:

- `wiki/graph/` — report, share card, share kit
- `wiki/outputs/` — saved query/explore/source-guide/session outputs
- `wiki/context/` — markdown context-pack companions
- `wiki/memory/` — task ledger pages
- `wiki/insights/` — human-authored / review-oriented note layer
- `wiki/candidates/` — staged candidate concept/entity pages

## Extension points that actually matter

- provider routing: `packages/engine/src/providers/registry.ts`
- provider config/task mapping: `swarmvault.config.json`
- schema overlays: `packages/engine/src/schema.ts`
- orchestration roles: `config.orchestration.*`, `packages/engine/src/orchestration.ts`
- web search adapters: `webSearch.*`
- agent instruction install targets: `packages/engine/src/agents.ts`
- viewer actions/API: `packages/engine/src/viewer.ts`

## Operational commands worth remembering

- `swarmvault next` — safest read-only orientation
- `swarmvault quickstart <input>` — init + ingest + compile + viewer
- `swarmvault source add <input>` — recurring source workflow
- `swarmvault compile`
- `swarmvault query "<question>"`
- `swarmvault explore "<question>" --steps 3`
- `swarmvault doctor` / `swarmvault retrieval doctor --repair`
- `swarmvault watch --repo --once --code-only`
- `swarmvault graph serve`
- `swarmvault context build "<goal>" --target <path-or-node> --budget <tokens>`
- `swarmvault task start "<goal>" --target <path-or-node>`
- `swarmvault mcp`

## Debugging / archaeology notes

- The biggest complexity sink is `packages/engine/src/vault.ts`.
- The CLI surface includes many hidden compatibility aliases (`scan`, `clone`, `update`, `tree`, `merge-graphs`, `watch-status`, `memory`), so check whether a behavior is current surface or compatibility baggage.
- Some post-pass compile work intentionally fails soft (decay/consolidation) so a successful compile does not guarantee every auxiliary maintenance pass succeeded.
- `docs/pdf-extraction.md` explicitly says richer PDF vision/OCR is **not wired into the default path**.
- `STABILITY.md` is useful for identifying what the repo considers stable vs experimental.
- `SCALE.md` documents real tested limits; large-vault behavior is not hand-wavy.

## Maturity assessment

Core engine + CLI behavior looks mature and strongly tested. `packages/engine/test/` covers ingest, compile, retrieval, managed sources, graph export/push, watch roots, memory, migration, provider registry, and more. Viewer and Obsidian plugin have narrower but real tests. The repo is feature-rich and operationally serious, but it also shows surface accretion and historical compatibility layers.
