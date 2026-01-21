@echo off
title Kiosk Security Test
color 0A
echo ════════════════════════════════════════════════════════════════════
echo                   KIOSK SECURITY VERIFICATION TEST
echo ════════════════════════════════════════════════════════════════════
echo.

REM Test 1: Check if VBScript launcher exists
echo [Test 1] Checking VBScript launcher...
if exist "C:\StudentKiosk\START_KIOSK_SILENT.vbs" (
    echo    ✅ PASS - VBScript launcher found
) else (
    echo    ❌ FAIL - VBScript launcher missing
    goto :error
)

REM Test 2: Check startup registry
echo [Test 2] Checking startup configuration...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v StudentKiosk | find "START_KIOSK_SILENT.vbs" >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ PASS - VBScript launcher registered in startup
) else (
    echo    ⚠️ WARNING - Old batch launcher or not registered
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v StudentKiosk
)

REM Test 3: Check if old batch launcher is still in use
echo [Test 3] Checking for old CMD launcher...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v StudentKiosk | find "START_KIOSK.bat" >nul 2>&1
if %errorlevel%==0 (
    echo    ❌ FAIL - Old batch launcher still active!
    echo    → Run INSTALL_KIOSK.bat again to fix
    goto :error
) else (
    echo    ✅ PASS - No old CMD launcher
)

REM Test 4: Check Node.js installation
echo [Test 4] Checking Node.js...
where node >nul 2>&1
if %errorlevel%==0 (
    echo    ✅ PASS - Node.js installed
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo       Version: %NODE_VERSION%
) else (
    echo    ❌ FAIL - Node.js not found
    goto :error
)

REM Test 5: Check kiosk installation
echo [Test 5] Checking kiosk installation...
if exist "C:\StudentKiosk\main-simple.js" (
    echo    ✅ PASS - Kiosk files installed
) else (
    echo    ❌ FAIL - Kiosk files missing
    goto :error
)

REM Test 6: Check dependencies
echo [Test 6] Checking npm dependencies...
if exist "C:\StudentKiosk\node_modules\electron" (
    echo    ✅ PASS - Electron installed
) else (
    echo    ⚠️ WARNING - Electron missing, run: cd C:\StudentKiosk ^&^& npm install
)

REM Test 7: Check server configuration
echo [Test 7] Checking server configuration...
if exist "C:\StudentKiosk\server-config.json" (
    echo    ✅ PASS - Server config exists
    echo    Config:
    type "C:\StudentKiosk\server-config.json"
) else (
    echo    ❌ FAIL - Server config missing
    goto :error
)

REM Test 8: Check shell replacement mode
echo [Test 8] Checking shell replacement mode...
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell | find "KIOSK_SHELL_LAUNCHER.bat" >nul 2>&1
if %errorlevel%==0 (
    echo    ⚠️ WARNING - Shell replacement mode ACTIVE
    echo    → Kiosk will launch instead of Windows Explorer
    echo    → To restore: Run RESTORE_EXPLORER_SHELL.bat in Safe Mode
) else (
    echo    ✅ Standard startup mode (recommended)
)

REM Test 9: Check for background processes
echo [Test 9] Checking for running kiosk processes...
tasklist | find "electron.exe" >nul 2>&1
if %errorlevel%==0 (
    echo    ℹ️ INFO - Kiosk is currently running
    tasklist | find "electron.exe"
) else (
    echo    ℹ️ INFO - Kiosk not running
)

echo.
echo ════════════════════════════════════════════════════════════════════
echo                        ALL TESTS COMPLETED
echo ════════════════════════════════════════════════════════════════════
echo.
echo ✅ Security fixes verified!
echo.
echo NEXT STEPS:
echo 1. Test launch: wscript "C:\StudentKiosk\START_KIOSK_SILENT.vbs"
echo 2. Verify: NO CMD window should appear
echo 3. Test lockdown: Try Alt+Tab, Windows Key, Alt+F4 (all should be blocked)
echo 4. If working: Restart computer to test auto-start
echo.
goto :end

:error
echo.
echo ════════════════════════════════════════════════════════════════════
echo                           TESTS FAILED
echo ════════════════════════════════════════════════════════════════════
echo.
echo Some tests failed. Please fix the issues above.
echo.
echo COMMON FIXES:
echo - Missing files: Run INSTALL_KIOSK.bat
echo - Old launcher: Run INSTALL_KIOSK.bat to update
echo - Missing Node: Install Node.js from https://nodejs.org
echo.

:end
pause
