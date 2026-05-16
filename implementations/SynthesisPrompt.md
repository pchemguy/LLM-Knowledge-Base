# Software Implementation Comparison

Your task is to compare alternative implementations of the "LLM Wiki" project concept included in a collection of select implementations and synthesize findings. The original reference description of the "LLM Wiki" project concept is `docs/karpathy/llm-wiki.md` and its further discussion is included as `docs/rohitg00/llm-wiki-v2.md`. The target implementations to be compared are included as this LLM-Knowledge-Base project's Git submodules namespaced as `implementations/[OWNER]/[REPO]/`.

Each of the target implementations has been already analyzed via the `project_onboarding` agent yielding distinct `OnboardingReport.md` and `ONBOARDING.md` for each analyzed implementation. These two files were moved one level up from `implementations/[OWNER]/[REPO]/` to `implementations/[OWNER]/`. You MUST rely on these files as your primary source of truth about individual implementations. You MUST NOT perform a from-scratch analysis for individual target implementations and only refer to actual projects as a focused back up option, if at all.

You MUST create `implementations/REVIEW.md` document comparing the individual implementations and synthesizing prior analysis findings choosing appropriate robust communication formats. The reader of this `REVIEW.md` document is an expert understanding the underline project concept description.

For each of these implementations, the reader needs to be able to quickly

- grasp the architecture, scope, functionality, key implementation facts, and maturity;
- decide if further exploration/learning (both from user and dev point of view) is warranted; 
- understand, whether it should be selected for subsequent use or adaptation, or studied and treated as the source of inspiration of specific design choices to be incorporated in a new project.

The document must also provide a robust means for prioritizing efforts when more than on alternative deserves further attention (which is expected).
