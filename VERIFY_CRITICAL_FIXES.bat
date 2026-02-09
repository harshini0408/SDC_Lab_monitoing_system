@echo off
REM ========================================
REM Verify Critical Escape Key Fixes
REM ========================================

echo.
echo ========================================
echo   CRITICAL FIXES VERIFICATION
echo ========================================
echo.

set "FILE=d:\New_SDC\lab_monitoring_system\student_deployment_package\student-kiosk\main-simple.js"

echo [1/5] Checking forceKioskLock is declared at top of createWindow...
findstr /N "function createWindow" "%FILE%" > temp1.txt
findstr /N "function forceKioskLock" "%FILE%" > temp2.txt
for /f "tokens=1 delims=:" %%a in (temp1.txt) do set CREATE_LINE=%%a
for /f "tokens=1 delims=:" %%a in (temp2.txt) do set FORCE_LINE=%%a
del temp1.txt temp2.txt

if %FORCE_LINE% GTR %CREATE_LINE% (
    if %FORCE_LINE% LSS 200 (
        echo    ✅ PASS: forceKioskLock declared at line %FORCE_LINE% ^(inside createWindow at %CREATE_LINE%^)
    ) else (
        echo    ❌ FAIL: forceKioskLock declared too late at line %FORCE_LINE%
        pause
        exit /b 1
    )
) else (
    echo    ❌ FAIL: forceKioskLock not inside createWindow
    pause
    exit /b 1
)

echo.
echo [2/5] Checking Escape is NOT in blockKioskShortcuts array...
findstr /C:"'Escape'" "%FILE%" | findstr /C:"windowShortcuts" >nul
if errorlevel 1 (
    echo    ✅ PASS: Escape not in windowShortcuts array
) else (
    echo    ❌ FAIL: Escape still in windowShortcuts array
    pause
    exit /b 1
)

echo.
echo [3/5] Checking only ONE Escape registration exists...
findstr /C:"globalShortcut.register('Escape'" "%FILE%" > temp.txt
for /f %%a in ('type temp.txt ^| find /c /v ""') do set COUNT=%%a
del temp.txt

if "%COUNT%"=="1" (
    echo    ✅ PASS: Exactly 1 Escape registration found
) else (
    echo    ❌ FAIL: Found %COUNT% Escape registrations ^(should be 1^)
    pause
    exit /b 1
)

echo.
echo [4/5] Checking only ONE blur handler exists...
findstr /C:"mainWindow.on('blur'" "%FILE%" > temp.txt
for /f %%a in ('type temp.txt ^| find /c /v ""') do set COUNT=%%a
del temp.txt

if "%COUNT%"=="1" (
    echo    ✅ PASS: Exactly 1 blur handler found
) else (
    echo    ❌ FAIL: Found %COUNT% blur handlers ^(should be 1^)
    pause
    exit /b 1
)

echo.
echo [5/5] Checking blur handler uses forceKioskLock...
findstr /C:"mainWindow.on('blur', forceKioskLock)" "%FILE%" >nul
if errorlevel 1 (
    echo    ❌ FAIL: blur handler doesn't use forceKioskLock
    pause
    exit /b 1
) else (
    echo    ✅ PASS: blur handler correctly uses forceKioskLock
)

echo.
echo ========================================
echo       ✅ ALL CRITICAL FIXES VERIFIED
echo ========================================
echo.
echo All 3 critical issues have been fixed:
echo  ✅ forceKioskLock declared before use
echo  ✅ Escape registered only once
echo  ✅ Only one blur handler
echo.
echo READY FOR DEPLOYMENT!
echo.
echo NEXT STEPS:
echo 1. Deploy to test system:
echo    copy /Y "%FILE%" "C:\StudentKiosk\main-simple.js"
echo.
echo 2. Restart kiosk and test Escape key
echo    - Should see NO taskbar at all
echo    - Console: "✅ OS-level Escape blocked"
echo.
echo 3. Deploy to all systems after successful test
echo.
pause
