# ONBOARDING

## What this repo actually is

This is a Claude Code skill package for operating an LLM-managed markdown wiki. It is not a standalone app. The real runtime is:

- this repo as the skill/tooling package;
- Claude Code as the host agent;
- a separate target wiki directory containing `raw/`, `wiki/`, and a root `CLAUDE.md`.

The semantic center is `SKILL.md` plus the mode docs in `references/`. The Python code only handles deterministic structural edits.

## Dominant architecture

- Prompt/workflow-driven orchestration, not service runtime.
- LLM owns semantic work: ingest, synthesis, cross-linking, contradiction handling, multi-page updates.
- Scripts own mechanical bookkeeping: scaffold layout, `index.md`, `log.md`, lint reports.
- Durable state lives in the target wiki, not in this repository.

Read this repo as a control package for an external markdown knowledge base.

## Semantic centers

Start here:

1. `SKILL.md`
2. `references/ingest-workflow.md`
3. `references/update-workflow.md`
4. `references/lint-workflow.md`
5. `scripts/lint_wiki.py`
6. `assets/templates/wiki-CLAUDE.md.tmpl`

Why these matter:

- `SKILL.md` contains routing, invariants, and the actual product contract.
- ingest/update/query/lint docs define the operational semantics.
- `lint_wiki.py` is the richest script and the only one that orchestrates other scripts.
- the schema template shows how target-wiki conventions are captured.

## Core runtime model

### Three-layer contract

- `raw/`: immutable, user-curated sources. LLM reads but never modifies.
- `wiki/`: LLM-managed markdown pages.
- root `CLAUDE.md`: per-wiki schema and workflow overrides.

### Main operation loops

- Bootstrap: `init_wiki.py` scaffolds directories and starter files.
- Ingest: LLM reads source, updates source/entity/concept pages, then calls `update_index.py` and `append_log.py`.
- Query: LLM reads `wiki/index.md` first, drills into relevant pages, optionally files the answer back.
- Update: LLM performs a semantic multi-page correction sweep with diff-before-write; no dedicated update script exists.
- Lint: `lint_wiki.py` writes a dated report and usually auto-tracks it in index/log.

## Script contracts

- `scripts/init_wiki.py`: idempotent scaffold of target wiki layout, including `wiki/reports/`.
- `scripts/update_index.py`: upserts index entries by exact `(category, title)`; target page flag is `--page-path`.
- `scripts/append_log.py`: appends `## [YYYY-MM-DD] action | title` with constrained action names.
- `scripts/lint_wiki.py`: checks only mechanical issues, not semantic drift.

Important implementation detail: `lint_wiki.py` shells out to `update_index.py` and `append_log.py` when auto-tracking reports.

## Invariants and assumptions

- The user owns `raw/`; the LLM owns `wiki/`.
- Every meaningful operation should update the index and/or log through scripts, not ad hoc edits.
- Contradictions are recorded, not silently overwritten.
- The local wiki schema in target `CLAUDE.md` is the real customization layer.
- Git is assumed to be desirable for rollback, but bootstrap code does not create a repo.

## Sharp edges and known mismatches

- `references/bootstrap-workflow.md` says bootstrap defaults to `git init`; `scripts/init_wiki.py` does not do that.
- `references/ingest-workflow.md` contains an `update_index.py` example using the wrong flag name; the script expects `--page-path` for the page being indexed.
- Multi-wiki routing is convention-based. There is no automated validation of cross-wiki paths or routing correctness.
- Lint does not catch stale claims or semantic contradictions unless the agent notices them after reading the report.

## Extension pattern

If you add a new capability, keep the existing split:

1. behavior change in `SKILL.md`;
2. detailed procedure in `references/` if needed;
3. script only for deterministic mechanical work;
4. template update if the new capability emits durable wiki artifacts.

Avoid pushing semantic policy into scripts unless it is fully deterministic.

## Fast debugging guide

- Wrong behavior in a mode: inspect `SKILL.md`, then the relevant `references/*.md` file.
- Wrong CLI usage: inspect the script directly, not README examples.
- Drift between target wiki practice and expected layout: inspect `assets/templates/wiki-CLAUDE.md.tmpl` and `references/schema-design-guide.md`.
- Lint oddities: start with `scripts/lint_wiki.py`, especially `find_md_files`, broken-link checks, and `auto_track`.

## Maintainer mindset

Treat this repo less like an app codebase and more like an operational specification with small helper binaries. The critical question during changes is usually not “does the Python code work?” but “do `SKILL.md`, the workflow docs, templates, and scripts still describe the same behavior?”
