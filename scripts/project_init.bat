:: ============================================================================
:: Collects GitHub metrics for specified list of repositories.
::
:: https://chatgpt.com/c/6a045362-cb44-83eb-abdd-d7d04f67e030
:: ============================================================================
::
@echo off

:: ============================================================================ MAIN BEGIN
:: ----------------------------------------------------------------------------
:MAIN

SetLocal EnableExtensions EnableDelayedExpansion
set "ErrorStatus=0"

set "TIMEOUT=%WINDIR%\System32\timeout.exe"

cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"
set "INSTRUCTIONS=%PROJECT_ROOT%\.github\copilot-instructions.md"
set AGENT_TOOLS=github(*), write, memory, web_fetch, web_search, skill, sql,^
    shell(bash:*),^
    shell(cmd:*),^
    shell(python:*),^
    shell(pytest:*),^
    shell(npm:*), ^
    shell(git:*),^
    shell(gh:*),^
    shell(curl:*)    

rundll32 user32.dll,MessageBeep
"%TIMEOUT%" /T 60
cd /d "%PROJECT_ROOT%"

copilot -p "/init" ^
    --model=gpt-5.4 ^
    --effort=medium ^
    --reasoning-effort=medium ^
    --allow-tool="%AGENT_TOOLS%" ^
    --allow-all-urls ^
    --enable-all-github-mcp-tools ^
    --log-level=all ^
    --no-ask-user

set "ErrorStatus=%ERRORLEVEL%"

if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=%ERRORLEVEL%"
    echo {ERROR} Failed to init project.
    goto :MAIN_EXIT
)

if not exist "%INSTRUCTIONS%" (
    set "ErrorStatus=1"
    echo {ERROR} Failed to create "%INSTRUCTIONS%"
    goto :MAIN_EXIT
)

:MAIN_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ---------------------------------------------------------------------------- 
:: ============================================================================ MAIN END
