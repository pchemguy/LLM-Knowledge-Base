# Understand Anything — Onboarding Notes

## What this repo is

- A pnpm monorepo for the `Understand Anything` skill/plugin system plus its dashboard and homepage.
- The real product is the knowledge-graph pipeline: generate graph artifacts, then explore them in a UI or through skill prompts.

## Where the behavior lives

- `understand-anything-plugin/packages/core/src/*` — graph schema, validation, persistence, search, language/framework detection, Tree-sitter integration, staleness/fingerprints.
- `understand-anything-plugin/src/*` — chat/diff/explain/onboard prompt builders.
- `understand-anything-plugin/skills/*` — actual operational instructions for `/understand`, `/understand-domain`, `/understand-knowledge`, `/understand-dashboard`, etc.
- `understand-anything-plugin/packages/dashboard/src/*` — UI state, graph views, layout, filters, token gate.

## Runtime model

- Everything revolves around `.understand-anything/*.json` artifacts in the analyzed project.
- The dashboard loads those files, validates them, and switches between structural/domain/knowledge views.
- Skills orchestrate analysis and artifact generation; the dashboard only consumes artifacts.

## Important invariants

- Graphs are validated before use.
- Absolute file paths are sanitized before persistence.
- Tree-sitter init must happen before structural analysis.
- Worktree installs redirect output to the main repo root unless disabled.
- `searchMode: semantic` is currently not a real embedding-based mode; it still uses fuzzy search.

## High-signal entry points

- `packages/core/src/index.ts`
- `packages/core/src/types.ts`
- `packages/core/src/schema.ts`
- `packages/core/src/persistence/index.ts`
- `packages/dashboard/src/App.tsx`
- `packages/dashboard/src/store.ts`
- `src/context-builder.ts`
- `src/diff-analyzer.ts`
- `src/explain-builder.ts`
- `src/onboard-builder.ts`

## Operational workflow

1. Install the plugin/skills (`install.sh` or `install.ps1`).
2. Run `/understand` on a project.
3. Inspect `knowledge-graph.json` in the dashboard.
4. Use `/understand-diff`, `/understand-explain`, `/understand-onboard`, `/understand-domain`, `/understand-knowledge` as needed.

## Debugging tips

- If the dashboard complains, check `WarningBanner` for validation/layout issues.
- If analysis looks stale, inspect `fingerprints.json` and `meta.json`.
- If a file is missing from the graph, check `ignore-filter.ts` and `.understandignore`.
- If graph rendering feels wrong, check `packages/dashboard/src/utils/elk-layout.ts` and `layout.ts`.

## Sharp edges

- Semantic search is still aspirational.
- Layout code is mid-migration from dagre to ELK.
- Dashboard CI coverage is lighter than core/skill coverage.
- Some graph metadata is intentionally left blank at build time and filled later by higher-level analysis.

## Fast local commands

- `pnpm install`
- `pnpm --filter @understand-anything/core build`
- `pnpm --filter @understand-anything/skill build`
- `pnpm --filter @understand-anything/dashboard dev`

