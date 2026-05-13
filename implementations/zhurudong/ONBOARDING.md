# ONBOARDING

## What this repo actually is

This repository is a **starter kit for an LLM-operated markdown knowledge base**, not a standalone application. The main "program" is `templates/CLAUDE.en.md` / `templates/CLAUDE.md`: those files define the schema, invariants, and ingest/query/lint workflows that an external LLM CLI is supposed to execute against a filesystem-based wiki.

For immediate hands-on use in this checkout, start in `examples/`, not repo root. Root is template source; `examples/` is the only populated knowledge-base instance.

## Semantic centers

1. `templates/CLAUDE.en.md` - primary behavior contract; read this before changing anything structural.
2. `install.sh` - only executable bootstrap logic; creates the canonical `raw/` + `wiki/` layout and downloads the template.
3. `examples/` - worked example of the intended output shape after ingest.

If you understand those three areas, you understand the repository.

## Dominant architecture

- **Instruction-centric:** behavior is specified in markdown, not in source code.
- **Filesystem-backed:** durable state is plain markdown under `raw/` and `wiki/`.
- **External-runtime-driven:** actual execution happens in Claude Code / Codex CLI / OpenCode, not inside this repo.
- **Regeneration-oriented:** `raw/` is immutable source truth; `wiki/` is derived understanding.

## Actual runtime/control model

The control loop is:

`human intent -> external LLM CLI -> template rules -> filesystem edits`

Important consequences:

- there is no local search engine, backend, or daemon;
- `_index.md` is the primary query router;
- `_log.md` is the primary continuity mechanism across sessions;
- correctness depends on the agent following the written rules.

## Core workflows encoded by the template

### Bootstrap

`install.sh` creates:

- `raw/`
- `raw/assets/`
- `wiki/summaries/`
- `wiki/entities/`
- `wiki/concepts/`
- `wiki/comparisons/`
- `wiki/overviews/`
- `wiki/synthesis/`
- `wiki/_index.md`
- `wiki/_log.md`

It also downloads the selected template as `CLAUDE.md` and creates `AGENTS.md`.

Note: the README's manual install snippet is shorter than the actual scaffold created by `install.sh`; if you bypass the script, you still need the full directory tree plus empty `wiki/_index.md` and `wiki/_log.md`.

### Session start

The template explicitly requires reading `wiki/_log.md` first when a wiki exists. This is how session continuity is reconstructed.

### Ingest

The agent is expected to:

1. fetch a source;
2. save immutable raw markdown and local assets;
3. generate/update summary, entity, concept, comparison, and overview pages as applicable;
4. rebuild `wiki/_index.md`;
5. append to `wiki/_log.md`.

### Query

The agent should read `wiki/_index.md` first, then targeted wiki pages, then optionally archive multi-source answers under `wiki/synthesis/`.

### Lint

Health checks are instruction-driven, not scripted: broken links, orphans, stale claims, contradictions, and missing cross-references are supposed to be found by the agent.

## Key invariants

- `raw/` is immutable after ingest.
- `wiki/` is LLM-owned and regenerable.
- summaries are the only wiki pages that directly reference `raw/`.
- use `[[folder/name]]` links, not bare names.
- `_log.md` is append-only.
- `synthesis/` is not part of full regeneration.

## Repository boundaries

What is implemented:

- bootstrap script;
- bilingual template files;
- usage docs;
- one seeded example knowledge base.

What is not implemented:

- automated fetch/parsing;
- local lint/search/rebuild tooling;
- tests/CI enforcing the schema;
- any app/server/runtime beyond the external agent CLI.

## Extension points

Most changes should start in `templates/CLAUDE.en.md` and `templates/CLAUDE.md`.

If you change schema or workflow semantics, also update:

1. `install.sh`
2. `README.md` / `README.zh-CN.md`
3. `examples/` so the sample output still matches the rules

There is no plugin system; extension is prompt-and-structure editing.

## Sharp edges

- The repo is Unix-oriented (`bash`, `curl`, `ln -sf`).
- Many guarantees are conventional, not enforced.
- Comparison/overview/synthesis flows are specified, but the example corpus is too small to demonstrate all of them.
- Drift between template, README, and example content is the main maintenance risk.
- `README.md` says MIT, but no top-level `LICENSE` file is present in the current checkout.

## Practical navigation order

1. `README.md`
2. `install.sh`
3. `templates/CLAUDE.en.md`
4. `examples/wiki/_log.md`
5. `examples/wiki/_index.md`
6. `examples/raw/2026-02-11-harness-engineering.md`
7. `examples/wiki/summaries/2026-02-11-harness-engineering.md`
8. `examples/wiki/entities/Codex.md`
9. `examples/wiki/concepts/Harness Engineering.md`

## Debugging / inspection approach

When behavior seems wrong, inspect artifacts rather than looking for hidden runtime code:

1. check `_log.md` for what the agent claims happened;
2. check `_index.md` for navigation drift;
3. compare derived pages against raw sources;
4. check whether file naming, frontmatter, and wiki-link conventions still match the template.
