---
repo: Lum1104/Understand-Anything
---

# Understand Anything Onboarding Report

## SYNOPSIS

### Implementation Identity

- pnpm monorepo centered on a Claude Code / Copilot-style skill plugin.
- Core behavior lives in `understand-anything-plugin/packages/core/src/*`; the dashboard is a React/Vite graph viewer in `packages/dashboard/src/*`.
- The repo operationalizes “understand a codebase” as: scan → normalize/analyze → persist `.understand-anything/knowledge-graph.json` → visualize / query / diff / onboard from that graph.

### Quick Adaptation Assessment

- Highly configurable at the language/framework layer (`packages/core/src/languages/*`, `plugins/*`) but tightly coupled around the shared `KnowledgeGraph` schema (`packages/core/src/types.ts`).
- Most changes land in one of three places: extraction/analyzers in core, prompt/context builders in `understand-anything-plugin/src/*`, or UI state/layout in `packages/dashboard/src/*`.
- Dashboard semantics are mostly stable; layout and filtering are the most active complexity hotspots.

### Fastest Path to First Successful Run

- Install deps: `pnpm install`
- Build shared core: `pnpm --filter @understand-anything/core build`
- Build the skill package: `pnpm --filter @understand-anything/skill build`
- Run the dashboard locally: `pnpm --filter @understand-anything/dashboard dev`
- For actual use, the repo expects a generated graph at `<project>/.understand-anything/knowledge-graph.json` and a token-gated dashboard fetch path (`packages/dashboard/src/App.tsx`).

### Minimal Manual Setup Path

- No wrapper automation is strictly required for the dashboard code itself.
- Minimal direct path is: build core, start dashboard dev server, and point it at a project graph via `GRAPH_DIR=<project-dir>` with a tokenized URL (`packages/dashboard/src/App.tsx`, `skills/understand-dashboard/SKILL.md`).
- For analysis generation, the repo’s real operational path is through skill commands in `understand-anything-plugin/skills/*`, not a standalone CLI.

### Operational Complexity Snapshot

- Setup: moderate.
- Runtime coordination: high, because graph generation is multi-step and dashboard state is multi-mode.
- Observability: decent for a UI tool (warnings, validation issues, token gate), weak for ingestion internals.
- Stability: good in the core/UI surface; some features are intentionally degraded or fallback-based.

## 1. Repository Purpose

This repo is a plugin+dashboard system for turning a codebase or wiki into an interactive knowledge graph.

What it actually implements:
- skill prompts and helper code for `/understand`, `/understand-chat`, `/understand-diff`, `/understand-explain`, `/understand-onboard`, `/understand-domain`, and `/understand-knowledge` (`understand-anything-plugin/skills/*`, `understand-anything-plugin/src/*`);
- a shared analysis/runtime core for parsing, fingerprinting, search, persistence, schema validation, and language/framework detection (`understand-anything-plugin/packages/core/src/*`);
- an interactive React dashboard that loads and navigates the persisted graph (`understand-anything-plugin/packages/dashboard/src/*`);
- a marketing/homepage shell (`homepage/*`).

The conceptual promise in the README is accurate, but the implementation is more specific: it is graph-generation plus graph-consumption, not a generic autonomous agent runtime.

## 2. High-Level System Model

This is an orchestration-centric graph system.

Primary semantic center:
- a shared `KnowledgeGraph` model (`packages/core/src/types.ts`) with nodes, edges, layers, and tours;
- graph validation/sanitization (`packages/core/src/schema.ts`);
- graph persistence under `.understand-anything/` (`packages/core/src/persistence/index.ts`);
- dashboard state derived from that graph (`packages/dashboard/src/store.ts`).

Runtime shape:
- analysis pipelines create/update graph artifacts;
- the dashboard reads those artifacts and derives UI state;
- skills act as LLM-facing adapters that turn the graph into prompts/markdown.

The architecture is not request/response server-centric; it is artifact-centric. The persisted graph is the contract.

## 3. Conceptual Capability Mapping

| Capability | Status | Where implemented | Notes |
|---|---|---|---|
| Codebase graph generation | Implemented | `packages/core/src/analyzer/*`, `plugins/*`, `skills/understand/*` | Graph creation is rooted in extracted file/function/class/import data and layer/tour assembly. |
| Multi-language parsing | Implemented, uneven | `packages/core/src/languages/*`, `plugins/tree-sitter-plugin.ts` | Strongest for TS/JS and supported Tree-sitter grammars; other languages may fall back to lighter/non-structural handling. |
| Search | Implemented | `packages/core/src/search.ts`, dashboard store/search bar | Fuzzy search is real; “semantic” mode is currently a label over the same engine in `store.ts`. |
| Diff impact analysis | Implemented | `src/diff-analyzer.ts` | Maps changed files → changed nodes → 1-hop affected nodes/layers. |
| Onboarding guide generation | Implemented | `src/onboard-builder.ts` | Uses layers, concepts, tour, and file map from the graph. |
| Deep file/component explanation | Implemented | `src/explain-builder.ts` | Path-based, with child/connected node expansion and layer context. |
| Domain graph | Implemented | `skills/understand-domain/*`, dashboard domain view | Separate graph artifact: `.understand-anything/domain-graph.json`. |
| Knowledge/wiki graph | Implemented | `skills/understand-knowledge/*`, dashboard knowledge view | Uses `kind: "knowledge"` to switch the dashboard layout mode. |
| Incremental update/staleness | Implemented | `packages/core/src/staleness.ts`, `fingerprint.ts`, `change-classifier.ts` | Structural fingerprints drive update decisions; conservative fallbacks exist. |
| Semantic search / embeddings | Not really implemented | `packages/core/src/embedding-search.ts`, `store.ts` | Present as a future-facing abstraction; dashboard currently keeps semantic mode on fuzzy search. |

## 4. Architecture and Component Analysis

### Monorepo / workspace layer
- Root `package.json`, `pnpm-workspace.yaml`.
- Contains three meaningful products: core library, skill package, dashboard, plus `homepage/`.
- CI builds/tests only core + skill (`.github/workflows/ci.yml`), while homepage deploys separately (`deploy-homepage.yml`).

### Core package (`understand-anything-plugin/packages/core/src`)
Owns the system’s durable domain model and low-level mechanics.

Key files:
- `types.ts` — canonical graph/node/edge/layer/tour/persistence types.
- `schema.ts` — validation, auto-fix, sanitization, alias normalization.
- `persistence/index.ts` — `.understand-anything` read/write for graph, meta, config, fingerprints, domain graph.
- `search.ts` — Fuse-based fuzzy search.
- `languages/*` — registry/config layer for language and framework detection.
- `plugins/tree-sitter-plugin.ts` — Tree-sitter-backed structural analysis.
- `plugins/registry.ts`, `plugins/discovery.ts` — analyzer plugin registry and config.
- `fingerprint.ts`, `staleness.ts`, `change-classifier.ts` — incremental analysis/update logic.
- `ignore-filter.ts` — ignore handling with `.understandignore`.

This package is the behavioral backbone. The dashboard depends on it for types, schema validation, and search; the skill package depends on it for graph understanding.

### Skill package (`understand-anything-plugin/src` + `skills/*`)
Owns prompt composition and skill-specific operational instructions.

Key files:
- `context-builder.ts` — query → relevant subgraph → markdown context.
- `diff-analyzer.ts` — changed files → impact analysis markdown.
- `explain-builder.ts` — path/function → detailed explanation context.
- `onboard-builder.ts` — graph → onboarding guide.
- `understand-chat.ts` — chat prompt composition.
- `skills/understand/*` and sibling SKILL.md files — actual platform instructions, batch/merge scripts, worktree redirect logic, dashboard launch steps.

These are not just docs; they define the operational protocol for each command.

### Dashboard package (`understand-anything-plugin/packages/dashboard/src`)
Owns UI state, view selection, filtering, layout, and graph interaction.

Key files:
- `App.tsx` — loads graph artifacts, validates them, wires token handling, selects structural/domain/knowledge views.
- `store.ts` — Zustand store for graph, selection, search, diff overlay, tours, filters, layout caches, and view state.
- `components/GraphView.tsx` — structural graph rendering and stable layout.
- `components/DomainGraphView.tsx` — domain flow rendering.
- `components/KnowledgeGraphView.tsx` — force-directed knowledge graph rendering.
- `utils/layout.ts`, `utils/elk-layout.ts`, `utils/containers.ts`, `utils/edgeAggregation.ts`, `utils/louvain.ts` — layout/aggregation heuristics.

This package contains the richest runtime coordination: multiple graph modes, delayed layout, token gating, and state resets when view/layer focus changes.

### Homepage (`homepage/*`)
- Astro marketing site, not part of the analysis runtime.
- Builds separately and deploys demo assets from the dashboard build (`.github/workflows/deploy-homepage.yml`).

## 5. Execution Flow Analysis

### Install / integration flow
1. `install.sh` / `install.ps1` clone the repo and create per-platform skill symlinks/junctions.
2. They link the skill directory into agent-specific skill locations and create a universal plugin root link.
3. This makes commands like `/understand` and `/understand-dashboard` available inside supported AI tools.

### Graph generation flow
1. A skill script under `skills/understand/*` starts from the current project root.
2. It uses git-aware worktree redirection in the skill’s Phase 0 (tested in `src/__tests__/worktree-redirect.test.mjs`).
3. Deterministic scanning plus analysis batches produce raw graph material.
4. Merge/validation yields `.understand-anything/knowledge-graph.json` plus `meta.json`; optional artifacts include `domain-graph.json`, `diff-overlay.json`, `fingerprints.json`, `config.json`.

### Dashboard startup flow
1. `packages/dashboard/src/App.tsx` resolves a token from `?token=` or `sessionStorage`.
2. It fetches `knowledge-graph.json`, `domain-graph.json`, `meta.json`, and optional `diff-overlay.json`.
3. Graphs are validated via `packages/core/src/schema.ts`.
4. The store (`store.ts`) indexes nodes/layers, initializes search, and resets layout state.
5. The appropriate view renders: structural, domain, or knowledge.

### Interaction flow
- Search uses `SearchEngine` with fuzzy matching over `name`, `tags`, `summary`, and `languageNotes`.
- Selecting nodes updates navigation history and may enter layer-detail mode.
- Tours drive highlight sets and fit-view behavior.
- Layout issues and graph validation issues are merged into one warning surface.

## 6. State and Persistence Model

State is mostly file-backed, not server-backed.

Persistent artifacts:
- `.understand-anything/knowledge-graph.json`
- `.understand-anything/domain-graph.json`
- `.understand-anything/meta.json`
- `.understand-anything/fingerprints.json`
- `.understand-anything/config.json`
- `.understand-anything/diff-overlay.json`
- `.understand-anything/.understandignore`

Important semantics:
- `persistence/index.ts` sanitizes absolute file paths before saving graph JSON.
- `loadGraph()` and `loadDomainGraph()` validate by default.
- Fingerprint and staleness logic are conservative: if structural analysis is missing, changes are treated as structural.
- Dashboard session state is ephemeral except for the access token stored in `sessionStorage`.

## 7. Coordination and Control Semantics

- Control is centralized in the persisted graph and in the dashboard store.
- The skill layer orchestrates agents/prompts, but the graph files are the real exchange boundary.
- The dashboard is directive: it derives all view state from loaded artifacts, then mutates only UI-local state.
- The plugin registry (`plugins/registry.ts`) routes analysis by language; the language registry routes by filename/extension.
- `TreeSitterPlugin.init()` is mandatory before analysis and gracefully skips unavailable grammars.
- Layout coordination is intentionally defensive: ELK input repair (`utils/elk-layout.ts`) auto-fixes missing dimensions, duplicate IDs, orphan edges, and cycles.

## 8. Configuration and Environment Model

Required/important:
- Node 22+ is assumed by `homepage/package.json` and CI.
- pnpm workspace is the package manager contract.
- Dashboard token gate expects `?token=` unless demo mode is enabled.
- Demo dashboard build uses env vars in `deploy-homepage.yml`: `VITE_GRAPH_URL`, `VITE_DOMAIN_GRAPH_URL`, `VITE_META_URL`.

Optional/advanced:
- `.understandignore` for scan filtering.
- `config.json` for `autoUpdate`.
- `sessionStorage` for token persistence.
- `GRAPH_DIR` and `VITE_*` envs for dashboard data source configuration.

## 9. Operational Usage Model

Canonical loop:
1. Install the skill/plugin.
2. Run `/understand` on a project.
3. Open `/understand-dashboard`.
4. Use search, layer drill-down, tours, diff overlay, and deep dives.
5. Re-run or incrementally update after changes.

Alternative workflows:
- `/understand-domain` for domain-flow graphs.
- `/understand-knowledge` for wiki-style knowledge bases.
- `/understand-diff` for impact analysis on uncommitted or PR changes.
- `/understand-explain <path>` for focused code explanations.

This is meant for repeated use on the same repo, not one-off offline analysis.

## 10. Extension and Customization Architecture

Stable extension seams:
- `AnalyzerPlugin` interface (`types.ts`).
- `PluginRegistry` and `LanguageRegistry`.
- `FrameworkRegistry` for manifest-based framework detection.
- Built-in language configs and extractors.
- Parser registry in `plugins/parsers/*`.
- Dashboard theming in `packages/dashboard/src/themes/*`.

Practical extension points:
- add a new language config and extractor;
- add a framework config and manifest detector;
- add a new skill prompt builder;
- add new node/edge types only if schema and dashboard mappings are updated together.

## 11. Key Architectural Decisions and Tradeoffs

- Artifact-first design: the graph file is the canonical shared state.
- Validation is strict enough to protect the dashboard, but tolerant enough to auto-correct and keep rendering.
- Search is lightweight and local rather than embedding-based.
- Layout is defensive and migration-aware: ELK is preferred, dagre remains as fallback/deprecated compatibility.
- Worktree redirection is explicitly baked into skill scripts to avoid losing generated artifacts in ephemeral checkouts.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

- `searchMode === "semantic"` is currently a UI affordance over the same fuzzy engine (`store.ts`), so semantic search is aspirational.
- `GraphBuilder.build()` leaves `frameworks` and `description` empty, so higher-level metadata is not yet fully populated from core analysis.
- `TreeSitterPlugin` is described as general, but extractor support is still the real limiter.
- CI covers core + skill, but not the dashboard package directly (`.github/workflows/ci.yml`).
- Layout code shows a migration in progress: ELK is primary, dagre remains for fallback.

## 13. Practical Usage Guide

### Minimal Viable Usage
- `pnpm install`
- `pnpm --filter @understand-anything/core build`
- `pnpm --filter @understand-anything/skill build`
- generate a graph via the `/understand` skill in a supported agent
- open the dashboard with `/understand-dashboard`

### Operational Assumptions
- users are comfortable with AI-agent plugins and shell-based setup;
- graph artifacts live inside the analyzed repo;
- the dashboard is typically launched against a local project directory;
- graph updates are expected to be repeated, incremental, and git-aware.

### Canonical Workflow
- analyze → inspect graph → ask targeted questions → diff changes → regenerate onboarding docs.

### Advanced Usage
- `--auto-update` / incremental update flows;
- domain graphs and knowledge-base graphs;
- commit the graph artifacts for team onboarding.

### Extension Workflow
- add/modify extractors and graph schema together;
- update dashboard node-type/category mappings when adding new node kinds;
- keep SKILL.md instructions and tests aligned.

### Debugging Workflow
- check `.understand-anything/meta.json` and validation warnings in the dashboard;
- inspect `graphIssues` / `layoutIssues` surfaced in `WarningBanner`;
- verify `knowledge-graph.json` against `packages/core/src/schema.ts`;
- for install issues, review `install.sh` / `install.ps1`.

### Observability
- UI warnings, console warnings/errors, token gate messages.
- No dedicated telemetry/metrics layer.

### Failure Modes
- missing graph → dashboard cannot start usefully;
- invalid graph → validation fails or items are dropped/auto-corrected;
- missing token → token gate blocks dashboard access;
- unavailable Tree-sitter grammars → graceful degradation, not hard failure.

### Performance Considerations
- Layout and graph filtering are the main expensive paths.
- Search is local and indexed over graph nodes.
- Incremental update logic exists to avoid full re-analysis where possible.

## 14. Project Navigation Guide

Best reading order:
1. `package.json`, `pnpm-workspace.yaml`
2. `understand-anything-plugin/packages/core/src/types.ts`
3. `understand-anything-plugin/packages/core/src/schema.ts`
4. `understand-anything-plugin/packages/core/src/persistence/index.ts`
5. `understand-anything-plugin/packages/core/src/index.ts`
6. `understand-anything-plugin/src/context-builder.ts`, `diff-analyzer.ts`, `explain-builder.ts`, `onboard-builder.ts`
7. `understand-anything-plugin/packages/dashboard/src/store.ts`
8. `understand-anything-plugin/packages/dashboard/src/App.tsx`
9. `understand-anything-plugin/packages/dashboard/src/components/GraphView.tsx`
10. `understand-anything-plugin/skills/*/SKILL.md`

Highest-value semantic centers:
- `packages/core/src/*`
- `packages/dashboard/src/store.ts`
- `packages/dashboard/src/App.tsx`
- `skills/understand/*`

## 15. Concise Deep Technical Synthesis

Understand Anything is an artifact-driven codebase understanding platform: a skill/plugin layer generates and updates a validated knowledge graph, and a React dashboard consumes that graph to provide search, tours, diff impact, deep dives, and domain/knowledge views.

The distinctive design choice is that the graph is the integration boundary. Parsing, fingerprinting, layout, and prompt generation all feed the same schema, which makes the system extensible but also means schema changes ripple everywhere.

