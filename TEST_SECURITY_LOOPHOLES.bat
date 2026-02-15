@echo off
setlocal

REM ============================================
REM  TEST SECURITY FIXES
REM  Verify all security restrictions are active
REM ============================================

echo.
echo ============================================
echo   TESTING SECURITY FIXES
echo ============================================
echo.
echo This script will verify that all security fixes are working:
echo   - Task Manager disabled
echo   - Ctrl+Alt+Delete disabled
echo   - Windows Key disabled
echo   - Power Button disabled
echo.
pause

echo.
echo ============================================
echo   CHECKING SYSTEM STATUS...
echo ============================================
echo.

set PASS_COUNT=0
set FAIL_COUNT=0

REM ============================================
REM TEST #1: Task Manager Status
REM ============================================
echo [1/4] Checking Task Manager status...

reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ PASS - Task Manager is DISABLED
    set /a PASS_COUNT+=1
) else (
    echo       ❌ FAIL - Task Manager is ENABLED ^(SECURITY RISK^)
    set /a FAIL_COUNT+=1
)
echo.

REM ============================================
REM TEST #2: Ctrl+Alt+Delete Status
REM ============================================
echo [2/4] Checking Ctrl+Alt+Delete status...

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ PASS - Ctrl+Alt+Delete is DISABLED
    set /a PASS_COUNT+=1
) else (
    echo       ❌ FAIL - Ctrl+Alt+Delete is ENABLED ^(SECURITY RISK^)
    set /a FAIL_COUNT+=1
)
echo.

REM ============================================
REM TEST #3: Windows Key Status
REM ============================================
echo [3/4] Checking Windows Key status...

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ PASS - Windows Key is DISABLED
    set /a PASS_COUNT+=1
) else (
    echo       ❌ FAIL - Windows Key is ENABLED ^(SECURITY RISK^)
    set /a FAIL_COUNT+=1
)
echo.

REM ============================================
REM TEST #4: Power Button Status
REM ============================================
echo [4/4] Checking Power Button status...

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PowerButtonAction" >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ PASS - Power Button is DISABLED
    set /a PASS_COUNT+=1
) else (
    echo       ⚠️ WARNING - Power Button is ENABLED ^(Minor Risk^)
    set /a FAIL_COUNT+=1
)
echo.

REM ============================================
REM TEST #5: Kiosk Process Status
REM ============================================
echo [5/5] Checking Kiosk application status...

tasklist /FI "IMAGENAME eq student-kiosk.exe" 2>NUL | find /I /N "student-kiosk.exe">NUL
if %errorLevel% equ 0 (
    echo       ✅ PASS - Kiosk application is RUNNING
    set /a PASS_COUNT+=1
) else (
    echo       ⚠️ WARNING - Kiosk application is NOT RUNNING
    set /a FAIL_COUNT+=1
)
echo.

REM ============================================
REM TEST RESULTS
REM ============================================
echo ============================================
echo   TEST RESULTS
echo ============================================
echo.
echo Tests Passed: %PASS_COUNT%
echo Tests Failed: %FAIL_COUNT%
echo.

if %FAIL_COUNT% equ 0 (
    echo ✅✅✅ ALL TESTS PASSED ✅✅✅
    echo.
    echo 🔒 SYSTEM IS FULLY SECURED
    echo    Students cannot:
    echo      - Open Task Manager
    echo      - Access Ctrl+Alt+Delete screen
    echo      - Use Windows Key shortcuts
    echo      - Bypass kiosk via power button
    echo.
) else (
    echo ⚠️⚠️⚠️ SOME TESTS FAILED ⚠️⚠️⚠️
    echo.
    echo 🚨 SECURITY GAPS DETECTED
    echo.
    echo Action Required:
    echo   1. Run DEPLOY_SECURITY_FIXES.bat as Administrator
    echo   2. Restart the computer
    echo   3. Run this test script again
    echo.
)

echo ============================================
echo.

REM ============================================
REM MANUAL TEST INSTRUCTIONS
REM ============================================
echo ============================================
echo   MANUAL TESTING INSTRUCTIONS
echo ============================================
echo.
echo Please manually test the following:
echo.
echo 1. Press Ctrl+Shift+Esc
echo    → Task Manager should NOT open
echo.
echo 2. Press Ctrl+Alt+Delete
echo    → Security screen should NOT appear
echo.
echo 3. Press Windows Key + D
echo    → Desktop should NOT show
echo.
echo 4. Press Windows Key + R
echo    → Run dialog should NOT open
echo.
echo 5. Press Escape key in kiosk
echo    → Taskbar should NOT appear
echo.
echo 6. Press Alt+Tab
echo    → Window switcher should NOT appear
echo.
echo If ANY of the above work, security is compromised!
echo.
echo ============================================
echo.

pause
exit /b %FAIL_COUNT%
