# ONBOARDING

## What this repo actually is

`llm-wiki` is a **multi-runtime prompt package** for running an LLM-maintained Markdown wiki. It is not a server or SDK. The core implementation is behavioral Markdown in `claude-plugin/skills/wiki-manager/` and `claude-plugin/commands/`, plus one deterministic local helper in `scripts/llm-wiki`.

## Dominant architecture

- **Claude-first source of truth:** `claude-plugin/`
- **Generated Codex mirror:** `plugins/llm-wiki/`
- **Generated OpenCode/Pi mirror:** `plugins/llm-wiki-opencode/`
- **Portable fallback protocol:** `AGENTS.md`

The semantic center is the **filesystem model**:

- hub config and topic selection
- `raw/` immutable sources
- `wiki/` synthesized articles
- `inventory/` operational records
- `datasets/` external-data manifests
- `output/` artifacts and `output/projects/<slug>/WHY.md`
- `_index.md` as derived cache, not source of truth

## Read this first

1. `README.md`
2. `CLAUDE.md`
3. `claude-plugin/skills/wiki-manager/SKILL.md`
4. `claude-plugin/commands/wiki.md`
5. `claude-plugin/skills/wiki-manager/references/{wiki-structure,indexing,linting,hub-resolution,research-infrastructure}.md`
6. `scripts/llm-wiki`

## Core execution model

The host runtime does the real execution. This repo tells it what to do.

Common flow:

1. resolve hub from `~/.config/llm-wiki/config.json` (`resolved_path` first)
2. resolve wiki root from `--local`, `--wiki <name>`, ambient `.wiki/`, else hub
3. route through `claude-plugin/commands/wiki.md`
4. operate directly on Markdown/JSON files
5. rely on lint and derived indexes to heal structural drift

## Most important files

- **Behavior core:** `claude-plugin/skills/wiki-manager/SKILL.md`
- **Router / first-run UX:** `claude-plugin/commands/wiki.md`
- **Research pipeline:** `claude-plugin/commands/research.md`
- **Query semantics:** `claude-plugin/commands/query.md`
- **Filesystem contract:** `claude-plugin/skills/wiki-manager/references/wiki-structure.md`
- **Derived-index contract:** `claude-plugin/skills/wiki-manager/references/indexing.md`
- **Schema + migration contract:** `claude-plugin/skills/wiki-manager/references/linting.md`
- **Deterministic enforcement:** `scripts/llm-wiki`
- **Codex packaging:** `scripts/{sync-codex-plugin,bootstrap-codex-plugin,verify-codex-plugin}.sh`
- **OpenCode packaging:** `scripts/sync-opencode-plugin.sh`

## Safe edit surface

Edit behavior in:

- `claude-plugin/skills/wiki-manager/SKILL.md`
- `claude-plugin/commands/*.md`
- `claude-plugin/skills/wiki-manager/references/*.md`

Do **not** hand-edit:

- `plugins/llm-wiki/`
- `plugins/llm-wiki-opencode/`

After behavior changes, regenerate mirrors with:

- `scripts/sync-codex-plugin.sh`
- `scripts/sync-opencode-plugin.sh`

## Structural invariants

- `_index.md` files are derived caches.
- `log.md` is append-only.
- lint is the migration system; there is no separate migrate command.
- hub content belongs under topic wikis, not the hub root.
- inventory is operational state, not factual evidence.
- dataset manifests index large/external data; they do not copy it into the wiki.
- project scope is explicit via `--project <slug>`; there is no ambient focus state.

## Deterministic subsystem

`scripts/llm-wiki` is the only real local program. It enforces:

- structure
- frontmatter schema
- canonical placement
- unknown-file quarantine
- index consistency
- link and source-provenance checks
- coverage
- freshness
- project hygiene

If you change schema or directory rules, update:

- `references/wiki-structure.md`
- `references/linting.md`
- `references/compilation.md`
- `scripts/llm-wiki`
- `tests/test-structure.sh`
- `tests/generate-defect-fixtures.sh`

## Tests that matter most

- `tests/test-plugin-validate.sh`
- `tests/test-structure.sh`
- `tests/test-local-cli-lint.sh`
- `tests/test-codex-sync.sh`
- `tests/test-opencode-sync.sh`
- `tests/test-codex-runtime.sh` when touching Codex bootstrap/docs
- `tests/promptfooconfig.yaml` when changing routing/behavior

## Known sharp edges

- Prompt behavior is richer than what tests can fully guarantee.
- `commands/librarian.md` still has an unimplemented `fix <id>` path.
- `commands/thesis.md` is a deprecated shim after thesis moved into research mode.
- Docs have some drift (counts and mirror details), so trust the actual tree and scripts over prose summaries.
- Maintainer tooling is Unix-oriented (`bash`, `rsync`, `ln -s`, `mktemp`).
- Codex first-time local install may still require interactive `/plugins` enable even after bootstrap.

## Debugging checklist

1. Confirm which runtime surface is in play: Claude vs Codex vs OpenCode/Pi vs `AGENTS.md`.
2. Read the generated mirror only after reading the Claude source.
3. If behavior changed, re-run both sync scripts.
4. Use `scripts/llm-wiki lint <wiki-root>` to validate structure.
5. Inspect manifests:
   - `.claude-plugin/marketplace.json`
   - `claude-plugin/.claude-plugin/plugin.json`
   - `.agents/plugins/marketplace.json`
   - `plugins/llm-wiki/.codex-plugin/plugin.json`
6. Use fixtures under `tests/fixtures/` to understand expected schema and failure cases.
