:: ============================================================================
:: Iterates through submodules in "implementations" and runs project onboarding
:: ============================================================================
::
@echo off


:: ============================================================================ MAIN BEGIN
:: ============================================================================
:MAIN

SetLocal EnableExtensions EnableDelayedExpansion
set "ExitStatus=0"

cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"
set "SUBS=%PROJECT_ROOT%\implementations"
cd /d "%SUBS%"

set "STDOUTLOG=%SUBS%\stdout.log"
set "STDERRLOG=%SUBS%\stderr.log"
del "%STDOUTLOG%" 2>nul
del "%STDERRLOG%" 2>nul


(
    call :TIMESTAMP

    for /d %%D in (*) do (
        call :ONBOARD_SUBMODULE "%%~D"
        if not "!ERRORLEVEL!"=="0" (set "ExitStatus=1")
    )


) 1>>"%STDOUTLOG%" 2>>"%STDERRLOG%"


:MAIN_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal
exit /b %ErrorStatus%
:: ============================================================================ 
:: ============================================================================ MAIN END


:: ============================================================================ ONBOARD_SUBMODULE BEGIN
:: ============================================================================
:ONBOARD_SUBMODULE
:: Runs onboarding analysis on submodule.
::
:: Analysis uses a custom Copilot agent "project_onboarding".
::
:: Script must copy the contents
::    of "docs/Repo Understanding/GitHub Agent"
::    to implementations/[SUB_OWNER]/[SUB_REPO]/.github
::
:: Expects: 
::   - each submodule to be analyzed is in [REPO_ROOT]/implementations/[SUB_OWNER]/[SUB_REPO];
::   - [SUB_REPO] is the only directory in its parent directory (no sibling directories);
::   - [SUB_OWNER] contains:
::       - before onboarding: no files
::       - after onboarding: OnboardingReport.md and ONBOARDING.md 
::
:: Call this sub with argument(s):
::   - %1 - Submodule OWNER
::
SetLocal
pushd "%CD%" || exit /b 1

set "SUB_OWNER=%~1"
set "PREFIX=%PROJECT_ROOT%\implementations\%SUB_OWNER%"
set "ErrorStatus=0"

echo ======================== ONBOARDING =========================
echo =============================================================
echo ----- SUBMODULE: "%SUB_OWNER%"
echo -------------------------------------------------------------
echo:
call :TIMESTAMP
echo:

:: Skip submodule onboarding if directory does not exists.

if not exist "%PREFIX%" (
    echo ERROR: Submodule directory "%PREFIX%" NOT FOUND.
    echo Skipping submodule onboarding.
    set "ErrorStatus=1"
    goto :ONBOARD_SUBMODULE_EXIT
)
cd /d "%PREFIX%"

:: Skip submodule onboarding if exists "%SUB_OWNER%\OnboardingReport.md"

if exist "OnboardingReport.md" (
    echo Found existing "OnboardingReport.md".
    echo Skipping submodule onboarding.
    set "ErrorStatus=0"
    goto :ONBOARD_SUBMODULE_EXIT
)

:: Get [SUB_REPO]

for /d %%D in (*) do (set "SUB_REPO=%%~D")
cd /d "%SUB_REPO%"

if not exist ".github" mkdir ".github"
if not "%ERRORLEVEL%"=="0" (
  set "ErrorStatus=%ERRORLEVEL%"
  echo ERROR Failed to create ".github". Skipping submodule...
  goto :ONBOARD_SUBMODULE_EXIT
)

:: Copy custom onboarding agent to submodule repository

xcopy /H /Y /B /E /Q "%PROJECT_ROOT%\docs\Repo Understanding\GitHub Agent\*" ".github"
if not "%ERRORLEVEL%"=="0" (
  set "ErrorStatus=%ERRORLEVEL%"
  echo ERROR Failed to copy onboarding agent to submodule repository. Skipping submodule...
  goto :ONBOARD_SUBMODULE_EXIT
)

:: Run onboarding

if not exist "%PROJECT_ROOT%\docs\karpathy\llm-wiki.md" (
    echo ERROR Missing input prompt.
    set "ErrorStatus=1"
    goto :ONBOARD_SUBMODULE_EXIT
)

call type "%PROJECT_ROOT%\docs\karpathy\llm-wiki.md" | copilot ^
    --allow-tool="shell(git:*),write" ^
    --model gpt-5.4 ^
    --effort medium ^
    --agent "project_onboarding" ^
    --no-ask-user

set "ErrorStatus=%ERRORLEVEL%"

if not "%ERRORLEVEL%"=="0" (
  echo ERROR Failed to complete onboarding via Copilot CLI. Skipping submodule...
  goto :ONBOARD_SUBMODULE_EXIT
)

if exist "OnboardingReport.md" move /Y "OnboardingReport.md" ..
if not "%ERRORLEVEL%"=="0" (
  set "ErrorStatus=%ERRORLEVEL%"
  echo ERROR Failed to move "OnboardingReport.md"...
  goto :ONBOARD_SUBMODULE_EXIT
)

if exist "ONBOARDING.md" move /Y "ONBOARDING.md" ..
if not "%ERRORLEVEL%"=="0" (
  set "ErrorStatus=%ERRORLEVEL%"
  echo ERROR Failed to move "ONBOARDING.md"...
  goto :ONBOARD_SUBMODULE_EXIT
)


:ONBOARD_SUBMODULE_EXIT
echo _____________________________________________________________
echo:
popd
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ============================================================================ 
:: ============================================================================ ONBOARD_SUBMODULE END


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
