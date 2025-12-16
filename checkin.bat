@echo off
REM FemasHR Check-in Batch Wrapper for Windows
REM This calls the bash script using Git Bash

SET SCRIPT_DIR=%~dp0
SET LOG_FILE=%TEMP%\femas_checkin.log

echo ========================================
echo    Femas Cloud - CHECK-IN Process
echo ========================================
echo Time: %date% %time%
echo Log: %LOG_FILE%
echo ========================================
echo.

echo [%date% %time%] Starting Femas check-in...
echo [%date% %time%] Starting Femas check-in... >> "%LOG_FILE%"

"C:\Program Files\Git\bin\bash.exe" "%SCRIPT_DIR%femas_checkin.sh"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Check-in completed successfully!
    echo [%date% %time%] Check-in completed successfully >> "%LOG_FILE%"
) else (
    echo.
    echo [ERROR] Check-in failed with error code %ERRORLEVEL%
    echo [%date% %time%] Check-in failed with error code %ERRORLEVEL% >> "%LOG_FILE%"
)

echo.
echo ========================================
