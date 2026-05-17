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

set "CHROME_BIN=G:\ProgramsMisc\Chromium\bin\sync\chrome.exe"
set "TIMEOUT=%WINDIR%\System32\timeout.exe"

cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"
set "SUBS=%PROJECT_ROOT%\implementations"
set "REPO_LIST=%SUBS%\repo_list.md"
set "REPORT=%SUBS%\GitHubStats.md"
set "TGNOTIFY=%PROJECT_ROOT%\scripts\tgnotify.bat"
if not exist "%TGNOTIFY%" (set "TGNOTIFY=")

set "STDOUTLOG=%SUBS%\stdout.log"
set "STDERRLOG=%SUBS%\stderr.log"
del "%STDOUTLOG%" 2>nul
del "%STDERRLOG%" 2>nul

:: Abort on missing implementations directory.

if not exist "%SUBS%" (
    echo {ERROR} Missing implementations directory: "%SUBS%"
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

:: Abort if chrome reference is invalid

if not exist "%CHROME_BIN%" (
    echo {ERROR} Chrome reference is not valid "%CHROME_BIN%"
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

:: Copy custom Copilot agents to repository.

call "%~dp0add_agents.bat"
if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=%ERRORLEVEL%"
    echo {ERROR} Failed to install custom agents.
    goto :MAIN_EXIT
)

:: Generate repository list.

if exist "%REPO_LIST%" (
    del /F /Q "%REPO_LIST%"
    if not "!ERRORLEVEL!"=="0" (
        set "ErrorStatus=!ERRORLEVEL!"
        echo {ERROR} Failed to delete repository list file.
        goto :REPOS_EXIT
    )
)

for /d %%O in ("%SUBS%\*") do (
    for /d %%R in ("%%~fO\*") do (
        cd /d "%%~R"
        call :PROCESS_REPO || (
            set "ErrorStatus=!ERRORLEVEL!"
            echo {ERROR} Failed to perform repo preprocessing "%%~R".
            goto :MAIN_EXIT
        )
    )
)

exit
rundll32 user32.dll,MessageBeep
"%TIMEOUT%" /T 60
if defined TGNOTIFY (call "%TGNOTIFY%" "*[GitHub Stats START]*")
cd /d "%PROJECT_ROOT%"

type "%REPO_LIST%" | copilot ^
    --allow-tool="shell(git:*),write" ^
    --model gpt-5.4 ^
    --effort medium ^
    --agent "github_stats" ^
    --no-ask-user

set "ErrorStatus=%ERRORLEVEL%"

if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=%ERRORLEVEL%"
    echo {ERROR} Failed to collect GitHub stats
    if defined TGNOTIFY (call "%TGNOTIFY%" "*[GitHub Stats FAILED]*")
    goto :MAIN_EXIT
)

if not exist "%REPORT%" (
    set "ErrorStatus=1"
    echo {ERROR} Failed to create "%REPORT%"
    if defined TGNOTIFY (call "%TGNOTIFY%" "*[GitHub Stats FAILED]*")
    goto :MAIN_EXIT
)

if defined TGNOTIFY (call "%TGNOTIFY%" "*[GitHub Stats COMPLETE]*")


:MAIN_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ---------------------------------------------------------------------------- 
:: ============================================================================ MAIN END


:: ============================================================================ PROCESS_REPO BEGIN
:: ----------------------------------------------------------------------------
:PROCESS_REPO
::
SetLocal
set "ErrorStatus=0"

set "ORIGIN="
for /f %%I in ('git remote get-url origin') do (set "URL=%%I")
if "%URL%"=="" (
    set "ErrorStatus=1"
    echo {ERROR} Failed to identify REPO/OWNER. Aborting...
    goto :PROCESS_REPO_EXIT
)
set "URL=%URL:~0,-4%"
set "ORIGIN=%URL:~19%"
echo - %ORIGIN% >>"%REPO_LIST%"
if not "%ERRORLEVEL%"=="0" (
    set "ErrorStatus=%ERRORLEVEL%"
    echo {ERROR} Failed to update repository list file.
    goto :PROCESS_REPO_EXIT
)

echo:
echo ====================== PROCESSING REPO ======================
echo =============================================================
echo ----- REPO: "%ORIGIN%"
echo -------------------------------------------------------------
echo:

set "HOMEPAGE=../../%ORIGIN:/=~%.html"
if not exist "%HOMEPAGE%" ("%CHROME_BIN%" --headless --dump-dom "%URL%" > "%HOMEPAGE%")

set "META={"repo":"%ORIGIN%""

:: Extract fork count

set "FORK_COUNT="
set "PATTERN=s/.*id=.repo-network-counter.[^>]*title=.\([0-9,][0-9,]*\).*/\1/p"
for /f "usebackq delims=" %%M in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "FORK_COUNT=%%M"
)
set "FORK_COUNT=%FORK_COUNT:,=%"
set "META=%META%, "forks": %FORK_COUNT%"

:: Extract star count

set "STAR_COUNT="
set "PATTERN=s/.*id=.repo-stars-counter-star.[^>]*title=.\([0-9,][0-9,]*\).*/\1/p"
for /f "usebackq delims=" %%M in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "STAR_COUNT=%%M"
)
set "STAR_COUNT=%STAR_COUNT:,=%"
set "META=%META%, "stars": %STAR_COUNT%"

set "RELEASES="
set "PATTERN=/\/releases/{:loop; /<\/a>/b match; N; b loop; :match; s/\n//g; s/.*\/releases[^>]*>[ \t]*Releases.*<span[^>]*title=.\([0-9,]*\).*/\1/p;}"
for /f "usebackq" %%A in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "RELEASES=%%A"
)
if not defined RELEASES (set "RELEASES=0")
set "META=%META%, "releases": %RELEASES%"

set "CONTRIBUTORS="
set "PATTERN=/\/contributors/{:loop; /<\/a>/b match; N; b loop; :match; s/\n//g; s/.*\/contributors[^>]*>[ \t]*Contributors.*<span[^>]*title=.\([0-9,]*\).*/\1/p;}"
for /f "usebackq" %%A in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "CONTRIBUTORS=%%A"
)
if not defined CONTRIBUTORS (set "CONTRIBUTORS=0")
set "META=%META%, "contributors": %CONTRIBUTORS%"

set "WATCHERS="
set "PATTERN=/\/watchers/{:loop; /<\/a>/b match; N; b loop; :match; s/\n//g; s/.*\/watchers[^>]*>.*<strong>\([0-9,]*\)<\/strong>.*/\1/p;}"
for /f "usebackq" %%A in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "WATCHERS=%%A"
)
set "META=%META%, "watchers": %WATCHERS%"

set "LNGS="
set "PATTERN=/search?l=/{:loop; /<\/a>/b match; N; b loop; :match; s/\n//g; s/.*search?l=[^>]*>.*text-bold[^>]*>\([^<]*\)<\/span>[ \t]*<span>\([^<]*\)<\/span>.*/\1|\2/p;}"
for /f "usebackq tokens=1,2 delims=|" %%A in (`sed -n "%PATTERN%" "%HOMEPAGE%"`) do (
    set "LNGS=!LNGS!, "%%A": "%%B""
)
if defined LNGS (
    set "LNGS={%LNGS:~2%}"
) else (
    set "LNGS={}"
)

set "META=%META%, "languages": %LNGS%"

set "META=%META%}"

echo   %META% >>"%REPO_LIST%"

"%TIMEOUT%" /T 5

echo:
echo ----- DONE: "%ORIGIN%"
echo -------------------------------------------------------------
echo:

:PROCESS_REPO_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ---------------------------------------------------------------------------- 
:: ============================================================================ PROCESS_REPO END
