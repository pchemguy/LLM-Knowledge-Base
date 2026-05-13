---
repo: NicholasSpisak/second-brain
---

# Second Brain Onboarding Report

## SYNOPSIS

### Implementation Identity

This repository is **not an application runtime** in the usual sense. It is a **skill/specification package** for standing up and operating an LLM-maintained Obsidian vault that follows the "LLM Wiki" pattern described in `docs/llm-wiki.md`. The dominant architecture is **prompt-governed, file-oriented orchestration**:

- the **control plane** is the skill markdown in `skills/`;
- the **data plane** is the generated vault (`raw/`, `wiki/`, `output/`);
- the only shipped executable automation is `skills/second-brain/scripts/onboarding.sh`.

The primary semantic center is the rule set in `skills/second-brain/references/wiki-schema.md` plus the operation-specific skills:

- `skills/second-brain/SKILL.md`
- `skills/second-brain-ingest/SKILL.md`
- `skills/second-brain-query/SKILL.md`
- `skills/second-brain-lint/SKILL.md`

### Quick Adaptation Assessment

The repository is easy to adapt at the **instruction/schema layer** and hard to adapt at the **automation layer** because most behavior is delegated to whichever coding agent consumes the skills.

- **Easy**: change wiki conventions, page formats, operating rules, supported agent templates, and workflow expectations.
- **Coupled**: all flows assume the vault invariant `raw/` + `wiki/` + `output/`, with `wiki/index.md` and `wiki/log.md` treated as mandatory control files.
- **Extension difficulty**: low for prompt changes, moderate if you want actual enforcement/automation because almost all behavior currently lives in prose rather than code.

### Fastest Path to First Successful Run

The shortest realistic path is the skill-based workflow documented in `README.md`:

1. Install via `npx skills add NicholasSpisak/second-brain`.
2. Invoke `/second-brain` inside a supported agent.
3. Let the skill scaffold a vault and generate one or more agent config files from `skills/second-brain/references/agent-configs/`.
4. Open the vault in Obsidian.
5. Drop or clip a source into `raw/`.
6. Run `/second-brain-ingest`.

This path requires:

- an external agent that supports skills;
- Obsidian;
- Node.js for `npx skills add`;
- in practice, **bash** and **python3** if the onboarding shell script is used directly.

### Minimal Manual Setup Path

There is a meaningful manual path because the real runtime state is just a folder tree plus markdown conventions:

1. Run `bash skills/second-brain/scripts/onboarding.sh <vault-path>`.
2. Manually create the desired agent config file at the vault root (or `.cursor/rules/`) from the relevant template under `skills/second-brain/references/agent-configs/`.
3. Insert the schema from `skills/second-brain/references/wiki-schema.md` starting at `## Architecture`, as the templates instruct.
4. Open the folder as an Obsidian vault and start operating the ingest/query/lint workflows manually through the agent.

The manual path is viable because there is no application service to start, but it is incomplete without an agent config file because the repo does not ship a standalone ingest/query/lint engine.

### Operational Complexity Snapshot

- **Setup complexity**: moderate. The repo itself is simple, but the real system depends on an external agent, Obsidian, and operator discipline.
- **Runtime fragility**: moderate. There is little hard enforcement; correctness depends on the agent following the schema and workflows exactly.
- **Infrastructure**: light. No database, server, queue, or build system.
- **Debugging**: mostly manual inspection of markdown state (`wiki/index.md`, `wiki/log.md`, frontmatter, backlinks).
- **Maturity**: onboarding scaffold is concrete and tested (`tests/test_onboarding.sh`); ingest/query/lint are operational specs, not automated implementations.

## 1. Repository Purpose

### Actual Implemented Purpose

Observed purpose: this repo packages a reusable **LLM-operated second-brain workflow** for Obsidian. The repo does not implement a knowledge engine that autonomously runs in the background; it packages the rules, templates, and one scaffold script required for a coding agent to behave like a wiki maintainer.

Concrete evidence:

- `README.md` describes installation through `npx skills add ...` and four skills.
- `docs/REQUIREMENTS.md` names four operations: onboarding, ingest, query, lint.
- `docs/llm-wiki.md` provides the abstract pattern the repo instantiates.
- `skills/second-brain/references/wiki-schema.md` defines the actual vault contract.

### Relationship to the Conceptual Description

The conceptual idea provided by the user describes an LLM that incrementally compiles raw sources into a persistent wiki instead of answering from raw documents each time. This repository operationalizes that idea in a narrower, more concrete way:

- **raw sources** become `raw/`;
- **persistent wiki** becomes `wiki/` with typed subdirectories;
- **schema/governing document** becomes an agent config generated from the templates and `wiki-schema.md`;
- **operations** become four skills.

### What Problem the Repo Is Really Solving

It solves the problem of **standardizing agent behavior** around an Obsidian-based personal knowledge base. The core value is not "search documents" but "make a coding agent reliably maintain a compounding markdown wiki with repeatable conventions."

### Target Use Cases

Implemented target use cases, based on the docs and workflows:

- personal/research knowledge accumulation through file ingest;
- structured wiki maintenance inside Obsidian;
- multi-agent reuse of the same vault conventions through generated configs;
- lightweight query and synthesis without deploying RAG infrastructure.

### Scope Boundaries

Out of scope in the current repo:

- autonomous background processing;
- database-backed retrieval;
- a dedicated search/index service;
- a real linter implementation;
- a non-agent UI beyond Obsidian;
- guaranteed consistency enforcement.

## 2. High-Level System Model

This system is best understood as a **prompt-governed file compiler for knowledge**, not as an app server and not as a library.

The dominant architectural identity is **orchestration-by-instruction**:

- the human curates sources and steers questions;
- the agent executes the workflows described in the skill files;
- the vault directories and markdown files act as the persistent state machine;
- Obsidian is the viewing and navigation frontend.

The main behavioral intelligence lives in the **schema and workflow documents**, especially:

- `skills/second-brain/references/wiki-schema.md`
- `skills/second-brain-ingest/SKILL.md`
- `skills/second-brain-query/SKILL.md`
- `skills/second-brain-lint/SKILL.md`

`skills/second-brain/scripts/onboarding.sh` is infrastructural, not semantic. It creates folders and seed files, but it does not embody the knowledge-graph semantics. Those semantics live in the rules: never edit `raw/`, always update `wiki/index.md`, append to `wiki/log.md`, use `[[wikilinks]]`, and encode metadata in frontmatter.

So the mental model is:

> **A markdown vault whose behavior is governed by a rulebook that external agents execute.**

The system's complexity therefore sits in:

1. schema design;
2. operation semantics;
3. consistency maintenance across markdown pages;
4. cross-agent portability of the same rules.

## 3. Conceptual Capability Mapping

| Conceptual capability | Implementation status | Owning files | Execution semantics | Limits / implications |
|---|---|---|---|---|
| Persistent wiki between raw docs and answers | Implemented as schema + workflow | `docs/llm-wiki.md`, `skills/second-brain/references/wiki-schema.md` | Agent reads raw sources, writes/update wiki pages, then answers from wiki first | No runtime enforcement; depends on agent compliance |
| Vault initialization | Partly automated | `skills/second-brain/SKILL.md`, `skills/second-brain/scripts/onboarding.sh` | Skill collects parameters; shell script scaffolds directories and seed files | Shell script does not itself generate config files or install tools |
| Agent config generation | Specified, template-driven | `skills/second-brain/SKILL.md`, `skills/second-brain/references/agent-configs/*.md` | The onboarding skill is expected to read templates, replace placeholders, and write per-agent config files | No standalone generator program exists |
| Source ingest into multiple wiki pages | Specified only | `skills/second-brain-ingest/SKILL.md` | Read source, discuss takeaways, create/update source/entity/concept pages, add links, update index/log | Requires interactive agent behavior; no executable ingest engine |
| Query against compiled knowledge | Specified only | `skills/second-brain-query/SKILL.md` | Read `wiki/index.md`, optionally use `qmd`, read relevant pages, answer with `[[wikilink]]` citations | No packaged search implementation; `qmd` is external |
| Wiki health/linting | Specified only | `skills/second-brain-lint/SKILL.md` | Audit links, orphans, contradictions, stale claims, missing pages, index consistency | No automated linter ships in repo |
| Multi-agent compatibility | Implemented as templates and conventions | `skills/second-brain/references/agent-configs/*.md`, `docs/REQUIREMENTS.md` | Same schema is emitted into Claude/Codex/Cursor/Gemini config formats | Contract consistency is manual/prompt-based |
| Tool augmentation | Lightly implemented | `skills/second-brain/references/tooling.md`, `onboarding.sh` | Script checks tool availability; skills reference them conceptually | Tools are optional and not vendored |

### Observation vs Inference

- **Observed**: the repo contains one concrete script, four skills, shared schema, and agent templates.
- **Inferred**: the author treats the skill package itself as the product, with external agents providing execution.
- **Speculative**: a richer future implementation might add true automation for ingest/query/lint, but no such engine exists here.

## 4. Architecture and Component Analysis

### 4.1 Documentation Layer

Files:

- `README.md`
- `docs/REQUIREMENTS.md`
- `docs/llm-wiki.md`

Responsibility:

- communicate the pattern, user-facing workflow, and implementation intent;
- map the abstract LLM Wiki idea to this specific repo.

Boundary:

- strong for product framing;
- weak as runtime evidence except where later confirmed by skill files and script behavior.

Notable coupling:

- the README assumes behaviors ("wizard generates config files", "query uses qmd automatically") that are only partially realized in code and actually depend on agent execution.

### 4.2 Shared Schema / Contract Layer

Primary file:

- `skills/second-brain/references/wiki-schema.md`

This is the actual contract that governs runtime behavior across agents. It owns:

- directory roles;
- page format and frontmatter;
- naming rules;
- index/log semantics;
- operating rules;
- lint frequency;
- optional tool usage.

Architectural significance:

- highest in the repo. It centralizes the invariants every operation depends on.

Leakiness:

- very high. Since there is no code enforcement, every consumer can violate the schema unless the agent follows it faithfully.

### 4.3 Operation-Specific Skill Layer

Files:

- `skills/second-brain/SKILL.md`
- `skills/second-brain-ingest/SKILL.md`
- `skills/second-brain-query/SKILL.md`
- `skills/second-brain-lint/SKILL.md`

Responsibility:

- define the orchestration loops for onboarding, ingest, query, and lint.

Behavioral role:

- these files are effectively the runtime control logic. They encode sequencing, required outputs, and operator interaction.

Sub-boundaries:

- **Onboarding** owns initial parameter collection and vault/bootstrap generation.
- **Ingest** owns transformation from raw sources into durable wiki pages.
- **Query** owns answer synthesis from the wiki-first search path.
- **Lint** owns integrity auditing and repair proposals.

Maturity:

- operationally detailed, but still **instructional artifacts** rather than executable subsystems.

### 4.4 Agent Template Layer

Files:

- `skills/second-brain/references/agent-configs/claude-code.md`
- `skills/second-brain/references/agent-configs/codex.md`
- `skills/second-brain/references/agent-configs/cursor.md`
- `skills/second-brain/references/agent-configs/gemini.md`

Responsibility:

- translate the shared schema into each agent's expected config file shape.

Architectural significance:

- medium. They are thin adapters, but they enable the repo's claim of multi-agent portability.

Important detail:

- these templates explicitly embed `{{WIKI_SCHEMA}}` from `wiki-schema.md`, which means the shared schema is the real source of truth and the templates are projection layers.

### 4.5 Executable Bootstrap Layer

Primary file:

- `skills/second-brain/scripts/onboarding.sh`

Responsibility:

- create the vault directory tree;
- seed `wiki/index.md` and `wiki/log.md`;
- detect optional tools;
- print JSON summary.

Architectural significance:

- low-to-medium. It is the only shipped executable, but it is infrastructural scaffolding rather than core domain logic.

Hidden coupling and assumptions:

- requires `bash`;
- invokes `python3` inside `check_tool()` to build JSON arrays;
- therefore has a hidden Python dependency not listed in `README.md`.

### 4.6 Test Layer

Primary file:

- `tests/test_onboarding.sh`

Responsibility:

- validate directory creation, idempotency, bootstrap file content, and JSON output.

Maturity signal:

- this is the strongest sign of production intent in the repo, but coverage is limited to onboarding.

Hidden assumptions:

- also depends on `bash`, `mktemp`, `grep`, and `python3 -m json.tool`.

## 5. Execution Flow Analysis

### 5.1 Install / Activation Flow

Observed path from `README.md`:

1. user installs the skill package via `npx skills add NicholasSpisak/second-brain`;
2. the host agent exposes four slash commands;
3. the user invokes `/second-brain` to create a vault;
4. subsequent work happens against the generated vault, not inside this repository.

Important implication:

- this repo is a **distribution package**. The actual operational state lives in the user's vault.

### 5.2 Onboarding Flow

Participating files:

- `skills/second-brain/SKILL.md`
- `skills/second-brain/scripts/onboarding.sh`
- `skills/second-brain/references/agent-configs/*.md`
- `skills/second-brain/references/wiki-schema.md`

Observed sequence:

1. The skill asks for vault name, path, domain, extra agents, and optional tools.
2. It runs `bash <skill-directory>/scripts/onboarding.sh <vault-path>`.
3. The script creates:
   - `raw/assets/`
   - `wiki/sources/`
   - `wiki/entities/`
   - `wiki/concepts/`
   - `wiki/synthesis/`
   - `output/`
4. The script creates `wiki/index.md` and `wiki/log.md` if absent.
5. The script checks whether `summarize`, `qmd`, and `agent-browser` are installed.
6. The skill is then supposed to generate config files by reading a template and injecting the schema.
7. The skill is also supposed to append a setup entry to `wiki/log.md`.

Observed/inferred split:

- **Observed**: steps 3-5 happen in shell script.
- **Observed**: steps 6-7 are specified in `skills/second-brain/SKILL.md`.
- **Not implemented in code**: there is no generator binary or shell function for steps 6-7.

### 5.3 Ingest Flow

Participating file:

- `skills/second-brain-ingest/SKILL.md`

Runtime semantics:

1. Identify target sources by explicit user selection or by comparing `raw/` against previous `ingest` entries in `wiki/log.md`.
2. Read the source completely, including important referenced images if needed.
3. Discuss takeaways with the user before writing.
4. Create a source page in `wiki/sources/`.
5. Create or update corresponding entity and concept pages.
6. Add cross-links via `[[wikilink]]`.
7. Update `wiki/index.md`.
8. Append an ingest entry to `wiki/log.md`.
9. Report created/updated pages and contradictions.

Execution shape:

- highly stateful, interactive, and multi-file;
- the log functions as the lightweight ingest ledger;
- the index functions as the lightweight retrieval index.

### 5.4 Query Flow

Participating file:

- `skills/second-brain-query/SKILL.md`

Runtime semantics:

1. Read `wiki/index.md`.
2. If available, use `qmd search "query terms" --path wiki/`.
3. Read relevant pages and follow links.
4. Only consult `raw/` if the wiki is insufficient.
5. Return answers with `[[wikilink]]` citations.
6. Offer to save high-value answers as `wiki/synthesis/*.md`, then update index/log.

Key operational philosophy:

- **wiki-first retrieval**. The wiki is treated as the compiled knowledge layer; raw sources are fallback material.

### 5.5 Lint Flow

Participating file:

- `skills/second-brain-lint/SKILL.md`

Runtime semantics:

1. enumerate wikilinks and broken references;
2. find orphan pages by absence of inbound links;
3. inspect contradictions and stale claims;
4. find missing pages and missing cross-references;
5. verify index consistency;
6. identify data gaps;
7. report by severity;
8. optionally fix and then append a lint entry to `wiki/log.md`.

Notable trait:

- linting is not syntax-oriented; it is **knowledge consistency auditing**.

### 5.6 Failure / Recovery Behavior

Observed:

- onboarding script is idempotent for `wiki/index.md` and `wiki/log.md`; it skips existing files.
- the log is append-only by rule.
- there is no transactional model. Partial edits across many wiki pages are possible if an agent is interrupted.

Inference:

- recovery is expected to be manual and file-based: inspect the log, re-run lint, and repair pages.

## 6. State and Persistence Model

### State Ownership

The system is entirely file-backed.

- `raw/` owns immutable source state.
- `wiki/` owns synthesized knowledge state.
- `output/` owns generated reports/artifacts.
- `wiki/index.md` owns navigational state.
- `wiki/log.md` owns chronological operation state.

### Mutable vs Immutable State

- **Immutable by contract**: `raw/`.
- **Mutable by design**: `wiki/`, `output/`, `wiki/index.md`.
- **Append-only by contract**: `wiki/log.md`.

### Metadata Model

Every wiki page must include frontmatter with:

- `tags`
- `sources`
- `created`
- `updated`

This turns each markdown page into a lightweight record with provenance and freshness metadata. There is no global schema validator.

### Persistence Semantics

- persistence is immediate and file-based;
- there is no separate cache or derived index beyond `wiki/index.md`;
- versioning is expected to come from git if the vault itself is in a repo, but this repo does not automate that.

### Synchronization Model

There is no lock or merge strategy. Multiple agents can theoretically work on the same vault because the templates share a common schema, but concurrent edits would rely on external file/version-control discipline.

## 7. Coordination and Control Semantics

### Execution Authority

Execution authority resides in the **host AI agent**, not in shell code.

- the shell script only scaffolds;
- the skills tell the agent how to behave;
- the agent decides how to inspect files, write pages, and sequence work.

### Control Topology

This is a **centralized, directive control model**:

- the user issues an operation (`/second-brain`, `/second-brain-ingest`, etc.);
- a single agent interprets that operation;
- the agent reads and writes the markdown state directly.

It is not event-driven, message-queue-driven, or reactive.

### Delegation and Routing

Routing is static and operation-based:

- onboarding routes to scaffold/config generation;
- ingest routes to wiki expansion;
- query routes to wiki retrieval/synthesis;
- lint routes to wiki integrity checks.

Within an operation, the main branching logic is content-dependent, e.g. whether a page already exists, whether `qmd` is available, or whether a topic warrants its own page.

### Failure Propagation

There is no coded retry, rollback, or cancellation control. Failures propagate as:

- missing tools;
- incomplete page updates;
- stale index/log state;
- inconsistent wiki structure.

The remediation strategy is procedural: inspect files, rerun the operation, or run lint.

## 8. Configuration and Environment Model

### Required Configuration

Documented prerequisites in `README.md`:

- Obsidian;
- an AI coding agent that supports skills;
- Node.js for install.

Operationally required but under-documented:

- `bash` for `skills/second-brain/scripts/onboarding.sh`;
- `python3` for its JSON array building and for `tests/test_onboarding.sh`.

### Agent Configuration Hierarchy

The effective config hierarchy is:

1. shared schema in `skills/second-brain/references/wiki-schema.md`;
2. per-agent template in `skills/second-brain/references/agent-configs/*.md`;
3. generated config file inside the user's vault (`CLAUDE.md`, `AGENTS.md`, `.cursor/rules/second-brain.mdc`, or `GEMINI.md`).

### Optional Tooling

Optional tools referenced in `tooling.md` and checked by `onboarding.sh`:

- `summarize`
- `qmd`
- `agent-browser`

Their role is augmentation, not core runtime dependency.

### Runtime Modes

No explicit runtime modes exist. The closest thing to modes is operational maturity:

- minimal mode: just index-driven wiki usage;
- augmented mode: add `qmd` for search and other tools for research/summarization.

## 9. Operational Usage Model

### Canonical Workflow

The actual intended loop is:

1. initialize a vault;
2. configure the agent with the generated rule file;
3. ingest sources one at a time into the wiki;
4. browse and inspect in Obsidian;
5. ask wiki-first questions;
6. save good answers back as synthesis pages;
7. periodically lint.

This is reinforced across `README.md`, `docs/REQUIREMENTS.md`, and all three operational skill files.

### User / Operator Role

The user is expected to:

- curate inputs into `raw/`;
- review takeaways during ingest;
- decide what analyses should be saved;
- run lint periodically;
- use Obsidian graph/backlinks as the primary browsing surface.

### Agent Role

The agent is expected to:

- maintain structure;
- preserve source immutability;
- update index/log consistently;
- propagate new knowledge into entity/concept pages;
- record contradictions instead of hiding them.

### Practical Reality

The repo assumes a relatively disciplined operator and a capable file-editing agent. This is not a push-button consumer workflow; it is a structured collaborative workflow between human and agent.

## 10. Extension and Customization Architecture

### Primary Extension Surface

The main extension boundary is the instruction layer:

- modify `skills/second-brain/references/wiki-schema.md` to change universal rules;
- modify `skills/second-brain-*/SKILL.md` to change operation behavior;
- modify `skills/second-brain/references/agent-configs/*.md` to support new or changed agent formats;
- modify `skills/second-brain/references/tooling.md` to document new tool integrations.

### How the System Expects to Evolve

Observed design suggests this project expects evolution through:

- richer schema conventions;
- more agent targets;
- stronger operational guidance;
- optional external tool adoption as the wiki grows.

### Missing Extension Infrastructure

There is no:

- plugin registry;
- service container;
- code-based provider abstraction;
- runtime hook system.

Extension is currently textual and policy-based.

## 11. Key Architectural Decisions and Tradeoffs

### Markdown as the System of Record

**Decision**: keep all state in markdown files and use Obsidian as the viewing layer.

**Tradeoff**:

- gains inspectability, portability, git-friendliness;
- loses strong validation, transactions, and structured query ergonomics.

### LLM-as-Maintainer Instead of Embedded Retrieval Engine

**Decision**: compile knowledge into pages rather than answer from raw retrieval each time.

**Tradeoff**:

- gains persistent synthesis and cross-linking;
- shifts correctness risk into agent behavior and maintenance discipline.

### Single Shared Schema Across Agents

**Decision**: keep one canonical schema and project it into multiple config formats.

**Tradeoff**:

- gains cross-agent portability and conceptual consistency;
- risks drift if templates and schema evolve out of sync.

### Minimal Code, Heavy Prompting

**Decision**: encode most behavior in markdown instructions rather than executable code.

**Tradeoff**:

- makes the project lightweight and flexible;
- leaves important guarantees unenforced and harder to test.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Implemented vs Aspirational

Implemented with concrete artifacts:

- vault scaffold creation;
- seed files;
- tool presence checks;
- agent config templates;
- onboarding test script.

Aspirational or instruction-only:

- config file generation during onboarding;
- actual ingest engine;
- actual query engine;
- actual lint engine;
- automatic tool installation/verification as a standalone executable flow.

### 12.2 Documentation vs Implementation Drift

`README.md` says the wizard generates config files for each selected agent. That behavior exists in `skills/second-brain/SKILL.md`, but not in `onboarding.sh`. The real implementation is therefore split between shell and agent behavior, which can confuse someone expecting a single executable onboarding tool.

### 12.3 Hidden Runtime Dependencies

The repo documents Node.js, Obsidian, and an agent, but the actual executable/test surface depends on:

- `bash`
- `python3`

Evidence:

- `skills/second-brain/scripts/onboarding.sh` uses `python3 -c ...`;
- `tests/test_onboarding.sh` uses `python3 -m json.tool`.

In the current environment, `python3` was not available and test execution was additionally blocked by command permissions. That makes the onboarding automation less portable than the README suggests.

### 12.4 Lack of Enforcement

The correctness of the wiki depends on the agent remembering to:

- update the index;
- append the log;
- preserve frontmatter;
- note contradictions.

There is no validator beyond the proposed lint workflow.

### 12.5 Concurrency / Partial-Write Risk

Because ingestion is explicitly multi-file and may touch 10-15 pages, interrupted or concurrent runs can leave the wiki in a partially updated state. No repair mechanism exists beyond manual review and lint.

### 12.6 Repo Archaeology

The repo has untracked `.github/` onboarding metadata (`git status` showed `?? .github/`). These files appear to support meta-onboarding of the repo rather than the second-brain product itself. They are not part of the main implementation path and should be treated as repository workflow metadata, not product runtime.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Install the skills into a supported agent.
2. Run `/second-brain`.
3. Open the created vault in Obsidian.
4. Put one markdown article into `raw/`.
5. Run `/second-brain-ingest`.
6. Inspect `wiki/index.md`, the created source page, and any new entity/concept pages.

### Operational Assumptions

- operator is comfortable with file-based workflows and Obsidian;
- sources are curated manually;
- the wiki remains moderate enough that index-driven navigation is still useful, or `qmd` is added later;
- human review remains part of ingest, especially because the skill explicitly asks to discuss takeaways before writing.

### Canonical Workflow

The intended steady-state loop is:

1. clip or drop source into `raw/`;
2. ingest it;
3. inspect/update generated pages;
4. query the wiki;
5. save useful syntheses;
6. run lint after bursts of ingestion.

### Advanced Usage

The advanced features are mostly optional tool integrations and operating habits:

- use `qmd` once the wiki becomes large;
- use `summarize` to preprocess difficult sources;
- use `agent-browser` when built-in web tools are insufficient;
- maintain a multi-agent vault through multiple generated config files that all embed the same schema.

### Extension Workflow

To extend the system safely:

1. start with `skills/second-brain/references/wiki-schema.md`;
2. update operation-specific skill files if the changed rule affects ingest/query/lint behavior;
3. update the relevant agent template(s) if the config shape or prose wrapper needs to change;
4. if scaffold invariants changed, update `skills/second-brain/scripts/onboarding.sh` and `tests/test_onboarding.sh`.

### Debugging Workflow

Most effective inspection points:

1. `wiki/log.md` for operation history;
2. `wiki/index.md` for catalog drift;
3. page frontmatter for provenance/freshness problems;
4. backlinks / graph view in Obsidian for orphan detection;
5. the lint skill as a manual repair checklist.

### Observability

Observability is primitive and file-native:

- onboarding emits JSON summary;
- operational history is persisted to `wiki/log.md`;
- index coverage is visible in `wiki/index.md`;
- no metrics, tracing, or structured runtime logging are present.

### Failure Modes

Most likely failures:

- broken or missing wikilinks;
- index out of sync with page set;
- stale entity/concept pages after new source ingest;
- contradictory facts not recorded;
- missing config generation if the host agent fails to follow onboarding instructions;
- shell-script portability failures due to bash/python assumptions.

### Performance Considerations

There are no computational bottlenecks inside this repo because there is no long-running service. The practical scaling limit is **human/agent navigability of the wiki**, which is why `qmd` is introduced as the wiki grows past index-friendly size.

## 14. Project Navigation Guide

### Highest-Value Reading Order

1. `README.md` — user-facing framing and install flow.
2. `docs/REQUIREMENTS.md` — concrete blueprint and concept-to-implementation mapping.
3. `skills/second-brain/references/wiki-schema.md` — core contract and invariants.
4. `skills/second-brain/SKILL.md` — onboarding orchestration.
5. `skills/second-brain-ingest/SKILL.md` — main knowledge compilation workflow.
6. `skills/second-brain-query/SKILL.md` — retrieval/synthesis behavior.
7. `skills/second-brain-lint/SKILL.md` — integrity/audit semantics.
8. `skills/second-brain/scripts/onboarding.sh` — actual executable bootstrap.
9. `tests/test_onboarding.sh` — what the author considered important enough to verify.

### Semantic Centers

If you only need the real behavioral core, read these first:

- `skills/second-brain/references/wiki-schema.md`
- `skills/second-brain-ingest/SKILL.md`
- `skills/second-brain-query/SKILL.md`

That is where the system's "intelligence" actually lives.

### Where Abstractions Become Concrete

- abstract pattern -> `docs/llm-wiki.md`
- implementation blueprint -> `docs/REQUIREMENTS.md`
- concrete schema contract -> `skills/second-brain/references/wiki-schema.md`
- concrete executable scaffold -> `skills/second-brain/scripts/onboarding.sh`

### Where to Modify What

- change universal rules -> `skills/second-brain/references/wiki-schema.md`
- change onboarding questions/flow -> `skills/second-brain/SKILL.md`
- change ingest/query/lint behavior -> corresponding `skills/*/SKILL.md`
- change generated config format -> `skills/second-brain/references/agent-configs/*.md`
- change scaffolded directories/files -> `skills/second-brain/scripts/onboarding.sh` and `tests/test_onboarding.sh`

## 15. Concise Deep Technical Synthesis

This repository is fundamentally a **portable operating manual for an LLM-managed markdown knowledge base**. Its dominant pattern is **schema-driven orchestration through agent prompts**, with Obsidian as the read-side interface and a generated vault as the persistent state store. The project is strongest where it defines conventions and workflows, and weakest where it would need enforcement or automation: beyond the onboarding shell scaffold, the real runtime is the behavior of the external agent that consumes the skills.

The best mental model is:

> **a file-based knowledge compiler whose compiler logic is written mostly in prompts instead of code.**

It appears optimized for technically comfortable users who value transparent markdown artifacts, low infrastructure overhead, and cross-agent portability more than hard guarantees or automation depth.
