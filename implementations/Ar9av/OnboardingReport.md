---
repo: Ar9av/obsidian-wiki
---

# obsidian-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

`obsidian-wiki` is not a conventional application. **Observed:** the behavioral core lives in 31 canonical skill definitions under `.skills/*/SKILL.md`, with `llm-wiki`, `wiki-ingest`, `wiki-query`, `wiki-status`, and `wiki-update` defining the shared runtime contract and the main read/write flows. The repo acts as a **prompt-defined workflow library plus distribution package**: an external coding agent reads these markdown skills, operates on a user-owned Obsidian vault, and persists state there.

The dominant architecture is **orchestration-by-instructions** rather than orchestration-by-code. State is externalized into the vault (`index.md`, `log.md`, `hot.md`, `.manifest.json`, page frontmatter), while the repo contributes schema, routing, and setup/bootstrap logic. The primary semantic center is therefore **the vault maintenance protocol**, not the shell/Python helper scripts.

**Maturity assessment:** operationally usable for agent-driven workflows, but heavily dependent on model compliance and prompt quality. Deterministic code exists mainly for installation (`setup.sh`), reminders (`scripts/daily-update.sh`, `scripts/wiki-notify.sh`), and the auxiliary `skill-creator` tooling. There are no repo-level tests or build manifests.

### Quick Adaptation Assessment

The repo is easy to extend **if** changes fit the existing pattern: add or revise a skill under `.skills/`, keep config resolution aligned with `.skills/llm-wiki/SKILL.md`, and preserve the special-file maintenance contract (`.manifest.json`, `index.md`, `log.md`, `hot.md`). It is harder to modify safely when the change affects cross-skill invariants, because there is no compiled enforcement layer; consistency is maintained by duplicated written instructions across many skills.

The highest-coupling points are:

- `.skills/llm-wiki/SKILL.md` — shared schema, link-format rules, retrieval-cost discipline, config resolution.
- Vault special files and page frontmatter schema.
- Agent discovery/bootstrap layout managed by `setup.sh`.

### Fastest Path to First Successful Run

The shortest realistic path is:

1. Set `OBSIDIAN_VAULT_PATH` in `.env` (or install via `npx skills add Ar9av/obsidian-wiki`, which README recommends).
2. Make the `.skills/` directory discoverable to your agent.
3. Run the `wiki-setup` workflow by telling the agent **"set up my wiki"**.
4. Open the target vault in Obsidian; then use `wiki-status`, `wiki-ingest`, or `wiki-query`.

Minimum runtime requirements are an AI coding agent with file read/write/search capability and a writable vault directory. No server, package install, or database is required for the core workflows.

### Minimal Manual Setup Path

You can bypass `setup.sh`.

1. Create either a local `.env` or `~/.obsidian-wiki/config` containing at least `OBSIDIAN_VAULT_PATH=...`.
2. Point your agent at this repo's `.skills/` directory using its native skill-discovery mechanism.
3. Ensure the agent also sees the appropriate always-on context file (`AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/obsidian-wiki.mdc`, etc.).
4. Invoke `wiki-setup` directly.

This manual path is often more portable than `setup.sh`, which assumes Unix tooling (`bash`, `ln -s`, `sed`) and, for the reminder feature, macOS `launchd`.

### Operational Complexity Snapshot

Setup complexity is low for core use and medium for full cross-agent installation. Runtime coordination is conceptually simple but operationally **prompt-fragile**: there is no executable engine enforcing the workflows. Debugging usually means reading the relevant skill file and the vault artifacts it should have updated, not stepping through code. Observability is mostly by inspection of `log.md`, `.manifest.json`, `hot.md`, and generated vault pages; deterministic logging inside the repo is minimal.

## 1. Repository Purpose

**Observed purpose:** this repo packages a repeatable implementation of Karpathy's “LLM Wiki” pattern for Obsidian. The README and `SETUP.md` frame it as a skill-based framework; the concrete implementation confirms that by storing the operational logic in markdown skills under `.skills/` and by distributing those skills to many agents via `setup.sh`.

The repo's actual problem statement is narrower than “build a personal knowledge base.” It solves:

- how an agent should structure and maintain an Obsidian vault;
- how ingest/query/lint/rebuild/update workflows should behave;
- how to route user intent to those workflows across multiple agent products;
- how to persist ingest/query state without a separate service.

Relative to the conceptual Karpathy gist, this repo **specializes and operationalizes** the idea by adding:

- a fixed vault schema and page frontmatter contract;
- delta tracking through `.manifest.json`;
- read-cost discipline for query/lint/status;
- cross-project syncing (`wiki-update`);
- dedicated ingest paths for agent histories (`claude`, `codex`, `copilot`, `hermes`, `openclaw`);
- maintenance workflows like `cross-linker`, `tag-taxonomy`, `wiki-export`, `daily-update`, and `graph-colorize`.

**Scope boundary:** it does not provide a standalone running service, search backend, UI, or plugin. Obsidian is treated as the viewer, the user's vault as the database/artifact store, and the AI coding agent as the execution engine.

## 2. High-Level System Model

The best mental model is:

> **A declarative control plane for AI-maintained knowledge bases, where markdown skills are the runtime policy and the Obsidian vault is the persistent data plane.**

This is an **orchestration-centric, state-externalized workflow system**. The repo does not own the event loop; the external agent does. The repo contributes:

- a canonical schema (`.skills/llm-wiki/SKILL.md`);
- a catalog of workflows (`.skills/*/SKILL.md`);
- agent-specific discovery/bootstrap wiring (`setup.sh`, bootstrap files, rule files);
- a small amount of helper automation (`scripts/`, `skill-creator` utilities).

The dominant concerns are:

1. **How knowledge should be represented** in the vault.
2. **How work should be routed** from user phrasing to a skill.
3. **How read/write operations should update shared state** consistently.
4. **How large-vault cost should be controlled** through tiered retrieval rather than full scans.

The project's behavioral intelligence primarily lives in:

- `.skills/llm-wiki/SKILL.md` — global invariants and shared contracts.
- `.skills/wiki-ingest/SKILL.md` — main write path for new knowledge.
- `.skills/wiki-query/SKILL.md` — main read path with escalating retrieval cost.
- `.skills/wiki-status/SKILL.md` — manifest-driven delta and graph analysis.
- History-ingest skills — provider-specific parsing strategies.

Shell and Python are secondary; they automate environment setup and meta-workflows, but they do not define the main knowledge-processing semantics.

## 3. Conceptual Capability Mapping

| Conceptual capability | Status | Implementation owner | Concrete mechanism | Limits / notes |
|---|---|---|---|---|
| Persistent compiled wiki instead of ad hoc RAG | **Implemented as policy** | `.skills/llm-wiki/SKILL.md`, `wiki-ingest`, `wiki-query` | Pages with frontmatter, `index.md`, `log.md`, `hot.md`, `.manifest.json`; update-in-place rules | Enforced by agent compliance, not code |
| Vault initialization | **Implemented** | `.skills/wiki-setup/SKILL.md` | Creates folders, `index.md`, `log.md`, `hot.md`, minimal `.obsidian` config | Manual/agent-driven; no deterministic generator in repo |
| Delta ingest of documents | **Implemented as policy** | `.skills/wiki-ingest/SKILL.md` | Compare source paths + `content_hash`/mtime in `.manifest.json`; update pages; rewrite special files | Hashing and deletion safety are described, not implemented centrally |
| Querying compiled knowledge | **Implemented as policy** | `.skills/wiki-query/SKILL.md` | Index pass → optional QMD pass → section grep → full reads; cite `[[wikilinks]]` | Runtime quality depends on agent executing retrieval discipline |
| Delta/status reporting | **Implemented as policy** | `.skills/wiki-status/SKILL.md` | Scans current sources, compares to manifest, recommends append vs rebuild; optional graph insights to `_insights.md` | No shared library; repeated logic across skills |
| Archive/rebuild/restore | **Implemented as policy** | `.skills/wiki-rebuild/SKILL.md` | `_archives/` snapshot layout + restore/rebuild rules | Explicitly requires confirmation; destructive semantics not code-guarded |
| Cross-project knowledge sync | **Implemented as policy** | `.skills/wiki-update/SKILL.md` | Distill current repo into `projects/<name>/`; track `last_commit_synced` in manifest | Useful from any repo after global setup |
| Cross-agent history ingest | **Implemented as policy** | `.skills/wiki-history-ingest`, `*-history-ingest` | Router + per-agent parsers for Claude/Codex/Copilot/Hermes/OpenClaw stores | Parsing is natural-language instruction, not parser code |
| Cross-agent targeted recall | **Implemented as policy** | `.skills/wiki-agent/SKILL.md`, `memory-bridge` | Topic-first session scoring + selective ingest; provenance-based browsing/diff | Advanced but prompt-heavy; relies on manifest/source hygiene |
| Graph maintenance/export | **Implemented as policy** | `cross-linker`, `wiki-export`, `graph-colorize` | Scan wikilinks/tags/categories; edit pages or `.obsidian/graph.json`; emit graph formats | `graph-colorize` touches Obsidian config directly |
| Autonomous web research | **Implemented as policy** | `.skills/wiki-research/SKILL.md` | Multi-round search/fetch/synthesis into references/concepts/entities/synthesis pages | No hard stop beyond written 3-round limit |
| Daily reminder/maintenance | **Partly deterministic** | `.skills/daily-update/SKILL.md`, `scripts/daily-update.sh`, `scripts/wiki-notify.sh` | Shell script computes stale-source count and state files; prompt-on-shell-open reminder | macOS/Unix biased; uses `launchd` in setup path |
| Skill authoring/extensibility | **Implemented, auxiliary** | `.skills/skill-creator/`, Python scripts | Create/eval/package skills, benchmark results, quick validation | This is the main code-heavy subsystem and contradicts the “no code” pitch |
| Repo-specific automation wrapper | **Thin / exploratory** | `.skills/obsidian-wiki-ingest/`, `scripts/ingest-wiki.sh` | High-level wrapper stub around `wiki-ingest` | Script is placeholder-level and not production-ready |

## 4. Architecture and Component Analysis

### 4.1 Canonical skill corpus (`.skills/`)

This is the repository's source of truth. Each skill folder packages one workflow as `SKILL.md`; some add `references/`, `scripts/`, `assets/`, or `agents/`.

Responsibility boundaries:

- **Foundational schema:** `llm-wiki`
- **Core write paths:** `wiki-setup`, `wiki-ingest`, history-ingest skills, `wiki-update`, `wiki-research`
- **Core read/audit paths:** `wiki-query`, `wiki-status`, `wiki-lint`, `memory-bridge`
- **Graph/taxonomy maintenance:** `cross-linker`, `tag-taxonomy`, `wiki-export`, `graph-colorize`
- **Meta-operations:** `wiki-rebuild`, `wiki-switch`, `impl-validator`, `skill-creator`

Architectural significance: **highest**. This is where the repo's effective behavior is specified.

### 4.2 Shared schema contract (`.skills/llm-wiki/SKILL.md`)

This file is effectively the platform specification.

It owns:

- three-layer model (raw sources → wiki → schema);
- vault directory conventions;
- page template;
- provenance markers and frontmatter fields;
- `base_confidence` + `lifecycle` semantics;
- retrieval primitives;
- link-format abstraction (`wikilink` vs `markdown`);
- config resolution protocol.

Other skills depend on it by reference instead of re-defining the core rules. That makes it the main abstraction boundary: if you change the page schema or config algorithm here, multiple skills must stay in sync.

### 4.3 Agent distribution and compatibility layer

`setup.sh`, `.github/copilot-instructions.md`, `.cursor/rules/obsidian-wiki.mdc`, `.agent/rules/obsidian-wiki.md`, `.kiro/steering/obsidian-wiki.md`, and the symlink trees under `.claude/`, `.cursor/`, `.windsurf/`, `.agents/`, `.kiro/` adapt the same canonical skills to multiple agent ecosystems.

Observed behavior:

- `.skills/` is canonical.
- `setup.sh` symlinks those skills into agent-specific discovery locations, both repo-local and global.
- `setup.sh` writes `~/.obsidian-wiki/config` so skills can run from arbitrary projects.
- Bootstraps like `CLAUDE.md`, `GEMINI.md`, and `.hermes.md` are symlinks to `AGENTS.md` in git metadata; on this Windows checkout they appear as tiny placeholder files, while `AGENTS.md` is the actual shared context file.

Architectural role: distribution glue, not semantic core.

### 4.4 Vault state model (external to repo)

The live wiki state is intentionally not stored in the repo. The vault owns:

- compiled pages under category and project folders;
- special files (`index.md`, `log.md`, `hot.md`, `.manifest.json`, `_insights.md`);
- optional taxonomy and dashboard metadata under `_meta/`;
- Obsidian config under `.obsidian/`.

This external state ownership is central: the repo defines how to manipulate the vault, but the vault is the durable artifact.

### 4.5 Operational shell scripts (`setup.sh`, `scripts/*.sh`)

These are the main deterministic operational components.

- `setup.sh` installs skills and config.
- `scripts/daily-update.sh` resolves config, checks stale sources against `.manifest.json`, and writes vault-scoped reminder state.
- `scripts/wiki-notify.sh` is sourced from shell startup and displays stale-vault reminders.
- `scripts/com.obsidian-wiki.daily-update.plist` supports macOS scheduling.

These scripts matter operationally but are still secondary to the markdown skills.

### 4.6 Auxiliary code subsystem: `skill-creator`

`skill-creator` is the main place where this repo becomes a conventional software project. It includes:

- a large meta-skill (`.skills/skill-creator/SKILL.md`);
- helper agents (`agents/*.md`);
- Python scripts for validation, aggregation, packaging, report generation, and eval viewing.

This subsystem is architecturally separate from the wiki runtime: it is a **tool for developing more skills**, not part of normal ingest/query operation.

### 4.7 Thin or exploratory artifacts

`.skills/obsidian-wiki-ingest/SKILL.md` and `.skills/obsidian-wiki-ingest/scripts/ingest-wiki.sh` look more aspirational than mature. The shell script contains hardcoded paths and empty variables, suggesting a stub rather than a real supported runtime path.

## 5. Execution Flow Analysis

### 5.1 Bootstrap / installation flow

**Observed path:** README recommends either `npx skills add Ar9av/obsidian-wiki` or `bash setup.sh`.

`setup.sh` then:

1. Ensures `.env` exists from `.env.example`.
2. Reads or prompts for `OBSIDIAN_VAULT_PATH`.
3. Writes `~/.obsidian-wiki/config` with `OBSIDIAN_VAULT_PATH` and `OBSIDIAN_WIKI_REPO`.
4. Creates `.hermes.md -> AGENTS.md`.
5. Symlinks canonical skills into repo-local agent directories and global agent directories.
6. Prints next-step instructions.

Runtime effect: after setup, the same skill set becomes discoverable from multiple agents and from other repositories.

### 5.2 Config resolution flow

This is the first real runtime step for most skills and is defined centrally in `.skills/llm-wiki/SKILL.md`.

Sequence:

1. Walk upward from current working directory, looking for a `.env` containing `OBSIDIAN_VAULT_PATH`.
2. If none found, fall back to `~/.obsidian-wiki/config`.
3. If still unresolved, tell the user to run `wiki-setup`.
4. After config resolution, `AGENTS.md` instructs the agent to read `$OBSIDIAN_VAULT_PATH/AGENTS.md` when present for vault-owner overrides.

This makes the framework usable both inside the repo and from arbitrary working directories.

### 5.3 Vault initialization flow (`wiki-setup`)

`wiki-setup` instructs the agent to:

1. create `.env` values;
2. create the vault folder structure;
3. create `index.md`, `log.md`, `hot.md`;
4. add minimal `.obsidian` config files;
5. recommend plugins;
6. verify the expected files/directories exist.

There is no deterministic initializer script; initialization is model-executed from the skill spec.

### 5.4 Main ingest flow (`wiki-ingest`)

This is the central write pipeline:

1. Resolve config and read `.manifest.json`, `index.md`, `log.md`.
2. Decide ingest mode: append, full, or raw.
3. Read source files.
4. Extract concepts/entities/claims/relationships/open questions.
5. Decide project scope.
6. Plan pages to create/update.
7. Write or merge pages using required frontmatter, provenance, confidence, lifecycle, links, and optional visibility tags.
8. Update back-links/cross-links.
9. Update `.manifest.json`, `index.md`, `log.md`, `hot.md`.

Critical runtime semantics:

- append mode is manifest-driven;
- `_raw/` promotion deletes only the promoted file after safe-path verification;
- source text is explicitly treated as untrusted instructions and should not alter agent behavior.

### 5.5 Query flow (`wiki-query`)

The read path is intentionally cost-tiered:

1. Resolve config.
2. Read `hot.md` if available.
3. Read `index.md`.
4. Build candidates from frontmatter/index only.
5. Optional QMD semantic pass if configured.
6. Section grep on top candidates if needed.
7. Full-read top pages only as last resort.
8. Synthesize with `[[wikilink]]` citations and staleness/lifecycle annotations.
9. Append a query log entry to `log.md`.

This is one of the clearest examples of the repo encoding execution policy rather than code: retrieval primitives are part of the contract.

### 5.6 Status / audit flow (`wiki-status`, `wiki-lint`)

`wiki-status`:

1. reads manifest;
2. scans configured source locations;
3. classifies sources as new/modified/touched/unchanged/deleted;
4. reports delta and recommends append/rebuild/full ingest;
5. optionally computes graph insights and writes `_insights.md`.

`wiki-lint`:

1. reads index/log;
2. scans vault pages;
3. checks orphans, broken links, frontmatter, summaries, staleness, contradictions, provenance drift, tag fragmentation, visibility-tag consistency, lifecycle/confidence schema, and synthesis gaps.

Both are read-heavy control workflows with no shared underlying implementation library.

### 5.7 Cross-project sync flow (`wiki-update`)

From any project directory:

1. resolve wiki config;
2. inspect the current project's docs/source/git history;
3. compare to `last_commit_synced` in the manifest;
4. distill only durable knowledge;
5. write or update `projects/<project-name>/...` plus any global concept/entity/skill pages;
6. update manifest, index, log, hot cache.

This is the main bridge from “coding in some repo” back into the Obsidian wiki.

### 5.8 Agent-history ingest flow

History ingest is split into:

- a thin router (`wiki-history-ingest`);
- provider-specific skills (`claude`, `codex`, `copilot`, `hermes`, `openclaw`).

Observed common flow:

1. resolve config;
2. compute delta against manifest;
3. scan agent-native storage layouts;
4. prefer higher-value pre-summarized artifacts when available (e.g. Copilot checkpoints, OpenClaw `MEMORY.md`, Codex session index);
5. cluster by topic rather than one page per session;
6. write pages and update manifest/index/log/hot.

The Copilot variant is the richest documented parser because it explicitly prioritizes `session-store.db`, checkpoints, transcript JSONL, memory artifacts, file-touch patterns, and refs.

### 5.9 Daily reminder flow

There are two parallel implementations of “daily update”:

- the skill specification in `.skills/daily-update/SKILL.md`;
- the deterministic script in `scripts/daily-update.sh`.

The script currently:

1. resolves config with the same walk-up algorithm;
2. computes a vault hash for per-vault state;
3. reads `.manifest.json`;
4. counts sources newer than `manifest.last_updated`;
5. writes `~/.obsidian-wiki/state/<vault-id>/.last_update`, `.pending_delta`, `.vault_path`.

`scripts/wiki-notify.sh` then reads those state directories on shell startup and prints a reminder when a vault is >20 hours old.

**Observed deviation:** the shell script does not actually refresh `index.md` or `hot.md`, while the `daily-update` skill spec says it should. This is a real documentation/implementation split.

## 6. State and Persistence Model

### Primary persisted state: the vault

The vault is the system of record. Key persisted objects:

- **wiki pages** — semantic content + frontmatter;
- `index.md` — content inventory;
- `log.md` — chronological operations journal;
- `hot.md` — compressed working-set summary;
- `.manifest.json` — ingest ledger and project sync metadata;
- `_insights.md` — graph-analysis output;
- `_meta/taxonomy.md` — controlled tag vocabulary;
- `.obsidian/graph.json` and other Obsidian settings.

### Page-level state

Pages carry:

- `title`, `category`, `tags`, `sources`, `created`, `updated`;
- `summary`;
- `provenance` fractions;
- `base_confidence`;
- `lifecycle`, `lifecycle_changed`, optionally `lifecycle_reason`, `superseded_by`;
- optional visibility tags.

This means the system pushes significant governance metadata into markdown frontmatter rather than external indexes.

### Manifest state

`.manifest.json` is the cross-workflow ledger. It stores, depending on skill:

- ingested source metadata;
- content hash and mtimes;
- page creation/update outputs;
- per-project sync metadata (`last_commit_synced`, `pages_in_vault`);
- top-level stats.

It is the main coupling artifact across ingest, status, update, memory-bridge, and reminders.

### Secondary persisted state outside the vault

- `~/.obsidian-wiki/config` and `config.<name>` vault profiles.
- `~/.obsidian-wiki/state/<vault-id>/...` reminder state.
- Agent-native history stores under `~/.claude`, `~/.codex`, `~/.copilot`, `~/.hermes`, `~/.openclaw`.

### Mutable vs computed state

Stored:

- page frontmatter;
- manifest content;
- log/index/hot caches;
- exported graph artifacts.

Computed on demand:

- staleness overlays (`updated` older than threshold);
- delta classification;
- graph hub/bridge/cohesion metrics;
- visibility tallies;
- memory-bridge cross-tool diffs.

There is no transaction model. Recovery is by rerun, rebuild, or archive restore.

## 7. Coordination and Control Semantics

This project has **distributed, directive control**:

- **Skill selection authority** lives in skill descriptions, router skills, and agent-specific always-on context files.
- **Execution authority** lives in the external coding agent, which interprets one skill at a time.
- **State authority** lives in the vault special files and page frontmatter.

### Control topology

- **Centralized invariants:** `llm-wiki` defines global rules.
- **Decentralized execution:** each skill owns its own step sequence.
- **Thin routing layers:** `wiki-history-ingest` and `wiki-switch` route commands to more specific behavior.
- **Optional self-checking:** some skills delegate validation to `impl-validator`.

### Scheduling / concurrency

There is no internal queue or scheduler except:

- the user's invocation sequence;
- macOS `launchd` for the reminder script;
- whatever concurrency the hosting agent supports when it spawns subagents.

The system is mostly synchronous and human-driven. Background automation is peripheral.

### Failure propagation

Failure usually manifests as:

- config not resolved;
- vault files missing or inconsistent;
- manifest drift;
- agent missing a required update step;
- OS/tool mismatch in shell-based setup.

Recovery mechanisms are mostly social/procedural:

- rerun the relevant skill;
- inspect `log.md` / `.manifest.json`;
- run `wiki-lint`;
- use `wiki-rebuild` archives.

This is a key distinction from traditional software: control robustness comes from carefully written instructions, not from runtime guards.

## 8. Configuration and Environment Model

### Required config

From `.env.example` and `llm-wiki`:

- `OBSIDIAN_VAULT_PATH` — mandatory.

### Common optional config

- `OBSIDIAN_SOURCES_DIR`
- `OBSIDIAN_CATEGORIES`
- `OBSIDIAN_MAX_PAGES_PER_INGEST`
- `CLAUDE_HISTORY_PATH`
- `CODEX_HISTORY_PATH`
- `LINT_SCHEDULE`
- `OBSIDIAN_LINK_FORMAT`
- `QMD_WIKI_COLLECTION`
- `QMD_PAPERS_COLLECTION`
- `OBSIDIAN_RAW_DIR`

### Additional variables referenced by skills

Observed in skill docs, but not fully represented in `.env.example`:

- `OBSIDIAN_WIKI_REPO`
- `HERMES_HOME`
- `OPENCLAW_HOME`
- `COPILOT_HISTORY_PATH`
- `COPILOT_VSCODE_STORAGE_PATH`

This indicates mild config drift between skills and template config.

### Config hierarchy

1. local `.env` found by walking upward from CWD;
2. global `~/.obsidian-wiki/config`;
3. named vault profiles via `config.<name>` and `wiki-switch`;
4. optional vault-local override file at `$OBSIDIAN_VAULT_PATH/AGENTS.md`.

### Environment assumptions

- A capable AI coding agent is the real runtime dependency.
- Bash/symlink-friendly environment is assumed for full setup.
- Obsidian is assumed for viewing and graph UX.
- QMD is optional for semantic search.
- Python 3 is needed for some helper scripts.
- SQLite access is assumed for Copilot/Codex history inspection.
- macOS `launchd` is assumed for the “daily cron” setup path.

## 9. Operational Usage Model

### Canonical user workflow

1. Install or expose skills to the agent.
2. Initialize a vault (`wiki-setup`).
3. Periodically run `wiki-status`.
4. Ingest new raw content or agent history (`wiki-ingest`, `wiki-history-ingest`, `data-ingest`, etc.).
5. Query compiled knowledge (`wiki-query`).
6. Maintain graph hygiene (`wiki-lint`, `cross-linker`, `tag-taxonomy`).
7. Use `wiki-update` from other projects to keep project knowledge current.

### Interaction model

The user does not “run the app.” They **state intent in natural language or a slash command**, the agent selects a skill, and that skill manipulates the vault directly.

### Development vs production distinction

There is no real app/runtime environment split. Instead there are:

- **framework maintenance** inside this repo;
- **vault operations** against a user's knowledge base;
- **cross-project usage** from arbitrary other repos.

### Repeated usage loop

- `wiki-status` decides whether append or rebuild is appropriate.
- Ingest/update operations rewrite special files.
- `hot.md` provides short-term continuity into the next session.

### Operational reality

The repo expects the operator to be comfortable with:

- agent prompting;
- file-system level configuration;
- reading markdown instructions when behavior is unclear;
- debugging by inspecting generated content rather than stack traces.

## 10. Extension and Customization Architecture

### Primary extension model: add or modify skills

The repo expects evolution through new folders under `.skills/<name>/` containing:

- `SKILL.md` (required);
- optional `references/`, `scripts/`, `assets/`, `agents/`.

This is an explicit extension point described by `skill-creator`.

### Shared extension constraints

New skills are expected to:

- reuse config resolution from `llm-wiki`;
- maintain vault special files when they write;
- obey page schema and provenance rules;
- use retrieval primitives for read-heavy tasks;
- integrate with the existing categories/projects split.

### Distribution extension model

`setup.sh` makes new skills discoverable across agents by symlinking everything under `.skills/`. This means adding a new skill usually requires **no code changes** to agent-specific registries beyond rerunning setup, except for agent-specific always-on prompts or slash-command registries if needed.

### Meta-extension tooling

`skill-creator` is the formal mechanism for creating and benchmarking new skills. It adds a secondary architecture:

- skill drafting;
- test-prompt generation;
- with-skill vs baseline runs;
- grading/aggregation/viewing;
- packaging/validation.

That subsystem is more deterministic and codeful than the main wiki runtime.

## 11. Key Architectural Decisions and Tradeoffs

### 11.1 Markdown instructions over executable orchestration

This keeps the framework agent-portable and easy to inspect, but correctness depends on agent obedience and interpretation rather than on code paths.

### 11.2 Vault-as-database

The project avoids a separate app/server/search stack for the core workflow. Benefits: simple artifact model, native Obsidian compatibility, git-friendliness. Cost: consistency enforcement and efficient querying are largely prompt conventions.

### 11.3 Compiled knowledge over raw retrieval

The repo strongly commits to “compile, don't retrieve.” That reduces repeated rediscovery and enables cross-linking, but requires more write-time discipline and raises maintenance burden if prompts drift.

### 11.4 Tiered retrieval

`wiki-query` and related skills prioritize index/frontmatter/grep before full reads. This is a deliberate scalability decision for large vaults and one of the most concrete architectural optimizations in the repo.

### 11.5 Manifest-driven delta

Using `.manifest.json` as the universal ledger unifies ingest, status, project sync, and reminder flows. The tradeoff is high coupling to a mutable JSON file with no centralized schema enforcement.

### 11.6 Multi-agent distribution

Supporting many agent ecosystems broadens reach, but increases bootstrap complexity and creates portability issues around symlinks, rules files, and platform assumptions.

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 “No scripts, no dependencies” is not literally true

**Observed:** the repo contains `setup.sh`, two shell scripts under `scripts/`, a macOS plist, Python utilities under `skill-creator`, and a shell script under `obsidian-wiki-ingest`. The core runtime is markdown-driven, but the marketing line is overstated.

### 12.2 Prompt compliance is the enforcement layer

Almost all important invariants are documented rather than executed by code. If a skill forgets to update `hot.md` or miscomputes manifest entries, nothing in the repo automatically catches that unless another skill like `impl-validator` is invoked.

### 12.3 No automated tests or CI-facing manifests

No `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `requirements.txt`, or test files were found at repo root or below general test patterns. This makes regression detection manual.

### 12.4 Unix/macOS bias

`setup.sh` assumes `bash`, `ln -s`, `sed -i`, and interactive prompts. Reminder setup assumes `launchd`. This is operationally awkward on Windows despite the repo being used from agent environments that may run on Windows.

### 12.5 Thin / incomplete wrapper artifacts

`obsidian-wiki-ingest` includes a high-level wrapper and a nearly empty shell script with a hardcoded project path. That looks exploratory and should not be treated as a production-grade entry point.

### 12.6 Config surface is inconsistent

Some skills reference variables absent from `.env.example`, especially around Hermes/OpenClaw/Copilot paths. This increases setup ambiguity.

### 12.7 Documentation / implementation drift

Examples:

- `daily-update` skill describes index and `hot.md` refresh plus validator spawning, but `scripts/daily-update.sh` only writes reminder state and stale counts.
- README/SETUP frame the project as simpler than the actual repo now is.
- Router/skill lists have grown beyond some older summaries.

### 12.8 Symlink portability complexity

The repo tracks symlink trees in git for agent skill discovery. On filesystems or git configs without symlink support, these can degrade into plain files or require rerunning `setup.sh`.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. Create `.env` from `.env.example`.
2. Set `OBSIDIAN_VAULT_PATH`.
3. Make `.skills/` discoverable to your agent.
4. Run `wiki-setup`.
5. Use `wiki-ingest`, `wiki-status`, and `wiki-query`.

### Operational Assumptions

- The user is willing to let an agent edit many markdown files.
- The vault is small-to-medium unless the operator uses the cost-aware retrieval patterns.
- The operator understands that the vault is the product and chat history is disposable unless captured.
- Obsidian is the intended viewing/debugging environment.
- External histories (`~/.claude`, `~/.codex`, `~/.copilot`, etc.) are available locally for history ingest.

### Canonical Workflow

1. `wiki-status`
2. Ingest the delta (`wiki-ingest` or history ingest)
3. Cross-link / lint if needed
4. Query the wiki
5. Sync project learnings with `wiki-update`

### Advanced Usage

- Use QMD collections for semantic search in query/ingest.
- Use `wiki-agent` for targeted retrieval from another tool's history.
- Use `memory-bridge` to compare what different AI tools contributed.
- Use `wiki-export` for graph outputs.
- Use `graph-colorize` to align Obsidian graph visuals with taxonomy/visibility.
- Use `wiki-switch` for multiple vault profiles.

### Extension Workflow

1. Read `.skills/llm-wiki/SKILL.md`.
2. Decide whether the new behavior is a new skill or a change to an existing one.
3. Add `.skills/<new-skill>/SKILL.md`, optional helpers/resources.
4. Keep special-file maintenance and config resolution aligned.
5. Rerun `setup.sh` or re-expose the skill to agents.

### Debugging Workflow

Best inspection points:

- `.skills/<skill>/SKILL.md` — intended behavior.
- Vault `log.md` — what the skill claims happened.
- Vault `.manifest.json` — what sources/pages were tracked.
- Vault `index.md` / `hot.md` — whether the cheap-query surfaces were maintained.
- `AGENTS.md` / agent-specific rule files — routing/bootstrap context.
- `setup.sh` and `scripts/*.sh` — if discovery or reminders are failing.

### Observability

There is no metrics/tracing system. Observability is document-centric:

- append-only log entries;
- manifest entries;
- exported graph artifacts;
- reminder state files under `~/.obsidian-wiki/state/<vault-id>/`.

### Failure Modes

- Config not found or wrong vault path.
- Skills not discovered by the current agent.
- Manifest drift causing duplicate or skipped ingest.
- Missing updates to `index.md`/`hot.md` reducing query quality.
- Cross-platform failures in setup/reminder scripts.
- History-ingest parsing assumptions not matching the user's actual local data layout.

### Performance Considerations

Main cost drivers:

- full-page reads across large vaults;
- repeated whole-history scans for agent transcripts;
- graph-wide grep passes;
- research/web-fetch fanout.

The framework mitigates this through frontmatter summaries, `index.md`, optional QMD, and selective extraction rules.

## 14. Project Navigation Guide

### Best reading order

1. `README.md` — product framing and supported workflows.
2. `SETUP.md` — actual installation/operational expectations.
3. `.skills/llm-wiki/SKILL.md` — global schema and runtime contract.
4. `.skills/wiki-ingest/SKILL.md` — main write path.
5. `.skills/wiki-query/SKILL.md` — main read path.
6. `.skills/wiki-status/SKILL.md` — delta model and insights.
7. `.skills/wiki-update/SKILL.md` — cross-project sync semantics.
8. One history-ingest skill relevant to your target agent (`copilot` is the richest documented one).
9. `setup.sh` — distribution/bootstrap behavior.
10. `scripts/daily-update.sh` and `scripts/wiki-notify.sh` — reminder automation.
11. `.skills/skill-creator/` — only if modifying the framework itself or adding meta-tooling.

### Highest-value entry points

- `.skills/llm-wiki/SKILL.md`
- `.skills/wiki-ingest/SKILL.md`
- `.skills/wiki-query/SKILL.md`
- `.skills/wiki-status/SKILL.md`
- `.skills/wiki-update/SKILL.md`
- `setup.sh`
- `AGENTS.md`

### Where abstractions become concrete

- Config resolution becomes concrete in `setup.sh` and `scripts/daily-update.sh`.
- Agent history abstractions become concrete in provider-specific skills, especially `copilot-history-ingest` and `codex-history-ingest`.
- Distribution abstractions become concrete in the symlink trees and rule/bootstrap files.

### What to ignore on first pass

- Most mirrored skill directories under `.claude/`, `.cursor/`, `.windsurf/`, `.agents/`, `.kiro/` — they are distribution mirrors, not source of truth.
- `obsidian-wiki-ingest` shell wrapper — low maturity.
- `skill-creator` implementation details unless you are editing framework-generation tooling.

## 15. Concise Deep Technical Synthesis

`obsidian-wiki` is a **schema-and-workflow repo for making an external AI agent behave like a disciplined Obsidian wiki maintainer**. Its architecture is unusual because the real runtime is not inside the repository: the repo supplies prompt contracts, distribution glue, and a few helper scripts, while the agent executes those contracts against a user-owned vault that holds all meaningful state.

The project is optimized for engineers who are comfortable treating markdown, frontmatter, and agent instructions as first-class infrastructure. Its strongest ideas are the manifest-driven delta model, cost-tiered retrieval, and the disciplined separation between canonical skill definitions and agent-specific packaging. Its biggest risks are prompt fragility, cross-skill drift, and the absence of automated enforcement. The safest way to modify it is to think of `.skills/llm-wiki/SKILL.md` as the platform spec, `.skills/` as the executable workflow layer, and the vault artifacts as the database whose invariants every skill must preserve.
