---
description: Based on https://github.com/microsoft/vscode-copilot-chat/blob/main/assets/prompts/init.prompt.md
---

# Software Project Onboarding Instructions Maintenance

Explore software project and generate or update onboarding instructions.

Target: `.github/copilot-instructions.md` - project-wide standards (recommended, cross-editor).

## Workflow

1. **Discover existing conventions**
    Search: `.github/copilot-instructions.md`, `AGENT.md`, `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `.clinerules`, `.cursor/rules/**`, `.windsurf/rules/**`, `.clinerules/**`, `README.md`.
2. **Explore the codebase**
    Find essential knowledge that helps an AI agent be immediately productive:
    - Project-specific conventions that differ from common practices
    - Architecture decisions and component boundaries
    - Build/test commands (agents run these automatically)
    - Key files/directories that exemplify patterns
    - Potential pitfalls or common development environment issues    
    
    Also inventory existing documentation (`docs/**/*.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, etc.) to identify topics that should be linked, not duplicated.
3. **Generate or merge**
    - New file: Use template, include only relevant sections
    - Existing file: Preserve valuable content, update outdated sections, remove duplication
    - Follow the **Link, don't embed** principle from workspace-instructions.md
4. **Iterate**
    - Ask for feedback on unclear or incomplete sections
    - If the workspace is complex, suggest applyTo-based instructions for specific areas (e.g., frontend, backend, tests)

## Template

Only include sections the workspace benefits from:

```markdown
# Project Guidelines

## Code Style

{Language and formatting preferences—reference key files that exemplify patterns}

## Architecture

{Major components, service boundaries, the "why" behind structural decisions}

## Build and Test

{Commands to install, build, test—agents will attempt to run these}

## Conventions

{Patterns that differ from common practices—include specific examples}
```

For large repos, link to detailed docs instead of embedding: `See docs/TESTING.md for test conventions.`

## Core Principles

1. **Minimal by default**: Only what's relevant to *every* task
2. **Concise and actionable**: Every line should guide behavior
3. **Link, don't embed**: Reference docs instead of copying content. Search for existing docs (`docs/**/*.md`, `CONTRIBUTING.md`, etc.) and catalog what they cover—only inline agent-critical gotchas not documented elsewhere
4. **Keep current**: Update when practices change

## Anti-patterns

- **Kitchen sink**: Everything instead of what matters most
- **Duplicating docs**: Copying README instead of linking
- **Obvious instructions**: Conventions already enforced by linters
