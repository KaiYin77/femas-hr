@echo off
REM Femas HR Uninstallation Script for Windows
REM This script will remove scheduled tasks from Task Scheduler

echo ========================================
echo   Femas HR Auto Check-in/out Uninstaller
echo ========================================
echo.

REM ---- Check if running as Administrator ----
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this batch file as Administrator
    echo.
    echo Right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo [WARNING] This will remove the following scheduled tasks:
echo.
echo   - FemasHR Check-in
echo   - FemasHR Check-out
echo.
echo Note: .env file will NOT be deleted
echo.

set /p CONFIRM="Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Cancelled
    pause
    exit /b 0
)

echo.
echo [Step 1/2] Removing check-in task
echo ========================================
echo.

schtasks /Delete /TN "FemasHR Check-in" /F >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Check-in task removed
) else (
    echo [INFO] Check-in task not found (may already be removed)
)

echo.
echo [Step 2/2] Removing check-out task
echo ========================================
echo.

schtasks /Delete /TN "FemasHR Check-out" /F >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Check-out task removed
) else (
    echo [INFO] Check-out task not found (may already be removed)
)

echo.
echo ========================================
echo     Uninstallation Complete!
echo ========================================
echo.
echo [Reminder]
echo.
echo To delete .env file, please remove it manually:
echo   %~dp0.env
echo.
echo To delete log files, please remove them manually:
echo   %%TEMP%%\femas_checkin.log
echo   %%TEMP%%\femas_checkout.log
echo.
pause
