---
repo: https://github.com/zhurudong/andrej-karpathy-llm-wiki
---

## 1. Repository Purpose

This repository does not implement an LLM knowledge base as a running application. It packages a reusable operating pattern for one. The concrete deliverables are a bootstrap script in install.sh, bilingual prompt schemas in CLAUDE.en.md and CLAUDE.md, and a worked example in examples.

Observed: the repo creates a filesystem scaffold, downloads a rules file, and relies on an external LLM CLI to perform ingest, query, lint, and maintenance. Inference: the real problem it solves is not “serve knowledge-base queries” but “turn a generic coding/chat agent into a disciplined wiki maintainer using only markdown and conventions.”

Scope boundaries are tight:
- In scope: directory conventions, page types, lifecycle rules, bootstrapping, cross-CLI compatibility, example outputs.
- Out of scope: automatic ingestion pipeline, search service, vector DB, web backend, local daemon, deterministic compiler, validation tooling.

## 2. High-Level System Model

The best mental model is: a prompt-programmed, filesystem-native knowledge compiler whose execution engine is outsourced to whichever LLM CLI reads the schema.

Architecturally, the dominant identity is schema-centric and orchestration-by-instruction. The behavioral intelligence lives primarily in CLAUDE.en.md, not in code. install.sh only bootstraps the workspace. The “runtime” is the loop of human instruction → LLM reads rules and files → LLM mutates markdown state.

The runtime topology is simple:
- Persistent state: markdown files under raw/ and wiki/.
- Control plane: the rules file read by the agent.
- Execution engine: Claude Code, Codex CLI, OpenCode, or similar, as described in README.md.
- Human role: curate sources, ask questions, review results.
- LLM role: perform bookkeeping, synthesis, and graph maintenance.

The semantic center is the contract between page types and workflows:
- Immutable factual substrate in raw/.
- Regenerable interpretation layer in wiki/.
- Index and log as navigation/control aids.
- Cross-links as the graph.
- Git and editor tooling as the operational shell.

## 3. Conceptual Capability Mapping

| Capability | Status | Where Implemented | Execution Semantics | Limits |
|---|---|---|---|---|
| Bootstrap a new KB | Implemented | install.sh | Creates directories, fetches template, creates AGENTS symlink, seeds empty index/log | Unix-oriented shell only |
| Cross-CLI rules portability | Implemented | README.md, install.sh | Same schema exposed as CLAUDE.md and AGENTS.md | Depends on CLI honoring project rules files |
| Ingest workflow | Specified, not automated | CLAUDE.en.md | LLM fetches source, saves raw, compiles wiki pages, updates index/log | No enforcement, retries, or transactionality |
| Query workflow | Specified, not automated | CLAUDE.en.md | Read index first, then targeted pages, then synthesize answer, optionally archive | Quality depends on agent compliance and prompting |
| Lint workflow | Specified, not automated | CLAUDE.en.md | Structural/content review done by LLM over files | No shipped validator |
| Persistent wiki graph | Implemented as file contract | _index.md, _log.md, [examples/wiki/concepts/Harness Engineering.md](examples/wiki/concepts/Harness Engineering.md) | Cross-links and frontmatter encode graph and metadata | Manual/LLM maintenance only |
| Example compiled knowledge | Implemented | 2026-02-11-harness-engineering.md and wiki | Demonstrates one ingest end-to-end | Small sample only |
| Multilingual templates | Implemented | CLAUDE.en.md, CLAUDE.md, README.md, README.zh-CN.md | Installer chooses `en` or `zh` template | Example corpus is Chinese-only |
| Optional search/slide/plugin tooling | Not implemented here | Only mentioned conceptually in user idea, not shipped in repo | External addition expected | No integrated search or presentation generation |

## 4. Architecture and Component Analysis

The repository has four meaningful components.

install.sh is the only executable code. It owns environment bootstrap only:
- Creates the canonical folder tree.
- Downloads the chosen template from GitHub.
- Creates the AGENTS symlink.
- Seeds empty wiki/_index.md and wiki/_log.md in the new instance.
This is foundational infrastructure, not domain logic.

CLAUDE.en.md and CLAUDE.md are the real program:
- They define invariants, page types, naming rules, link topology, ingest/query/lint behavior, and maintenance commands.
- They also define the control strategy: read log on session start, read index first on query, preserve raw immutability, regenerate derived knowledge from raw.
- This is the orchestration/control layer and semantic core.

examples is the concrete model of expected steady-state behavior:
- 2026-02-11-harness-engineering.md shows raw-source storage and image references.
- 2026-02-11-harness-engineering.md shows summary style and opinionated analysis.
- Codex.md and the concept pages show cross-linking and incremental accumulation.
- _index.md and _log.md show the navigation and temporal ledgers.
This is the domain-output layer.

README.md and README.zh-CN.md are operator documentation:
- They explain what to do, which CLIs can consume the template, and how the repo relates to the underlying idea.
- They are important for usage, but they do not govern runtime behavior unless the human follows them.

Incidental rather than central:
- .github contains Copilot prompt/agent metadata for this workspace, not part of the published wiki pattern.
- There are no tests, libraries, services, package manifests, or CI workflows governing the wiki logic.

## 5. Execution Flow Analysis

Startup and bootstrap:
- Operator runs the installer from install.sh, typically via the curl pipe shown in README.md.
- The script creates raw/, wiki/, and all page-type subdirectories.
- It fetches one schema file into CLAUDE.md and symlinks AGENTS.md to it.
- It creates blank index and log files.
- Control then leaves the repository’s code entirely and moves into the external LLM CLI.

Session initialization in a live knowledge base:
- The template requires the agent to read wiki/_log.md first.
- This makes the log a continuity mechanism, not just an audit trail.
- Observed in the schema, not enforced by code.

Ingest flow:
- Human says “ingest” or similar.
- Agent fetches the URL using whatever tools its host environment provides.
- Agent writes an immutable raw markdown source and attachments.
- Agent compiles derived pages: one summary, zero or more entity updates, zero or more concept updates, maybe a comparison, maybe an overview.
- Agent rebuilds wiki/_index.md and appends wiki/_log.md.
- The sample ingest in _log.md shows exactly one such run.

Query flow:
- Agent reads wiki/_index.md first.
- It then performs targeted reads of relevant summaries/entities/concepts.
- It synthesizes an answer and may suggest archiving it into synthesis/ if it spans multiple pages.
- This is effectively a manual retrieval plan encoded in the prompt rather than a search subsystem.

Lint flow:
- Agent performs structural checks such as broken links and orphan detection.
- It then performs higher-order semantic checks such as stale claims or contradictions.
- It returns proposed fixes rather than applying them immediately.
- This flow is a human-reviewed maintenance pass, not autonomous repair by default.

Recovery and regeneration:
- The template explicitly permits recompile from raw for summaries/entities/concepts/comparisons/overviews.
- Synthesis is treated differently: it is query-derived and retained.
- This gives the system a recoverable derived layer without needing a separate database.

## 6. State and Persistence Model

State is entirely file-backed.

Persistent state categories:
- Immutable facts: raw sources in raw.
- Mutable derived understanding: pages under wiki.
- Navigation state: _index.md.
- Timeline state: _log.md.

State ownership:
- Humans own source curation and typically initiate ingest/query/lint.
- The LLM owns wiki derivation and maintenance.
- raw/ is declared human-write-on-ingest then immutable.
- wiki/ is declared LLM-owned and regenerable.

State transitions:
- Source added to raw.
- Derived graph expanded or updated.
- Index rewritten.
- Log appended.
- Optional synthesis added from answers.

Persistence semantics:
- Durability comes from the filesystem and, implicitly, Git.
- There is no cache layer, lock manager, or snapshot/rollback support.
- Recovery strategy is conceptual recompilation from raw, not transaction logs or checkpoints.

A notable design choice is that source provenance is page-local and human-readable rather than normalized into a machine-enforced schema. That keeps the system transparent but weakens deterministic tooling.

## 7. Coordination and Control Semantics

Execution authority is centralized in the external LLM agent, guided by the template and triggered by the human.

This is a directive control model:
- Human issues intent.
- Template routes the agent’s behavior.
- Filesystem provides the working memory and state boundary.
- Agent performs reads/writes using its host tools.

Work routing is dynamic and tool-agnostic:
- The template says “use available tools” for fetch/search/lint tasks.
- It does not prescribe one fetcher, one search engine, or one host platform.
- That increases portability, but runtime behavior varies by host agent capabilities.

Concurrency model:
- The repository itself has none.
- There are no queues, workers, schedulers, or locks.
- Coordination is effectively single-operator, single-agent, file-mediated.
- If multiple humans or agents operate concurrently, conflict resolution is delegated to Git and human workflow discipline.

Failure propagation:
- If ingest is partial, there is no automatic compensation.
- If the agent misses a rule, there is no runtime guardrail except human review.
- Deduplication, link integrity, and freshness are policy obligations, not enforced invariants.

This is the repo’s core tradeoff: centralized semantic control through instructions, decentralized execution through whatever agent/tool stack the operator happens to use.

## 8. Configuration and Environment Model

Required configuration is minimal:
- Directory name and template language are provided to install.sh.
- The live knowledge base requires an LLM CLI that reads CLAUDE.md or AGENTS.md, as documented in README.md.

Operational prerequisites:
- Bash-compatible shell.
- `curl`.
- `ln` support for symlinks.
- Internet access for template download and most ingest flows.
- An agent environment with file and fetch capabilities.

Optional environment:
- Obsidian, Logseq, or Foam for browsing, per README.md.
- Git for versioning and collaboration.

Notably absent:
- No environment variables.
- No provider/model config in the repo.
- No pluggable backend configuration.
- No deployment modes.
- No local search binary.

Windows-specific inference: because the only installer is Bash and it relies on symlinks, the repo is friendlier to macOS/Linux or Windows with WSL/Git Bash than to native PowerShell-only environments.

## 9. Operational Usage Model

The intended workflow is lightweight and conversational rather than system-administrative.

Canonical operator loop:
- Bootstrap a wiki with install.sh.
- Open the directory in an editor.
- Launch an LLM CLI in that directory.
- Ingest one source at a time.
- Read the generated pages as they appear.
- Ask questions against accumulated pages.
- Periodically run lint and, when needed, recompile or update index.

The repo itself is used in two different ways:
- As a template source: copy/fetch CLAUDE.en.md or use the installer.
- As a reference implementation: inspect wiki to see what “good output” looks like.

This is not a production deployment model. There is no daemon, no API endpoint, and no background service. The practical usage model is “LLM-assisted authoring inside a normal folder.”

## 10. Extension and Customization Architecture

Customization is prompt-first.

The primary extension point is the schema file:
- Add new page types.
- Change frontmatter fields.
- Alter ingest/query/lint workflows.
- Tighten source handling rules.
- Localize language and naming conventions.

The secondary extension point is the directory structure itself:
- The wiki graph is just folders and markdown files.
- Adding new folders is easy, but the agent must be taught their semantics in the template.

Cross-CLI adaptation is handled by the CLAUDE.md / AGENTS.md alias strategy in install.sh and README.md. That is the closest thing the repo has to an adapter layer.

What is not present:
- No plugin registry.
- No code hooks.
- No formal provider interface.
- No machine-readable extension API.
- No guaranteed compatibility contract beyond prompt wording.

Inference: the system expects to evolve mostly by editing instructions, not by adding software components.

## 11. Key Architectural Decisions and Tradeoffs

The biggest decision is to encode behavior in markdown instructions rather than executable logic.
- Benefit: extreme portability, transparency, and hackability.
- Cost: weak enforcement and highly variable runtime behavior.

The second major decision is raw/ vs wiki/ separation.
- Benefit: clear distinction between immutable fact and mutable interpretation.
- Cost: regeneration is social/procedural, not automatic; drift can still occur.

The third is using index/log instead of heavier retrieval infrastructure.
- Benefit: no embeddings, no database, easy inspection, good enough at modest scale.
- Cost: scaling depends on disciplined summarization and the agent’s ability to navigate files.

The fourth is using the repo as both product and specification.
- Benefit: the sample wiki makes the abstract pattern concrete.
- Cost: the sample is tiny, so many scale assumptions remain untested inside this repo.

The fifth is multilingual templates.
- Benefit: broader usability.
- Cost: doubles prompt-maintenance surface and invites divergence over time.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

The largest gap is that almost all operational guarantees are advisory, not enforced. CLAUDE.en.md describes deduplication, link correctness, frontmatter, and lint behavior, but the repo ships no validator to ensure those things happen.

There is no automated ingestion/search/lint implementation. The idea file mentions optional search tooling like qmd, but this repository does not ship any such integration. That means the “system” is only as reliable as the chosen LLM host.

There are no tests and no CI workflows for the core template semantics. Observed: file search results show no package manifests and .github contains prompts/agents, not workflows. This makes regressions in the prompt template hard to detect mechanically.

The installer is operationally narrow:
- Unix shell only.
- Symlink requirement may be awkward on some Windows setups.
- No native PowerShell installer.

The sample is informative but thin:
- One raw article.
- One summary.
- Three entities.
- Three concepts.
That is enough to demonstrate conventions, not enough to validate overview generation, synthesis archiving, or multi-source contradiction handling.

A documentation inconsistency: README.md claims MIT licensing, but the repository tree shown in the workspace does not include a LICENSE file. That may just be omitted in the current checkout, but based on observed files it is a real packaging gap.

Small ambiguity: CLAUDE.md resolves as a relative reference to the shared template rather than a standalone copy. Inference: the example is intended to share the root template via symlink or link-like file entry. That is efficient, but it can be brittle across platforms and tooling.

## 13. Practical Usage Guide

Minimal viable usage:
- Run the bootstrap command from README.md.
- Enter the new directory.
- Start a supported LLM CLI.
- Ingest one article.
- Confirm that raw/, summary, entity/concept pages, index, and log are all updated.

Operational assumptions:
- Moderate corpus size where index-first navigation is still workable.
- An operator comfortable reviewing markdown diffs.
- A local editor with good file navigation.
- Reliable agent access to file and web tools.
- Willingness to treat git history as the audit trail.

Canonical workflow:
- Curate a source.
- Ingest it with the agent.
- Review the generated summary and graph updates.
- Ask follow-up questions.
- Archive multi-page insights into synthesis when valuable.
- Periodically lint and repair drift.

Advanced usage:
- Split templates per domain.
- Add stricter frontmatter and Dataview-style metadata conventions.
- Integrate external search tools outside this repo.
- Use Git branches and pull requests if multiple people co-maintain a wiki.

Extension workflow:
- Edit CLAUDE.en.md or CLAUDE.md.
- Update README.md if workflow assumptions change.
- Refresh or expand examples so the sample remains representative.

Debugging workflow:
- Start with _log.md or the instance’s current log to reconstruct recent actions.
- Check _index.md for missing pages or broken categorization.
- Compare raw source vs summary vs entity/concept pages to see whether extraction or integration failed.
- Inspect the template for the relevant workflow rule before blaming the agent host.

Observability:
- Primary observability is file state and git diff.
- Secondary observability is the append-only log.
- There are no built-in traces, metrics, or structured runtime logs.

Failure modes:
- Partial ingest leaves raw and wiki out of sync.
- Agent ignores or incompletely follows schema.
- Broken wiki-links accumulate without detection.
- Duplicate entity/concept pages emerge if search-before-create is skipped.
- Large corpora may outgrow manual index-first navigation.

Performance considerations:
- Cheap at small scale because everything is plain files.
- Human review, not computation, is the main bottleneck.
- As corpus size grows, lack of built-in search becomes the likely pain point before storage or compute do.

## 14. Repository Navigation Guide

Best reading order for a new engineer:
1. README.md to understand product positioning and operator expectations.
2. install.sh to see what the repo actually creates.
3. CLAUDE.en.md for the real control logic.
4. _log.md to see an actual ingest event.
5. _index.md to understand navigation and page taxonomy.
6. 2026-02-11-harness-engineering.md and 2026-02-11-harness-engineering.md to compare source vs derived summary.
7. Codex.md and [examples/wiki/concepts/Harness Engineering.md](examples/wiki/concepts/Harness Engineering.md) to see accumulation and linking.

Highest-value semantic centers:
- CLAUDE.en.md: workflow semantics and invariants.
- install.sh: actual scaffold creation and portability assumptions.
- wiki: output contract and page semantics.

Where abstractions become concrete:
- The abstract idea in the prompt becomes filesystem layout in install.sh.
- The workflow model becomes agent instructions in CLAUDE.en.md.
- The intended outputs become concrete in wiki.

## 15. Concise Deep Technical Synthesis

Fundamentally, this repository is a prompt-defined operating system for a markdown knowledge base. It is not an app, service, or ingestion engine; it is a compact protocol that tells a general-purpose LLM agent how to behave like a disciplined wiki maintainer over a folder tree. Its distinctive choice is to treat the rules file as the runtime, the filesystem as the database, wiki-links as the graph, and Git/editor tooling as the surrounding platform. That makes it unusually portable and transparent, and also unusually dependent on human discipline and agent compliance. It appears optimized for technically literate users who value inspectable artifacts and low infrastructure overhead more than deterministic automation.

No tests or executable validations were run because the repository does not contain a test suite or application runtime beyond the bootstrap shell script.

Natural next steps:
1. Expand the sample under examples with at least 3 related sources so overview generation and contradiction handling become observable rather than aspirational.
2. Add a lightweight validator script for broken links, required frontmatter, and index/log consistency so the prompt contract gains mechanical enforcement.
3. Add a Windows-native bootstrap path and a LICENSE file to close the two most obvious packaging gaps.