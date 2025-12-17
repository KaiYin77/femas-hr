@echo off
REM ========================================
REM Femas HR - Test Suite Runner
REM Runs all independent test scripts
REM ========================================

SET SCRIPT_DIR=%~dp0
SET TEST_PASSED=0
SET TEST_FAILED=0
SET TEST_SKIPPED=0

echo ========================================
echo   Femas HR - Test Suite
echo ========================================
echo.
echo Running all tests...
echo.

REM ========================================
REM Check if bash is available
REM ========================================

where bash >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Bash not found! Please install Git for Windows or WSL.
    echo         Download Git: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [INFO] Bash found:
where bash
echo.

REM ========================================
REM Test 1: Bash Installation Test
REM ========================================

echo ========================================
echo [Test 1] Bash Installation Test
echo ========================================
echo.

if exist "%SCRIPT_DIR%test_bash.sh" (
    bash "%SCRIPT_DIR%test_bash.sh"
    if %ERRORLEVEL% EQU 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [SKIP] test_bash.sh not found
    set /a TEST_SKIPPED+=1
)

echo.
pause
echo.

REM ========================================
REM Test 2: RANDOM Distribution Test
REM ========================================

echo ========================================
echo [Test 2] RANDOM Distribution Test
echo ========================================
echo.

if exist "%SCRIPT_DIR%test_random.sh" (
    bash "%SCRIPT_DIR%test_random.sh"
    if %ERRORLEVEL% EQU 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [SKIP] test_random.sh not found
    set /a TEST_SKIPPED+=1
)

echo.
pause
echo.

REM ========================================
REM Test 3: Holiday Configuration Test
REM ========================================

echo ========================================
echo [Test 3] Holiday Configuration Test
echo ========================================
echo.

if not exist "%SCRIPT_DIR%holidays" (
    echo [SKIP] holidays file not found
    echo       Run install.bat or: copy holidays.example holidays
    set /a TEST_SKIPPED+=1
) else if exist "%SCRIPT_DIR%test_holidays.sh" (
    bash "%SCRIPT_DIR%test_holidays.sh"
    if %ERRORLEVEL% EQU 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [SKIP] test_holidays.sh not found
    set /a TEST_SKIPPED+=1
)

echo.
pause
echo.

REM ========================================
REM Test 4: Checkout Sanity Test
REM ========================================

echo ========================================
echo [Test 4] Instant Checkout Test
echo ========================================
echo.

if not exist "%SCRIPT_DIR%.env" (
    echo [SKIP] .env file not found
    echo       Run install.bat first to configure credentials
    set /a TEST_SKIPPED+=1
) else if exist "%SCRIPT_DIR%test_instant_checkout.sh" (
    bash "%SCRIPT_DIR%test_instant_checkout.sh"
    if %ERRORLEVEL% EQU 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [SKIP] test_instant_checkout.sh not found
    set /a TEST_SKIPPED+=1
)

echo.
pause
echo.

REM ========================================
REM Test 5: User ID Inspection Test
REM ========================================

echo ========================================
echo [Test 5] User ID Inspection Test
echo ========================================
echo.

if not exist "%SCRIPT_DIR%.env" (
    echo [SKIP] .env file not found
    echo       Run install.bat first to configure credentials
    set /a TEST_SKIPPED+=1
) else if exist "%SCRIPT_DIR%test_user_id.sh" (
    bash "%SCRIPT_DIR%test_user_id.sh"
    if %ERRORLEVEL% EQU 0 (
        set /a TEST_PASSED+=1
    ) else (
        set /a TEST_FAILED+=1
    )
) else (
    echo [SKIP] test_user_id.sh not found
    set /a TEST_SKIPPED+=1
)

echo.
pause
echo.

REM ========================================
REM Test Summary
REM ========================================

echo ========================================
echo   Test Summary
echo ========================================
echo.
echo Tests Passed:  %TEST_PASSED%
echo Tests Failed:  %TEST_FAILED%
echo Tests Skipped: %TEST_SKIPPED%
echo.

if %TEST_FAILED% EQU 0 (
    echo ========================================
    echo [SUCCESS] All tests passed!
    echo ========================================
) else (
    echo ========================================
    echo [FAILED] Some tests failed
    echo ========================================
)

echo.
pause
exit /b %TEST_FAILED%
