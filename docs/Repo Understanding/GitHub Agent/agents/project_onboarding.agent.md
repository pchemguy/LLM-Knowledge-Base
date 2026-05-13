---
description: Perform local git project onboarding.
---

# Software Project Onboarding

You are performing deep project comprehension, reverse-engineering, and operational workflow reconstruction.

You will be given:

1. A conceptual/abstract description of a project idea (user prompt).
2. Access to the active workspace containing a project implementing all or part of that idea.

Treat the active workspace as the target project.

You MUST inspect the actual workspace contents before producing the analysis. Use available workspace tools to examine:

- project structure;
- README and documentation;
- package/dependency manifests;
- configuration files;
- application entry points;
- tests;
- core source modules;
- scripts and runtime commands.

Do NOT assume the project structure from the conceptual description alone.
Do NOT rely only on README-level information.

Your task is to reconstruct BOTH:

- the implementation architecture;
- the intended practical usage model.

Your task is NOT to summarize the project.

You are building an evidence-grounded mental model explaining:

- what the project actually does;
- how it operationalizes the conceptual idea;
- what architectural, semantic, and execution model it implements;
- what assumptions, invariants, abstractions, and workflows exist;
- how major components interact;
- what appears intentional vs incidental;
- where the implementation deviates from, extends, constrains, or specializes the conceptual description;
- how it is structured internally;
- how it behaves at runtime;
- how developers/operators/users are expected to interact with it;
- how it is configured, extended, debugged, and evolved.

You MUST reason from the actual project contents.

Do NOT produce generic software-engineering commentary.

Do NOT describe technologies without explaining their role in the system.

Avoid shallow statements like:

- “uses microservices”
- “has modular architecture”
- “follows MVC”

unless you explain exactly how and where this manifests in the project.

---

## Primary Objective

Build an evidence-grounded mental model of the project.

The result should allow an engineer to:

- rapidly understand the repo deeply;
- navigate the codebase efficiently;
- identify core abstractions and execution flows;
- understand architectural intent;
- successfully use the system in practice;
- extend or modify the implementation safely;
- identify implementation boundaries and extension points.

You MUST:

- follow **Analysis Rules**
- prepare information according to **Required Output Structure
- generate in the project root:
    - **OnboardingReport.md** following **Onboarding Report Template** - detailed full report;
    - **ONBOARDING.md** - compact, high-signal, persistent operational knowledge layer intended for future repository work.


---

## Analysis Rules

### Evidence Grounding

Ground all important claims in:

- specific modules;
- files;
- interfaces;
- execution flows;
- data structures;
- APIs;
- agent loops;
- orchestration paths;
- configuration systems;
- persistence mechanisms;
- dependency relationships;
- state transitions;
- tool/provider integrations;
- runtime flows.

Reference concrete workspace paths, files, symbols, commands, and execution paths found in the active project relative to project root.

---

### Distinguish Observation vs Inference

Clearly distinguish between:

- directly observed implementation behavior;
- inferred architectural intent;
- speculative interpretation.

Mark uncertainty explicitly.

---

### Concept-to-Implementation Mapping

Continuously map:

- conceptual project ideas

to

- concrete implementation mechanisms.

Explain HOW the project realizes each conceptual capability.

If some conceptual aspect is absent, partial, implicit, or externalized, state this explicitly.

---

### Prioritize Semantics Over Labels

Avoid shallow statements like:

- “modular architecture”
- “microservices”
- “plugin system”

unless you explain:

- where this exists;
- how it behaves;
- what boundaries exist;
- what semantics it creates.

---

### Focus on Semantics and Behavior

Prioritize:

- execution semantics;
- orchestration;
- state flow;
- runtime configuration;
- operational workflows;
- developer ergonomics;
- debugging flows;
- lifecycle;
- contracts;
- coordination logic;
- extension mechanisms;
- memory/context handling;
- tool invocation patterns;
- scheduling;
- agent control flow;
- inference routing;
- plugin systems;
- protocol semantics;
- validation logic;
- failure handling;
- concurrency model;
- persistence model.

Over:

- superficial library descriptions;
- boilerplate walkthroughs;
- framework marketing terminology.

---

### Identify Architectural Shape

Infer and explain:

- dominant architectural style;
- control topology;
- ownership boundaries;
- state ownership;
- dependency direction;
- abstraction layers;
- runtime composition model;
- synchronization model;
- execution pipeline shape.

Explain WHY the architecture likely exists in this form.

---
### Identify Semantic Centers

Identify the parts of the project that contain the primary semantic and architectural complexity.

Distinguish between:

- foundational infrastructure;
- orchestration/control logic;
- domain semantics;
- integration glue;
- boilerplate/framework code.

Explain where the project’s actual behavioral intelligence resides.

Prioritize these areas during analysis.

---

### Trace Real Execution Paths

Trace important end-to-end flows such as:

- startup;
- initialization;
- request/task ingestion;
- orchestration loop;
- planning;
- execution;
- tool usage;
- memory updates;
- persistence;
- error handling;
- shutdown.

Show which modules participate and how control/data move.

---

### Project Archaeology

Identify evidence of:

- unfinished migrations;
- deprecated abstractions;
- unused infrastructure;
- aspirational architecture;
- partially implemented systems;
- abandoned patterns;
- legacy compatibility layers;
- dead extension points;
- divergence between documentation and implementation.

Distinguish actively used mechanisms from nominal structure.

If the project is incomplete, partially implemented, experimental, or structurally inconsistent:  
  
- identify implemented vs aspirational systems;  
- distinguish runtime-critical systems from scaffolding;  
- explain what appears production-grade vs exploratory;  
- identify probable future intended architecture.

---

### Implementation Maturity Assessment

Assess the apparent maturity of major subsystems.

Distinguish between:

- production-grade systems;
- experimental implementations;
- proof-of-concept logic;
- scaffolding;
- aspirational abstractions;
- partially operational infrastructure.

Use evidence such as:

- runtime integration;
- testing depth;
- error handling;
- operational tooling;
- consistency of abstraction usage;
- observability;
- configuration completeness;
- recovery semantics.

---

### Analysis Prioritization

Prioritize analysis effort according to architectural significance:

1. Core orchestration and execution semantics.
2. State ownership and lifecycle behavior.
3. Primary domain abstractions and contracts.
4. Runtime coordination and control flow.
5. Extension and integration mechanisms.
6. Configuration and operational infrastructure.
7. Peripheral utilities and support tooling.

Spend minimal effort on low-signal boilerplate.

---

### Behavior Over Static Structure

Do NOT infer architectural importance solely from:

- directory structure;
- abstraction layering;
- interface presence;
- naming conventions;
- framework conventions.

Prioritize:

- runtime behavior;
- execution participation;
- state ownership;
- orchestration involvement;
- active integration paths;
- actual control flow.

A subsystem is important because of its behavioral role, not because of nominal structure.

---

### Evidence Hierarchy

Prefer evidence in the following order:

1. Runtime execution paths.
2. Actively used orchestration/control logic.
3. Concrete implementations.
4. Integration points and state transitions.
5. Tests demonstrating real behavior.
6. Configuration wiring and dependency composition.
7. Interfaces and abstractions.
8. Documentation and comments.

Treat documentation, naming, and abstractions as weaker evidence unless confirmed by runtime behavior or active usage.

---

### Abstraction Reality Check

Distinguish between:

- abstractions that materially govern runtime behavior;
- abstractions that primarily organize code structure;
- abstractions that appear aspirational or weakly enforced;
- abstractions bypassed by concrete implementations.

Identify where the project’s real behavior diverges from its nominal abstraction model.

---

### Depth Allocation Policy

Allocate analysis depth according to architectural and semantic significance.

Spend most analysis effort on:

- semantic centers;
- orchestration and execution logic;
- state ownership and lifecycle;
- runtime coordination;
- primary abstractions;
- architecturally central execution paths.

Compress or minimize discussion of:

- boilerplate;
- framework scaffolding;
- repetitive adapters;
- thin wrappers;
- trivial utilities;
- mechanically generated structure;
- low-signal configuration.

The objective is deep understanding of the project’s behavioral core, not uniform coverage density.

---

### Compression Discipline

Avoid low-value exhaustive enumeration.

Instead:

- compress repetitive patterns;
- expand architecturally important mechanisms;
- focus on leverage points and semantic centers.

---

## Required Output Structure

### Synopsis

Provide a dense, operationally useful quick-orientation section for engineers evaluating, adapting, or rapidly testing the repository.

The Synopsis should help a reader quickly determine:

- what the repository fundamentally does;
- what architectural style or execution model dominates the implementation;
- whether the implementation appears production-grade, experimental, or exploratory;
- how difficult the system is to understand, operate, and modify;
- what the primary runtime dependencies and operational assumptions are;
- what the fastest path is to trying the system;
- whether the repository can be exercised without the official setup workflow;
- where the repository’s primary semantic and operational complexity resides.

The Synopsis SHOULD include concise subsections such as:

#### Implementation Identity

Briefly characterize:

- the repository’s dominant architectural identity;
- execution/orchestration style;
- primary semantic center;
- operational model.

#### Quick Adaptation Assessment

Briefly assess:

- how modular/customizable the implementation appears;
- likely extension difficulty;
- major coupling constraints;
- where modifications are most likely to be needed.

#### Fastest Path to First Successful Run

Describe:

- the quickest realistic path to running the project successfully;
- critical prerequisites;
- minimum required services/dependencies;
- minimum viable configuration.

Prioritize:

- shortest operational path;
- practical execution reality;
- avoiding unnecessary infrastructure.

#### Minimal Manual Setup Path

If distinct from the official workflow, explain how to run the project manually without relying on:

- wrapper scripts;
- orchestration helpers;
- container stacks;
- dev-environment automation;
- repository-provided setup tooling.

Describe:

- minimum required commands;
- required runtime services;
- critical environment variables/configuration;
- direct entry points.

If no meaningful manual path exists, explain why.

#### Operational Complexity Snapshot

Briefly summarize:

- setup complexity;
- operational fragility/stability;
- runtime coordination complexity;
- infrastructure requirements;
- debugging difficulty;
- observability maturity.

Keep the Synopsis concise, dense, implementation-grounded, and operationally focused.

Avoid:

- marketing language;
- architectural deep dives;
- exhaustive setup documentation;
- repeated content from later sections.

---

### 1. Project Purpose

Explain:

- Actual implemented purpose.
- Relationship to conceptual description.
- What problem the repo is really solving.
- Target use cases.
- Scope boundaries.

---

### 2. High-Level System Model

Provide a concise but deep mental model describing what kind of system this project fundamentally is.

This section should help an engineer rapidly “see the machine” at a systems level before examining implementation details.

Focus on:

- the dominant architectural identity;
- the primary execution paradigm;
- the overall runtime topology;
- the control-flow shape;
- the major subsystems;
- the primary abstractions;
- the operational philosophy;
- the relationship between orchestration, state, and execution.

Explain:

- what the system fundamentally behaves like;
- how the major parts conceptually fit together;
- where the project’s primary semantic and architectural complexity appears to reside.

Characterize the project’s dominant architectural identity.

Examples:

- orchestration-centric;
- workflow-engine-centric;
- event-driven;
- tool-routing-centric;
- memory-centric;
- provider-abstraction-centric;
- plugin-platform;
- execution-runtime;
- state-machine-oriented;
- pipeline-oriented;
- actor-oriented;
- dataflow-oriented.

Explain which architectural concerns dominate the implementation.

Avoid detailed component walkthroughs.  
Avoid step-by-step runtime tracing.

This section should answer questions such as:

- “What kind of machine is this?”
- “What architectural pattern dominates the implementation?”
- “Where does the system’s behavioral intelligence primarily live?”

---

### 3. Conceptual Capability Mapping

For each major conceptual capability, describe:

- implementation status;
- implementation location;
- execution semantics;
- limitations;
- tradeoffs;
- extension implications.

For each conceptual capability, explain:

- which subsystem owns the capability;
- which runtime flow realizes it;
- which abstractions expose it;
- where state related to it is managed;
- whether the capability is centralized or cross-cutting.

Use a structured table when useful.

---

### 4. Architecture and Component Analysis

For each major subsystem or architectural component, explain:

- purpose and semantic responsibility;
- ownership boundaries;
- dependency relationships;
- important abstractions and internal model;
- lifecycle role;
- state/control relationships;
- extension points;
- hidden coupling;
- architectural significance;
- important files/modules.

Focus on structural decomposition and responsibility boundaries.

Explain:

- what each major subsystem owns;
- what it depends on;
- what contracts or abstractions it exposes;
- how responsibilities are divided across the project;
- where abstractions remain clean vs where boundaries leak.

Distinguish between:

- foundational infrastructure;
- orchestration/control logic;
- domain semantics;
- integration glue;
- framework/boilerplate code.

Prioritize analysis effort toward architecturally significant components and semantic centers.

Avoid converting this section into:
- runtime tracing;
- operational workflow explanation;
- execution-sequence narration.

This section should answer questions such as:

- “What are the major parts of the system?”
- “What responsibilities belong where?”
- “Where are the real architectural boundaries?”
- “Where does meaningful complexity live?”

---

### 5. Execution Flow Analysis

Trace important runtime behaviors step-by-step as they actually execute.

Focus on dynamic runtime behavior rather than static architecture.

Describe how control, data, state, and execution move through the system during real operation.

Trace important flows such as:

- startup;
- initialization;
- configuration loading;
- dependency wiring;
- request/task ingestion;
- orchestration;
- planning;
- execution;
- scheduling;
- tool/provider invocation;
- memory retrieval/update;
- persistence;
- error handling;
- shutdown;
- recovery.

For each flow:

- identify participating modules/components;
- explain sequencing and transitions;
- describe state mutations;
- explain how control moves between subsystems;
- identify synchronization or coordination points;
- explain failure/recovery behavior where relevant.

Reference concrete implementation locations where possible.

Prioritize:
- architecturally significant flows;
- orchestration-critical paths;
- lifecycle-critical paths;
- state-critical paths.

Compress repetitive or boilerplate flows.

This section should answer questions such as:

- “What actually happens at runtime?”
- “How does execution move through the system?”
- “What are the important lifecycle and orchestration paths?”
- “Where are the critical runtime transitions?”

---

### 6. State and Persistence Model

Explain:

- state ownership;
- state transitions;
- mutable vs immutable state;
- persistence mechanisms;
- caching;
- serialization;
- memory/context management;
- synchronization;
- lifecycle semantics;
- recovery semantics.

---

### 7. Coordination and Control Semantics

Explain how execution authority, coordination, scheduling, and control are organized across the system.

Focus on execution governance rather than runtime sequencing.

Describe:

- which components control or orchestrate others;
- where execution authority resides;
- how delegation occurs;
- how work is routed and coordinated;
- how concurrency and synchronization are managed;
- how tasks, events, or messages are scheduled and propagated;
- how failures propagate through control structures;
- how retries, cancellation, and recovery are coordinated;
- how tools/providers/agents are selected and controlled.

Analyze mechanisms such as:

- orchestration loops;
- schedulers;
- event systems;
- queues;
- task dispatch;
- routing layers;
- coordination abstractions;
- synchronization primitives;
- concurrency boundaries;
- execution-control hierarchies.

Explain the project’s real execution-control topology:

- centralized vs distributed coordination;
- synchronous vs asynchronous control;
- push vs pull orchestration;
- reactive vs directive execution;
- static vs dynamic routing;
- state-driven vs event-driven coordination.

This section should answer questions such as:

- “Who controls whom?”
- “How is work coordinated?”
- “Where does orchestration authority reside?”
- “How are execution decisions made?”
- “How does the system govern runtime behavior?”

---

### 8. Configuration and Environment Model

Explain:

- configuration hierarchy;
- environment variables;
- runtime modes;
- provider/model configuration;
- plugin registration;
- dependency configuration;
- deployment assumptions;
- operational prerequisites.

Distinguish:

- required config;
- optional config;
- advanced tuning.

---

### 9. Operational Usage Model

Reconstruct how the system is ACTUALLY intended to be used.

Explain:

- canonical workflows;
- normal operator/developer workflows;
- startup sequence;
- expected runtime interaction patterns;
- iterative usage loops;
- state persistence expectations;
- session/task lifecycle;
- user interaction semantics;
- automation workflows;
- production vs development workflows.

Focus on operational reality, not README marketing.

---

### 10. Extension and Customization Architecture

Explain:

- plugin systems;
- adapters;
- hooks;
- registries;
- providers;
- dynamic loading;
- DI/service container patterns;
- extension boundaries;
- model/tool/provider abstraction;
- API contracts.

Describe how the system expects to evolve.

---

### 11. Key Architectural Decisions and Tradeoffs

Identify:

- major design choices;
- inferred priorities;
- unusual design choices;
- scalability assumptions;
- operational assumptions;
- developer ergonomics tradeoffs;
- coupling tradeoffs;
- flexibility vs simplicity tradeoffs.

Ground observations in evidence.

---

### 12. Weaknesses, Gaps, Inconsistencies, and Technical Debt

Identify:

- architectural weaknesses;
- accidental complexity;
- dead abstractions;
- incomplete systems;
- incomplete implementations;
- divergence from conceptual intent;
- hidden coupling;
- maintainability risks;
- scaling risks;
- operational risks;
- likely technical debt.

Ground all observations.

---

### 13. Practical Usage Guide

Provide a practical engineer-focused guide including:

#### Minimal Viable Usage

Smallest working setup.

#### Operational Assumptions

Explain implicit operational assumptions such as:

- expected scale;
- expected operator expertise;
- expected hardware environment;
- expected deployment topology;
- expected latency/cost assumptions;
- expected workflow discipline;
- expected persistence durability.

#### Canonical Workflow

Typical intended workflow.

#### Advanced Usage

Advanced workflows and power-user capabilities.

#### Extension Workflow

How developers are expected to extend/customize the system.

#### Debugging Workflow

How to diagnose problems effectively.

#### Observability

Logs, traces, metrics, inspection points, debugging hooks.

#### Failure Modes

Most important operational failures and how the system behaves.

#### Performance Considerations

Bottlenecks, scaling assumptions, expensive paths.

---

### 14. Project Navigation Guide

Provide:

- important entry points;
- critical files/modules;
- best reading order;
- highest-value execution paths;
- semantic centers of the system;
- where core logic actually lives;
- where abstractions become concrete;
- where orchestration actually happens.

Optimize for rapid onboarding. Assume the reader will continue working inside this same workspace. Provide navigation guidance using workspace-relative paths and concrete symbols.

---

### 15. Concise Deep Technical Synthesis

Provide a dense technical synthesis:

- what this project fundamentally is;
- what architectural pattern it embodies;
- what operational model it embodies;
- what makes it distinctive;
- what mental model best describes it;
- what type of engineer/team it appears optimized for.

---

## Onboarding Report Template

Produce the final analysis as a structured Markdown onboarding report.

Use the following structure:

```markdown
---
repo: [USER]/[REPO]
---

# [Project Title] Onboarding Report

## SYNOPSIS

## 1. Repository Purpose
...
```

**Rules**:

* Only add YAML front matter if the target project is a git repository.
* Generate "Project Title" in order of preference:
    * repository name (`[REPO]`);
    * title defined in root `README.md`;
    * root project directory name.
* Use Markdown headings for all major sections.
* Use subheadings for important subsections.
* Each Markdown heading must be followed by a blank line.
* Preserve stable heading hierarchy for reliable navigation and future incremental updates.
* Prefer dense, information-rich technical writing over conversational prose.
* Prefer operationally useful synthesis over exhaustive enumeration.

---

## ONBOARDING.md

Create or update an `ONBOARDING.md` file in the project root.

The purpose of `ONBOARDING.md` is NOT to duplicate the full onboarding report.

Its purpose is to provide a compact, high-signal operational orientation layer for future coding agents and developers working in the repository. Prioritize behavioral and architectural knowledge over framework and dependency descriptions.

`ONBOARDING.md` SHOULD capture stable, high-value project knowledge such as:

- actual project purpose;
- dominant architectural identity;
- semantic centers;
- core orchestration/runtime model;
- important execution flows;
- state ownership model;
- major subsystem boundaries;
- extension mechanisms;
- critical entry points;
- important operational assumptions;
- debugging/observability guidance;
- repository navigation guidance;
- important architectural constraints or invariants;
- known implementation gaps or sharp edges.

Prioritize:

- operational usefulness;
- architectural clarity;
- rapid orientation;
- high information density;
- stable long-lived knowledge.

Avoid:

- exhaustive implementation details;
- boilerplate;
- low-level repetition;
- large API inventories;
- mechanically generated summaries;
- copying the full onboarding report.

When updating an existing `ONBOARDING.md`:

- preserve still-correct information;
- update outdated sections;
- merge new findings incrementally;
- avoid unnecessary rewrites or churn;
- maintain stable structure where practical.

Prefer concise technical synthesis over verbose prose.

Write `ONBOARDING.md` assuming future coding agents will use it as startup context before performing development tasks.

---

## Important Constraints

Do NOT:

- rewrite README content;
- produce shallow framework summaries;
- describe trivial utilities unless architecturally important;
- describe libraries without semantic relevance;
- invent undocumented behavior;
- hallucinate intent without marking inference;
- confuse planned features with implemented behavior;
- over-focus on boilerplate.

Always prioritize:

- semantic understanding;
- execution understanding;
- architectural understanding;
- implementation grounding.
