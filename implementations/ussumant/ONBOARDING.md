# ONBOARDING

## What this repo actually is

This repository is **not a standalone compiler app**. It is a **Claude/Codex plugin/spec bundle** for building and operating markdown knowledge wikis. The main behavior is defined in:

- `plugin/commands/*.md` — user-facing workflow contracts
- `plugin/skills/wiki-compiler/SKILL.md` — core compile pipeline
- `plugin/hooks/*` — session-start wiki-first guidance
- `plugin/visualize/*` — the only substantial executable runtime

The host LLM is the execution engine. This repo provides the protocol.

## Dominant architecture

- **Control plane:** markdown commands and skill specs
- **State plane:** `.wiki-compiler.json`, generated `schema.md`, generated `.compile-state.json`
- **Output plane:** compiled wiki markdown (`INDEX.md`, `topics/*.md`, `concepts/*.md`, `log.md`, optional `CONTEXT.md`)
- **Automation plane:** Bash session-start hook injects wiki-first context
- **Viewer plane:** Node server parses wiki markdown into graph JSON for `index.html`

The semantic center is `plugin/skills/wiki-compiler/SKILL.md`.

## Core runtime model

### Initialization

`plugin/commands/wiki-init.md`

- auto-detects `knowledge` vs `codebase` mode
- writes `.wiki-compiler.json`
- creates initial wiki dirs/files
- in codebase fast-path, immediately compiles

### Compilation

`plugin/commands/wiki-compile.md` → `plugin/skills/wiki-compiler/SKILL.md`

Phases:

1. scan sources
2. classify into topics
3. compile topic articles
4. derive concept articles
5. generate/update `schema.md`
6. regenerate `INDEX.md`
7. update `.compile-state.json` + `log.md`
8. generate/update `CONTEXT.md` in codebase mode

Only topic article compilation is allowed to parallelize.

### Session start

`plugin/hooks/hooks.json` → `plugin/hooks/session-start` → `plugin/hooks/wiki-session-context`

Behavior:

- finds nearest `.wiki-compiler.json`
- if wiki exists, tells agent to start from `INDEX.md` and prefer topic pages over raw files
- can warn if source files changed after last compile

### Visualization

`plugin/visualize/server.js` + `plugin/visualize/index.html`

- parses `INDEX.md`, `topics/*.md`, `concepts/*.md`
- concept edges come from concept frontmatter `topics_connected`
- fallback edges come from shared sources or topic-to-topic source references

## Critical files

| File | Why it matters |
| --- | --- |
| `plugin/skills/wiki-compiler/SKILL.md` | main behavioral brain |
| `plugin/commands/wiki-init.md` | setup semantics and mode detection |
| `plugin/commands/wiki-compile.md` | compile entry point |
| `plugin/hooks/wiki-session-context` | auto wiki-first startup behavior |
| `plugin/visualize/server.js` | concrete parser/runtime for compiled wiki |
| `plugin/templates/*.md` | output/capture soft schemas |
| `plugin/skills/wiki-compiler/adapters/*.md` | source acquisition extension points |

## State ownership

- `.wiki-compiler.json` — source scope, output path, mode, article structure, update policy
- `schema.md` — durable topic/concept naming and structure rules
- `.compile-state.json` — coarse incremental memory
- topic/concept markdown — synthesized knowledge
- `wiki-sources/captures/` — normalized external raw sources

## Important invariants

- source files are read-only during compile
- topic slugs are lowercase kebab-case
- topic pages use `##` section headings
- `Sources` sections are operationally important
- concept pages should expose `topics_connected` in frontmatter

The visualizer depends on those conventions.

## Operational reality

- there is **no local compiler binary**
- the repo is useful only inside a capable host agent, except for the visualizer
- fastest real usage path: install plugin → run `/wiki-init` → run `/wiki-compile`
- manual local exercise path: `node plugin/visualize/server.js --wiki-dir path/to/wiki`

## Environment / prerequisites

Core:

- Claude Code or Codex plugin/skill support
- Node.js
- Bash + Unix tools for hooks

Optional:

- Node 20+, npm, Field Theory CLI for `/fetch-bookmarks x`

## Extension points

### Safest to modify

- `plugin/templates/*`
- adapter markdown files
- init defaults / prompt text

### Semantically central

- `plugin/skills/wiki-compiler/SKILL.md`
- `plugin/hooks/wiki-session-context`

### When changing the graph

Check both:

- `plugin/visualize/server.js`
- markdown format assumptions in templates/skill

## Sharp edges / debt

- behavior is instruction-driven, not strongly enforced in code
- `.compile-state.json` is too thin for robust deterministic incrementality
- `mode` is overloaded (`codebase`/`knowledge` vs `staging`/`recommended`/`primary`)
- `wiki-ingest.md` logs to `compile-log.md`, while main compile flow uses `log.md`
- `wiki-visualize.md` documents `--port`, but `server.js` hardcodes `3848`
- cross-platform support is uneven because hooks and some commands assume Bash/macOS utilities
- adapter ecosystem is partial; only X bookmark sync is implemented
- there are no tests or build scripts in repo root

## Best reading order for future work

1. `README.md`
2. `plugin/skills/wiki-compiler/SKILL.md`
3. `plugin/commands/wiki-init.md`
4. `plugin/commands/wiki-compile.md`
5. `plugin/hooks/wiki-session-context`
6. `plugin/visualize/server.js`
7. relevant templates or adapters

## Practical debugging checklist

1. inspect `.wiki-compiler.json`
2. inspect `wiki/schema.md`
3. inspect `wiki/INDEX.md`
4. inspect `wiki/.compile-state.json`
5. inspect `wiki/log.md`
6. confirm topic article `Sources` sections
7. confirm visualizer parser assumptions if graph/view output looks wrong

## Mental model

Treat this repo as a **portable operating manual for an LLM-maintained wiki**, with a small Node/Bash support layer. Most changes are changes to the agent protocol, not to a traditional application runtime.
