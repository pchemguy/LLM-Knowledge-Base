# ONBOARDING

## What this repository actually is

This repo is a **skill bundle**, not a runnable app. The real implementation is `SKILL.md`: a workflow contract that teaches an external Agent Skills-compatible coding agent how to maintain a Karpathy-style markdown knowledge base in some **other** project directory.

The core persistent model the skill operates on is:

- `raw/` -> immutable source captures
- `wiki/` -> mutable synthesized knowledge pages
- `wiki/index.md` -> global topic-grouped catalog
- `wiki/log.md` -> append-only operation log

## Dominant architectural identity

Treat the repo as a **specification-driven orchestration system**:

- `SKILL.md` = control policy and runtime semantics
- `references/*.md` = file-shape contracts
- `examples/*` = de facto golden outputs / behavioral evidence
- `README.md` = install and framing only

There is no in-repo runtime, API, database, crawler, or test suite.

## Semantic centers

Read these first:

1. `SKILL.md`
2. `references/article-template.md`
3. `references/raw-template.md`
4. `references/index-template.md`
5. `references/archive-template.md`
6. `examples/README.md`
7. `examples/2026-03-19-claude-code-statusline-landscape.md`
8. `examples/claude-code-statusline-landscape.md`
9. `examples/log-sample.md`

The highest-value logic lives in:

- ingest initialization and file naming,
- merge-vs-create article decisions,
- cascade updates,
- citation/relative-path rewriting,
- deterministic vs heuristic lint authority.

## Actual execution model

The host agent reads `SKILL.md` and performs one of three prompt-level operations:

- **Ingest**: fetch source -> save `raw/<topic>/...` -> create/update `wiki/<topic>/<article>.md` -> update `wiki/index.md` -> append `wiki/log.md`
- **Query**: read `wiki/index.md` -> read relevant articles -> answer in chat; optional archive writes a new wiki page and updates index/log
- **Lint**: auto-fix only structural/deterministic issues; report semantic/editorial issues

Important invariants from `SKILL.md`:

- first **ingest** initializes missing `raw/` / `wiki/` structure
- **query** and **lint** must not initialize; they should tell the user to ingest first
- ingest always does both raw capture and wiki compilation
- `wiki/` supports only **one level of topic subdirectories**
- archive pages are snapshots and should not be cascade-updated later

## State ownership model

State is filesystem-only and lives in the **target project**, not this repo.

- raw files are conceptually immutable
- normal wiki articles are mutable and may receive cascade updates
- archive pages are point-in-time snapshots
- `wiki/log.md` is append-only

Recovery and auditing are expected to come from git, file diffs, `wiki/index.md`, and `wiki/log.md`.

## Operational assumptions

- A surrounding tool supports Agent Skills and file edits.
- Web/file retrieval comes from the host environment; the skill itself does not implement fetchers.
- The corpus is small-to-medium enough that index-first discovery is still workable.
- Humans curate sources and review outputs; the agent does the bookkeeping and synthesis.

## Extension surface

Most repo changes should be made by editing:

- `SKILL.md` for behavior
- `references/*.md` for persistent file formats
- `examples/*` when behavior changes enough that representative outputs should be updated

There are no plugin hooks or provider adapters inside the repo. Customization is spec-first.

## Debugging / observability

When the skill behaves incorrectly, inspect generated artifacts rather than looking for runtime code:

- compare output files against `references/*.md`
- inspect `wiki/index.md` and `wiki/log.md`
- verify relative links
- check whether cascade updates were too broad or too narrow
- tighten ambiguous wording in `SKILL.md`

## Important sharp edges

- No tests, CI, or executable validation exist.
- Behavior quality depends heavily on the host agent following prose instructions precisely.
- There is visible spec/example drift:
  - `references/raw-template.md` requires `Published`, but the example raw file omits it.
  - `SKILL.md` uses `ingest` / `lint` log terminology, while `examples/log-sample.md` shows `Compile` / `Update`.
  - `references/index-template.md` is a global index template, but `examples/ai-coding-tools-index.md` is topic-local.

Treat examples as evidence of intent, not perfect conformance.

## Minimal path to use

1. Install via `npx add-skill Astro-Han/karpathy-llm-wiki` or manually copy `SKILL.md` + `references/` into a skill directory.
2. Open any project directory.
3. Ask the agent to ingest a source.
4. Inspect the created `raw/` and `wiki/` artifacts.

Without an external agent host, this repository does not run by itself.
