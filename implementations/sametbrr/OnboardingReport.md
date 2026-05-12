---
repo: sametbrr/llm-wiki-manager
---

# llm-wiki-manager Onboarding Report

## 1. Repository Purpose

### Actual implemented purpose

This repository is not a standalone application and not a wiki engine in the conventional sense. It is a Claude Code skill package that teaches an agent how to bootstrap, maintain, query, lint, and evolve a user-owned markdown wiki, plus four small Python scripts that handle deterministic structural edits. The actual product is the combination of:

- the skill contract in `SKILL.md`;
- the workflow/reference corpus in `references/`;
- the page/schema templates in `assets/templates/`;
- the helper CLIs in `scripts/`;
- a separate target wiki directory that the user operates on.

### Relationship to the conceptual description

The user prompt describes the abstract LLM wiki pattern. This repo operationalizes that idea as a disciplined Claude-facing package. The implementation does not automate semantic synthesis itself; it constrains the agent to do that work consistently and provides scripts for the mechanical bookkeeping that is easy to standardize.

### What problem the repo is really solving

The repo solves a narrower problem than “build an LLM-powered knowledge base.” It solves: “how do I make an LLM act like a reliable markdown wiki maintainer across sessions, without building a database-backed product?” Its design focus is eliminating drift in a filesystem-based wiki by enforcing:

- separation between raw sources and generated knowledge;
- append-only operational logging;
- index upkeep;
- cross-reference discipline;
- explicit contradiction handling;
- per-wiki schema capture in `CLAUDE.md`.

### Target use cases

Observed target use cases, grounded in README and references:

- personal research and “second brain” workflows;
- topic-deep-dive wikis that accumulate over weeks or months;
- book-companion or course-companion wikis;
- project wiki plus global wiki routing;
- LLM-assisted maintenance of an Obsidian-style markdown corpus.

### Scope boundaries

Implemented scope:

- scaffold a wiki directory layout;
- append standardized log entries;
- upsert index entries;
- perform mechanical linting and emit dated reports;
- teach an LLM the operating discipline for manual semantic work.

Not implemented here:

- document ingestion pipelines;
- embeddings, vector stores, or retrieval infrastructure;
- a daemon, web UI, or API server;
- automatic semantic propagation logic in code;
- automated multi-wiki link validation;
- full autonomous wiki authoring without an interactive LLM session.

## 2. High-Level System Model

This repository is fundamentally an orchestration-spec package with small deterministic filesystem tools attached. The dominant architectural identity is prompt-and-workflow centric rather than application-runtime centric.

The “machine” looks like this:

1. Claude Code loads `SKILL.md`.
2. The skill routes the user request into a mode such as bootstrap, ingest, query, update, lint, schema-evolve, teach, or multi-wiki.
3. The selected reference document in `references/` supplies the semantic operating procedure.
4. The LLM performs the high-judgment work by reading and editing the target wiki.
5. The helper scripts mutate the target wiki’s structural state where consistency matters: `index.md`, `log.md`, scaffold layout, and lint reports.

The primary semantic center is not the Python code. It is the combination of `SKILL.md` plus the workflow docs, because that is where routing, invariants, operational decisions, and distinction between local contradiction handling vs multi-page update propagation actually live.

The Python scripts are intentionally subordinate. They exist to make the semantic workflow safer by removing repetitive string-editing tasks from the LLM. This creates a split architecture:

- semantic authority: skill prompt + reference docs;
- structural authority: helper CLIs;
- durable domain state: the external wiki repository the user is building.

Operationally, this behaves like a lightweight human-in-the-loop workflow runtime for maintaining markdown knowledge bases.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Owning implementation | Execution semantics | Limits / tradeoffs |
| --- | --- | --- | --- | --- |
| Persistent wiki over raw sources | Implemented as workflow pattern | `SKILL.md`, `references/architecture.md`, `assets/templates/wiki-CLAUDE.md.tmpl` | Enforced by three-layer contract: `raw/`, `wiki/`, schema file | Persistence lives in the target wiki, not this repo |
| Bootstrap a new wiki | Implemented | `scripts/init_wiki.py`, `references/bootstrap-workflow.md` | Idempotent scaffolding of directories and starter files | Does not initialize git despite docs implying that |
| Source ingest and integration | Partially implemented in code, strongly implemented in workflow | `references/ingest-workflow.md`, page templates | LLM reads source, writes summary, updates related pages, then uses scripts for index/log | Semantic integration is manual LLM work, not scripted |
| Query against compiled knowledge | Implemented as agent workflow | `references/query-workflow.md` | Read `wiki/index.md`, drill into candidate pages, synthesize answer, optionally file back | No query engine or search backend bundled |
| Multi-page claim correction | Implemented as manual workflow | `references/update-workflow.md` | LLM sweeps pages semantically, shows diffs, applies per-page revise/dispute/annotate strategy | No dedicated update script; depends on agent rigor |
| Mechanical wiki lint | Implemented in code | `scripts/lint_wiki.py`, `references/lint-workflow.md` | Scans markdown files, writes dated report, optionally auto-tracks report in index/log | Catches mechanics only, not semantic drift |
| Schema evolution | Implemented as workflow | `references/schema-design-guide.md` | Update target wiki `CLAUDE.md` when conventions stabilize | No schema validator |
| Multi-wiki routing | Implemented as convention + workflow | `references/multi-wiki-routing.md`, `SKILL.md`, template comment block | Project `CLAUDE.md` declares external wiki path and routing rules; scripts must use explicit `--path` | No automated enforcement beyond agent compliance |
| Teaching / onboarding users to the pattern | Implemented as documentation workflow | `references/teaching-mode.md`, `references/philosophy.md` | Agent explains model, then optionally transitions to bootstrap | Purely prompt-driven |

## 4. Architecture and Component Analysis

### 4.1 Semantic control plane: `SKILL.md`

`SKILL.md` is the runtime contract for Claude Code. It defines:

- when the skill should trigger;
- the mode router;
- invariants that apply in every mode;
- the canonical wiki layout;
- the role of each script and template;
- the distinction between ingest, update, lint, and multi-wiki semantics.

Architecturally, this is the repo’s real entry point. If an engineer wants to understand what the system does, this is the highest-value starting file.

Important ownership:

- route selection;
- behavioral policy;
- guardrails around raw-vs-wiki ownership;
- bookkeeping obligations;
- escalation from local contradiction handling to update mode.

### 4.2 Workflow corpus: `references/`

These markdown files are not ancillary docs; they are modular behavioral subroutines for the skill.

Key files:

- `references/bootstrap-workflow.md`: zero-to-wiki flow.
- `references/ingest-workflow.md`: most operationally important flow.
- `references/query-workflow.md`: read-from-index-first query discipline.
- `references/update-workflow.md`: semantic change propagation model.
- `references/lint-workflow.md`: separates mechanical vs semantic health checking.
- `references/schema-design-guide.md`: explains the target wiki’s local contract.
- `references/multi-wiki-routing.md`: dual-target routing and absolute-link rules.
- `references/architecture.md` and `references/philosophy.md`: conceptual scaffolding.
- `references/teaching-mode.md`: user education path.

This corpus functions like a human-readable workflow engine. Each document encodes mode-specific sequencing, approval checkpoints, and behavioral heuristics.

### 4.3 Deterministic helper scripts: `scripts/`

These scripts are the only executable code in the package. They are deliberately stdlib-only and narrow in scope.

#### `scripts/init_wiki.py`

Responsibility:

- create target directories;
- place `.gitkeep` files;
- render starter `CLAUDE.md` from template;
- write fallback `README.md`, `wiki/index.md`, and `wiki/log.md` if missing.

Behavioral role:

- establishes the three-layer filesystem layout;
- keeps bootstrap idempotent;
- creates `wiki/reports/`, indicating reports are first-class artifacts.

Design note: it writes README and starter schema, but it does not run `git init` or commit anything.

#### `scripts/update_index.py`

Responsibility:

- find `wiki/index.md` under a target wiki root;
- normalize category names;
- compute the link target relative to `wiki/`;
- upsert entries by exact `(category, title)`;
- preserve a canonical section ordering with `Reports` included.

Hidden significance:

- it is the only mechanism that ensures index consistency is deterministic across sessions;
- its API (`--page-path`) defines the true script contract, which some reference examples currently violate.

#### `scripts/append_log.py`

Responsibility:

- enforce a constrained action vocabulary;
- validate single-line titles and ISO dates;
- append a heading of the form `## [YYYY-MM-DD] action | title`;
- optionally attach freeform details.

Architectural role:

- gives the wiki a machine-greppable audit trail;
- turns operations into a consistent chronological ledger.

#### `scripts/lint_wiki.py`

Responsibility:

- scan wiki markdown for broken links, raw-source references to missing files, orphan pages, index drift, stub pages, log gaps, and slug mismatches;
- exclude `wiki/index.md`, `wiki/log.md`, and `wiki/reports/` from content-page checks;
- render a dated markdown report;
- auto-track reports by shelling out to `update_index.py` and `append_log.py` when applicable.

Architectural significance:

- this is the only place where one helper script orchestrates others;
- it elevates reports into persistent state by default rather than ephemeral terminal output;
- it codifies the repo’s distinction between “mechanical health” and “semantic health”.

### 4.4 Templates: `assets/templates/`

These templates are the structural vocabulary for the target wiki.

Notable points:

- `wiki-CLAUDE.md.tmpl` establishes the local schema contract and embeds commented multi-wiki configuration.
- `source-summary.md.tmpl` includes frontmatter with a `raw:` pointer back to source files.
- `entity-page.md.tmpl` and `concept-page.md.tmpl` formalize `Disputes`, `Related`, and `Sources` sections.
- `comparison-page.md.tmpl` supports filed-back query artifacts rather than just ingest artifacts.
- `index.md.tmpl` and `log.md.tmpl` make structural files agent-readable and self-describing.

These templates matter because they define the page-shape invariants the workflow docs rely on later.

### 4.5 Example artifact: `assets/examples/healthy-wiki-tree.txt`

This file is not runtime-critical, but it reveals intended scale and maturity assumptions:

- dozens of source pages;
- entity and concept pages with multiple inbound links;
- recurring lint reports;
- occasional filed-back notes;
- schema revisions over time.

It serves as a reference “steady state” model for what success looks like.

### 4.6 Foundational vs semantic vs glue code split

- Foundational infrastructure: the four scripts and templates.
- Semantic orchestration: `SKILL.md` and workflow docs.
- Integration glue: the target wiki’s `CLAUDE.md`, `index.md`, `log.md`, and markdown links.
- Boilerplate/minimal scaffolding: README installation text and examples.

Meaningful complexity lives in the prompt/workflow layer, not in the code layer.

## 5. Execution Flow Analysis

### 5.1 Skill startup and mode selection

Observed flow:

1. Claude Code loads `SKILL.md` as a skill package.
2. The skill inspects the user request and local filesystem state.
3. It routes into one primary mode using the table in `SKILL.md`.
4. The agent reads the matching document in `references/` for mode-specific instructions.
5. The agent inspects the target wiki and performs the requested operation.

This is a dynamic, documentation-driven dispatch model. There is no code router implementing mode selection.

### 5.2 Bootstrap flow

Observed implementation path:

1. User asks to set up a wiki in a directory.
2. Agent confirms root and topic, per `references/bootstrap-workflow.md`.
3. Agent runs `scripts/init_wiki.py --path <root> --name <name> --topic <topic>`.
4. `init_wiki.py` creates `raw/`, `wiki/`, `wiki/sources/`, `wiki/entities/`, `wiki/concepts/`, `wiki/notes/`, and `wiki/reports/`, plus starter files.
5. Agent may optionally append a bootstrap log entry using `append_log.py`.

Important deviation: bootstrap docs mention git initialization as a default part of bootstrap, but the script performs no git operations.

### 5.3 Ingest flow

Observed control path:

1. User places a source into target `raw/` or provides content to be saved there.
2. Agent reads the source and surveys `wiki/index.md` plus related pages.
3. Agent optionally confirms a short ingest plan with the user.
4. Agent writes `wiki/sources/<slug>.md` using `source-summary.md.tmpl` conventions.
5. Agent updates or creates entity and concept pages referenced by the source.
6. Agent cross-links source summaries and synthesized pages.
7. Agent runs `update_index.py` for each new or substantially changed page.
8. Agent runs `append_log.py --action ingest` once to summarize the ingest.

The LLM owns all semantic branching inside this flow, including page-creation thresholds and contradiction detection.

### 5.4 Query flow

Observed control path:

1. User asks a question against accumulated wiki knowledge.
2. Agent reads `wiki/index.md` first.
3. Agent reads candidate pages and, if needed, linked source summaries or raw files.
4. Agent synthesizes an answer from wiki pages, not from raw sources directly.
5. If the answer is valuable, agent may create a new notes/comparison page.
6. Agent updates index for any filed-back page.
7. Agent appends a `query` log entry.

Architecturally, query is optimized for compiled knowledge reuse rather than ad hoc retrieval.

### 5.5 Update flow

Observed control path:

1. User or ingest process identifies a source-driven correction with multi-page impact.
2. Agent defines the claim under review and the source authority.
3. Agent semantically sweeps likely pages using index-guided reading.
4. Agent proposes scope and waits for approval.
5. Agent shows diff-before-write per page.
6. Agent applies one of three strategies per page: revise, disputes, or annotate.
7. Agent updates any misleading index summaries.
8. Agent appends a single `update` log entry summarizing the sweep.

This is the repo’s most sophisticated behavioral loop, but it is entirely prompt-driven.

### 5.6 Lint flow

Observed code path:

1. Agent runs `scripts/lint_wiki.py --path <root>`.
2. Script enumerates markdown pages under `wiki/`, excluding structural files and reports.
3. Script runs mechanical checks and renders markdown output.
4. Default path writes to `wiki/reports/lint-<today>.md`.
5. If tracking is enabled and report lives inside `wiki/`, `lint_wiki.py` invokes `update_index.py` and `append_log.py` via `subprocess.run`.
6. Agent then layers semantic review on top of the generated report.

This creates a hybrid execution model: code handles syntax/mechanics; agent handles meaning.

### 5.7 Multi-wiki flow

Observed workflow path:

1. Project `CLAUDE.md` declares an external wiki path and routing rules.
2. Agent reads both project and global schemas.
3. Agent decides the target wiki for a given write.
4. Scripts are always called with explicit `--path <wiki-root>`.
5. Cross-wiki links are absolute filesystem paths, never relative traversals.

The flow is operationally clear but not mechanically enforced by code.

## 6. State and Persistence Model

### Primary state

The primary durable state is outside this repository, in the target wiki managed by the user. This repo is a reusable controller package, not the state container.

### State-bearing artifacts in a managed wiki

- `raw/`: immutable source corpus.
- `wiki/`: mutable compiled knowledge.
- `wiki/index.md`: current content catalog.
- `wiki/log.md`: append-only operation timeline.
- `wiki/reports/*.md`: dated health snapshots.
- target `CLAUDE.md`: local schema and operating rules.

### Local state in this repo

Within this repository itself, persistent state is minimal and static:

- prompt text;
- reference workflows;
- templates;
- script logic.

### Mutation model

- `raw/` in a target wiki is treated as immutable.
- `wiki/` pages are mutable and agent-owned.
- `index.md` is upsert-oriented, not append-only.
- `log.md` is append-only.
- same-day lint reports overwrite at a stable filename, but new days accumulate longitudinal history.

### Synchronization and recovery

There is no concurrency model beyond filesystem writes. Recovery is expected to come from git in the target wiki, not from application-level rollback features. Multiple docs explicitly assume version control as the rollback mechanism, but the scripts do not enforce or manage it.

### Serialization model

All state is plain markdown plus optional YAML frontmatter. Script metadata is serialized directly into markdown text rather than sidecar JSON or a database.

## 7. Coordination and Control Semantics

### Where execution authority resides

Execution authority is split:

- routing and semantic decisions: Claude agent via `SKILL.md` and `references/`;
- deterministic structural edits: helper scripts;
- final approval for substantive edits: human user in several workflows.

This is a centralized coordination model with the LLM as orchestrator.

### Delegation pattern

The agent delegates only the narrowest possible tasks to scripts:

- scaffold layout;
- append structured log text;
- upsert index entries;
- compute lint results and write reports.

All high-judgment coordination remains in the agent loop.

### Synchronization style

The system is synchronous and request-driven. There are no queues, background jobs, or event streams. One user request maps to one interactive operation.

### Failure propagation

- Script failures surface as CLI errors.
- Semantic failures appear as workflow drift: stale pages, missed contradictions, or misrouted writes.
- Lint intentionally catches only mechanical failures and leaves semantic failures to the agent.

### Control topology

This is directive rather than reactive orchestration:

- user request initiates work;
- skill selects mode;
- agent performs guided sequence;
- scripts mutate structural files as substeps.

The closest analogy is a lightweight manual workflow engine where markdown and prompt documents are the control graph.

## 8. Configuration and Environment Model

### Required environment

Observed prerequisites:

- Claude Code as the intended host environment;
- Python 3 available on the machine;
- filesystem access to the target wiki root;
- optionally git for safe rollback and history.

There is no dependency manifest. All scripts rely on Python stdlib only.

### Configuration hierarchy

1. Skill-level defaults in `SKILL.md`.
2. Mode-specific rules in `references/*.md`.
3. Per-wiki overrides in the target wiki’s `CLAUDE.md`.
4. Per-command flags such as `--path`, `--stdout`, `--no-track`, `--stub-words`, and `--log-gap-days`.

### Required config in a target wiki

- `CLAUDE.md` at wiki root;
- `wiki/index.md` and `wiki/log.md` created by bootstrap;
- a category structure that the local schema documents.

### Optional config

- frontmatter conventions;
- custom category taxonomy;
- external wiki path declaration;
- lint cadence and ingest aggressiveness;
- absolute-path cross-wiki linking policy.

### Runtime modes

No code-level mode flag exists. Modes are inferred from natural language and local state.

## 9. Operational Usage Model

### Canonical workflow

1. Install this repo as a Claude skill package.
2. Start Claude in a research or project directory.
3. Bootstrap a target wiki there.
4. Drop sources into `raw/`.
5. Ingest sources one at a time or in batches.
6. Ask questions against the compiled wiki.
7. File back valuable answers.
8. Periodically lint and evolve the schema.

### Expected interaction pattern

This repo assumes a conversational human-in-the-loop workflow, not a fire-and-forget automation pipeline. Several reference docs explicitly call for short approval checkpoints before substantive edits.

### Development workflow for this repo itself

For maintainers of this repo, the main workflow is not “run the app”; it is:

- refine skill behavior in `SKILL.md`;
- refine per-mode guidance in `references/`;
- evolve templates;
- keep scripts aligned with docs;
- test scripts manually against a sample wiki.

### Production vs development distinction

There is no meaningful app deployment boundary. “Production” is the user actively operating a wiki with the skill. “Development” is editing this repository’s prompts and helper scripts.

## 10. Extension and Customization Architecture

### Primary extension surface: target wiki schema

The main extension mechanism is per-wiki `CLAUDE.md`. This lets each target wiki specialize:

- categories;
- naming conventions;
- page sections;
- ingest review style;
- query filing policy;
- routing rules.

### Package-level extension surfaces

- add or revise workflow documents in `references/`;
- add new page templates in `assets/templates/`;
- add new deterministic scripts in `scripts/`;
- update `SKILL.md` mode router and invariants.

### What this is not

It is not a plugin platform with dynamic discovery, interfaces, or registry loading. Extensions happen through convention and direct file edits.

### Effective extension contract

To add a new operational capability cleanly, the repo’s pattern implies four coordinated changes:

1. define or update the mode contract in `SKILL.md`;
2. add a dedicated workflow reference if the behavior is complex;
3. add a script only for deterministic mechanical work;
4. add or revise templates if the new capability emits durable wiki artifacts.

## 11. Key Architectural Decisions and Tradeoffs

### Markdown-first over application-first

The repo chooses a plain-filesystem, plain-markdown architecture instead of a service-backed knowledge system. Tradeoff:

- pro: transparent, git-friendly, editor-agnostic, low infrastructure;
- con: no strong invariants beyond what the agent and scripts preserve.

### Prompt-governed semantics over code-governed semantics

Semantic behavior is encoded in docs rather than program logic. Tradeoff:

- pro: easy to evolve, rich in nuance, keeps code small;
- con: correctness depends heavily on agent compliance and host model quality.

### Small scripts for structural discipline

The repo deliberately scripts only the brittle repetitive mutations. Tradeoff:

- pro: less code, lower maintenance, more adaptable workflows;
- con: important behaviors like update-mode sweep remain non-verifiable by code.

### Persistent artifacts over ephemeral answers

Both query answers and lint reports are designed to become durable files. This expresses a clear product philosophy: compound knowledge beats transient chat output.

### Per-wiki schema over universal schema

The system avoids enforcing one permanent taxonomy. Tradeoff:

- pro: adapts to personal research, projects, books, or team knowledge bases;
- con: cross-wiki interoperability is weak and depends on local discipline.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### Documented workflow vs code mismatches

Observed mismatches:

- `references/bootstrap-workflow.md` states `git init` happens during bootstrap, but `scripts/init_wiki.py` does not do this.
- `references/ingest-workflow.md` shows an `update_index.py` example using `--path "wiki/concepts/..."` where the actual script requires `--page-path` for the target page and uses `--path` for the wiki root.
- README says “nine detailed workflow documents” while the listed items in `references/` total ten files.

These are not cosmetic. They can mislead an agent or user during real operation.

### Semantic critical path is not executable code

The most important workflows, especially ingest/update/query, depend on prompt quality rather than testable code paths. This is an intentional design choice, but it limits automated verification.

### No automated tests

There are no unit tests or fixture-based integration tests for the scripts. Given the repo’s size this is survivable, but it raises regression risk around markdown parsing and report generation.

### Multi-wiki enforcement is advisory

Multi-wiki routing depends on `CLAUDE.md` conventions and agent obedience. There is no code-level validator that checks absolute cross-wiki links, declared external wiki paths, or incorrect routing behavior.

### Lint is deliberately incomplete

This is by design, but it creates an operational sharp edge: users may over-trust lint output even though substantive health remains manual.

### Host-environment coupling

The repository claims broad conceptual portability, but the implementation is explicitly optimized for Claude Code skill loading and `CLAUDE.md`. Adapting to other agents would require renaming and possibly reworking host-specific assumptions.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Install this repo where Claude Code can load it as a skill.
2. Open Claude in an empty or existing project directory.
3. Run bootstrap for a new wiki.
4. Put one source into `raw/`.
5. Ask the agent to ingest it.

At minimum, only Python 3 and a writable filesystem are required.

### Operational Assumptions

- the user is willing to curate sources;
- the user accepts markdown files as the durable knowledge representation;
- the LLM session can read and write the wiki directory;
- the user reviews important semantic edits rather than blindly trusting all output;
- git is available or at least desirable for rollback, though not enforced.

### Canonical Workflow

The stable loop is:

1. source arrives in `raw/`;
2. ingest compiles it into source/entity/concept pages;
3. query reuses compiled pages;
4. filed-back answers deepen the wiki;
5. lint catches structural damage and surfaces semantic follow-up opportunities;
6. schema evolves when patterns stabilize.

### Advanced Usage

- multi-wiki setups with project and global knowledge bases;
- filed-back comparison pages using `comparison-page.md.tmpl`;
- use of `wiki/reports/` as an accumulated health history;
- optional external search tooling such as qmd, which README mentions as future scale support.

### Extension Workflow

When extending this repo:

1. change the mode contract in `SKILL.md` if behavior changes globally;
2. add or revise the relevant `references/` file;
3. add a script only if the new behavior is deterministic enough to codify;
4. update templates if persistent page shapes change.

### Debugging Workflow

Best debugging order for maintainers:

1. inspect the relevant workflow doc in `references/`;
2. verify the CLI contract in the corresponding script;
3. compare with template expectations;
4. run scripts manually against a sample wiki;
5. check for drift between README, skill docs, and actual flags.

### Observability

Primary observability is textual:

- script stdout/stderr;
- `wiki/log.md` in the managed wiki;
- dated lint reports under `wiki/reports/`;
- git history in the target wiki.

There are no metrics, traces, or structured logs.

### Failure Modes

- index and log drift if scripts are skipped;
- stale or contradictory pages if semantic workflows are followed lazily;
- broken cross-wiki links that lint will not catch automatically;
- incorrect routing when external wiki rules are absent or ambiguous;
- user over-trust of prompt instructions that have drifted from script reality.

### Performance Considerations

Performance concerns are mostly human/LLM token costs rather than CPU cost. Scripts are trivial on repo-scale inputs. The expensive path is agent reading across many pages during ingest, query, or update. The repo intentionally avoids heavyweight infrastructure, which keeps compute cost low but shifts scale pressure onto prompt-based navigation.

## 14. Project Navigation Guide

### Best reading order

1. `SKILL.md`
2. `references/architecture.md`
3. `references/ingest-workflow.md`
4. `references/update-workflow.md`
5. `scripts/lint_wiki.py`
6. `scripts/update_index.py`
7. `assets/templates/wiki-CLAUDE.md.tmpl`
8. remaining reference docs as needed

### Highest-value files

- `SKILL.md`: true entry point and behavioral contract.
- `references/ingest-workflow.md`: most important user-facing semantic loop.
- `references/update-workflow.md`: strongest statement of what makes this more than simple RAG.
- `scripts/lint_wiki.py`: most architecturally rich script.
- `assets/templates/wiki-CLAUDE.md.tmpl`: strongest expression of per-wiki customization.

### Where abstractions become concrete

- Abstract idea becomes operational contract in `SKILL.md`.
- Mode narratives become stepwise procedures in `references/*.md`.
- Structural conventions become real files in `assets/templates/*.tmpl`.
- Repetitive bookkeeping becomes code in `scripts/*.py`.

### Semantic centers

The semantic centers are:

- `SKILL.md` mode routing and invariants;
- ingest/update/query/lint workflow docs;
- target wiki `CLAUDE.md` template.

### Low-signal areas

- the root README is useful for packaging and positioning, but it is not the best source of runtime truth;
- the example tree is illustrative but not normative.

## 15. Concise Deep Technical Synthesis

This project is a Claude Code skill package that turns the abstract LLM wiki idea into an operational discipline for managing markdown knowledge bases. Architecturally, it is a prompt-governed workflow runtime with a few deterministic filesystem CLIs attached, not an application server or indexing platform.

Its distinctive choice is to keep semantic intelligence in prompt/reference documents while codifying only the structural mutations that most benefit from consistency: scaffolding, index upkeep, log appends, and lint reports. The durable product is not this repository itself but the external wiki the user grows with it.

The repo appears optimized for technically comfortable users or teams who prefer transparent markdown-plus-git workflows over heavier software, and who are willing to let an LLM handle maintenance work while they retain source curation and editorial oversight.
