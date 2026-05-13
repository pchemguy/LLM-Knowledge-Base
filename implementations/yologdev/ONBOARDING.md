# ONBOARDING

## What this repo actually is

`karpathy-llm-wiki` / **yopedia** is a Next.js app whose real core is a **filesystem-backed wiki lifecycle engine**:

- ingest sources into `raw/`
- materialize/update wiki pages in `wiki/`
- keep `wiki/index.md` and `wiki/log.md` in sync
- query the wiki through BM25 + optional embeddings + LLM synthesis
- lint and repair corpus health
- expose the same corpus through web UI, CLI, and MCP

The UI is a shell around `src/lib/*`. If you need to understand behavior, start there.

## Semantic centers

### 1. Page lifecycle orchestration

**Read first:** `src/lib/lifecycle.ts`

This is the most important module. `runPageLifecycleOp()` owns the real write/delete contract:

1. mutate page file
2. update embeddings
3. update `index.md`
4. update cross-references / strip backlinks
5. append `log.md`
6. clean up revisions/discussions on delete

If you add a new write path and bypass `writeWikiPageWithSideEffects()` or `deleteWikiPage()`, you will likely drift index/log/revisions/embeddings/cross-links.

### 2. Wiki storage model

**Read next:** `src/lib/wiki.ts`, `src/lib/frontmatter.ts`, `src/lib/raw.ts`

Important invariants:

- wiki pages live in `wiki/<slug>.md`
- raw sources live in `raw/<slug>.md`
- `index.md` is the main browse/query catalog
- `log.md` is append-only activity history
- frontmatter is **not full YAML**; it is a constrained parser/serializer
- `sources` provenance is stored as JSON-in-frontmatter because nested YAML is intentionally unsupported

### 3. Ingest pipeline

**Read:** `src/lib/ingest.ts`, `src/lib/fetch.ts`, `src/lib/url-safety.ts`, `src/lib/schema.ts`

Important behavior:

- ingest supports **preview → approve** and direct ingest
- URL ingest does SSRF checks, redirect validation, content-type/size limits, and image download
- long content is chunked and continued through follow-up LLM calls
- `SCHEMA.md` is loaded at runtime and injected into prompts
- alias deduplication happens before page creation via `src/lib/alias-index.ts`

### 4. Query/retrieval pipeline

**Read:** `src/lib/query.ts`, `src/lib/query-search.ts`, `src/lib/bm25.ts`, `src/lib/embeddings.ts`

Important behavior:

- small wikis load all pages
- larger wikis use BM25
- optional vector search is fused with BM25 via RRF
- optional LLM re-ranking improves candidate selection
- query answers can be saved back into the wiki as first-class pages

## Main runtime surfaces

### Web UI

- `/ingest` → preview/approve or direct source ingest
- `/wiki` → index
- `/wiki/[slug]` → page view with metadata, backlinks, discussions, revisions
- `/query` → streaming query + history + save-to-wiki
- `/lint` → health checks + selected auto-fixes
- `/settings` → provider config + embedding rebuild
- `/raw` → raw source browser
- `/wiki/graph` → canvas graph view
- `/wiki/contributors` → contributor/trust view

### APIs

Most important routes:

- `src/app/api/ingest/route.ts`
- `src/app/api/query/stream/route.ts`
- `src/app/api/wiki/route.ts`
- `src/app/api/wiki/[slug]/route.ts`
- `src/app/api/lint/route.ts`
- `src/app/api/lint/fix/route.ts`
- `src/app/api/agents/[id]/context/route.ts`

### Agent / CLI surfaces

- CLI entrypoint: `src/cli.ts` (`pnpm cli`)
- MCP server: `src/mcp.ts` (`pnpm mcp`)

MCP reuses the same domain functions as the web app; it is another transport, not another architecture.

## State and persistence

Primary durable state:

- `wiki/*.md`
- `wiki/index.md`
- `wiki/log.md`
- `raw/*.md`

Secondary state:

- `wiki/.revisions/<slug>/...`
- `wiki/.vectors.json`
- `wiki/query-history.json`
- `discuss/<slug>.json`
- `agents/<id>.json`
- `.llm-wiki-config.json`

## Configuration

Provider resolution is **env > config file > defaults**.

Important env vars:

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GOOGLE_GENERATIVE_AI_API_KEY`
- `OLLAMA_BASE_URL`
- `OLLAMA_MODEL`
- `LLM_MODEL`
- `EMBEDDING_MODEL`
- `DATA_DIR`
- `WIKI_DIR`
- `RAW_DIR`

Settings UI persists config to `.llm-wiki-config.json` through `src/lib/config.ts`.

## Operational assumptions

- happy path is **single-process, local filesystem**
- write coordination uses **in-process** locks only (`src/lib/lock.ts`)
- expected corpus size is modest; several scans are whole-wiki
- Anthropic is supported for generation, but embeddings need OpenAI/Google/Ollama

## Extension guidance

### Safe places to extend

- ingest behavior → `src/lib/ingest.ts`
- retrieval/ranking → `src/lib/query-search.ts`
- answer behavior → `src/lib/query.ts`
- page metadata conventions → `SCHEMA.md` + `src/lib/frontmatter.ts`
- page lifecycle → `src/lib/lifecycle.ts`
- MCP tools → `src/mcp.ts`

### Rules worth preserving

- page writes go through lifecycle orchestration
- raw sources remain immutable
- frontmatter stays within the constrained parser’s supported subset
- `SCHEMA.md` is part of runtime behavior, not just docs

## Sharp edges / technical debt

1. **Storage abstraction is partial.** `src/lib/storage/*` exists, but `talk.ts`, `agents.ts`, `config.ts`, and parts of fetch/image handling still use direct `fs`.
2. **Cloudflare portability is not complete.** `cloudflare-r2` is detected but not implemented.
3. **Embedding architecture is inconsistent.** `StorageProvider` has embedding APIs, but `src/lib/embeddings.ts` writes `wiki/.vectors.json` directly.
4. **Naming is mid-pivot.** Repo/docs say yopedia; some UI metadata still says LLM Wiki.
5. **Some MCP/API affordances are ahead of reality.** Example: MCP `ingest_url` accepts `tags` but does not apply them.

## Debugging map

- provider/config issues → `src/lib/config.ts`, `src/lib/llm.ts`, `/api/status`
- ingest failures → `src/lib/fetch.ts`, `src/lib/url-safety.ts`, `src/lib/ingest.ts`
- broken write side effects → `src/lib/lifecycle.ts`, `src/lib/wiki.ts`, `src/lib/revisions.ts`, `src/lib/wiki-log.ts`
- poor retrieval → `src/lib/query-search.ts`, `src/lib/bm25.ts`, `src/lib/embeddings.ts`
- lint behavior → `src/lib/lint.ts`, `src/lib/lint-checks.ts`, `src/lib/lint-fix.ts`

## Best reading order

1. `README.md`
2. `YOYO.md`
3. `SCHEMA.md`
4. `src/lib/wiki.ts`
5. `src/lib/frontmatter.ts`
6. `src/lib/lifecycle.ts`
7. `src/lib/ingest.ts`
8. `src/lib/query.ts`
9. `src/lib/query-search.ts`
10. `src/mcp.ts`
11. `src/lib/__tests__/integration.test.ts`
