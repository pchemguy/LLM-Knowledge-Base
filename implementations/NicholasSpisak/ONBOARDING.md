# ONBOARDING

## What this repo actually is

This repository packages a **skill-driven operating model** for an LLM-maintained Obsidian vault. It is not a standalone app or service. The repo's product is:

- skill prompts under `skills/`;
- a shared wiki contract in `skills/second-brain/references/wiki-schema.md`;
- agent-config templates in `skills/second-brain/references/agent-configs/`;
- one scaffold script in `skills/second-brain/scripts/onboarding.sh`.

The real runtime state lives in the user's generated vault, not in this repository.

## Dominant architecture

Treat the system as **prompt-governed file orchestration**:

- **control plane**: `skills/second-brain*.md`
- **state model**: `raw/` (immutable sources), `wiki/` (LLM-owned knowledge), `output/` (artifacts)
- **navigation/index state**: `wiki/index.md`
- **operation ledger**: `wiki/log.md`
- **frontend**: Obsidian

The semantic center is `skills/second-brain/references/wiki-schema.md`. Read that before changing anything else.

## Core execution model

Four operations define the system:

1. **Onboarding** (`skills/second-brain/SKILL.md`)  
   Collects vault parameters, runs `scripts/onboarding.sh`, then is supposed to generate agent config files from the templates.
2. **Ingest** (`skills/second-brain-ingest/SKILL.md`)  
   Reads a source from `raw/`, creates/updates source/entity/concept pages, adds wikilinks, updates index and log.
3. **Query** (`skills/second-brain-query/SKILL.md`)  
   Searches the wiki first (`wiki/index.md`, optionally `qmd`), reads relevant pages, answers with `[[wikilink]]` citations, may save synthesis pages.
4. **Lint** (`skills/second-brain-lint/SKILL.md`)  
   Audits broken links, orphans, contradictions, stale claims, missing pages, and index drift.

## Critical invariants

From `wiki-schema.md`:

- never modify `raw/`;
- every wiki page needs frontmatter with `tags`, `sources`, `created`, `updated`;
- always use `[[wikilink]]` for internal references;
- always update `wiki/index.md` when pages are created/deleted;
- always append to `wiki/log.md` for operations;
- prefer updating existing pages over creating duplicates;
- source pages stay factual; synthesis belongs in concept/synthesis pages.

These are not enforced by code; they are enforced by agent behavior.

## What is actually implemented vs specified

### Implemented concretely

- vault scaffolding and seed files: `skills/second-brain/scripts/onboarding.sh`
- onboarding test coverage: `tests/test_onboarding.sh`
- shared schema and agent templates

### Specified but not code-backed

- actual config-file generation during onboarding
- ingest engine
- query engine
- lint engine
- automatic repairs

Most repo behavior lives in prompts, not code.

## Important operational assumptions

- requires an external coding agent that supports skills/config files;
- Obsidian is the intended browsing UI;
- README documents Node.js, but actual runnable scripts also assume **bash** and **python3**;
- optional tools are `summarize`, `qmd`, and `agent-browser`;
- `qmd` matters only when the wiki outgrows manual/index navigation.

## Highest-value files to read first

1. `README.md`
2. `docs/REQUIREMENTS.md`
3. `skills/second-brain/references/wiki-schema.md`
4. `skills/second-brain-ingest/SKILL.md`
5. `skills/second-brain-query/SKILL.md`
6. `skills/second-brain-lint/SKILL.md`
7. `skills/second-brain/scripts/onboarding.sh`
8. `tests/test_onboarding.sh`

## Where to change behavior

- **global rules/schema** -> `skills/second-brain/references/wiki-schema.md`
- **onboarding wizard flow** -> `skills/second-brain/SKILL.md`
- **ingest/query/lint semantics** -> operation `SKILL.md` files
- **generated agent config formats** -> `skills/second-brain/references/agent-configs/*.md`
- **scaffolded vault structure** -> `skills/second-brain/scripts/onboarding.sh` and `tests/test_onboarding.sh`

## Sharp edges / risks

- README implies a fuller onboarding automation than the shell script alone provides.
- `onboarding.sh` and `tests/test_onboarding.sh` have an under-documented `python3` dependency.
- There is no transactional protection for multi-file ingest updates.
- There is no hard validator for schema compliance; linting is also prompt-defined.
- Multi-agent support is convention-based, so concurrent edits depend on external discipline/version control.

## Practical debugging heuristics

- start with `wiki/log.md` to see what the agent claims happened;
- compare actual pages to `wiki/index.md` for drift;
- inspect frontmatter when provenance or freshness looks wrong;
- use backlinks / graph view in Obsidian for orphan detection;
- if changing scaffold behavior, keep `tests/test_onboarding.sh` aligned.

## Repo maturity

This is a **partly operational, partly aspirational** project:

- onboarding scaffold is concrete and tested;
- knowledge operations are well-specified but rely on host-agent execution rather than shipped code.
