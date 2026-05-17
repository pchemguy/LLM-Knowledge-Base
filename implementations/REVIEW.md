# LLM Wiki Implementation Comparative Review

Primary evidence for this review is the moved onboarding artifacts under `implementations/*/{OnboardingReport.md,ONBOARDING.md}`. The conceptual baseline is Karpathy's three-layer raw/wiki/schema pattern in `docs/karpathy/llm-wiki.md`, with Rohit Ghumare's extensions in `docs/rohitg00/llm-wiki-v2.md` adding memory lifecycle, typed graph structure, hybrid search, automation, and collaboration expectations.

## 1. Executive Comparative Synopsis

The implementation landscape splits into four clear families:

1. **Full local/wiki runtimes** that actually ingest sources, compile persistent artifacts, and expose CLI/API/MCP/UI surfaces. The strongest examples are **SwarmVault**, **Link**, **Synthadoc**, **yopedia**, **OmegaWiki**, **llmwiki (lucasastorian)**, and **PulseOS-Lite**.
2. **Memory-runtime reinterpretations** that pursue the same compounding-knowledge goal but replace the wiki artifact with structured service state. **agentmemory** is the clearest case; **Understand Anything** is adjacent, emphasizing graph artifacts over wiki pages.
3. **Prompt/spec operating systems** where the host agent is the runtime and the repository mainly defines workflows, schemas, and conventions. **nvk/llm-wiki** is the most complete version of this family; **sametbrr**, **NicholasSpisak**, **Ar9av**, **Astro-Han**, **zhurudong**, and **MehmetGoekce** sit on the lighter end.
4. **Bootstrap/scaffolding compilers** that generate a repo-local knowledge system with deterministic maintenance scripts instead of shipping a long-lived runtime. **Ss1024sS** is the clearest example; **ussumant** is close, but oriented more around a compile protocol plus viewer.

The main architectural divergence is **where intelligence lives**:

- **engine-centric** repos put it in code (`SwarmVault`, `Link`, `Synthadoc`, `agentmemory`, `yopedia`, `lucasastorian`, `PulseOS-Lite`);
- **schema-plus-script** repos split it between data contracts and helper tools (`OmegaWiki`, `Ss1024sS`);
- **prompt-centric** repos put it in `SKILL.md`, `CLAUDE.md`, `wiki.md`, or similar instruction files (`nvk`, `sametbrr`, `Ar9av`, `NicholasSpisak`, `Astro-Han`, `MehmetGoekce`, `zhurudong`, `ussumant`).

Operationally, the spectrum runs from **real local products** to **portable operating manuals**:

- **Most operationally serious:** `implementations/SwarmClawAI`, `implementations/gowtham0992`, `implementations/axoviq-ai`, `implementations/yologdev`, `implementations/lucasastorian`, `implementations/rohitg00`
- **Operational but domain-specialized or workflow-heavy:** `implementations/skyllwt`, `implementations/jp-carrilloe`
- **Best as prompt/spec references or bootstrap kits:** `implementations/nvk`, `implementations/sametbrr`, `implementations/NicholasSpisak`, `implementations/Ar9av`, `implementations/Astro-Han`, `implementations/zhurudong`, `implementations/ussumant`, `implementations/Ss1024sS`, `implementations/MehmetGoekce`

For follow-up study:

- **Best holistic reference architecture:** **SwarmVault**
- **Best explicit memory-lifecycle implementation:** **agentmemory** and **Link**
- **Best typed schema + local research graph design:** **OmegaWiki**
- **Best straightforward ingest-time wiki compiler:** **Synthadoc**
- **Best app-shaped wiki product:** **yopedia** and **llmwiki (lucasastorian)**, with the latter also showing hosted/service evolution
- **Best prompt-system reference:** **nvk/llm-wiki**

No single implementation fully realizes Rohit's whole v2 stack. The pattern is decomposed across the ecosystem:

- **memory lifecycle / consolidation:** `agentmemory`, `Link`
- **typed graph:** `OmegaWiki`, `SwarmVault`, `Understand Anything`
- **hybrid search:** `SwarmVault`, `yopedia`, `agentmemory`, `Synthadoc` optional, `Link` more modestly
- **automation / recurring workflows:** `SwarmVault`, `OmegaWiki`, `agentmemory`
- **portable prompt protocol:** `nvk`, `sametbrr`, `Ar9av`, `NicholasSpisak`

## 2. Comparative Matrix

### 2.1 High-level comparison

| Implementation                       | Architectural identity                                 | Primary durable state                                                  | Retrieval / graph model                                     | Operational model                             | Apparent maturity         | Best role                                                       |
| ------------------------------------ | ------------------------------------------------------ | ---------------------------------------------------------------------- | ----------------------------------------------------------- | --------------------------------------------- | ------------------------- | --------------------------------------------------------------- |
| `gowtham0992/link`                   | Markdown memory runtime with CLI/HTTP/MCP              | `raw/`, `wiki/`, `wiki/memories/`, JSON caches                         | wiki search + memory recall + backlinks                     | local Python runtime                          | High in core semantics    | direct adoption for explicit-memory wiki workflows              |
| `SwarmClawAI/SwarmVault`             | Orchestration-centric local knowledge compiler         | `raw/`, `wiki/`, `state/*`                                             | SQLite FTS, typed graph, optional embeddings, context packs | rich local CLI/viewer/MCP/watch runtime       | High                      | reference architecture / direct trials / subsystem mining       |
| `axoviq-ai/Synthadoc`                | Queue-driven ingest-time wiki compiler                 | Markdown wiki + SQLite job/audit/cache DBs                             | BM25, optional vectors; no deep graph center                | localhost server + CLI + plugin               | Medium-high               | direct local adoption when simplicity matters                   |
| `skyllwt/OmegaWiki`                  | Schema-governed research wiki runtime                  | `wiki/*.md`, `wiki/graph/*.jsonl`, checkpoints                         | typed entities/edges/xrefs; index-driven query              | local scripts + Claude skills + local SPA     | Medium                    | research-specific adaptation / graph-schema study               |
| `nvk/llm-wiki`                       | Multi-runtime prompt package                           | filesystem wiki roots/hubs                                             | index-first, no true search backend                         | host-agent execution + deterministic lint CLI | Medium-high as protocol   | prompt/spec reference architecture                              |
| `yologdev/yopedia`                   | Filesystem wiki engine wrapped in Next.js app          | `raw/`, `wiki/`, revisions, vectors, query history                     | BM25 + optional embeddings + RRF + backlinks                | local web app + CLI + MCP                     | Medium-high               | app-shaped local wiki product / UI reference                    |
| `Lum1104/Understand-Anything`        | Knowledge-graph artifact pipeline                      | `.understand-anything/*.json` in analyzed project                      | validated graph artifacts, fuzzy/structural search          | plugin/skills + dashboard                     | Medium                    | graph/dashboard subsystem mining, not direct wiki adoption      |
| `rohitg00/agentmemory`               | iii-engine memory worker                               | iii-backed KV scopes, persisted indexes                                | BM25 + optional vector + optional graph hybrid              | service + REST + MCP + viewer                 | High in core memory paths | memory-lifecycle reference / shared memory service              |
| `zhurudong/andrej-karpathy-llm-wiki` | Template/starter kit                                   | generated `raw/` + `wiki/`                                             | `_index.md` / `_log.md`, no engine                          | external agent follows template               | Low-medium                | minimal Karpathy-style prompt starter                           |
| `sametbrr/llm-wiki-manager`          | Skill package with deterministic wiki scripts          | target repo `raw/` + `wiki/`                                           | index/log + mechanical linter                               | Claude skill + helper scripts                 | Medium                    | prompt-first repo with better bookkeeping than pure prompt kits |
| `jp-carrilloe/PulseOS-Lite`          | Markdown-first daemon-backed company memory            | `000_Company_Memory` + workspace SQLite cache                          | summary-vector retrieval + graph snapshot                   | local daemon/chat/UI/MCP                      | Medium                    | company-memory adaptation / daemon-backed markdown runtime      |
| `NicholasSpisak/second-brain`        | Skill-driven Obsidian operating model                  | generated vault files                                                  | index-first, optional `qmd`                                 | external agent + bash scaffold                | Low-medium                | lightweight prompt workflow reference                           |
| `Ar9av/obsidian-wiki`                | Skill pack + schema contract for Obsidian vaults       | vault files + `.manifest.json` + `hot.md`                              | retrieval primitives, manifest delta model                  | external agent + setup scripts                | Low-medium                | Obsidian skill-system reference                                 |
| `ussumant/llm-wiki-compiler`         | Plugin/spec bundle with compile workflow               | compiled wiki markdown + `.wiki-compiler.json` + `.compile-state.json` | topic/concept graph from markdown conventions               | host agent + session-start hooks + viewer     | Medium                    | compile-protocol reference / visualizer idea source             |
| `lucasastorian/llmwiki`              | Dual-mode wiki service (local + hosted)                | local fs + SQLite, or Postgres + S3                                    | FTS/chunks/references graph; MCP-first authoring            | API + web + local/hosted MCP                  | Medium-high               | product-style evaluation / hosted evolution study               |
| `Astro-Han/karpathy-llm-wiki`        | Pure skill/spec bundle                                 | target project `raw/` + `wiki/`                                        | index/log driven                                            | host agent only                               | Low                       | minimal skill reference                                         |
| `Ss1024sS/LLM-wiki`                  | Bootstrap compiler for generated repo knowledge system | generated `docs/wiki`, manifests, scripts                              | manifest/freshness/provenance checks                        | bootstrap once, then generated scripts        | Medium                    | scaffold + provenance/freshness script mining                   |
| `MehmetGoekce/llm-wiki`              | Prompt/template package with L1/L2 split               | external wiki + config + Claude memory                                 | prompt-driven, no engine                                    | Claude workflow kit                           | Low-medium                | concept framing and L1/L2 layering ideas                        |

### 2.2 Adaptation and conceptual alignment

| Implementation | Karpathy core alignment | Rohit v2 alignment | Adaptation friendliness | Main coupling hotspot | Recommended disposition |
| --- | --- | --- | --- | --- | --- |
| Link | High | High on lifecycle, medium on automation/graph | Medium-high | `link_core` shared semantics across CLI/UI/MCP | adapt directly if explicit memory matters |
| SwarmVault | Very high | High across search/automation/graph, medium on forgetting | Medium | `packages/engine/src/vault.ts` centrality | study deeply; adopt selectively or directly |
| Synthadoc | Very high | Medium; weak on graph/lifecycle depth | High | single `Orchestrator` + server-required CLI model | direct adoption / simplify-and-adapt |
| OmegaWiki | High | High on graph/schema, medium on lifecycle | Medium | schema + Python + skills must stay aligned | adapt for research-focused systems |
| nvk | High | Medium conceptually, low enforceability | High | prompt-source vs generated mirrors | reference architecture for prompt bundles |
| yopedia | High | Medium-high via hybrid retrieval and lifecycle orchestration | Medium-high | `src/lib/lifecycle.ts` side-effect hub | adapt for app-centric local wiki |
| Understand Anything | Medium-low | Medium on graph/search ideas | Medium | artifact schema + dashboard coupling | mine graph/UI ideas only |
| agentmemory | Medium as wiki, very high as v2 memory engine | Very high on lifecycle/consolidation/hybrid search | Medium | iii-engine dependency and shared KV schema | study for memory kernel, not direct wiki |
| zhurudong | High minimal core | Low | High | prompt/template drift | starter reference only |
| sametbrr | High | Low-medium | Medium-high | behavior split across prose and scripts | adapt if you want deterministic helpers without full engine |
| PulseOS-Lite | Medium-high | Medium on retrieval/runtime, low on lifecycle sophistication | Medium | daemon/index rebuild model | mine daemon/index ideas; adapt if company-memory niche fits |
| NicholasSpisak | High core | Low | High | external-agent dependence | starter prompt kit |
| Ar9av | Medium-high | Low-medium | Medium | skill contracts share conventions but no code reuse | Obsidian skill reference |
| ussumant | High compile-first | Medium on compile/session-start ideas | Medium | prompt contract plus visualizer assumptions | mine compile workflow and viewer |
| lucasastorian | High | Medium | Medium | duplicated local/hosted behavior | product-style reuse or hosted study |
| Astro-Han | High minimal core | Low | High | prompt precision | minimal reference only |
| Ss1024sS | High compile-first | Medium on freshness/provenance | Medium-high | scaffold template consistency | mine generated scripts and CI-safe checks |
| MehmetGoekce | Medium-high | Low-medium via L1/L2 split | High | prompt-only semantics | concept/reference source, not runtime base |

## 3. Architectural Taxonomy

### 3.1 Engine-centric local wiki runtimes

**Members:** `gowtham0992`, `SwarmClawAI`, `axoviq-ai`, `yologdev`, `jp-carrilloe`, `lucasastorian`

These repos implement the Karpathy idea as a **real software system** rather than a behavioral spec. Common traits:

- persistent local artifacts are first-class;
- deterministic code owns indexing, query assembly, or lifecycle side effects;
- LLMs are used for synthesis, not for every structural responsibility;
- MCP is usually treated as a primary surface, not a bolt-on.

What distinguishes them is **how much runtime they build around the wiki**:

- `Link` emphasizes explicit memory lifecycle inside markdown state.
- `SwarmVault` turns the wiki into a broad local operating environment with graph, review, watch, task, and context-pack layers.
- `Synthadoc` is the cleanest ingest-time compiler with a centralized orchestrator and queue.
- `yopedia` is an app-shaped implementation with one strong lifecycle module mediating writes.
- `PulseOS-Lite` specializes toward company memory and a daemon-backed chat/editor.
- `lucasastorian` is the only implementation that clearly bifurcates into local and hosted product modes.

Tradeoff: highest practical utility, but also the most coupling and maintenance overhead.

### 3.2 Schema-plus-script research/compile systems

**Members:** `skyllwt`, `Ss1024sS`

These repos do not rely purely on prompt discipline, but neither do they become broad services. They treat the wiki as a **typed file database** and use deterministic scripts to preserve structure, freshness, provenance, or graph consistency.

- `OmegaWiki` is the strongest typed-schema design: YAML contracts for entities, edges, and reverse-link invariants, with `research_wiki.py` as the mutation engine.
- `Ss1024sS` is less interactive and more bootstrap-oriented: generate a project-local wiki system and maintain it through scripts like `ingest_raw.py`, `stale_report.py`, and `wiki_check.py`.

Tradeoff: more enforcement than prompt-only kits, less operational heft than app/service runtimes.

### 3.3 Memory-runtime reinterpretations

**Members:** `rohitg00`, `Lum1104`

These repos shift away from "persistent wiki pages as the source of truth" while still pursuing compounding knowledge.

- `agentmemory` is a **service-backed memory kernel**: observations, summaries, semantic/procedural memories, and graph scopes are the real artifacts; Obsidian export is secondary.
- `Understand Anything` centers on **graph artifacts and dashboard exploration** rather than a wiki authoring loop.

Tradeoff: architecturally innovative and closer to Rohit's lifecycle/consolidation vision, but less directly adoptable as an "LLM wiki" in Karpathy's sense.

### 3.4 Prompt/spec operating systems

**Members:** `nvk`, `sametbrr`, `NicholasSpisak`, `Ar9av`, `Astro-Han`, `zhurudong`, `MehmetGoekce`, `ussumant`

These repos treat the **host agent as the runtime** and primarily ship:

- a schema/instruction layer,
- setup/bootstrap scripts,
- optional deterministic helpers,
- sometimes packaging for multiple runtimes.

There is a further split inside this family:

1. **stronger operational protocol packages**: `nvk`, `sametbrr`, `ussumant`
2. **lighter starter kits / skill bundles**: `NicholasSpisak`, `Ar9av`, `Astro-Han`, `zhurudong`, `MehmetGoekce`

Tradeoff: lowest implementation burden and highest portability, but behavior quality depends on prompt fidelity, host-agent quality, and operator discipline.

## 4. Per-Implementation Comparative Profiles

### 4.1 `gowtham0992/link`

**Evidence:** `implementations/gowtham0992/ONBOARDING.md`

Link is one of the clearest attempts to fuse Karpathy's markdown wiki with Rohit's memory-lifecycle concerns. Its distinctive contribution is **explicit durable memory as a first-class sublayer** (`wiki/memories/`) with remember/review/update/archive/forget flows, while keeping raw/wiki/index/log as markdown files. It is strongest when you want **bounded query packets plus explicit memory governance**, not a broad ingest automation engine. The main caveat is that ingest is more of a **status/guidance workflow** than a fully internal raw-to-wiki authoring pipeline.

**Best use:** direct local adoption for a disciplined personal/project wiki where explicit memory decisions matter more than autonomous ingestion breadth.

### 4.2 `SwarmClawAI/SwarmVault`

**Evidence:** `implementations/SwarmClawAI/ONBOARDING.md`, `implementations/SwarmClawAI/OnboardingReport.md`

SwarmVault is the most complete **local operating system for knowledge compilation** in the set. It covers source normalization, compile-time analysis, generated wiki pages, typed graph state, SQLite retrieval, viewer, MCP, watch loops, recurring sources, context packs, persisted chat, task ledgers, and review workflows. It is the closest thing here to a **reference implementation of a production-grade local LLM Wiki platform**.

Its weakness is also its strength: a large, centralized engine. `packages/engine/src/vault.ts` is the semantic sink where many decisions converge.

**Best use:** first repo to study if you want an end-to-end architecture; strong candidate for direct trials if you can accept breadth and complexity.

### 4.3 `axoviq-ai/Synthadoc`

**Evidence:** `implementations/axoviq-ai/ONBOARDING.md`, `implementations/axoviq-ai/OnboardingReport.md`

Synthadoc is the cleanest **ingest-time wiki compiler** in the set. Its architecture is easy to reason about: one orchestrator, one SQLite-backed job queue, specialized agents, markdown wiki output. It operationalizes Karpathy directly and avoids the sprawling surface area of SwarmVault. The tradeoff is a shallower graph/lifecycle story and some implementation gaps around MCP, cost enforcement, and nominal parallelism.

**Best use:** adopt or adapt when you want a straightforward local compiler with a persistent queue and clean operational model.

### 4.4 `skyllwt/OmegaWiki`

**Evidence:** `implementations/skyllwt/ONBOARDING.md`, `implementations/skyllwt/OnboardingReport.md`

OmegaWiki is the strongest **typed research-wiki** design. The important idea is the split across **schema YAML**, **deterministic mutation tools**, and **skill-level orchestration**. It goes further than most wiki repos in formalizing entity types, edge types, reverse-link invariants, citations, checkpoints, and derived context briefs. It is less general-purpose than SwarmVault or Synthadoc and more workflow-heavy, but it is one of the best sources for **typed graph + linter + skill contract** composition.

**Best use:** adapt for literature/research systems or mine for schema-governed graph ideas.

### 4.5 `nvk/llm-wiki`

**Evidence:** `implementations/nvk/ONBOARDING.md`, `implementations/nvk/OnboardingReport.md`

This is the strongest **prompt/spec bundle** in the collection. Unlike lighter kits, it has a serious filesystem model (`raw/`, `wiki/`, `inventory/`, `datasets/`, `output/`), multi-runtime packaging, and a deterministic lint CLI. It demonstrates how to turn a prompt-defined wiki into a **portable operational protocol** across Claude, Codex, OpenCode/Pi, and `AGENTS.md`.

Its main limitation is that orchestration remains host-agent-driven; the strongest enforcement is structural lint, not execution control.

**Best use:** prompt architecture reference; especially good if you want portability across agent ecosystems.

### 4.6 `yologdev/yopedia`

**Evidence:** `implementations/yologdev/ONBOARDING.md`

yopedia is a strong **app-first local wiki engine**. The core idea is not the Next.js shell but the lifecycle module that guarantees page-write side effects: update page, embeddings, index, backlinks, log, revisions, and discussions together. It has one of the clearest write contracts in the set and a practical hybrid retrieval story. It looks like one of the better choices if you want a **single-machine wiki product with a browser UI** instead of a prompt kit.

**Best use:** local app reference; especially valuable for write-lifecycle orchestration and web/MCP reuse over shared domain functions.

### 4.7 `Lum1104/Understand-Anything`

**Evidence:** `implementations/Lum1104/ONBOARDING.md`

Understand Anything is only partially an LLM Wiki implementation. It is better read as a **knowledge-graph generation and exploration system** for understanding code/projects. Its persistent artifacts are graph JSON files, and the dashboard consumes them after skill-driven analysis. That makes it weaker as a direct wiki adoption candidate, but valuable as a source of **graph schema, persistence, validation, and dashboard ideas**.

**Best use:** mine graph artifact and visualization patterns; lower priority for direct wiki adoption.

### 4.8 `rohitg00/agentmemory`

**Evidence:** `implementations/rohitg00/ONBOARDING.md`, `implementations/rohitg00/OnboardingReport.md`

agentmemory is the best implementation of the **Rohit v2 direction** in spirit, but it is not a markdown wiki runtime. It realizes confidence/consolidation/hybrid retrieval/graph-ready memory as structured service state inside iii-engine. Its strengths are capture pipelines, memory evolution, hybrid recall, and multi-surface exposure. Its weakness for this review's purpose is that the wiki layer is derivative, not canonical.

**Best use:** study for memory kernels, consolidation tiers, hybrid search, and multi-client memory services; not as the direct base if you need editable markdown as source of truth.

### 4.9 `zhurudong/andrej-karpathy-llm-wiki`

**Evidence:** `implementations/zhurudong/ONBOARDING.md`

This is a **minimal Karpathy template kit**. The whole system is effectively a starter prompt plus example output. It does a good job preserving the raw/wiki/index/log core, but almost all guarantees are conventional. There is little executable infrastructure beyond installation/bootstrap.

**Best use:** minimal conceptual starting point or lightweight instructional reference.

### 4.10 `sametbrr/llm-wiki-manager`

**Evidence:** `implementations/sametbrr/ONBOARDING.md`

sametbrr sits between prompt kits and full runtimes. It keeps semantic work in `SKILL.md` and workflow docs, but adds deterministic scripts for scaffold, index updates, log appends, and lint reporting. That makes it a better example than pure prompt kits when you want **LLM-owned semantics with script-owned bookkeeping**.

**Best use:** adapt when you want a moderate middle ground: still portable, but less dependent on the model remembering every structural side effect.

### 4.11 `jp-carrilloe/PulseOS-Lite`

**Evidence:** `implementations/jp-carrilloe/ONBOARDING.md`

PulseOS-Lite is a **company-memory specialization** of the pattern. Markdown remains canonical, but a local daemon, SQLite cache, graph snapshot, and chat/UI surfaces sit on top. It is less general than SwarmVault or yopedia and more opinionated about corporate-memory taxonomy and bootstrap templates. The retrieval model is distinctive: **summary-vector-based**, not chunk-vector-based.

**Best use:** mine daemon-backed markdown retrieval and company-memory workflow ideas; adapt directly only if the domain fit is strong.

### 4.12 `NicholasSpisak/second-brain`

**Evidence:** `implementations/NicholasSpisak/ONBOARDING.md`

Second Brain is a **prompt-governed Obsidian workflow** with a tested scaffold script but no real ingest/query/lint engine. It is useful as an operational spec for a vault-centric workflow and for its shared schema discipline, but most semantics remain host-agent behavior.

**Best use:** prompt workflow reference for Obsidian-based personal knowledge bases.

### 4.13 `Ar9av/obsidian-wiki`

**Evidence:** `implementations/Ar9av/ONBOARDING.md`

Ar9av's repo is another Obsidian skill pack, but more operationally elaborate than many prompt kits: manifest tracking, `hot.md`, project/global scoping, retrieval primitives, skill distribution artifacts, and reminder automation. It still depends entirely on the external agent as executor, yet it has a more explicit operational model than the lightest kits.

**Best use:** reference for skill-pack structure and vault metadata conventions.

### 4.14 `ussumant/llm-wiki-compiler`

**Evidence:** `implementations/ussumant/ONBOARDING.md`

This repo is a **compile-protocol bundle** rather than a runtime. Its distinctive idea is to frame knowledge compilation as `wiki-init` + `wiki-compile`, maintain a `.compile-state.json`, and use hooks to push agents toward the compiled wiki first. The built-in visualizer gives it more concrete runtime than most prompt kits. It is a good example of **wiki compilation as a codebase-oriented compile pipeline**.

**Best use:** mine compile-state, session-start context, and visualization ideas.

### 4.15 `lucasastorian/llmwiki`

**Evidence:** `implementations/lucasastorian/ONBOARDING.md`, `implementations/lucasastorian/OnboardingReport.md`

lucasastorian's project is the most clearly **productized app/service** in the set. The local mode stays close to Karpathy's pattern; the hosted mode pushes toward a multi-tenant SaaS with Postgres, S3, auth, resumable uploads, and hosted MCP. It is strong for studying how an LLM wiki becomes an actual service product. The cost is duplicated local/hosted semantics and some drift in the local wrapper.

**Best use:** evaluate when you care about hosted evolution, service boundaries, and MCP-first authoring over a document corpus.

### 4.16 `Astro-Han/karpathy-llm-wiki`

**Evidence:** `implementations/Astro-Han/ONBOARDING.md`

Astro-Han is a **pure skill/spec bundle** with very little executable support. Its value is conceptual clarity around ingest/query/lint/archive flows and one-level topic directories, not runtime sophistication.

**Best use:** minimal prompt reference, especially for strict topic/article conventions.

### 4.17 `Ss1024sS/LLM-wiki`

**Evidence:** `implementations/Ss1024sS/ONBOARDING.md`

Ss1024sS is best understood as a **generated knowledge-system bootstrapper**. The generated repo gets raw manifests, provenance checks, freshness reports, wiki validation, and AI protocol files. Compared with prompt-only kits, it has much better deterministic support for stale/provenance management. Compared with full runtimes, it lacks a long-lived orchestration loop.

**Best use:** mine raw-manifest, provenance, and freshness tooling for repo-local knowledge systems.

### 4.18 `MehmetGoekce/llm-wiki`

**Evidence:** `implementations/MehmetGoekce/ONBOARDING.md`

MehmetGoekce's repo is a **Claude workflow kit** with an L1/L2 split: always-loaded Claude memory vs on-demand markdown wiki. That conceptual split is its strongest distinctive idea. Beyond setup and templates, most behavior is prompt-defined and not code-enforced.

**Best use:** study for layered memory framing, not for runtime mechanics.

## 5. Cross-Implementation Design Patterns

### 5.1 The wiki-as-compiled-artifact pattern is dominant

Most implementations accept Karpathy's core inversion: **compile knowledge at ingest/update time instead of re-synthesizing from raw sources on every query**. This is explicit in `Synthadoc`, `SwarmVault`, `yopedia`, `Link`, `lucasastorian`, `OmegaWiki`, and even in prompt kits like `nvk`, `sametbrr`, and `zhurudong`.

### 5.2 `index.md` / `log.md` remain the ecosystem's universal control files

Nearly every markdown-first implementation treats some variant of:

- `index.md` or `_index.md` as routing/catalog state
- `log.md` or `_log.md` as continuity/audit state

This is the most stable cross-implementation invariant, even when everything else changes.

### 5.3 The "schema is the real product" theme recurs everywhere

Karpathy hints at this; Rohit states it directly. The ecosystem agrees:

- `SCHEMA.md`, `CLAUDE.md`, `SKILL.md`, `wiki.md`, YAML schema files, or config manifests usually matter more than the UI.
- Even engine-heavy repos rely on explicit contracts: `OmegaWiki` YAML schema, `SwarmVault` schema file, `yopedia` `SCHEMA.md`, `Link` `LINK.md`, `agentmemory` `AGENTS.md`.

### 5.4 Deterministic helpers usually own bookkeeping, not semantics

A recurring split:

- LLM: decide what to create/update/synthesize
- script/engine: update index, log, backlinks, caches, validation artifacts

This split is implemented most cleanly in `yopedia`, `sametbrr`, `Link`, `OmegaWiki`, and `Ss1024sS`.

### 5.5 Graph ambition is common; graph reality is uneven

There are three graph levels in the ecosystem:

1. **backlink/index graph**: `Link`, `yopedia`, many prompt kits
2. **explicit typed graph state**: `OmegaWiki`, `SwarmVault`, `agentmemory`, `Understand Anything`
3. **query-time graph traversal as first-class semantics**: only partially realized; strongest signals are in `OmegaWiki`, `SwarmVault`, and `agentmemory`

Most repos still treat graph as **derived navigation help**, not as the primary query planner Rohit's v2 calls for.

### 5.6 Hybrid search is concentrated in a few serious runtimes

Real BM25+vector or multi-signal retrieval appears mainly in:

- `SwarmVault`
- `yopedia`
- `agentmemory`
- `Synthadoc` optional vector mode
- `PulseOS-Lite` summary-vector variant

Many prompt kits still rely on index-first browsing plus host-agent file search.

### 5.7 Memory lifecycle is the least implemented Rohit theme

Confidence, supersession, forgetting, and tiered consolidation are rare as explicit runtime concepts.

- **Strongest explicit lifecycle work:** `agentmemory`, `Link`
- **Partial adjacent work:** `SwarmVault` review/consolidation, `OmegaWiki` lifecycle transitions, `yopedia` revisions/discussions
- **Mostly absent:** the prompt-kit family

## 6. Major Tradeoffs and Divergences

### 6.1 Engine-centric vs prompt-centric

**Engine-centric** repos provide stronger guarantees, better observability, and less dependence on model obedience, but they accumulate coupling and operational surface area.  
**Prompt-centric** repos are portable and easy to adapt conceptually, but correctness drifts unless the host agent behaves well.

This is the ecosystem's primary fault line.

### 6.2 Markdown-first vs service-state-first

`Link`, `SwarmVault`, `Synthadoc`, `yopedia`, `OmegaWiki`, `PulseOS-Lite`, and `lucasastorian` keep markdown or file artifacts near the center. `agentmemory` explicitly does not. The tradeoff is:

- markdown-first => inspectable, git-friendly, portable
- service-state-first => better lifecycle machinery, coordination, and structured retrieval

No implementation cleanly gets both at full strength.

### 6.3 Compile-first simplicity vs workflow breadth

`Synthadoc` shows the benefits of a tight ingest/query/lint loop.  
`SwarmVault` shows what happens when the wiki becomes a broader workbench with tasks, watch loops, chat, context packs, recurring sources, and review queues.

The broader the runtime, the more it shifts from "wiki maintainer" to "knowledge operating system."

### 6.4 Local-first practicality vs hosted/service ambition

Most repos are local-first. `lucasastorian` is the clearest hosted evolution path; `agentmemory` is service-first but not wiki-first. Hosted paths add auth, tenancy, resumable uploads, and more robust storage, but increase drift risk because local and hosted semantics diverge.

### 6.5 Typed schema rigor vs loose page conventions

`OmegaWiki` and `Ss1024sS` take schema/provenance/freshness much more seriously than lighter prompt kits.  
Many other repos operate with useful conventions but relatively weak runtime enforcement.

This matters for long-lived corpora: without deterministic schema checking, wiki quality degrades into "whatever the model happened to write."

## 7. Operational and Practical Assessment

### 7.1 Setup complexity

**Lowest friction:** prompt/spec kits (`zhurudong`, `Astro-Han`, `NicholasSpisak`, `MehmetGoekce`)  
**Moderate and realistic local setup:** `Link`, `Synthadoc`, `yopedia`, `PulseOS-Lite`, `OmegaWiki`  
**Heavier but richer:** `SwarmVault`, `agentmemory`, `lucasastorian`

The easiest repos to "start" are often the ones with the weakest enforcement because the runtime already exists outside the repo.

### 7.2 Operational fragility

Most fragile patterns:

- host-agent-dependent prompt kits with little deterministic checking
- multi-surface systems with duplicated behavior (`lucasastorian` local/hosted)
- engine-first systems with one oversized semantic center (`SwarmVault`, `Link`, `Synthadoc` to a lesser extent)

Most stable behavior typically comes from:

- explicit validators (`OmegaWiki`, `Ss1024sS`, `nvk`, `Link`)
- centralized write orchestration (`yopedia`, `Synthadoc`)

### 7.3 Observability and debugging

Best debugging surfaces:

- `SwarmVault`: session artifacts, doctor commands, viewer, approvals, retrieval state
- `agentmemory`: viewer, health endpoints, structured logs, doctor/status, index persistence
- `Link`: status/doctor/benchmark/memory-audit flows
- `Synthadoc`: jobs, audit DB, traces, job queue
- `OmegaWiki`: graph files, checkpoints, linter, stats/maturity

Weakest observability is in the prompt-kit family, where debugging usually means diffing generated markdown against instructions.

### 7.4 Local-development friendliness

Best local-first ergonomics: `Synthadoc`, `Link`, `yopedia`, `SwarmVault`  
Reasonable but specialized: `PulseOS-Lite`, `OmegaWiki`  
More burdened by external runtime assumptions: `agentmemory` (iii-engine), `lucasastorian` hosted path, prompt kits that depend on Claude/Codex skill/plugin behavior

## 8. Adaptation and Reuse Potential

### 8.1 Best candidates for direct adaptation

1. **SwarmVault** if you want the broadest platform and can tolerate complexity.
2. **Synthadoc** if you want a clean ingest-time compiler with lower operational burden.
3. **Link** if explicit memory governance is central.
4. **yopedia** if you want a web-app shell over a coherent local wiki engine.
5. **OmegaWiki** if the problem is research/literature-centric and typed graph semantics matter.

### 8.2 Best reference architectures, even if not adopted whole

1. **SwarmVault** for end-to-end local knowledge runtime design.
2. **agentmemory** for lifecycle, consolidation, and hybrid-memory architecture.
3. **OmegaWiki** for typed wiki schema, linter, and skill/tool separation.
4. **nvk** for multi-runtime prompt packaging and portable protocol design.
5. **lucasastorian** for local-to-hosted product evolution.

### 8.3 Strongest subsystem ideas to mine

| Subsystem / idea | Best sources |
| --- | --- |
| explicit memory lifecycle in markdown wiki | `gowtham0992/link` |
| holistic local knowledge compiler | `SwarmClawAI/SwarmVault` |
| queue-backed ingest orchestration | `axoviq-ai/Synthadoc` |
| typed entity/edge/xref schema | `skyllwt/OmegaWiki` |
| lifecycle-safe page writes | `yologdev/yopedia` |
| memory consolidation + hybrid recall | `rohitg00/agentmemory` |
| dual local/hosted service split | `lucasastorian/llmwiki` |
| summary-vector daemon over markdown corpus | `jp-carrilloe/PulseOS-Lite` |
| prompt-system portability across agent runtimes | `nvk/llm-wiki` |
| provenance/freshness scripts for generated wiki repos | `Ss1024sS/LLM-wiki` |

### 8.4 Typical modification pressure points

- **central orchestrators or lifecycle hubs**: `SwarmVault` `vault.ts`, `Link` `link_core`, `Synthadoc` `Orchestrator`, `yopedia` `lifecycle.ts`
- **schema/runtime dual definitions**: `OmegaWiki`, `Understand Anything`, prompt kits with template + docs + scripts
- **multi-surface duplication**: `lucasastorian`, `agentmemory`, `nvk` generated mirrors
- **prompt/documentation drift**: almost every prompt-centric implementation

## 9. Prioritized Recommendations

### 9.1 Highest-priority deeper study

1. **SwarmVault** — best overall understanding of what a serious local LLM Wiki platform can become.
2. **agentmemory** — best source for Rohit-style lifecycle, consolidation, and memory-service thinking.
3. **OmegaWiki** — best typed graph/schema approach in a markdown-first research system.
4. **yopedia** — best compact app-shaped implementation with a strong write-lifecycle contract.
5. **Link** — best markdown-first memory governance layer.

### 9.2 Best candidates for short operational trials

1. **Synthadoc** — lowest-friction serious compiler.
2. **Link** — practical if memory capture/review matters.
3. **yopedia** — practical if browser UX and MCP matter.
4. **SwarmVault** — trial-worthy if you want breadth and don't mind a larger surface.

### 9.3 Best candidates for production evaluation

1. **SwarmVault** — broadest operational maturity.
2. **agentmemory** — strongest service-grade memory kernel, if markdown-first storage is optional.
3. **lucasastorian/llmwiki** — clearest hosted/product path.
4. **Link** and **Synthadoc** — smaller, more focused local products.

### 9.4 Best repos to study for prompt/spec design

1. **nvk/llm-wiki** — strongest portable prompt architecture.
2. **sametbrr/llm-wiki-manager** — good middle ground between prompts and deterministic helpers.
3. **Ar9av/obsidian-wiki** — good skill-pack operational conventions.
4. **Astro-Han** and **zhurudong** — minimal skill/template examples.

### 9.5 Best repos for isolated subsystem reuse

1. **agentmemory** for memory tiers, hybrid search, session capture.
2. **OmegaWiki** for typed graph schema and xref linting.
3. **yopedia** for side-effect-safe page lifecycle orchestration.
4. **Ss1024sS** for provenance, freshness, and generated-script maintenance.
5. **PulseOS-Lite** for daemon-backed markdown indexing and graph/editor coupling.

## 10. Concise Technical Synthesis

This ecosystem is not converging on one "LLM Wiki" architecture. It is converging on a **design space** with three strong truths:

1. **Persistent artifacts beat per-query rediscovery.**
2. **The schema/instruction layer is usually the real product.**
3. **Operational bookkeeping must be automated or the wiki decays.**

From there, implementations diverge on what the persistent artifact should be:

- editable markdown wiki,
- typed graph plus markdown,
- service-owned memory state,
- or a generated repo-local knowledge system.

The strongest overall direction appears to be a **hybrid architecture**:

- markdown or markdown-like artifacts remain human-readable source-of-truth outputs,
- deterministic code owns lifecycle side effects, validation, and retrieval indexes,
- a typed graph exists as a first-class derived structure,
- memory lifecycle and consolidation are explicit,
- MCP/CLI/UI all reuse one semantic core.

No single repository completes that synthesis cleanly. The nearest composite picture is:

- **SwarmVault** for holistic local runtime,
- **agentmemory** for lifecycle and memory evolution,
- **OmegaWiki** for typed schema/graph discipline,
- **yopedia** for page lifecycle orchestration,
- **nvk** for portable prompt packaging.

That composite is more instructive than any single repo. The most promising implementation direction is therefore **not picking one winner**, but combining:

- Karpathy's markdown-first inspectability,
- Rohit's lifecycle/graph/search/automation additions,
- SwarmVault-style operational breadth,
- OmegaWiki-style schema rigor,
- and Link/agentmemory-style explicit memory governance.
