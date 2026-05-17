# GitHub Repository Metrics Report

## Methodology

- **Live retrieval during this run:** GitHub repository metadata was retrieved in-run via GitHub-oriented agent/tooling, with preference for GitHub API/CLI-backed sources where available.
- **Repository inspection:** Repository contents were inspected from the workspace’s mirrored implementation folders and HTML repository captures to detect stack, operational signals, documentation quality, and AI/agent-facing structure.
- **Supplementary artifacts:** Existing workspace artifacts (`implementations/repo_list.md`, `implementations/github_stats_local.json`, mirrored repository folders, and repository HTML captures) were used **only as supplementary context and cross-check material**, not as a substitute for live retrieval.
- **Relative time anchor:** All relative-age statements use **2026-05-17T22:19:12.712+03:00**.
- **Missing data policy:** If a datum could not be refreshed or verified reliably in this environment, it is reported as **N/A**, **Unknown**, **Unavailable**, or **Not reliably retrievable**.
- **Heuristics:** Activity, maintenance, onboarding, complexity, and AI-agent suitability labels are explicitly marked as heuristics and are based on observable signals such as recency, commit volume, contributors, release cadence, repo structure, setup docs, tests, workflows, and agent-instruction files.

## Notes _(if appropriate)_

- Several deep GitHub metrics were only partially available via live retrieval in this environment. In particular, **latest release date** and **merged PRs in the last 90 days** were frequently **Not reliably retrievable**.
- Some repositories appear to be very new 2026 projects with extremely compressed histories; commit-frequency values reflect the grounded history artifacts available in the workspace.
- `yologdev/karpathy-llm-wiki` appears to surface as **yologdev/yopedia** in repository metadata/description, but this report retains the **user-supplied repository identifier**.
- Language **byte counts** were not consistently available in the grounded artifacts; when unavailable, they are marked accordingly.

## Cross-Repository Comparative Tables

### Popularity Ranking

| Rank | Repository | Stars | Forks | Notes |
| --- | --- | ---: | ---: | --- |
| 1 | Lum1104/Understand-Anything | 14,882 | 1,378 | Breakout adoption leader |
| 2 | rohitg00/agentmemory | 10,736 | 907 | Very strong ecosystem pull |
| 3 | Ar9av/obsidian-wiki | 1,309 | 151 | Strong niche adoption |
| 4 | lucasastorian/llmwiki | 910 | 146 | Full app + MCP appeal |
| 5 | Astro-Han/karpathy-llm-wiki | 845 | 114 | High doc-template adoption |
| 6 | skyllwt/OmegaWiki | 672 | 102 | Strong growth despite incomplete live metadata |
| 7 | swarmclawai/swarmvault | 456 | 52 | Mid-tier but active |
| 8 | nvk/llm-wiki | 426 | 56 | Strong maintenance signal |
| 9 | NicholasSpisak/second-brain | 324 | 57 | Popular but currently quiet |
| 10 | axoviq-ai/synthadoc | 311 | 30 | Production-oriented niche |
| 11 | ussumant/llm-wiki-compiler | 261 | 24 | Plugin/compiler angle |
| 12 | Ss1024sS/LLM-wiki | 101 | 24 | Small but documented |
| 13 | MehmetGoekce/llm-wiki | 88 | 11 | Small, docs-focused |
| 14 | yologdev/karpathy-llm-wiki | 56 | 8 | Active but still niche |
| 15 | gowtham0992/link | 42 | 8 | Low adoption, high recent dev |
| 16 | zhurudong/andrej-karpathy-llm-wiki | 12 | 2 | Minimal template |
| 17 | jp-carrilloe/pulseOS-lite | 11 | 1 | Low visibility |
| 18 | sametbrr/llm-wiki-manager | 7 | 2 | Very early-stage |

### Activity Ranking

| Rank | Repository | Last Commit | Commits 30d | Heuristic |
| --- | --- | --- | ---: | --- |
| 1 | yologdev/karpathy-llm-wiki | 2026-05-16 | 368 | Active |
| 2 | rohitg00/agentmemory | 2026-05-16 | 123 | Active |
| 3 | Lum1104/Understand-Anything | 2026-05-13 | 108 | Active |
| 4 | gowtham0992/link | 2026-05-11 | 363 | Active |
| 5 | skyllwt/OmegaWiki | 2026-05-17 | 32 | Active |
| 6 | axoviq-ai/synthadoc | 2026-05-16 | 47 | Active |
| 7 | nvk/llm-wiki | 2026-05-14 | 79 | Active |
| 8 | Ar9av/obsidian-wiki | 2026-05-16 | 32 | Active |
| 9 | swarmclawai/swarmvault | 2026-05-11 | 33 | Active |
| 10 | lucasastorian/llmwiki | 2026-05-13 | 32 | Active |
| 11 | jp-carrilloe/pulseOS-lite | 2026-05-07 | 24 | Active |
| 12 | zhurudong/andrej-karpathy-llm-wiki | 2026-05-13 | 10 | Active |
| 13 | ussumant/llm-wiki-compiler | 2026-05-05 | 1 | Low activity |
| 14 | Ss1024sS/LLM-wiki | 2026-04-20 | 11 | Low activity |
| 15 | sametbrr/llm-wiki-manager | 2026-05-07 | 5 | Low activity |
| 16 | MehmetGoekce/llm-wiki | 2026-04-18 | 1 | Low activity |
| 17 | Astro-Han/karpathy-llm-wiki | 2026-04-13 | 0 | Dormant |
| 18 | NicholasSpisak/second-brain | 2026-04-06 | 0 | Dormant |

### Maintenance Ranking

| Rank | Repository | Releases | Contributors | Maintenance Heuristic |
| --- | --- | ---: | ---: | --- |
| 1 | swarmclawai/swarmvault | 75 | 2 | Stable maintenance |
| 2 | nvk/llm-wiki | 41 | 4 | Stable maintenance |
| 3 | rohitg00/agentmemory | 39 | 24 | Rapid iteration |
| 4 | Lum1104/Understand-Anything | 6 | 30 | Rapid iteration |
| 5 | Ss1024sS/LLM-wiki | 5 | 2 | Maintenance-only |
| 6 | axoviq-ai/synthadoc | 4 | 4 | Rapid iteration |
| 7 | Ar9av/obsidian-wiki | 2 | 10 | Rapid iteration |
| 8 | MehmetGoekce/llm-wiki | 2 | 2 | Maintenance-only |
| 9 | sametbrr/llm-wiki-manager | 2 | 1 | Experimental |
| 10 | gowtham0992/link | 1 | 1 | Rapid iteration |
| 11 | skyllwt/OmegaWiki | 0 | 4 | Rapid iteration |
| 12 | yologdev/karpathy-llm-wiki | 0 | 3 | Rapid iteration |
| 13 | lucasastorian/llmwiki | 0 | 3 | Rapid iteration |
| 14 | zhurudong/andrej-karpathy-llm-wiki | 0 | 2 | Experimental |
| 15 | ussumant/llm-wiki-compiler | 0 | 2 | Experimental |
| 16 | jp-carrilloe/pulseOS-lite | 0 | 1 | Experimental |
| 17 | Astro-Han/karpathy-llm-wiki | 0 | 1 | Experimental |
| 18 | NicholasSpisak/second-brain | 0 | 1 | Experimental |

### Onboarding Friendliness Ranking

| Rank | Repository | Heuristic Score | Basis |
| --- | --- | ---: | --- |
| 1 | yologdev/karpathy-llm-wiki | 9.5/10 | ONBOARDING docs, app docs, workflows, config surface |
| 2 | Lum1104/Understand-Anything | 8.5/10 | README, CONTRIBUTING, docs, plugins, benchmarks |
| 3 | jp-carrilloe/pulseOS-lite | 8.5/10 | Multi-step run/how-it-works docs + AGENTS/CLAUDE |
| 4 | rohitg00/agentmemory | 8.0/10 | Governance/docs breadth, packages, website |
| 5 | axoviq-ai/synthadoc | 8.0/10 | README, CONTRIBUTING, docs, tests, workflows |
| 6 | MehmetGoekce/llm-wiki | 8.0/10 | Docs, diagrams, examples, setup template |
| 7 | gowtham0992/link | 8.0/10 | README, CONTRIBUTING, tests, integrations |
| 8 | skyllwt/OmegaWiki | 7.8/10 | README, docs, setup scripts, app structure |
| 9 | lucasastorian/llmwiki | 7.5/10 | App structure, tests, docker, MCP |
| 10 | swarmclawai/swarmvault | 7.5/10 | Multilingual READMEs, smoke/validation, skills |
| 11 | Ar9av/obsidian-wiki | 7.0/10 | README + SETUP + rich agent docs |
| 12 | Ss1024sS/LLM-wiki | 7.0/10 | README, CONTRIBUTING, examples, tests |
| 13 | nvk/llm-wiki | 6.5/10 | Strong agent docs, lighter conventional onboarding |
| 14 | Astro-Han/karpathy-llm-wiki | 5.0/10 | README + example/reference docs only |
| 15 | ussumant/llm-wiki-compiler | 5.0/10 | README + plugin artifacts |
| 16 | zhurudong/andrej-karpathy-llm-wiki | 5.0/10 | Minimal bilingual template + examples |
| 17 | NicholasSpisak/second-brain | 4.5/10 | Minimal structure |
| 18 | sametbrr/llm-wiki-manager | 4.0/10 | Sparse repo, limited docs surface |

### Implementation Complexity Ranking

| Rank | Repository | Heuristic | Basis |
| --- | --- | --- | --- |
| 1 | rohitg00/agentmemory | Very high | Monorepo, website, packages, integrations, benchmark, deploy |
| 2 | Lum1104/Understand-Anything | Very high | Workspace, homepage, plugin ecosystem, multi-client support |
| 3 | lucasastorian/llmwiki | High | API + web + converter + MCP + Supabase |
| 4 | yologdev/karpathy-llm-wiki | High | Full Next.js app + lifecycle engine + MCP + workflows |
| 5 | swarmclawai/swarmvault | High | Workspace/packages, smoke tests, validation, release automation |
| 6 | skyllwt/OmegaWiki | High | App + MCP servers + tooling + docs + runtime |
| 7 | axoviq-ai/synthadoc | High | Python engine + plugin + docs + tests |
| 8 | nvk/llm-wiki | Medium-high | Multi-agent/plugins/scripts/tests |
| 9 | gowtham0992/link | Medium | Python core + server + integrations + tests |
| 10 | Ar9av/obsidian-wiki | Medium | Agent-framework repo, many instruction surfaces |
| 11 | jp-carrilloe/pulseOS-lite | Medium | Structured memory framework, lighter codebase |
| 12 | Ss1024sS/LLM-wiki | Medium-low | Commands/examples/tests, mostly docs/scripts |
| 13 | ussumant/llm-wiki-compiler | Low-medium | Plugin-centered, smaller footprint |
| 14 | MehmetGoekce/llm-wiki | Low | Docs-heavy template repo |
| 15 | Astro-Han/karpathy-llm-wiki | Low | Minimal docs-first implementation |
| 16 | sametbrr/llm-wiki-manager | Low | Very small surface area |
| 17 | NicholasSpisak/second-brain | Low | Minimal docs/skills/tests |
| 18 | zhurudong/andrej-karpathy-llm-wiki | Low | Single-file/template style |

### AI-Agent Suitability Ranking

| Rank | Repository | Heuristic | Basis |
| --- | --- | --- | --- |
| 1 | rohitg00/agentmemory | Excellent | AGENTS, integrations, package boundaries, publish/CI |
| 2 | Lum1104/Understand-Anything | Excellent | CLAUDE/Copilot/Cursor plugin surfaces, docs, workspace |
| 3 | Ar9av/obsidian-wiki | Excellent | AGENTS + CLAUDE + multiple agent directories |
| 4 | yologdev/karpathy-llm-wiki | Excellent | ONBOARDING, MCP, clear domain modules, workflows |
| 5 | nvk/llm-wiki | Excellent | AGENTS, CLAUDE, plugin directories, tests |
| 6 | jp-carrilloe/pulseOS-lite | Strong | AGENTS, CLAUDE, skills/tools/runbooks |
| 7 | skyllwt/OmegaWiki | Strong | CLAUDE, MCP config, setup scripts, app/tools split |
| 8 | swarmclawai/swarmvault | Strong | Skills, manifest, validation, release discipline |
| 9 | gowtham0992/link | Strong | Integrations for multiple agent clients, tests |
| 10 | lucasastorian/llmwiki | Strong | MCP boundary, componentized full-stack layout |
| 11 | axoviq-ai/synthadoc | Good | Engine/plugin split, tests, workflow |
| 12 | Ss1024sS/LLM-wiki | Good | Claude plugin, commands, examples |
| 13 | ussumant/llm-wiki-compiler | Moderate | Plugin and agents dirs, smaller capability surface |
| 14 | MehmetGoekce/llm-wiki | Moderate | Good docs, simpler automation surface |
| 15 | zhurudong/andrej-karpathy-llm-wiki | Moderate | Minimal but compressible |
| 16 | Astro-Han/karpathy-llm-wiki | Limited | Mostly documentation template |
| 17 | NicholasSpisak/second-brain | Limited | Sparse automation cues |
| 18 | sametbrr/llm-wiki-manager | Limited | Small repo, little reproducibility evidence |

## Repository Analyses

### Ar9av/obsidian-wiki

- **Owner / org:** Ar9av
- **GitHub URL:** https://github.com/Ar9av/obsidian-wiki
- **Description:** Framework for AI agents to build and maintain an Obsidian wiki using Karpathy's LLM Wiki pattern.
- **Primary topic tags:** wiki, knowledge-base, obsidian, llm-tools, agent-skills

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 1,309 |
| Forks | 151 |
| Repo Age | 2y 1m 1d |
| Last Commit | 2026-05-16 (~1 day ago) |
| Contributors | 10 |
| Primary Languages | Python, HTML, Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 57.0% | Unavailable |
| HTML | 33.1% | Unavailable |
| Shell | 9.9% | Unavailable |

#### Activity

- **Repository creation date:** 2024-04-16
- **Age since repository creation:** 2y 1m 1d
- **First commit date:** 2026-04-06
- **Age since first commit:** ~1m 11d
- **Most recent commit date:** 2026-05-16
- **Time since last commit:** ~1 day
- **Commit frequency:** 32 (30d) / 103 (90d) / 103 (12m)
- **Open issues:** 0
- **Total contributor count:** 10
- **Total commit count:** 103
- **Commits in last year:** 103
- **Release count:** 2
- **Latest release date:** Unavailable
- **Open pull requests:** 10
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on last commit within ~1 day and 32 commits in the last 30 days.
- **Development velocity heuristic:** **Rapid iteration** — based on 103 commits in 90 days, 10 contributors, 2 releases, and 10 open PRs.

#### Stack Detection

- **Detected stack:** Python, HTML, Shell, Obsidian-oriented knowledge-base framework
- **Observed repo signals:** `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agent/`, `.agents/`, `.claude/`, `.cursor/`, `.kiro/`, `.skills/`, `.windsurf/`, `setup.sh`, `SETUP.md`, `.env.example`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`setup.sh`, `.env.example`; no devcontainer/nix observed)
- **Package publishing:** Not observed
- **Benchmarks:** Observed in supplementary workspace scan
- **Examples / demo apps:** No demo app observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes (`SETUP.md`, `setup.sh`)
- **Quick start:** Partial
- **Contribution guide:** No `CONTRIBUTING.md` observed
- **Architecture docs:** Not observed
- **API docs:** Not observed
- **Onboarding docs:** Partial via setup + agent docs
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **7.0/10** — based on README, setup docs, and unusually rich agent-facing instructions, offset by limited conventional architecture/testing docs.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Medium; agent-specific surfaces are clearly separated
- **Monorepo complexity:** Low-medium
- **Generated code:** Not reliably retrievable
- **Code navigation difficulty:** Low-medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Weak
- **Agent instruction files:** Strong (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, multiple agent dirs)
- **Dependency graph complexity heuristic:** Medium — multiple agent integrations but limited conventional app stack
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **High**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **High**

### Astro-Han/karpathy-llm-wiki

- **Owner / org:** Astro-Han
- **GitHub URL:** https://github.com/Astro-Han/karpathy-llm-wiki
- **Description:** Agent Skills-compatible LLM wiki for Claude Code, Cursor, and Codex. Build a Karpathy-style knowledge base from raw sources, citations, and linting.
- **Primary topic tags:** markdown, productivity, cursor, knowledge-base, personal-knowledge-base

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 845 |
| Forks | 114 |
| Repo Age | 1m 12d |
| Last Commit | 2026-04-13 (~1m 4d ago) |
| Contributors | 1 |
| Primary Languages | Not reliably retrievable |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Not reliably retrievable | N/A | N/A |

#### Activity

- **Repository creation date:** 2026-04-05
- **Age since repository creation:** 1m 12d
- **First commit date:** 2026-04-05
- **Age since first commit:** ~1m 12d
- **Most recent commit date:** 2026-04-13
- **Time since last commit:** ~1m 4d
- **Commit frequency:** 0 (30d) / 14 (90d) / 14 (12m)
- **Open issues:** 0
- **Total contributor count:** 1
- **Total commit count:** 14
- **Commits in last year:** 14
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** 1
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Dormant** — based on no commits in the last 30 days and last commit more than a month ago.
- **Development velocity heuristic:** **Experimental** — based on 1 contributor, low total commit volume, and no releases.

#### Stack Detection

- **Detected stack:** Documentation-first markdown knowledge-base template
- **Observed repo signals:** `README.md`, `SKILL.md`, `assets/`, `examples/`, `references/`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Weak
- **Package publishing:** Not observed
- **Documentation site:** Not observed
- **Examples:** Yes (`examples/`)

#### Documentation

- **README completeness:** Moderate
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Not observed in root scan
- **Architecture docs:** Not observed
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Yes
- **Onboarding friendliness heuristic:** **5.0/10** — based on README, examples, and references, but limited runnable or testable structure.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low
- **Monorepo complexity:** None
- **Code navigation difficulty:** Low
- **Build reproducibility:** Weak
- **Test reproducibility:** Weak
- **Agent instruction files:** `SKILL.md` only
- **Dependency graph complexity heuristic:** Low
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Limited**
- **Context compression suitability heuristic:** **Very high**
- **Satellite-module feasibility heuristic:** **Low**

### axoviq-ai/synthadoc

- **Owner / org:** axoviq-ai
- **GitHub URL:** https://github.com/axoviq-ai/synthadoc
- **Description:** Synthadoc: An open-source LLM knowledge compilation engine that turns raw documents into structured, local-first wikis.
- **Primary topic tags:** enterprise, knowledge-graph, pkm, synthetic, domain-adaptation

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 311 |
| Forks | 30 |
| Repo Age | 2y 1m 6d |
| Last Commit | 2026-05-16 (~1 day ago) |
| Contributors | 4 |
| Primary Languages | Python, TypeScript |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 82.7% | Unavailable |
| TypeScript | 17.3% | Unavailable |

#### Activity

- **Repository creation date:** 2024-04-11
- **Age since repository creation:** 2y 1m 6d
- **First commit date:** 2026-04-10
- **Age since first commit:** ~1m 7d
- **Most recent commit date:** 2026-05-16
- **Time since last commit:** ~1 day
- **Commit frequency:** 47 (30d) / 249 (90d) / 249 (12m)
- **Open issues:** 1
- **Total contributor count:** 4
- **Total commit count:** 249
- **Commits in last year:** 249
- **Release count:** 4
- **Latest release date:** Unavailable
- **Open pull requests:** 0
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on very recent commits and 47 commits in the last 30 days.
- **Development velocity heuristic:** **Rapid iteration** — based on 249 commits in 90 days, 4 contributors, and 4 releases.

#### Stack Detection

- **Detected stack:** Python, TypeScript, Obsidian plugin, docs/wiki compiler
- **Observed repo signals:** `pyproject.toml`, `.github/workflows/ci.yml`, `tests/`, `hooks/`, `docs/`, `obsidian-plugin/`, `scripts/`, `wiki/`
- **CI/CD:** Yes
- **Automated testing:** Yes (`tests/`, workflow)
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`pyproject.toml`)
- **Package publishing:** Not observed
- **Benchmarks:** Observed in supplementary scan
- **Examples / demo apps:** Not clearly observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Yes
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **8.0/10** — based on README, CONTRIBUTING, architecture docs, tests, and CI.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** High (engine + plugin + docs split)
- **Monorepo complexity:** Medium
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Partial-strong
- **Test reproducibility:** Good
- **Agent instruction files:** Not directly observed in root scan
- **Dependency graph complexity heuristic:** Medium-high
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Good**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### gowtham0992/link

- **Owner / org:** gowtham0992
- **GitHub URL:** https://github.com/gowtham0992/link
- **Description:** Local personal memory for LLM agents.
- **Primary topic tags:** markdown, memory, knowledge-base, obsidian, personal-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 42 |
| Forks | 8 |
| Repo Age | 9y 5m 26d |
| Last Commit | 2026-05-11 (~6 days ago) |
| Contributors | 1 |
| Primary Languages | Python, Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 97.4% | Unavailable |
| Shell | 2.5% | Unavailable |
| Ruby | 0.1% | Unavailable |

#### Activity

- **Repository creation date:** 2016-11-21
- **Age since repository creation:** 9y 5m 26d
- **First commit date:** 2026-04-09
- **Age since first commit:** ~1m 8d
- **Most recent commit date:** 2026-05-11
- **Time since last commit:** ~6 days
- **Commit frequency:** 363 (30d) / 393 (90d) / 393 (12m)
- **Open issues:** 1
- **Total contributor count:** 1
- **Total commit count:** 393
- **Commits in last year:** 393
- **Release count:** 1
- **Latest release date:** Unavailable
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on last commit within a week and very high recent commit volume.
- **Development velocity heuristic:** **Rapid iteration** — based on 393 commits in 90 days, despite only 1 contributor and 1 release.

#### Stack Detection

- **Detected stack:** Python, shell utilities, local memory/wiki server, MCP-oriented integrations
- **Observed repo signals:** `pyproject.toml`, `.github/workflows/ci.yml`, `link.py`, `serve.py`, `mcp_package/`, `integrations/`, `tests/`, `.env.example`
- **CI/CD:** Yes
- **Automated testing:** Yes
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`pyproject.toml`, `.env.example`)
- **Package publishing:** Not reliably retrievable
- **Examples / demo apps:** No dedicated demo app observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Not observed
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **8.0/10** — based on README, CONTRIBUTING, tests, CI, and explicit integrations directory.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** Medium
- **Monorepo complexity:** Low-medium
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Good
- **Agent instruction files:** No root AGENTS/CLAUDE file observed
- **Agent-client integrations:** Strong (`integrations/`, `mcp_package/`)
- **Dependency graph complexity heuristic:** Medium
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **High**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### jp-carrilloe/pulseOS-lite

- **Owner / org:** jp-carrilloe
- **GitHub URL:** https://github.com/jp-carrilloe/pulseOS-lite
- **Description:** Company Memory for AI Agents.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 11 |
| Forks | 1 |
| Repo Age | 2y 3m 12d |
| Last Commit | 2026-05-07 (~10 days ago) |
| Contributors | 1 |
| Primary Languages | TypeScript, CSS, Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| TypeScript | 90.4% | Unavailable |
| CSS | 6.7% | Unavailable |
| Shell | 1.5% | Unavailable |

#### Activity

- **Repository creation date:** 2024-02-05
- **Age since repository creation:** 2y 3m 12d
- **First commit date:** 2026-04-21
- **Age since first commit:** ~26 days
- **Most recent commit date:** 2026-05-07
- **Time since last commit:** ~10 days
- **Commit frequency:** 24 (30d) / 24 (90d) / 24 (12m)
- **Open issues:** 0
- **Total contributor count:** 1
- **Total commit count:** 24
- **Commits in last year:** 24
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** 0
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on a recent last commit and 24 commits in the last 30 days.
- **Development velocity heuristic:** **Experimental** — based on single-contributor development, no releases, and moderate but recent commit activity.

#### Stack Detection

- **Detected stack:** TypeScript memory framework with CLI/docs/tooling
- **Observed repo signals:** `AGENTS.md`, `CLAUDE.md`, `.claude.json`, `.codex/`, `cli/`, `docs/`, `skills/`, `tools/`, `01_RUNME.md` to `05_MCP_SETUP.md`, `.env.example`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`package.json` observed in nested CLI, runbooks, `.env.example`)
- **Package publishing:** Not observed
- **Documentation site:** Not observed

#### Documentation

- **README completeness:** Strong
- **Installation instructions:** Yes
- **Quick start:** Yes
- **Contribution guide:** Yes
- **Architecture docs:** Yes
- **API docs:** Not observed
- **Onboarding docs:** Yes (explicit run/how-it-works/setup sequence)
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **8.5/10** — based on structured step-by-step docs, AGENTS/CLAUDE guidance, and clear operational runbooks.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Medium
- **Monorepo complexity:** Low-medium
- **Code navigation difficulty:** Low-medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Weak
- **Agent instruction files:** Strong (`AGENTS.md`, `CLAUDE.md`, `.claude.json`, `.codex/`)
- **Dependency graph complexity heuristic:** Medium
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **High**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Medium**

### lucasastorian/llmwiki

- **Owner / org:** lucasastorian
- **GitHub URL:** https://github.com/lucasastorian/llmwiki
- **Description:** Open Source Implementation of Karpathy's LLM Wiki. Upload documents, connect your Claude account via MCP, and have it write your wiki.
- **Primary topic tags:** mcp, knowledge-base, agents, ai-agents, karpathy

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 910 |
| Forks | 146 |
| Repo Age | 2y 1m 20d |
| Last Commit | 2026-05-13 (~4 days ago) |
| Contributors | 3 |
| Primary Languages | Python, TypeScript, PLpgSQL |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 52.0% | Unavailable |
| TypeScript | 44.9% | Unavailable |
| PLpgSQL | 1.7% | Unavailable |
| CSS | 1.2% | Unavailable |
| Dockerfile | 0.2% | Unavailable |
| HTML | 0.0% | Unavailable |

#### Activity

- **Repository creation date:** 2024-03-27
- **Age since repository creation:** 2y 1m 20d
- **First commit date:** 2026-04-04
- **Age since first commit:** ~1m 13d
- **Most recent commit date:** 2026-05-13
- **Time since last commit:** ~4 days
- **Commit frequency:** 32 (30d) / 91 (90d) / 91 (12m)
- **Open issues:** 8
- **Total contributor count:** 3
- **Total commit count:** 91
- **Commits in last year:** 91
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** 1
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on recent commits and 32 commits in the last 30 days.
- **Development velocity heuristic:** **Rapid iteration** — based on 91 commits in 90 days across multiple components and multiple contributors.

#### Stack Detection

- **Detected stack:** Python, TypeScript, PostgreSQL/Supabase, Docker, MCP, Netlify
- **Observed repo signals:** `api/`, `web/`, `converter/`, `mcp/`, `shared/`, `supabase/`, `.github/workflows/test.yml`, `docker-compose.yml`, `docker-compose.test.yml`, multiple Dockerfiles, `pytest.ini`, `netlify.toml`
- **CI/CD:** Yes
- **Automated testing:** Yes
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Yes
- **Reproducible dev environment:** Partial-strong (compose + Dockerfiles + test workflow)
- **Package publishing:** Not observed
- **Demo app / docs site:** Web app surface observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Not observed in root scan
- **Architecture docs:** Limited
- **API docs:** Limited
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **7.5/10** — based on strong runnable structure and testing/container signals, offset by lighter contributor-facing docs.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium
- **Modularity:** High
- **Monorepo complexity:** High
- **Code navigation difficulty:** Medium-high
- **Build reproducibility:** Good
- **Test reproducibility:** Good
- **Agent instruction files:** No root AGENTS/CLAUDE observed
- **AI-facing surfaces:** MCP component clearly separated
- **Dependency graph complexity heuristic:** High
- **LLM onboarding difficulty heuristic:** **Medium-high**
- **Agent automation friendliness heuristic:** **High**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### Lum1104/Understand-Anything

- **Owner / org:** Lum1104
- **GitHub URL:** https://github.com/Lum1104/Understand-Anything
- **Description:** Turn any code or knowledge base into an interactive knowledge graph you can explore, search, and ask questions about.
- **Primary topic tags:** memory, knowledge-graph, knowledge-base, codex, business-knowledge

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 14,882 |
| Forks | 1,378 |
| Repo Age | 2m 2d |
| Last Commit | 2026-05-13 (~4 days ago) |
| Contributors | 30 |
| Primary Languages | TypeScript, Python, Astro |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| TypeScript | 82.2% | Unavailable |
| Python | 10.3% | Unavailable |
| Astro | 2.9% | Unavailable |
| JavaScript | 2.8% | Unavailable |
| CSS | 0.6% | Unavailable |
| PowerShell | 0.6% | Unavailable |

#### Activity

- **Repository creation date:** 2026-03-15
- **Age since repository creation:** 2m 2d
- **First commit date:** 2026-03-14
- **Age since first commit:** ~2m 3d
- **Most recent commit date:** 2026-05-13
- **Time since last commit:** ~4 days
- **Commit frequency:** 108 (30d) / 480 (90d) / 480 (12m)
- **Open issues:** 13
- **Total contributor count:** 30
- **Total commit count:** 480
- **Commits in last year:** 480
- **Release count:** 6
- **Latest release date:** Unavailable
- **Open pull requests:** 77
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on sustained high recent commit volume and a recent last commit.
- **Development velocity heuristic:** **Rapid iteration** — based on 480 commits in 90 days, 30 contributors, 6 releases, and very high open-PR volume.

#### Stack Detection

- **Detected stack:** TypeScript workspace, Python support, Astro/homepage, plugin ecosystem
- **Observed repo signals:** `package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, `tsconfig.json`, `CLAUDE.md`, `.claude-plugin/`, `.copilot-plugin/`, `.cursor-plugin/`, `.github/workflows/ci.yml`, `.github/workflows/deploy-homepage.yml`, `homepage/`, `understand-anything-plugin/`
- **CI/CD:** Yes
- **Automated testing:** Observed in supplementary workspace scan
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Observed in supplementary workspace scan
- **Reproducible dev environment:** Strong (`pnpm` workspace + scripts + workflow)
- **Package publishing:** Observed in supplementary workspace scan
- **Documentation site / demo app:** Yes (`homepage/`)
- **Benchmarks:** Observed in supplementary workspace scan

#### Documentation

- **README completeness:** Strong
- **Installation instructions:** Yes
- **Quick start:** Yes
- **Contribution guide:** Yes
- **Architecture docs:** Yes
- **API docs:** Yes
- **Onboarding docs:** Partial
- **Examples / tutorials:** Partial
- **Onboarding friendliness heuristic:** **8.5/10** — based on broad docs surface, contributor docs, plugin docs, and clear workspace layout.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** High
- **Monorepo complexity:** High
- **Code navigation difficulty:** Medium-high
- **Build reproducibility:** Strong
- **Test reproducibility:** Good
- **Agent instruction files:** Strong (`CLAUDE.md`, Copilot/Cursor/Claude plugin dirs)
- **Generated code:** Not reliably retrievable
- **Dependency graph complexity heuristic:** High
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Excellent**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### MehmetGoekce/llm-wiki

- **Owner / org:** MehmetGoekce
- **GitHub URL:** https://github.com/MehmetGoekce/llm-wiki
- **Description:** Build Karpathy's LLM Wiki with Claude Code. L1/L2 cache architecture. Logseq + Obsidian support.
- **Primary topic tags:** productivity, ai, wiki, developer-tools, obsidian

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 88 |
| Forks | 11 |
| Repo Age | Unavailable |
| Last Commit | 2026-04-18 (~29 days ago) |
| Contributors | 2 |
| Primary Languages | Shell, Mermaid |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Shell | 89.5% | Unavailable |
| Mermaid | 10.5% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-08
- **Age since first commit:** ~1m 9d
- **Most recent commit date:** 2026-04-18
- **Time since last commit:** ~29 days
- **Commit frequency:** 1 (30d) / 14 (90d) / 14 (12m)
- **Open issues:** 0
- **Total contributor count:** 2
- **Total commit count:** 14
- **Commits in last year:** 14
- **Release count:** 2
- **Latest release date:** Unavailable
- **Open pull requests:** 0
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Low activity** — based on only 1 commit in the last 30 days and nearly a month since the last commit.
- **Development velocity heuristic:** **Maintenance-only** — based on low recent commit volume, 2 releases, and small contributor pool.

#### Stack Detection

- **Detected stack:** Shell, Mermaid, documentation/template repo
- **Observed repo signals:** `CHANGELOG.md`, `CONTRIBUTING.md`, `config.example.yml`, `diagrams/`, `docs/`, `examples/`, `openspec/`, `templates/`, `setup.sh`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`setup.sh`, config template)
- **Package publishing:** Not observed
- **Examples:** Yes
- **Architectural diagrams:** Yes

#### Documentation

- **README completeness:** Strong
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Yes (diagrams + docs)
- **API docs:** Not observed
- **Onboarding docs:** Partial
- **Examples / tutorials:** Yes
- **Onboarding friendliness heuristic:** **8.0/10** — based on diagrams, examples, docs, setup script, and contribution guide.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low-medium
- **Monorepo complexity:** None
- **Code navigation difficulty:** Low
- **Build reproducibility:** Partial
- **Test reproducibility:** Weak
- **Agent instruction files:** No root CLAUDE/AGENTS observed in root listing
- **Dependency graph complexity heuristic:** Low
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Moderate**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Low**

### NicholasSpisak/second-brain

- **Owner / org:** NicholasSpisak
- **GitHub URL:** https://github.com/NicholasSpisak/second-brain
- **Description:** LLM-maintained personal knowledge base for Obsidian. Based on Andrej Karpathy's LLM Wiki pattern.
- **Primary topic tags:** markdown, ai, knowledge-base, obsidian, personal-wiki

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 324 |
| Forks | 57 |
| Repo Age | 2y 1m 16d |
| Last Commit | 2026-04-06 (~1m 11d ago) |
| Contributors | 1 |
| Primary Languages | Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Shell | 100.0% | Unavailable |

#### Activity

- **Repository creation date:** 2024-03-31
- **Age since repository creation:** 2y 1m 16d
- **First commit date:** 2026-04-06
- **Age since first commit:** ~1m 11d
- **Most recent commit date:** 2026-04-06
- **Time since last commit:** ~1m 11d
- **Commit frequency:** 0 (30d) / 7 (90d) / 7 (12m)
- **Open issues:** 1
- **Total contributor count:** 1
- **Total commit count:** 7
- **Commits in last year:** 7
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** 3
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Dormant** — based on no commits in the last 30 days and no observed activity since early April.
- **Development velocity heuristic:** **Experimental** — based on single-contributor, very small commit history, and no releases.

#### Stack Detection

- **Detected stack:** Minimal Obsidian/skills template
- **Observed repo signals:** `README.md`, `docs/`, `skills/`, `tests/`
- **CI/CD:** No workflow file observed
- **Automated testing:** Limited (`tests/` directory only)
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Weak
- **Package publishing:** Not observed

#### Documentation

- **README completeness:** Moderate
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Not observed
- **Architecture docs:** Not observed
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **4.5/10** — based on a readable but minimal repo without strong operational or contributor guidance.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low
- **Monorepo complexity:** None
- **Code navigation difficulty:** Low
- **Build reproducibility:** Weak
- **Test reproducibility:** Weak
- **Agent instruction files:** None observed
- **Dependency graph complexity heuristic:** Low
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Limited**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Low**

### nvk/llm-wiki

- **Owner / org:** nvk
- **GitHub URL:** https://github.com/nvk/llm-wiki
- **Description:** LLM-compiled knowledge bases for any AI agent. Parallel multi-agent research, thesis-driven investigation, source ingestion, wiki compilation, querying, and artifact generation.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 426 |
| Forks | 56 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-14 (~3 days ago) |
| Contributors | 4 |
| Primary Languages | Shell, Python, JavaScript |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Shell | 51.7% | Unavailable |
| Python | 45.7% | Unavailable |
| JavaScript | 2.6% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-04
- **Age since first commit:** ~1m 13d
- **Most recent commit date:** 2026-05-14
- **Time since last commit:** ~3 days
- **Commit frequency:** 79 (30d) / 180 (90d) / 180 (12m)
- **Open issues:** Unavailable
- **Total contributor count:** 4
- **Total commit count:** 180
- **Commits in last year:** 180
- **Release count:** 41
- **Latest release date:** Unavailable
- **Open pull requests:** 3
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on recent commits and 79 commits in the last 30 days.
- **Development velocity heuristic:** **Stable maintenance** — based on 41 releases, multiple contributors, and sustained recent commit activity.

#### Stack Detection

- **Detected stack:** Shell, Python, JavaScript, multi-agent wiki compiler
- **Observed repo signals:** `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.claude/`, `.claude-plugin/`, `claude-plugin/`, `plugins/`, `scripts/`, `tests/`
- **CI/CD:** No workflow file observed
- **Automated testing:** Limited (`tests/`)
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial
- **Package publishing:** Not observed
- **Documentation site:** Not observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Not observed
- **Architecture docs:** Limited
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **6.5/10** — based on strong agent docs and plugin structure, but lighter conventional onboarding materials.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** High
- **Monorepo complexity:** Medium
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Partial
- **Agent instruction files:** Strong (`AGENTS.md`, `CLAUDE.md`, plugin dirs)
- **Dependency graph complexity heuristic:** Medium-high
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Excellent**
- **Context compression suitability heuristic:** **Medium-high**
- **Satellite-module feasibility heuristic:** **High**

### rohitg00/agentmemory

- **Owner / org:** rohitg00
- **GitHub URL:** https://github.com/rohitg00/agentmemory
- **Description:** Persistent memory for AI coding agents based on real-world benchmarks.
- **Primary topic tags:** ai, memory, cursor, hermes, copilot

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 10,736 |
| Forks | 907 |
| Repo Age | 2m 20d |
| Last Commit | 2026-05-16 (~1 day ago) |
| Contributors | 24 |
| Primary Languages | TypeScript, HTML, JavaScript |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| TypeScript | 81.1% | Unavailable |
| HTML | 8.1% | Unavailable |
| JavaScript | 8.0% | Unavailable |
| CSS | 1.5% | Unavailable |
| Python | 0.6% | Unavailable |
| Shell | 0.5% | Unavailable |
| Dockerfile | 0.2% | Unavailable |

#### Activity

- **Repository creation date:** 2026-02-25
- **Age since repository creation:** 2m 20d
- **First commit date:** 2026-02-27
- **Age since first commit:** ~2m 18d
- **Most recent commit date:** 2026-05-16
- **Time since last commit:** ~1 day
- **Commit frequency:** 123 (30d) / 278 (90d) / 278 (12m)
- **Open issues:** 28
- **Total contributor count:** 24
- **Total commit count:** 278
- **Commits in last year:** 278
- **Release count:** 39
- **Latest release date:** Unavailable
- **Open pull requests:** Unavailable
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on recent commits and 123 commits in the last 30 days.
- **Development velocity heuristic:** **Rapid iteration** — based on 278 commits in 90 days, 24 contributors, and 39 releases.

#### Stack Detection

- **Detected stack:** TypeScript monorepo, website, packages, plugin/integrations, Docker
- **Observed repo signals:** `AGENTS.md`, `DESIGN.md`, `GOVERNANCE.md`, `ROADMAP.md`, `SECURITY.md`, `MAINTAINERS.md`, `benchmark/`, `test/`, `packages/`, `website/`, `integrations/`, `plugin/`, `docker-compose.yml`, `.github/workflows/ci.yml`, `.github/workflows/publish.yml`
- **CI/CD:** Yes
- **Automated testing:** Partial-direct (test dir observed; exact test coverage not fully retrievable)
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Yes
- **Reproducible dev environment:** Strong
- **Package publishing:** Yes (publish workflow)
- **Documentation site / demo app:** Yes (`website/`)
- **Benchmarks:** Yes (`benchmark/`)

#### Documentation

- **README completeness:** Strong
- **Installation instructions:** Yes
- **Quick start:** Yes
- **Contribution guide:** Yes
- **Architecture docs:** Yes (`DESIGN.md`)
- **API docs:** Limited
- **Onboarding docs:** Partial
- **Examples / tutorials:** Partial
- **Onboarding friendliness heuristic:** **8.0/10** — based on very broad governance/architecture docs and strong operational structure, offset by high repo complexity.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** Very high
- **Monorepo complexity:** Very high
- **Code navigation difficulty:** Medium-high
- **Build reproducibility:** Strong
- **Test reproducibility:** Partial-good
- **Agent instruction files:** Strong (`AGENTS.md`, integrations, plugin surfaces)
- **Generated code:** Not reliably retrievable
- **Dependency graph complexity heuristic:** Very high
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Excellent**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **Excellent**

### sametbrr/llm-wiki-manager

- **Owner / org:** sametbrr
- **GitHub URL:** https://github.com/sametbrr/llm-wiki-manager
- **Description:** GitHub description not meaningfully set; repository page exposed the default “Contribute to … development” text.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 7 |
| Forks | 2 |
| Repo Age | 2y 28d |
| Last Commit | 2026-05-07 (~10 days ago) |
| Contributors | 1 |
| Primary Languages | Python, Go Template |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 74.5% | Unavailable |
| Go Template | 25.5% | Unavailable |

#### Activity

- **Repository creation date:** 2024-04-19
- **Age since repository creation:** 2y 28d
- **First commit date:** 2026-05-07
- **Age since first commit:** ~10 days
- **Most recent commit date:** 2026-05-07
- **Time since last commit:** ~10 days
- **Commit frequency:** 5 (30d) / 5 (90d) / 5 (12m)
- **Open issues:** 7
- **Total contributor count:** 1
- **Total commit count:** 5
- **Commits in last year:** 5
- **Release count:** 2
- **Latest release date:** Unavailable
- **Open pull requests:** 4
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Low activity** — based on only 5 commits in the last 30 days and no observed activity after initial burst.
- **Development velocity heuristic:** **Experimental** — based on 1 contributor, 5 total commits, and sparse structure.

#### Stack Detection

- **Detected stack:** Small Python/template manager repo
- **Observed repo signals:** `README.md`, `SKILL.md`, `assets/`, `references/`, `scripts/`, `CLAUDE.md`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Weak
- **Package publishing:** Not observed

#### Documentation

- **README completeness:** Basic
- **Installation instructions:** Limited
- **Quick start:** Limited
- **Contribution guide:** Not observed
- **Architecture docs:** Limited
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **4.0/10** — based on a sparse documentation and operational surface.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low
- **Monorepo complexity:** None
- **Code navigation difficulty:** Low
- **Build reproducibility:** Weak
- **Test reproducibility:** Weak
- **Agent instruction files:** `CLAUDE.md`, `SKILL.md`
- **Dependency graph complexity heuristic:** Low
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Limited**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Low**

### skyllwt/OmegaWiki

- **Owner / org:** skyllwt
- **GitHub URL:** https://github.com/skyllwt/OmegaWiki
- **Description:** Karpathy's LLM-Wiki vision, fully realized — wiki-centric full-lifecycle AI research platform powered by Claude Code.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 672 |
| Forks | 102 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-17 (<1 day ago) |
| Contributors | 4 |
| Primary Languages | Python, JavaScript, CSS |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 79.5% | Unavailable |
| JavaScript | 13.6% | Unavailable |
| CSS | 3.6% | Unavailable |
| PowerShell | 1.5% | Unavailable |
| Shell | 1.4% | Unavailable |
| Go Template | 0.2% | Unavailable |
| HTML | 0.2% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-09
- **Age since first commit:** ~1m 8d
- **Most recent commit date:** 2026-05-17
- **Time since last commit:** <1 day
- **Commit frequency:** 32 (30d) / 67 (90d) / 67 (12m)
- **Open issues:** N/A
- **Total contributor count:** 4
- **Total commit count:** 67
- **Commits in last year:** 67
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on same-day last commit and steady recent commit flow.
- **Development velocity heuristic:** **Rapid iteration** — based on 67 commits in 90 days, 4 contributors, and broad app/tooling footprint.

#### Stack Detection

- **Detected stack:** Python app, JavaScript/CSS frontend assets, MCP servers, Claude-oriented tooling
- **Observed repo signals:** `.mcp.json`, `.claude/`, `CLAUDE.md`, `app/`, `config/`, `docs/`, `i18n/`, `mcp-servers/`, `runtime/`, `tools/`, `requirements.txt`, `setup.sh`, `setup.ps1`, `.github/workflows/daily-arxiv.yml`
- **CI/CD:** Yes (scheduled workflow observed)
- **Automated testing:** Not observed
- **Linting / formatter:** Not reliably retrievable
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial (`requirements.txt`, setup scripts)
- **Package publishing:** Not observed
- **Demo app:** App surface observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Yes
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **7.8/10** — based on docs, setup scripts, architecture materials, and clear app/tool split.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** High
- **Monorepo complexity:** Medium-high
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Weak
- **Agent instruction files:** Strong (`CLAUDE.md`, `.claude/`, `.mcp.json`)
- **Dependency graph complexity heuristic:** High
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Strong**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### Ss1024sS/LLM-wiki

- **Owner / org:** Ss1024sS
- **GitHub URL:** https://github.com/Ss1024sS/LLM-wiki
- **Description:** Based on Karpathy’s LLM Wiki pattern.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 101 |
| Forks | 24 |
| Repo Age | Unavailable |
| Last Commit | 2026-04-20 (~27 days ago) |
| Contributors | 2 |
| Primary Languages | Python, Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Python | 98.7% | Unavailable |
| Shell | 1.3% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-06
- **Age since first commit:** ~1m 11d
- **Most recent commit date:** 2026-04-20
- **Time since last commit:** ~27 days
- **Commit frequency:** 11 (30d) / 40 (90d) / 40 (12m)
- **Open issues:** N/A
- **Total contributor count:** 2
- **Total commit count:** 40
- **Commits in last year:** 40
- **Release count:** 5
- **Latest release date:** Unavailable
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Low activity** — based on last commit almost a month ago despite some recent 30-day commit volume.
- **Development velocity heuristic:** **Maintenance-only** — based on 5 releases, 2 contributors, but limited recent momentum.

#### Stack Detection

- **Detected stack:** Python-centric wiki template with Claude plugin support
- **Observed repo signals:** `.claude-plugin/`, `.github/workflows/wiki-lint.yml`, `commands/`, `docs/`, `examples/`, `scripts/`, `skills/`, `tests/`, `UNIVERSAL.md`, `SECURITY.md`
- **CI/CD:** Yes
- **Automated testing:** Partial (`tests/`)
- **Linting / formatter:** Partial (wiki-lint workflow)
- **Containerization:** Not observed
- **Reproducible dev environment:** Partial
- **Package publishing:** Not observed
- **Examples:** Yes

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Limited
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Yes
- **Onboarding friendliness heuristic:** **7.0/10** — based on CONTRIBUTING, examples, tests, and workflow support.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** Medium
- **Monorepo complexity:** Low-medium
- **Code navigation difficulty:** Low-medium
- **Build reproducibility:** Partial
- **Test reproducibility:** Partial
- **Agent instruction files:** Claude plugin support observed
- **Dependency graph complexity heuristic:** Medium
- **LLM onboarding difficulty heuristic:** **Low-medium**
- **Agent automation friendliness heuristic:** **Good**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Medium**

### swarmclawai/swarmvault

- **Owner / org:** swarmclawai
- **GitHub URL:** https://github.com/swarmclawai/swarmvault
- **Description:** Local-first LLM Wiki, knowledge graph builder, RAG-alternative knowledge base, and agent memory store.
- **Primary topic tags:** wiki, mcp, opencode, knowledge-graph, obsidian

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 456 |
| Forks | 52 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-11 (~6 days ago) |
| Contributors | 2 |
| Primary Languages | TypeScript, JavaScript, CSS |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| TypeScript | 86.0% | Unavailable |
| JavaScript | 12.5% | Unavailable |
| CSS | 1.4% | Unavailable |
| Shell | 0.1% | Unavailable |
| HTML | 0.0% | Unavailable |
| Dart | 0.0% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-06
- **Age since first commit:** ~1m 11d
- **Most recent commit date:** 2026-05-11
- **Time since last commit:** ~6 days
- **Commit frequency:** 33 (30d) / 181 (90d) / 181 (12m)
- **Open issues:** N/A
- **Total contributor count:** 2
- **Total commit count:** 181
- **Commits in last year:** 181
- **Release count:** 75
- **Latest release date:** Unavailable
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on recent last commit and 33 commits in the last 30 days.
- **Development velocity heuristic:** **Stable maintenance** — based on 75 releases, consistent recent commits, and validation/smoke infrastructure.

#### Stack Detection

- **Detected stack:** TypeScript workspace, packages, Obsidian plugin, CLI/engine split
- **Observed repo signals:** `package.json`, `pnpm-workspace.yaml`, `biome.json`, `lefthook.yml`, `manifest.json`, `packages/`, `skills/`, `smoke/`, `templates/`, `validation/`, `.github/workflows/ci.yml`, `.github/workflows/live-smoke.yml`
- **CI/CD:** Yes
- **Automated testing:** Yes (smoke + validation)
- **Linting / formatter:** Yes (`biome.json`)
- **Containerization:** Not observed
- **Reproducible dev environment:** Strong (`pnpm` workspace + CI)
- **Package publishing:** Likely yes from manifest/workspace signals; not fully verified
- **Documentation site:** Not observed
- **Examples / demo apps:** Templates and worked examples observed

#### Documentation

- **README completeness:** Good
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Yes
- **Architecture docs:** Partial (`SCALE.md`, `STABILITY.md`)
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Partial
- **Onboarding friendliness heuristic:** **7.5/10** — based on CI, validation, multilingual docs, and strong operational layout.

#### AI/Agent Assessment

- **Repository structure clarity:** Medium-high
- **Modularity:** High
- **Monorepo complexity:** High
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Strong
- **Test reproducibility:** Strong
- **Agent instruction files:** No root AGENTS/CLAUDE observed
- **Dependency graph complexity heuristic:** High
- **LLM onboarding difficulty heuristic:** **Medium**
- **Agent automation friendliness heuristic:** **Strong**
- **Context compression suitability heuristic:** **Medium**
- **Satellite-module feasibility heuristic:** **High**

### ussumant/llm-wiki-compiler

- **Owner / org:** ussumant
- **GitHub URL:** https://github.com/ussumant/llm-wiki-compiler
- **Description:** Claude Code plugin that compiles markdown knowledge files into a topic-based wiki.
- **Primary topic tags:** Unavailable

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 261 |
| Forks | 24 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-05 (~12 days ago) |
| Contributors | 2 |
| Primary Languages | HTML, JavaScript, Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| HTML | 58.1% | Unavailable |
| JavaScript | 26.1% | Unavailable |
| Shell | 15.8% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-04
- **Age since first commit:** ~1m 13d
- **Most recent commit date:** 2026-05-05
- **Time since last commit:** ~12 days
- **Commit frequency:** 1 (30d) / 30 (90d) / 30 (12m)
- **Open issues:** N/A
- **Total contributor count:** 2
- **Total commit count:** 30
- **Commits in last year:** 30
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Low activity** — based on 1 commit in the last 30 days and no commits in the last ~12 days.
- **Development velocity heuristic:** **Experimental** — based on small contributor pool, no releases, and plugin-centered scope.

#### Stack Detection

- **Detected stack:** HTML/JavaScript plugin, shell installer
- **Observed repo signals:** `.agents/`, `.claude-plugin/`, `plugin/`, `assets/`, `README.md`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Weak
- **Package publishing:** Not observed

#### Documentation

- **README completeness:** Moderate
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Not observed
- **Architecture docs:** Not observed
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Limited
- **Onboarding friendliness heuristic:** **5.0/10** — based on a readable README and plugin structure, but little operational/testing material.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low-medium
- **Monorepo complexity:** Low
- **Code navigation difficulty:** Low
- **Build reproducibility:** Weak
- **Test reproducibility:** Weak
- **Agent instruction files:** `.agents/`, `.claude-plugin/`
- **Dependency graph complexity heuristic:** Low-medium
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Moderate**
- **Context compression suitability heuristic:** **High**
- **Satellite-module feasibility heuristic:** **Medium**

### yologdev/karpathy-llm-wiki

- **Owner / org:** yologdev
- **GitHub URL:** https://github.com/yologdev/karpathy-llm-wiki
- **Description:** The self-growing Karpathy LLM Wiki, grown by an AI agent “yoyo”; metadata also surfaces the name `yologdev/yopedia`.
- **Primary topic tags:** wiki, knowledge-base, karpathy, ai-agent, llm

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 56 |
| Forks | 8 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-16 (~1 day ago) |
| Contributors | 3 |
| Primary Languages | TypeScript, JavaScript |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| TypeScript | 97.1% | Unavailable |
| JavaScript | 2.2% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-06
- **Age since first commit:** ~1m 11d
- **Most recent commit date:** 2026-05-16
- **Time since last commit:** ~1 day
- **Commit frequency:** 368 (30d) / 747 (90d) / 747 (12m)
- **Open issues:** N/A
- **Total contributor count:** 3
- **Total commit count:** 747
- **Commits in last year:** 747
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on recent commits and extremely high recent commit volume.
- **Development velocity heuristic:** **Rapid iteration** — based on 747 commits in 90 days and a full application/workflow surface despite no verified release count.

#### Stack Detection

- **Detected stack:** Next.js / TypeScript app, Docker, Vitest, ESLint, MCP, wiki lifecycle engine
- **Observed repo signals:** `Dockerfile`, `docker-compose.yml`, `package.json`, `pnpm-lock.yaml`, `next.config.ts`, `tailwind.config.ts`, `vitest.config.ts`, `eslint.config.mjs`, `mcp.json`, `.yoyo/`, `SCHEMA.md`, `DEPLOY.md`, `.github/workflows/build.yml` plus multiple role workflows, `ONBOARDING.md`, `OnboardingReport.md`
- **CI/CD:** Yes
- **Automated testing:** Yes (Vitest config observed)
- **Linting / formatter:** Yes (ESLint config observed)
- **Containerization:** Yes
- **Reproducible dev environment:** Strong
- **Package publishing:** Not observed
- **Documentation site / demo app:** Yes (web app)

#### Documentation

- **README completeness:** Strong
- **Installation instructions:** Yes
- **Quick start:** Partial
- **Contribution guide:** Not observed
- **Architecture docs:** Strong (`ONBOARDING.md`, `SCHEMA.md`, concept docs)
- **API docs:** Partial via route references in onboarding doc
- **Onboarding docs:** Yes
- **Examples / tutorials:** Partial
- **Onboarding friendliness heuristic:** **9.5/10** — based on explicit onboarding reports, architecture guidance, deploy docs, workflows, and strong config visibility.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** High
- **Monorepo complexity:** Medium-high
- **Code navigation difficulty:** Medium
- **Build reproducibility:** Strong
- **Test reproducibility:** Good
- **Agent instruction files:** `.yoyo/`, `mcp.json`, onboarding report
- **Generated code:** Not reliably retrievable
- **Dependency graph complexity heuristic:** High
- **LLM onboarding difficulty heuristic:** **Low-medium**
- **Agent automation friendliness heuristic:** **Excellent**
- **Context compression suitability heuristic:** **Good**
- **Satellite-module feasibility heuristic:** **Excellent**

### zhurudong/andrej-karpathy-llm-wiki

- **Owner / org:** zhurudong
- **GitHub URL:** https://github.com/zhurudong/andrej-karpathy-llm-wiki
- **Description:** A minimal `CLAUDE.md` template that turns any LLM CLI into a personal knowledge base.
- **Primary topic tags:** wiki, knowledge-base, obsidian, pkm, ai-agents

#### Summary

| Metric | Value |
| --- | --- |
| Stars | 12 |
| Forks | 2 |
| Repo Age | Unavailable |
| Last Commit | 2026-05-13 (~4 days ago) |
| Contributors | 2 |
| Primary Languages | Shell |

#### Languages

| Language | Fraction | Bytes |
| --- | --- | --- |
| Shell | 100.0% | Unavailable |

#### Activity

- **Repository creation date:** Unavailable
- **Age since repository creation:** Unavailable
- **First commit date:** 2026-04-24
- **Age since first commit:** ~23 days
- **Most recent commit date:** 2026-05-13
- **Time since last commit:** ~4 days
- **Commit frequency:** 10 (30d) / 10 (90d) / 10 (12m)
- **Open issues:** N/A
- **Total contributor count:** 2
- **Total commit count:** 10
- **Commits in last year:** 10
- **Release count:** 0
- **Latest release date:** N/A
- **Open pull requests:** N/A
- **Merged PRs in last 90 days:** Not reliably retrievable
- **Activity heuristic:** **Active** — based on a recent last commit and 10 commits in the last 30 days.
- **Development velocity heuristic:** **Experimental** — based on small team size, small total commit count, and no releases.

#### Stack Detection

- **Detected stack:** Minimal shell/template repo
- **Observed repo signals:** `CLAUDE.md`, `README.md`, `README.zh-CN.md`, `examples/`, `install.sh`, `templates/`
- **CI/CD:** No workflow file observed
- **Automated testing:** Not observed
- **Linting / formatter:** Not observed
- **Containerization:** Not observed
- **Reproducible dev environment:** Weak-partial (`install.sh`)
- **Package publishing:** Not observed

#### Documentation

- **README completeness:** Moderate
- **Installation instructions:** Partial
- **Quick start:** Partial
- **Contribution guide:** Not observed
- **Architecture docs:** Limited
- **API docs:** Not observed
- **Onboarding docs:** Limited
- **Examples / tutorials:** Yes
- **Onboarding friendliness heuristic:** **5.0/10** — based on bilingual docs and examples, but small operational/documentation footprint.

#### AI/Agent Assessment

- **Repository structure clarity:** High
- **Modularity:** Low
- **Monorepo complexity:** None
- **Code navigation difficulty:** Low
- **Build reproducibility:** Weak-partial
- **Test reproducibility:** Weak
- **Agent instruction files:** `CLAUDE.md`
- **Dependency graph complexity heuristic:** Low
- **LLM onboarding difficulty heuristic:** **Low**
- **Agent automation friendliness heuristic:** **Moderate**
- **Context compression suitability heuristic:** **Very high**
- **Satellite-module feasibility heuristic:** **Low**

## Final Cross-Repository Comparative Analysis and Conclusions

- **Popularity leaders:** `Lum1104/Understand-Anything` and `rohitg00/agentmemory` are clear outliers in adoption; both pair large community interest with broad multi-client agent support.
- **Most active builders:** `yologdev/karpathy-llm-wiki`, `rohitg00/agentmemory`, `Lum1104/Understand-Anything`, `axoviq-ai/synthadoc`, `nvk/llm-wiki`, and `Ar9av/obsidian-wiki` show the strongest recent build velocity.
- **Most maintenance-mature repos:** `swarmclawai/swarmvault`, `nvk/llm-wiki`, and `rohitg00/agentmemory` show the strongest maintenance signals from release cadence plus active development.
- **Best onboarding surfaces:** `yologdev/karpathy-llm-wiki`, `Lum1104/Understand-Anything`, `jp-carrilloe/pulseOS-lite`, `rohitg00/agentmemory`, and `axoviq-ai/synthadoc` have the best combination of README depth, setup material, architecture cues, and operational structure.
- **Most complex implementations:** `rohitg00/agentmemory`, `Lum1104/Understand-Anything`, `lucasastorian/llmwiki`, `yologdev/karpathy-llm-wiki`, `swarmclawai/swarmvault`, and `skyllwt/OmegaWiki` are better treated as **systems**, not simple template repos.
- **Best AI-agent suitability:** `rohitg00/agentmemory`, `Lum1104/Understand-Anything`, `Ar9av/obsidian-wiki`, `yologdev/karpathy-llm-wiki`, and `nvk/llm-wiki` are the strongest candidates for automated agent workflows because they expose clear agent-specific contracts, instructions, or modular surfaces.
- **Template-like/lightweight repos:** `Astro-Han/karpathy-llm-wiki`, `MehmetGoekce/llm-wiki`, `NicholasSpisak/second-brain`, `ussumant/llm-wiki-compiler`, and `zhurudong/andrej-karpathy-llm-wiki` are easier to comprehend quickly, but generally provide less operational rigor.
- **Dormancy risk:** `Astro-Han/karpathy-llm-wiki` and `NicholasSpisak/second-brain` currently show the clearest dormancy signal from recency and 30-day activity.
- **Strong niche repos that outperform their star count operationally:** `gowtham0992/link`, `jp-carrilloe/pulseOS-lite`, and `axoviq-ai/synthadoc`.
- **Overall conclusion:** The repository set has split into three clusters:
  1. **Full products / systems** — e.g. `agentmemory`, `Understand-Anything`, `llmwiki`, `yologdev`, `swarmvault`, `OmegaWiki`.
  2. **Operational frameworks for agent-maintained memory/wikis** — e.g. `Ar9av`, `nvk`, `gowtham0992`, `jp-carrilloe`, `axoviq-ai`.
  3. **Lightweight templates / reference implementations** — e.g. `Astro-Han`, `MehmetGoekce`, `NicholasSpisak`, `zhurudong`.
- **Best “start here” choices by need:**
  - **For production-grade agent memory:** `rohitg00/agentmemory`
  - **For interactive knowledge graph UX:** `Lum1104/Understand-Anything`
  - **For agent-first wiki framework:** `Ar9av/obsidian-wiki`
  - **For deeply documented app architecture:** `yologdev/karpathy-llm-wiki`
  - **For release-disciplined local-first wiki tooling:** `swarmclawai/swarmvault`
