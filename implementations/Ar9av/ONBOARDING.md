# ONBOARDING

## What this repo actually is

This is **not** an app or service. The repo is a **skill pack + schema contract** for AI coding agents that maintain an Obsidian vault. The real runtime is:

1. an external agent that can read/write files,
2. a user vault at `OBSIDIAN_VAULT_PATH`,
3. the markdown workflow specs in `.skills/*/SKILL.md`.

The main product is the **vault**, not anything inside this repo.

## Semantic centers

- `.skills/llm-wiki/SKILL.md` — global contract: vault layout, page schema, provenance, lifecycle, retrieval primitives, config resolution, link format.
- `.skills/wiki-ingest/SKILL.md` — core write path for source distillation.
- `.skills/wiki-query/SKILL.md` — core read path with cost-tiered retrieval.
- `.skills/wiki-status/SKILL.md` — manifest-driven delta model and graph insights.
- `.skills/wiki-update/SKILL.md` — cross-project sync from arbitrary repos.
- `*-history-ingest` skills — provider-specific parsing of local agent histories.

If you change one of these, read the others first; they share assumptions but do not share code.

## Runtime model

- Skills resolve config by walking up from CWD for `.env`, then falling back to `~/.obsidian-wiki/config`.
- State lives mostly in the **vault**:
  - `.manifest.json` — ingest ledger / project sync metadata
  - `index.md` — page inventory
  - `log.md` — chronological operations log
  - `hot.md` — short-term semantic cache
  - page frontmatter — title/category/tags/sources/summary/provenance/confidence/lifecycle
- `wiki-query`, `wiki-lint`, `wiki-status`, and `cross-linker` are supposed to follow the **Retrieval Primitives** table in `llm-wiki`: index/frontmatter first, section grep second, full reads last.

## Important invariants

- `.skills/` is the only source of truth; mirrored directories under `.claude/`, `.cursor/`, `.windsurf/`, `.agents/`, `.kiro/` are distribution artifacts.
- Every write workflow should update `.manifest.json`, `index.md`, `log.md`, and usually `hot.md`.
- New/updated pages should follow the frontmatter contract from `llm-wiki`.
- Internal links depend on `OBSIDIAN_LINK_FORMAT` (`wikilink` by default, `markdown` optional).
- Project-specific knowledge belongs under `projects/<name>/`; global knowledge belongs in top-level category folders.

## Setup and ops entry points

- `README.md` — product framing.
- `SETUP.md` — practical install/use flow.
- `setup.sh` — writes `~/.obsidian-wiki/config`, creates bootstrap symlinks, installs skills into agent discovery locations.
- `AGENTS.md` — shared always-on context for AGENTS-aware agents.
- `.github/copilot-instructions.md`, `.cursor/rules/obsidian-wiki.mdc`, `.agent/rules/obsidian-wiki.md`, `.kiro/steering/obsidian-wiki.md` — agent-specific bootstrap context.
- `scripts/daily-update.sh` + `scripts/wiki-notify.sh` — reminder-state automation.

## Fastest way to understand or modify behavior

1. Read `.skills/llm-wiki/SKILL.md`.
2. Read the specific skill you want to modify.
3. Inspect where that skill says it reads/writes in the vault.
4. If the change affects setup/discovery, read `setup.sh`.
5. If the change affects reminder automation, read `scripts/daily-update.sh`.

## Extension model

Add new capabilities by creating `.skills/<name>/SKILL.md` plus optional `references/`, `scripts/`, `assets/`, or `agents/`.

If the skill writes to the vault, it should:

- resolve config via `llm-wiki`,
- reuse the page/special-file conventions,
- obey retrieval-cost discipline for read-heavy work,
- update log/manifest/index/hot consistently.

`skill-creator` is the built-in meta-tool for authoring/evaluating new skills.

## Sharp edges / known gaps

- The repo markets itself as “no scripts, no dependencies,” but it does include shell/Python support tooling.
- There are no automated tests or CI manifests in the repo.
- `setup.sh` and reminder setup are Unix/macOS-oriented (`bash`, `ln -s`, `sed`, `launchd`).
- `obsidian-wiki-ingest` looks exploratory; do not treat it as a mature entry point.
- Some env vars referenced by skills are not present in `.env.example` (notably some Hermes/OpenClaw/Copilot paths).
- The `daily-update` skill spec is richer than `scripts/daily-update.sh`; treat the script as the actual deterministic behavior.

## Recommended reading order for future work

1. `README.md`
2. `SETUP.md`
3. `.skills/llm-wiki/SKILL.md`
4. One of `.skills/wiki-ingest/SKILL.md` or `.skills/wiki-query/SKILL.md`
5. `.skills/wiki-status/SKILL.md`
6. `.skills/wiki-update/SKILL.md`
7. Relevant history-ingest skill
8. `setup.sh`

## Bottom-line mental model

Treat this repo as a **workflow/specification layer** for AI agents, with the **vault as the database** and the **agent as the executor**. Most bugs or feature changes will come from changing written operational contracts, not from changing algorithmic code.
