---
repo: yologdev/yopedia
---

# karpathy-llm-wiki Onboarding Report

## SYNOPSIS

### Implementation Identity

This repository is a **filesystem-backed knowledge-workbench** implemented as a Next.js 15 App Router app. The core machine is not the UI but the content lifecycle around `src/lib/ingest.ts`, `src/lib/query.ts`, `src/lib/query-search.ts`, `src/lib/lifecycle.ts`, and `src/lib/wiki.ts`: ingest sources into markdown pages, keep an index/log in sync, enrich pages with frontmatter and cross-links, then query the resulting corpus through BM25, optional vector search, and LLM synthesis.

The dominant architectural style is **orchestration around markdown state**. Markdown pages in `wiki/` are the primary durable content artifact; most other subsystems exist to derive, search, annotate, or preserve that content. The main semantic center is the write/query path, not the React layer.

Observed maturity is mixed:

- **Production-like core**: ingest, page CRUD, query, lint, revisions, export, MCP, provider/config handling, and broad test coverage in `src/lib/__tests__`.
- **Experimental/aspirational edges**: storage-provider portability, Cloudflare deployment path, agent identity layer, and some “yopedia” pivot features are partially integrated rather than uniformly enforced.

### Quick Adaptation Assessment

The repo is reasonably modifiable if changes stay inside the existing semantic seams:

- **Best extension seams**: `src/lib/lifecycle.ts` for any page write/delete path, `src/lib/query-search.ts` for retrieval changes, `src/lib/ingest.ts` for ingest behavior, `src/lib/schema.ts` + `SCHEMA.md` for prompt/schema conventions, `src/mcp.ts` for agent tool exposure.
- **Main coupling constraint**: many features assume markdown pages plus `index.md`/`log.md` remain authoritative. Bypassing `writeWikiPageWithSideEffects()` usually breaks index, log, revisions, embeddings, or cross-references.
- **Portability constraint**: a storage abstraction exists in `src/lib/storage/*`, but several subsystems still bypass it and use direct `fs` (`src/lib/talk.ts`, `src/lib/agents.ts`, `src/lib/config.ts`, `src/lib/fetch.ts`), so non-filesystem backends are not actually end-to-end ready.

### Fastest Path to First Successful Run

The shortest realistic path is:

1. Install Node.js 22+ and pnpm.
2. Set one provider credential in `.env.local` (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GOOGLE_GENERATIVE_AI_API_KEY`, or Ollama settings).
3. Run `pnpm install`.
4. Run `pnpm dev`.
5. Open `http://localhost:3000`, then use `/ingest` to create the first page.

Minimum runtime dependencies are just Node, pnpm, local filesystem write access, and one LLM provider if you want real ingest/query generation. Without an LLM key, the app still boots and can browse/edit files, but query/ingest degrade or stop depending on path.

### Minimal Manual Setup Path

There is a meaningful manual path without Docker or GitHub automation:

1. `pnpm install`
2. Configure env or settings-backed provider
3. `pnpm dev` for development, or `pnpm build && pnpm start` for production

Direct entry points:

- Web app: `src/app/*`
- CLI: `pnpm cli` → `src/cli.ts`
- MCP server: `pnpm mcp` → `src/mcp.ts`

Data defaults to the current working directory:

- `wiki/` for generated pages
- `raw/` for ingested source documents

Optional overrides: `DATA_DIR`, `WIKI_DIR`, `RAW_DIR`.

### Operational Complexity Snapshot

- **Setup complexity**: low to medium; one Node app plus local writable directories.
- **Runtime coordination complexity**: medium; several write-side effects must stay aligned.
- **Operational fragility**: moderate; local single-process usage is the happy path.
- **Observability**: basic; logs/errors exist, but there are no metrics/traces.
- **Debugging difficulty**: moderate; most failures localize cleanly to fetch, provider config, prompt output, or lifecycle side effects.
- **Infrastructure assumptions**: local filesystem semantics, single-instance server assumptions for locking, optional network access to LLM providers and fetched URLs.

## 1. Repository Purpose

### Actual Implemented Purpose

Observed behavior: this repo implements a **local-first wiki application that lets humans and agents ingest sources, materialize them as markdown wiki pages, query those pages with citations, lint the corpus, inspect history, and expose the wiki through REST, CLI, and MCP interfaces**.

The actual problem being solved is broader than “LLM reads docs and answers questions.” The implementation tries to make the LLM maintain a persistent knowledge artifact:

- raw sources are stored in `raw/` via `src/lib/raw.ts`
- wiki pages are stored in `wiki/` via `src/lib/wiki.ts`
- page structure is constrained by runtime-loaded conventions from `SCHEMA.md` via `src/lib/schema.ts`
- query answers can be written back into the wiki via `src/lib/query.ts::saveAnswerToWiki`
- linting treats the wiki as a maintained corpus rather than a disposable answer cache via `src/lib/lint.ts`

### Relationship to the Conceptual Description

The Karpathy concept is implemented concretely, but with important extensions and deviations.

**Implemented from the concept:**

- raw/wiki/schema layering (`src/lib/raw.ts`, `src/lib/wiki.ts`, `SCHEMA.md`)
- ingest/query/lint loops (`src/lib/ingest.ts`, `src/lib/query.ts`, `src/lib/lint.ts`)
- index/log files as navigation and chronology (`src/lib/wiki.ts::listWikiPages`, `src/lib/wiki-log.ts`)
- markdown as the primary knowledge artifact

**Extensions beyond the concept:**

- web UI and REST API (`src/app/*`, `src/app/api/*`)
- CLI (`src/cli.ts`)
- MCP server for external agents (`src/mcp.ts`)
- revisions, contributor profiles, talk threads, graph visualization, dataview queries, Obsidian export, embeddings, and agent profiles

**Deviations / constraints:**

- the wiki is not LLM-exclusive; users can create, edit, and delete pages directly through `/wiki/new`, `/wiki/[slug]/edit`, `/api/wiki`, and MCP write tools
- not all durable state is markdown; discussions, agent profiles, query history, config, and vectors are JSON sidecars
- the project still presents itself partly as “LLM Wiki” and partly as “yopedia”; naming and schema evolution are mid-transition (`README.md`, `YOYO.md`, `src/app/layout.tsx`, `src/app/page.tsx`)

### Target Use Cases

Observed target use cases:

- personal or research wiki construction from URLs/text
- querying a maintained markdown corpus with citations
- exposing the corpus to external coding/research agents through MCP
- operating a local knowledge base that can be browsed, linted, exported, and manually edited
- bootstrapping “agent identity” bundles through wiki pages and agent context endpoints

### Scope Boundaries

What is clearly in scope:

- local markdown/wiki management
- LLM-backed ingest and query
- retrieval over current wiki pages
- provenance and page metadata
- content maintenance workflows

What is not fully implemented or remains exploratory:

- multi-user auth or permissioning
- distributed coordination or durable multi-process locking
- truly provider-agnostic storage beyond local FS
- the “agent surface” as a mature separate representation; current implementation mostly layers JSON registries and scope filters on top of the markdown wiki

## 2. High-Level System Model

At a systems level, this project behaves like a **content lifecycle engine wrapped in a Next.js product shell**.

The core mental model is:

1. **Sources arrive** as text or fetched URLs.
2. **LLM/editor logic transforms** them into markdown pages shaped by `SCHEMA.md`.
3. **Lifecycle orchestration** writes page content, updates the index, saves revisions, updates embeddings, amends cross-references, and appends the activity log.
4. **Retrieval logic** ranks relevant pages from the wiki and feeds them back into an LLM for citation-bearing answers.
5. **Maintenance logic** scans the corpus for structural problems and optionally rewrites/fixes content.
6. **Agent-facing surfaces** expose the same corpus via MCP and agent context endpoints.

The dominant architectural concerns are:

- **state ownership in files** rather than a database
- **write-path consistency** across page file, index, log, revisions, and embeddings
- **retrieval quality** over a medium-sized markdown corpus
- **prompt/schema co-evolution** by loading conventions from `SCHEMA.md` at runtime

The project’s behavioral intelligence primarily lives in:

- `src/lib/lifecycle.ts` — real write/delete orchestration authority
- `src/lib/ingest.ts` — source-to-page transformation and metadata migration logic
- `src/lib/query.ts` + `src/lib/query-search.ts` — retrieval and answer orchestration
- `src/lib/lint-checks.ts` + `src/lib/lint-fix.ts` — corpus health semantics

The React/UI layer mainly exposes these capabilities; it does not define the domain semantics.

## 3. Conceptual Capability Mapping

| Capability | Status | Primary implementation | Execution semantics | Notes / limitations |
|---|---|---|---|---|
| Source ingest from URL/text | Implemented | `src/lib/ingest.ts`, `src/lib/fetch.ts`, `/api/ingest` | Fetch or accept text, optionally preview, then persist raw source and write/update wiki page | URL path includes SSRF checks; preview mode is first-class |
| Batch URL ingest | Implemented | `/api/ingest/batch`, `src/components/BatchIngestForm.tsx` | Streams per-URL NDJSON results sequentially | Batch is bounded by `MAX_BATCH_URLS`; no queueing |
| Query wiki with citations | Implemented | `src/lib/query.ts`, `src/lib/query-search.ts`, `/api/query`, `/api/query/stream` | Select pages, build context, call LLM, extract citations | Streaming route falls back client-side to non-streaming |
| Save query output back to wiki | Implemented | `src/lib/query.ts::saveAnswerToWiki`, `/api/query/save` | Wraps answer in frontmatter and routes through unified lifecycle pipeline | Produces “query-answer” tagged pages |
| Persistent wiki index/log | Implemented | `src/lib/wiki.ts`, `src/lib/wiki-log.ts` | `index.md` is regenerated from entries; `log.md` is append-only | Index remains summary-oriented, not graph-derived |
| Manual page CRUD | Implemented | `/api/wiki`, `/api/wiki/[slug]`, `/wiki/new`, `/wiki/[slug]/edit` | Page bodies are edited without exposing raw frontmatter in UI | Must preserve metadata server-side |
| Cross-reference maintenance | Implemented | `src/lib/search.ts`, `src/lib/lifecycle.ts` | LLM chooses related pages; target pages receive “See also” backlinks | Heuristic/LLM-dependent, not graph-theoretic |
| Hybrid search | Implemented | `src/lib/bm25.ts`, `src/lib/query-search.ts`, `src/lib/embeddings.ts` | BM25 always, optional vectors, optional LLM re-rank | Embeddings require non-Anthropic provider support |
| Lint and auto-fix | Implemented | `src/lib/lint.ts`, `src/lib/lint-checks.ts`, `src/lib/lint-fix.ts`, `/api/lint`, `/api/lint/fix` | Structural and semantic checks, some deterministic fixes, some LLM rewrites | Contradiction/missing-concept checks depend on LLM |
| Revision history | Implemented | `src/lib/revisions.ts`, `/api/wiki/[slug]/revisions`, `RevisionHistory` | Snapshot-before-overwrite, full-file revisions, optional author/reason sidecars | No diff/merge model, just snapshots |
| Discussions / talk pages | Implemented | `src/lib/talk.ts`, `/api/wiki/[slug]/discuss*`, `DiscussionPanel` | JSON-backed threads/comments per page | Uses direct fs, not storage abstraction |
| Contributor profiles / trust | Implemented | `src/lib/contributors.ts`, contributor pages/routes | Aggregates revisions + discussion activity, heuristically computes trust | Batch scans all content; small-scale assumption |
| Agent identity/context | Partially mature but functional | `src/lib/agents.ts`, `/api/agents/*`, MCP tools | Stores agent profile JSON plus wiki-backed identity/learnings/social pages | Clear useful shape, but still local and ad hoc |
| MCP server | Implemented | `src/mcp.ts`, `mcp.json` | stdio MCP server exposing read/write/query/seed tools | Directly reuses library functions |
| Graph browse | Implemented | `/api/wiki/graph`, `src/lib/graph.ts`, `src/lib/graph-render.ts`, `useGraphSimulation` | Builds link graph, detects communities, simulates client-side physics | Mostly visualization, not semantic storage |
| Dataview-style frontmatter querying | Implemented | `src/lib/dataview.ts`, `/api/wiki/dataview` | Filters/sorts pages by parsed frontmatter fields | Works over current page frontmatter only |
| Obsidian export | Implemented | `src/lib/export.ts`, `/api/wiki/export` | Converts markdown links to wikilinks and zips vault | Preserves frontmatter |
| Cloudflare-compatible storage/provider swap | Aspirational scaffolding | `src/lib/storage/*` | Factory detects provider and exposes interface | Only filesystem provider exists; many modules bypass abstraction |

## 4. Architecture and Component Analysis

### 4.1 Product Shell: Next.js App Router

**Primary files:** `src/app/layout.tsx`, `src/app/page.tsx`, `src/app/*/page.tsx`, `src/app/api/*`

Responsibility:

- server-render page shells for wiki, raw sources, graph, contributors, log
- mount client components/hooks for interactive flows like ingest, query, settings, lint
- expose a REST-ish API surface that mirrors the domain libraries

Architectural significance is moderate, not dominant. The app layer wires UX and transport, but most semantics are delegated down into `src/lib`.

### 4.2 Core Wiki Storage and Parsing Layer

**Primary files:** `src/lib/wiki.ts`, `src/lib/frontmatter.ts`, `src/lib/raw.ts`, `src/lib/types.ts`, `src/lib/paths.ts`

This layer owns:

- path resolution (`DATA_DIR`, `WIKI_DIR`, `RAW_DIR`)
- safe slug validation
- page I/O
- index parsing/writing
- frontmatter parsing/serialization
- page cache for multi-step operations

Important semantics:

- wiki pages are durable markdown files in `wiki/<slug>.md`
- `index.md` is the canonical list surface for browsing/query selection
- frontmatter is intentionally a **constrained YAML subset**, not general YAML (`src/lib/frontmatter.ts`)
- typed frontmatter normalization is schema-aware for fields like `confidence`, `disputed`, `expiry`, `authors`, `contributors`, and `aliases`

This is a real behavioral boundary, not just organization. Nearly every feature depends on its guarantees.

### 4.3 Unified Page Lifecycle Pipeline

**Primary files:** `src/lib/lifecycle.ts`, `src/lib/revisions.ts`, `src/lib/wiki-log.ts`, `src/lib/lock.ts`

This is the strongest architectural center in the repo.

`runPageLifecycleOp()` in `src/lib/lifecycle.ts` centralizes the page mutation contract:

1. validate slug
2. mutate page file
3. update embedding index
4. clean up related data on delete
5. mutate `index.md`
6. update cross-page references
7. append `log.md`

Why it exists in this form: the project learned that parallel write paths drift. The code explicitly encodes that lesson in comments and structure. Any new write-like feature is expected to route through `writeWikiPageWithSideEffects()` or `deleteWikiPage()`.

Hidden coupling:

- revisions are captured inside `writeWikiPage()` before overwrite
- cross-reference updates assume markdown links and a “See also” convention
- log structure is parseable markdown headings
- locking is in-process only

### 4.4 Ingest Pipeline

**Primary files:** `src/lib/ingest.ts`, `src/lib/fetch.ts`, `src/lib/url-safety.ts`, `src/lib/schema.ts`, `src/lib/sources.ts`, `src/lib/alias-index.ts`

Responsibility:

- source acquisition (URL/text/X mention)
- chunking and continuation prompting for long sources
- frontmatter migration/defaulting
- provenance tracking
- alias-aware deduplication
- preview/commit workflow

Notable semantics:

- ingest can be preview-only (`options.preview`) or direct write
- `SCHEMA.md` page conventions are loaded at runtime into prompts, so schema docs directly influence LLM behavior
- URL ingest performs SSRF checks, redirect validation, content-type limits, size limits, and optional image download/rewrite
- re-ingest uses prior `source_url`
- structured provenance is stored as JSON serialized into frontmatter because nested YAML is intentionally unsupported

This subsystem directly operationalizes the original concept.

### 4.5 Retrieval and Query Engine

**Primary files:** `src/lib/query.ts`, `src/lib/query-search.ts`, `src/lib/bm25.ts`, `src/lib/embeddings.ts`, `src/lib/search.ts`, `src/lib/citations.ts`

Responsibility:

- select relevant pages
- build query context
- construct system prompts
- call LLMs for answer generation
- extract citations
- save answers as pages

Control is layered:

- `query-search.ts` owns retrieval and context assembly
- `query.ts` owns prompt construction and answer behavior
- `embeddings.ts` adds optional dense retrieval

Key design choice: the repo kept the original index-first spirit but moved beyond it. It now uses BM25 over titles/summaries/full bodies, optional vectors, RRF fusion, and optional LLM re-ranking.

### 4.6 Search, Graph, and Browse Utilities

**Primary files:** `src/lib/search.ts`, `src/lib/graph.ts`, `src/lib/graph-render.ts`, `src/lib/dataview.ts`, `src/lib/export.ts`

This is mostly read-side infrastructure:

- content search and fuzzy fallback
- backlink discovery
- graph construction and client rendering
- frontmatter-based ad hoc querying
- Obsidian export

These modules extend browseability rather than define corpus semantics.

### 4.7 Linting and Corpus Maintenance

**Primary files:** `src/lib/lint.ts`, `src/lib/lint-checks.ts`, `src/lib/lint-fix.ts`

Responsibility:

- structural health checks
- semantic quality checks
- selected auto-fixes

Checks span multiple maturity levels:

- deterministic structural checks: orphan, stale index, empty page, broken link, missing crossref
- metadata quality checks: stale page, low confidence, unmigrated page, duplicate entity
- LLM-dependent semantic checks: contradiction, missing concept page

The linter is a maintenance engine for the persistent corpus, not just code-style linting.

### 4.8 Provider and Configuration Layer

**Primary files:** `src/lib/config.ts`, `src/lib/providers.ts`, `src/lib/llm.ts`, `src/app/api/settings/route.ts`

Responsibility:

- resolve provider/model credentials from env + config file
- mask keys and annotate config sources
- instantiate Vercel AI SDK providers
- handle retries for transient provider errors

Architecture is centralized and reused cleanly by both UI and server code. This is one of the more polished seams in the repo.

### 4.9 Storage Abstraction

**Primary files:** `src/lib/storage/types.ts`, `src/lib/storage/index.ts`, `src/lib/storage/filesystem.ts`

Nominal responsibility:

- abstract storage away from local FS
- enable future Cloudflare R2 / alternative backends

Reality check:

- core wiki/raw/revision/log code does use `getStorage()`
- several important subsystems bypass it entirely (`talk.ts`, `agents.ts`, `config.ts`, `fetch.ts`)
- `StorageProvider` exposes embedding/index APIs that the current embedding implementation does not actually use

This is therefore partly real and partly aspirational.

### 4.10 Agent/MCP Layer

**Primary files:** `src/mcp.ts`, `src/lib/agents.ts`, `src/app/api/agents/*`

Responsibility:

- expose wiki read/write/query tools over MCP
- register agents as profiles plus wiki-backed identity pages
- assemble agent context bundles

This subsystem is semantically important because it reinterprets the wiki as an agent runtime surface, but it is still specialized rather than globally structuring the app.

### 4.11 UI-Specific Interaction Layer

**Primary files:** `src/hooks/useIngest.ts`, `src/hooks/useStreamingQuery.ts`, `src/hooks/useSettings.ts`, `src/hooks/useGraphSimulation.ts`, `src/components/*`

This layer owns UX-specific flow control:

- two-phase ingest preview/approve
- streaming query with fallback
- settings save/test/rebuild
- graph physics/render loop

It is important for practical operation but not the primary architectural core.

## 5. Execution Flow Analysis

### 5.1 Startup / Initialization

Observed runtime path:

1. Next.js boots the App Router.
2. `src/app/layout.tsx` installs theme script, nav, and client providers.
3. Data directories are not globally initialized at startup; they are created lazily by write paths (`ensureDirectories()` in `src/lib/wiki.ts`, `ensureDiscussDir()` in `src/lib/talk.ts`, `ensureAgentsDir()` in `src/lib/agents.ts`).
4. Provider state is resolved lazily by `src/lib/config.ts` / `src/lib/llm.ts`.

Implication: the app starts with an empty or missing `wiki/`/`raw/` and only materializes them when needed.

### 5.2 Text/URL Ingest

**UI flow:** `src/app/ingest/page.tsx` → `src/hooks/useIngest.ts` → `/api/ingest`  
**Domain flow:** `src/app/api/ingest/route.ts` → `src/lib/ingest.ts`

Text path:

1. user enters title/content
2. `useIngest` can call preview or direct ingest
3. `/api/ingest` validates body
4. `ingest()` slugifies title and resolves aliases via `resolveAlias()`
5. content is chunked if oversized
6. LLM generates full page or continuation fragments
7. raw source is written to `raw/<slug>.md`
8. frontmatter is built/merged, including provenance and schema migration defaults
9. unified lifecycle pipeline writes page, updates index, embeddings, cross-refs, log
10. alias index is updated incrementally

URL path adds:

1. `fetchUrlContent()` with SSRF/content-type/size checks and redirect validation
2. `downloadImages()` rewrites markdown image URLs to local assets under `raw/assets/<slug>/`
3. then it falls through to the same `ingest()` pipeline

### 5.3 Preview / Approve Ingest

This is a distinct implemented flow, not documentation fiction.

1. `useIngest.handlePreview()` POSTs `{ preview: true }`
2. `ingest()` runs generation and related-page detection but **skips disk writes**
3. UI renders `IngestPreview`
4. approve POSTs `generatedContent`
5. `ingest()` skips the LLM call and commits the exact approved content

This is one of the clearest examples of the intended human-in-the-loop workflow.

### 5.4 Query Flow

**UI flow:** `src/app/query/page.tsx` → `useStreamingQuery.ts`  
**API/domain flow:** `/api/query/stream` or `/api/query` → `src/lib/query.ts` / `src/lib/query-search.ts`

Sequence:

1. user submits question and format
2. client first attempts `/api/query/stream`
3. route validates question/format/scope, verifies wiki is non-empty and provider configured
4. `selectPagesForQuery()` picks pages:
   - all pages for small wiki
   - otherwise BM25
   - optionally vector search
   - optionally LLM rerank
5. `buildContext()` loads selected pages
6. `buildQuerySystemPrompt()` combines selected context, whole-index listing, `SCHEMA.md` conventions, and format hints
7. provider stream is returned with `X-Wiki-Sources` header
8. client accumulates tokens, then refines sources to actual cited slugs
9. completed answers are appended to query history

Fallback path:

- if streaming endpoint fails, `useStreamingQuery` retries through `/api/query`

### 5.5 Save Query Answer to Wiki

1. `QueryResultPanel` hits `/api/query/save`
2. route validates title/content
3. `saveAnswerToWiki()` constructs markdown, summary, and query-answer frontmatter
4. it delegates to `writeWikiPageWithSideEffects()`
5. history entry can then be marked with `savedAs`

Important architectural point: saved query answers are not a special storage class; they become first-class wiki pages.

### 5.6 Manual Edit / Delete

**Edit path:** `/api/wiki/[slug]::PUT`

1. server reads current page + frontmatter
2. new body replaces visible markdown only
3. frontmatter is preserved and `updated` bumped
4. contributor is appended if provided
5. write goes through lifecycle pipeline

**Delete path:** `deleteWikiPage()` in `src/lib/lifecycle.ts`

1. page is deleted from `wiki/`
2. embedding entry removed
3. revisions removed
4. discussions removed
5. index row removed
6. backlinks stripped from other pages
7. log entry appended

Raw source files are intentionally left untouched, preserving the “raw is immutable” model.

### 5.7 Lint / Fix Flow

**UI flow:** `src/app/lint/page.tsx` → `useLint`  
**Domain flow:** `src/lib/lint.ts` → `src/lib/lint-checks.ts`

Sequence:

1. lint route/hook resolves enabled checks and severity filter
2. disk slugs and index entries are loaded
3. lightweight checks run in parallel
4. LLM-dependent semantic checks run in parallel if enabled
5. results are filtered and summarized
6. lint pass is appended to `log.md`

Fix path:

1. UI sends issue data to `/api/lint/fix`
2. route dispatches to `fixLintIssue()`
3. deterministic or LLM-backed repair runs
4. fix typically reuses lifecycle write/delete path

### 5.8 Agent Seeding / Agent Context Flow

**Seed flow:** `/api/agents/seed` → `seedAgent()`

1. validate agent id and sections
2. create/update wiki pages for identity/learnings/social sections
3. assign frontmatter with agent authorship and long expiry
4. register agent JSON profile in `agents/<id>.json`

**Context flow:** `/api/agents/[id]/context`

1. load agent profile
2. read all referenced wiki pages for identity/learnings/social
3. concatenate each section with separators
4. return one bundled context payload plus meta counts

### 5.9 MCP Flow

`src/mcp.ts` is effectively a second transport layer over the same domain library. MCP tool handlers call the same ingest/query/wiki/agent functions used elsewhere, so MCP does not define an alternate model; it is an alternate interface.

## 6. State and Persistence Model

### State Ownership

Primary content state:

- `wiki/<slug>.md` — canonical page content
- `wiki/index.md` — catalog used by browse and retrieval
- `wiki/log.md` — chronological activity trail
- `raw/<slug>.md` — immutable source text

Secondary durable state:

- `wiki/.revisions/<slug>/<timestamp>.md` + `.meta.json` — snapshots and attribution
- `wiki/.vectors.json` — vector store maintained by `src/lib/embeddings.ts`
- `wiki/query-history.json` — saved query history
- `.llm-wiki-config.json` under `DATA_DIR` — persisted provider config
- `discuss/<slug>.json` — talk threads
- `agents/<id>.json` — agent profiles

### Mutable vs Immutable

- **Intended immutable**: raw sources after capture
- **Mutable**: wiki pages, index, log, revisions set, vector store, config, discussions, agent profiles

### Caching

- `src/lib/wiki.ts` provides a per-operation page cache used by multi-step flows like query/lint
- `src/lib/config.ts` caches config synchronously for 5 seconds
- alias index is cached in-memory and incrementally updated

### Serialization Model

- wiki pages: markdown + constrained YAML frontmatter
- provenance field `sources` is JSON embedded into frontmatter string space
- discussions, agents, query history, config, vectors: JSON files

### Synchronization

- in-process locks via `withFileLock()` serialize shared resources like `index.md`, `log.md`, vectors, and discuss files
- no cross-process lock or database transaction boundary exists

### Recovery Semantics

- revisions provide local page rollback material but there is no automated restore flow
- many reads degrade gracefully on missing files
- embedding failures are explicitly non-fatal in lifecycle operations

## 7. Coordination and Control Semantics

### Execution Authority

Control is mostly centralized in library functions, not distributed across components:

- **page mutation authority**: `runPageLifecycleOp()` in `src/lib/lifecycle.ts`
- **query selection authority**: `selectPagesForQuery()` / `searchIndex()`
- **provider resolution authority**: `src/lib/config.ts` + `src/lib/llm.ts`
- **lint orchestration authority**: `src/lib/lint.ts`

### Coordination Topology

The system is mostly **directive and synchronous**:

- request arrives
- route or hook calls library function
- library function performs a fixed orchestration sequence
- response is returned

There is no internal event bus, queue, or actor system.

### Delegation

Delegation happens by semantic layer:

- UI delegates to API/hooks
- API delegates to library modules
- library delegates to storage/provider/fetch/LLM helpers

The most meaningful delegations are:

- ingest/query delegate generation to the configured LLM
- query delegates ranking to BM25/vector/optional rerank
- lifecycle delegates only storage-like effects; it still owns orchestration

### Concurrency Model

- Reads are often parallelized (`Promise.all`) inside lint, graph/context loading, and some agent routes
- Writes are serialized per logical key using in-memory lock chains
- Batch ingest streams results sequentially per URL rather than parallelizing requests

### Failure Propagation

- fetch/provider/input errors generally propagate as HTTP errors or thrown library exceptions
- some optional/secondary failures are intentionally softened:
  - vector updates in lifecycle
  - malformed provenance parsing
  - malformed agent files during listing
  - missing talk or revision directories

### Cancellation / Retry

- LLM text generation retries transient failures with exponential backoff in `src/lib/llm.ts`
- streaming query can be aborted from the client hook
- there is no general task cancellation framework beyond request abort semantics

## 8. Configuration and Environment Model

### Configuration Hierarchy

Observed precedence:

1. environment variables
2. `.llm-wiki-config.json`
3. provider defaults

### Important Environment Variables

Required/primary:

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GOOGLE_GENERATIVE_AI_API_KEY`
- `OLLAMA_BASE_URL`
- `OLLAMA_MODEL`

Optional behavior/config:

- `LLM_MODEL`
- `EMBEDDING_MODEL`
- `DATA_DIR`
- `WIKI_DIR`
- `RAW_DIR`
- `STORAGE_PROVIDER`

### Runtime Modes

- development: `pnpm dev`
- production build/start: `pnpm build`, `pnpm start`
- Docker standalone: `Dockerfile`, `docker-compose.yml`
- MCP stdio server: `pnpm mcp`
- CLI mode: `pnpm cli`

### Provider Model

Supported providers are centralized in `src/lib/providers.ts`:

- Anthropic
- OpenAI
- Google
- Ollama

Embeddings are only supported for OpenAI, Google, and Ollama.

### Deployment Assumptions

The code is optimized for local Node.js and a writable filesystem. The Docker image preserves this by mounting `/app/wiki` and `/app/raw`. Cloudflare/R2 support is an architectural direction, not a finished runtime.

## 9. Operational Usage Model

### Canonical Human Workflow

1. configure provider in env or `/settings`
2. ingest first source via `/ingest`
3. browse `/wiki` and inspect page metadata/backlinks
4. ask questions in `/query`
5. save valuable answers back into the wiki
6. run `/lint` periodically and fix issues
7. inspect `/wiki/log`, `/wiki/contributors`, `/wiki/graph`, and `/raw`

### Operator / Developer Workflow

1. run local app
2. inspect or edit markdown/wiki behavior through `src/lib/*`
3. use CLI for scripted ingest/query/lint/list/status
4. use MCP when integrating external agents

### Agent Workflow

There are two actual agent-facing models:

1. **generic wiki maintenance via MCP** — search, read, create, update, delete, ingest, query
2. **identity bootstrap via agent profiles** — seed an agent and fetch `/api/agents/[id]/context`

### Production vs Development Reality

The repository contains GitHub-agent growth docs (`README.md`, `YOYO.md`), but the application itself is a conventional self-hosted Next.js app. The “self-evolving agent pipeline” is repository meta-process, not runtime app logic.

## 10. Extension and Customization Architecture

### Real Extension Mechanisms

- **SCHEMA-driven prompt customization**: `SCHEMA.md` is read at runtime by `src/lib/schema.ts`
- **provider abstraction**: `src/lib/llm.ts`, `src/lib/providers.ts`
- **storage-provider abstraction**: `src/lib/storage/*` (partial)
- **MCP tool registry**: `src/mcp.ts`
- **agent page seeding/profile registry**: `src/lib/agents.ts`
- **frontmatter query engine**: `src/lib/dataview.ts`

### How the System Expects to Evolve

Observed intended evolution paths:

- richer yopedia metadata and trust semantics in page frontmatter
- stronger agent identity/context features
- alternate storage backends
- more semantic projections of the wiki for agents

### Non-Mechanisms

There is no general plugin loader, dependency injection container, or event-hook framework. Extension mostly means adding code to existing semantic centers.

## 11. Key Architectural Decisions and Tradeoffs

### Markdown as Primary Domain State

Decision: keep core knowledge as markdown files rather than a database.

Tradeoff:

- pro: inspectable, portable, exportable, Obsidian-friendly
- con: consistency requires careful orchestration across many files and sidecars

### Unified Lifecycle Pipeline

Decision: route all page mutations through one shared orchestration path.

Tradeoff:

- pro: prevents drift between ingest/edit/save/delete behaviors
- con: central module becomes a high-coupling hotspot

### Runtime-Loaded Schema

Decision: prompts pull conventions from `SCHEMA.md` at runtime.

Tradeoff:

- pro: prompt and schema evolve together without code edits
- con: behavior depends on mutable documentation text and can drift subtly

### Hybrid Retrieval

Decision: combine BM25, optional embeddings, and optional LLM reranking.

Tradeoff:

- pro: better recall/precision than naive index-only selection
- con: more moving parts and configuration-sensitive behavior

### Constrained Frontmatter Parser

Decision: reject full YAML in favor of a tiny supported subset.

Tradeoff:

- pro: predictable round-tripping and type control
- con: awkward encodings like JSON-in-frontmatter for structured provenance

## 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

### 12.1 Storage Abstraction Is Incomplete

Observed inconsistency:

- `wiki.ts`, `raw.ts`, `revisions.ts`, `query-history.ts` use `getStorage()`
- `talk.ts`, `agents.ts`, `config.ts`, and `fetch.ts` use direct `fs`

Implication: the nominal storage abstraction does not yet own all durable state, so non-filesystem providers are incomplete by design.

### 12.2 Cloudflare Portability Is Aspirational

Evidence:

- `src/lib/storage/index.ts` can detect `"cloudflare-r2"`
- it immediately throws “not yet implemented”
- `FilesystemStorageProvider` remains the only concrete provider

### 12.3 Duplicate/Unused Abstraction Surface Around Embeddings

`StorageProvider` defines embedding and derived-index methods, and `FilesystemStorageProvider` implements them under `.indexes/`, but the active embedding system in `src/lib/embeddings.ts` writes `wiki/.vectors.json` directly. This indicates architecture in transition.

### 12.4 In-Process Locks Only

`src/lib/lock.ts` explicitly serializes work only inside one process. Multi-instance production could still race on shared files.

### 12.5 Naming / Product Transition Drift

The repository, README, and YOYO docs lean toward “yopedia,” but the app metadata and some UI still say “LLM Wiki” (`src/app/layout.tsx`, `src/app/page.tsx`, CLI help). The pivot is real but incomplete.

### 12.6 Agent/Discussion/Contributor Systems Are Local and Unauthenticated

They add semantic richness, but there is no auth, identity verification, or remote collaboration model. Trust is heuristic and local-file-derived.

### 12.7 Some APIs Expose More Ambition Than Current Behavior

Examples:

- MCP `list_pages` offers sort by confidence, but confidence is not actually loaded into list entries there
- MCP `ingest_url` accepts `tags`, but observed handler does not use them

These are minor but real abstraction leaks.

### 12.8 Mixed Maturity Across “yopedia” Features

Phase-like yopedia metadata is broadly present in ingest and page rendering, but not every write path guarantees equal richness. The repo contains both mature wiki behavior and ongoing schema migration behavior.

## 13. Practical Usage Guide

### Minimal Viable Usage

1. configure one LLM provider
2. run `pnpm dev`
3. ingest one text or URL source
4. query the resulting wiki

### Operational Assumptions

- expected scale: tens to low hundreds of pages, not massive corpora
- expected operator expertise: comfortable with local dev tooling and markdown
- expected topology: single local/server instance with writable disk
- expected durability: file durability, not transactional DB guarantees
- expected cost model: LLM-backed ingest/query, optional embedding provider cost

### Canonical Workflow

Use `/ingest` with preview, approve useful material, browse `/wiki`, ask questions in `/query`, save good answers as pages, then run `/lint` and fix issues.

### Advanced Usage

- batch ingest via `/api/ingest/batch`
- filtered frontmatter queries via `/api/wiki/dataview`
- export to Obsidian via `/api/wiki/export`
- rebuild embeddings via `/settings`
- use MCP from external agents via `pnpm mcp`
- scope queries/search to `agent:<id>` after seeding agent profiles

### Extension Workflow

When extending behavior:

1. start in `src/lib`, not UI
2. route new page mutations through `writeWikiPageWithSideEffects()` or `deleteWikiPage()`
3. if prompt behavior changes, update `SCHEMA.md` alongside code
4. add/update tests in `src/lib/__tests__`

### Debugging Workflow

Useful checkpoints:

- provider/config issues: `src/lib/config.ts`, `/api/status`, `/settings`
- ingest fetch failures: `src/lib/fetch.ts`, `src/lib/url-safety.ts`
- retrieval quality: `src/lib/query-search.ts`, `src/lib/bm25.ts`, `src/lib/embeddings.ts`
- write consistency bugs: `src/lib/lifecycle.ts`, `src/lib/wiki.ts`, `src/lib/revisions.ts`, `src/lib/wiki-log.ts`
- lint weirdness: `src/lib/lint-checks.ts`, `src/lib/lint-fix.ts`

### Observability

- activity timeline: `wiki/log.md` and `/wiki/log`
- revision history: `/wiki/[slug]` + `RevisionHistory`
- raw sources: `/raw`
- contributor activity: `/wiki/contributors`
- graph view: `/wiki/graph`

There are logger calls across subsystems, but no centralized telemetry stack.

### Failure Modes

- missing provider credentials → query/ingest may error or degrade
- blocked/invalid URLs → ingest rejects early
- malformed frontmatter → page reads can fail in frontmatter-aware paths
- stale index/log state from out-of-band edits → lint detects some, not all, inconsistencies
- multi-process writes → possible race conditions not covered by lock layer

### Performance Considerations

- BM25 full-body corpus building reads every page; acceptable only at modest scale
- contributor and lint scans are corpus-wide and O(number of pages/revisions)
- vector rebuild is linear over all pages
- graph layout is client-side canvas simulation; fine for moderate graphs, not optimized for very large ones

## 14. Project Navigation Guide

### Best Reading Order

1. `README.md` — product framing and surfaces
2. `YOYO.md` — intended direction and feature phases
3. `SCHEMA.md` — runtime page conventions
4. `src/lib/wiki.ts` + `src/lib/frontmatter.ts` — page storage model
5. `src/lib/lifecycle.ts` — mutation orchestration
6. `src/lib/ingest.ts` + `src/lib/fetch.ts` — source-to-page path
7. `src/lib/query.ts` + `src/lib/query-search.ts` + `src/lib/bm25.ts` — query path
8. `src/lib/lint.ts` + `src/lib/lint-checks.ts` — maintenance path
9. `src/mcp.ts` — agent-facing transport
10. representative tests in `src/lib/__tests__`

### Highest-Value Entry Points

- `src/lib/lifecycle.ts::runPageLifecycleOp`
- `src/lib/ingest.ts::ingest`
- `src/lib/query.ts::query`
- `src/lib/query-search.ts::searchIndex`
- `src/lib/wiki.ts::listWikiPages`, `readWikiPageWithFrontmatter`, `writeWikiPage`
- `src/mcp.ts::createMcpServer`

### Where Abstractions Become Concrete

- provider selection becomes concrete in `src/lib/llm.ts::getModel`
- storage becomes concrete in `src/lib/storage/index.ts::getStorage`
- schema docs become prompt input in `src/lib/schema.ts`
- semantic wiki writes become durable side effects in `src/lib/lifecycle.ts`

### Semantic Centers

The real behavioral core is concentrated in:

- `src/lib/lifecycle.ts`
- `src/lib/ingest.ts`
- `src/lib/query.ts`
- `src/lib/query-search.ts`
- `src/lib/wiki.ts`

Most other files either expose these semantics or decorate them.

## 15. Concise Deep Technical Synthesis

This project is fundamentally a **local markdown knowledge runtime for humans and agents**, not just a demo web app. Its defining pattern is: **treat the wiki as the durable product, and treat ingest/query/lint/UI/MCP as coordinated ways of maintaining and exploiting that artifact**.

Architecturally, it is best understood as a **lifecycle-oriented, file-backed orchestration system**:

- files own state
- a shared lifecycle pipeline owns consistency
- retrieval logic turns the file corpus back into LLM context
- maintenance logic continuously audits the corpus
- transport layers (web, CLI, MCP) all sit on top of the same library core

It is distinctive because it concretizes the “LLM-maintained wiki” idea more thoroughly than a typical RAG app: pages are durable, answers can become pages, revisions and logs preserve lineage, and even agent identity is being pushed into the same wiki substrate.

The implementation appears optimized for a small team or solo operator comfortable with local files, markdown, and iterative product evolution — someone who values inspectability and extensibility more than hard multi-tenant infrastructure boundaries.
