# ONBOARDING

## Actual purpose

This repo is a **distribution/scaffolding repo** for a compile-first project knowledge system. It does not run a long-lived service. Its job is to bootstrap another repo with:

- `docs/wiki/` markdown pages
- `manifests/` raw-source indexes
- `scripts/` validation/ingest/freshness tooling
- repo-level AI protocol files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.windsurfrules`)

The public entry point is `scripts/bootstrap_knowledge_system.py`; the real implementation is `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`.

## Dominant architectural identity

Think of this as a **template compiler + file-based maintenance runtime**:

1. bootstrap copies templates from `skills/knowledge-system-bootstrap/templates/`
2. generated scripts operate over files in the target repo
3. agent config files encode the session loop

The semantic center is the generated script suite, not the wrapper docs/plugin metadata.

## Semantic centers

Read these first if you need to understand behavior:

1. `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`
2. `skills/knowledge-system-bootstrap/templates/scripts/ingest_raw.py`
3. `skills/knowledge-system-bootstrap/templates/scripts/stale_report.py`
4. `skills/knowledge-system-bootstrap/templates/scripts/delta_compile.py`
5. `skills/knowledge-system-bootstrap/templates/scripts/provenance_check.py`
6. `skills/knowledge-system-bootstrap/templates/scripts/wiki_check.py`

`ingest_raw.py` is the richest script: it hashes raw files, classifies kinds, parses common formats structurally, updates `raw_sources.csv`, writes `raw_index.json`, and emits `intake_report.md`.

## Core runtime model

Bootstrapped repos are expected to operate with three persistent surfaces:

- **raw**: local evidence tree outside Git, usually resolved via `PROJECT_RAW_ROOT`
- **wiki**: Git-tracked compiled markdown under `docs/wiki/`
- **manifest/derived state**: `manifests/raw_sources.csv`, `raw_sources.meta.json`, `raw_index.json`, and generated reports

Agent/session control is instruction-driven:

1. run `python3 scripts/version_check.py`
2. read `docs/wiki/index.md`
3. read `docs/wiki/current-status.md`
4. read `docs/wiki/log.md`
5. read more wiki pages only as needed
6. write durable conclusions back into the wiki before ending the session

## Important execution flows

### Bootstrap

- root wrapper `scripts/bootstrap_knowledge_system.py` uses `os.execv(...)` to jump into the skill copy
- internal bootstrap iterates `TEMPLATE_TO_TARGET`
- templates are rendered with `__PROJECT_NAME__`, `__RAW_ROOT_NAME__`, `__TODAY__`
- `--force` overwrites; default behavior skips divergent existing files; backups become `.bak.<timestamp>`

### Raw intake

- `scripts/init_raw_root.py` creates the local raw directory layout
- `scripts/ingest_raw.py` walks the raw tree, hashes files, updates the manifest, writes `raw_index.json`, and emits `intake_report.md`

### Freshness

- `scripts/provenance_check.py` verifies non-session pages have `source_hash`; full mode compares against live raw files, `--ci` is structural only
- `scripts/stale_report.py` classifies fresh/stale/missing/unresolved/archived/new and writes `stale_report.md`
- `scripts/delta_compile.py --write-drafts` writes manual recompilation stubs into `docs/wiki/drafts/` instead of mutating live pages

## State ownership and invariants

- `docs/wiki/SCHEMA.md` defines wiki page frontmatter
- `scripts/wiki_check.py` enforces required files, frontmatter, valid links, log header format, and that `index.md` references wiki pages
- `manifests/raw_sources.meta.json` defines manifest schema version and allowed statuses (`new`, `compiled`, `archived`)
- `source: session` pages are provenance-exempt; non-session pages are expected to carry `source_hash`

The system has no DB, queue, daemon, or server state. Everything important is files plus conventions.

## CI-safe vs dev-only

`docs/wiki/runtime-profile.md` and runtime headers split scripts into:

- **ci-safe**: `wiki_check.py`, `raw_manifest_check.py`, `untracked_raw_check.py`, `wiki_size_report.py`, `provenance_check.py --ci`
- **dev-only**: `ingest_raw.py`, `stale_report.py`, `delta_compile.py`, full `provenance_check.py`, `init_raw_root.py`, `version_check.py`, `export_memory_repo.py`

This matters because raw files are expected to stay out of Git.

## Extension points

There is no runtime plugin system inside the generated knowledge system. Extension means changing the scaffold:

- edit files under `skills/knowledge-system-bootstrap/templates/`
- update `TEMPLATE_TO_TARGET` in the internal bootstrap script
- keep docs/tests/CI/demo in sync

If adding a new AI platform, treat it as a cross-cutting change touching templates, packaging docs, and tests.

## Operational assumptions

- Python 3 is the main runtime dependency
- Git/Bash are needed for upgrade/install flows, not core bootstrap
- raw files must be available locally if you want full provenance/stale checks
- teams must follow writeback discipline; there is no technical enforcement beyond validators and conventions

## Sharp edges / known drift

Confirmed repo drift to keep in mind:

1. file-count claims disagree (`README.md`/CI say 33; `CHANGELOG.md` and `docs/release-notes-v1.3.0.md` say 32; `SKILL.md` says 30)
2. `CONTRIBUTING.md` still describes pre-v1.3.0 embedded string templates
3. `templates/scripts/upgrade.sh` still says `# llm-wiki-version: 1.2.2`
4. `templates/scripts/ingest_raw.py` writes `"llm_wiki_version": "1.2.2"` into `raw_index.json`
5. `examples/demo-project/README.md` still invokes the skill-internal bootstrap script directly, contrary to root docs

## Best navigation path

For future work in this repo:

1. inspect `skills/knowledge-system-bootstrap/scripts/bootstrap_knowledge_system.py`
2. inspect the specific template you want to change under `skills/knowledge-system-bootstrap/templates/`
3. inspect `tests/test_bootstrap.py`
4. inspect `.github/workflows/wiki-lint.yml`
5. only then touch docs/packaging files

If behavior seems confusing, trust the generated script templates and tests over marketing-level docs.
