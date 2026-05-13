# ONBOARDING

## What this repo actually is

`agentmemory` is an **iii-engine worker that provides persistent memory for coding agents**. The core machine is:

1. ingest session/tool events (`src/hooks/*`, `/agentmemory/observe`, integrations);
2. normalize/compress them into typed observations (`src/functions/observe.ts`, `compress.ts`);
3. index them for recall (`src/functions/search.ts`, `smart-search.ts`, `src/state/hybrid-search.ts`);
4. optionally derive summaries/facts/procedures/graph state (`summarize.ts`, `consolidation-pipeline.ts`, `graph.ts`);
5. expose the result through REST, MCP, CLI, and the viewer.

This is **not** a markdown-first wiki system. The source of truth is iii-backed KV state defined by `src/state/schema.ts` and `src/types.ts`. Obsidian export exists, but only as a derived output (`src/functions/obsidian-export.ts`).

## Semantic centers

### 1. Capture pipeline

- `src/functions/observe.ts` is the main ingestion gateway.
- It validates `HookPayload`, strips secrets, deduplicates, extracts images/tool fields, updates session counters, and writes observations.
- It then replaces raw observations with either LLM-compressed or synthetic compressed observations.

### 2. Retrieval

- `src/functions/search.ts` powers BM25 recall and narrative/full/compact outputs.
- `src/functions/smart-search.ts` exposes the hybrid retrieval surface used heavily by MCP/REST.
- `src/state/hybrid-search.ts` is the main ranking logic: BM25 + optional vector + optional graph, fused with weighted RRF and diversified by session.

### 3. Session evolution

- `src/functions/summarize.ts` generates session summaries on stop.
- `src/functions/remember.ts` stores explicit durable memories with supersession/versioning.
- `src/functions/consolidation-pipeline.ts` derives semantic/procedural layers and decay.
- `src/functions/graph.ts` extracts/query graph entities/edges when enabled.

## Runtime/control model

- `src/index.ts` is the real composition root. Read it first.
- iii-engine is mandatory for the full server. `StateKV` is only a wrapper over iii `state::*` calls (`src/state/kv.ts`).
- REST + event subscribers + MCP endpoints are all registered from the worker.
- Some maintenance is in-process timer-based (`auto-forget`, decay, consolidation), not purely durable cron.

## Operational model

### Normal full-server path

- Start with `npx @agentmemory/agentmemory`.
- CLI bootstrap is in `src/cli.ts`.
- Full service expects iii-engine **v0.11.2**; this pin is intentional and documented in code/changelog/README.
- REST default: `http://localhost:3111`
- streams default: `ws://localhost:3112`
- viewer default: `http://localhost:3113`

### Standalone MCP path

- `npx -y @agentmemory/agentmemory mcp`
- implemented in `src/mcp/standalone.ts`
- proxy-first to running server; local JSON-backed fallback second
- local fallback is **not** feature-complete

## Important defaults and invariants

- No provider key -> `noop` provider. Capture + synthetic BM25 still work; LLM-backed summarize/compress do not.
- `AGENTMEMORY_AUTO_COMPRESS` is **off by default**.
- `AGENTMEMORY_INJECT_CONTEXT` is **off by default**.
- Observation storage is not immutable raw archival: compressed records overwrite raw observation entries.
- Saved `Memory` records must remain retrievable through observation-shaped fallbacks (`memoryToObservation` path).
- Search/index correctness depends on provider/vector dimension consistency; startup can refuse to load a mismatched persisted vector index.

## High-value files

- `src/index.ts` — runtime wiring
- `src/config.ts` — config + feature flags + provider selection
- `src/state/schema.ts` — KV scope map
- `src/types.ts` — actual data model
- `src/functions/observe.ts`
- `src/functions/compress.ts`
- `src/functions/search.ts`
- `src/state/hybrid-search.ts`
- `src/functions/summarize.ts`
- `src/triggers/api.ts`
- `src/mcp/server.ts`
- `src/cli.ts`

## Extension surfaces

When adding/changing a feature, check whether it must be wired through:

1. `src/index.ts` (function registration / counts in startup log)
2. `src/triggers/api.ts` (REST)
3. `src/mcp/tools-registry.ts` (tool definition)
4. `src/mcp/server.ts` (tool handler)
5. tests under `test/`
6. README/plugin metadata if the public surface changed

`AGENTS.md` contains explicit consistency rules for MCP tools, REST endpoints, version bumps, KV scopes, and audit operations.

## Debugging / observability

- CLI: `agentmemory status`, `agentmemory doctor`
- REST: `/agentmemory/health`, `/agentmemory/config/flags`
- Viewer: `:3113`
- iii console: `iii console --port 3114`
- logs: `src/logger.ts` writes structured stderr lines
- health snapshots: `src/health/monitor.ts`

## Maturity / sharp edges

- Core capture + retrieval + viewer + CLI/MCP surfaces are the most mature parts.
- Advanced coordination features (actions, leases, routines, signals, mesh, sketches, sentinels) are implemented and tested, but they are not the main runtime path.
- There is documentation/stat drift: `AGENTS.md` has stale counts, and tool-count claims are stricter in docs than in tests.
- The repo currently depends on the older iii worker model; the engine pin is a real architectural constraint, not a packaging accident.

## Conceptual mapping to “LLM Wiki”

Closest mapping:

- raw sources -> hooks/imported transcripts/filesystem events
- persistent knowledge layer -> KV scopes (`sessions`, `observations`, `memories`, `summaries`, `semantic`, `procedural`, `graph`)
- schema/governance -> `AGENTS.md`, config/env, tool registries, function contracts

Main deviation:

- the primary artifact is **structured runtime memory**, not editable markdown pages
- Obsidian export is an optional bridge, not the core storage model
