# GitHub Repository Metrics Report

<!-- markdownlint-disable MD024 -->

Generated: 2026-05-17

## Methodology

- Live GitHub data came from repository search, release listing, and pull-request search endpoints.
- Local repository inspection came from `implementations/github_stats_local.json`, generated from the checked-out clones under `implementations/*/*`.
- Prompt-supplied metadata was used where it was the only grounded source available, especially for contributor counts, first-commit timestamps, and language percentages when GitHub language-byte endpoints throttled.
- `watchers` were not used in comparative tables because GitHub repository search returns `watchers_count` equal to stars, while the prompt snapshot appears to reflect subscriber counts.

## Data Integrity Notes

- Several local clones had inconsistent first/last commit detection relative to the prompt snapshot. For commit dates, this report prefers the prompt-provided `first_commit` and `last_commit` values; local clone commit-count metrics are still reported as local history signals.
- `yologdev/karpathy-llm-wiki` appears to have been renamed on GitHub to `yologdev/yopedia`. The report keeps the original prompt identity but uses live GitHub data from `yopedia` and calls out the rename where relevant.
- GitHub language byte counts were intermittently rate-limited. Percentages are still grounded from prompt snapshots or GitHub responses; byte counts are marked `N/A` where not reliably retrievable.

## Cross-Repository Comparative Tables

### Popularity Ranking

| Rank | Repository                                     | Stars | Forks | Open issues |
| ---- | ---------------------------------------------- | ----: | ----: | ----------: |
| 1    | Lum1104/Understand-Anything                    | 14922 |  1390 |          15 |
| 2    | rohitg00/agentmemory                           | 10989 |   926 |          98 |
| 3    | Ar9av/obsidian-wiki                            |  1312 |   151 |           8 |
| 4    | lucasastorian/llmwiki                          |   912 |   146 |           5 |
| 5    | Astro-Han/karpathy-llm-wiki                    |   845 |   114 |           2 |
| 6    | skyllwt/OmegaWiki                              |   673 |   103 |           3 |
| 7    | swarmclawai/swarmvault                         |   457 |    52 |           2 |
| 8    | nvk/llm-wiki                                   |   428 |    56 |           4 |
| 9    | NicholasSpisak/second-brain                    |   324 |    57 |           0 |
| 10   | axoviq-ai/synthadoc                            |   314 |    32 |           1 |
| 11   | ussumant/llm-wiki-compiler                     |   261 |    25 |           1 |
| 12   | Ss1024sS/LLM-wiki                              |   101 |    24 |           0 |
| 13   | MehmetGoekce/llm-wiki                          |    89 |    11 |           0 |
| 14   | yologdev/karpathy-llm-wiki -> yologdev/yopedia |    56 |     8 |           6 |
| 15   | gowtham0992/link                               |    42 |     8 |           0 |
| 16   | zhurudong/andrej-karpathy-llm-wiki             |    12 |     2 |           1 |
| 17   | jp-carrilloe/pulseOS-lite                      |    11 |     1 |           0 |
| 18   | sametbrr/llm-wiki-manager                      |     7 |     2 |           0 |

### Activity Ranking

| Rank | Repository | Last commit | Local commits 30d | Merged PRs 90d | Heuristic |
| --- | --- | --- | ---: | ---: | --- |
| 1 | rohitg00/agentmemory | 2026-05-16 | 123 | 184 | Active / rapid iteration |
| 2 | Lum1104/Understand-Anything | 2026-05-13 | 108 | 62 | Active / rapid iteration |
| 3 | axoviq-ai/synthadoc | 2026-05-15 | 47 | 80 | Active / rapid iteration |
| 4 | yologdev/yopedia | 2026-05-16 | 368 | 25 | Active / rapid iteration |
| 5 | gowtham0992/link | 2026-05-11 | 363 | 22 | Active / rapid iteration |
| 6 | Ar9av/obsidian-wiki | 2026-05-16 | 32 | 30 | Active / rapid iteration |
| 7 | skyllwt/OmegaWiki | 2026-05-12 | 32 | 29 | Active / rapid iteration |
| 8 | nvk/llm-wiki | 2026-05-14 | 79 | 20 | Active / stable maintenance |
| 9 | lucasastorian/llmwiki | 2026-05-13 | 32 | 15 | Active / stable maintenance |
| 10 | swarmclawai/swarmvault | 2026-05-11 | 33 | 0 | Active / release-driven |
| 11 | zhurudong/andrej-karpathy-llm-wiki | 2026-05-13 | 10 | 0 | Active / maintenance-only |
| 12 | jp-carrilloe/pulseOS-lite | 2026-05-07 | 24 | 0 | Active / experimental |
| 13 | Ss1024sS/LLM-wiki | 2026-04-20 | 11 | 0 | Low activity / stable maintenance |
| 14 | sametbrr/llm-wiki-manager | 2026-05-07 | 5 | 0 | Active / experimental |
| 15 | ussumant/llm-wiki-compiler | 2026-05-05 | 1 | 0 | Low activity / maintenance-only |
| 16 | MehmetGoekce/llm-wiki | 2026-04-18 | 1 | 0 | Low activity / maintenance-only |
| 17 | Astro-Han/karpathy-llm-wiki | 2026-04-13 | 0 | 0 | Low activity |
| 18 | NicholasSpisak/second-brain | 2026-04-06 | 0 | 0 | Low activity |

### Maintenance Ranking

| Rank | Repository | Signals |
| --- | --- | --- |
| 1 | rohitg00/agentmemory | 39 releases, 184 merged PRs in 90d, active issue/PR queue |
| 2 | axoviq-ai/synthadoc | 4 releases, 80 merged PRs in 90d, recent release cadence |
| 3 | Lum1104/Understand-Anything | 6 releases, 62 merged PRs in 90d, sustained popularity growth |
| 4 | Ar9av/obsidian-wiki | 2 releases, 30 merged PRs in 90d, active contributions |
| 5 | yologdev/yopedia | 25 merged PRs in 90d, strong recent commit velocity |
| 6 | nvk/llm-wiki | 41 releases, 20 merged PRs in 90d, active release train |
| 7 | skyllwt/OmegaWiki | 29 merged PRs in 90d, active maintainer loop |
| 8 | gowtham0992/link | 1 release, 22 merged PRs in 90d, single-maintainer but active |
| 9 | lucasastorian/llmwiki | 15 merged PRs in 90d, app-level maintenance ongoing |
| 10 | swarmclawai/swarmvault | 75 releases, recent release 2026-05-11, release-driven maintenance |
| 11 | Ss1024sS/LLM-wiki | 5 releases, lower recent PR activity |
| 12 | MehmetGoekce/llm-wiki | 2 releases, docs-focused maintenance |
| 13 | jp-carrilloe/pulseOS-lite | no releases yet, recent but low PR volume |
| 14 | ussumant/llm-wiki-compiler | no releases, recent but quiet |
| 15 | sametbrr/llm-wiki-manager | 2 releases on launch day, little follow-up yet |
| 16 | zhurudong/andrej-karpathy-llm-wiki | no releases, low-volume upkeep |
| 17 | Astro-Han/karpathy-llm-wiki | no releases, activity slowed after initial burst |
| 18 | NicholasSpisak/second-brain | no releases, minimal follow-up after launch |

### Onboarding Friendliness Ranking

| Rank | Repository | Score | Rationale |
| --- | --- | ---: | --- |
| 1 | rohitg00/agentmemory | 9.0 | README, product framing, releases, ecosystem docs, active packaging |
| 2 | Lum1104/Understand-Anything | 8.8 | strong README, docs, releases, broad platform support |
| 3 | axoviq-ai/synthadoc | 8.6 | README, contributing, architecture docs, tests, release notes |
| 4 | Ar9av/obsidian-wiki | 8.4 | README, setup docs, AGENTS, clear vault model |
| 5 | gowtham0992/link | 8.2 | README, docs site, tests, release/install channels |
| 6 | MehmetGoekce/llm-wiki | 8.1 | README plus FAQ and troubleshooting docs |
| 7 | yologdev/yopedia | 8.0 | strong onboarding note, clear runtime map, app surfaces documented |
| 8 | nvk/llm-wiki | 7.8 | extensive release notes and protocol docs, less concise than top tier |
| 9 | lucasastorian/llmwiki | 7.6 | app docs plus tests and containerization |
| 10 | skyllwt/OmegaWiki | 7.6 | clear README and active PR flow, fewer guided docs than top tier |
| 11 | swarmclawai/swarmvault | 7.4 | release-heavy docs and product framing, more surface area to absorb |
| 12 | jp-carrilloe/pulseOS-lite | 7.2 | onboarding doc present, still small and evolving |
| 13 | Ss1024sS/LLM-wiki | 7.0 | README and release notes are decent, less user-facing guide depth |
| 14 | Astro-Han/karpathy-llm-wiki | 6.8 | clear README but sparse operational depth |
| 15 | sametbrr/llm-wiki-manager | 6.2 | small repo with readable release notes but limited docs depth |
| 16 | ussumant/llm-wiki-compiler | 6.0 | clear concept, limited operational docs |
| 17 | zhurudong/andrej-karpathy-llm-wiki | 5.9 | minimal template-style repo, less guided onboarding |
| 18 | NicholasSpisak/second-brain | 5.6 | README present, minimal follow-up docs |

### Implementation Complexity Ranking

| Rank | Repository | Complexity |
| --- | --- | --- |
| 1 | Lum1104/Understand-Anything | Very high |
| 2 | rohitg00/agentmemory | Very high |
| 3 | axoviq-ai/synthadoc | High |
| 4 | yologdev/yopedia | High |
| 5 | lucasastorian/llmwiki | High |
| 6 | swarmclawai/swarmvault | High |
| 7 | skyllwt/OmegaWiki | Medium-high |
| 8 | nvk/llm-wiki | Medium-high |
| 9 | Ar9av/obsidian-wiki | Medium |
| 10 | jp-carrilloe/pulseOS-lite | Medium |
| 11 | gowtham0992/link | Medium |
| 12 | Ss1024sS/LLM-wiki | Medium-low |
| 13 | MehmetGoekce/llm-wiki | Medium-low |
| 14 | ussumant/llm-wiki-compiler | Medium-low |
| 15 | sametbrr/llm-wiki-manager | Low |
| 16 | Astro-Han/karpathy-llm-wiki | Low |
| 17 | NicholasSpisak/second-brain | Low |
| 18 | zhurudong/andrej-karpathy-llm-wiki | Low |

### AI-Agent Suitability Ranking

| Rank | Repository | Suitability |
| --- | --- | --- |
| 1 | Ar9av/obsidian-wiki | Very high |
| 2 | nvk/llm-wiki | Very high |
| 3 | yologdev/yopedia | High |
| 4 | Astro-Han/karpathy-llm-wiki | High |
| 5 | MehmetGoekce/llm-wiki | High |
| 6 | axoviq-ai/synthadoc | High |
| 7 | gowtham0992/link | High |
| 8 | sametbrr/llm-wiki-manager | Medium-high |
| 9 | Ss1024sS/LLM-wiki | Medium-high |
| 10 | NicholasSpisak/second-brain | Medium-high |
| 11 | zhurudong/andrej-karpathy-llm-wiki | Medium-high |
| 12 | skyllwt/OmegaWiki | Medium |
| 13 | ussumant/llm-wiki-compiler | Medium |
| 14 | jp-carrilloe/pulseOS-lite | Medium |
| 15 | swarmclawai/swarmvault | Medium |
| 16 | lucasastorian/llmwiki | Medium |
| 17 | rohitg00/agentmemory | Medium |
| 18 | Lum1104/Understand-Anything | Medium |

## Repository Analyses

## Ar9av/obsidian-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 1312 |
| Forks | 151 |
| Open Issues | 8 |
| Repo Age | 41d |
| Last Commit | 2026-05-16 |
| Contributors | 10 |
| Primary Languages | Python 57.0%, HTML 33.1%, Shell 9.9% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 57.0% | 89650 |
| HTML | 33.1% | 52056 |
| Shell | 9.9% | 15500 |

### Activity

- Created 2026-04-06; first commit 2026-04-06; last commit 2026-05-16.
- Local git counts: 103 total, 32 in 30d, 103 in 90d, 103 in 12m.
- Open PRs: 2. Merged PRs in last 90d: 30.
- Releases: 2. Latest release: 2026-05-06.
- Heuristics: active; rapid iteration.

### Stack Detection

- Python and shell-heavy agent-skill pack for Obsidian wiki maintenance.
- Strong agent bootstrap surface: `AGENTS.md`, setup scripts, mirrored skill directories.
- Local inspection did not confirm CI or automated tests.

### Documentation

- README, setup docs, AGENTS guidance, and workspace onboarding notes make the vault model clear.
- Onboarding friendliness: 8.4/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low.
- Agent automation friendliness: high.
- Context compression suitability: high.
- Satellite-module feasibility: high.

## Astro-Han/karpathy-llm-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 845 |
| Forks | 114 |
| Open Issues | 2 |
| Repo Age | 42d |
| Last Commit | 2026-04-13 |
| Contributors | 1 |
| Primary Languages | None reported by GitHub languages API |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| N/A | N/A | N/A |

### Activity

- Created 2026-04-05; first commit 2026-04-05; last commit 2026-04-13.
- Local git counts: 14 total, 0 in 30d, 14 in 90d, 14 in 12m.
- Open PRs: 1. Merged PRs in last 90d: 0.
- Releases: 0. Latest release: N/A.
- Heuristics: low activity; maintenance-only.

### Stack Detection

- Primarily a markdown/spec skill pack with minimal executable surface.
- No tests, CI, or containerization were confirmed locally.

### Documentation

- README is clear and topic-rich, but operational depth is lighter than the more mature competitors.
- Onboarding friendliness: 6.8/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low.
- Agent automation friendliness: high.
- Context compression suitability: very high.
- Satellite-module feasibility: high.

## axoviq-ai/synthadoc

### Summary

| Metric | Value |
| --- | --- |
| Stars | 314 |
| Forks | 32 |
| Open Issues | 1 |
| Repo Age | 36d |
| Last Commit | 2026-05-15 |
| Contributors | 4 |
| Primary Languages | Python 82.7%, TypeScript 17.3% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 82.7% | 958395 |
| TypeScript | 17.3% | 200131 |
| JavaScript | <0.1% | 372 |

### Activity

- Created 2026-04-11; first commit 2026-04-10; last commit 2026-05-15.
- Local git counts: 249 total, 47 in 30d, 249 in 90d, 249 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 80.
- Releases: 4. Latest release: 2026-05-11.
- Heuristics: active; rapid iteration.

### Stack Detection

- Python backend plus TypeScript frontend/plugin surface.
- Manifests indicate `pyproject.toml`, `package.json`, `tsconfig.json`, and Vitest.
- Local inspection confirmed tests, contributing guide, and architecture documentation.

### Documentation

- Strong README and design materials; release notes are detailed and operationally useful.
- Onboarding friendliness: 8.6/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium.
- Agent automation friendliness: high.
- Context compression suitability: medium-high.
- Satellite-module feasibility: medium-high.

## gowtham0992/link

### Summary

| Metric | Value |
| --- | --- |
| Stars | 42 |
| Forks | 8 |
| Open Issues | 0 |
| Repo Age | 37d |
| Last Commit | 2026-05-11 |
| Contributors | 1 |
| Primary Languages | Python 97.4%, Shell 2.5%, Ruby 0.1% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 97.4% | 1148473 |
| Shell | 2.5% | 29733 |
| Ruby | 0.1% | 1485 |

### Activity

- Created 2026-04-10; first commit 2026-04-09; last commit 2026-05-11.
- Local git counts: 393 total, 363 in 30d, 393 in 90d, 393 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 22.
- Releases: 1. Latest release: 2026-05-16.
- Heuristics: active; rapid iteration.

### Stack Detection

- Python-first local memory/wiki system with docs site and package publication path.
- Local inspection found `pyproject.toml`, tests, and contributing guidance.

### Documentation

- README, GitHub Pages site, and release notes cover install and usage well.
- Onboarding friendliness: 8.2/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low-medium.
- Agent automation friendliness: high.
- Context compression suitability: high.
- Satellite-module feasibility: medium-high.

## jp-carrilloe/pulseOS-lite

### Summary

| Metric | Value |
| --- | --- |
| Stars | 11 |
| Forks | 1 |
| Open Issues | 0 |
| Repo Age | 26d |
| Last Commit | 2026-05-07 |
| Contributors | 1 |
| Primary Languages | TypeScript 90.4%, CSS 6.7%, Shell 1.5% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| TypeScript | 90.4% | N/A |
| CSS | 6.7% | N/A |
| Shell | 1.5% | N/A |

### Activity

- Created 2026-04-21; first commit 2026-04-21; last commit 2026-05-07.
- Local git counts: 24 total, 24 in 30d, 24 in 90d, 24 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 0. Latest release: N/A.
- Heuristics: active; experimental.

### Stack Detection

- TypeScript/Vite application with company-memory framing.
- Manifests indicate `package.json`, `vite.config`, and `tsconfig.json`.
- Local onboarding and architecture docs exist; tests were not confirmed.

### Documentation

- Small but readable docs footprint, helped by explicit onboarding notes.
- Onboarding friendliness: 7.2/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium.
- Agent automation friendliness: medium.
- Context compression suitability: medium.
- Satellite-module feasibility: medium.

## lucasastorian/llmwiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 912 |
| Forks | 146 |
| Open Issues | 5 |
| Repo Age | 42d |
| Last Commit | 2026-05-13 |
| Contributors | 3 |
| Primary Languages | Python 52.0%, TypeScript 44.9%, PLpgSQL 1.7% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 52.0% | N/A |
| TypeScript | 44.9% | N/A |
| PLpgSQL | 1.7% | N/A |
| CSS | 1.2% | N/A |
| Dockerfile | 0.2% | N/A |
| HTML | 0.0% | N/A |

### Activity

- Created 2026-04-04; first commit 2026-04-04; last commit 2026-05-13.
- Local git counts: 91 total, 32 in 30d, 91 in 90d, 91 in 12m.
- Open PRs: 3. Merged PRs in last 90d: 15.
- Releases: 0. Latest release: N/A.
- Heuristics: active; stable maintenance.

### Stack Detection

- Python plus Next.js/TypeScript app with Docker and pytest presence.
- Topics and onboarding note point to MCP integration and hosted app workflow.

### Documentation

- Good product README and test/container hints, but less opinionated onboarding than top-tier repos.
- Onboarding friendliness: 7.6/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium-high.
- Agent automation friendliness: medium.
- Context compression suitability: medium.
- Satellite-module feasibility: medium.

## Lum1104/Understand-Anything

### Summary

| Metric | Value |
| --- | --- |
| Stars | 14922 |
| Forks | 1390 |
| Open Issues | 15 |
| Repo Age | 63d |
| Last Commit | 2026-05-13 |
| Contributors | 30 |
| Primary Languages | TypeScript 82.2%, Python 10.3%, Astro 2.9% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| TypeScript | 82.2% | N/A |
| Python | 10.3% | N/A |
| Astro | 2.9% | N/A |
| JavaScript | 2.8% | N/A |
| CSS | 0.6% | N/A |
| PowerShell | 0.6% | N/A |

### Activity

- Created 2026-03-15; first commit 2026-03-14; last commit 2026-05-13.
- Local git counts: 480 total, 108 in 30d, 480 in 90d, 480 in 12m.
- Open PRs: 1. Merged PRs in last 90d: 62.
- Releases: 6. Latest release: 2026-05-04.
- Heuristics: active; rapid iteration.

### Stack Detection

- TypeScript-heavy web app with Astro surface, Python analysis tooling, Docker, and package publishing.
- Local inspection found architecture docs, API docs, tests, containerization, and release discipline.

### Documentation

- Strong documentation and release notes, though the implementation surface is broad.
- Onboarding friendliness: 8.8/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium-high.
- Agent automation friendliness: medium.
- Context compression suitability: medium.
- Satellite-module feasibility: medium.

## MehmetGoekce/llm-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 89 |
| Forks | 11 |
| Open Issues | 0 |
| Repo Age | 39d |
| Last Commit | 2026-04-18 |
| Contributors | 2 |
| Primary Languages | Shell 89.5%, Mermaid 10.5% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Shell | 89.5% | N/A |
| Mermaid | 10.5% | N/A |

### Activity

- Created 2026-04-08; first commit 2026-04-08; last commit 2026-04-18.
- Local git counts: 14 total, 1 in 30d, 14 in 90d, 14 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 2. Latest release: 2026-04-18.
- Heuristics: low activity; maintenance-only.

### Stack Detection

- Shell-and-docs-centric skill/spec repo with Logseq and Obsidian framing.
- Architecture docs and AGENTS presence were confirmed; tests/CI were not.

### Documentation

- FAQ and troubleshooting docs materially improve onboarding versus its small code surface.
- Onboarding friendliness: 8.1/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low.
- Agent automation friendliness: high.
- Context compression suitability: very high.
- Satellite-module feasibility: high.

## NicholasSpisak/second-brain

### Summary

| Metric | Value |
| --- | --- |
| Stars | 324 |
| Forks | 57 |
| Open Issues | 0 |
| Repo Age | 40d |
| Last Commit | 2026-04-06 |
| Contributors | 1 |
| Primary Languages | Shell 100.0% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Shell | 100.0% | N/A |

### Activity

- Created 2026-04-06; first commit 2026-04-06; last commit 2026-04-06.
- Local git counts: 7 total, 0 in 30d, 7 in 90d, 7 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 0. Latest release: N/A.
- Heuristics: low activity.

### Stack Detection

- Minimal shell-based skill pack for Obsidian second-brain maintenance.
- Tests were detected locally, but broader operational tooling appears light.

### Documentation

- README is present, but the repo has relatively little guided follow-up documentation.
- Onboarding friendliness: 5.6/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low.
- Agent automation friendliness: medium-high.
- Context compression suitability: high.
- Satellite-module feasibility: high.

## nvk/llm-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 428 |
| Forks | 56 |
| Open Issues | 4 |
| Repo Age | 42d |
| Last Commit | 2026-05-14 |
| Contributors | 4 |
| Primary Languages | Shell 51.7%, Python 45.7%, JavaScript 2.6% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Shell | 51.7% | N/A |
| Python | 45.7% | N/A |
| JavaScript | 2.6% | N/A |

### Activity

- Created 2026-04-04; first commit 2026-04-04; last commit 2026-05-14.
- Local git counts: 180 total, 79 in 30d, 180 in 90d, 180 in 12m.
- Open PRs: 4. Merged PRs in last 90d: 20.
- Releases: 41. Latest release: 2026-05-14.
- Heuristics: active; stable maintenance with aggressive release cadence.

### Stack Detection

- Shell/Python local CLI and protocol-driven wiki system with plugin/distribution surfaces.
- Release notes reference test suites and sync scripts, even though local file heuristics did not positively identify a standard test directory.

### Documentation

- Strong protocol and release-note trail; onboarding is good once you accept the repo's conventions.
- Onboarding friendliness: 7.8/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low-medium.
- Agent automation friendliness: very high.
- Context compression suitability: high.
- Satellite-module feasibility: high.

## rohitg00/agentmemory

### Summary

| Metric | Value |
| --- | --- |
| Stars | 10989 |
| Forks | 926 |
| Open Issues | 98 |
| Repo Age | 81d |
| Last Commit | 2026-05-16 |
| Contributors | 24 |
| Primary Languages | TypeScript 81.1%, HTML 8.1%, JavaScript 8.0% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| TypeScript | 81.1% | N/A |
| HTML | 8.1% | N/A |
| JavaScript | 8.0% | N/A |
| CSS | 1.5% | N/A |
| Python | 0.6% | N/A |
| Shell | 0.5% | N/A |
| Dockerfile | 0.2% | N/A |

### Activity

- Created 2026-02-25; first commit 2026-02-27; last commit 2026-05-16.
- Local git counts: 278 total, 123 in 30d, 278 in 90d, 278 in 12m.
- Open PRs: 54. Merged PRs in last 90d: 184.
- Releases: 39. Latest release: 2026-05-17.
- Heuristics: active; rapid iteration.

### Stack Detection

- Large TypeScript product with Next.js-style web surface, memory engine, docker-compose, and package publishing.
- Architecture docs, contributing guide, benchmarks, and packaging signals are all present.

### Documentation

- Broad and polished docs surface; complexity is the main onboarding challenge, not missing docs.
- Onboarding friendliness: 9.0/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium-high.
- Agent automation friendliness: medium.
- Context compression suitability: medium.
- Satellite-module feasibility: medium.

## sametbrr/llm-wiki-manager

### Summary

| Metric | Value |
| --- | --- |
| Stars | 7 |
| Forks | 2 |
| Open Issues | 0 |
| Repo Age | 10d |
| Last Commit | 2026-05-07 |
| Contributors | 1 |
| Primary Languages | Python 74.5%, Go Template 25.5% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 74.5% | N/A |
| Go Template | 25.5% | N/A |

### Activity

- Created 2026-05-07; first commit 2026-05-07; last commit 2026-05-07.
- Local git counts: 5 total, 5 in 30d, 5 in 90d, 5 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 2. Latest release: 2026-05-07.
- Heuristics: active; experimental.

### Stack Detection

- Small Python/template skill pack with multi-wiki routing safeguards.
- Architecture doc exists; broader test and CI surface was not confirmed.

### Documentation

- Release notes do a fair amount of explanatory work for a very small codebase.
- Onboarding friendliness: 6.2/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low-medium.
- Agent automation friendliness: medium-high.
- Context compression suitability: high.
- Satellite-module feasibility: high.

## skyllwt/OmegaWiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 673 |
| Forks | 103 |
| Open Issues | 3 |
| Repo Age | 38d |
| Last Commit | 2026-05-12 |
| Contributors | 4 |
| Primary Languages | Python 79.5%, JavaScript 13.6%, CSS 3.6% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 79.5% | N/A |
| JavaScript | 13.6% | N/A |
| CSS | 3.6% | N/A |
| PowerShell | 1.5% | N/A |
| Shell | 1.4% | N/A |
| Go Template | 0.2% | N/A |
| HTML | 0.2% | N/A |

### Activity

- Created 2026-04-09; first commit 2026-04-09; last commit 2026-05-12.
- Local git counts: 67 total, 32 in 30d, 67 in 90d, 67 in 12m.
- Open PRs: 1. Merged PRs in last 90d: 29.
- Releases: 0. Latest release: N/A.
- Heuristics: active; rapid iteration.

### Stack Detection

- Python/JS research platform with active prompt-driven skill work and README-heavy documentation.
- Architecture docs are present; CI/tests were not confirmed by local heuristic scan.

### Documentation

- Good README and active PR trail, but less mature packaged onboarding than the strongest repos.
- Onboarding friendliness: 7.6/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium.
- Agent automation friendliness: medium.
- Context compression suitability: medium-high.
- Satellite-module feasibility: medium-high.

## Ss1024sS/LLM-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 101 |
| Forks | 24 |
| Open Issues | 0 |
| Repo Age | 41d |
| Last Commit | 2026-04-20 |
| Contributors | 2 |
| Primary Languages | Python 98.7%, Shell 1.3% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Python | 98.7% | N/A |
| Shell | 1.3% | N/A |

### Activity

- Created 2026-04-06; first commit 2026-04-06; last commit 2026-04-20.
- Local git counts: 40 total, 11 in 30d, 40 in 90d, 40 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 5. Latest release: 2026-04-18.
- Heuristics: low activity; stable maintenance.

### Stack Detection

- Python bootstrap/validation workflow with release-oriented docs and cursor rules.
- Local inspection confirmed tests and `AGENTS`/`CLAUDE`-style agent surfaces.

### Documentation

- Release notes are strong; general onboarding is decent but more maintainer-centric.
- Onboarding friendliness: 7.0/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low-medium.
- Agent automation friendliness: medium-high.
- Context compression suitability: high.
- Satellite-module feasibility: high.

## swarmclawai/swarmvault

### Summary

| Metric | Value |
| --- | --- |
| Stars | 457 |
| Forks | 52 |
| Open Issues | 2 |
| Repo Age | 40d |
| Last Commit | 2026-05-11 |
| Contributors | 2 |
| Primary Languages | TypeScript 86.0%, JavaScript 12.5%, CSS 1.4% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| TypeScript | 86.0% | N/A |
| JavaScript | 12.5% | N/A |
| CSS | 1.4% | N/A |
| Shell | 0.1% | N/A |
| HTML | 0.0% | N/A |
| Dart | 0.0% | N/A |

### Activity

- Created 2026-04-06; first commit 2026-04-06; last commit 2026-05-11.
- Local git counts: 181 total, 33 in 30d, 181 in 90d, 181 in 12m.
- Open PRs: 2. Merged PRs in last 90d: 0.
- Releases: 75. Latest release: 2026-05-11.
- Heuristics: active; release-driven stable maintenance.

### Stack Detection

- TypeScript app plus Go module/tooling, Vite, pnpm, Vitest, and Biome.
- Package publishing and aggressive release cadence are both clear.

### Documentation

- Strong product framing and release notes, but the breadth of the surface increases onboarding load.
- Onboarding friendliness: 7.4/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium.
- Agent automation friendliness: medium.
- Context compression suitability: medium.
- Satellite-module feasibility: medium.

## ussumant/llm-wiki-compiler

### Summary

| Metric | Value |
| --- | --- |
| Stars | 261 |
| Forks | 25 |
| Open Issues | 1 |
| Repo Age | 43d |
| Last Commit | 2026-05-05 |
| Contributors | 2 |
| Primary Languages | HTML 58.1%, JavaScript 26.1%, Shell 15.8% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| HTML | 58.1% | N/A |
| JavaScript | 26.1% | N/A |
| Shell | 15.8% | N/A |

### Activity

- Created 2026-04-04; first commit 2026-04-04; last commit 2026-05-05.
- Local git counts: 30 total, 1 in 30d, 30 in 90d, 30 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 0. Latest release: N/A.
- Heuristics: low activity; maintenance-only.

### Stack Detection

- HTML/JS/Shell workflow around Claude/Codex knowledge compilation.
- Local scan found a light-weight surface with modest operational tooling.

### Documentation

- Concept is readable, but the repo has less onboarding structure than the stronger peers.
- Onboarding friendliness: 6.0/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low-medium.
- Agent automation friendliness: medium.
- Context compression suitability: medium-high.
- Satellite-module feasibility: high.

## yologdev/karpathy-llm-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 56 |
| Forks | 8 |
| Open Issues | 6 |
| Repo Age | 41d |
| Last Commit | 2026-05-16 |
| Contributors | 3 |
| Primary Languages | TypeScript 97.1%, JavaScript 2.2% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| TypeScript | 97.1% | N/A |
| JavaScript | 2.2% | N/A |

### Activity

- Prompt identity is `yologdev/karpathy-llm-wiki`, but live GitHub search now resolves to `yologdev/yopedia`.
- Created 2026-04-06; first commit 2026-04-06; last commit 2026-05-16.
- Local git counts: 747 total, 368 in 30d, 747 in 90d, 747 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 25.
- Releases: 0. Latest release: N/A.
- Heuristics: active; rapid iteration.

### Stack Detection

- Next.js-style TypeScript app backed by filesystem wiki lifecycle, BM25, embeddings, CLI, and MCP.
- Onboarding note identifies `src/lib/lifecycle.ts` and `src/lib/query*.ts` as semantic centers.

### Documentation

- Strong onboarding note and clear storage/runtime model, especially for a repo this young.
- Onboarding friendliness: 8.0/10.

### AI/Agent Assessment

- LLM onboarding difficulty: medium.
- Agent automation friendliness: high.
- Context compression suitability: medium-high.
- Satellite-module feasibility: medium-high.

## zhurudong/andrej-karpathy-llm-wiki

### Summary

| Metric | Value |
| --- | --- |
| Stars | 12 |
| Forks | 2 |
| Open Issues | 1 |
| Repo Age | 23d |
| Last Commit | 2026-05-13 |
| Contributors | 2 |
| Primary Languages | Shell 100.0% |

### Languages

| Language | Fraction | Bytes |
| --- | --- | ---: |
| Shell | 100.0% | N/A |

### Activity

- Created 2026-04-24; first commit 2026-04-24; last commit 2026-05-13.
- Local git counts: 10 total, 10 in 30d, 10 in 90d, 10 in 12m.
- Open PRs: 0. Merged PRs in last 90d: 0.
- Releases: 0. Latest release: N/A.
- Heuristics: active; maintenance-only.

### Stack Detection

- Minimal shell/template repo oriented around a CLAUDE.md-based knowledge-base pattern.
- Architecture doc exists; broader automation surface remains intentionally small.

### Documentation

- Concise and understandable, but still a lightweight template-level repo.
- Onboarding friendliness: 5.9/10.

### AI/Agent Assessment

- LLM onboarding difficulty: low.
- Agent automation friendliness: medium-high.
- Context compression suitability: very high.
- Satellite-module feasibility: high.

## Final Conclusions

- The repo set splits into two broad families: markdown/spec-first skill packs (`Ar9av`, `Astro-Han`, `MehmetGoekce`, `NicholasSpisak`, `zhurudong`, `sametbrr`, `Ss1024sS`) and product-style applications (`Lum1104`, `rohitg00`, `axoviq-ai`, `lucasastorian`, `swarmclawai`, `yologdev`). The first family is easier for agents to absorb; the second provides richer end-user surfaces but substantially higher implementation complexity.
- `rohitg00/agentmemory`, `Lum1104/Understand-Anything`, `axoviq-ai/synthadoc`, `Ar9av/obsidian-wiki`, `nvk/llm-wiki`, and `yologdev/yopedia` currently show the strongest maintenance signals.
- `Ar9av/obsidian-wiki` and `nvk/llm-wiki` remain the cleanest agent-oriented reference implementations when optimizing for repo clarity and prompt-surface leverage rather than feature breadth.
- `yologdev/karpathy-llm-wiki` is the main identity conflict in the dataset: the prompt snapshot uses the original repo name while live GitHub data now points to `yologdev/yopedia`.
- Language-byte completeness is partial due GitHub throttling. The percentage breakdowns remain grounded; byte counts are intentionally marked `N/A` where not reliably retrievable.
