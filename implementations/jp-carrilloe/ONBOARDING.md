# ONBOARDING

## What this repo actually is

PulseOS-Lite is a **Markdown-first company-memory runtime**. The real product is `cli/`, not the top-level docs alone:

- canonical knowledge lives in `000_Company_Memory`
- raw intake for bootstrap lives in `001_Data_Souces`
- `cli/` builds a workspace-local SQLite index over `000_Company_Memory`
- the daemon serves retrieval-backed chat, the graph/editor UI, and MCP tools

The repo’s “agent” language is mostly a **document-governance and prompting model**. The active runtime is a local daemon plus indexer, not a distributed agent system.

## Semantic centers

### `cli\retrieval.ts`

Primary behavioral core. Owns:

- SQLite schema (`documents`, `knowledge_vectors`, `document_references`, `document_chunks`, `index_runs`, `rebuild_change_log`, `crm_*`)
- Markdown scanning under `000_Company_Memory` only
- metadata extraction (`title`, `status`, `owner_agent`, `ontology_domain`)
- summary embeddings (OpenAI if available, heuristic otherwise)
- graph snapshot generation
- rebuild drift detection and advisory
- retrieval prompt-context assembly

Important invariant: **Markdown is source of truth; SQLite is a derived cache**.

### `cli\daemon.ts`

Owns runtime control:

- localhost daemon lifecycle
- chat `/command` surface
- UI endpoints
- file read/write API restricted to `000_Company_Memory`
- graph-session token/cookie handshake
- docked terminal session management

### `cli\bootstrap.ts` + `cli\bootstrap-intake.ts`

Own bootstrap semantics:

- find unfilled numbered template docs
- gather intake from active/legacy intake folders + external references + existing curated memory
- fill docs in dependency order
- prefer curated company-memory evidence over raw intake when conflicting
- refresh index immediately after bootstrap

## Runtime model

### Chat

`npm run chat` -> ensure workspace state -> ensure daemon -> daemon ensures index is current -> daemon retrieves docs and calls selected provider.

Retrieval model is **summary-vector based**, not chunk-vector based:

- one vector per document summary
- chunks are stored only so full document bodies can be inserted into prompts

### UI

`npm run ui` builds the React bundle and uses the daemon as backend.

The UI is a **visualizer/editor over the indexed company memory**, not the source of truth itself. Saving a doc writes the file and then immediately runs a full reindex.

### Index rebuilds

Out-of-band Markdown edits require rebuild:

- `cd cli && npm run index`
- `/reload` in chat
- UI `Rebuild index` / `Rebuild graph/index`

The graph is backed by the SQLite snapshot, not live filesystem parsing on page refresh.

## State ownership

### In repo

- `000_Company_Memory`: canonical curated docs
- `001_Data_Souces`: raw bootstrap intake

### Outside repo

Workspace state defaults to `~\.pulseos\workspaces\<workspace-id>\...`:

- `knowledge-base.sqlite`
- `daemon-state.json`
- `bootstrap-state.json`
- `snapshots\`, `logs\`, `cache\`

Read `cli\workspace-storage.ts` and `cli\shared.ts` before changing storage behavior.

## Key operational assumptions

- local developer-machine workflow, not a multi-user deployed service
- strong reliance on filesystem + localhost daemon
- directory taxonomy under `000_Company_Memory` is meaningful ontology
- rebuild discipline is required after file-level KB changes
- bootstrap should **not** run until real source material exists in `001_Data_Souces`

## Auth / provider behavior

Implemented auth paths in `cli\auth.ts`:

- OpenAI: `OPENAI_API_KEY` or `codex login`
- Claude: `ANTHROPIC_API_KEY` or `claude auth login`
- Gemini: API key only

Important distinction:

- chat/bootstrap can run via local CLI sessions
- embeddings still need `OPENAI_API_KEY` for provider-backed vectors
- without that key, retrieval falls back to heuristic embeddings

## Important commands

From `cli/`:

- `npm run chat`
- `npm run ui`
- `npm run index`
- `npm run status`
- `npm run bootstrap`
- `npm run mcp`
- `npm test`

## Sharp edges / gaps

1. **UI terminal is Unix-centric.** `cli\daemon.ts` launches `python3` and defaults to `/bin/zsh`; `cli\terminal_bridge.py` depends on `pty`, `fcntl`, and `termios`. Treat Windows support for the docked terminal as suspect.
2. **`502_Execution_Engine\ark-engine` is mostly scaffold.** The active runtime does not depend on it.
3. **Full reindex on save/reload.** There is no selective incremental update path.
4. **Chat sessions are in-memory only.** Daemon restart loses conversation history.

## Where to start reading

1. `README.md`
2. `01_RUNME.md`
3. `cli\package.json`
4. `cli\index.ts`
5. `cli\daemon.ts`
6. `cli\retrieval.ts`
7. `cli\bootstrap.ts`
8. `cli\bootstrap-intake.ts`
9. `cli\shared.ts`
10. `cli\workspace-storage.ts`

## Safe modification guidance

- If changing what gets indexed, start in `cli\retrieval.ts`.
- If changing commands, daemon routes, or UI backend behavior, start in `cli\index.ts` + `cli\daemon.ts`.
- If changing bootstrap semantics, inspect both `cli\bootstrap.ts` and `cli\bootstrap-intake.ts`.
- If editing `000_Company_Memory`, preserve numbered domain structure and metadata conventions unless intentionally migrating them.
- Treat AGENTS/CLAUDE guidance as repo operating conventions even when runtime code does not enforce them directly.
