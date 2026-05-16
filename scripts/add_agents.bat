:: ============================================================================
:: Adds custom agents from templates templates/commands
::
:: Must be executed from the root of the target repo with .git
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

echo:
echo ============================================================================
echo ======================== CUSTOM AGENT INSTALLATION =========================
echo ============================================================================
echo:

set "TARGET_ROOT=%CD%"
set "SOURCE_PREFIX=%~dp0..\templates\commands"
set "ErrorStatus=0"

:: Verify that the current directory is the root of the target repo with .git

if not exist "%TARGET_ROOT%\.git" (
    echo [ERROR] Execute this "%~nx0" script from the target repository root with ".git".
    echo [ERROR] Aborting...
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

:: Verify that templates directory exists

if not exist "%SOURCE_PREFIX%" (
    echo [ERROR] Templates directory not found: "%SOURCE_PREFIX%"
    echo Aborting...
    set "ErrorStatus=1"
    goto :MAIN_EXIT
)

:: Make github dirs

for %%D in ("agents" "prompts") do (
    if not exist "%TARGET_ROOT%\.github\%%~D" (
        md "%TARGET_ROOT%\.github\%%~D" || (
            set "ErrorStatus=!ERRORLEVEL!"
            echo ERROR Failed to create ".github\%%~D". Aborting...
            goto :MAIN_EXIT
        )
    )
)

:: Copy agents

for %%F in ("%SOURCE_PREFIX%\*") do (
    copy /Y /B "%%~F" "%TARGET_ROOT%\.github\agents\%%~nF.agent%%~xF"
    if not "!ERRORLEVEL!"=="0" (
        set "ErrorStatus=!ERRORLEVEL!"
        echo ERROR Failed to install agent. Aborting...
        goto :MAIN_EXIT
    )

    (
        echo ---
        echo agent: %%~nF
        echo ---
    ) > "%TARGET_ROOT%\.github\prompts\%%~nF.prompt%%~xF"
    if not "!ERRORLEVEL!"=="0" (
        set "ErrorStatus=!ERRORLEVEL!"
        echo ERROR Failed to install agent. Aborting...
        goto :MAIN_EXIT
    )
)

set "ErrorStatus=0"

:MAIN_EXIT
if not defined ErrorStatus (set "ErrorStatus=0")
EndLocal & exit /b %ErrorStatus%
:: ============================================================================ 
:: ============================================================================ MAIN END
