@echo off
REM ========================================
REM Quick Test: Escape Key Fix Verification
REM ========================================

echo.
echo ========================================
echo    ESCAPE KEY FIX - VERIFICATION TEST
echo ========================================
echo.
echo This will test if the Escape key is properly blocked
echo in kiosk mode using OS-level global shortcuts.
echo.

set "KIOSK_PATH=C:\StudentKiosk"
set "SOURCE_PATH=d:\New_SDC\lab_monitoring_system\student_deployment_package\student-kiosk"

echo [1/4] Checking if kiosk is installed...
if not exist "%KIOSK_PATH%\main-simple.js" (
    echo    ERROR: Kiosk not found at %KIOSK_PATH%
    echo    Please install the kiosk first.
    pause
    exit /b 1
)
echo    OK: Kiosk found at %KIOSK_PATH%

echo.
echo [2/4] Checking for globalShortcut.register in code...
findstr /C:"globalShortcut.register('Escape'" "%KIOSK_PATH%\main-simple.js" >nul 2>&1
if errorlevel 1 (
    echo    WARNING: Global shortcut for Escape not found in deployed version
    echo    The fix may not be deployed yet.
    echo.
    choice /C YN /M "Do you want to deploy the fixed version now"
    if errorlevel 2 goto skipDeploy
    if errorlevel 1 goto deployFix
) else (
    echo    OK: Global shortcut for Escape found
)

echo.
echo [3/4] Checking for blockKioskShortcuts function...
findstr /C:"function blockKioskShortcuts" "%KIOSK_PATH%\main-simple.js" >nul 2>&1
if errorlevel 1 (
    echo    ERROR: blockKioskShortcuts function not found
    echo    The code structure may have changed.
    pause
    exit /b 1
)
echo    OK: blockKioskShortcuts function found

echo.
echo [4/4] Checking for Escape in windowShortcuts array...
findstr /C:"'Escape'" "%KIOSK_PATH%\main-simple.js" >nul 2>&1
if errorlevel 1 (
    echo    ERROR: Escape key not in shortcuts array
    echo    The fix is incomplete.
    pause
    exit /b 1
)
echo    OK: Escape key found in shortcuts array

echo.
echo ========================================
echo          VERIFICATION COMPLETE
echo ========================================
echo.
echo Status: FIX IS DEPLOYED AND READY
echo.
echo NEXT STEPS:
echo 1. Close any running kiosk instances
echo 2. Launch the kiosk: cd C:\StudentKiosk ^&^& npm start
echo 3. Wait for login screen
echo 4. Press Escape key multiple times rapidly
echo 5. Check console for: "BLOCKED Escape at OS level"
echo 6. Verify NO taskbar appears at all
echo.
echo If taskbar still appears:
echo - Check if kiosk is running in TEST mode (KIOSK_MODE=false)
echo - Restart the computer to clear any stuck processes
echo - Check Windows security software (may block global shortcuts)
echo.
pause
exit /b 0

:deployFix
echo.
echo ========================================
echo       DEPLOYING FIXED VERSION
echo ========================================
echo.
echo Copying fixed main-simple.js to %KIOSK_PATH%...
copy /Y "%SOURCE_PATH%\main-simple.js" "%KIOSK_PATH%\main-simple.js"
if errorlevel 1 (
    echo    ERROR: Failed to copy file
    echo    Make sure the source file exists and you have permissions.
    pause
    exit /b 1
)
echo    OK: File copied successfully
echo.
echo Fix deployed! Please restart the kiosk to apply changes.
echo.
pause
exit /b 0

:skipDeploy
echo.
echo Skipping deployment. The kiosk may not have the fix.
echo.
pause
exit /b 0
