# ONBOARDING

## What this repo actually is

Link is a **local Markdown-backed memory runtime for LLM agents**. The repo is not primarily a wiki generator; it is a shared core for:

- **retrieval** from `wiki/` + `wiki/memories/`
- **explicit memory lifecycle** (remember, review, update, archive, forget)
- **ingest readiness/repair** for `raw/` -> `wiki/` workflows
- **three runtime surfaces**: CLI (`link.py`), local HTTP/UI (`serve.py`), MCP (`mcp_package/link_mcp/server.py`)

The most important mental model: **sources become wiki knowledge, explicit remember becomes durable memory, queries use both**.

## Semantic centers

Focus on these modules first:

- `mcp_package/link_core/memory.py` — memory records, recall ranking, duplicate/conflict checks, review lifecycle, profile/audit/explanation, proposal heuristics
- `mcp_package/link_core/query.py` — bounded answer-ready packets with provenance and follow-up actions
- `mcp_package/link_core/wiki.py` — cache build, search metadata, context expansion, graph data, backlinks rebuild/index rebuild
- `mcp_package/link_core/ingest.py` — pending/stale/blocked raw detection and guided next steps
- `mcp_package/link_core/validation.py` — required frontmatter, sections, dead links, stale backlink detection
- `mcp_package/link_core/status.py` — readiness summary and next actions

Most real behavior should be added in `link_core`, then surfaced outward.

## Runtime surfaces

### CLI: `link.py`

Public command surface for init/demo/status/query/brief/memory/repair/benchmark/verify flows. `init_wiki` and `create_demo` also define the repo’s intended first-run experience.

### Local HTTP/UI: `serve.py`

Loopback-only browser surface. Important constraints:

- binds only to `127.0.0.1`
- rejects `--host` / `--bind`
- validates `Host`
- requires `X-Link-Local-Action` for mutations
- validates local `Origin` / `Referer`
- rate limits local writes

Treat it as a **trusted local control plane**, not a deployable web app.

### MCP: `mcp_package/link_mcp/server.py`

Primary agent-facing integration. The `FastMCP` instructions encode the expected tool order:

1. `link_status`
2. `starter_prompts`
3. `ingest_status`
4. `query_link`
5. `memory_brief`
6. `get_graph_summary`
7. `backup_wiki`
8. `validate_wiki`

Sharp edge: the module parses `--wiki` and exits at import time if the wiki is missing.

## Core execution flows

### Query flow

Adapter -> `query.py:query_link` -> `memory.py:recall_memories` + `search.py:search_pages` + `wiki.py:context_for_topic` -> compact packet with `budget_report`, `follow_up`, provenance, and context packet.

### Memory write flow

Adapter -> `memory.py:write_memory_page` / `update_memory_page` -> duplicate/conflict checks -> write `wiki/memories/*.md` -> update `wiki/index.md` -> append `wiki/log.md` -> optionally rebuild backlinks -> clear adapter cache.

### Capture flow

`capture_session` stores long notes under `raw/memory-captures/` and returns **proposals only**. `accept_capture` is the point that turns one proposal into durable memory.

### Ingest control flow

`ingest.py:collect_ingest_status` scans `raw/`, source pages, secrets, stale mtimes, and backlink health, then returns `guidance`, `plan`, `completion`, and exact next prompts. Link **does not** do the actual raw->wiki authoring itself.

## State model

Durable state:

- `raw/` — source files plus `raw/memory-captures/`
- `wiki/` — authoritative Markdown pages
- `wiki/memories/` — explicit durable memory
- `wiki/index.md` — human catalog
- `wiki/log.md` — append-only operation log
- `wiki/_backlinks.json` — derived graph index
- `wiki/_link_schema.json` — schema marker
- `.link-cache/wiki-cache-v1.json` — derived persistent cache
- `.link-backups/` — local tar.gz backups

Persistence model:

- no DB
- Markdown + YAML frontmatter for primary state
- JSON for indexes/meta
- atomic per-file writes and lock files via `link_core/files.py`

Important limitation: multi-file updates are not transactional across page + index + log + backlinks.

## Operational workflow

### Fastest first run

```bash
python link.py demo
python link.py serve link-demo
```

### Manual setup without installers

```bash
python link.py init my-link
python link.py status --validate my-link
python link.py serve my-link
python -m pip install .\mcp_package
python -m link_mcp --wiki .\my-link\wiki
```

### Canonical day-to-day flow

1. `status --validate`
2. add files under `raw/`
3. `ingest-status`
4. external agent ingests according to `LINK.md`
5. `rebuild-index`
6. `rebuild-backlinks`
7. `validate`
8. `query` / `brief`
9. explicit memory flows only when the user wants durable recall

## Practical constraints and invariants

- Durable memory is **explicit**. Do not auto-save memory from normal retrieval.
- New/updated memory should normally end in `review_status: pending`.
- Archive is the default cleanup path; permanent forget is exceptional.
- Bounded retrieval is intentional. Prefer `query_link`, `graph-summary`, paginated page/backlink APIs, and `get_graph_summary` over full dumps.
- Web mutation APIs intentionally avoid duplicate/conflict override paths; explicit override decisions belong in CLI or MCP after human review.
- Root `wiki/` in the repo is scaffold/sample state, not trustworthy representative data.

## Extension guidance

When adding behavior:

1. put shared semantics in `mcp_package/link_core/`
2. expose them in `link.py`, `serve.py`, and/or `mcp_package/link_mcp/server.py`
3. update docs and contract guards:
   - `scripts/check_tool_contract.py`
   - `scripts/check_runtime_duplication.py`
   - `scripts/check_release_hygiene.py`
4. add tests under `tests/`

If you touch page formats or agent protocol, also update `LINK.md`, `README.md`, `mcp_package/README.md`, and relevant docs pages.

## Debugging and inspection

High-signal tools:

- `link.py status --validate`
- `link.py doctor`
- `link.py ingest-status`
- `link.py validate --strict`
- `link.py rebuild-index`
- `link.py rebuild-backlinks`
- `link.py memory-audit`
- `link.py memory-inbox`
- `link.py explain-memory`
- `link.py benchmark`

Tests worth reading:

- `tests/test_demo_snapshot.py`
- `tests/test_link_cli.py`
- `tests/test_mcp_contract.py`
- `tests/test_ingest_core.py`
- `tests/test_status_core.py`
- `tests/test_serve.py`
- `tests/test_large_wiki_smoke.py`

## Sharp edges / archaeology

- `ingest` is a workflow concept and status engine, not a first-class internal authoring engine.
- `.linkignore` is scaffolded/documented but not obviously enforced in the current runtime.
- `mcp_package/link_mcp/server.py` has import-time side effects.
- `link.py` and `serve.py` still contain some logic that the repo is gradually moving into `link_core`.
- Installers are bash-first; the manual Python path is simpler for Windows or automation.

## Reading order

1. `README.md`
2. `link.py`
3. `mcp_package/link_mcp/server.py`
4. `mcp_package/link_core/memory.py`
5. `mcp_package/link_core/query.py`
6. `mcp_package/link_core/wiki.py`
7. `mcp_package/link_core/ingest.py`
8. `mcp_package/link_core/validation.py`
9. `serve.py`
