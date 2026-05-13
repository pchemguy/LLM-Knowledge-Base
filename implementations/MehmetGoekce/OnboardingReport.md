---
repo: MehmetGoekce/llm-wiki
---

# llm-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

`llm-wiki` is **not** a standalone wiki engine or CLI service. The concrete implementation is a **prompt-and-scaffolding kit for Claude Code**:

- `setup.sh` is the only executable subsystem in this repo. It bootstraps an external Logseq or Obsidian vault, writes `llm-wiki.yml`, creates starter wiki pages from templates, optionally initializes git in the vault, and copies `wiki.md` into a Claude Code commands directory.
- `wiki.md` is the runtime control plane. It encodes the `/wiki ingest`, `/wiki query`, `/wiki lint`, `/wiki status`, and `/wiki import` workflows as prompt instructions for Claude Code, not as shell/Python code.
- `templates/`, `docs/`, and `openspec/` define the schema, output shape, and intended behaviors that Claude is supposed to enforce when it operates on the wiki.

**Observed:** the repo contains one shell installer (`setup.sh`), templates, docs, and specs, but no parser, search indexer, linter, or query engine implementation.

**Inference:** the project’s behavioral intelligence intentionally lives in Claude Code’s instruction-following loop rather than in local deterministic code.

### Quick Adaptation Assessment

The system is easy to retarget at the **prompt/template level** and hard to extend at the **deterministic-runtime level**, because there is almost no deterministic runtime beyond setup:

| Area | Adaptation difficulty | Why |
|---|---:|---|
| Namespace/page-shape changes | Low | Edit `templates/` and schema docs/specs |
| Workflow tuning for ingest/query/lint | Medium | Edit `wiki.md`; behavior depends on Claude following the prompt |
| Adding a new wiki backend | Medium-high | Requires new template set, setup logic, and prompt rules |
| Adding reliable machine-enforced behaviors | High | Requires writing new executable tooling; current repo does not implement command logic programmatically |

Major coupling points are `setup.sh` ↔ template layout ↔ `wiki.md` conventions ↔ `llm-wiki.yml` key semantics.

### Fastest Path to First Successful Run

The shortest realistic path is:

1. Install **bash**, **python3**, and **git**.
2. Run `./setup.sh`.
3. Choose **Logseq** or **Obsidian**, point it at a vault/graph, accept or customize namespaces, optionally provide a Claude memory path, optionally initialize git, optionally copy the `/wiki` command into a Claude Code project.
4. Open the target vault in the wiki app and invoke Claude Code with `/wiki ingest "..."`.

Minimum runtime dependencies are external to this repo:

- Claude Code (paid Anthropic plan implied by `docs/faq.md`)
- a writable Logseq graph or Obsidian vault
- local filesystem access from Claude Code to the configured wiki path

### Minimal Manual Setup Path

There is a meaningful manual path because the runtime is file-based:

1. Create an empty Logseq graph or Obsidian vault.
2. Copy the appropriate starter pages from `templates\logseq\` or `templates\obsidian\` into the target vault, substituting dates/namespaces.
3. Create `llm-wiki.yml` from `config.example.yml`.
4. Copy `wiki.md` into `<project>\.claude\commands\wiki.md`.
5. Ensure Claude Code can reach the configured wiki root and, if used, the L1 memory directory.

**Constraint:** the repo does not provide a standalone non-Claude execution path for `/wiki` commands. Manual setup replaces `setup.sh`, but it does **not** replace Claude Code.

### Operational Complexity Snapshot

| Dimension | Assessment |
|---|---|
| Setup complexity | Low-moderate; one script plus external vault/app selection |
| Runtime fragility | Medium; correctness depends on Claude following prompt discipline |
| Coordination complexity | Low in code, medium in practice because wiki state is shared mutable markdown |
| Infra requirements | Minimal local tooling; no DB, containers, or package managers |
| Debugging difficulty | Medium-high; failures are often prompt/format/drift issues, not stack traces |
| Observability maturity | Low; no logs/metrics beyond dashboard pages, git history, and Claude output |

The primary semantic complexity lives in **`wiki.md` + schema conventions + L1/L2 routing**, not in the shell script.

## 1. Repository Purpose

The implemented purpose is to turn Karpathy’s abstract “LLM wiki” idea into a **Claude Code operating pattern** backed by markdown files in Logseq or Obsidian.

What the repo actually solves:

- scaffolding a wiki-shaped filesystem layout for two markdown UIs (`setup.sh`);
- defining a prompt contract that tells Claude how to ingest sources, answer questions, lint wiki health, and maintain page structure (`wiki.md`);
- codifying a specific semantic model: **L1 Claude memory for always-needed operational knowledge, L2 wiki pages for on-demand knowledge** (`README.md`, `docs/l1-l2-architecture.md`, `templates/*/Schema.md`).

Scope boundaries:

- **In scope:** bootstrap, schema definition, prompt workflows, documentation/specification, starter templates.
- **Not concretely implemented in code:** a search engine, parser, linter, migration engine, scheduler, background worker, or persistent service.
- **Externalized:** actual reasoning, retrieval, synthesis, conflict detection, and safe file mutation are delegated to Claude Code executing the prompt in `wiki.md`.

Relationship to the conceptual description:

- The repo adopts the gist’s three-layer idea (raw sources, wiki, schema) but specializes it for **Claude Code + Logseq/Obsidian** and adds the L1/L2 split as its main architectural differentiation.

## 2. High-Level System Model

At a systems level this is a **prompt-governed, file-oriented knowledge maintenance runtime** with one bootstrap script.

Dominant architectural identity:

- **Orchestration-centric:** Claude Code is expected to orchestrate all wiki work by following `wiki.md`.
- **State-externalized:** durable state lives in markdown files, a YAML config, the Claude memory directory, and git history.
- **Schema-driven:** the schema page and template conventions are the main guardrails for page semantics.
- **Tool-adapter shaped:** Logseq and Obsidian are treated as two serialization backends for the same conceptual wiki.

The machine, conceptually:

1. `setup.sh` creates the initial wiki substrate and config.
2. The user invokes `/wiki ...` inside Claude Code.
3. Claude reads `llm-wiki.yml`, the schema page, and a small set of wiki pages.
4. Claude performs a prompt-defined workflow (ingest/query/lint/status/import).
5. Claude mutates or reads the external vault and may recommend git commits.

Where the behavioral intelligence lives:

- **Observed semantic center:** `wiki.md`, especially its workflow phases, constraints, and L1/L2 boundary rules.
- **Secondary semantic center:** schema templates and schema documentation, which define page types, required metadata, cross-reference rules, and lint expectations.
- **Low semantic weight:** most of the repo’s docs restate or elaborate these rules; `setup.sh` is important operationally but not semantically rich.

## 3. Conceptual Capability Mapping

| Conceptual capability | Implementation status | Concrete owner/location | Execution semantics | Limits / extension implications |
|---|---|---|---|---|
| Persistent wiki maintenance | **Partially implemented** | `wiki.md`, templates, external wiki vault | Claude is instructed to create/update pages and preserve append-only history | No deterministic enforcement; depends on Claude compliance |
| L1/L2 knowledge split | **Strongly specified, weakly enforced in code** | `README.md`, `docs/l1-l2-architecture.md`, schema templates, `wiki.md` | Claude routes operational rules/credentials to L1 and deeper knowledge to L2 | No local tool checks this except via prompt behavior |
| Initial wiki bootstrapping | **Implemented concretely** | `setup.sh`, `templates\logseq\*`, `templates\obsidian\*` | Interactive bash installer renders starter pages and config | Only covers initial scaffolding, not ongoing wiki maintenance |
| Ingest pipeline | **Prompt-defined** | `wiki.md`, `openspec\specs\ingest.md` | 5-phase Claude workflow: analyze, scan, update, quality gate, report | No executable ingest engine in repo |
| Query/synthesis | **Prompt-defined** | `wiki.md`, `openspec\specs\query.md` | Claude searches/globs/reads 3-5 pages and synthesizes answers with citations | Quality depends on Claude search strategy; no ranking implementation |
| Lint/health checking | **Prompt-defined** | `wiki.md`, `openspec\specs\lint.md`, schema docs | Claude scans pages for nine rule categories and may auto-fix some | No parser or linter binary exists locally |
| Status dashboard | **Prompt-defined, lightly scaffolded** | `wiki.md`, Dashboard templates | Claude updates dashboard page with counts and health summaries | No dedicated OpenSpec for status; maturity lower |
| Import existing notes | **Aspirational / underspecified** | `wiki.md` only | Claude is instructed to inventory and convert notes | No spec file, no setup integration, no executable helper |
| Tool dual-support (Logseq/Obsidian) | **Implemented in scaffolding; prompt-defined at runtime** | `setup.sh`, both template trees, `wiki.md` format rules | Setup chooses serialization; Claude is instructed to honor it later | Adding another backend would require repeating this pattern |
| Git safety/versioning | **Implemented minimally in setup, otherwise manual/prompted** | `setup.sh`, docs | Installer can initialize git and create an initial commit in the wiki root | Ongoing commit discipline is advisory, not enforced |

## 4. Architecture and Component Analysis

### 4.1 Installer and bootstrap layer

**Files:** `setup.sh`, `config.example.yml`

Purpose:

- gather operator choices (tool, path, namespaces, memory path, git init, skill installation);
- materialize the initial wiki structure;
- create `llm-wiki.yml`;
- optionally install the Claude command into another project.

Ownership boundaries:

- Owns only bootstrap-time filesystem creation and config emission.
- Does **not** own steady-state wiki operations after installation.

Important behavior:

- `check_command` hard-fails if `python3` or `git` are missing (`setup.sh:8-17`).
- Tool choice controls template directory, file layout, and `pages_dir` semantics (`setup.sh:32-83`).
- A Python heredoc renders schema/dashboard/hub pages and skips existing files (`setup.sh:149-230`).
- Skill installation copies `wiki.md` into `.claude\commands` (`setup.sh:263-282`).

Hidden coupling:

- Assumes template variable names and directory layouts match the Python substitution logic.
- Assumes `wiki.md` contains a `<CONFIG_PATH>` placeholder, but **observed:** the current `wiki.md` does not contain that token, so the sed replacement step is a no-op.

Architectural significance:

- High operational significance for first-run success.
- Low ongoing semantic significance after scaffolding completes.

### 4.2 Runtime command contract

**Files:** `wiki.md`

Purpose:

- define Claude Code’s `/wiki` command semantics and safety rules.

This is the closest thing the repo has to an application runtime. It specifies:

- configuration loading;
- tool-specific formatting rules;
- ingest/query/lint/status/import workflows;
- constraints such as append-only updates, “max 3 wiki pages loaded simultaneously,” and no secrets in L2.

Boundary:

- It does not execute anything itself; it governs the behavior of an external agent.

Architectural significance:

- This is the repo’s primary control surface.
- If you change system behavior, `wiki.md` is usually the highest-leverage file.

### 4.3 Schema and serialization layer

**Files:** `templates\logseq\Schema.md`, `templates\obsidian\Schema.md`, `docs\schema-reference.md`, `openspec\specs\schema.md`

Purpose:

- define the ontology of page types, required properties, cross-link expectations, and L1/L2 routing rules;
- serialize the same semantics into Logseq’s block format and Obsidian’s frontmatter format.

Key abstractions:

- page types: entity, project, knowledge, feedback, hub;
- namespaces;
- metadata invariants (`created`, `updated`, `status`, `confidence`, etc.);
- cross-reference minimum and hub completeness expectations.

Where boundaries leak:

- The schema is both a template artifact and a documentation/spec artifact; changes must often be reflected in several places manually.

### 4.4 Template corpus

**Files:** `templates\logseq\Hub.md`, `templates\logseq\Dashboard.md`, `templates\obsidian\Hub.md`, `templates\obsidian\Dashboard.md`

Purpose:

- create the initial minimum wiki topology: Schema page, Dashboard page, one hub page per namespace.

Role in lifecycle:

- Only used during setup unless operators manually reapply them.

Complexity:

- Low, but they encode initial navigation and metadata assumptions that downstream Claude workflows rely on.

### 4.5 Documentation and OpenSpec layer

**Files:** `README.md`, `docs\*.md`, `openspec\project.md`, `openspec\specs\*.md`, `openspec\AGENTS.md`

Purpose:

- explain the operational model to humans and future agents;
- state acceptance criteria and requirements for intended behaviors.

Reality check:

- These files often describe intended behavior more completely than the executable code.
- They are semantically important because the runtime is prompt-driven, but they are still weaker evidence than `setup.sh` and `wiki.md`.

### 4.6 External state surfaces

**Owned outside the repo:** target wiki root, Claude memory directory, git repository in the wiki root, Claude Code project command directory.

These are architecturally central despite not living in the repo because the repo is a generator/controller for them.

## 5. Execution Flow Analysis

### 5.1 Bootstrap / first-run flow

**Observed implementation:** `setup.sh`

1. Resolve script directory (`setup.sh:5`).
2. Check prerequisites for `python3` and `git` (`setup.sh:8-17`).
3. Prompt for tool selection, wiki path, namespaces, memory path, git init decision, and skill install path (`setup.sh:32-114`, `263-282`).
4. Create missing directories (`setup.sh:60-83`).
5. Render starter pages using inline Python with date/namespace substitution (`setup.sh:149-230`).
6. Emit `llm-wiki.yml` in the target wiki root (`setup.sh:232-261`).
7. Copy `wiki.md` into the chosen Claude project if requested (`setup.sh:269-281`).
8. Optionally create an initial git commit in the target wiki repo (`setup.sh:285-295`).
9. Print next-step instructions (`setup.sh:298-310`).

State mutations:

- external wiki directory tree;
- optional `.git` and `.gitignore` in the wiki root;
- Claude project `.claude\commands\wiki.md`.

Failure behavior:

- invalid tool choice exits immediately;
- missing prerequisites exit immediately;
- missing template directory exits immediately;
- existing generated pages are skipped rather than overwritten.

### 5.2 `/wiki` command invocation flow

**Observed implementation artifact:** `wiki.md`

This is not a local process launch; it is a Claude Code command flow.

1. User invokes `/wiki <subcommand> ...` in Claude Code.
2. Claude is instructed to read `llm-wiki.yml` first (`wiki.md:28-33`, `openspec\specs\config.md`).
3. Claude derives tool mode, page path conventions, namespaces, and memory path.
4. Claude follows the relevant workflow section.

**Inference:** actual control remains inside Claude’s turn-level reasoning loop, not a deterministic interpreter embedded in this repo.

### 5.3 Ingest flow

**Observed in prompt/specs:** `wiki.md:65-97`, `openspec\specs\ingest.md`

1. Source analysis: detect URL/file/text, extract entities/facts/dates/relationships.
2. Wiki scan: load config + schema, discover existing target pages, identify create/update plan.
3. Page operations: create pages with required metadata, append to existing pages, update hubs, add cross-links.
4. Quality gate: check required properties, cross-reference minimum, credential patterns, page-touch counts.
5. Report: summarize changes/warnings and recommend commit behavior.

Runtime-critical transitions:

- deciding L1 vs L2 placement;
- matching extracted topics to existing pages;
- append-only mutation versus page creation;
- blocking on credential pattern detection.

### 5.4 Query flow

**Observed in prompt/specs:** `wiki.md:98-122`, `openspec\specs\query.md`

1. Parse question into namespaces/entities/keywords.
2. Search candidate pages via glob/grep-style retrieval.
3. Read 3-5 pages, at most 3 simultaneously.
4. Synthesize an answer, check confidence/staleness, surface contradictions.
5. Optionally offer write-back as a new page or page update.

Notable semantic choice:

- the query path is designed to create durable artifacts from useful answers, but **write-back requires explicit user confirmation** in the spec.

### 5.5 Lint / status / import flows

**Lint:** fully prompt-defined, with nine rules and selective auto-fix behavior (`wiki.md:123-156`, `openspec\specs\lint.md`).

**Status:** prompt-defined dashboard update flow (`wiki.md:157-178`) but lacks a dedicated OpenSpec file; it appears less mature than ingest/query/lint.

**Import:** prompt-defined conversion workflow (`wiki.md:179-200`) with no matching spec file or installer support; this appears exploratory.

### 5.6 Shutdown / recovery

There is no daemon or long-lived local runtime to shut down. Recovery is file-based:

- rerun `setup.sh` to regenerate missing scaffold pieces without overwriting existing pages;
- rerun Claude workflows after partial failure, relying on append-only discipline and git history.

## 6. State and Persistence Model

### State ownership

| State | Owner | Persistence |
|---|---|---|
| Wiki knowledge (L2) | external Logseq/Obsidian vault | markdown files + optional git |
| Always-loaded operational knowledge (L1) | Claude memory directory | markdown/text files outside git-tracked wiki |
| Runtime config | `llm-wiki.yml` in wiki root | YAML file |
| Claude command contract | `.claude\commands\wiki.md` in target project | copied markdown prompt |
| Evolution history | git repo in wiki root if initialized | commit history |

### Mutable vs immutable

- Raw source material is intended to be immutable conceptually, but the repo does not manage raw sources directly.
- Wiki pages are mutable but governed by an **append-only** convention.
- L1 memory is mutable and treated as the authority for operational rules/secrets.

### Persistence semantics

- No database or cache service exists.
- Durability is purely filesystem-based.
- Git is the only formal history mechanism offered.

### Recovery semantics

- Existing files are skipped by setup, preventing destructive regeneration.
- Prompt docs assume rerunning ingest/lint/query is safe if append-only rules are obeyed.

### Synchronization model

- There is no concurrency control.
- `README.md` explicitly warns that parallel Claude sessions can conflict on shared wiki files.

## 7. Coordination and Control Semantics

Execution authority is strongly centralized in **Claude Code**.

Real control topology:

- **Centralized, directive orchestration:** the user issues `/wiki ...`; Claude governs the whole workflow.
- **Synchronous, turn-driven control:** there is no event bus, queue, scheduler, or worker pool in repo code.
- **State-driven retrieval:** Claude is supposed to inspect config/schema/pages, then decide what to read or write next.

Delegation model:

- `wiki.md` delegates format choice to config (`tool`, `pages_dir`, namespaces).
- `setup.sh` delegates page rendering complexity to embedded Python.
- The rest of the system delegates interpretation and safe mutation to Claude.

Concurrency and coordination:

- No locks, transaction boundaries, or merge safeguards.
- Coordination is social/procedural: one Claude session should preferably own the wiki at a time.

Failure propagation:

- In the installer, failures are direct shell exits.
- In runtime command workflows, failures are expected to appear as Claude warnings/aborts, especially for missing config, missing required properties, or credential detection.

Most important control invariant:

- **Config must be read first** and the selected tool mode must govern all downstream serialization.

## 8. Configuration and Environment Model

### Configuration hierarchy

1. **Claude project command installation:** `.claude\commands\wiki.md`
2. **Per-wiki runtime config:** `llm-wiki.yml`
3. **In-wiki schema page:** `Wiki/Schema` or `Wiki___Schema.md`
4. **Optional L1 memory directory:** path referenced by `memory_path`

### Required config keys

Per `config.example.yml` and `openspec\specs\config.md`:

- `tool`
- `wiki_path`
- `pages_dir`
- `namespaces`

Optional:

- `memory_path`
- lint and ingest tuning shown in `README.md` examples, though `setup.sh` emits only the basic keys.

### Runtime modes

- `tool: logseq` -> flat `pages\` directory, triple-underscore filenames, inline properties.
- `tool: obsidian` -> nested `Wiki\...` directory structure, YAML frontmatter, empty `pages_dir`.

### Environmental assumptions

- bash-compatible shell
- Python 3 standard library only
- git available locally
- Claude Code able to access both the working project and the target wiki root

### Observed inconsistencies

- `README.md` advertises 8 default namespaces including `Careers`, but `setup.sh` and `config.example.yml` default to 7 namespaces and omit `Careers`.
- `openspec\specs\setup.md` says git-related steps should be skippable if git is unavailable, but `setup.sh` hard-fails if git is missing.
- `setup.sh` attempts to patch `<CONFIG_PATH>` into `wiki.md`, but the current `wiki.md` does not contain that placeholder.

## 9. Operational Usage Model

### Canonical user workflow

1. Use `setup.sh` once to scaffold a target wiki.
2. Open the target graph/vault in Logseq or Obsidian.
3. Use Claude Code `/wiki ingest` to turn sources into structured wiki updates.
4. Use `/wiki query` to answer questions from the wiki and optionally file new synthesis back into the wiki.
5. Use `/wiki lint` periodically to keep structure and safety intact.
6. Use `/wiki status` as a lightweight dashboard/health snapshot.
7. Commit wiki changes to git in the target wiki repo.

### Developer workflow in this repo

Typical modifications will touch one or more of:

- `wiki.md` for runtime behavior;
- `setup.sh` for bootstrap UX or file generation changes;
- `templates\` for generated starter content;
- `docs\` and `openspec\` for human/agent guidance and acceptance criteria.

### Interaction semantics

- The repo expects **human-in-the-loop operation**, not fully unattended automation.
- Ingest can be interactive and interpretive; users are expected to guide emphasis and approve write-backs where appropriate.

### Production vs development reality

- There is no production deployment topology in the conventional sense.
- “Production” here means a real personal/team knowledge workflow backed by local markdown and git.

## 10. Extension and Customization Architecture

There is no plugin registry or DI container. Extension is **convention-based**.

### Main extension surfaces

1. **Prompt extension:** edit `wiki.md` to change workflows, constraints, or supported commands.
2. **Schema extension:** edit schema templates/docs/specs to add page types, properties, lint rules, or namespace policy.
3. **Tool adapter extension:** add another template subtree and update `setup.sh` + `wiki.md` format rules.
4. **Config extension:** add new keys to `llm-wiki.yml` and teach both setup and prompt how to use them.

### Expected evolution model

The repo assumes the system evolves by co-designing:

- prompt rules;
- page schema;
- wiki structure conventions;
- lightweight setup automation.

It does **not** yet provide a structured extension API.

## 11. Key Architectural Decisions and Tradeoffs

### Claude-first implementation

Decision:

- encode ingest/query/lint behavior as a Claude prompt instead of local code.

Tradeoff:

- very low implementation footprint and flexibility;
- lower determinism, weaker enforceability, harder debugging.

### Two-layer knowledge model

Decision:

- split knowledge into L1 Claude memory and L2 wiki.

Tradeoff:

- better context efficiency and secret isolation;
- more conceptual overhead and possible duplication drift.

### Dual backend support through serialization templates

Decision:

- treat Logseq and Obsidian as interchangeable conceptual backends with different file encodings.

Tradeoff:

- broader adoption path;
- duplicated template/docs maintenance and format drift risk.

### Zero-dependency ethos

Decision:

- use only bash, python3, and git.

Tradeoff:

- easy adoption and no package management burden;
- no deterministic search/lint/query tooling beyond what Claude can improvise.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Runtime behavior is mostly aspirational

The repo documents extensive workflows, but only setup is concretely executable. Ingest, query, lint, status, and import are prompt contracts rather than implemented programs.

### 12.2 Documentation/spec drift

Observed examples:

- `README.md` says 8 namespaces including `Careers`; `setup.sh`/`config.example.yml` default to 7.
- `openspec\specs\setup.md` says git can be skipped if unavailable; `setup.sh` requires git up front.
- `openspec\specs\setup.md` says namespace naming is not validated; `setup.sh` now validates it.

### 12.3 Missing config-path wiring

`setup.sh` copies `wiki.md` and tries to replace `<CONFIG_PATH>`, but the source `wiki.md` no longer contains that placeholder. That suggests either stale docs/specs or a partially completed migration away from absolute-path embedding.

### 12.4 Missing migration/import tooling

`docs\logseq-vs-obsidian.md` references `./migrate.sh`, but no such script exists in the repo.

### 12.5 Uneven maturity across commands

- `ingest`, `query`, and `lint` have full OpenSpec coverage.
- `status` appears in `wiki.md` and README but lacks its own spec.
- `import` appears in `wiki.md` but is absent from README’s main command table and from OpenSpec coverage.

### 12.6 No automated tests

Testing is manual and scenario-based (`CONTRIBUTING.md`, `openspec\AGENTS.md`). That matches the zero-dependency goal but weakens change confidence.

### 12.7 Concurrency remains a social contract

The wiki is a shared mutable filesystem with no locking or merge strategy beyond git and user discipline.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Have Claude Code, bash, python3, git, and either Logseq or Obsidian.
2. Run `setup.sh`.
3. Open the generated wiki root in the chosen app.
4. Use `/wiki ingest "small source"` first.
5. Inspect generated pages and the hub/dashboard structure before scaling up.

### Operational Assumptions

- Small-to-moderate wiki scale initially (~50-200 pages is the design center referenced in docs).
- Users are comfortable with markdown files, git, and Claude-driven editing.
- The wiki root is local and writable.
- Secrets are managed separately in Claude memory, not in the wiki.

### Canonical Workflow

- ingest new source;
- inspect touched pages;
- query the accumulated wiki;
- lint periodically;
- commit meaningful wiki changes.

### Advanced Usage

- customize namespaces and schema for a domain;
- use Obsidian/Logseq graph and backlinks as the navigation UI;
- use query write-back to convert ephemeral analysis into persistent pages;
- maintain the L1/L2 boundary intentionally as the corpus grows.

### Extension Workflow

1. Update OpenSpec/doc contract first if changing semantics.
2. Modify `wiki.md` to encode the new behavior.
3. Update templates if generated page shapes change.
4. Update `setup.sh` if new config/template plumbing is required.
5. Manually test both tool modes.

### Debugging Workflow

Best inspection points:

- generated `llm-wiki.yml`
- installed `.claude\commands\wiki.md`
- generated Schema and hub pages
- Claude output during `/wiki` execution
- git diff in the target wiki repo

### Observability

- Dashboard pages are the main in-wiki observability surface.
- git history in the target wiki repo is the main audit trail.
- There are no structured logs, metrics exporters, or tracing facilities.

### Failure Modes

| Failure mode | Typical cause | Expected behavior |
|---|---|---|
| Setup fails early | missing bash/python3/git, invalid input, missing templates | shell exit with direct message |
| Claude command unavailable | skill not copied into `.claude\commands` | `/wiki` command absent until manual copy/rerun |
| Wrong file layout/links | mismatched Logseq vs Obsidian mode | broken wikilinks or pages not indexed |
| Secrets flagged | credential-like text in L2 | lint/quality gate should warn and block write path |
| Prompt drift | docs/specs and `wiki.md` disagree | inconsistent runtime behavior across sessions |

### Performance Considerations

- No local indexing/search engine exists; retrieval cost scales with Claude’s file scanning behavior.
- The “max 3 pages loaded simultaneously” rule is a prompt budget tactic, not a system-level optimization.
- Past a few hundred pages, operational quality will depend heavily on disciplined hubs, namespaces, and prompt behavior.

## 14. Project Navigation Guide

### Best reading order

1. `README.md` — external framing and quick-start.
2. `setup.sh` — the only executable runtime code in repo.
3. `wiki.md` — the real behavioral contract.
4. `templates\logseq\*` and `templates\obsidian\*` — concrete serialized outputs.
5. `docs\schema-reference.md` and `docs\l1-l2-architecture.md` — semantic rules.
6. `openspec\project.md` and relevant `openspec\specs\*.md` — acceptance criteria and intended behavior.

### Highest-value entry points

| Path | Why it matters |
|---|---|
| `setup.sh` | first-run bootstrapping and config generation |
| `wiki.md` | command semantics and runtime constraints |
| `templates\logseq\Schema.md` / `templates\obsidian\Schema.md` | ontology and page invariants |
| `docs\schema-reference.md` | most complete human-readable schema explanation |
| `docs\l1-l2-architecture.md` | core architectural differentiator |
| `openspec\specs\ingest.md` / `query.md` / `lint.md` | intended command behavior details |

### Semantic centers

The repo’s core logic is conceptually concentrated in:

1. `wiki.md`
2. schema templates/docs
3. L1/L2 routing docs/specs

The shell script is important, but it is mainly an initializer for those semantics.

### Where abstractions become concrete

- Tool-agnostic schema becomes concrete in `templates\logseq\*` vs `templates\obsidian\*`.
- High-level setup requirements become concrete in prompt/branching logic inside `setup.sh`.
- Abstract command descriptions become concrete only at Claude execution time via `wiki.md`.

## 15. Concise Deep Technical Synthesis

`llm-wiki` is best understood as a **Claude Code knowledge-maintenance operating system encoded in markdown and one installer script**.

It embodies a **prompt-driven orchestration pattern** rather than a conventional software service. The repo’s unique move is not “use an LLM with a wiki”; it is **split the knowledge surface into always-loaded L1 operational memory and on-demand L2 markdown knowledge**, then teach Claude to maintain the L2 corpus under a schema. The actual code footprint is intentionally tiny, but that means reliability depends on prompt quality, documentation coherence, and operator discipline.

This repo appears optimized for engineers or technical operators who are comfortable letting an LLM manipulate a local markdown knowledge base, want minimal dependencies, and are willing to trade deterministic tooling for a flexible Claude-centered workflow.
