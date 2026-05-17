---
description: Collects GitHub metrics for provided repository list and generates comparison table.
url: https://chatgpt.com/c/6a093ba3-78f4-83eb-b88a-f5499d412a99
---

# GitHub Repository Metrics Collection

For each GitHub repository in the provided list, collect and report the following metadata and derived statistics.

The repository list may contain:

* full GitHub URLs;
* `OWNER/REPO` identifiers;
* local git remotes resolvable to GitHub repositories;
* pre-extracted metadata, which may not be readily available via API.

Use GitHub API data where possible. Use git history analysis only when necessary.

If pre-extracted metadata, prior analysis results, repository annotations, onboarding reports, or any other repository-related information are directly provided in the prompt or workspace context, the agent MUST still perform a full independent online and/or repository-level analysis whenever possible.

Prompt-provided metadata MUST be treated as supplementary context rather than a substitute for retrieval and verification.

The final report MUST combine:

- retrieved live repository data;
- repository inspection results;
- git history analysis;
- and any supplied pre-extracted metadata

into a unified final analysis.

When prompt-provided metadata conflicts with retrieved repository data, the report MUST:

- explicitly identify the conflict;
- prefer authoritative or directly retrievable sources where possible;
- and avoid silently collapsing discrepancies into a single asserted fact.

The presence of pre-supplied metadata MUST NOT reduce the scope, depth, rigor, or independence of the repository analysis.

---

## Data Integrity and Anti-BS Requirements

Every factual statistic, repository attribute, metadata field, timestamp, count, language fraction, activity signal, and derived input MUST be grounded in actually retrieved information.

Acceptable grounding sources include:

- GitHub API responses;
- GitHub CLI/API output;
- local `git` history inspection;
- directly inspected repository files;
- pre-extracted metadata explicitly provided in the repository list;
- tool output generated during the run.

The agent MUST NOT fabricate, guess, interpolate, or silently infer factual statistics.

If any item for any repository is unavailable, inaccessible, ambiguous, rate-limited, unsupported by the available tools, or cannot be reliably retrieved, the report MUST clearly indicate this with one of:

- `N/A`
- `Unknown`
- `Unavailable`
- `Not reliably retrievable`

Missing or unavailable data MUST NEVER be replaced with:

- guessed values;
- placeholder numbers;
- optimistic assumptions;
- or implied certainty.

When heuristics are used, the report MUST:

- identify them as heuristics;
- briefly describe the basis used;
- and avoid overstating confidence.

Any heuristic classification MUST identify the factual signals used as its basis. For example:

- `Dormancy heuristic: inferred from last commit date and commit frequency`
- `Bus factor heuristic: inferred from contributor concentration`
- `Onboarding friendliness heuristic: inferred from README, setup docs, tests, CI, and examples`

If the required factual basis for a heuristic is unavailable, the heuristic result MUST be reported as `N/A` or `Not reliably retrievable`.

The final report MUST prioritize correctness, traceability, and explicit missing-data handling over completeness.

---

## Required Metrics

### Repository Identity

* repository name
* owner / organization
* GitHub URL
* description
* primary topic tags

---

### Popularity and Adoption

* star count
* fork count
* open issue count

---

### Temporal Activity

* repository creation date
* age since repository creation
* date of first commit
* age since first commit
* date of most recent commit
* time since last commit
* commit frequency over:
    * last 30 days
    * last 90 days
    * last 12 months

Derived heuristics:

* active
* low activity
* dormant
* abandoned

---

### Contributor Activity

* total contributor count

---

### Development Velocity

* total commit count
* commits in last year
* release count
* latest release date
* open pull request count
* merged pull requests in last 90 days

Derived heuristics:

* rapid iteration
* stable maintenance
* maintenance-only
* experimental

---

### Codebase Characteristics

Collect GitHub-reported language breakdown sorted by descending percentage.

For each language:

* language name
* percentage
* byte count if available

---

### Technology Stack Detection

Infer major technologies/frameworks/platforms from repository contents.

Examples:

* Python
* C++
* Rust
* TypeScript
* Electron
* React
* FastAPI
* PyTorch
* CUDA
* SQLite
* Docker
* Kubernetes

Detect from:

* package manifests
* lock files
* CI configs
* Dockerfiles
* build systems
* dependency manifests

---

### Project Operational Signals

Detect presence of:

* CI/CD
* automated testing
* linting
* formatter configuration
* containerization
* reproducible development environment
* package publishing
* documentation site
* benchmarks
* examples
* demo applications

---

### Documentation Quality

Check for:

* README completeness
* installation instructions
* quick start
* contribution guide
* architecture documentation
* API documentation
* onboarding documentation
* examples/tutorials

Derived heuristic:

* onboarding friendliness score

---

### AI/Agent Friendliness

Detect:

* repository structure clarity
* modularity
* monorepo complexity
* presence of generated code
* code navigation difficulty
* build reproducibility
* test reproducibility
* deterministic setup quality
* existence of AGENTS.md / CLAUDE.md / Cursor rules / Copilot instructions
* existence of onboarding reports
* presence of architectural diagrams
* dependency graph complexity heuristic

Derived heuristics:

* LLM onboarding difficulty
* agent automation friendliness
* context compression suitability
* satellite-module feasibility heuristic

---

## Output Requirements

Generate a structured report in Markdown.

### Output File Requirement

The final report MUST be written to:

```text
implementations/GitHubStats.md
```

relative to the active workspace root directory.

The file MUST be fully overwritten on each run.

Do NOT print the full report to stdout unless explicitly requested. Instead:

- write the complete report to `GitHubStats.md`;
- print only:
    - processing progress;
    - warnings/errors;
    - and a concise completion summary.

The generated `GitHubStats.md` MUST be fully self-contained and include:

- per-repository analysis;
- comparative tables;
- derived heuristics;
- and final cross-repository conclusions.

### Individual Repository Information

For each repository include:

```markdown
## OWNER/REPO

### Summary

| Metric            | Value |
| ----------------- | ----- |
| Stars             |       |
| Forks             |       |
| Repo Age          |       |
| Last Commit       |       |
| Contributors      |       |
| Primary Languages |       |

### Languages

| Language | Fraction |
| -------- | -------- |

### Activity

...

### Stack Detection

...

### Documentation

...

### AI/Agent Assessment

...
```

At the end, generate comparative analysis.

### Cross-Repository Comparative Tables

Including:

* popularity ranking
* activity ranking
* maintenance ranking
* onboarding friendliness ranking
* implementation complexity ranking
* AI-agent suitability ranking

---
