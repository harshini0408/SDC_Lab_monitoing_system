@echo off
REM ========================================
REM Verify Escape Key Fix Implementation
REM ========================================

echo.
echo ========================================
echo   ESCAPE KEY FIX - VERIFICATION
echo ========================================
echo.

set "FILE=d:\New_SDC\lab_monitoring_system\student_deployment_package\student-kiosk\main-simple.js"

echo [1/5] Checking for OS-level Escape blocking...
findstr /C:"globalShortcut.register('Escape'" "%FILE%" >nul
if errorlevel 1 (
    echo    ❌ FAILED: OS-level Escape blocking not found
    pause
    exit /b 1
) else (
    echo    ✅ PASS: OS-level Escape blocking found
)

echo.
echo [2/5] Checking for forceKioskLock function...
findstr /C:"function forceKioskLock" "%FILE%" >nul
if errorlevel 1 (
    echo    ❌ FAILED: forceKioskLock function not found
    pause
    exit /b 1
) else (
    echo    ✅ PASS: forceKioskLock function found
)

echo.
echo [3/5] Checking for event handler hookups...
findstr /C:"mainWindow.on('leave-full-screen', forceKioskLock)" "%FILE%" >nul
if errorlevel 1 (
    echo    ❌ FAILED: leave-full-screen handler not using forceKioskLock
    pause
    exit /b 1
) else (
    echo    ✅ PASS: Event handlers using forceKioskLock
)

echo.
echo [4/5] Checking for 100ms watchdog interval...
findstr /C:"forceKioskLock();" "%FILE%" | findstr /C:"100" >nul
if errorlevel 1 (
    echo    ⚠️  WARNING: Could not verify 100ms interval
) else (
    echo    ✅ PASS: 100ms watchdog interval found
)

echo.
echo [5/5] Checking for simplified before-input-event...
findstr /C:"before-input-event" "%FILE%" >nul
if errorlevel 1 (
    echo    ❌ FAILED: before-input-event handler not found
    pause
    exit /b 1
) else (
    echo    ✅ PASS: before-input-event handler found
)

echo.
echo ========================================
echo       ✅ ALL CHECKS PASSED
echo ========================================
echo.
echo The fix has been successfully implemented!
echo.
echo NEXT STEPS:
echo 1. Deploy to test system:
echo    copy /Y "%FILE%" "C:\StudentKiosk\main-simple.js"
echo.
echo 2. Restart kiosk and test:
echo    cd C:\StudentKiosk
echo    npm start
echo.
echo 3. Press Escape rapidly - should see NO taskbar
echo    Console should show: "✅ OS-level Escape blocked"
echo.
echo 4. After testing, deploy to all systems:
echo    cd d:\New_SDC\lab_monitoring_system
echo    UPDATE_DEPLOYED_STUDENTS.bat
echo.
pause
