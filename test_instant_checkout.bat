@echo off
REM ========================================
REM Instant Checkout Test (Windows Batch)
REM Tests checkout script without delay
REM ========================================

SET SCRIPT_DIR=%~dp0
SET ENV_FILE=%SCRIPT_DIR%.env

echo ========================================
echo   Instant Checkout Test
echo ========================================
echo.

REM ---- Check if .env file exists ----
if not exist "%ENV_FILE%" (
    echo [FAIL] .env file not found at: %ENV_FILE%
    echo        Please run install.bat first
    echo.
    pause
    exit /b 1
)

echo [INFO] Running checkout script with SKIP_DELAY enabled
echo        This will test credentials without random delay
echo.

REM ---- Run checkout with SKIP_DELAY ----
set SKIP_DELAY=1
call "%SCRIPT_DIR%checkout.bat"
set RESULT=%ERRORLEVEL%
set SKIP_DELAY=

echo.

if %RESULT% EQU 0 (
    echo ========================================
    echo [PASS] Instant checkout test succeeded!
    echo ========================================
    echo.
    echo Your credentials and checkout script are working correctly.
) else (
    echo ========================================
    echo [FAIL] Instant checkout test failed
    echo ========================================
    echo.
    echo Please check:
    echo   - Your credentials in .env file
    echo   - Your network connection
    echo   - The error messages above
)

echo.
pause
exit /b %RESULT%
