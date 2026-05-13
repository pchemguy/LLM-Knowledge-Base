---
repo: nvk/llm-wiki
---

# llm-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

`llm-wiki` is a **prompt-programmed, file-backed knowledge-base operating model** packaged for several agent runtimes rather than a conventional app or library. The dominant implementation is in Markdown behavior specs under `claude-plugin/skills/wiki-manager/` and `claude-plugin/commands/`; the main deterministic code is the local lint helper in `scripts/llm-wiki`.

**Observed:** `claude-plugin/skills/wiki-manager/SKILL.md`, `claude-plugin/commands/wiki.md`, `claude-plugin/skills/wiki-manager/references/wiki-structure.md`, `scripts/llm-wiki`.

**Inference:** the repo’s real “runtime” is the host agent plus filesystem; this repository provides behavioral contracts, packaging, and structural guardrails.

### Quick Adaptation Assessment

Behavior changes are centralized but tightly coupled. The safe edit surface is `claude-plugin/skills/wiki-manager/` and `claude-plugin/commands/*.md`; `plugins/llm-wiki/` and `plugins/llm-wiki-opencode/` are generated mirrors. Schema changes must be reflected in references, the local CLI, structural tests, and fixtures.

**Observed:** `CLAUDE.md`, `scripts/sync-codex-plugin.sh`, `scripts/sync-opencode-plugin.sh`, `tests/test-structure.sh`, `tests/generate-defect-fixtures.sh`.

### Fastest Path to First Successful Run

The fastest realistic usage path from this checkout is:

1. **Portable mode:** give an agent `AGENTS.md`.
2. **OpenCode/Pi mode:** load `plugins/llm-wiki-opencode/skills/wiki-manager/SKILL.md`.
3. **Codex mode:** `codex plugin marketplace add <repo-path>`, then enable **LLM Wiki** in `/plugins`.

There is no standalone server or CLI app to start for end-user operation.

### Minimal Manual Setup Path

Without helper scripts:

1. **Portable:** copy `AGENTS.md` into the target project or agent context.
2. **OpenCode:** point `opencode.json` `"instructions"` at `plugins/llm-wiki-opencode/skills/wiki-manager/SKILL.md` and allow external wiki/config paths.
3. **Codex:** add the repo as a local marketplace source, then enable the plugin interactively.

**Observed:** `README.md`, `plugins/llm-wiki-opencode/README.md`, `scripts/bootstrap-codex-plugin.sh`, `scripts/verify-codex-plugin.sh`.

### Operational Complexity Snapshot

- **Setup complexity:** medium for users, medium-high for maintainers.
- **Runtime dependencies:** host agent tools, writable filesystem, optional web access, runtime-specific permissions.
- **Stability profile:** strongest around schema, lint, packaging, and sync; weaker around prompt-driven research/compile/audit behavior.
- **Debugging profile:** file- and test-centric rather than process-centric.

I could not execute the repo’s shell-based tests in this environment because PowerShell-backed command execution was unavailable, so this report is grounded in inspected repository contents rather than live runs.

## 1. Repository Purpose

`llm-wiki` implements a reusable protocol for running an LLM-maintained Markdown knowledge base with five major content layers:

1. `raw/` immutable ingested sources.
2. `wiki/` synthesized articles.
3. `inventory/` durable operational records.
4. `datasets/` manifests for large or external corpora.
5. `output/` generated artifacts and project deliverables.

The conceptual Karpathy-style “LLM wiki” idea is present, but this repo extends it into a broader operating model: topic-isolated hubs, derived indexes, trust audits, librarian scans, collection ingestion, dataset manifests, project folders, and resume/provenance artifacts.

**Observed:** `AGENTS.md`, `README.md`, `claude-plugin/commands/{inventory,dataset,audit,librarian,ingest-collection,project}.md`.

**Scope boundary:** there is no search backend, DB, API service, or standalone orchestrator in the repo. The host runtime performs reasoning and tool use; this repo defines how that work should be done and what files it should create.

## 2. High-Level System Model

This is a **prompt-orchestration-centric, filesystem-backed execution spec**.

At a systems level:

1. A host runtime loads a plugin or instruction file.
2. The prompt layer resolves the active wiki root from config and flags.
3. A router (`claude-plugin/commands/wiki.md`) dispatches work into explicit workflows.
4. Workflows read/write Markdown and JSON/JSONL state in the wiki tree.
5. Deterministic helpers (`scripts/llm-wiki`, `tests/*.sh`) enforce structure, placement, and packaging invariants.

The primary semantic center is not classes or services; it is the **filesystem schema plus prompt contracts** in:

- `claude-plugin/skills/wiki-manager/SKILL.md`
- `claude-plugin/commands/*.md`
- `claude-plugin/skills/wiki-manager/references/{wiki-structure,indexing,linting,hub-resolution,research-infrastructure}.md`

**Inference:** the architecture exists in this form to keep the behavior portable across Claude, Codex, OpenCode, Pi, and “any agent” via `AGENTS.md`, while preserving one dominant authoring surface.

## 3. Conceptual Capability Mapping

| Capability | Implementation status | Main location | Runtime semantics | Limits / notes |
|---|---|---|---|---|
| Natural-language routing | Implemented | `claude-plugin/commands/wiki.md` | Priority-ordered signal router chooses a workflow | Prompt-defined, not code-enforced |
| Source ingest | Implemented as workflow spec | `claude-plugin/commands/ingest.md`, `references/ingestion.md` | URL/file/text/inbox -> raw source -> indexes/log | Depends on runtime tools and web/PDF access |
| Collection ingest | Implemented as workflow spec | `claude-plugin/commands/ingest-collection.md` | Repo/wiki/archive -> collection manifest + child sources | No dedicated collector binary |
| Compilation | Implemented as workflow spec | `claude-plugin/commands/compile.md`, `references/compilation.md` | Survey uncompiled raw sources -> update wiki articles | Deterministic guarantees come mostly from later lint |
| Query and resume | Implemented as workflow spec | `claude-plugin/commands/query.md` | Index-first browse, then article reads, optional deep/raw/sibling peek | No true search index |
| Multi-agent research | Implemented as workflow spec | `claude-plugin/commands/research.md`, `references/research-infrastructure.md` | Search -> ingest -> compile, with optional multi-round state | Emergent behavior depends on host agent |
| Thesis mode | Implemented as research mode | `claude-plugin/commands/research.md`; deprecated shim in `commands/thesis.md` | Adds claim framing, evidence directions, verdicts | Shim indicates migration still visible |
| Inventory | Implemented | `claude-plugin/commands/inventory.md`, `references/inventory.md` | Durable operational tracking records in `inventory/` | Explicitly not factual evidence |
| Dataset registry | Implemented | `claude-plugin/commands/dataset.md`, `references/datasets.md` | Metadata/index layer for large or remote data | No query engine beyond manifests |
| Librarian scan | Partially implemented | `claude-plugin/commands/librarian.md`, `references/librarian.md` | Quality/staleness review of `wiki/` layer | `fix <id>` is not implemented |
| Trust audit | Implemented as workflow spec | `claude-plugin/commands/audit.md`, `references/audit.md` | Reuse librarian + provenance + fresh evidence gathering | Requires reachable sources/web |
| Structural lint | Deterministically implemented | `scripts/llm-wiki`, `references/linting.md` | Schema, placement, links, coverage, freshness, project hygiene | Strongest production-grade subsystem |
| Multi-runtime packaging | Deterministically implemented | `scripts/sync-*.sh`, manifests under `.claude-plugin`, `.agents`, `plugins/` | Claude source -> Codex/OpenCode mirrors | Requires sync discipline |

## 4. Architecture and Component Analysis

### 4.1 Claude-side behavioral source of truth

**Files:** `claude-plugin/.claude-plugin/plugin.json`, `claude-plugin/commands/*.md`, `claude-plugin/skills/wiki-manager/SKILL.md`, `claude-plugin/skills/wiki-manager/references/*.md`

**Responsibility:** defines the canonical behavior model, command vocabulary, tool allowlists, and wiki semantics.

**Boundary:** this is the intended direct-edit surface. Everything in `plugins/` is derivative.

**Hidden coupling:** command files inline hub-resolution rules instead of importing them. `references/hub-resolution.md` explicitly says that, as of v0.4.1, commands no longer depend on that file at runtime.

### 4.2 Filesystem schema as domain model

**Files:** `AGENTS.md`, `references/wiki-structure.md`, `references/indexing.md`, `references/linting.md`

This is the deepest abstraction in the repo. It defines:

- hub vs topic wiki vs local `.wiki/`
- authoritative content layers
- frontmatter schemas
- derived indexes
- append-only logs
- session/provenance files
- concurrency expectations

The repo’s domain semantics are encoded more strongly in path and frontmatter conventions than in executable code.

### 4.3 Runtime-specific packaging mirrors

#### Codex

**Files:** `plugins/llm-wiki/.codex-plugin/plugin.json`, `plugins/llm-wiki/skills/wiki/SKILL.md`, `plugins/llm-wiki/skills/wiki/agents/openai.yaml`, `.agents/plugins/marketplace.json`, `scripts/{sync-codex-plugin,bootstrap-codex-plugin,verify-codex-plugin}.sh`

**Semantic role:** translate Claude-authored behavior into Codex’s marketplace and skill model, including a rewritten skill frontmatter, Codex-specific operational notes, generated UI metadata, and config bootstrap.

**Important nuance:** Codex does not mirror Claude command files directly; it flattens behavior into a rewritten `SKILL.md`.

#### OpenCode / Pi

**Files:** `plugins/llm-wiki-opencode/skills/wiki-manager/SKILL.md`, `plugins/llm-wiki-opencode/README.md`, `scripts/sync-opencode-plugin.sh`

**Semantic role:** package the same behavior as an instruction file instead of a plugin-command surface.

**Important nuance:** OpenCode keeps `references/` as a symlink back into Claude source, while Codex copies reference files for marketplace caching.

### 4.4 Deterministic local lint runtime

**File:** `scripts/llm-wiki`

This is the strongest executable subsystem in the repo. It owns:

- hub/wiki root resolution
- frontmatter parsing
- canonical placement
- unknown-file quarantine
- link validation
- source provenance resolution
- coverage and freshness checks
- project hygiene
- machine-readable and text reports

It is not a full wiki runtime; it is a structural guardrail and local deterministic assistant for the prompt system.

### 4.5 Test harness and fixtures

**Files:** `tests/test-plugin-validate.sh`, `tests/test-structure.sh`, `tests/test-local-cli-lint.sh`, `tests/test-codex-sync.sh`, `tests/test-opencode-sync.sh`, `tests/test-codex-runtime.sh`, `tests/promptfooconfig.yaml`, `tests/fixtures/golden-wiki/`, `tests/fixtures/defects/`

The tests focus on:

- plugin/package validity
- schema and placement invariants
- local lint behavior
- generated mirror drift
- limited routing checks via Promptfoo

The test suite is structurally mature; it is less comprehensive for deep workflow correctness.

## 5. Execution Flow Analysis

### 5.1 Startup and command resolution

1. A runtime loads the relevant packaging surface:
   - Claude via `.claude-plugin/marketplace.json` -> `claude-plugin/`
   - Codex via `.agents/plugins/marketplace.json` + `plugins/llm-wiki/`
   - OpenCode/Pi via the instruction file path
2. `SKILL.md` and/or `commands/wiki.md` establishes the operating model.
3. Each workflow resolves the hub path using the config-first protocol.
4. The active wiki root is chosen by `--local`, `--wiki <name>`, ambient `.wiki/`, or fallback hub selection.
5. The selected workflow operates directly on wiki files.

### 5.2 Top-level routing

`claude-plugin/commands/wiki.md` is the top-level control surface. It handles:

- `init`
- `config`
- status views
- fuzzy routing for freeform requests

Routing is priority-based. Inventory and dataset signals intentionally outrank generic question/URL patterns, which prevents eager ingestion when the user actually wants to track or classify something first.

### 5.3 Shared wiki-operation prelude

Most commands inline the same resolution sequence:

1. Read `~/.config/llm-wiki/config.json`.
2. Prefer `resolved_path`; otherwise expand `hub_path`; otherwise fallback to `~/wiki/_index.md`.
3. Resolve target wiki from flags or context.
4. Read `_index.md` or branch into first-run/onboarding behavior.

This duplication is intentional but increases drift risk.

### 5.4 Research flow

`claude-plugin/commands/research.md` specifies the largest runtime pipeline:

1. Parse topic/question/thesis flags.
2. Resolve or create target wiki.
3. Optionally read inventory indexes for operational context.
4. Spawn research agents by mode (standard/deep/retardmax/plan/question/thesis).
5. Score credibility before ingestion.
6. Ingest chosen sources into `raw/`.
7. Compile synthesized articles into `wiki/`.
8. Write logs, outputs, and optional session/provenance artifacts.
9. In `--min-time` mode, iterate by round using `.research-session.json`, `.session-events.jsonl`, and `.session-checkpoint.json`.

### 5.5 Query flow

`claude-plugin/commands/query.md` formalizes a 3-hop, index-first navigation model:

1. Read master `_index.md`.
2. Read category indexes.
3. Read only matched articles.
4. Optionally grep `wiki/` and `raw/`.
5. In deep mode, peek sibling wiki indexes.
6. Synthesize an answer citing wiki content only.

Resume mode is a specialized operational query that inspects session files, logs, stats, and recently updated articles.

### 5.6 Deterministic lint flow

From `scripts/llm-wiki:934-959`, the local CLI performs:

1. wiki root resolution
2. `check_structure`
3. `load_documents`
4. `check_frontmatter_schema`
5. `check_canonical_placement`
6. `check_unknown_files`
7. reload documents
8. `check_index_consistency`
9. `check_links`
10. `check_source_provenance`
11. `check_tags`
12. `check_coverage`
13. `check_freshness`
14. `check_projects`
15. log/report output

This ordering is important: placement and unknown-file handling happen before later checks consume the resulting document set.

## 6. State and Persistence Model

### Authoritative state

The source of truth is the wiki filesystem itself:

- `wikis.json`
- `config.md`
- `log.md`
- `raw/`
- `wiki/`
- `inventory/`
- `datasets/`
- `output/`
- `output/projects/<slug>/WHY.md`

### Derived state

`_index.md` files are explicitly treated as caches. `references/indexing.md` and `SKILL.md` describe rebuild-on-read behavior, and `scripts/llm-wiki` checks them for staleness and integrity.

### Ephemeral state

- `.research-session.json`
- `.thesis-session.json`

These are crash-recovery/session-control files.

### Durable provenance state

- `.session-events.jsonl`
- `.session-checkpoint.json`
- `.librarian/*`
- `.audit/*`

These support replay, resume, trust evaluation, and operational history.

### Synchronization model

The repo intentionally avoids locking:

- indexes converge because they derive from files
- logs are append-only
- independent file writes do not coordinate
- same-file edits are effectively last-write-wins

**Inference:** this is optimized for “good enough” concurrent agent collaboration, not strict transactional integrity.

## 7. Coordination and Control Semantics

Execution authority is mostly centralized in prompt contracts.

### Control hierarchy

1. host runtime
2. top-level skill/router (`SKILL.md`, `commands/wiki.md`)
3. specific command prompt
4. reference docs
5. filesystem state

### Routing semantics

The system is **directive, centrally routed, and mostly synchronous at the command level**, with optional delegated concurrency inside research workflows. `commands/wiki.md` decides what workflow to enter; once inside, the command prompt governs execution.

### Concurrency model

Concurrency is **narrow and delegated**:

- research can fan out to multiple agents
- plan mode creates multiple research paths
- file-state coordination relies on derived-index convergence rather than a scheduler

No runtime scheduler or queue exists in code.

### Failure propagation

- structural issues surface through lint
- sync drift is turned into a failing test after self-healing regeneration
- interrupted research is expected and resumable
- Codex bootstrap has an explicit “pending” state when first-time interactive enablement is still required

## 8. Configuration and Environment Model

### Configuration hierarchy

Primary runtime config is `~/.config/llm-wiki/config.json` with:

- `hub_path`
- `resolved_path`

If config exists, it is authoritative. Only when config is absent should the runtime fall back to `~/wiki`.

### Wiki targeting

Resolution order is stable across the repo:

1. explicit path / `--local`
2. `--wiki <name>`
3. ambient `.wiki/`
4. hub fallback

### Runtime-specific environment assumptions

- **Claude:** plugin marketplace support, `claude-plugin/`
- **Codex:** writable `~/.codex`, marketplace registration, eventual `/plugins` enable
- **OpenCode:** instruction loading plus `external_directory` permissions
- **Pi:** reuses the OpenCode skill file

### Dev/test environment assumptions

Observed prerequisites include `bash`, `python3`, `rsync`, `sed`, `git`, and optional `codex`, `@anthropic-ai/claude-code`, `promptfoo`, `pdftotext`.

There is no `package.json`, `requirements.txt`, or equivalent tool manifest provisioning these automatically.

## 9. Operational Usage Model

### Canonical user workflow

1. initialize a wiki
2. ingest sources or launch research
3. compile articles
4. query the compiled wiki
5. maintain with lint / librarian / refresh
6. generate outputs, plans, or assessments
7. audit when trust or provenance matters
8. capture deferred operational state in inventory/datasets/projects

### Maintainer workflow

1. edit Claude-side source files
2. sync generated runtime mirrors
3. run structural/sync/runtime tests
4. stage generated `plugins/` changes
5. release by keeping manifests aligned

### Actual runtime interaction model

This repo expects users to interact with an LLM conversationally, not by scripting against an API. Even explicit command examples are really **prompt-entry shorthands**:

- Claude: `/wiki:*`
- Codex: `@wiki ...`
- OpenCode/Pi: natural-language request interpreted through the instruction file

## 10. Extension and Customization Architecture

### Main extension surface

Edit:

- `claude-plugin/skills/wiki-manager/SKILL.md`
- `claude-plugin/commands/*.md`
- `claude-plugin/skills/wiki-manager/references/*.md`

### Runtime adaptation layer

Adaptation into other runtimes is handled by:

- `scripts/sync-codex-plugin.sh`
- `scripts/sync-opencode-plugin.sh`

The sync scripts do not merely copy files; they patch wording, frontmatter, and runtime assumptions.

### Schema extension workflow

For any filesystem/schema change, the repo expects coordinated updates to:

- `references/wiki-structure.md`
- `references/linting.md`
- `references/compilation.md`
- `scripts/llm-wiki`
- `tests/test-structure.sh`
- `tests/generate-defect-fixtures.sh`
- sometimes `tests/promptfooconfig.yaml`

This is the repo’s real extension contract.

## 11. Key Architectural Decisions and Tradeoffs

### Prompt-first, code-light implementation

**Observed:** most behavior lives in Markdown prompts and references.

**Tradeoff:** portable and inspectable, but behavior guarantees depend heavily on model compliance.

### Filesystem as database

**Observed:** all persistent state is Markdown, JSON, and directories.

**Tradeoff:** transparent and git/Obsidian-friendly, but weak on transactions, query power, and automated invariants without lint.

### Derived indexes rather than authoritative indexes

**Observed:** `references/indexing.md`; `_index.md` is a cache.

**Tradeoff:** better concurrent tolerance, but repeated stale-check/rebuild logic spreads across prompts and tooling.

### Lint-as-migration

**Observed:** `references/linting.md` explicitly rejects a separate migration command.

**Tradeoff:** elegant unified healing path, but lint becomes a semantic choke point and high-maintenance hotspot.

### Claude-first authoring with generated mirrors

**Observed:** README, `CLAUDE.md`, sync scripts.

**Tradeoff:** one dominant authoring surface, but mirror drift and rewrite maintenance are unavoidable.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

1. **Documentation drift exists.**
   - `CLAUDE.md` still describes `commands/*.md` as 16 files and references as 10 files, while the workspace currently contains more.
   - README describes sync behavior more generally than the actual OpenCode symlink-vs-Codex-copy distinction.

2. **Core workflow semantics are lightly executable.**
   - Structural and packaging rules are strongly tested.
   - Research/compile/audit/query behavior is mostly prompt-contract behavior.

3. **Some subsystems are visibly incomplete or transitional.**
   - `commands/librarian.md` advertises `fix <id>` as not yet implemented.
   - `commands/thesis.md` remains as a deprecated shim after thesis mode moved into research.

4. **Schema duplication is high.**
   - The same path/frontmatter semantics recur across AGENTS, SKILL, command files, references, local CLI, tests, fixtures, and docs.

5. **Maintainer workflows are Unix-biased.**
   - Sync/test scripts rely on `bash`, `rsync`, `ln -s`, `mktemp`, and related tooling.

6. **Headless Codex activation is not fully solved.**
   - `test-codex-runtime.sh` treats a pending interactive-enable condition as skip rather than a guaranteed automated success path.

## 13. Practical Usage Guide

### Minimal Viable Usage

- Lowest friction for understanding the system: read `AGENTS.md`.
- Lowest friction for local deterministic behavior: use `scripts/llm-wiki lint <wiki-root>`.
- Lowest friction runtime packaging path: OpenCode/Pi instruction loading or Codex local marketplace install.

### Operational Assumptions

- users are comfortable with file-based knowledge stores
- host agent can read/write files and preferably search the web
- wiki storage may live outside the project directory
- interruptions are normal and should be recovered from file artifacts
- outputs are Markdown-first and git-friendly

### Canonical Workflow

1. `/wiki init <topic>` or research with `--new-topic`
2. ingest sources or collections
3. compile
4. query
5. lint / librarian / refresh
6. output / plan / assess
7. audit when trust matters

### Advanced Usage

- `--min-time` multi-round research
- `--plan` decomposed research paths
- `--mode thesis`
- dataset manifests for large corpora
- inventory as durable operational memory
- project-scoped outputs under `output/projects/<slug>/`

### Extension Workflow

1. edit Claude-side source
2. update schema/reference docs as needed
3. run sync scripts
4. run structural/sync tests
5. update Promptfoo routing tests if behavior changed
6. commit generated mirror changes

### Debugging Workflow

Best inspection points:

- `.claude-plugin/marketplace.json`
- `claude-plugin/.claude-plugin/plugin.json`
- `plugins/llm-wiki/.codex-plugin/plugin.json`
- `plugins/llm-wiki/skills/wiki/SKILL.md`
- `plugins/llm-wiki-opencode/skills/wiki-manager/SKILL.md`
- `scripts/llm-wiki`
- `tests/fixtures/golden-wiki/`
- `tests/fixtures/defects/`

### Observability

The observability model is file-native:

- `log.md`
- `_index.md`
- `.session-events.jsonl`
- `.session-checkpoint.json`
- `.librarian/*`
- `.audit/*`

### Failure Modes

- wrong hub path or sandbox permissions -> wiki appears empty/inaccessible
- generated mirror drift -> sync tests fail after regeneration
- malformed or stale indexes -> rebuild-on-read or lint findings
- misplaced files -> lint `--fix` relocates or quarantines
- Codex installed but not enabled -> verify returns pending
- prompt drift -> runtime behavior diverges from documentation

### Performance Considerations

- index-first reads are the main scale strategy
- prompts explicitly chunk long writes
- collection ingest avoids one-file-per-operation churn where possible
- there is no true search/index backend; large-scale use eventually relies on filesystem scans or external tools such as the README-mentioned `qmd`

## 14. Project Navigation Guide

### Highest-value entry points

1. `README.md`
2. `CLAUDE.md`
3. `claude-plugin/skills/wiki-manager/SKILL.md`
4. `claude-plugin/commands/wiki.md`
5. `claude-plugin/commands/{ingest,ingest-collection,compile,query,research,audit,inventory,dataset}.md`
6. `claude-plugin/skills/wiki-manager/references/{wiki-structure,indexing,linting,hub-resolution,research-infrastructure}.md`
7. `scripts/llm-wiki`
8. `scripts/{sync-codex-plugin,sync-opencode-plugin,bootstrap-codex-plugin,verify-codex-plugin}.sh`
9. `tests/test-plugin-validate.sh`, `tests/test-structure.sh`, `tests/test-local-cli-lint.sh`

### Best reading order

1. `README.md`
2. `CLAUDE.md`
3. `SKILL.md`
4. `commands/wiki.md`
5. core workflow commands
6. `wiki-structure.md`, `indexing.md`, `linting.md`
7. `scripts/llm-wiki`
8. sync/bootstrap scripts
9. tests and fixtures

### Where the semantic centers actually live

- **Behavioral core:** `claude-plugin/skills/wiki-manager/`
- **Routing/control logic:** `claude-plugin/commands/wiki.md`
- **Filesystem/state semantics:** `references/wiki-structure.md`, `references/indexing.md`, `references/linting.md`
- **Deterministic enforcement:** `scripts/llm-wiki`
- **Packaging translation:** `scripts/sync-*.sh`

### Where abstractions become concrete

- hub/wiki resolution: `scripts/llm-wiki:891-931`
- derived index checks: `scripts/llm-wiki:627-647`
- placement enforcement: `scripts/llm-wiki:480-532`
- source-provenance resolution: `scripts/llm-wiki:688-760`
- Codex/OpenCode translation: Python rewrite blocks inside the sync scripts

## 15. Concise Deep Technical Synthesis

`llm-wiki` is best understood as a **portable behavioral runtime spec for turning general-purpose coding/research agents into Markdown knowledge-base operators**.

Its architecture is distinctive because it combines:

- Claude-first authoring
- runtime-specific prompt rewriting
- filesystem-backed persistent state
- derived-index concurrency instead of locks
- lint-as-migration
- generated packaging mirrors
- strong structural tests but softer semantic workflow guarantees

The repo appears optimized for teams comfortable treating prompt engineering, filesystem schema, and test fixtures as first-class implementation surfaces.
