---
repo: Astro-Han/karpathy-llm-wiki
---

# karpathy-llm-wiki Onboarding Report

## SYNOPSIS

**Evidence stance:** statements labeled as observed are grounded directly in repository files; statements using terms like "likely" or "implied" are inferences from the current spec, templates, and examples rather than executable runtime proof.

### Implementation Identity

This repository is **not a runnable wiki application**. Its actual implementation is a **portable Agent Skills specification** centered on `SKILL.md`, with markdown templates in `references/` and example outputs in `examples/`. The dominant architectural style is **instruction-driven orchestration over a filesystem knowledge model**: an external coding agent reads the skill, then operates on a separate user project containing `raw/` and `wiki/` directories.

The primary semantic center is `SKILL.md`, especially the rules for **Ingest**, **Query**, and **Lint** (`SKILL.md:41-177`). `references/*.md` are effectively schema contracts for the persistent artifacts the agent must create or maintain. There is no internal runtime, server, database, or library API inside this repo.

### Quick Adaptation Assessment

Adaptation is straightforward if you are comfortable editing prompt/spec text and markdown schemas. The repo is highly customizable at the **workflow and document-shape level**, but not via code extension points because there is almost no executable code. The strongest coupling is between:

- `SKILL.md` operational rules,
- `references/*.md` file formats,
- downstream agent behavior,
- the target project's `raw/` / `wiki/` layout.

Most modifications will require coordinated changes to `SKILL.md`, one or more templates, and usually the examples if you want the documentation to remain representative.

### Fastest Path to First Successful Run

The shortest path is to install or copy the skill into an Agent Skills-compatible tool, then run an ingest prompt against any project directory:

1. Install with `npx add-skill Astro-Han/karpathy-llm-wiki` (`README.md:50-56`), or manually copy `SKILL.md` and `references/` into the tool's skill directory (`README.md:98-108`).
2. In a target project, ask the agent to ingest a source such as `Ingest this article: https://example.com/...` (`README.md:58-78`).
3. The first ingest creates `raw/`, `wiki/`, `wiki/index.md`, and `wiki/log.md` if missing (`SKILL.md:28-38`).

Critical prerequisite: the host agent must support file edits plus either web/file access or pasted content.

### Minimal Manual Setup Path

There is no meaningful local runtime to boot manually because the repo itself is only a skill bundle. The minimal manual path is:

1. Copy `SKILL.md` and `references/` into an Agent Skills tool's skill directory (`README.md:104-108`).
2. Open any ordinary working directory.
3. Use natural-language prompts to invoke ingest/query/lint behavior.

Without an external agent runtime, the repository does nothing by itself.

### Operational Complexity Snapshot

Setup complexity is low; runtime complexity is pushed outward into the host agent and the maintained markdown corpus. The system is operationally lightweight—no services, builds, or databases—but behavior is somewhat fragile because correctness depends on the agent consistently following the spec. Observability is basic but effective: `wiki/index.md`, `wiki/log.md`, relative links, and git history provide the main inspection surfaces. Debugging means auditing generated markdown and refining `SKILL.md`, not stepping through code.

## 1. Repository Purpose

### Actual Implemented Purpose

The repository packages Andrej Karpathy's "LLM wiki" idea into a reusable skill so an external agent can maintain a persistent markdown knowledge base. The implementation goal is to turn a generic coding agent into a disciplined operator over three artifacts:

- immutable source captures in `raw/`,
- synthesized knowledge articles in `wiki/`,
- control metadata in `wiki/index.md` and `wiki/log.md`.

This is stated in `README.md:15-29` and operationalized in `SKILL.md:14-188`.

### Relationship to the Conceptual Description

The conceptual description proposes a three-layer model: raw sources, wiki, and schema. This repo implements the **schema layer** almost exclusively. It does **not** ship a crawler, parser, search engine, or wiki UI. Instead, it codifies the pattern as instructions plus markdown contracts so a host agent can enact the workflow.

### Problem the Repo Is Really Solving

The practical problem solved here is not "how to store knowledge" but **how to constrain an LLM agent's behavior so markdown knowledge compilation is consistent across sessions**. The repo standardizes:

- when initialization is allowed,
- how files are named,
- what metadata must exist,
- how answers are cited,
- which outputs are mutable vs append-only,
- which lint operations may auto-fix and which must only report.

### Target Use Cases

Observed target use cases are:

- personal or research knowledge bases maintained by an agent,
- repeated ingest of articles/files into topic-organized markdown,
- querying synthesized wiki content instead of raw documents,
- periodic health checks over the wiki structure.

These are described in `README.md:17-48` and exemplified in `examples/README.md`.

### Scope Boundaries

The repo does **not** implement:

- source retrieval infrastructure beyond telling the agent to use whatever tools exist (`SKILL.md:45-58`),
- embeddings/RAG/search infrastructure,
- executable validation or CI,
- a viewer/editor,
- persistence beyond ordinary markdown files,
- scheduling/automation.

Those concerns are delegated to the external agent runtime or the user's surrounding tooling.

## 2. High-Level System Model

This project is best understood as a **specification-driven markdown compiler workflow**. Its behavioral "machine" is an external LLM agent, but the repo defines the machine's operating rules tightly enough that the resulting filesystem should behave like a persistent knowledge base.

The dominant architecture is **orchestration-centric and state-on-filesystem**:

- `SKILL.md` is the control policy.
- `references/*.md` are the artifact schemas.
- `raw/` and `wiki/` in the user project are the persistent state stores.
- `wiki/index.md` is the content-oriented directory.
- `wiki/log.md` is the chronological event log.

The system's behavioral intelligence primarily lives in the decision rules inside `SKILL.md`, especially:

- topic selection and file naming during ingest,
- merge-vs-create article decisions,
- cascade update semantics,
- citation path rewriting,
- deterministic vs heuristic lint authority.

So although the repo is small, its core is semantically dense: it encodes a stateful content-maintenance workflow without implementing a software runtime.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Owning files | Execution semantics | Limits / implications |
|---|---|---|---|---|
| Persistent wiki compilation from raw sources | **Implemented as instructions** | `SKILL.md:41-99`, `references/raw-template.md`, `references/article-template.md` | Ingest fetches source into `raw/` and always compiles/updates `wiki/` in the same operation | Dependent on agent compliance; no executable enforcement |
| Structured knowledge pages with cross-links | **Implemented as schema + policy** | `references/article-template.md`, `SKILL.md:62-88` | Articles synthesize content, keep Raw links, optionally maintain `See Also`, and receive cascade updates | No hard validator for link quality or article shape |
| Query over compiled knowledge with citations | **Implemented as instructions** | `SKILL.md:101-130`, `references/archive-template.md` | Query reads `wiki/index.md`, then relevant articles, answers in chat; optional archive writes a new wiki page | No built-in search tool; relies on index-first browsing |
| Health/lint workflow | **Implemented as hybrid deterministic/heuristic spec** | `SKILL.md:133-177` | Deterministic checks may auto-fix index/link/raw-reference issues; heuristic issues are report-only | Heuristics are intentionally underspecified and agent-dependent |
| Initialization of a new knowledge base | **Implemented** | `SKILL.md:28-38` | First ingest creates required directories/files; query/lint must refuse to initialize | Clear invariant, but still no code-level enforcement |
| Operational examples / golden outputs | **Implemented as examples** | `examples/*` | Examples demonstrate expected raw/article/index/log shapes | These behave like documentation-based tests rather than actual tests |
| Tool portability across agent ecosystems | **Partially implemented** | `README.md:98-108` | Repo is distributed as an Agent Skills-compatible bundle | Depends on external tool support; no adapter code here |
| Rich retrieval/search tooling | **Absent in repo** | N/A | Mentioned conceptually only in upstream idea, not implemented here | Index-first navigation is the only encoded discovery mechanism |

## 4. Architecture and Component Analysis

### 4.1 Semantic Core: `SKILL.md`

`SKILL.md` is the only file that materially governs runtime behavior. It owns:

- trigger descriptions (`SKILL.md:1-8`),
- the persistent data model (`SKILL.md:14-27`),
- initialization rules (`SKILL.md:28-38`),
- ingest pipeline (`SKILL.md:41-99`),
- query/archive pipeline (`SKILL.md:101-130`),
- lint rules and authority model (`SKILL.md:133-177`),
- repository-wide invariants (`SKILL.md:181-188`).

This is the closest thing the repo has to an application entry point. Everything else is either support material or documentation around this file.

### 4.2 Data Contract Layer: `references/`

The `references/` directory is architecturally important because it constrains the shapes of persistent outputs.

- `references/raw-template.md` defines the source capture format: title, source metadata, collected date, published date, then preserved original content.
- `references/article-template.md` defines compiled article structure: `Sources`, `Raw`, `Overview`, synthesized body, optional `See Also`.
- `references/index-template.md` defines the global, topic-grouped knowledge catalog.
- `references/archive-template.md` defines archived query-answer pages, including the rule that citations point to wiki articles rather than raw sources.

These files are not just examples; they are **contract references** explicitly invoked by `SKILL.md`.

### 4.3 User-Facing Framing Layer: `README.md`

`README.md` explains how the skill should be installed and invoked, but it does not add significant behavior beyond what `SKILL.md` already defines. Its main architectural role is to:

- frame the repo as a reusable skill package,
- advertise the three operations,
- declare compatibility assumptions,
- provide install and prompt entry points.

This is important operationally but not a semantic center.

### 4.4 Evidence / Golden Corpus: `examples/`

`examples/` functions as a lightweight substitute for tests. It shows:

- one raw capture (`examples/2026-03-19-claude-code-statusline-landscape.md`),
- one compiled article (`examples/claude-code-statusline-landscape.md`),
- one topic-style index page (`examples/ai-coding-tools-index.md`),
- log conventions (`examples/log-sample.md`),
- explanatory framing (`examples/README.md`).

These examples reveal intended output richness that the templates alone do not show, such as synthesized tables and deeper narrative structure in compiled articles.

### 4.5 Peripheral Files

- `assets/karpathy-tweet.png` supports README presentation only.
- `.gitignore` is trivial and repo-local only.
- `LICENSE` is standard MIT licensing.

These are peripheral and do not influence system behavior.

### 4.6 Architectural Boundaries

The cleanest boundary in the project is between:

1. **specification/control** (`SKILL.md`),
2. **artifact schemas** (`references/`),
3. **demonstration corpus** (`examples/`).

The leakiest boundary is between the repo and the external host agent: all execution depends on that agent faithfully interpreting the spec. There is no in-repo enforcement layer.

## 5. Execution Flow Analysis

### 5.1 Startup / Activation

There is no standalone startup sequence. Operational startup is:

1. An Agent Skills-compatible host loads this skill bundle.
2. A user issues a prompt matching ingest/query/lint triggers.
3. The host agent consults `SKILL.md` and the templates as needed.

So runtime begins with **prompt dispatch into a specification**, not with process boot.

### 5.2 First Ingest Flow

Observed implementation path from `SKILL.md:28-99`:

1. Detect that the request is an ingest.
2. If `raw/` or `wiki/` are missing in the target project, create only missing elements:
   - `raw/`
   - `wiki/`
   - `wiki/index.md`
   - `wiki/log.md`
3. Acquire source content using whatever web/file tooling exists.
4. Choose or create an appropriate topic directory.
5. Save a raw markdown capture in `raw/<topic>/...`.
6. Decide whether the source should merge into an existing article, create a new article, or both.
7. Update affected article bodies and metadata, including conflict annotations where needed.
8. Perform cascade updates on materially affected related pages.
9. Update `wiki/index.md` entries for all touched articles.
10. Append an `ingest` entry to `wiki/log.md`.

Important runtime property: raw capture and wiki compilation are explicitly inseparable—"Always both steps, no exceptions" (`SKILL.md:43`).

### 5.3 Query Flow

Observed path from `SKILL.md:101-124`:

1. Refuse to initialize missing wiki structures; user must ingest first.
2. Read `wiki/index.md` to locate relevant articles.
3. Read selected articles.
4. Synthesize an answer preferring wiki content over model priors.
5. Cite using project-root-relative wiki paths in conversation.
6. If archival is requested, write a new archive page using archive-template rules, then update index and log.

This creates a two-mode query path:

- **ephemeral query** -> answer only in conversation,
- **archived query** -> new point-in-time wiki page plus index/log mutation.

### 5.4 Lint Flow

Observed path from `SKILL.md:133-177`:

1. Refuse to initialize a missing wiki.
2. Run deterministic checks with auto-fix authority:
   - index consistency,
   - internal link repair,
   - Raw reference repair,
   - same-topic `See Also` maintenance.
3. Run heuristic checks with report-only authority:
   - contradictions,
   - stale claims,
   - missing conflict annotations,
   - orphan pages,
   - missing cross-topic links,
   - missing concept pages,
   - stale archives.
4. Append a `lint` log entry with counts.

The key semantic distinction is that lint is **part validator, part editorial reviewer**, but only the deterministic subset may mutate files automatically.

### 5.5 Shutdown / Completion

There is no explicit shutdown. Completion is the end of the host agent turn after filesystem updates and/or conversational output. Persistence is immediate because state is just markdown files.

## 6. State and Persistence Model

### State Ownership

State lives in the **target project**, not in this repository:

- `raw/` owns immutable source captures.
- `wiki/` owns mutable synthesized knowledge.
- `wiki/index.md` owns navigational state.
- `wiki/log.md` owns chronological audit state.
- archived query pages own point-in-time synthesized answers.

### Mutable vs Immutable

- `raw/` files are conceptually immutable after capture (`SKILL.md:18`, `SKILL.md:56`).
- normal wiki articles are mutable and may be cascade-updated.
- archive pages are immutable snapshots after creation (`SKILL.md:83`, `SKILL.md:124`).
- `wiki/log.md` is append-only.

### Persistence Mechanism

Persistence is plain markdown-on-filesystem with relative links. There is no database, cache, vector store, or separate metadata store.

### Synchronization Model

No concurrent synchronization mechanism is defined. The implied model is one agent operation at a time over a git-tracked working tree. If multiple agents/users edit simultaneously, consistency would depend on ordinary file merges rather than any repo-provided lock or transaction model.

### Recovery Semantics

Recovery is coarse-grained:

- git history is the likely rollback mechanism,
- lint can repair some structural issues,
- log/index provide partial reconstruction of prior activity,
- there is no explicit journal/replay subsystem beyond `wiki/log.md`.

## 7. Coordination and Control Semantics

Execution authority is highly centralized:

- the host agent is the sole executor,
- `SKILL.md` is the governing policy,
- the filesystem is the shared state surface.

### Control Topology

The control topology is **directive and centralized**, not event-driven:

- user prompt selects operation,
- skill rules govern admissible actions,
- agent performs read/decide/write steps,
- index/log are updated as coordination artifacts.

### Work Routing

Routing decisions are local and semantic rather than infrastructural:

- choose topic directory,
- choose merge vs create,
- choose related pages for cascade updates,
- choose whether a query should remain ephemeral or become archived.

These are dynamic content-routing decisions specified in prose, not dispatched through code objects or queues.

### Concurrency and Scheduling

No scheduler, queue, worker pool, or async model exists in-repo. The design assumes synchronous request handling inside a single host-agent turn.

### Failure Propagation

Observed failure handling is explicit but shallow:

- inaccessible source -> ask user to paste content (`SKILL.md:47`),
- query/lint before initialization -> tell user to run ingest first (`SKILL.md:37`),
- ambiguous missing-link repair -> report rather than guess (`SKILL.md:146-153`).

This is a conservative governance style: auto-fix only when confidence is structurally high.

## 8. Configuration and Environment Model

### Required Configuration

There are no environment variables or executable config files in this repo. Required configuration is implicit:

- an Agent Skills-compatible host,
- this skill bundle installed or copied into that host,
- a writable project directory,
- agent access to files and ideally to the web.

### Optional / Advanced Configuration

The main customization surface is editing:

- `SKILL.md` for workflow and behavioral rules,
- `references/*.md` for markdown schemas,
- optionally the surrounding tool's skill installation path.

### Runtime Modes

The repo defines three operation modes at the prompt level:

- ingest,
- query (with optional archive branch),
- lint.

There are no separate development/production code paths in the repo itself.

### Deployment Assumptions

Deployment is effectively "distribute a directory of markdown instructions." The README advertises `npx add-skill` as the preferred install path, but manual copying is also supported (`README.md:50-56`, `README.md:98-108`).

## 9. Operational Usage Model

### Canonical Workflow

The intended usage loop is:

1. install the skill into an agent tool,
2. ingest one or more sources,
3. let the agent create/update wiki pages,
4. ask questions against the wiki,
5. optionally archive valuable answers,
6. periodically lint the wiki,
7. inspect results in ordinary markdown tooling and git.

This matches both `README.md:58-79` and the operation sections in `SKILL.md`.

### Human vs Agent Responsibilities

Observed division of labor:

- **human**: choose sources, ask questions, decide what to archive, interpret results;
- **agent**: normalize sources, synthesize articles, update cross-links, maintain index/log, run lint passes.

That mirrors the conceptual idea and is explicitly stated in the README narrative.

### Developer Workflow in This Repo

Working on this repo itself means editing the skill contract, not application code. The normal maintainer workflow is likely:

1. revise `SKILL.md`,
2. update affected templates in `references/`,
3. update examples/docs so they continue to represent intended behavior.

### Production vs Development Reality

There is no binary distinction between production and development here. The same markdown spec is both the source and the shipped artifact.

## 10. Extension and Customization Architecture

### Primary Extension Mechanism: Spec Editing

This repo expects evolution through specification changes rather than plugins or code modules.

Key extension points:

- add or change operation rules in `SKILL.md`,
- refine file schemas in `references/`,
- expand trigger language in the skill front matter,
- enrich examples to teach new behavior patterns.

### Provider / Tool Abstraction

The abstraction boundary is weakly enforced but intentional: the skill avoids assuming a specific model or tool implementation beyond Agent Skills compatibility. That is why retrieval instructions are phrased as "use whatever web or file tools your environment provides" (`SKILL.md:47`).

### What Is Not Extensible In-Repo

There is no plugin registry, DI container, hook system, or executable provider interface. Extending behavior beyond prompt/spec logic requires the surrounding tool ecosystem, not changes inside this repo alone.

## 11. Key Architectural Decisions and Tradeoffs

### Markdown Filesystem Over Structured Backend

Decision: use ordinary markdown files and relative links rather than a database or vector index.

Why it likely exists:

- maximum portability,
- git-native versioning,
- human inspectability,
- compatibility with Obsidian-like workflows.

Tradeoff: behavior is transparent and durable, but correctness is not machine-enforced.

### Index-First Retrieval Over Embedded Search

Decision: query starts from `wiki/index.md` instead of a search engine (`SKILL.md:110-113`).

Tradeoff: simple and deterministic at moderate scale, but likely weaker for large corpora or fuzzy recall. This matches the README's emphasis on curated synthesis over classic RAG.

### Centralized Single-Agent Control

Decision: one host agent owns orchestration.

Tradeoff: low conceptual overhead and easy portability, but no built-in safeguards for concurrent editing or stronger execution guarantees.

### Deterministic vs Heuristic Lint Split

Decision: only structurally checkable issues are auto-fixed; semantic/editorial issues are report-only.

Tradeoff: reduces harmful silent edits while acknowledging that some wiki maintenance is interpretive.

### One-Level Topic Hierarchy

Decision: `wiki/` supports only one topic-directory level (`SKILL.md:20`, `SKILL.md:184`).

Tradeoff: simpler path management and citation rewriting, but constrains information architecture as the corpus grows.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### No Executable Validation

There are no tests, manifests, CI workflows, or validation scripts in the repo. All correctness depends on documentation fidelity and host-agent obedience.

### Documentation-Behavior Drift Risk

Because behavior lives in prose, the risk of drift is high. Templates, README promises, and examples can diverge without any automated detection.

### Observed Inconsistencies

Several concrete inconsistencies are already visible:

1. `references/raw-template.md` requires `Published`, but `examples/2026-03-19-claude-code-statusline-landscape.md:1-5` omits it.
2. `SKILL.md` specifies log entries like `## [YYYY-MM-DD] ingest | ...` and `lint | ...` (`SKILL.md:91-97`, `SKILL.md:175-177`), while `examples/log-sample.md` uses capitalized action names such as `Compile` and `Update`.
3. `references/index-template.md` defines a global topic-grouped `wiki/index.md`, but `examples/ai-coding-tools-index.md` is a topic-local index page rather than an example of the declared global index.

These may be intentional evolution artifacts, but they are real evidence of spec/example drift.

### Aspirational Rather Than Enforced Portability

The README claims compatibility across multiple tools, but the repo contains no adapters or compatibility tests. Portability is an aspiration encoded in documentation, not a verified subsystem.

### Limited Operational Guidance for Hard Cases

The skill covers many editorial decisions at a high level, but edge cases remain open:

- deduplication of near-identical sources,
- concurrent edits,
- large-scale wiki reorganization,
- source types like PDFs/images with extraction failures,
- handling of extremely large wikis.

These are not blockers, but they show the project is more "battle-tested prompt bundle" than full platform.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Install/copy the skill.
2. Use an Agent Skills-compatible host with file-edit ability.
3. Run one ingest prompt.
4. Inspect the created `raw/` and `wiki/` directories in the target project.

### Operational Assumptions

- A human curator chooses worthwhile sources.
- The host agent can read/write markdown reliably.
- The wiki is small-to-moderate enough that index-first navigation remains useful.
- Git or some equivalent version control is available for recovery.
- Operators are comfortable reviewing markdown diffs.

### Canonical Workflow

Ingest -> inspect generated wiki pages -> ask targeted questions -> optionally archive answers -> lint periodically -> refine the skill as needed.

### Advanced Usage

Advanced use is mostly process-level rather than code-level:

- archive query answers as durable wiki pages,
- evolve templates for domain-specific article shapes,
- use git history and examples as quality baselines,
- adapt topic taxonomy and cross-link rules for a specialized corpus.

### Extension Workflow

When extending behavior:

1. modify `SKILL.md`,
2. update matching templates,
3. adjust examples if the intended output shape changed,
4. test manually by running representative ingest/query/lint prompts in a target project.

### Debugging Workflow

The most effective debugging path is artifact inspection:

- compare generated files against `references/*.md`,
- inspect `wiki/index.md` and `wiki/log.md`,
- check relative links,
- review whether cascade updates touched the correct articles,
- tighten or clarify `SKILL.md` where the agent behaved ambiguously.

### Observability

Primary observability surfaces:

- `wiki/log.md` for chronological actions,
- `wiki/index.md` for coverage and navigation,
- markdown diffs in git,
- the structure of Raw / Sources / See Also links inside articles.

### Failure Modes

Most likely failures:

- source fetch unavailable,
- wiki not initialized before query/lint,
- ambiguous link repair cases,
- spec/example drift causing inconsistent output,
- host agent under-following or over-interpreting the instructions.

### Performance Considerations

There are no computational performance optimizations in-repo. The likely scaling bottlenecks are:

- manual index scanning for discovery,
- growing cascade-update scope,
- increased semantic ambiguity as the number of articles grows.

## 14. Project Navigation Guide

### Highest-Value Entry Points

1. `SKILL.md` — read first; it is the real implementation.
2. `references/article-template.md` and `references/raw-template.md` — understand the persistent artifact contracts.
3. `references/index-template.md` and `references/archive-template.md` — understand navigation and archival behavior.
4. `examples/README.md` plus the example raw/article/log files — see the intended outputs.
5. `README.md` — use mainly for installation and framing.

### Semantic Centers

The repo's real complexity lives in:

- ingest merge/create/cascade rules,
- citation path conventions,
- lint authority boundaries,
- the persistent distinction between raw, mutable wiki articles, archived answers, and append-only logs.

### Best Reading Order

1. `README.md`
2. `SKILL.md`
3. `references/*.md`
4. `examples/README.md`
5. `examples/2026-03-19-claude-code-statusline-landscape.md`
6. `examples/claude-code-statusline-landscape.md`
7. `examples/log-sample.md`

### Where Abstractions Become Concrete

- `SKILL.md` describes the workflow abstractly.
- `references/` makes the workflow concrete as file formats.
- `examples/` shows what concrete, high-information outputs look like in practice.

## 15. Concise Deep Technical Synthesis

This project is a **prompt-spec runtime packaged as a repository**. It embodies a **single-agent, filesystem-backed knowledge-compilation model** in which the agent is the execution engine, markdown files are the database, `SKILL.md` is the orchestration policy, and `references/` are schema contracts.

What makes it distinctive is that it treats durable markdown synthesis—not retrieval infrastructure—as the core knowledge primitive. The repo is optimized for teams or individuals who are comfortable steering agents through explicit workflow contracts and who prefer editable, git-native knowledge artifacts over opaque application backends.

Its strength is conceptual leverage and portability; its weakness is that almost all guarantees are social/documentary rather than executable.
