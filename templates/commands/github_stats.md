---
description: Collects GitHub metrics for provided repository list and generates comparison table.
url: https://chatgpt.com/c/6a093ba3-78f4-83eb-b88a-f5499d412a99
---

# GitHub Repository Metrics Collection

For each GitHub repository in the provided list, collect and report the following metadata and derived statistics.

The repository list may contain:

* full GitHub URLs;
* `OWNER/REPO` identifiers;
* local git remotes resolvable to GitHub repositories.

Use GitHub API data where possible. Use git history analysis only when necessary.

---

## Required Metrics

### Repository Identity

* repository name
* owner / organization
* GitHub URL
* description
* primary topic tags
* license
* default branch
* archived status
* fork status (whether this repo itself is a fork)

---

### Popularity and Adoption

* star count
* fork count
* watcher count
* open issue count
* GitHub dependent repositories count (if available)
* GitHub dependent packages count (if available)

Optional:

* traffic popularity indicators if accessible
* notable downstream forks or adopters

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
* active contributors in last 90 days
* bus factor heuristic
* top contributor commit share percentage
* maintainer concentration heuristic

Optional:

* maintainer responsiveness
* median PR merge time
* issue response latency

---

### Development Velocity

* total commit count
* commits in last year
* release count
* latest release date
* release cadence
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

Additionally collect:

* estimated repository size
* lines of code estimate if available
* monorepo heuristic
* generated-code heuristic
* vendored-code heuristic

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

### Ecosystem and Maintenance Signals

Detect:

* GitHub Actions usage
* stale dependencies heuristic
* recent dependency updates
* security policy
* CODEOWNERS
* issue templates
* PR templates
* semantic versioning usage
* changelog maintenance

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

## Data Integrity and Anti-Hallucination Requirements

All reported statistics, metadata, classifications, heuristics, and derived conclusions MUST be grounded in actually retrieved repository data, GitHub API responses, git history analysis, or directly inspected repository contents.

The agent MUST NOT:

- fabricate values;
- estimate unavailable statistics without explicit labeling;
- infer precise numeric values from incomplete evidence;
- present assumptions as facts;
- silently substitute missing data.

If any metric, field, statistic, heuristic input, or repository attribute cannot be reliably retrieved, verified, or derived, the report MUST explicitly indicate this using one of:

- `N/A`
- `Unknown`
- `Unavailable`
- `Not reliably retrievable`

as appropriate.

Missing or unavailable data MUST NEVER be replaced with:

- guessed values;
- placeholder numbers;
- optimistic assumptions;
- or implied certainty.

Any heuristic, inference, classification, or interpretation MUST be clearly distinguishable from raw factual repository data.

When heuristics are used, the report MUST:

- identify them as heuristics;
- briefly describe the basis used;
- and avoid overstating confidence.

Examples:

- "Bus factor heuristic: Low confidence"
- "Dormancy classification inferred from commit recency"
- "Technology stack inferred from dependency manifests"

If conflicting signals are detected across sources, the report MUST:

- explicitly mention the conflict;
- prefer authoritative sources;
- and avoid collapsing ambiguity into a false definitive conclusion.

The report MUST prioritize correctness, traceability, and epistemic honesty over completeness.

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
