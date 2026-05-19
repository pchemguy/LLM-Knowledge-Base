:: ============================================================================
:: Synthesizes results of implementation analysis.
::
:: https://chatgpt.com/c/6a045362-cb44-83eb-abdd-d7d04f67e030
:: ============================================================================
::
@echo off


:: ============================================================================ MAIN BEGIN
:: ============================================================================
:MAIN

SetLocal EnableExtensions EnableDelayedExpansion
set "ErrorStatus=0"

cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"
set "PROMPT_FILE=%PROJECT_ROOT%\scripts\SynthesisPrompt.md"
set "PROJECT_BASELINE=%PROJECT_ROOT%\docs\karpathy\llm-wiki.md"
set "PROJECT_EXTENSION=%PROJECT_ROOT%\docs\rohitg00\llm-wiki-v2.md"
set "REPORT_FILE=%PROJECT_ROOT%\implementations\REVIEW.md"
set "AGENT=project_onboarding"
set AGENT_TOOLS=github(*), write, memory, web_fetch, web_search, skill, sql,^
    shell(bash:*),^
    shell(cmd:*),^
    shell(python:*),^
    shell(pytest:*),^
    shell(npm:*), ^
    shell(git:*),^
    shell(gh:*),^
    shell(curl:*)    

set "TGNOTIFY=%PROJECT_ROOT%\scripts\tgnotify.bat"
if not exist "%TGNOTIFY%" (set "TGNOTIFY=")

set "STDOUTLOG=%PROJECT_ROOT%\stdout.log"
set "STDERRLOG=%PROJECT_ROOT%\stderr.log"
del "%STDOUTLOG%" 2>nul
del "%STDERRLOG%" 2>nul


:: Abort if project description or prompt file is not available

if not exist "%PROMPT_FILE%" (
    echo ERROR Missing prompt file.
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

if not exist "%PROJECT_BASELINE%" (
    echo ERROR Missing baseline description.
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

if not exist "%PROJECT_EXTENSION%" (
    echo ERROR Missing missing extended description.
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

(
    call :TIMESTAMP
    call :SYNTHESIS
    set "ErrorStatus=!ERRORLEVEL!"
)
::) 1^>^>"%STDOUTLOG%" 2^>^>"%STDERRLOG%"


:MAIN_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal
exit /b %ErrorStatus%
:: ============================================================================ 
:: ============================================================================ MAIN END


:: ============================================================================ SYNTHESIS BEGIN
:: ============================================================================
:SYNTHESIS
:: Runs implementation synthesis.
::
:: Analysis uses a custom Copilot agent "project_onboarding".
::
:: Script must copy the contents
::    of "docs/Repo Understanding/GitHub Agent"
::    to .github
::
:: Expects: 
::   - each submodule to be analyzed is in [REPO_ROOT]/implementations/[SUB_OWNER]/[SUB_REPO];
::   - [SUB_REPO] is the only directory in its parent directory (no sibling directories);
::   - [SUB_OWNER] contains OnboardingReport.md and ONBOARDING.md
::
:: Call this sub with argument(s):
::   - None
::
SetLocal
pushd "%CD%" || exit /b 1

set "ErrorStatus=0"

echo ======================== SYNTHESIS ==========================
echo =============================================================
echo -------------------------------------------------------------
echo:
call :TIMESTAMP
echo:

:: Abort if any analysis file is missing.

set "SUBS=%PROJECT_ROOT%\implementations"

for /d %%D in (%SUBS%\*) do (
    if not exist "%%~D\OnboardingReport.md" (
        echo [ERROR] "%%~D\OnboardingReport.md" is not found. Aborting...
        set "ErrorStatus=1"
        goto :SYNTHESIS_EXIT
    )
    if not exist "%%~D\ONBOARDING.md" (
        echo [ERROR] "%SUBS%\%%~D\ONBOARDING.md" is not found. Aborting...
        set "ErrorStatus=1"
        goto :SYNTHESIS_EXIT
    )
)

:: Make .github

if not exist "%PROJECT_ROOT%\.github" (
    mkdir "%PROJECT_ROOT%\.github" || (
        set "ErrorStatus=!ERRORLEVEL!"
        echo ERROR Failed to create ".github". Aborting...
        goto :SYNTHESIS_EXIT
    )
)

:: Copy custom onboarding agent

pushd "%CD%"
call "%~dp0add_agents.bat"
if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=%ERRORLEVEL%"
    echo {ERROR} Failed to install custom agents.
    goto :MAIN_EXIT
)
popd

:: Run synthesis

rundll32 user32.dll,MessageBeep
"%WINDIR%\System32\timeout.exe" /T 60
if defined TGNOTIFY (call "%TGNOTIFY%" "**[SYNTHESIS START]**")

type "%PROMPT_FILE%" | copilot ^
    --model=gpt-5.4 ^
    --effort=medium ^
    --reasoning-effort=medium ^
    --agent="%AGENT%" ^
    --allow-tool="%AGENT_TOOLS%" ^
    --allow-all-urls ^
    --enable-all-github-mcp-tools ^
    --log-level=all ^
    --no-ask-user

set "ErrorStatus=%ERRORLEVEL%"

if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=1"
    echo ERROR Failed to complete synthesis via Copilot CLI.
    if defined TGNOTIFY (call "%TGNOTIFY%" "**[SYNTHESIS FAILED]**")
    goto :SYNTHESIS_EXIT
)

if not exist "%REPORT_FILE%" (
    set "ErrorStatus=1"
    echo ERROR Failed to complete synthesis via Copilot CLI: missing report "%REPORT_FILE%".
    if defined TGNOTIFY (call "%TGNOTIFY%" "**[SYNTHESIS FAILED]**: No report file.")
    goto :SYNTHESIS_EXIT
)

if defined TGNOTIFY (call "%TGNOTIFY%" "**[SYNTHESIS COMPLETE]**: %%%%0AReport in '%REPORT_FILE%'")

:SYNTHESIS_EXIT
echo _____________________________________________________________
echo:
popd
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ============================================================================ 
:: ============================================================================ SYNTHESIS END


:: ============================================================================ TIMESTAMP BEGIN
:: ============================================================================
:TIMESTAMP
::
SetLocal

set CommandText=time /T
set Output=
for /f "Usebackq delims=" %%i in (`%CommandText%`) do (
    if "/!Output!/"=="//" (
      set Output=%%i
    )
)
set CurTime=%Output%

set CommandText=date /T
set Output=
for /f "Usebackq delims=" %%i in (`%CommandText%`) do (
    if "/!Output!/"=="//" (
      set Output=%%i
    )
)
set CurDate=%Output%

echo ==================== %CurDate% %CurTime% ====================
echo.

:TIMESTAMP_EXIT
EndLocal & exit /b 0
:: ============================================================================ 
:: ============================================================================ TIMESTAMP END
