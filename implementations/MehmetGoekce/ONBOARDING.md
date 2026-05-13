# ONBOARDING

## What this repo actually is

`llm-wiki` is primarily a **Claude Code prompt/template package**, not a standalone application. The only concrete executable logic here is `setup.sh`, which scaffolds an external Logseq or Obsidian wiki, writes `llm-wiki.yml`, creates starter pages from `templates\`, and can copy `wiki.md` into a Claude project as `.claude\commands\wiki.md`.

The real runtime behavior for `/wiki ingest`, `/wiki query`, `/wiki lint`, `/wiki status`, and `/wiki import` lives in **`wiki.md`** as prompt instructions that Claude Code follows.

## Dominant architecture

- **Control plane:** `wiki.md`
- **Bootstrap plane:** `setup.sh`
- **State plane:** external wiki files + `llm-wiki.yml` + optional Claude memory directory + git
- **Semantic center:** L1/L2 split
  - **L1:** Claude memory, always loaded, for rules/gotchas/identity/credentials
  - **L2:** markdown wiki, loaded on demand, for projects/workflows/research/history

Think of the repo as a **schema-governed operating manual for Claude**, plus a script that lays down the initial filesystem structure.

## Highest-value files

1. `setup.sh` — only executable subsystem; understand bootstrap behavior here first.
2. `wiki.md` — most important file in the repo; defines runtime workflows and constraints.
3. `templates\logseq\Schema.md` and `templates\obsidian\Schema.md` — concrete ontology/page invariants.
4. `docs\schema-reference.md` — best human-readable explanation of page types, metadata, and lint rules.
5. `docs\l1-l2-architecture.md` — explains the project’s main design decision.
6. `openspec\specs\ingest.md`, `query.md`, `lint.md` — intended behavior and acceptance criteria.

## Real execution model

### Setup flow

`setup.sh`:

1. requires `python3` and `git`;
2. prompts for Logseq vs Obsidian, wiki path, namespaces, memory path, git init, skill install path;
3. renders schema/dashboard/hub pages from `templates\`;
4. writes `llm-wiki.yml`;
5. optionally copies `wiki.md` into another project’s `.claude\commands\`.

### Runtime flow

After setup, the user works **outside this repo**:

1. open the target vault/graph;
2. invoke `/wiki ...` in Claude Code;
3. Claude reads `llm-wiki.yml`, the schema page, and relevant wiki pages;
4. Claude mutates/reads the wiki according to `wiki.md`.

There is **no local ingest/query/lint engine** here beyond the prompt contract.

## State ownership

| State | Location |
|---|---|
| L2 wiki content | target Logseq/Obsidian vault |
| L1 operational memory | Claude memory directory (`memory_path`) |
| runtime config | `llm-wiki.yml` in wiki root |
| command definition | copied `wiki.md` in `.claude\commands\` |
| history/audit | git in the target wiki repo |

## Important invariants

- Tool mode (`logseq` vs `obsidian`) must govern **all** downstream formatting.
- L2 wiki is append-only by convention; Claude should add, not overwrite.
- Secrets belong in **L1 only**, never in the wiki.
- Cross-references are first-class; hubs must list children.
- The repo assumes Claude reads config **before** any wiki operation.

## Maturity and reality check

### Concrete / production-ish

- `setup.sh`
- template generation
- dual Logseq/Obsidian starter structures

### Prompt-defined / non-deterministic

- ingest
- query
- lint
- status
- import

The repo is operational as a workflow kit, but most runtime guarantees are **instructional rather than enforced by code**.

## Known sharp edges

- `setup.sh` tries to replace `<CONFIG_PATH>` in `wiki.md`, but the current `wiki.md` does not contain that placeholder.
- `README.md` says 8 default namespaces including `Careers`; `setup.sh`/`config.example.yml` default to 7 and omit it.
- `docs\logseq-vs-obsidian.md` references `migrate.sh`, but no such script exists.
- `status` has prompt support but no dedicated OpenSpec file.
- `import` exists in `wiki.md` only; it is the least mature path.
- No automated tests; validation is manual (`CONTRIBUTING.md`, `openspec\AGENTS.md`).

## How to modify safely

If changing behavior:

1. update `wiki.md` first;
2. update the relevant schema/template files if page shape changes;
3. update `setup.sh` if config generation or installation plumbing changes;
4. sync docs/specs after code changes or drift will grow immediately.

If changing semantics without setup impact, most work belongs in:

- `wiki.md`
- `docs\schema-reference.md`
- `docs\l1-l2-architecture.md`
- `openspec\specs\*.md`

## Best debugging path

When something feels wrong, inspect in this order:

1. generated `llm-wiki.yml`;
2. installed `.claude\commands\wiki.md`;
3. generated schema and hub pages in the target wiki;
4. Claude output from the `/wiki` command;
5. git diff in the target wiki repo.

## Fast mental model

This repo is a **Claude-operated markdown knowledge-base pattern** with:

- one bootstrap script;
- one command prompt file;
- two serialization backends (Logseq/Obsidian);
- no standalone engine.

The most important question when editing it is usually not “what code path runs?” but **“what will Claude do after reading `wiki.md`, `llm-wiki.yml`, and the schema?”**
