---
description: Based on https://github.com/microsoft/vscode-copilot-chat/blob/main/assets/prompts/init.prompt.md
---

# Software Project Onboarding Instructions Maintenance

Explore the software project and generate or update project-wide onboarding instructions for AI coding agents in file: 

`.github/copilot-instructions.md`

The objective is NOT to summarize the project. The objective is to provide high-signal operational guidance that helps an AI agent become productive quickly and avoid incorrect assumptions.

## Workflow

1. **Discover existing guidance**
    Search for:
    - `.github/copilot-instructions.md`
    - `AGENT.md`
    - `AGENTS.md`
    - `CLAUDE.md`
    - `.cursorrules`
    - `.windsurfrules`
    - `.clinerules`
    - `.cursor/rules/**`
    - `.windsurf/rules/**`
    - `.clinerules/**`
    - `README.md`
    
    Treat existing guidance as authoritative unless contradicted by the codebase.
    
2. **Explore the codebase**
    Identify information that materially improves future agent task execution:
    - Project-specific conventions that differ from ecosystem defaults
    - Architecture boundaries and subsystem responsibilities
    - Build/test/lint/typecheck commands
    - Development workflow expectations
    - Important dependency relationships
    - Key files/directories that demonstrate canonical patterns
    - Common pitfalls, hidden constraints, or environment issues
    - Areas with unusually high complexity, fragility, or coupling
    
    Also inventory existing documentation:
    - `docs/**/*.md`
    - `CONTRIBUTING.md`
    - `ARCHITECTURE.md`
    - `DEVELOPMENT.md`
    - `TESTING.md`
    - similar project docs
    
    Prefer linking to existing documentation instead of duplicating it.
    
3. **Generate or update**
    - New file:
         - Use the template below
         - Include only relevant sections
    - Existing file:
         - Preserve valuable project-specific guidance
         - Remove stale or duplicated content
         - Consolidate overlapping instructions
         - Avoid replacing precise guidance with generic wording
    - Prioritize:
        - project-specific behavior;
        - operational guidance;
        - actionable constraints;
        - canonical examples.
    - Avoid:
        - generic programming advice;
        - ecosystem defaults;
        - style rules already enforced automatically;
        - restating README content.

4. **Iterate**
    - Identify unclear or missing operational guidance
    - Suggest decomposition into scoped instruction files when appropriate
        (e.g. frontend/backend/tests/infrastructure)
    - For large or polyglot repositories, prefer layered guidance over a single oversized file

---

## Template

Only include sections that provide meaningful project-specific value.

```markdown
# Project Guidelines

## Architecture

{Major components, subsystem boundaries, important data/control flow, architectural constraints}

## Development Workflow

{How developers actually work in this repository}

## Build and Test

{Commands for install/build/test/lint/typecheck/run}

## Project Conventions

{Patterns that differ from common ecosystem practices}

## Key Locations

{Important directories/files/components agents should understand before modifying code}

## Common Pitfalls

{Non-obvious constraints, edge cases, fragile areas, environment traps}
```

For detailed procedures, prefer links:

- `See docs/TESTING.md for test conventions.`
- `See docs/ARCHITECTURE.md for subsystem details.`

Do not duplicate large documentation sections into onboarding instructions.

---

## Core Principles

1. **Operational relevance first**
    Include information that materially improves agent task execution quality.
2. **Project-specific over generic**
    Prefer repository-specific guidance over general best practices.
3. **Minimal but high-signal**
    Every section should justify its existence.
4. **Link, don't embed**
    Reference authoritative docs instead of duplicating them.
5. **Ground conclusions in evidence**
    Derive guidance from actual repository structure, tooling, configuration, and code patterns.
6. **Optimize for maintainability**
    The onboarding file should remain useful as the repository evolves.

---

## Anti-patterns

- Generic software engineering advice
- README paraphrasing
- Large architecture summaries with no operational value
- Copying extensive documentation into onboarding instructions
- Inventing conventions not supported by the repository
- Overly verbose onboarding files
- Instructions already enforced automatically by tooling
