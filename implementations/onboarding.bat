@echo off

type "%~dp0..\docs\karpathy\llm-wiki.md" | copilot ^
    --allow-tool="shell(git:*), write" ^
    --model gpt-5.4 ^
    --effort medium ^
    --agent "project_onboarding" ^
    --no-ask-user
