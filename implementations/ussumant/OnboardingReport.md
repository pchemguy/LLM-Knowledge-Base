---
repo: ussumant/llm-wiki-compiler
---

# LLM Wiki Compiler Onboarding Report

## SYNOPSIS

### Implementation Identity

**Observed:** this repository is primarily a **plugin/specification pack for host LLMs**, not a standalone compiler application. The main behavioral logic lives in markdown workflow specs under `plugin/commands/` and `plugin/skills/wiki-compiler/SKILL.md`. The only substantial executable runtime in the repo is the knowledge-graph viewer in `plugin/visualize/server.js`, plus Bash session-start hooks in `plugin/hooks/`.

**Dominant architectural identity:** centrally orchestrated, **prompt-defined workflow runtime**. Claude Code or Codex acts as the execution engine; the repo supplies command contracts, compilation phases, file templates, capture adapters, and session-start context rules.

**Primary semantic center:** `plugin/skills/wiki-compiler/SKILL.md`. That file defines the end-to-end compile semantics: scan sources, discover topics, synthesize topic articles, synthesize cross-topic concepts, evolve `schema.md`, regenerate `INDEX.md`, update `.compile-state.json`/`log.md`, and optionally generate `CONTEXT.md` in codebase mode.

**Maturity signal:** mixed. The conceptual workflow is well-specified and broad in scope, but enforcement is soft because most behavior depends on LLM compliance rather than deterministic code. The visualizer and hook path are concrete; compile/search/query/lint/ingest are operationally real only through the host agent following markdown instructions.

### Quick Adaptation Assessment

- **Easy to customize at the prompt/spec layer:** article sections, capture shapes, schema rules, wiki modes, and onboarding prompts are all plain markdown or JSON templates.
- **Harder to harden operationally:** correctness depends on the host agent following instructions consistently; few invariants are programmatically enforced.
- **Major coupling points:**
  - `.wiki-compiler.json` is the shared control file across commands, hooks, and skill behavior.
  - generated markdown shape is relied on by downstream tooling, especially `plugin/visualize/server.js`.
  - Claude/Codex-specific packaging and hook semantics are built into `plugin/.claude-plugin/`, `plugin/.codex-plugin/`, and `plugin/hooks/`.

### Fastest Path to First Successful Run

For intended use:

1. Install the plugin into Claude or Codex using the manifests under `plugin/.claude-plugin/`, `plugin/.codex-plugin/`, and marketplace metadata in `.claude-plugin/marketplace.json` / `.agents/plugins/marketplace.json`.
2. In a target folder, run `/wiki-init` or `/wiki-init --codebase`.
3. Run `/wiki-compile`.
4. Optionally run `/wiki-visualize`.

**Operational reality:** if you try this repository itself as the target folder, auto-detection is likely to pick **knowledge mode** because the repo is markdown-heavy and has no `package.json`, `pyproject.toml`, or similar manifest. Force `--codebase` if you want a wiki about the repository’s architecture rather than about its markdown docs/specs.

### Minimal Manual Setup Path

There is **no meaningful standalone manual compiler path** in this repo.

- Compile/init/ingest/query/lint are not implemented as local binaries; they are markdown instruction sets intended to be executed by Claude/Codex.
- The only fully local executable subsystem is the visualizer:
  - `node plugin/visualize/server.js --wiki-dir path/to/wiki`
  - then open `http://localhost:3848`

So the repository can be exercised manually only for visualization and hook behavior. The “compiler” itself exists as a protocol for an agent, not as a deterministic CLI.

### Operational Complexity Snapshot

- **Setup:** low-medium if you already use Claude/Codex plugins; high if you expect a normal CLI/package install workflow.
- **Runtime fragility:** medium-high because instructions, not code, enforce most semantics.
- **Infrastructure:** intentionally minimal; no DB, no embedding index, no external service required for the core model.
- **Observability:** generated markdown, `.compile-state.json`, `log.md`, and the visual graph are the main observability surfaces.
- **Cross-platform reality:** mixed. `plugin/visualize/server.js` is portable Node, but hooks and several command examples assume Bash and Unix tools.

## 1. Repository Purpose

**Observed purpose:** this repo packages a reusable Claude/Codex plugin that compiles either markdown corpora or codebase knowledge into a persistent markdown wiki that agents can read instead of repeatedly re-reading raw sources.

It is **not** a wiki instance and **not** a traditional compiler library. It is meta-tooling for creating wiki instances elsewhere.

### Relationship to the conceptual “LLM Wiki” idea

The conceptual pattern describes three layers: immutable raw sources, a maintained markdown wiki, and a schema/instruction layer. This repository implements that pattern almost literally:

| Conceptual capability | Concrete mechanism in repo | Status |
| --- | --- | --- |
| Immutable source layer | `plugin/skills/wiki-compiler/SKILL.md` explicitly forbids modifying files outside the configured output directory | Implemented as instruction |
| Persistent wiki artifact | generated `wiki/INDEX.md`, `wiki/topics/*.md`, `wiki/concepts/*.md`, `wiki/schema.md`, `wiki/log.md`, optional `wiki/CONTEXT.md` | Implemented as target artifact model |
| Schema-guided maintenance | `plugin/templates/schema-template.md` and schema update rules in `SKILL.md` | Implemented |
| Incremental ingest/compile/query/lint | command specs under `plugin/commands/` | Implemented as agent workflows |
| Session-time wiki reuse | `plugin/hooks/session-start` and `plugin/hooks/wiki-session-context` | Concretely implemented |
| Source capture into raw layer | `plugin/commands/wiki-capture.md`, `fetch-bookmarks.md`, adapter specs under `plugin/skills/wiki-compiler/adapters/` | Implemented, partially adapter-complete |
| Knowledge graph browsing | `plugin/visualize/server.js` + `plugin/visualize/index.html` | Concretely implemented |

### What problem the repo is really solving

The repo tries to reduce repeated context loading by converting many raw files into a smaller set of synthesized topic pages with explicit source backlinks and coverage markers. For codebases, it extends this idea from “knowledge notes” into “operational architecture briefings.”

### Target use cases

- personal/project knowledge bases built from markdown
- codebase onboarding wikis derived from READMEs, ADRs, config, API contracts, and optionally key source files
- cross-project “global wiki” capture of bookmarks and interesting links
- agent-first workflows where the LLM updates the wiki and humans browse it in Obsidian or the built-in graph

### Scope boundaries

**Observed non-goals / absences:**

- no parser library or compiler binary
- no embedding or vector search backend
- no programmatic topic classifier
- no local scheduler/service except the visualization server
- no built-in test suite for workflow compliance

## 2. High-Level System Model

This system is best understood as a **host-agent-controlled compilation protocol** with markdown as both implementation medium and output medium.

- **Control plane:** command specs in `plugin/commands/`
- **Compilation engine:** host LLM executing `plugin/skills/wiki-compiler/SKILL.md`
- **State/config plane:** `.wiki-compiler.json`, generated `schema.md`, generated `.compile-state.json`
- **Output plane:** topic/concept/index/context markdown files under the configured output directory
- **Runtime augmentation plane:** `plugin/hooks/` injects session-start guidance so the agent prefers the compiled wiki
- **Visualization plane:** `plugin/visualize/` parses compiled markdown into an interactive graph

The architecture is therefore **orchestration-centric and state-informed**, but not code-heavy. The main behavioral intelligence lives in the semantic rules for:

- how topic boundaries are inferred
- how codebase mode differs from knowledge mode
- when concepts are created
- how source recency affects article wording
- how schema changes are treated as durable structure
- how raw captures are normalized before they join the compilation pipeline

**Inference:** the author prioritizes flexibility, host portability, and zero infrastructure over deterministic enforcement. The repository behaves more like a portable operating manual for an agent than like a normal software package.

## 3. Conceptual Capability Mapping

| Capability | Owner | Implementation location | Execution semantics | Limits / tradeoffs |
| --- | --- | --- | --- | --- |
| Wiki initialization | command spec | `plugin/commands/wiki-init.md` | interactive setup; auto-detects knowledge vs codebase mode; writes `.wiki-compiler.json`; creates initial output files | depends on agent obeying “one question at a time”; only codebase fast-path auto-compiles |
| Incremental compilation | core skill + command wrapper | `plugin/commands/wiki-compile.md`, `plugin/skills/wiki-compiler/SKILL.md` | reads config/state/schema; scans changed files; compiles changed topics; regenerates shared artifacts | state model is thin; incrementality is advisory rather than strongly verifiable |
| Topic article synthesis | core skill | `SKILL.md` Phase 3; `plugin/templates/article-template.md`; `plugin/templates/codebase-article-template.md` | read all sources for each topic and synthesize sections with coverage tags and source links | section quality depends on host LLM; format is soft-schema |
| Concept synthesis | core skill | `SKILL.md` Phase 3.5 | discover recurring cross-topic patterns spanning 3+ topics | deliberately interpretive; easy to drift if host agent is inconsistent |
| Schema evolution | core skill + template | `SKILL.md` Phase 3.7; `plugin/templates/schema-template.md` | schema becomes human-editable source of structural truth; new topics/concepts appended with evolution log | removal requires human approval; enforcement is social/instructional |
| Query answering from wiki | command spec | `plugin/commands/wiki-query.md` | read `INDEX.md`, pick 1-3 topic pages, answer with section citations, optionally file synthesis back into wiki | no deterministic retrieval engine beyond index/topic reading |
| Keyword search | command spec | `plugin/commands/wiki-search.md` | tiered index scan then grep-like full-article search | semantic search is explicitly deferred to future external tools |
| Wiki linting | command spec | `plugin/commands/wiki-lint.md` | compare state/index/schema/articles for stale pages, orphans, low coverage, contradictions, drift | contradiction detection is vague/spec-driven rather than algorithmically defined |
| Single-source ingest | command spec | `plugin/commands/wiki-ingest.md` | user-guided summary → classification → topic update → index/schema/state/log update | interactive; log file naming conflicts with main compile path (`compile-log.md` vs `log.md`) |
| Link capture | command spec + adapters | `plugin/commands/wiki-capture.md`, `plugin/skills/wiki-compiler/adapters/capture-*.md` | normalize external link to markdown source under `wiki-sources/captures/`, then optionally connect it into wiki | capture quality depends on external extraction availability |
| External bookmark sync | adapter dispatcher | `plugin/commands/fetch-bookmarks.md`, `plugin/skills/wiki-compiler/adapters/x.md` | delegate per-source setup/sync/export/config wiring | only X/Twitter adapter ships; others are aspirational |
| Session-start wiki-first behavior | Bash hooks | `plugin/hooks/hooks.json`, `plugin/hooks/session-start`, `plugin/hooks/wiki-session-context` | locate nearest `.wiki-compiler.json`, inspect compiled wiki state, emit context telling the agent to use wiki first | Claude hook integration is concrete; Codex support is advisory only |
| Visualization | Node server + HTML app | `plugin/visualize/server.js`, `plugin/visualize/index.html` | parse compiled markdown into graph API; browser renders nodes, edges, article side panel | relies on markdown conventions and fixed port; no persistence |

## 4. Architecture and Component Analysis

### 4.1 Packaging and Host Integration

**Files:** `plugin/.claude-plugin/plugin.json`, `plugin/.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`

This layer only makes the project installable/discoverable inside host agents. It does not implement runtime behavior, but it is the distribution boundary.

`plugin/.codex-plugin/plugin.json` points Codex at `./skills/`, reinforcing that the repo’s real unit of behavior is a skill/spec bundle rather than compiled code.

### 4.2 Command Specification Layer

**Files:** `plugin/commands/*.md`

These command files are the effective controllers of the system. They own:

- argument semantics
- user interaction flow
- validation expectations
- sequencing across compile/search/query/lint/capture/migration/upgrade workflows

They are not passive docs; they are executable behavioral contracts for the host agent.

### 4.3 Core Compiler Skill

**File:** `plugin/skills/wiki-compiler/SKILL.md`

This is the system’s main semantic core. It centralizes shared logic that the individual commands route into:

- source scanning
- change detection
- topic discovery
- codebase vs knowledge mode behavior
- article generation
- concept generation
- schema evolution
- index regeneration
- state/log updates
- codebase navigation file generation

This is the repo’s closest equivalent to a traditional compiler pipeline.

### 4.4 Hook / Session Context Layer

**Files:** `plugin/hooks/hooks.json`, `plugin/hooks/session-start`, `plugin/hooks/wiki-session-context`

This layer turns the wiki from a generated artifact into a session-default knowledge source.

`wiki-session-context` walks up directories to find the nearest `.wiki-compiler.json`, reads config values via `node -e`, checks whether `INDEX.md` and `.compile-state.json` exist, and emits context text based on compile state and configured mode. It can also warn about staleness by scanning source directories for newer files using `find`, `touch -t`, `mktemp`, and file mtimes.

Architecturally, this is the only automatic orchestration trigger in the repo.

### 4.5 Visualization Layer

**Files:** `plugin/visualize/server.js`, `plugin/visualize/index.html`

This is the most concrete executable subsystem.

`server.js`:

- resolves the wiki directory from `--wiki-dir` or `.wiki-compiler.json`
- parses frontmatter and `##` sections from topic/concept markdown
- extracts topic metadata from `INDEX.md`
- builds explicit graph edges from concept frontmatter `topics_connected`
- adds fallback edges from shared sources or topic references when no concept edge exists
- serves JSON on `/api/graph`, `/api/topic/:slug`, `/api/concept/:slug`

`index.html` is a self-contained browser client that renders the graph on a canvas, provides search, node expansion, hover tooltips, and a side panel for article content.

**Important hidden coupling:** the visualizer assumes specific markdown conventions:

- `INDEX.md` contains a parseable topic table
- topic article sections are `##` headings
- concept frontmatter uses a simple array-like `topics_connected`
- `Sources` sections hold operational backlinks

### 4.6 Template Layer

**Files:** `plugin/templates/article-template.md`, `codebase-article-template.md`, `schema-template.md`, `index-template.md`, `captured-source-template.md`, `global-wiki-config.json`

These are soft schemas for generated artifacts and capture normalization. Their significance is higher than normal templates because downstream behavior implicitly depends on them.

### 4.7 Adapter Layer

**Files:** `plugin/skills/wiki-compiler/adapters/*.md`

This layer extends the raw-source acquisition side without changing the compiler pipeline. All adapters normalize external material into markdown first, then feed it back through the standard wiki flows.

Two adapter families exist:

- link capture adapters: `capture-web.md`, `capture-x.md`, `capture-youtube.md`
- bookmark sync adapters: `x.md`

### 4.8 Documentation / Marketing Layer

**Files:** `README.md`, image assets under `assets/` and `plugin/assets/`

This is lower architectural significance than the layers above, but it does reveal intended product positioning: a zero-infra, agent-first “compiled knowledge” workflow that also supports codebase onboarding.

## 5. Execution Flow Analysis

### 5.1 Initialization Flow

1. User runs `/wiki-init` or asks Codex to initialize a wiki.
2. `plugin/commands/wiki-init.md` scans the project root for code manifests and markdown-heavy directories.
3. It chooses or asks the user to choose knowledge mode vs codebase mode.
4. In knowledge mode, it asks interactive questions about sources, name, output path, and article structure.
5. In codebase mode, it can auto-detect project type, topic candidates, knowledge files, and a default article structure in one pass.
6. It writes `.wiki-compiler.json`, creates `wiki/`, `wiki/topics/`, `wiki/concepts/`, creates empty `.compile-state.json` and `log.md`, and in the codebase fast-path immediately invokes compilation.

**Observation:** initialization is itself an LLM-guided interview, not a fixed command-line option parser.

### 5.2 Compilation Flow

1. `/wiki-compile` validates `.wiki-compiler.json`.
2. It reads `schema.md` if present.
3. It invokes the `wiki-compiler` skill.
4. Phase 1 scans configured sources and compares them to `.compile-state.json`.
5. Phase 2 classifies sources into topics.
6. Phase 3 synthesizes topic pages from all sources assigned to each changed topic.
7. Phase 3.5 reads compiled topics and synthesizes cross-topic concept pages.
8. Phase 3.7 generates or evolves `schema.md`.
9. Phase 4 regenerates `INDEX.md`.
10. Phase 5 appends to `log.md` and rewrites `.compile-state.json`.
11. Phase 6 generates or updates `CONTEXT.md` on codebase-mode first run.

**Coordination detail:** only Phase 3 is allowed to parallelize, and even then only via subagents per topic. Later phases are explicitly parent-controlled and sequential.

### 5.3 Query and Search Flow

**`/wiki-query`:**

1. read `.wiki-compiler.json`
2. read `INDEX.md`
3. optionally read `schema.md`
4. pick 1-3 topic pages
5. answer with section citations
6. optionally file useful synthesis back into the wiki and log it

**`/wiki-search`:**

1. validate config
2. scan `INDEX.md` first for cheap topic discovery
3. if insufficient, search full topic and concept pages
4. present excerpts with coverage hints and suggested next actions

These flows are designed to avoid re-reading raw files until the wiki signals low coverage.

### 5.4 Capture Flow

1. `/wiki-capture` resolves target wiki: global, local, or both.
2. It ensures target wiki config exists, auto-initializing the global wiki from `plugin/templates/global-wiki-config.json` when necessary.
3. It requests or uses explicit user context.
4. It routes the URL to exactly one capture adapter.
5. The adapter writes a normalized markdown source under `wiki-sources/captures/...`.
6. The command ensures the capture source path is present in `sources[]`.
7. Unless `--no-update` is used, it proposes connections to existing topics/concepts, asks for confirmation, and then uses the ingest/update path.

**Architectural pattern:** external content is never injected directly into topic pages; it is first turned into a durable raw-source markdown file.

### 5.5 Bookmark Sync Flow

1. `/fetch-bookmarks` lists or dispatches to a bookmark adapter.
2. For source `x`, `plugin/skills/wiki-compiler/adapters/x.md` defines preflight checks, optional global npm install of Field Theory CLI, bookmark sync, markdown export, and optional config update.
3. Auto-sync support is described for macOS, with Linux/WSL and Windows getting instructions instead of installation.

**Observation:** this is an integration contract, not an implementation library.

### 5.6 Session Start Flow

1. Claude executes the `SessionStart` hook from `plugin/hooks/hooks.json`.
2. `plugin/hooks/session-start` calls `plugin/hooks/wiki-session-context`.
3. That script climbs parent directories looking for `.wiki-compiler.json`.
4. If none exists, it emits nothing.
5. If config exists but no compiled wiki exists yet, it emits a “compile first” prompt.
6. If a compiled wiki exists, it emits location, topic count, last compiled date, mode-specific guidance, and possibly a staleness warning derived from source mtimes.

This is the repo’s only genuinely automatic runtime behavior.

### 5.7 Visualization Flow

1. User runs `/wiki-visualize` or directly starts `node plugin/visualize/server.js --wiki-dir ...`.
2. The Node server loads the compiled wiki files on demand.
3. Browser requests `/api/graph`.
4. The client renders topics as nodes and concept/shared-source links as edges.
5. Clicking a node or edge loads the backing article JSON and shows sections in a side panel.

**Important runtime fact:** the visualizer is live-read, not precompiled; wiki file changes appear immediately because the server reparses files per request.

## 6. State and Persistence Model

### Persistent state

**User-owned / manually editable**

- `.wiki-compiler.json` — primary config
- `schema.md` — becomes the structural source of truth after first compile

**Generated**

- `{output}/INDEX.md`
- `{output}/topics/*.md`
- `{output}/concepts/*.md`
- `{output}/log.md`
- `{output}/.compile-state.json`
- `{output}/CONTEXT.md` in codebase mode

**Captured source layer**

- `wiki-sources/captures/...`

### State ownership

- `.wiki-compiler.json` owns scan scope, mode, output path, link style, article sections, and update policy.
- `schema.md` owns naming conventions and long-lived topic/concept structure.
- `.compile-state.json` owns minimal incremental memory: last compile date, topics, source locations, total source count.
- topic and concept pages own the synthesized semantic content.

### Mutable vs immutable

- raw sources are intended to be immutable during compile
- compiled wiki files are mutable and regenerated
- captured-source markdown is append-only in spirit; capture docs explicitly forbid overwriting existing captured files

### Invariants

- compile must not modify files outside configured output directory
- topic slugs are lowercase kebab-case
- topic pages use `##` section headings
- `Sources` sections list all contributing sources
- concept frontmatter should expose `topics_connected`

### Persistence limitations

**Observed limitation:** `.compile-state.json` is underspecified for true incremental behavior. The documented shape stores only:

- `last_compiled`
- topic slug list
- source location list
- total source count

It does not record per-topic source membership, per-file hashes, or source-to-topic mappings. Incremental compilation therefore depends on the host agent re-deriving enough state each run.

## 7. Coordination and Control Semantics

Execution authority resides with the **host LLM following repo-authored specs**.

### Control topology

- **Centralized:** commands initiate flows, the core skill governs compile semantics, hooks only prepend context.
- **Directive, not reactive:** work happens when the user invokes commands, except for session-start guidance.
- **State-informed:** config/schema/state files shape decisions, but they do not enforce them mechanically.

### Delegation model

- command files dispatch into shared skill behavior
- capture command dispatches into exactly one adapter based on URL pattern
- compile may delegate per-topic article generation to subagents
- concept/schema/index/log/state stages remain in the parent controller

### Routing model

- source routing: `sources[]` in `.wiki-compiler.json`
- wiki-target routing: prompt wording + existence of local/global configs
- capture routing: URL pattern → adapter
- graph routing: concept-defined edges first, fallback shared-source/topic-ref edges second

### Concurrency model

The only explicitly parallelizable part is topic compilation in Phase 3. Everything else is serialized. That suggests the author treats concept discovery and schema/index/state mutation as global consistency points.

### Failure propagation

Mostly fail-stop and conversational:

- missing config → tell user to run init
- missing compiled wiki → tell user to compile first
- failing external adapter step → stop and surface error
- failing environment preflight → stop with install instructions

There is little evidence of automatic retry or structured recovery beyond user-guided reruns.

## 8. Configuration and Environment Model

### Main config: `.wiki-compiler.json`

Observed/configured fields across README, init flow, and skill:

- `version`
- `name`
- `mode`
- `sources[]`
- `output`
- `article_sections`
- `topic_hints`
- `link_style`
- `auto_update`
- `service_discovery` (codebase mode)
- `knowledge_files` (codebase mode)
- `deep_scan` (codebase mode)
- `code_extensions` (mentioned in the skill prerequisites)

### Environment variables

- `LLM_WIKI_GLOBAL_DIR` — overrides default global wiki root
- `CLAUDE_PLUGIN_ROOT` — path resolution for commands/hooks/templates
- `CURSOR_PLUGIN_ROOT` / `COPILOT_CLI` — alter JSON envelope emitted by `plugin/hooks/session-start`

### Runtime prerequisites

For core plugin operation:

- Claude Code or Codex with plugin/skill support
- Node.js for the visualizer and for config reads inside hooks
- Bash + Unix utilities for hooks and some command recipes

For optional X bookmark integration:

- Node 20+
- npm
- Field Theory CLI (`fieldtheory`)

### Required vs optional configuration

**Required for any useful local wiki**

- `.wiki-compiler.json`
- at least one source path
- output path
- compiled `INDEX.md` after first run

**Optional / advanced**

- custom `article_sections`
- `topic_hints`
- `deep_scan`
- global wiki path override
- capture source wiring
- bookmark auto-sync

### Important configuration inconsistency

`mode` is overloaded across different semantics:

- `wiki-init --codebase` writes `"mode": "codebase"`
- `plugin/hooks/wiki-session-context` also interprets `mode` as presentation mode (`staging`, `recommended`, `primary`)

The script works around this by separately deriving `wiki_mode`, but the same field is still carrying both workflow type and session-guidance mode. That is a real coupling flaw.

## 9. Operational Usage Model

### Canonical usage

The intended lifecycle is:

1. initialize a local or global wiki
2. compile sources into topic pages
3. start future sessions by reading the wiki first
4. query/search against the wiki instead of raw files
5. ingest individual sources or capture external links
6. occasionally lint the wiki and evolve the schema

### Expected user roles

- **human:** curates source scope, approves structure changes, gives capture context, reads/browses resulting wiki
- **host LLM:** performs synthesis, updates topic/concept pages, maintains schema/index/log/state

### Development vs production reality

This repo does not define a “server deployment.” Its real production environment is a user’s Claude/Codex workflow plus a filesystem.

### Session semantics

The session-start hook is meant to establish a **wiki-first read discipline**:

- start at `INDEX.md`
- read topic pages before raw files
- use raw sources only for low-coverage sections or code-level precision

### Operational assumptions

- users are comfortable with markdown files as durable state
- humans tolerate agent-mediated workflows instead of strict CLIs
- wiki files are viewed in Obsidian or a text editor
- source sets are moderate enough for LLM-driven synthesis rather than requiring formal indexing infrastructure

## 10. Extension and Customization Architecture

### Primary extension surfaces

1. **Command specs** in `plugin/commands/`
2. **Core skill logic** in `plugin/skills/wiki-compiler/SKILL.md`
3. **Templates** in `plugin/templates/`
4. **Adapters** in `plugin/skills/wiki-compiler/adapters/`
5. **Schema conventions** in generated `schema.md`

### How the system expects to evolve

- add new capture or bookmark adapters by creating markdown adapter contracts
- refine compile behavior by editing `SKILL.md`
- customize article structure at init time or by editing config/schema later
- extend host support by adding new plugin metadata or hook integrations

### Extension boundaries

**Cleanest boundaries**

- capture adapter interface
- template layer
- generated schema as human-controlled convention layer

**Leakier boundaries**

- visualizer assumptions about markdown format
- hook assumptions about config shape and Unix utilities
- command docs that include shell commands not portable across platforms

### Customization difficulty

- easy: change article sections, naming conventions, default global config, README/UX text
- medium: add new capture adapters following existing markdown contracts
- harder: harden compile semantics, make behavior cross-platform, or introduce deterministic enforcement without rewriting the architecture

## 11. Key Architectural Decisions and Tradeoffs

### Prompt-defined runtime instead of compiled runtime

**Observed choice:** core behavior is encoded in markdown skills and commands.

**Tradeoff:** very portable and easy to modify; weakly enforced and harder to test deterministically.

### Filesystem-native persistent state

The project uses markdown + JSON files as the full persistence layer.

**Tradeoff:** easy to inspect, back up, diff, and sync; limited structural guarantees and no transactional consistency.

### Wiki as compiled intermediate representation

The output wiki is explicitly a synthesis layer between raw files and future queries.

**Tradeoff:** strong context compression and reuse; risk of synthesis drift or stale summaries when compile discipline is weak.

### Schema as co-owned source of truth

Generated `schema.md` becomes a human/agent co-evolved control file.

**Tradeoff:** flexible governance of topic structure; removal/cleanup is cautious and manual, so structure may accrete over time.

### Zero-infrastructure bias

README and command design consistently avoid databases, hosted platforms, and embeddings.

**Tradeoff:** simple adoption; search and verification stay comparatively shallow.

### Visualization from markdown, not from a separate graph store

The graph is derived live from compiled markdown and concept frontmatter.

**Tradeoff:** no synchronization burden; graph quality depends heavily on markdown discipline and parser assumptions.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 The compiler is mostly aspirational code-wise

There is no executable compiler implementation beyond instructions in markdown files. This is intentional, but it means behavior cannot be validated or regression-tested in the usual way.

### 12.2 Thin incremental state

`.compile-state.json` does not track enough detail for robust incremental recomputation or lint precision.

### 12.3 Cross-platform fragility

- hooks are Bash-based and use Unix commands
- `wiki-visualize.md` uses `open`, which is macOS-specific
- `wiki-upgrade.md` assumes `~/.claude/plugins`

The repo positions itself as portable across hosts, but some operational flows are OS-biased.

### 12.4 `mode` overload

`plugin/hooks/wiki-session-context` conflates session-guidance mode and knowledge/codebase mode in the same config field.

### 12.5 Command/spec inconsistencies

- `plugin/commands/wiki-ingest.md` says it logs to `{output}/compile-log.md`, while the compiler skill uses `{output}/log.md`.
- `plugin/commands/wiki-visualize.md` documents `--port`, but `plugin/visualize/server.js` hardcodes port `3848` and ignores any port flag.
- `plugin/templates/index-template.md` includes `Total concepts`, while the Phase 4 example in `SKILL.md` does not; format expectations are not fully unified.

### 12.6 Partial adapter ecosystem

Only the X/Twitter bookmark adapter is present. README and command docs mention future Readwise, Pocket, GitHub stars, etc.; those are aspirational.

### 12.7 No automated validation surface

There are no tests, no manifests, and no build scripts in the repository root. That is consistent with the architecture, but it makes change safety dependent on careful manual reasoning.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Install the plugin into Claude or Codex.
2. In a target folder, run `/wiki-init` or say “Initialize a wiki for this repo.”
3. Run `/wiki-compile`.
4. Open `wiki/INDEX.md`.
5. Optionally run `/wiki-visualize`.

### Operational Assumptions

- moderate-scale source corpus, not huge enterprise-scale indexing
- users are comfortable editing markdown/JSON
- the host LLM can read/write files reliably
- source material quality affects synthesis quality
- recency matters, especially for bookmark-heavy or fast-moving topics

### Canonical Workflow

1. curate source directories
2. initialize config
3. compile
4. use query/search against wiki
5. ingest or capture new material
6. recompile incrementally
7. lint and refine schema when needed

### Advanced Usage

- run global wiki + local project wiki side by side
- use codebase mode with `deep_scan: true` for richer module articles
- use capture adapters to build durable source archives from links
- use concept pages for cross-topic strategic patterns

### Extension Workflow

To add a new source type:

1. add an adapter under `plugin/skills/wiki-compiler/adapters/`
2. wire routing into command semantics if needed
3. ensure it normalizes into markdown under a stable source path
4. let the existing compile path synthesize it into topics

To change article shape:

1. edit init defaults/templates, or
2. update `article_sections` in config/schema conventions

### Debugging Workflow

Inspect in this order:

1. `.wiki-compiler.json`
2. `wiki/schema.md`
3. `wiki/INDEX.md`
4. `wiki/.compile-state.json`
5. `wiki/log.md`
6. relevant topic/concept article `Sources` sections
7. hook output from `plugin/hooks/wiki-session-context`
8. visualizer parsing assumptions in `plugin/visualize/server.js`

### Observability

- `INDEX.md` exposes topic inventory and recent changes
- `log.md` records compile/lint/query-filed history
- `.compile-state.json` shows compile date and coarse source inventory
- `CONTEXT.md` explains how codebase wiki consumers should navigate
- graph UI provides structural visibility into topic/concept connectivity

### Failure Modes

- no config → init required
- config exists but no compile → commands degrade to “compile first”
- stale wiki → hook emits warning based on source mtimes
- capture adapter cannot extract content → workflow asks for user-provided material instead of fabricating
- bookmark integration preflight fails → stop with external-tool instructions

### Performance Considerations

- cost is dominated by host LLM reads/writes, not local CPU
- `deep_scan` intentionally limits source-file reads per topic
- index-first query/search is a cost-control strategy
- visualizer reparses files live; acceptable for moderate wiki sizes, but there is no caching layer

## 14. Project Navigation Guide

### Best reading order

1. `README.md` — product framing and user-facing flows
2. `plugin/skills/wiki-compiler/SKILL.md` — actual compile semantics
3. `plugin/commands/wiki-init.md` and `plugin/commands/wiki-compile.md` — orchestration entry points
4. `plugin/hooks/wiki-session-context` — automatic session behavior
5. `plugin/visualize/server.js` — concrete executable parser/runtime
6. `plugin/templates/*.md` / `*.json` — output contracts
7. `plugin/commands/wiki-capture.md` and adapter specs — source acquisition path

### Highest-value semantic centers

- `plugin/skills/wiki-compiler/SKILL.md`
- `plugin/commands/wiki-init.md`
- `plugin/hooks/wiki-session-context`
- `plugin/visualize/server.js`

### Where abstractions become concrete

- compile/query/lint/ingest remain mostly specification-level in `plugin/commands/` and `SKILL.md`
- hook execution becomes concrete in `plugin/hooks/`
- wiki rendering becomes concrete in `plugin/visualize/server.js` and `plugin/visualize/index.html`

### Entry points for common changes

| Goal | Start here |
| --- | --- |
| change compile behavior | `plugin/skills/wiki-compiler/SKILL.md` |
| change init interview/default config | `plugin/commands/wiki-init.md`, `plugin/templates/global-wiki-config.json` |
| add new capture source | `plugin/skills/wiki-compiler/adapters/`, `plugin/commands/wiki-capture.md` |
| change article layout | `plugin/templates/article-template.md`, `plugin/templates/codebase-article-template.md`, init defaults |
| change session-start behavior | `plugin/hooks/wiki-session-context`, `plugin/hooks/session-start`, `plugin/hooks/hooks.json` |
| change graph semantics | `plugin/visualize/server.js`, `plugin/visualize/index.html` |

## 15. Concise Deep Technical Synthesis

This repository is fundamentally a **filesystem-native, agent-driven wiki compiler protocol** packaged as a Claude/Codex plugin. Its architectural pattern is not “application with plugins”; it is closer to **plugin-distributed operating instructions for an LLM**, with a small amount of supporting executable code for hooks and graph visualization.

The system’s distinctive idea is that the wiki is treated as a compiled intermediate representation: durable enough to replace repeated raw-file reading, lightweight enough to live entirely in markdown, and flexible enough to be co-governed by humans through `schema.md`.

It appears optimized for engineers or knowledge workers who are comfortable letting an LLM maintain derived artifacts on the filesystem, who value transparent markdown state over hosted infrastructure, and who accept softer guarantees in exchange for low setup cost and high workflow malleability.
