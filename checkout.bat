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

"C:\Program Files\Git\bin\bash.exe" "%SCRIPT_DIR%femas_checkout.sh"

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
