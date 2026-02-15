@echo off
setlocal enabledelayedexpansion

REM ============================================
REM  DEPLOY CRITICAL SECURITY FIXES
REM  Lab Monitoring System - Security Hardening
REM ============================================

echo.
echo ============================================
echo   CRITICAL SECURITY FIXES DEPLOYMENT
echo ============================================
echo.
echo This script will apply the following security fixes:
echo   1. Disable Task Manager (blocks Ctrl+Shift+Esc)
echo   2. Disable Ctrl+Alt+Delete screen
echo   3. Disable Windows Key combinations
echo   4. Disable Power Button action
echo.
echo WARNING: These changes require ADMINISTRATOR PRIVILEGES
echo          and a SYSTEM RESTART to take full effect.
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo ============================================
echo   STARTING DEPLOYMENT...
echo ============================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERROR: This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo ✅ Administrator privileges confirmed
echo.

REM ============================================
REM FIX #1: Disable Task Manager
REM ============================================
echo [1/4] Disabling Task Manager...
echo       Blocking: Ctrl+Shift+Esc

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Task Manager disabled successfully
) else (
    echo       ⚠️ WARNING: Failed to disable Task Manager
    set ERROR_COUNT=1
)
echo.

REM ============================================
REM FIX #2: Disable Ctrl+Alt+Delete Screen
REM ============================================
echo [2/4] Disabling Ctrl+Alt+Delete security screen...
echo       Blocking: Ctrl+Alt+Del

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Ctrl+Alt+Delete screen disabled successfully
) else (
    echo       ⚠️ WARNING: Failed to disable Ctrl+Alt+Delete
    set ERROR_COUNT=1
)
echo.

REM ============================================
REM FIX #3: Disable Windows Key
REM ============================================
echo [3/4] Disabling Windows Key combinations...
echo       Blocking: Win+D, Win+R, Win+X, Win+L, etc.

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d 00000000000000000300000000005BE000005CE00000000000 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Windows Key disabled successfully
) else (
    echo       ⚠️ WARNING: Failed to disable Windows Key
    set ERROR_COUNT=1
)
echo.

REM ============================================
REM FIX #4: Disable Power Button Action
REM ============================================
echo [4/4] Disabling Power Button action...
echo       Power button will be ignored

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PowerButtonAction" /t REG_DWORD /d 0 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Power Button disabled successfully
) else (
    echo       ⚠️ WARNING: Failed to disable Power Button
    set ERROR_COUNT=1
)
echo.

REM ============================================
REM DEPLOYMENT COMPLETE
REM ============================================
echo ============================================
echo   DEPLOYMENT COMPLETE
echo ============================================
echo.

if defined ERROR_COUNT (
    echo ⚠️ PARTIAL SUCCESS: Some fixes could not be applied
    echo    Please check the warnings above.
    echo.
) else (
    echo ✅ ALL SECURITY FIXES APPLIED SUCCESSFULLY
    echo.
)

echo IMPORTANT: 
echo   - Changes will take effect after SYSTEM RESTART
echo   - Test on ONE computer before deploying to all 60 systems
echo   - Keep ROLLBACK_SECURITY_FIXES.bat available in case of issues
echo.
echo ============================================
echo.

REM Ask for restart
echo.
choice /C YN /M "Do you want to RESTART NOW to apply changes"
if errorlevel 2 goto :no_restart
if errorlevel 1 goto :do_restart

:do_restart
echo.
echo Restarting in 10 seconds...
echo Press Ctrl+C to cancel
timeout /t 10
shutdown /r /t 0
exit /b 0

:no_restart
echo.
echo ⚠️ Remember to restart manually for changes to take effect
echo.
pause
exit /b 0
