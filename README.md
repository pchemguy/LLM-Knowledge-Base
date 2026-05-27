---
url: https://chatgpt.com/c/69ff8c5e-a7e4-83eb-9748-27e1a8646e77
---

# LLM-Knowledge-Base

## Roster

[Karpathy's LLM Wiki](docs/karpathy/llm-wiki.md)
[LLM Wiki v2 — extending Karpathy's LLM Wiki pattern](LLM%20Wiki%20v2%20—%20extending%20Karpathy's%20LLM%20Wiki%20pattern%20with%20lessons%20from%20building%20agent%20memory.md)

| #   | Name                                 | URL                                                   | Class       | README                                                                 |
| --- | ------------------------------------ | ----------------------------------------------------- | ----------- | ---------------------------------------------------------------------- |
| 1   | Link                                 | https://github.com/gowtham0992/link                   | Significant | [README](implementations/gowtham0992/Link/README.md)                   |
| 2   | SwarmVault                           | https://github.com/swarmclawai/swarmvault             | Significant | [README](implementations/SwarmClawAI/SwarmVault/README.md)             |
| 3   | Synthadoc                            | https://github.com/axoviq-ai/synthadoc                | Significant | [README](implementations/axoviq-ai/Synthadoc/README.md)                |
| 4   | OmegaWiki                            | https://github.com/skyllwt/OmegaWiki                  | Significant | [README](implementations/skyllwt/OmegaWiki/README.md)                  |
| 5   | LLM Wiki                             | https://github.com/nvk/llm-wiki                       | Significant | [README](implementations/nvk/LLM-Wiki-nvk/README.md)                   |
| 6   | yopedia                              | https://github.com/yologdev/yopedia                   | Significant | [README](implementations/yologdev/yopedia/README.md)                   |
| 7   | Understand Anything                  | https://github.com/Lum1104/Understand-Anything        | Significant | [README](implementations/Lum1104/Understand-Anything/README.md)        |
| 8   | AgentMemory                          | https://github.com/rohitg00/agentmemory               | Significant | [README](implementations/rohitg00/AgentMemory/README.md)               |
| 9   |                                      |                                                       |             |                                                                        |
| 10  |                                      |                                                       |             |                                                                        |
|     |                                      |                                                       |             |                                                                        |
|     | Second Brain                         | https://github.com/NicholasSpisak/second-brain        | Small       | [README](implementations/NicholasSpisak/Second-Brain/README.md)        |
|     |                                      |                                                       |             |                                                                        |
|     |                                      |                                                       |             |                                                                        |
|     | LLM Wiki                             | https://github.com/lucasastorian/llmwiki              | Small       | [README](implementations/lucasastorian/LLM-Wiki/README.md)             |
|     |                                      |                                                       |             |                                                                        |
| 11  | LLM Wiki Compiler                    | https://github.com/ussumant/llm-wiki-compiler         | Small       | [README](implementations/ussumant/LLM-Wiki-Compiler/README.md)         |
| 12  | LLM Wiki                             | https://github.com/MehmetGoekce/llm-wiki              | Small       | [README](implementations/MehmetGoekce/LLM-Wiki-MehmetGoekce/README.md) |
| 13  | LLM Wiki                             | https://github.com/Ss1024sS/LLM-wiki                  | Small       | [README](implementations/Ss1024sS/LLM-Wiki-Ss1024sS/README.md)         |
| 14  | Obsidian Wiki                        | https://github.com/Ar9av/obsidian-wiki                | Small       | [README](implementations/Ar9av/Obsidian-Wiki/README.md)                |
| 15  | LLM Wiki Manager                     | https://github.com/sametbrr/llm-wiki-manager          | Small       | [README](implementations/sametbrr/LLM-Wiki-Manager/README.md)          |
| 16  | Karpathy LLM Wiki                    | https://github.com/Astro-Han/karpathy-llm-wiki        | Small       | [README](implementations/Astro-Han/Karpathy-LLM-Wiki/README.md)        |
| 17  | Karpathy-Inspired LLM Knowledge Base | https://github.com/zhurudong/andrej-karpathy-llm-wiki | Small       | [README](implementations/zhurudong/andrej-karpathy-llm-wiki/README.md) |
| 18  | PulseOS-Lite                         | https://github.com/jp-carrilloe/pulseOS-lite          | Small       | [README](implementations/jp-carrilloe/PulseOS-Lite/README.md)          |

---

## Understand Anything

**repo**: https://github.com/Lum1104/Understand-Anything

### Architecture

- **Analysis**:
  Target analysis and processing is performed via slash commands / skills / custom agents from within the interface provided by supported agents (such as Codex or Claude).
- **Results retrieval**:
  Processed results are presented via a browser-based web dashboard UI using a local Vite web server.
- **Development**:
  "Understand Anything" is developed via the Superpowers SDD framework. The specs are included in the source repository.
- **Implementation**:
  "Understand Anything" is implemented as a plugin compatible with Claude and Codex (TypeScript/Vite/Markdown + Bash/PowerShell setup).
  For Codex:
    - Clone repo and open it as an existing project / folder (Ctrl-O); then go to `plugins` and `understand-anything` should become available as a vendor in the vendor dropdown filter next to the `Search plugins` field (typically showing `Codex official` by default).
    - After installation, the plugin can be opened by clicking on it to see available skills and disabling individual skills, if desired so.

### Core components

- Core functionality is under `understand-anything-plugin` (path base, except for `docs`)
- Uses `Tree-sitter`
- **Dev Framework**: SDD - Superpowers
- **Tree filtering**: `.gitignore` semantics

| Component                                 | Path                          | Language          |
| ----------------------------------------- | ----------------------------- | ----------------- |
| Implementation specs                      | `docs/superpowers`            | Markdown          |
| Custom agents                             | `agents`                      | Markdown          |
| Agent skills                              | `skills`                      | Markdown + Python |
| Agent hooks                               | `hooks`                       | Markdown          |
| Language-specific analyzers (LLM)         | `skills/understand/languages` | Markdown          |
| Deterministic core                        | `packages/core`               | TypeScript        |
| Language-specific analyzers (algorithmic) | `packages/core/src/plugins`   | TypeScript        |
| Language-specific configs (algorithmic)   | `packages/core/src/languages` | TypeScript        |
| UI and Local web server                   | `packages/dashboard`          | TypeScript + Vite |
| Setup scripts                             | `[REPO ROOT]`                 | Bash + PowerShell |

### Produced Artifacts

**Location**: `.understand-anything` in the Target Repository.

| Target                       | Description                                       |
| ---------------------------- | ------------------------------------------------- |
| `tmp/ua-domain-generate.mjs` |                                                   |
| `intermediate`               | Project directory analysis results in JSON format |
| Agent skills                 | Markdown                                          |

---

## Link

**repo**: https://github.com/gowtham0992/link

### Architecture

The core LLM functionality is in `LINK.md`. This module essentially defines an agent skill or a custom agent, except that it is not framed as either. The deterministic part (CLI, UI, web server, and MCP server) are code in Python, while initialization scripts are in Bash. On Windows, a Conda environment with `m2-base` and `git` packages installed provide sufficient environment. The only additional step that should be performed is copying `python.exe` to `python3.exe` (necessary for the initialization script). The agent will use MCP server, if configured, or Link CLI + `link_core` (also expects `python3`), otherwise.

The target project initialization command executed from the _target project root_ as

```text
bash <PATH_TO_LINK_CLONE_ROOT>/integrations/<AGENT>/install.sh --project
```

creates 

1. `raw` directory for holding the source files;
2. `wiki` directory with scaffolding (`integrations/_shared/scaffold.sh`) for wiki files;
3. `LINK.md` copy acting as a de facto skill definition;
4. `link_core` copy acting as the deterministic component of the `LINK.md` skill;
5. `AGENTS.md` or agent-specific module with contents of `integrations/_shared/link-instructions-project.md`, which wires MCP server, Link CLI + `link_core` as a fallback, and `LINK.md` as skill definition.

### Core components

| Component                                   | Path                              | Language        |
| ------------------------------------------- | --------------------------------- | --------------- |
| CLI                                         | `link.py`                         | Python          |
| Web server + UI                             | `serve.py`                        | Python          |
| Deterministic core                          | `mcp_package/link_core`           | Python          |
| MCP server                                  | `mcp_package/link_mcp`            | Python          |
| LLM core                                    | `LINK.md`                         | Markdown        |
| `AGENTS.md` template and supporting scripts | `integrations/_shared`            | Markdown + Bash |
| Target project initialization               | `integrations/<AGENT>/install.sh` | Bash            |

---

## SwarmVault

**repo**: https://github.com/swarmclawai/swarmvault

### Core components

- All paths are relative to SwarmVault repository root.
- Packaged Electron App

| Component                           | Path                         | Language                       |
| ----------------------------------- | ---------------------------- | ------------------------------ |
| Language-specific target smoke      | `smoke/fixtures/tiny-matrix` | `<SUPPORTED TARGET LANGUAGES>` |
| LLM Wiki Schema                     | `templates`                  | Markdown                       |
| UI and deterministic infrastructure | `packages`                   | TypeScript                     |
| Tutorials                           | `worked`                     | Markdown                       |


---

## LLM Wiki Compiler

**repo**: https://github.com/ussumant/llm-wiki-compiler

### Architecture

Agent skill + command modules + templates + helper scripts.
Supports Claude and Codex (partially).

### Core components

| Component       | Path                          | Language   |
| --------------- | ----------------------------- | ---------- |
| Agent skill     | `plugin/skills/wiki-compiler` | Markdown   |
| Helper scripts  | `plugin/hooks`                | Bash       |
| Command modules | `plugin/commands`             | Markdown   |
| Templates       | `plugin/templates`            | Markdown   |
| Visualizer      | `plugin/visualize`            | JavaScript |

---

## LLM Wiki - MehmetGoekce

**repo**: https://github.com/MehmetGoekce/llm-wiki

### Architecture

Agent skill file + templates for Obsidian and Logseq + helper scripts.

### Core components

- **Dev Framework**: SDD - OpenSpec

| Component                     | Path        | Language |
| ----------------------------- | ----------- | -------- |
| Agent skill                   | `wiki.md`   | Markdown |
| Helper scripts (generated)    | `setup.sh`  | Python   |
| Obsidian and Logseq templates | `templates` | Markdown |
| Implementation specs          | `openspec`  | Markdown |

---

## LLM Wiki - Ss1024sS

**repo**: https://github.com/Ss1024sS/LLM-wiki

### Architecture

Agent skill file + templates + helper scripts + AGNETS.md templates.

### Core components

| Component                                      | Path                                | Language          |
| ---------------------------------------------- | ----------------------------------- | ----------------- |
| Agent skill + templates + skill helper scripts | `skills/knowledge-system-bootstrap` | Markdown + Python |
| Helper scripts                                 | `scripts`                           | Python + Bash     |
| AGNETS.md templates                            | `UNIVERSAL.md`                      | Markdown          |

---

## Obsidian Wiki

**repo**: https://github.com/Ar9av/obsidian-wiki

### Architecture

Agent skills + helper scripts + AGNETS.md onboarding.  
Notable feature - one skill per slash command. A better design, however, would probably be having one skill or a few focused skills, with each `SKLILL.md` acting as a routing module that defines just the names of the associated slash commands and routes to individual associated modules.

### Core components

| Component                     | Path        | Language                 |
| ----------------------------- | ----------- | ------------------------ |
| Agent skills + helper scripts | `.skills`   | Markdown + Python + Bash |
| AGNETS.md - wiki onboarding   | `AGNETS.md` | Markdown                 |

---

## LLM Wiki Manager

**repo**: https://github.com/sametbrr/llm-wiki-manager

### Architecture

Agent skill file + helper scripts. Appears to be reasonably documented.

### Core components

- **Dev Framework**: Anthropic [skill creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator).

| Component                                                                    | Path         | Language |
| ---------------------------------------------------------------------------- | ------------ | -------- |
| Agent skill                                                                  | `SKILL.md`   | Markdown |
| Helper scripts for scaffold, index updates, log appends, and lint reporting. | `scripts`    | Python   |
| Documentation                                                                | `references` | Markdown |

---

## Karpathy LLM Wiki

**repo**: https://github.com/Astro-Han/karpathy-llm-wiki

### Architecture

Agent skill file.

### Core components

| Component   | Path         | Language |
| ----------- | ------------ | -------- |
| Agent skill | `SKILL.md`   | Markdown |
| Templates   | `references` | Markdown |

---

## Karpathy-Inspired LLM Knowledge Base

**repo**: https://github.com/zhurudong/andrej-karpathy-llm-wiki

### Architecture

Agent skill file.

### Core components

| Component   | Path                     | Language |
| ----------- | ------------------------ | -------- |
| Agent skill | `templates/CLAUDE.en.md` | Markdown |


---

## PulseOS-Lite

**repo**: https://github.com/jp-carrilloe/pulseOS-lite

The project repository appears quite messy. Sorting it out problematic. It mentions SQLite database use, but otherwise its value is unclear.

---

## 11. PulseOS-Lite - jp-carrilloe

**repo**: jp-carrilloe/pulseOS-lite

Note: Involves SQLite.

## 15. LLM Wiki App - lucasastorian

**repo**: lucasastorian/llmwiki

Note: TypeScript application (https://llmwiki.app)




