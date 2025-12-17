@echo off
REM FemasHR Check-out Batch Wrapper for Windows
REM This calls the bash script using Git Bash

SET SCRIPT_DIR=%~dp0
SET LOG_FILE=%TEMP%\femas_checkout.log

echo ========================================
echo    Femas Cloud - CHECK-OUT Process
echo ========================================
echo Time: %date% %time%
echo Log: %LOG_FILE%
echo ========================================
echo.

echo [%date% %time%] Starting Femas check-out...
echo [%date% %time%] Starting Femas check-out... >> "%LOG_FILE%"

REM Try to find bash in PATH first
where bash >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    bash -c "SKIP_DELAY=%SKIP_DELAY% '%SCRIPT_DIR%femas_checkout.sh'"
    goto :check_result
)

REM Check Git Bash in common locations
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" -c "SKIP_DELAY=%SKIP_DELAY% '%SCRIPT_DIR%femas_checkout.sh'"
    goto :check_result
)

if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" -c "SKIP_DELAY=%SKIP_DELAY% '%SCRIPT_DIR%femas_checkout.sh'"
    goto :check_result
)

REM Check WSL
where wsl >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    wsl bash -c "SKIP_DELAY=%SKIP_DELAY% '%SCRIPT_DIR%femas_checkout.sh'"
    goto :check_result
)

REM If we get here, bash wasn't found
echo [ERROR] Bash not found! Please install Git for Windows or WSL.
echo [ERROR] Download Git: https://git-scm.com/download/win
echo [%date% %time%] ERROR: Bash not found >> "%LOG_FILE%"
exit /b 1

:check_result
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Check-out completed successfully!
    echo [%date% %time%] Check-out completed successfully >> "%LOG_FILE%"
) else (
    echo.
    echo [ERROR] Check-out failed with error code %ERRORLEVEL%
    echo [%date% %time%] Check-out failed with error code %ERRORLEVEL% >> "%LOG_FILE%"
)

echo.
echo ========================================
