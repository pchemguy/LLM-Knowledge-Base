# Agent Instructions for LLM-Knowledge-Base

## Scope

This repository is a comparison and analysis workspace for LLM Wiki style projects, not a single deployable application.

- Default assumption: you are editing the workspace's documentation, scripts, templates, or onboarding artifacts.
- Do not start by changing code inside `implementations/*/*` unless the task explicitly targets a specific implementation repository.
- Treat each `implementations/[OWNER]/[REPO]/` directory as an imported project with its own conventions and tooling.

## Canonical Sources

- Start with [README.md](README.md) for the implementation inventory.
- Use [docs/karpathy/llm-wiki.md](docs/karpathy/llm-wiki.md) for the baseline concept.
- Use [docs/rohitg00/llm-wiki-v2.md](docs/rohitg00/llm-wiki-v2.md) for the extended pattern and terminology.
- When working on a specific implementation, prefer `implementations/[OWNER]/OnboardingReport.md` and `implementations/[OWNER]/ONBOARDING.md` before re-exploring the submodule.

## Repository Workflow

There is no root build, lint, or test pipeline. The main workflow is script-driven analysis.

- `scripts/onboarding.bat`: runs the `project_onboarding` agent across implementation submodules and writes onboarding artifacts next to each owner directory.
- `scripts/synthesis.bat`: uses the onboarding artifacts plus the concept docs to generate `implementations/REVIEW.md`.
- `scripts/github_stats.bat`: collects GitHub metadata for the tracked implementations.
- `scripts/add_agents.bat`: installs template agent and prompt files into the current repository's `.github/` directory.

Run these from the repository root unless the script explicitly states otherwise.

## Key Locations

- `docs/`: source material, concept notes, and VS Code agent references.
- `implementations/*.html`: captured GitHub or project pages for the tracked implementations.
- `implementations/[OWNER]/`: onboarding artifacts plus one implementation submodule directory.
- `scripts/`: Windows batch automation for onboarding, synthesis, stats, and notifications.
- `templates/commands/`: source templates used by `scripts/add_agents.bat`.

## Working Conventions

- Prefer linking to existing docs instead of copying their content into new guidance files.
- Preserve the owner/repo layout under `implementations/`; the batch scripts assume each owner directory contains exactly one submodule directory plus generated reports.
- If a task concerns one implementation, stay local to that implementation and follow its own `AGENTS.md`, `CLAUDE.md`, or README if present.
- If a task concerns comparison or synthesis, use the existing onboarding artifacts as the primary evidence source and avoid redundant repo-wide re-analysis.

## Common Pitfalls

- Do not invent root-level build or test commands; they are not part of this workspace.
- `scripts/add_agents.bat` must be run from the root of the target repository containing `.git`.
- `scripts/onboarding.bat` and `scripts/synthesis.bat` expect Copilot CLI access and custom agent installation to work.
- `scripts/github_stats.bat` depends on a valid local Chrome path and repository remotes; verify environment-specific paths before changing that workflow.
