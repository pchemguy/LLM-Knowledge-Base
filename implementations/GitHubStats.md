# GitHub Repository Metrics Report

## Methodology

- **Live GitHub data used:** repository identity, descriptions, topics, stars, forks, open issues, creation timestamps, root-level repository contents, release lists, and pull request counts.
- **Git history analysis used:** total commit counts and commit frequencies over the last 30/90/365 days, derived from live commit listings.
- **Prompt-supplied metadata used as supplementary context:** contributor totals, language percentage breakdowns, and first/last commit cross-checks.
- **Unavailable or not reliably retrievable from the accessible toolset:** GitHub language byte counts, direct contributor-list verification, and a dedicated languages API endpoint. These are explicitly marked where needed.
- **Reference time:** 2026-05-17 20:41 UTC.

### Heuristic definitions

- **Activity heuristic**
  - **Active:** last commit within 14 days and meaningful recent commit volume.
  - **Low activity:** last commit within 30 days, but low recent commit volume.
  - **Dormant:** no commits in the last 30 days or last commit older than 30 days.
  - **Abandoned:** no commits in the last 90 days. None of these repositories met that threshold.
- **Development velocity heuristic**
  - **Rapid iteration:** very high recent commit volume and/or high merged PR throughput.
  - **Stable maintenance:** steady updates with releases, docs, fixes, or moderate PR throughput.
  - **Maintenance-only:** low change volume, mostly polishing/docs/fixes.
  - **Experimental:** young repository with low contributor diversity and limited release/process maturity.
- **Onboarding friendliness score (1-10):** heuristic based on README quality, install instructions, quick start, examples, docs, CI/tests, and contributor guidance.
- **Implementation complexity / AI suitability rankings:** heuristic rankings grounded in visible repository structure, stack breadth, tooling, monorepo surface area, explicit agent docs, setup reproducibility, and testing signals.

## Notes

- **Contributor counts** come from the prompt-supplied metadata because a direct contributor-count endpoint was not available in the accessible toolset.
- **Language fractions** come from the prompt-supplied metadata. The live repository inspection cross-checked primary language and stack shape, but **language byte counts were not reliably retrievable**.
- For all repositories in this set, **commits in the last 90 days**, **commits in the last 12 months**, and **commits in the last year** equal total commit count because every repository was created within the last 12 months.
- Some PR-search operations hit short-lived GitHub search rate limits late in collection. The report preserves the successfully retrieved counts and marks anything uncertain as unavailable rather than guessing.

## Cross-Repository Comparative Tables

### Compact comparison table

| Repo | Stars | Forks | Contributors | Last Commit Age | 30d Commits | Open PRs | Merged PRs (90d) | Releases |
| --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: |
| Lum1104/Understand-Anything | 14941 | 1392 | 30 | ~5d | 129 | 2 | 62 | 6 |
| rohitg00/agentmemory | 11159 | 939 | 24 | ~1d | 191 | 55 | 184 | 40 |
| Ar9av/obsidian-wiki | 1314 | 151 | 10 | ~1d | 42 | 2 | 30 | 2 |
| lucasastorian/llmwiki | 913 | 147 | 3 | ~4d | 50 | 3 | 15 | 0 |
| Astro-Han/karpathy-llm-wiki | 845 | 114 | 1 | ~35d | 0 | 1 | 0 | 0 |
| skyllwt/OmegaWiki | 673 | 103 | 4 | <1d | 35 | 2 | 29 | 0 |
| swarmclawai/swarmvault | 457 | 52 | 2 | ~6d | 46 | 1 | 0 | 75 |
| nvk/llm-wiki | 428 | 57 | 4 | ~3d | 93 | 4 | 20 | 41 |
| NicholasSpisak/second-brain | 325 | 57 | 1 | ~41d | 0 | 0 | 0 | 0 |
| axoviq-ai/synthadoc | 314 | 32 | 4 | ~1d | 60 | 0 | 81 | 4 |
| ussumant/llm-wiki-compiler | 261 | 25 | 2 | ~12d | 1 | 0 | 0 | 0 |
| Ss1024sS/LLM-wiki | 101 | 24 | 2 | ~28d | 10 | 0 | 0 | 5 |
| MehmetGoekce/llm-wiki | 89 | 11 | 2 | ~30d | 1 | 0 | 0 | 2 |
| yologdev/yopedia | 56 | 8 | 3 | ~0d | 428 | 0 | 27 | 0 |
| gowtham0992/link | 42 | 8 | 1 | ~6d | 374 | 0 | 22 | 1 |
| zhurudong/andrej-karpathy-llm-wiki | 12 | 2 | 2 | ~5d | 11 | 0 | 0 | 0 |
| jp-carrilloe/pulseOS-lite | 11 | 1 | 1 | ~10d | 23 | 0 | 0 | 0 |
| sametbrr/llm-wiki-manager | 7 | 2 | 1 | ~10d | 5 | 0 | 0 | 2 |

### Popularity ranking

| Rank | Repo | Stars | Forks | Open Issues |
| --- | --- | ---: | ---: | ---: |
| 1 | Lum1104/Understand-Anything | 14941 | 1392 | 16 |
| 2 | rohitg00/agentmemory | 11159 | 939 | 99 |
| 3 | Ar9av/obsidian-wiki | 1314 | 151 | 8 |
| 4 | lucasastorian/llmwiki | 913 | 147 | 5 |
| 5 | Astro-Han/karpathy-llm-wiki | 845 | 114 | 2 |
| 6 | skyllwt/OmegaWiki | 673 | 103 | 5 |
| 7 | swarmclawai/swarmvault | 457 | 52 | 2 |
| 8 | nvk/llm-wiki | 428 | 57 | 4 |
| 9 | NicholasSpisak/second-brain | 325 | 57 | 0 |
| 10 | axoviq-ai/synthadoc | 314 | 32 | 1 |
| 11 | ussumant/llm-wiki-compiler | 261 | 25 | 1 |
| 12 | Ss1024sS/LLM-wiki | 101 | 24 | 0 |
| 13 | MehmetGoekce/llm-wiki | 89 | 11 | 0 |
| 14 | yologdev/yopedia | 56 | 8 | 4 |
| 15 | gowtham0992/link | 42 | 8 | 0 |
| 16 | zhurudong/andrej-karpathy-llm-wiki | 12 | 2 | 1 |
| 17 | jp-carrilloe/pulseOS-lite | 11 | 1 | 0 |
| 18 | sametbrr/llm-wiki-manager | 7 | 2 | 0 |

### Activity ranking

| Rank | Repo | 30d Commits | Total Commits | Last Commit Age | Activity Heuristic |
| --- | --- | ---: | ---: | --- | --- |
| 1 | yologdev/yopedia | 428 | 793 | ~0d | Active |
| 2 | gowtham0992/link | 374 | 396 | ~6d | Active |
| 3 | rohitg00/agentmemory | 191 | 344 | ~1d | Active |
| 4 | Lum1104/Understand-Anything | 129 | 498 | ~5d | Active |
| 5 | nvk/llm-wiki | 93 | 186 | ~3d | Active |
| 6 | axoviq-ai/synthadoc | 60 | 262 | ~1d | Active |
| 7 | lucasastorian/llmwiki | 50 | 109 | ~4d | Active |
| 8 | swarmclawai/swarmvault | 46 | 182 | ~6d | Active |
| 9 | Ar9av/obsidian-wiki | 42 | 111 | ~1d | Active |
| 10 | skyllwt/OmegaWiki | 35 | 70 | <1d | Active |
| 11 | jp-carrilloe/pulseOS-lite | 23 | 23 | ~10d | Active |
| 12 | zhurudong/andrej-karpathy-llm-wiki | 11 | 11 | ~5d | Active |
| 13 | Ss1024sS/LLM-wiki | 10 | 40 | ~28d | Low activity |
| 14 | sametbrr/llm-wiki-manager | 5 | 5 | ~10d | Low activity |
| 15 | MehmetGoekce/llm-wiki | 1 | 15 | ~30d | Low activity |
| 16 | ussumant/llm-wiki-compiler | 1 | 30 | ~12d | Low activity |
| 17 | Astro-Han/karpathy-llm-wiki | 0 | 14 | ~35d | Dormant |
| 18 | NicholasSpisak/second-brain | 0 | 7 | ~41d | Dormant |

### Maintenance ranking

| Rank | Repo | Basis | Maintenance Heuristic |
| --- | --- | --- | --- |
| 1 | rohitg00/agentmemory | 40 releases, 184 merged PRs, 191 recent commits | Rapid iteration |
| 2 | nvk/llm-wiki | 41 releases, 20 merged PRs, 93 recent commits | Rapid iteration |
| 3 | swarmclawai/swarmvault | 75 releases, steady recent commits, structured docs | Stable maintenance |
| 4 | Lum1104/Understand-Anything | 6 releases, 62 merged PRs, 129 recent commits | Rapid iteration |
| 5 | axoviq-ai/synthadoc | 4 releases, 81 merged PRs, 60 recent commits | Rapid iteration |
| 6 | Ar9av/obsidian-wiki | 2 releases, 30 merged PRs, 42 recent commits | Rapid iteration |
| 7 | lucasastorian/llmwiki | 15 merged PRs, moderate recent volume, no release process yet | Rapid iteration |
| 8 | skyllwt/OmegaWiki | 29 merged PRs, active docs/tooling churn | Rapid iteration |
| 9 | gowtham0992/link | 1 release, 22 merged PRs, very high recent commit volume | Rapid iteration |
| 10 | Ss1024sS/LLM-wiki | 5 releases, modest recent updates, CI/docs discipline | Stable maintenance |
| 11 | MehmetGoekce/llm-wiki | 2 releases, mostly docs/spec hardening lately | Maintenance-only |
| 12 | yologdev/yopedia | very high commits, but no releases and bot-heavy evolution loop | Experimental |
| 13 | jp-carrilloe/pulseOS-lite | active but still young and single-maintainer | Experimental |
| 14 | ussumant/llm-wiki-compiler | low recent change volume, no releases | Experimental |
| 15 | sametbrr/llm-wiki-manager | very young, low volume, 1 maintainer | Experimental |
| 16 | zhurudong/andrej-karpathy-llm-wiki | recent but small-scope template project | Experimental |
| 17 | Astro-Han/karpathy-llm-wiki | dormant, no releases, 1 contributor | Experimental |
| 18 | NicholasSpisak/second-brain | dormant, no releases, 1 contributor | Experimental |

### Onboarding friendliness ranking

| Rank | Repo | Score | Basis |
| --- | --- | ---: | --- |
| 1 | rohitg00/agentmemory | 9.5 | very large README/docs set, governance, benchmarks, examples, plugins, Docker, tests |
| 2 | Lum1104/Understand-Anything | 9.0 | README, docs, translated READMEs, plugin packaging, install scripts, CI/tooling |
| 3 | Ar9av/obsidian-wiki | 9.0 | README + SETUP, AGENTS/CLAUDE docs, setup script, CI, multi-agent install surface |
| 4 | axoviq-ai/synthadoc | 9.0 | extensive README, docs, tests, plugin, hooks, packaging |
| 5 | nvk/llm-wiki | 9.0 | AGENTS/CLAUDE, plugins, tests, scripts, release-heavy project maturity |
| 6 | swarmclawai/swarmvault | 9.0 | multilingual READMEs, docs, stability/scale docs, templates, validation suites |
| 7 | MehmetGoekce/llm-wiki | 8.5 | README, docs, examples, diagrams, contributing, OpenSpec coverage |
| 8 | gowtham0992/link | 8.5 | README, docs, CONTRIBUTING, SECURITY, tests, integrations, packaging |
| 9 | skyllwt/OmegaWiki | 8.0 | README, docs, config/app split, CLAUDE guidance, setup scripts |
| 10 | yologdev/yopedia | 8.0 | README, SCHEMA, deploy docs, Docker, lint/test configs |
| 11 | Ss1024sS/LLM-wiki | 8.0 | README, docs, tests, commands, plugin packaging, security docs |
| 12 | jp-carrilloe/pulseOS-lite | 8.0 | large numbered how-to docs, AGENTS/CLAUDE, docs and scripts |
| 13 | lucasastorian/llmwiki | 7.5 | README, tests, Docker, API/web split, but less explicit onboarding scaffolding |
| 14 | ussumant/llm-wiki-compiler | 7.0 | large README and plugin packaging, but thinner repo surface otherwise |
| 15 | Astro-Han/karpathy-llm-wiki | 7.0 | concise README + SKILL/examples, but limited operational scaffolding |
| 16 | NicholasSpisak/second-brain | 7.0 | README/docs/tests present, but small surface and limited process docs |
| 17 | zhurudong/andrej-karpathy-llm-wiki | 7.0 | bilingual README, examples, install script, template-first simplicity |
| 18 | sametbrr/llm-wiki-manager | 6.5 | README + SKILL only, smaller docs/process surface |

### Implementation complexity ranking

| Rank | Repo | Complexity | Basis |
| --- | --- | --- | --- |
| 1 | rohitg00/agentmemory | Very high | multi-package TS system, plugins, website, integrations, Docker, benchmarks |
| 2 | Lum1104/Understand-Anything | Very high | monorepo/plugins/homepage/docs, graph tooling, multiple install surfaces |
| 3 | skyllwt/OmegaWiki | High | app + config + runtime + mcp-servers + i18n + raw/wiki split |
| 4 | lucasastorian/llmwiki | High | API/web/MCP/extension/supabase/converter stack |
| 5 | swarmclawai/swarmvault | High | package workspace, templates, validation, smoke, multilingual docs |
| 6 | yologdev/yopedia | High | Next.js app, Docker, Cloudflare deployment, schema docs, growth automation |
| 7 | axoviq-ai/synthadoc | Medium-high | Python engine + TypeScript plugin + tests + hooks + docs |
| 8 | gowtham0992/link | Medium-high | large Python codebase, server/UI, packaging, MCP package, integrations |
| 9 | nvk/llm-wiki | Medium | many plugins/tests/docs, but lighter code surface than app-heavy repos |
| 10 | jp-carrilloe/pulseOS-lite | Medium | TS memory app plus docs, CLI, tools, skills |
| 11 | Ar9av/obsidian-wiki | Medium | many agent/plugin mirrors and scripts, but simpler core codebase |
| 12 | Ss1024sS/LLM-wiki | Medium | Python tooling + tests + commands + plugin packaging |
| 13 | MehmetGoekce/llm-wiki | Medium | templates/docs/specs/setup script, limited runtime code |
| 14 | ussumant/llm-wiki-compiler | Low-medium | plugin-oriented structure, lighter code depth |
| 15 | sametbrr/llm-wiki-manager | Low-medium | script + skill repo with modest packaging surface |
| 16 | Astro-Han/karpathy-llm-wiki | Low | content/skill/reference oriented |
| 17 | NicholasSpisak/second-brain | Low | small skills/docs/tests package |
| 18 | zhurudong/andrej-karpathy-llm-wiki | Low | template + examples + install script |

### AI-agent suitability ranking

| Rank | Repo | Suitability | Basis |
| --- | --- | --- | --- |
| 1 | Ar9av/obsidian-wiki | Excellent | explicit AGENTS.md and CLAUDE.md, multi-agent mirrors, setup docs, deterministic structure |
| 2 | rohitg00/agentmemory | Excellent | AGENTS.md, extensive docs, tests, reproducible packaging, strong automation surface |
| 3 | nvk/llm-wiki | Excellent | AGENTS/CLAUDE, plugins, tests, scripts, release discipline |
| 4 | MehmetGoekce/llm-wiki | Very high | strong docs/specs/examples, clear setup and architecture diagrams |
| 5 | swarmclawai/swarmvault | Very high | stable docs, validation suites, templates, release/process maturity |
| 6 | Lum1104/Understand-Anything | Very high | explicit CLAUDE guidance, install scripts, plugins, docs, reproducible workspace |
| 7 | skyllwt/OmegaWiki | High | CLAUDE, app/config/runtime separation, docs, scripts, but broader surface area |
| 8 | axoviq-ai/synthadoc | High | clear Python/package/plugin layout, tests, hooks, docs |
| 9 | gowtham0992/link | High | docs/tests/integrations/security, but large Python files raise navigation cost |
| 10 | Ss1024sS/LLM-wiki | High | plugin packaging, tests, scripts, docs, deterministic bootstrap |
| 11 | zhurudong/andrej-karpathy-llm-wiki | High | very simple template repo, install script, bilingual docs |
| 12 | ussumant/llm-wiki-compiler | Medium-high | plugin-centric and compact, but thinner operational docs |
| 13 | Astro-Han/karpathy-llm-wiki | Medium-high | compact, easy to read, examples present, but less operational tooling |
| 14 | NicholasSpisak/second-brain | Medium-high | small and easy to reason about, but limited automation/process depth |
| 15 | sametbrr/llm-wiki-manager | Medium | compact and simple, but sparse quality signals |
| 16 | jp-carrilloe/pulseOS-lite | Medium | strong docs, but mixed app/data layout increases navigation cost |
| 17 | yologdev/yopedia | Medium | active and documented, but autonomous-growth history increases context volume |
| 18 | lucasastorian/llmwiki | Medium | capable stack, but higher navigation/build complexity and less explicit agent onboarding |

## Repository Analyses

### Ar9av/obsidian-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 1314 |
| Forks | 151 |
| Open Issues | 8 |
| Repo Age | ~41 days |
| First Commit | 2026-04-06 11:50:01 +0530 |
| Age Since First Commit | ~41 days |
| Last Commit | 2026-05-16 15:19:45 +0530 |
| Time Since Last Commit | ~1 day |
| Contributors | 10 |
| Total Commits | 111 |
| Commits in Last Year | 111 |
| Commits in Last 30 Days | 42 |
| Commits in Last 90 Days | 111 |
| Commits in Last 12 Months | 111 |
| Release Count | 2 |
| Latest Release Date | 2026-05-06 |
| Open PRs | 2 |
| Merged PRs in Last 90 Days | 30 |
| Primary Languages | Python, HTML, Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 57.0% | Unavailable |
| HTML | 33.1% | Unavailable |
| Shell | 9.9% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- Strong recent maintenance: 42 commits in 30 days, 30 merged PRs in 90 days, and a fresh release cycle.
- Activity heuristic basis: very recent commit activity plus sustained merged PR throughput.

#### Stack Detection

- Python-centric skill/tooling repo with shell-based setup.
- Explicit multi-agent surfaces: `.agents`, `.claude`, `.cursor`, `.kiro`, `.windsurf`, `.skills`.
- Operational signals present: CI/CD (`.github`), setup script, scripts folder, env example, package-style agent instructions.
- Documentation/demo signals present: README, SETUP, agent docs, scripts.

#### Documentation

- README, SETUP.md, AGENTS.md, and CLAUDE.md provide unusually strong agent-facing onboarding.
- Quick-start/setup quality appears high from dedicated setup docs and install script.
- Contribution guidance is lighter than some larger projects, but onboarding documentation is strong overall.
- **Onboarding friendliness score:** 9.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low
- **Agent automation friendliness:** Excellent
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: explicit agent instruction files, mirrored tool-specific surfaces, deterministic repo structure, and limited code/build complexity.

### Astro-Han/karpathy-llm-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 845 |
| Forks | 114 |
| Open Issues | 2 |
| Repo Age | ~42 days |
| First Commit | 2026-04-05 13:37:06 +0800 |
| Age Since First Commit | ~42 days |
| Last Commit | 2026-04-13 09:37:27 +0800 |
| Time Since Last Commit | ~35 days |
| Contributors | 1 |
| Total Commits | 14 |
| Commits in Last Year | 14 |
| Commits in Last 30 Days | 0 |
| Commits in Last 90 Days | 14 |
| Commits in Last 12 Months | 14 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 1 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Unknown |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Not reliably retrievable | N/A | Unavailable |

#### Activity

- **Status:** Dormant
- **Velocity:** Experimental
- No commits in the last 30 days and last change is over a month old.
- Activity heuristic basis: zero 30-day commits and a stale last-commit timestamp, despite strong adoption.

#### Stack Detection

- Lightweight markdown/skill/reference repository.
- Root-level signals: README, SKILL.md, examples, references, assets.
- Operational signals are limited: no visible tests, linting config, containerization, or reproducible dev environment at root.

#### Documentation

- README plus SKILL.md and examples make the concept easy to inspect.
- Installation and quick-start coverage likely sufficient for a template/skill repo.
- Missing stronger contributor/CI/test scaffolding reduces onboarding depth.
- **Onboarding friendliness score:** 7.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low-medium
- **Agent automation friendliness:** Medium-high
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: compact content-first structure and examples help agents, but weaker operational tooling lowers automation confidence.

### axoviq-ai/synthadoc

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 314 |
| Forks | 32 |
| Open Issues | 1 |
| Repo Age | ~36 days |
| First Commit | 2026-04-10 23:55:47 -0400 |
| Age Since First Commit | ~36 days |
| Last Commit | 2026-05-16 11:27:14 -0400 |
| Time Since Last Commit | ~1 day |
| Contributors | 4 |
| Total Commits | 262 |
| Commits in Last Year | 262 |
| Commits in Last 30 Days | 60 |
| Commits in Last 90 Days | 262 |
| Commits in Last 12 Months | 262 |
| Release Count | 4 |
| Latest Release Date | 2026-05-11 |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 81 |
| Primary Languages | Python, TypeScript |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 82.7% | Unavailable |
| TypeScript | 17.3% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- 60 commits in 30 days, 81 merged PRs in 90 days, and 4 releases in a short lifetime indicate aggressive delivery.

#### Stack Detection

- Python core application with TypeScript-based Obsidian plugin surface.
- Root signals: `pyproject.toml`, tests, scripts, hooks, plugin folder, wiki folder.
- Operational signals: CI/CD, tests, package/release process, docs, hooks, examples embedded via wiki/docs structure.

#### Documentation

- Large README, docs directory, CONTRIBUTING, and release notes provide strong onboarding depth.
- Setup appears reproducible from pyproject plus plugin/runtime scaffolding.
- **Onboarding friendliness score:** 9.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** High
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** Medium
- Basis: well-documented mixed Python/TS stack with tests and clear structure, though broader runtime surface raises context size.

### gowtham0992/link

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 42 |
| Forks | 8 |
| Open Issues | 0 |
| Repo Age | ~37 days |
| First Commit | 2026-04-09 14:51:31 -0600 |
| Age Since First Commit | ~38 days |
| Last Commit | 2026-05-11 01:12:48 -0600 |
| Time Since Last Commit | ~6 days |
| Contributors | 1 |
| Total Commits | 396 |
| Commits in Last Year | 396 |
| Commits in Last 30 Days | 374 |
| Commits in Last 90 Days | 396 |
| Commits in Last 12 Months | 396 |
| Release Count | 1 |
| Latest Release Date | 2026-05-16 |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 22 |
| Primary Languages | Python, Shell, Ruby |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 97.4% | Unavailable |
| Shell | 2.5% | Unavailable |
| Ruby | 0.1% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- One of the highest 30-day commit volumes in the set, even though contributor concentration is very high.

#### Stack Detection

- Python application/server with packaging, MCP package, integrations, docs, tests, and wiki/raw data dirs.
- Root signals show CI, tests, docs, packaging, SECURITY, CONTRIBUTING, and GitHub Pages-backed docs site.
- Containerization is not obvious at root, but packaging and deployment signals are strong.

#### Documentation

- README, CHANGELOG, docs, CONTRIBUTING, SECURITY, and integration folders create strong onboarding coverage.
- Quick-start and operational docs appear solid.
- **Onboarding friendliness score:** 8.5/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** High
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** High
- Basis: strong documentation and tests offset the challenge of very large single-file Python entry points.

### jp-carrilloe/pulseOS-lite

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 11 |
| Forks | 1 |
| Open Issues | 0 |
| Repo Age | ~26 days |
| First Commit | 2026-04-21 18:57:35 +0200 |
| Age Since First Commit | ~26 days |
| Last Commit | 2026-05-07 16:22:47 +0200 |
| Time Since Last Commit | ~10 days |
| Contributors | 1 |
| Total Commits | 23 |
| Commits in Last Year | 23 |
| Commits in Last 30 Days | 23 |
| Commits in Last 90 Days | 23 |
| Commits in Last 12 Months | 23 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | TypeScript, CSS, Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| TypeScript | 90.4% | Unavailable |
| CSS | 6.7% | Unavailable |
| Shell | 1.5% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Experimental
- Recent but single-maintainer and low-process; commit cadence is healthy but still early-stage.

#### Stack Detection

- TypeScript-centric memory/workspace application with CLI, tools, skills, and docs.
- Root signals: `.claude.json`, AGENTS, CLAUDE, docs, scripts, skills, CLI, env example.
- Operational signals: CI/CD present, but test/lint/formatter evidence is not explicit from the root listing.

#### Documentation

- Strong human-readable onboarding: README plus numbered run/how-it-works/how-to-run docs.
- AGENTS and CLAUDE files improve agent-specific onboarding.
- **Onboarding friendliness score:** 8.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** Medium
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** Medium
- Basis: documentation is good, but mixed app/content layout and limited visible testing reduce confidence.

### lucasastorian/llmwiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 913 |
| Forks | 147 |
| Open Issues | 5 |
| Repo Age | ~43 days |
| First Commit | 2026-04-04 13:11:42 -0400 |
| Age Since First Commit | ~43 days |
| Last Commit | 2026-05-13 21:20:55 -0400 |
| Time Since Last Commit | ~4 days |
| Contributors | 3 |
| Total Commits | 109 |
| Commits in Last Year | 109 |
| Commits in Last 30 Days | 50 |
| Commits in Last 90 Days | 109 |
| Commits in Last 12 Months | 109 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 3 |
| Merged PRs in Last 90 Days | 15 |
| Primary Languages | Python, TypeScript, PLpgSQL |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 52.0% | Unavailable |
| TypeScript | 44.9% | Unavailable |
| PLpgSQL | 1.7% | Unavailable |
| CSS | 1.2% | Unavailable |
| Dockerfile | 0.2% | Unavailable |
| HTML | 0.0% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- Healthy 30-day volume and merged PR flow, though the project has not yet formalized releases.

#### Stack Detection

- Multi-surface application: API, web frontend, MCP, converter, extension, Supabase, Docker.
- Operational signals: CI/CD, tests, docker-compose, deployment config (`netlify.toml`), env example.
- Strong app-platform complexity compared with template-first repos.

#### Documentation

- README plus tests and container configs make setup possible, but onboarding is less explicit than agent-first repos.
- Contribution and architecture docs are not as visible at root.
- **Onboarding friendliness score:** 7.5/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** High
- **Agent automation friendliness:** Medium
- **Context compression suitability:** Low
- **Satellite-module feasibility:** Medium
- Basis: richer app architecture improves functionality, but broad cross-cutting surfaces increase navigation and setup cost for agents.

### Lum1104/Understand-Anything

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 14941 |
| Forks | 1392 |
| Open Issues | 16 |
| Repo Age | ~63 days |
| First Commit | 2026-03-14 17:15:51 +0800 |
| Age Since First Commit | ~64 days |
| Last Commit | 2026-05-13 10:20:33 +0800 |
| Time Since Last Commit | ~5 days |
| Contributors | 30 |
| Total Commits | 498 |
| Commits in Last Year | 498 |
| Commits in Last 30 Days | 129 |
| Commits in Last 90 Days | 498 |
| Commits in Last 12 Months | 498 |
| Release Count | 6 |
| Latest Release Date | 2026-05-04 |
| Open PRs | 2 |
| Merged PRs in Last 90 Days | 62 |
| Primary Languages | TypeScript, Python, Astro |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| TypeScript | 82.2% | Unavailable |
| Python | 10.3% | Unavailable |
| Astro | 2.9% | Unavailable |
| JavaScript | 2.8% | Unavailable |
| CSS | 0.6% | Unavailable |
| PowerShell | 0.6% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- High recent commit volume, strong merged PR throughput, and consistent releases.

#### Stack Detection

- TypeScript-first monorepo with plugins, homepage/site, docs, scripts, and install surfaces.
- Root signals: package.json, pnpm workspace, plugin dirs for Claude/Copilot/Cursor, install scripts, docs, homepage.
- Operational signals: CI/CD, package management, formatter/lint likely via package scripts, reproducible workspace, package publishing/plugin distribution.

#### Documentation

- README, CLAUDE.md, CONTRIBUTING, docs, translated READMEs, and dedicated install scripts support strong onboarding.
- Docs appear broad, but repo breadth increases onboarding time.
- **Onboarding friendliness score:** 9.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium-high
- **Agent automation friendliness:** Very high
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** High
- Basis: explicit agent docs and reproducible workspace are excellent, but repo breadth and plugin/app complexity are substantial.

### MehmetGoekce/llm-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 89 |
| Forks | 11 |
| Open Issues | 0 |
| Repo Age | ~39 days |
| First Commit | 2026-04-08 09:25:45 +0200 |
| Age Since First Commit | ~40 days |
| Last Commit | 2026-04-18 08:19:40 +0200 |
| Time Since Last Commit | ~30 days |
| Contributors | 2 |
| Total Commits | 15 |
| Commits in Last Year | 15 |
| Commits in Last 30 Days | 1 |
| Commits in Last 90 Days | 15 |
| Commits in Last 12 Months | 15 |
| Release Count | 2 |
| Latest Release Date | 2026-04-18 |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Shell, Mermaid |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Shell | 89.5% | Unavailable |
| Mermaid | 10.5% | Unavailable |

#### Activity

- **Status:** Low activity
- **Velocity:** Maintenance-only
- Recent work appears mostly documentation/spec hardening rather than feature churn.

#### Stack Detection

- Setup-script-first wiki tooling with templates, docs, diagrams, examples, and OpenSpec specs.
- Operational signals: CI/CD, setup script, config example, docs, examples, diagrams.
- Strong design/spec orientation despite light executable complexity.

#### Documentation

- README, docs, examples, diagrams, changelog, contributing, and openspec folder create excellent clarity.
- Architecture documentation is clearly present.
- **Onboarding friendliness score:** 8.5/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low
- **Agent automation friendliness:** Very high
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: low code complexity, strong architecture docs, explicit examples, and setup instructions.

### NicholasSpisak/second-brain

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 325 |
| Forks | 57 |
| Open Issues | 0 |
| Repo Age | ~41 days |
| First Commit | 2026-04-06 14:27:46 -0400 |
| Age Since First Commit | ~41 days |
| Last Commit | 2026-04-06 23:16:19 -0400 |
| Time Since Last Commit | ~41 days |
| Contributors | 1 |
| Total Commits | 7 |
| Commits in Last Year | 7 |
| Commits in Last 30 Days | 0 |
| Commits in Last 90 Days | 7 |
| Commits in Last 12 Months | 7 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Shell | 100.0% | Unavailable |

#### Activity

- **Status:** Dormant
- **Velocity:** Experimental
- Adoption outpaced maintenance activity; no commits landed in the last 30 days.

#### Stack Detection

- Minimal skills/docs package with docs, tests, and skills directories.
- Operational signals: tests present; CI/lint/package publishing not obvious from root.

#### Documentation

- README plus docs/tests suggest a decent starter experience.
- Smaller repo surface keeps onboarding simple, but process/docs depth is limited.
- **Onboarding friendliness score:** 7.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low
- **Agent automation friendliness:** Medium-high
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: simple layout and light footprint are agent-friendly, but limited operational scaffolding reduces robustness.

### nvk/llm-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 428 |
| Forks | 57 |
| Open Issues | 4 |
| Repo Age | ~43 days |
| First Commit | 2026-04-04 17:52:11 -0400 |
| Age Since First Commit | ~43 days |
| Last Commit | 2026-05-14 08:47:28 -0600 |
| Time Since Last Commit | ~3 days |
| Contributors | 4 |
| Total Commits | 186 |
| Commits in Last Year | 186 |
| Commits in Last 30 Days | 93 |
| Commits in Last 90 Days | 186 |
| Commits in Last 12 Months | 186 |
| Release Count | 41 |
| Latest Release Date | 2026-05-14 |
| Open PRs | 4 |
| Merged PRs in Last 90 Days | 20 |
| Primary Languages | Shell, Python, JavaScript |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Shell | 51.7% | Unavailable |
| Python | 45.7% | Unavailable |
| JavaScript | 2.6% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- Very strong release cadence plus high 30-day commit volume.

#### Stack Detection

- Agent/plugin-heavy repo with AGENTS, CLAUDE, plugin packaging, tests, and scripts.
- Operational signals: CI/CD, tests, release process, plugin packaging, scripts.
- Reproducible dev environment is lighter than full monorepos, but automation surface is strong.

#### Documentation

- Very strong agent-facing docs and README.
- Release-heavy process maturity helps onboarding and maintenance confidence.
- **Onboarding friendliness score:** 9.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** Excellent
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** High
- Basis: explicit instruction files, plugin/test surfaces, and disciplined release cadence.

### rohitg00/agentmemory

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 11159 |
| Forks | 939 |
| Open Issues | 99 |
| Repo Age | ~81 days |
| First Commit | 2026-02-27 11:32:40 +0530 |
| Age Since First Commit | ~80 days |
| Last Commit | 2026-05-16 10:43:30 +0100 |
| Time Since Last Commit | ~1 day |
| Contributors | 24 |
| Total Commits | 344 |
| Commits in Last Year | 344 |
| Commits in Last 30 Days | 191 |
| Commits in Last 90 Days | 344 |
| Commits in Last 12 Months | 344 |
| Release Count | 40 |
| Latest Release Date | 2026-05-17 |
| Open PRs | 55 |
| Merged PRs in Last 90 Days | 184 |
| Primary Languages | TypeScript, HTML, JavaScript |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| TypeScript | 81.1% | Unavailable |
| HTML | 8.1% | Unavailable |
| JavaScript | 8.0% | Unavailable |
| CSS | 1.5% | Unavailable |
| Python | 0.6% | Unavailable |
| Shell | 0.5% | Unavailable |
| Dockerfile | 0.2% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- This is the clearest high-throughput maintenance project in the set: 191 commits and 184 merged PRs in the most recent 90-day window.

#### Stack Detection

- Large TypeScript system with packages, plugin packaging, website, integrations, Docker, benchmarks, deploy configs.
- Operational signals: CI/CD, tests, Docker, package publishing, docs, benchmark suite, examples, strong repo governance.

#### Documentation

- Extremely strong: README, AGENTS, DESIGN, ROADMAP, GOVERNANCE, SECURITY, maintainers docs, examples, benchmark docs.
- Setup/build reproducibility appears strong from package and Docker configs.
- **Onboarding friendliness score:** 9.5/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** Excellent
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** High
- Basis: explicit agent docs, very strong process docs, reproducible tooling, but broad monorepo surface still costs context.

### sametbrr/llm-wiki-manager

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 7 |
| Forks | 2 |
| Open Issues | 0 |
| Repo Age | ~10 days |
| First Commit | 2026-05-07 16:25:27 +0300 |
| Age Since First Commit | ~10 days |
| Last Commit | 2026-05-07 17:24:42 +0300 |
| Time Since Last Commit | ~10 days |
| Contributors | 1 |
| Total Commits | 5 |
| Commits in Last Year | 5 |
| Commits in Last 30 Days | 5 |
| Commits in Last 90 Days | 5 |
| Commits in Last 12 Months | 5 |
| Release Count | 2 |
| Latest Release Date | 2026-05-07 |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Python, Go Template |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 74.5% | Unavailable |
| Go Template | 25.5% | Unavailable |

#### Activity

- **Status:** Low activity
- **Velocity:** Experimental
- Very new repository with minimal change history and single-maintainer concentration.

#### Stack Detection

- Small script/skill repository with README, SKILL, scripts, assets, references.
- Operational signals are light; CI/tests/linting are not obvious from the root listing.

#### Documentation

- README and SKILL make the repo understandable, but supporting docs are thin.
- **Onboarding friendliness score:** 6.5/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low
- **Agent automation friendliness:** Medium
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: compact structure is easy to inspect, but reliability/process signals remain limited.

### skyllwt/OmegaWiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 673 |
| Forks | 103 |
| Open Issues | 5 |
| Repo Age | ~38 days |
| First Commit | 2026-04-09 22:10:57 +0800 |
| Age Since First Commit | ~38 days |
| Last Commit | 2026-05-17 11:00:47 +0800 |
| Time Since Last Commit | <1 day |
| Contributors | 4 |
| Total Commits | 70 |
| Commits in Last Year | 70 |
| Commits in Last 30 Days | 35 |
| Commits in Last 90 Days | 70 |
| Commits in Last 12 Months | 70 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 2 |
| Merged PRs in Last 90 Days | 29 |
| Primary Languages | Python, JavaScript, CSS |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 79.5% | Unavailable |
| JavaScript | 13.6% | Unavailable |
| CSS | 3.6% | Unavailable |
| PowerShell | 1.5% | Unavailable |
| Shell | 1.4% | Unavailable |
| Go Template | 0.2% | Unavailable |
| HTML | 0.2% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- Very recent commit plus solid merged PR throughput, despite no formal releases yet.

#### Stack Detection

- Broader research platform: app, config, runtime, mcp-servers, raw/wiki, tools, i18n.
- Operational signals: CI/CD, setup scripts, requirements.txt, docs, CLAUDE guidance, likely MCP integration.
- Containerization not obvious at root, but reproducible setup appears plausible.

#### Documentation

- README, docs, CHANGELOG, CLAUDE, CONTRIBUTING, and configuration docs create strong onboarding.
- Large surface area increases onboarding time.
- **Onboarding friendliness score:** 8.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** High
- **Agent automation friendliness:** High
- **Context compression suitability:** Low
- **Satellite-module feasibility:** Medium
- Basis: many modules and directories increase complexity, but explicit CLAUDE/config docs help agents.

### Ss1024sS/LLM-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 101 |
| Forks | 24 |
| Open Issues | 0 |
| Repo Age | ~41 days |
| First Commit | 2026-04-06 10:49:36 +0800 |
| Age Since First Commit | ~41 days |
| Last Commit | 2026-04-20 01:16:39 +0800 |
| Time Since Last Commit | ~28 days |
| Contributors | 2 |
| Total Commits | 40 |
| Commits in Last Year | 40 |
| Commits in Last 30 Days | 10 |
| Commits in Last 90 Days | 40 |
| Commits in Last 12 Months | 40 |
| Release Count | 5 |
| Latest Release Date | 2026-04-18 |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Python, Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Python | 98.7% | Unavailable |
| Shell | 1.3% | Unavailable |

#### Activity

- **Status:** Low activity
- **Velocity:** Stable maintenance
- Release/process maturity is stronger than raw recent commit volume would suggest.

#### Stack Detection

- Python-heavy wiki/bootstrap tooling with plugin packaging, commands, scripts, skills, tests, docs.
- Operational signals: CI/CD, tests, plugin packaging, security docs, commands.

#### Documentation

- README, docs, CHANGELOG, UNIVERSAL guide, CONTRIBUTING, SECURITY, and commands support onboarding well.
- **Onboarding friendliness score:** 8.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium-low
- **Agent automation friendliness:** High
- **Context compression suitability:** Medium-high
- **Satellite-module feasibility:** High
- Basis: good tooling/docs balance with moderate complexity and explicit packaging surfaces.

### swarmclawai/swarmvault

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 457 |
| Forks | 52 |
| Open Issues | 2 |
| Repo Age | ~41 days |
| First Commit | 2026-04-06 21:51:02 +0100 |
| Age Since First Commit | ~41 days |
| Last Commit | 2026-05-11 10:36:06 +0100 |
| Time Since Last Commit | ~6 days |
| Contributors | 2 |
| Total Commits | 182 |
| Commits in Last Year | 182 |
| Commits in Last 30 Days | 46 |
| Commits in Last 90 Days | 182 |
| Commits in Last 12 Months | 182 |
| Release Count | 75 |
| Latest Release Date | 2026-05-11 |
| Open PRs | 1 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | TypeScript, JavaScript, CSS |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| TypeScript | 86.0% | Unavailable |
| JavaScript | 12.5% | Unavailable |
| CSS | 1.4% | Unavailable |
| Shell | 0.1% | Unavailable |
| HTML | 0.0% | Unavailable |
| Dart | 0.0% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Stable maintenance
- High release cadence and healthy recent commit volume, but little live PR throughput visible compared with the largest projects.

#### Stack Detection

- TS workspace with packages, templates, smoke tests, validation, scripts, docs, multilingual READMEs.
- Operational signals: CI/CD, formatter (`biome.json`), hooks (`lefthook.yml`), package workspace, smoke/validation suites, package publishing cues.

#### Documentation

- README plus SCALE/STABILITY docs, multilingual READMEs, docs, templates, and validation surfaces create excellent onboarding.
- **Onboarding friendliness score:** 9.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium
- **Agent automation friendliness:** Very high
- **Context compression suitability:** Medium
- **Satellite-module feasibility:** High
- Basis: strong operational hygiene and documentation offset monorepo breadth.

### ussumant/llm-wiki-compiler

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 261 |
| Forks | 25 |
| Open Issues | 1 |
| Repo Age | ~43 days |
| First Commit | 2026-04-04 21:42:54 +0530 |
| Age Since First Commit | ~43 days |
| Last Commit | 2026-05-05 19:25:28 +0530 |
| Time Since Last Commit | ~12 days |
| Contributors | 2 |
| Total Commits | 30 |
| Commits in Last Year | 30 |
| Commits in Last 30 Days | 1 |
| Commits in Last 90 Days | 30 |
| Commits in Last 12 Months | 30 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | HTML, JavaScript, Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| HTML | 58.1% | Unavailable |
| JavaScript | 26.1% | Unavailable |
| Shell | 15.8% | Unavailable |

#### Activity

- **Status:** Low activity
- **Velocity:** Experimental
- Recent activity has dropped sharply after initial buildout.

#### Stack Detection

- Plugin/agent-oriented compiler repo with `.agents`, `.claude-plugin`, plugin folder, assets, large README.
- Operational signals: packaging/plugin distribution, but limited visible tests or CI cues from root.

#### Documentation

- README is substantial and likely carries most of the onboarding load.
- Fewer surrounding docs/process files than the more mature peers.
- **Onboarding friendliness score:** 7.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low-medium
- **Agent automation friendliness:** Medium-high
- **Context compression suitability:** Medium-high
- **Satellite-module feasibility:** High
- Basis: compact plugin-oriented structure is easy to reason about, but there are fewer verification signals.

### yologdev/yopedia

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 56 |
| Forks | 8 |
| Open Issues | 4 |
| Repo Age | ~41 days |
| First Commit | 2026-04-06 02:07:59 +0200 |
| Age Since First Commit | ~42 days |
| Last Commit | 2026-05-17 17:33:45 +0000 |
| Time Since Last Commit | ~3 hours |
| Contributors | 3 |
| Total Commits | 793 |
| Commits in Last Year | 793 |
| Commits in Last 30 Days | 428 |
| Commits in Last 90 Days | 793 |
| Commits in Last 12 Months | 793 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 27 |
| Primary Languages | TypeScript, JavaScript |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| TypeScript | 97.1% | Unavailable |
| JavaScript | 2.2% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Rapid iteration
- Highest raw commit volume in the whole set, with bot-driven autonomous evolution contributing heavily.

#### Stack Detection

- Next.js/TypeScript app with Docker, Cloudflare deployment config, schema docs, lint/test configs, and automation-specific files (`.yoyo`, `YOYO.md`).
- Operational signals: CI/CD, Docker, linting, testing, deployment config, reproducible package manager lockfile.

#### Documentation

- README, SCHEMA, DEPLOY, YOYO docs, and concept docs provide strong domain guidance.
- High change volume may reduce onboarding stability despite good written docs.
- **Onboarding friendliness score:** 8.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Medium-high
- **Agent automation friendliness:** Medium-high
- **Context compression suitability:** Low-medium
- **Satellite-module feasibility:** Medium
- Basis: explicit schema/deploy docs help, but fast autonomous growth creates a large, shifting context surface.

### zhurudong/andrej-karpathy-llm-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 12 |
| Forks | 2 |
| Open Issues | 1 |
| Repo Age | ~23 days |
| First Commit | 2026-04-24 18:58:36 +0800 |
| Age Since First Commit | ~23 days |
| Last Commit | 2026-05-13 12:42:34 +0800 |
| Time Since Last Commit | ~5 days |
| Contributors | 2 |
| Total Commits | 11 |
| Commits in Last Year | 11 |
| Commits in Last 30 Days | 11 |
| Commits in Last 90 Days | 11 |
| Commits in Last 12 Months | 11 |
| Release Count | 0 |
| Latest Release Date | N/A |
| Open PRs | 0 |
| Merged PRs in Last 90 Days | 0 |
| Primary Languages | Shell |

#### Languages

| Language | Fraction | Byte Count |
| --- | ---: | --- |
| Shell | 100.0% | Unavailable |

#### Activity

- **Status:** Active
- **Velocity:** Experimental
- Recent but still small-scope and template-focused.

#### Stack Detection

- Minimal template/bootstrap repo: install script, CLAUDE template, bilingual READMEs, examples, templates.
- Operational signals: no visible CI/tests at root; simplicity is the main strength.

#### Documentation

- Bilingual README coverage and examples are strong for a small repo.
- Setup is likely straightforward because scope is narrow.
- **Onboarding friendliness score:** 7.0/10

#### AI/Agent Assessment

- **LLM onboarding difficulty:** Low
- **Agent automation friendliness:** High
- **Context compression suitability:** High
- **Satellite-module feasibility:** High
- Basis: tiny footprint, template-first design, and explicit install/bootstrap path.

## Cross-Repository Conclusions

- **Most adopted:** `Lum1104/Understand-Anything` and `rohitg00/agentmemory` dominate stars, forks, and contributor depth; both also show strong operational maturity.
- **Most active by raw throughput:** `yologdev/yopedia`, `gowtham0992/link`, `rohitg00/agentmemory`, and `Lum1104/Understand-Anything`.
- **Most release-driven maintenance:** `swarmclawai/swarmvault`, `nvk/llm-wiki`, and `rohitg00/agentmemory`.
- **Best explicit agent/onboarding ergonomics:** `Ar9av/obsidian-wiki`, `rohitg00/agentmemory`, `nvk/llm-wiki`, `MehmetGoekce/llm-wiki`, and `swarmclawai/swarmvault`.
- **Simplest template-first repos for quick study:** `zhurudong/andrej-karpathy-llm-wiki`, `Astro-Han/karpathy-llm-wiki`, and `NicholasSpisak/second-brain`.
- **Most complex implementation surfaces:** `rohitg00/agentmemory`, `Lum1104/Understand-Anything`, `skyllwt/OmegaWiki`, `lucasastorian/llmwiki`, and `swarmclawai/swarmvault`.
- **Best candidates for agent automation on day one:** `Ar9av/obsidian-wiki`, `rohitg00/agentmemory`, `nvk/llm-wiki`, `MehmetGoekce/llm-wiki`, and `swarmclawai/swarmvault`.
