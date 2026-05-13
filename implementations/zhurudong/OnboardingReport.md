---
repo: zhurudong/andrej-karpathy-llm-wiki
---

# andrej-karpathy-llm-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

This repository is not an application runtime in the usual sense. **Observed:** the only executable artifact is `install.sh`, and the main behavioral asset is the instruction template in `templates/CLAUDE.en.md` and `templates/CLAUDE.md`. The project operationalizes Karpathy's "LLM wiki" idea by packaging a **schema-driven, file-backed operating manual for an external LLM CLI**. The semantic center is the template: it defines the directory model, invariants, and ingest/query/lint control flow that the agent is expected to execute against a markdown knowledge base.

### Quick Adaptation Assessment

Adaptation is easy if the desired change is "change the schema or workflow rules" and harder if the desired change is "enforce behavior mechanically." Most customization goes through `templates/CLAUDE.en.md`, `templates/CLAUDE.md`, `README.md`, and `install.sh`. Coupling is high around the fixed directory names `raw/`, `wiki/`, `wiki/_index.md`, and `wiki/_log.md`; renaming or reshaping the knowledge base requires coordinated edits across the template, bootstrap script, docs, and example instance.

### Fastest Path to First Successful Run

For a **fresh** knowledge base, the shortest path is the documented bootstrap:

```bash
curl -fsSL https://raw.githubusercontent.com/zhurudong/andrej-karpathy-llm-wiki/main/install.sh | bash -s my-kb
cd my-kb
# launch claude / codex / opencode in that directory
```

Prerequisites are minimal but external: a Unix-like shell with `bash`, `curl`, and an LLM CLI that reads `CLAUDE.md` or `AGENTS.md`. There is no local service, database, or dependency installation step.

For **this checked-out repository**, the fastest successful interaction is to open the LLM CLI inside `examples/`, because repo root is template source, not a live `raw/` + `wiki/` instance.

### Minimal Manual Setup Path

The repository documents a three-command manual path in `README.md`, but `install.sh` shows the true minimum is slightly larger: you also need the `raw/`, `raw/assets/`, and `wiki/*` directories plus empty `wiki/_index.md` and `wiki/_log.md`. **Observed constraint:** the repo does not provide a non-shell bootstrap path or a Windows-native installer; `install.sh` uses `bash`, `curl`, and `ln -sf`. If symlinks are inconvenient, the real minimum is still "put the template rules file where your chosen CLI expects it, then create `raw/` and `wiki/` using the prescribed layout."

### Operational Complexity Snapshot

Local infrastructure complexity is low; behavioral complexity is outsourced to the agent and the quality of its tool access. There is no validator, no tests, no indexer, and no enforcement beyond prompt instructions. This makes setup light but runtime behavior comparatively fragile: correctness depends on the external LLM honoring the schema, maintaining links consistently, and using the documented flows in `templates/CLAUDE.en.md`.

### Evidence Legend

- **Observed:** directly visible in repository files or example artifacts.
- **Inferred:** likely architectural intent derived from multiple observed files.
- **Speculative:** plausible but not directly confirmed in the repository.

## 1. Repository Purpose

The implemented purpose is to **distribute a reusable knowledge-base scaffold for LLM-operated markdown wikis**, not to run the wiki itself. `README.md` positions the project as "One `CLAUDE.md` = a self-maintaining local knowledge base," and `install.sh` bootstraps a new knowledge-base directory by downloading the template and creating `raw/` and `wiki/`.

The relationship to the conceptual description is direct but narrower:

- **Observed conceptual fit:** the repo implements the two-layer `raw/` + `wiki/` pattern, incremental ingest/query/lint workflows, and an index/log discipline.
- **Observed specialization:** instead of shipping a search engine, backend, or orchestration daemon, it encodes behavior as LLM instructions in `templates/CLAUDE.en.md`.
- **Observed boundary:** there is no local automation for fetching, summarizing, link validation, or regeneration. Those actions are expected to be carried out by the external LLM agent using whatever tools its host CLI exposes.

Target use cases are therefore:

1. Bootstrap a new markdown knowledge base quickly.
2. Reuse a stable schema across different agent CLIs.
3. Provide a concrete example of what generated wiki artifacts should look like (`examples/`).

Out of scope in the current implementation:

- standalone querying/search beyond markdown files and index-first navigation;
- automatic ingestion pipelines;
- programmatic linting or repair;
- concurrency control, access control, or deployment tooling;
- any runtime beyond an external agent CLI plus filesystem.

## 2. High-Level System Model

Fundamentally, this project behaves like an **instruction-packaged execution contract for a human-and-agent workflow**.

Its dominant architectural identity is:

- **instruction-centric:** the template file is the main executable specification;
- **filesystem-backed:** all durable state is plain markdown under `raw/` and `wiki/`;
- **external-runtime-driven:** actual execution lives in Claude Code, Codex CLI, OpenCode, or a similar agent host, not in this repository;
- **schema-first and regeneration-oriented:** `raw/` is immutable source material, `wiki/` is a derived understanding layer that can be rebuilt.

The primary semantic center is `templates/CLAUDE.en.md`:

- it defines the directory structure;
- it encodes invariants such as raw immutability and wiki regenerability;
- it maps user intents like "ingest", "query", and "lint" to concrete file operations;
- it defines navigation heuristics such as "read `wiki/_index.md` first" and "read `wiki/_log.md` at session start."

The rest of the repository supports that center:

- `install.sh` instantiates the filesystem shape;
- `README.md` explains how to launch the pattern;
- `examples/` shows the intended steady-state artifact graph after one ingest.

**Inferred architectural intent:** treat prompt instructions as the "program," markdown as the data model, and the LLM CLI as the execution engine. This keeps the system portable and low-infrastructure, but it also means the most important behavior is convention-driven rather than mechanically enforced.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Implementation owner/location | Execution semantics | Limitations and extension implications |
|---|---|---|---|---|
| Bootstrap a new knowledge base | Implemented | `install.sh`, `README.md` | Creates `raw/`, `raw/assets/`, `wiki/*`, downloads template, creates `AGENTS.md`, initializes `_index.md` and `_log.md` | Unix-shell oriented; no Windows-native or package-manager installer |
| Cross-CLI rules portability | Implemented | `README.md`, `install.sh`, `templates/CLAUDE.en.md` | Same rules file is exposed as `CLAUDE.md` and `AGENTS.md` so multiple CLIs can consume it | Depends on convention-file compatibility of external tools |
| Ingest workflow | Implemented as instructions, not code | `templates/CLAUDE.en.md` "Ingest" section | External agent fetches source, stores raw markdown/assets, compiles summary/entities/concepts, updates index/log | No local fetcher, parser, dedupe checker, or transaction safety |
| Query workflow | Implemented as instructions, not code | `templates/CLAUDE.en.md` "Query" section | Read `_index.md`, read target pages, synthesize answer, optionally archive to `wiki/synthesis/` | No built-in retrieval engine; answer quality depends on agent discipline |
| Lint/health-check workflow | Implemented as instructions, not code | `templates/CLAUDE.en.md` "Lint" section | Agent checks links, orphans, stale claims, contradictions, missing pages, then proposes fixes | No validator scripts; health check is advisory unless the agent performs it correctly |
| Regeneration model | Partially implemented | Documented in template, implied by `raw/` vs `wiki/` split | Summaries/entities/concepts/comparisons/overviews can be regenerated from raw; synthesis is preserved | No recompile command implementation; regeneration is manual agent labor |
| Example compiled wiki | Implemented | `examples/raw/`, `examples/wiki/` | Demonstrates actual artifact shape, frontmatter, links, `_index.md`, `_log.md`, summary/entity/concept pages | Only one seeded source; comparison and overview flows are not demonstrated |
| Bilingual starter template | Implemented | `templates/CLAUDE.en.md`, `templates/CLAUDE.md`, `README.zh-CN.md`, `install.sh` arg 2 | Bootstrap can choose English (`en`) or Chinese (`zh`) template | Other locales require manual authoring |

## 4. Architecture and Component Analysis

### 4.1 Template Instruction Layer

**Files:** `templates/CLAUDE.en.md`, `templates/CLAUDE.md`, root `CLAUDE.md`

This is the actual control plane.

- **Responsibility:** define the knowledge-base schema, lifecycle rules, naming conventions, cross-link topology, and operator commands.
- **Ownership boundary:** owns semantics, not execution. It tells the external agent what to do, but cannot enforce it on its own.
- **Dependencies:** assumes the agent can read/write files, fetch web pages, search the repo, and reason over markdown.
- **State relationship:** governs all persistent state under `raw/` and `wiki/`.
- **Extension point:** editing these templates is the primary way to change project behavior.

Architecturally, this layer is more important than the shell script. The script merely creates the directories; the template determines how the system behaves after bootstrap.

### 4.2 Bootstrap Script

**File:** `install.sh`

`install.sh` is a thin instantiation layer:

- reads target directory and language choice;
- creates fixed directories for `raw/` and each `wiki/` subtype;
- downloads the chosen template from GitHub as `CLAUDE.md`;
- creates `AGENTS.md` pointing at `CLAUDE.md`;
- touches empty `_index.md` and `_log.md`.

Its architectural role is narrow but important: it hardcodes the repository's structural invariants into a reproducible scaffold. It does not perform validation, package installation, or content seeding.

### 4.3 Human-Facing Documentation Layer

**Files:** `README.md`, `README.zh-CN.md`

These files explain how to operate the template and clarify that this repository is a starter kit, not a service. `README.md` is also where several implementation truths are stated explicitly:

- the single template file is the "entire program";
- the `examples/` directory is a real sample instance;
- the recommended workflow is to run an external LLM CLI inside the generated directory and speak natural-language commands.

The docs are not just marketing here; they disambiguate the runtime model that the repo itself cannot express in code.

### 4.4 Example Knowledge Base

**Files:** `examples/raw/**`, `examples/wiki/**`, `examples/CLAUDE.md`

This is the concrete reference implementation of the schema. It shows:

- raw article storage with frontmatter and local asset references (`examples/raw/2026-02-11-harness-engineering.md`);
- compiled summary/entity/concept pages with frontmatter and `[[folder/name]]` links;
- an append-only `_log.md`;
- an `_index.md` used as a content-oriented navigation spine.

This example is architecturally valuable because it reveals what the template is trying to produce, including link density and page style. It also exposes current boundaries: only one article is seeded, so comparison and overview generation are specified but not demonstrated.

### 4.5 GitHub Agent Metadata

**Files:** `.github/agents/project_onboarding.agent.md`, `.github/prompts/project_onboarding.prompt.md`

These are peripheral to the knowledge-base pattern itself. They appear to register a project-specific onboarding agent for GitHub/Copilot tooling. **Observed:** the local file content is minimal, so these files do not materially define the repo's main behavior.

### 4.6 Architectural Boundary Summary

The repository splits cleanly into:

1. **Behavior specification:** template markdown.
2. **Filesystem instantiation:** `install.sh`.
3. **Usage explanation:** README files.
4. **Reference output:** `examples/`.

The real behavior boundary is unusual: the repo stops at the point where a conventional application would start. Runtime orchestration is delegated outward to the LLM CLI.

## 5. Execution Flow Analysis

### 5.1 Bootstrap / Initialization Flow

**Observed flow:** `README.md` -> `install.sh`

1. User runs the curl-piped `install.sh` command from `README.md`.
2. `install.sh` resolves target directory and `LANG_CHOICE`.
3. It creates the canonical directory skeleton:
   - `raw/`
   - `raw/assets/`
   - `wiki/summaries/`
   - `wiki/entities/`
   - `wiki/concepts/`
   - `wiki/comparisons/`
   - `wiki/overviews/`
   - `wiki/synthesis/`
4. It downloads the selected template into `CLAUDE.md`.
5. It creates `AGENTS.md` as a symlink to the same file.
6. It initializes `wiki/_index.md` and `wiki/_log.md`.
7. It prints the next-step commands for the operator.

No dependency graph, build, or compile step exists.

### 5.2 Session Start Flow

**Observed flow source:** `templates/CLAUDE.en.md`

1. A new agent session starts inside a knowledge-base directory.
2. The first required action is to read `wiki/_log.md` if `wiki/` exists.
3. The log gives the agent recent operational context before new work begins.

This is important because continuity is not held in an application database or server session; it is reconstructed from markdown history.

### 5.3 Ingest Flow

**Observed flow source:** `templates/CLAUDE.en.md`, validated by `examples/raw/` and `examples/wiki/`

1. User issues a natural-language ingest command.
2. Agent fetches source content and attachments using whatever tools its CLI exposes.
3. Agent writes immutable raw source markdown under `raw/` and stores local assets under `raw/assets/<slug>/`.
4. Agent compiles a 1:1 summary into `wiki/summaries/`.
5. Agent searches for or creates entity pages under `wiki/entities/`.
6. Agent searches for or creates concept pages under `wiki/concepts/`.
7. Agent conditionally produces comparisons or overviews if criteria are met.
8. Agent rebuilds `wiki/_index.md`.
9. Agent appends an entry to `wiki/_log.md`.

The example harness-ingestion artifacts demonstrate the end state of this flow, including source metadata in raw frontmatter and cross-linked derived pages.

### 5.4 Query Flow

**Observed flow source:** `templates/CLAUDE.en.md`, `README.md`

1. User asks a question rather than ingesting content.
2. Agent reads `wiki/_index.md` first to locate candidate pages.
3. Agent reads specific summaries/entities/concepts.
4. If needed, agent performs supplemental search over `wiki/`.
5. Agent answers inline, using wiki links in the response.
6. Agent decides whether the answer is worth archiving to `wiki/synthesis/`.

This is a retrieval-and-synthesis loop without a separate retrieval system. The index is the first-stage router.

### 5.5 Lint / Health Check Flow

**Observed flow source:** `templates/CLAUDE.en.md`, `README.md`

1. User asks for a lint or health check.
2. Agent performs structural checks such as broken links and orphan pages.
3. Agent performs content review such as contradictions and stale claims.
4. Agent suggests gaps and new questions.
5. Agent reports issues and waits for user confirmation before editing.
6. Agent appends a lint record to `_log.md`.

**Observed limitation:** there is no local lint script, so this flow is purely agent-driven.

### 5.6 Maintenance / Regeneration Flow

**Observed flow source:** `templates/CLAUDE.en.md`

Maintenance commands such as "recompile wiki" or "update index" are specified as behaviors the agent should perform. There is no repository code implementing these commands. Recovery is therefore procedural: the agent reconstructs wiki pages from raw sources and preserves `wiki/synthesis/`.

## 6. State and Persistence Model

State is entirely filesystem-based.

### 6.1 State Ownership

- `raw/`: immutable source-of-truth state owned by human-curated ingest plus agent write-once behavior.
- `wiki/`: mutable derived state owned by the LLM.
- `wiki/_index.md`: navigation state summarizing the current wiki graph.
- `wiki/_log.md`: chronological operational state for continuity across sessions.
- `wiki/synthesis/`: durable archive of prior synthesized answers; explicitly excluded from full regeneration.

### 6.2 State Transition Model

The template defines a one-way semantic flow:

`raw source -> summary -> entities/concepts -> comparisons/overviews -> optional synthesis`

Only summaries directly reference raw files. Derived pages cross-link among themselves using `[[folder/name]]`.

### 6.3 Persistence Characteristics

- plain markdown and local assets;
- frontmatter carries page type, dates, tags, aliases, and raw-source linkage;
- no database, queue, cache, or lock file;
- Git history is implicitly part of the durability model.

### 6.4 Recovery Semantics

**Observed rule:** most wiki pages are regenerable from raw inputs; synthesis is not.  
**Inferred implication:** if the wiki drifts or degrades, the recovery path is "rebuild derived pages from `raw/` and preserved synthesis," not "restore application state."

### 6.5 Synchronization and Concurrency

No concurrency model is implemented. Simultaneous edits by multiple agents or humans would rely on Git and normal file-merge behavior. There is no conflict resolution logic inside the project.

## 7. Coordination and Control Semantics

Execution authority is centralized in the **external agent session plus the template instructions**.

### 7.1 Control Topology

- **Human operator** chooses the high-level intent: ingest, query, lint, recompile.
- **Template** maps that intent to a file-operation workflow.
- **External LLM CLI** executes the workflow using its tools.
- **Filesystem** stores durable state for the next session.

This is a centralized, directive control model rather than an event-driven or distributed one.

### 7.2 Routing Semantics

Routing is mostly static and intent-driven:

- "ingest/save/capture" -> ingest pipeline;
- questions -> query pipeline;
- "lint wiki" -> health-check pipeline;
- "recompile wiki" / "update index" -> maintenance pipeline.

Within query flow, `_index.md` is the primary retrieval router. That is the repo's substitute for a formal search subsystem.

### 7.3 Work Delegation

The repo delegates almost everything operationally meaningful to the agent:

- content fetching;
- entity/concept extraction;
- deduplication;
- contradiction detection;
- archive decisions.

Because these are not encoded as scripts, delegation is soft and instruction-based.

### 7.4 Failure Propagation

Failures are operational rather than programmatic:

- if the agent misnames a file, link topology breaks;
- if the agent forgets to update `_index.md`, query routing degrades;
- if the agent edits `raw/`, core invariants are violated;
- if tooling access is missing, ingest and lint become partial or impossible.

There is no retry, cancellation, or compensation logic beyond the agent deciding to fix its own prior output.

### 7.5 Coordination Maturity

This control model is elegant but lightly enforced. It is best viewed as a disciplined workflow contract, not a hardened orchestration engine.

## 8. Configuration and Environment Model

### 8.1 Required Configuration

There are effectively no environment variables. Required configuration is structural:

- a compatible rules file (`CLAUDE.md` or `AGENTS.md`);
- the expected directory layout under `raw/` and `wiki/`;
- an agent CLI capable of reading project rules and editing local files.

### 8.2 Bootstrap-Time Configuration

`install.sh` accepts:

1. target directory name;
2. language choice (`en` or `zh`).

That is the only explicit configuration surface implemented in code.

### 8.3 Runtime Assumptions

The runtime assumes the agent host can:

- fetch web content;
- save files locally;
- inspect markdown and images;
- search the repository;
- follow long-lived conversational instructions.

These are external capabilities, not provided by this repo.

### 8.4 Optional Tooling

`README.md` treats Obsidian, Logseq, VS Code + Foam, and plain CLI tools as optional browsing layers. They are viewers, not system dependencies.

### 8.5 Missing Configuration Surfaces

There is no local configuration for:

- models/providers;
- API keys;
- storage backends;
- search indexing;
- observability;
- policy tuning beyond editing the template itself.

## 9. Operational Usage Model

### 9.1 Canonical User Workflow

The intended operational sequence is:

1. bootstrap a new knowledge-base directory using `install.sh` or the manual steps;
2. launch an LLM CLI in that directory;
3. ingest sources one at a time using natural-language commands;
4. inspect the generated wiki in a markdown editor;
5. ask questions against the compiled wiki;
6. optionally archive good synthesized answers;
7. periodically ask the agent to lint the wiki.

### 9.2 Actual Runtime Interaction Pattern

This is a conversational file-maintenance loop. The user does not operate menus, HTTP APIs, or subcommands after setup. Instead, the operator gives semantic intents in natural language and expects the agent to translate them into file-system operations consistent with the template.

### 9.3 Development Workflow for This Repository

For maintainers of this repository itself, the main work appears to be:

- evolve `templates/CLAUDE*.md`;
- keep `README*` aligned with the template;
- keep `install.sh` aligned with the template's directory model;
- seed or refresh `examples/` to demonstrate the current schema.

### 9.4 Production vs Development Distinction

There is no strong production/development separation inside the repo. The same template governs both experimentation and long-lived usage. The difference is likely the operator's discipline and the maturity of the resulting knowledge base, not a runtime mode switch.

## 10. Extension and Customization Architecture

There is no plugin framework. Extension happens through **schema editing**.

### 10.1 Primary Extension Mechanisms

1. Edit `templates/CLAUDE.en.md` and `templates/CLAUDE.md` to add folders, rules, or workflows.
2. Update `install.sh` so new knowledge bases instantiate the revised structure.
3. Update `README.md` and the example instance so operational docs match the new behavior.

### 10.2 Effective Contracts

The most important contracts are conventional:

- page naming conventions;
- frontmatter shape;
- `[[folder/name]]` link syntax;
- raw immutability;
- index-first query routing;
- append-only `_log.md`.

Breaking any of these changes the de facto API between the agent, the filesystem, and human operators.

### 10.3 Extension Difficulty

- **Easy:** add new instructions, tags, or page templates.
- **Moderate:** add new page categories or revise topology, because docs, bootstrap, and examples must stay aligned.
- **Hard:** add trustworthy automation or enforcement, because the current design intentionally avoids local runtime code.

### 10.4 Inferred Evolution Path

The likely growth path is to keep the markdown-centered model but add helper tools around it: validators, better search, or CLI adapters. The template itself mentions optional tooling ideas, but those are not implemented here.

## 11. Key Architectural Decisions and Tradeoffs

### 11.1 Markdown as the Persistence Layer

**Observed choice:** everything is stored in markdown plus local assets.  
**Tradeoff:** maximum portability and inspectability, minimal infra, but weak guarantees and no structured query engine.

### 11.2 Prompt File as the Program

**Observed choice:** `README.md` explicitly states the template is the entire program.  
**Tradeoff:** cross-CLI portability and fast iteration, but runtime correctness depends on prompt adherence rather than code enforcement.

### 11.3 Raw/Wiki Separation

**Observed choice:** raw is immutable, wiki is regenerable.  
**Tradeoff:** good provenance and recovery model, but the repo depends on operator discipline because immutability is not technically enforced.

### 11.4 Index and Log Instead of RAG Infrastructure

**Observed choice:** `_index.md` and `_log.md` are the navigation and continuity primitives.  
**Tradeoff:** simple and grep-friendly at small to moderate scale, but scaling quality depends on the agent's ability to maintain them.

### 11.5 CLI-Agnostic Compatibility via `CLAUDE.md` / `AGENTS.md`

**Observed choice:** bootstrap creates both names from the same template.  
**Tradeoff:** portability across tool ecosystems, but still bounded by each tool's project-rule-file semantics.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 No Mechanical Enforcement

The biggest weakness is structural: the repository defines many rules but provides almost no code to enforce them. Broken links, duplicate entities, stale `_index.md`, or accidental raw edits are all possible.

### 12.2 Unix-Centric Bootstrap

`install.sh` assumes `bash`, `curl`, and symlink support. There is no repository-provided Windows-native path, despite the concept being otherwise platform-neutral.

### 12.3 Documentation-Heavy, Tool-Light

The repo documents ingest, lint, and regeneration flows in detail, but none of them exist as scripts or commands. This is intentional, yet it means operational maturity depends on the host agent rather than the repository itself.

### 12.4 Limited Example Coverage

The sample knowledge base demonstrates summary/entity/concept generation well, but not:

- comparisons;
- overviews;
- synthesis archives;
- multi-article deduplication behavior;
- large-scale navigation behavior.

### 12.5 Soft Schema Consistency

Frontmatter conventions and topology are described clearly, but there is no schema checker. Drift between template, example, and future generated content is a realistic maintenance risk.

### 12.6 External Runtime Dependence

The project's core feature set only exists when paired with a capable agent CLI. Without that host, the repo is a template plus sample data.

### 12.7 License Metadata Drift

`README.md` claims the project is MIT-licensed, but no top-level `LICENSE` file is present in the current workspace snapshot. That may be an accidental omission or a workspace inconsistency, but as checked out it is a documentation-to-repo mismatch.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Run the bootstrap command from `README.md`.
2. Enter the generated directory.
3. Launch an LLM CLI that reads `CLAUDE.md` or `AGENTS.md`.
4. Ingest one article.
5. Inspect `raw/`, `wiki/_index.md`, `wiki/_log.md`, and the generated summary/entity/concept pages.

### Operational Assumptions

- The operator is comfortable steering an agent through natural-language requests.
- The agent can edit local files and fetch sources.
- The knowledge base will remain small enough that index-first navigation is still effective.
- Git or another backup mechanism will provide the safety net for mistakes.
- The operator will periodically review generated wiki pages rather than fully trusting unattended updates.

### Canonical Workflow

The repo's intended loop is:

`ingest source -> review generated pages -> ask questions -> optionally archive synthesis -> lint periodically`

This is exactly the workflow encoded in the template and exemplified by `examples/wiki/`.

### Advanced Usage

Advanced use is mainly structural rather than infrastructural:

- maintain richer entity/concept networks over time;
- add new wiki page categories by editing the template;
- use external editors like Obsidian to browse graph structure while the agent maintains files;
- seed additional example corpora to demonstrate better multi-source behavior.

### Extension Workflow

For repository maintainers:

1. modify `templates/CLAUDE.en.md` / `templates/CLAUDE.md`;
2. reflect schema changes in `install.sh`;
3. update `README.md` / `README.zh-CN.md`;
4. refresh `examples/` so the sample output matches the documented pattern.

### Debugging Workflow

Because there are no runtime logs or tests, debugging is mostly artifact inspection:

1. read `wiki/_log.md` to understand recent operations;
2. inspect `wiki/_index.md` to see whether navigation state is accurate;
3. compare generated pages against raw sources;
4. check whether file names, frontmatter, and links follow the template;
5. trace problems back to the rules in `templates/CLAUDE.en.md`.

### Observability

Observability is minimal and file-based:

- `wiki/_log.md` is the operation timeline;
- `wiki/_index.md` is the current content map;
- Git diff/history is the practical audit trail;
- the example wiki provides a reference output for regression-by-comparison.

### Failure Modes

Most likely failure modes are:

- malformed or inconsistent markdown/frontmatter;
- duplicate entity/concept pages due to weak deduplication;
- stale index/log state after partial operations;
- agent answers that do not archive important synthesis;
- divergence between the written schema and actual generated content.

### Performance Considerations

The design avoids backend complexity, but performance scales with agent attention rather than computation. As the wiki grows:

- `_index.md` becomes more important and harder to maintain;
- manual/agent lint passes become more expensive;
- the absence of search tooling becomes more noticeable.

The current repo acknowledges this indirectly by centering the index and keeping optional tooling out of scope.

## 14. Project Navigation Guide

### Best Reading Order

1. `README.md` - what the repo is and how it is supposed to be used.
2. `install.sh` - what is actually instantiated on disk.
3. `templates/CLAUDE.en.md` - the real behavior contract.
4. `examples/wiki/_log.md` - what one real ingest operation looked like.
5. `examples/wiki/_index.md` - how the knowledge base is navigated.
6. `examples/raw/2026-02-11-harness-engineering.md` - the raw-source format.
7. `examples/wiki/summaries/2026-02-11-harness-engineering.md` - summary semantics.
8. `examples/wiki/entities/Codex.md` and `examples/wiki/concepts/Harness Engineering.md` - accumulated entity/concept semantics.

### Highest-Value Semantic Centers

- `templates/CLAUDE.en.md`: all important rules live here.
- `install.sh`: the only executable bootstrap logic.
- `examples/wiki/`: the best evidence of how the template manifests in practice.

### Where Abstractions Become Concrete

- The template names the abstractions (`raw`, `wiki`, `_index`, `_log`, summaries, entities, concepts).
- `install.sh` concretizes them as directories and files.
- `examples/` shows their populated form after a real ingest.

### Low-Signal Areas

- `.github/agents/` and `.github/prompts/` are currently peripheral to the repo's core behavior.
- There is no hidden `src/` or test suite containing additional runtime logic.

## 15. Concise Deep Technical Synthesis

This project is best understood as a **portable prompt-program for a markdown-native knowledge base**. It takes an abstract idea about LLM-maintained personal wikis and instantiates it as a small set of conventions, a bootstrap shell script, and a worked example. Its architecture is unusual because the semantic core is not source code but instruction text: the agent host is the runtime, the template is the controller, and the filesystem is the database.

What makes it distinctive is the deliberate refusal to build traditional infrastructure. There is no vector DB, no backend, no ingest worker, and no custom indexer. Instead, the repo encodes a disciplined operational model around immutable raw sources, regenerable derived pages, a content index, and a chronological log. That makes the system easy to inspect, easy to port across LLM CLIs, and easy to adapt by editing markdown. It also makes the system only as reliable as the agent executing those rules.
