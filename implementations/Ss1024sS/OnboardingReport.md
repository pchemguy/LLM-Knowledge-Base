---
repo: Ss1024sS/LLM-wiki
---

# LLM-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

`LLM-wiki` is a **template-packaged workflow runtime for project memory**, not an application server. The behavioral core is the bootstrap engine in `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`, which maps template files to generated files via `TEMPLATE_TO_TARGET`, and the generated script suite under `skills/knowledge-system-bootstrap/templates/scripts/`, which turns the abstract “LLM wiki” idea into a concrete filesystem protocol: Git-tracked wiki pages plus manifest files inside the repo, and a raw evidence tree outside Git. The system is orchestration-centric but synchronous and file-based: users/agents call scripts, scripts read and mutate files, and repo-level AI config files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.windsurfrules`) encode the operational loop.

The main semantic center is **not** the bootstrap wrapper at `scripts/bootstrap_knowledge_system.py`; that file only `os.execv(...)` into the skill copy. The real behavioral intelligence lives in the generated scripts, especially `ingest_raw.py`, `stale_report.py`, `delta_compile.py`, `provenance_check.py`, and `wiki_check.py`.

### Quick Adaptation Assessment

The implementation is customizable primarily through **template editing**, not through a plugin registry or service API. The cleanest extension boundary is `skills/knowledge-system-bootstrap/templates/` plus the file map in `TEMPLATE_TO_TARGET`. Adding new platform behavior or generated assets usually requires touching:

1. `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`
2. one or more template files under `skills/knowledge-system-bootstrap/templates/`
3. docs (`README.md`, `UNIVERSAL.md`, `SKILL.md`)
4. tests and smoke workflow

Modification difficulty is moderate: the code is small and stdlib-only, but many behaviors are coupled through generated-file conventions, frontmatter rules, manifest schema, and the expectation that agents follow the repo-level session protocol.

### Fastest Path to First Successful Run

The shortest realistic path is:

1. `python3 scripts/bootstrap_knowledge_system.py <target-repo> "<Project Name>"`
2. `cd <target-repo>`
3. `python3 scripts/init_raw_root.py`
4. `python3 scripts/wiki_check.py`
5. `python3 scripts/raw_manifest_check.py`

If raw files already exist locally, the next practical path is:

1. set `PROJECT_RAW_ROOT`
2. `python3 scripts/ingest_raw.py`
3. `python3 scripts/stale_report.py`
4. `python3 scripts/delta_compile.py --write-drafts`

Minimum hard dependency is Python 3; Git and Bash are needed for upgrade/install flows, not for initial bootstrap.

### Minimal Manual Setup Path

There is a meaningful manual path because the repo is fundamentally a file generator. Without plugin/skill tooling, the direct entry point is the public wrapper `scripts/bootstrap_knowledge_system.py`. That wrapper is the supported interface; `README.md` explicitly says not to invoke the skill-internal bootstrap directly, though `examples/demo-project/README.md` still does so.

Minimal manual setup:

1. clone this repo
2. run `python3 scripts/bootstrap_knowledge_system.py <target> "<name>"`
3. in the target repo, create the raw root with `python3 scripts/init_raw_root.py`
4. optionally export `PROJECT_RAW_ROOT`
5. use the generated `scripts/*.py` directly

No container stack, daemon, database, or MCP server is required for the base workflow.

### Operational Complexity Snapshot

Setup complexity is low-to-moderate. Runtime fragility is mostly **protocol fragility**, not infrastructure fragility: if users fail to register raw files, skip writeback, or let docs drift, the system degrades. Operational coordination is simple because almost everything is synchronous CLI work over local files. Observability is script-output-centric: reports are written to `manifests/*.md` and validation failures are emitted to stdout/stderr. Debugging complexity is moderate because behavior is spread across templates, generated outputs, and repo-level AI instructions rather than a single runtime process.

The repo appears **maturing but still somewhat exploratory**: there is a substantial automated test suite in `tests/` and a smoke workflow in `.github/workflows/wiki-lint.yml`, but documentation and version metadata still show drift.

## 1. Repository Purpose

### Actual implemented purpose

Observed behavior: this repository packages a reusable method for turning project knowledge into a maintained repo-local wiki. It does that by scaffolding:

- wiki pages under `docs/wiki/`
- raw-source manifests under `manifests/`
- validation and maintenance scripts under `scripts/`
- AI-specific session protocol/config files in repo root
- optional Claude plugin and Codex skill packaging

The repo is therefore a **distribution vehicle for a knowledge-system scaffold**, not the knowledge system instance itself.

### Relationship to the conceptual description

The Karpathy gist describes an abstract three-layer idea: raw sources, wiki, schema. This repo concretizes that into:

- **raw**: a local sibling directory created by `init_raw_root.py`, referenced through `PROJECT_RAW_ROOT`
- **wiki**: markdown files in `docs/wiki/`
- **schema/protocol**: AI config files plus `docs/wiki/SCHEMA.md`, manifest schema in `manifests/raw_sources.meta.json`, and validator scripts

The implementation narrows the idea in important ways:

- it is explicitly **filesystem-first**, not database- or service-based
- it treats the wiki as a repo artifact to be updated by agents during normal coding sessions
- it introduces deterministic local preprocessing for raw files before any LLM synthesis
- it refuses silent auto-recompilation; stale work becomes **drafts**, not automatic wiki mutation

### What problem the repo is really solving

The repo solves **durable project memory for AI-assisted software work**. More specifically, it solves:

- session-to-session loss of context
- uncontrolled raw/binary artifacts in Git repos
- lack of provenance for claims written into markdown
- manual manifest maintenance
- stale wiki pages that no one notices

### Target use cases and scope boundaries

Target use cases are medium-scale project contexts where wiki pages remain readable directly by an LLM and where raw evidence exists as PDFs, spreadsheets, images, archives, or other non-code files. The repo is not a general wiki engine, not a hosted SaaS, not a knowledge graph platform, and not an ingestion service. Its scope ends at scaffolding, local file processing, validation, and workflow packaging.

## 2. High-Level System Model

This project is best modeled as a **compile-first, filesystem-governed knowledge workflow runtime**. The dominant architectural identity is a combination of:

- **template-driven scaffolder** at bootstrap time
- **synchronous CLI maintenance toolkit** during normal operation
- **instruction-driven agent protocol layer** through generated AI config files

The runtime topology is simple:

1. the public repo distributes templates and wrappers
2. bootstrap copies and parameterizes them into another repo
3. the target repo becomes the actual operating environment
4. local raw files live outside Git
5. agents/users repeatedly read wiki state, process work, and write back durable conclusions

The primary execution paradigm is not event-driven or message-driven. It is **directive and pull-based**: an agent or user explicitly invokes a script or follows a session protocol step. State is mostly files, not in-memory process state. Coordination authority is centralized in whichever script or agent is currently running; there is no long-lived orchestrator.

The project’s behavioral intelligence resides in a few places:

- `ingest_raw.py` for local raw interpretation and manifest/lock maintenance
- `stale_report.py` for freshness classification
- `delta_compile.py` for draft-oriented recompilation triage
- `provenance_check.py` and `wiki_check.py` for invariant enforcement
- the generated root config files for session-start/session-end behavior

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Owning implementation | Execution semantics | Limits / extension implications |
|---|---|---|---|---|
| Persistent wiki between sessions | Implemented | generated `docs/wiki/*`, root config templates, `UNIVERSAL.md` | Agents are instructed to read `index.md`, `current-status.md`, `log.md` first and write back durable knowledge | Depends on agent discipline; no automatic daemon enforces writeback |
| Raw source tracking outside Git | Implemented | `scripts/init_raw_root.py`, `manifests/raw_sources.csv`, `scripts/ingest_raw.py` | Raw files live in sibling/local directory; manifest tracks metadata and compile status | Path resolution depends on `PROJECT_RAW_ROOT` or default sibling naming |
| Provenance from wiki page to raw source | Implemented | `docs/wiki/SCHEMA.md`, `provenance_check.py`, `stale_report.py` | Wiki frontmatter stores `source`, `source_hash`, optional `compiled_from`; scripts resolve against manifest and raw files/lock | Multi-source provenance is lightweight string/list parsing, not a rich graph |
| Incremental ingestion | Implemented | `ingest_raw.py` | Walk raw tree, hash files, classify kind, update manifest, write `raw_index.json` and `intake_report.md` | Parsing is intentionally structural/local, not semantic |
| Contradiction/staleness detection | Partially implemented | `stale_report.py`, `provenance_check.py` | Detects stale hashes, unresolved sources, archived refs, and uncompiled raw | Does not semantically compare wiki claims; only structural/provenance freshness |
| Auto-maintained wiki health | Partially implemented | `wiki_check.py`, `raw_manifest_check.py`, `untracked_raw_check.py`, `wiki_size_report.py` | Structural validation scripts and CI-safe runtime split | No centralized scheduler; health checks run only when invoked |
| Automatic recompilation | Explicitly constrained | `delta_compile.py` | Writes draft stubs with frontmatter and source metadata | Intentionally avoids overwriting live pages |
| Cross-platform AI integration | Implemented | templates for `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.windsurfrules`; `.claude-plugin/*`; `commands/*`; `SKILL.md` | Same workflow packaged for different agent products | Adding a new platform requires new template/docs/tests rather than registration |
| Upgrade path for existing bootstrapped repos | Implemented | `scripts/upgrade_knowledge_system.py`, `scripts/upgrade.sh` | Bootstraps a temp project from latest repo, overwrites only safe files, prints config diffs | Safe file list is hard-coded; template/version drift can leak through |
| Search/RAG runtime | Not implemented as core product | only discussed in docs, no active search service | `wiki_size_report.py` quantifies when RAG may become useful | Search engine integration is aspirational/manual |

## 4. Architecture and Component Analysis

### 4.1 Public distribution layer

Files: `README.md`, `UNIVERSAL.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `commands/*.md`, `skills/knowledge-system-bootstrap/SKILL.md`

This layer owns packaging and adoption, not core semantics. It explains how to install the scaffold, exposes plugin/skill metadata, and gives end-user entry points like `/llm-wiki-bootstrap` and `/llm-wiki-status`. The plugin command docs are thin wrappers around the same bootstrap/status flows; they do not introduce new runtime behavior.

### 4.2 Bootstrap engine

Files: `scripts/bootstrap_knowledge_system.py`, `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`

Responsibility boundary:

- root wrapper: stable public command
- skill bootstrap: actual generator

The internal bootstrap script owns:

- target file inventory via `TEMPLATE_TO_TARGET`
- variable substitution via `render(...)`
- overwrite/backup semantics via `backup(...)`
- dry-run/force/no-backup orchestration in `main()`

Architectural significance: this is the repo’s **distribution compiler**. It transforms repo templates into a working target-repo runtime.

### 4.3 Generated wiki/manifests/config skeleton

Files: `skills/knowledge-system-bootstrap/templates/wiki/*`, `templates/manifests/*`, `templates/configs/*`

This layer encodes stable conventions and invariants:

- `docs/wiki/SCHEMA.md` specifies frontmatter structure
- `templates/wiki/index.md` establishes index-centered navigation
- `templates/wiki/log.md` establishes append-only chronology
- `templates/wiki/current-status.md` establishes a summary page expected to be rewritten often
- `raw_sources.meta.json` defines schema version and allowed statuses

These are not just examples; `wiki_check.py` and `raw_manifest_check.py` operationalize their conventions.

### 4.4 Validation layer

Files: `wiki_check.py`, `raw_manifest_check.py`, `untracked_raw_check.py`, `wiki_size_report.py`, `runtime-profile.md`

This is foundational infrastructure. It owns structural correctness, schema integrity, leak detection, and reading-strategy sizing. Notable details:

- `wiki_check.py` parses markdown links rather than using substring checks, and explicitly ignores fenced/inline code
- `raw_manifest_check.py` supports legacy manifests without `raw_sources.meta.json` and forward-compatible skipping on future schema versions
- `untracked_raw_check.py` scans both repo and optional raw root for suspicious asset files not registered in the manifest
- `wiki_size_report.py` quantizes the project’s “wiki before RAG” claim into GREEN/YELLOW/RED/PURPLE buckets

### 4.5 Raw-ingest and freshness subsystem

Files: `ingest_raw.py`, `stale_report.py`, `provenance_check.py`, `delta_compile.py`

This is the main domain-semantic subsystem.

`ingest_raw.py` owns:

- directory walking and filtering
- kind detection
- structural parsing of csv/tsv/xlsx/xlsm/xls/docx/pptx/pdf/images/archives/plaintext
- content hashing
- duplicate detection
- manifest row creation/update
- lock-file generation (`manifests/raw_index.json`)
- intake report generation

`stale_report.py` and `provenance_check.py` together own freshness semantics, but with different operational modes:

- `provenance_check.py` is stricter and more binary; with `--ci`, it becomes structural-only
- `stale_report.py` is more diagnostic; it classifies fresh/stale/missing/unresolved/archived/new

`delta_compile.py` owns the system’s intentionally conservative recompilation stance: it creates draft stubs and reports instead of mutating canonical wiki pages.

### 4.6 Upgrade/export layer

Files: `scripts/upgrade_knowledge_system.py`, `scripts/upgrade.sh`, `templates/scripts/upgrade.sh`, `export_memory_repo.py`, `version_check.py`

This layer handles lifecycle and distribution maintenance.

- `upgrade_knowledge_system.py` rebuilds a temp project from latest templates and copies only a safe subset into an existing target repo
- `export_memory_repo.py` mirrors the “memory surface” into another checkout, deliberately excluding raw binaries and application code
- `version_check.py` polls GitHub releases at session start

The export script is noteworthy because it treats wiki/manifests/rules as a distinct portable artifact, reinforcing the idea that memory is a first-class deliverable.

### 4.7 Tests and example project

Files: `tests/*`, `.github/workflows/wiki-lint.yml`, `examples/demo-project/*`

Tests are closer to behavioral smoke coverage than unit-isolated logic. `tests/test_bootstrap.py` verifies generation, validators, runtime headers, provenance behaviors, and force/dry-run semantics. The GitHub workflow bootstraps a project, ingests fake raw, checks stale detection, draft generation, and demo structure. `examples/demo-project/` serves as a concrete “what good looks like” snapshot.

## 5. Execution Flow Analysis

### 5.1 Bootstrap flow

1. User runs `scripts/bootstrap_knowledge_system.py`.
2. Wrapper resolves `REAL_SCRIPT` and replaces itself with the skill bootstrap via `os.execv(...)`.
3. The skill bootstrap parses CLI args, derives `slug` and `raw_root_name`, and builds substitution vars.
4. It iterates `TEMPLATE_TO_TARGET`, reads each template, applies sentinel replacement, and either creates, skips, marks unchanged, or overwrites with optional backup.
5. It prints created/skipped/overwritten lists and next steps.

This flow is synchronous, deterministic, and stateless except for file writes and `.bak.<timestamp>` copies.

### 5.2 Session-start flow in a bootstrapped repo

Observed in generated `AGENTS.md`, `CLAUDE.md`, and described in `UNIVERSAL.md`:

1. run `python3 scripts/version_check.py`
2. read `docs/wiki/index.md`
3. read `docs/wiki/current-status.md`
4. read `docs/wiki/log.md`
5. read more wiki pages only as needed

This is a crucial runtime behavior: the system’s “orchestrator” is partly the agent config file. Execution is governed by instructions embedded into the repo, not only by Python scripts.

### 5.3 Raw initialization flow

`init_raw_root.py` resolves a path from positional arg, `PROJECT_RAW_ROOT`, or default sibling raw-root name, creates the directory tree, and prints created paths. This is one-shot infrastructure bootstrap for evidence storage.

### 5.4 Raw ingestion flow

1. `ingest_raw.py` resolves raw root from CLI/env/default.
2. It loads `raw_sources.csv` and any prior `raw_index.json`.
3. It walks the raw tree, ignoring hidden/known junk directories.
4. For each candidate file, it computes a 16-char SHA-256 prefix and a structural summary.
5. It creates a new manifest row or updates an existing row, resetting status to `new` when content changed.
6. It tracks duplicates by content hash.
7. It marks missing manifest rows as archived.
8. It writes `raw_sources.csv`, `raw_index.json`, and `intake_report.md`.

Data movement is entirely file-to-file: raw files -> manifest rows / lock entries / report text.

### 5.5 Freshness and provenance flow

`stale_report.py`:

1. parses wiki frontmatter
2. resolves `source` and `compiled_from` against manifest rows
3. uses live raw hashes when raw root is available, or falls back to `raw_index.json`
4. classifies pages and writes `stale_report.md`
5. exits nonzero when stale/missing/unresolved/archived conditions exist

`provenance_check.py`:

1. parses frontmatter
2. skips `source: session` pages
3. requires `source_hash` for non-session pages
4. in normal mode, resolves manifest source paths and compares live hashes
5. in `--ci` mode, checks only for presence of `source_hash`

### 5.6 Delta compile flow

1. `delta_compile.py` re-reads wiki pages and manifest/lock state.
2. It identifies stale source-backed pages and manifest rows still `status=new`.
3. It chooses a target page using `compiled_into` or filename-derived slug.
4. If `--write-drafts` is set, it writes draft pages under `docs/wiki/drafts/`.
5. It writes `delta_compile_report.md`.

Important semantic choice: the system creates a **manual intervention queue** rather than an automatic rewrite loop.

### 5.7 Upgrade flow

1. `upgrade_knowledge_system.py` detects local version from generated script headers.
2. It clones or reuses a source repo snapshot.
3. It bootstraps a temporary project from latest templates.
4. It copies only hard-coded safe files into the target repo.
5. It prints changed config templates for manual merge rather than applying them.
6. It optionally adds newly introduced scripts.

This is effectively a self-hosted migration generator.

## 6. State and Persistence Model

### State ownership

The repo uses explicit file ownership boundaries:

- **Template state**: this distribution repo under `skills/knowledge-system-bootstrap/templates/`
- **Target wiki state**: `docs/wiki/*.md`
- **Manifest state**: `manifests/raw_sources.csv`, `raw_sources.meta.json`
- **Derived lock/report state**: `manifests/raw_index.json`, `intake_report.md`, `stale_report.md`, `delta_compile_report.md`
- **Agent protocol state**: root config files such as `AGENTS.md`
- **Raw evidence state**: external raw root outside Git

### Mutable vs immutable state

- raw files are treated as externally mutable but semantically authoritative
- wiki pages are mutable compiled consensus
- manifest rows are mutable metadata/index state
- lock and report files are mutable derived state
- templates in this repo are source-of-truth for future bootstraps/upgrades

### Persistence and serialization

Persistence is plain files:

- markdown for human-readable knowledge and reports
- CSV for manifest rows
- JSON for manifest schema and lock data
- environment variables for runtime path selection

There is no transactional store, no concurrency control, and no recovery journal beyond Git history and generated reports.

### Recovery semantics

Recovery is mostly operational:

- rerun bootstrap with `--force` for template regeneration
- rerun ingest/stale/delta scripts to rebuild derived state
- use `.bak.<timestamp>` files for overwrite rollback
- use Git for content history

## 7. Coordination and Control Semantics

Execution authority is **centralized per invocation**. Whichever actor is active controls the system:

- bootstrap script controls generation
- validator or ingest script controls a maintenance pass
- AI config file controls session protocol

Coordination is synchronous and directive:

- no scheduler
- no queue
- no event bus
- no daemon
- no background workers

Routing decisions are simple and mostly static:

- runtime headers in generated scripts split CI-safe vs dev-only execution
- `wiki_size_report.py` advises reading strategy, but does not enforce it
- config files route agent attention to `index.md`, `current-status.md`, `log.md`
- `delta_compile.py` routes raw changes to suggested target pages

Concurrency assumptions are social rather than technical. `UNIVERSAL.md` and the playbook explicitly describe page ownership, append-only `log.md`, and conflict resolution rules, but there is no lock manager or merge coordinator.

Failure propagation is explicit and shell-friendly: scripts return nonzero and print failures. Retry semantics are manual: rerun after fixing files or raw-path configuration.

## 8. Configuration and Environment Model

### Required configuration

For bootstrap:

- target directory
- human-readable project name

For raw-aware workflows:

- either `PROJECT_RAW_ROOT` or the default sibling raw-root path created from `__RAW_ROOT_NAME__`

### Optional configuration

| Variable | Used by | Role |
|---|---|---|
| `PROJECT_RAW_ROOT` | most raw-related generated scripts | points at local raw evidence tree |
| `LLM_WIKI_REPO_URL` | `scripts/upgrade_knowledge_system.py` | override upgrade source with local checkout or alternate repo |
| `LLM_WIKI_CI` | `provenance_check.py` | enables structural CI mode without `--ci` |
| `CODEX_HOME` | `scripts/install-codex-skill.sh` | overrides Codex skill install location |

### Runtime modes

The system has an explicit mode split documented in `runtime-profile.md`:

- **ci-safe**: `wiki_check.py`, `raw_manifest_check.py`, `untracked_raw_check.py`, `wiki_size_report.py`, `provenance_check.py --ci`
- **dev-only**: `ingest_raw.py`, `stale_report.py`, `delta_compile.py`, full `provenance_check.py`, `init_raw_root.py`, `version_check.py`, `export_memory_repo.py`

### Deployment assumptions

The expected deployment topology is local developer/operator machine + Git repo + local raw directory. Cloud CI validates only structural invariants unless raw files are mounted separately.

## 9. Operational Usage Model

### Canonical workflow

1. Bootstrap a target repo.
2. Initialize external raw root.
3. Start each working session by reading index/status/log.
4. Register new raw files, preferably through `ingest_raw.py`.
5. Compile durable findings into wiki pages while doing normal work.
6. Update `current-status.md` and append to `log.md`.
7. Run validators periodically.
8. If raw changed, use `stale_report.py` and `delta_compile.py --write-drafts`.
9. Optionally export the wiki surface into a separate memory repo.

### User interaction semantics

The system expects agents to behave more like maintainers than chatbots. `UNIVERSAL.md` and generated config files treat writeback as mandatory and explicitly say changing code without updating wiki is incomplete work.

### Development vs production reality

There is no “production service” here. Operational reality is repository maintenance discipline. The closest thing to production is a healthy bootstrapped repo with current wiki pages, a clean manifest, passing validators, and raw files managed outside Git.

## 10. Extension and Customization Architecture

There is no runtime plugin architecture inside the generated system. Extension happens by **changing the scaffold**.

### Primary extension boundaries

- `skills/knowledge-system-bootstrap/templates/` for generated file content
- `TEMPLATE_TO_TARGET` for file inventory
- AI platform config templates under `templates/configs/`
- Claude-specific commands under `templates/claude-commands/`
- workflow docs in `README.md`, `UNIVERSAL.md`, and `SKILL.md`

### How the system expects to evolve

Evidence from `CHANGELOG.md` suggests the intended evolution pattern is:

- add new generated scripts or wiki pages
- update the bootstrap map
- update CI smoke tests and pytest coverage
- carry changes forward through upgrade logic

### Boundary quality

The template boundary is reasonably clean after the v1.3.0 refactor, which moved embedded assets out of the bootstrap script into real files. However, the extension model is still somewhat leaky because docs, tests, file counts, and upgrade logic must stay manually synchronized.

## 11. Key Architectural Decisions and Tradeoffs

1. **Filesystem over service runtime.** Simpler to adopt, easier to diff, but no centralized coordination or rich querying.
2. **Raw outside Git, manifest inside Git.** Preserves repo hygiene and legal/storage sanity, but requires path configuration and dual-surface thinking.
3. **Structural local parsing before LLM use.** Cheap and deterministic, but intentionally shallow semantically.
4. **Draft-first recompilation.** Safer than auto-overwrite, but pushes more work back to humans/agents.
5. **Repo-level agent protocol.** Strongly influences behavior across tools, but relies on agents actually honoring those files.
6. **Template packaging across multiple AI platforms.** Broad adoption surface, but multiplies maintenance and doc-drift risk.
7. **Forward-compatible manifest schema skipping.** Friendly for CI, but can hide validator obsolescence until users notice the warning.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### Confirmed drift

1. **Bootstrap file counts disagree.** `README.md` and `.github/workflows/wiki-lint.yml` say 33 files; `CHANGELOG.md` and `docs/release-notes-v1.3.0.md` say 32; `SKILL.md` still says 30.
2. **`CONTRIBUTING.md` is stale.** It still claims templates are embedded string constants in the bootstrap script, but v1.3.0 moved them into real files under `skills/knowledge-system-bootstrap/templates/`.
3. **Version markers drift.** `templates/scripts/upgrade.sh` still carries `# llm-wiki-version: 1.2.2`, and `templates/scripts/ingest_raw.py` writes `"llm_wiki_version": "1.2.2"` into the lock payload even though the repo and most scripts are at 1.3.0.
4. **Example docs contradict supported entrypoint guidance.** `examples/demo-project/README.md` calls the skill-internal bootstrap script directly, while root docs explicitly say not to.

### Structural limitations

1. No real semantic contradiction analysis; stale detection is provenance-based only.
2. No built-in search engine beyond index-first navigation and optional future RAG guidance.
3. No concurrency control besides written collaboration rules.
4. No declared Python dev environment despite pytest-based tests.
5. Upgrade behavior depends on manually maintained safe-file lists and template diffs.

### Maturity assessment

- bootstrap engine: production-leaning and compact
- validation scripts: solid and focused
- raw ingest: practical and richer than docs alone suggest
- packaging/docs: useful but drift-prone
- contribution scaffolding: partially stale

## 13. Practical Usage Guide

### Minimal Viable Usage

Create a bootstrapped repo, initialize a raw root, and keep only three wiki pages hot at session start: `index.md`, `current-status.md`, `log.md`. This is enough to get durable session continuity without adopting the full raw-ingest pipeline immediately.

### Operational Assumptions

- operator has local filesystem access
- operator can run Python 3 scripts
- raw evidence can live outside Git
- project is small/medium enough that wiki-first reading still makes sense
- team is willing to follow writeback discipline

### Canonical Workflow

1. bootstrap
2. initialize raw root
3. ingest new raw when it appears
4. compile findings into wiki pages
5. keep `current-status.md` and `log.md` fresh
6. run structural and freshness checks
7. generate drafts for stale/new raw instead of freehand recompile starts

### Advanced Usage

- use `wiki_size_report.py` to decide when direct full reads stop being efficient
- use `export_memory_repo.py` to mirror memory surface elsewhere
- use Claude plugin or Codex skill packaging instead of manual bootstrap
- use upgrade tooling to refresh validators/scripts in existing projects

### Extension Workflow

Edit templates first, then update `TEMPLATE_TO_TARGET`, then update docs/tests/CI/demo to keep the scaffold coherent. When adding a new AI platform, treat it as a cross-cutting change touching templates, docs, and smoke coverage.

### Debugging Workflow

Useful sequence:

1. `wiki_check.py` for wiki structural breakage
2. `raw_manifest_check.py` for schema/index breakage
3. `untracked_raw_check.py` for leaked assets
4. `provenance_check.py` / `stale_report.py` for freshness problems
5. inspect generated reports under `manifests/`

### Observability

Observability is file- and stdout-based:

- runtime headers in scripts advertise intended execution context
- `manifests/intake_report.md`, `stale_report.md`, and `delta_compile_report.md` are durable diagnostics
- exit codes communicate pass/fail for automation

### Failure Modes

- raw root misconfigured or missing -> ingest/provenance/stale tooling degrades or fails
- wiki pages missing frontmatter -> `wiki_check.py` fails
- source-backed pages without `source_hash` -> provenance tooling fails
- raw files added without manifest registration -> `untracked_raw_check.py` fails
- docs/template count drift -> contributor confusion and possible test failures

### Performance Considerations

The code is designed for local, moderate-scale use. Expensive paths are raw-tree walks, hashing, and workbook/archive inspection in `ingest_raw.py`. No batching or parallelism is implemented. `wiki_size_report.py` explicitly treats very large wikis as a sign to introduce secondary retrieval, not to abandon the wiki.

## 14. Project Navigation Guide

### Highest-value reading order

1. `README.md` — repo identity and supported entrypoints
2. `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py` — authoritative file inventory and bootstrap semantics
3. `skills/knowledge-system-bootstrap/templates/scripts/ingest_raw.py`
4. `templates/scripts/stale_report.py`
5. `templates/scripts/delta_compile.py`
6. `templates/scripts/provenance_check.py`
7. `templates/scripts/wiki_check.py`
8. `templates/wiki/SCHEMA.md` and `templates/wiki/runtime-profile.md`
9. `tests/test_bootstrap.py`
10. `.github/workflows/wiki-lint.yml`

### Semantic centers

- `skills/knowledge-system-bootstrap/templates/scripts/ingest_raw.py`
- `skills/knowledge-system-bootstrap/templates/scripts/stale_report.py`
- `skills/knowledge-system-bootstrap/templates/scripts/delta_compile.py`
- `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`

### Where abstractions become concrete

- abstract “schema” becomes concrete in `templates/configs/*`, `templates/wiki/SCHEMA.md`, and `raw_sources.meta.json`
- abstract “persistent wiki” becomes concrete in generated `docs/wiki/*`
- abstract “ingest” becomes concrete in `ingest_raw.py` and `raw_index.json`
- abstract “keep knowledge current” becomes concrete in `stale_report.py`, `provenance_check.py`, and `delta_compile.py`

### Entry points

- public bootstrap: `scripts/bootstrap_knowledge_system.py`
- upgrade: `scripts/upgrade_knowledge_system.py`, `scripts/upgrade.sh`
- plugin commands: `commands/llm-wiki-bootstrap.md`, `commands/llm-wiki-status.md`
- core templates: `skills/knowledge-system-bootstrap/templates/`

## 15. Concise Deep Technical Synthesis

`LLM-wiki` is a **repo-scaffolding system for turning AI-assisted project work into a maintained, provenance-aware markdown memory layer**. Its architecture is a compact template compiler plus a generated script toolchain. It is not trying to be an autonomous knowledge platform; it is trying to make durable project memory cheap enough that humans and coding agents will actually keep it current.

The distinctive design choice is that it treats **knowledge maintenance as normal repo work**: wiki pages, manifests, agent rules, and validation scripts live alongside code, while raw evidence stays outside Git. The best mental model is “a compile pipeline for project memory, implemented as files and conventions.” It appears optimized for small teams or solo developers comfortable with Git, Python scripts, and disciplined AI workflows, and less optimized for organizations wanting centralized orchestration, rich search, or strict multi-user coordination controls.
