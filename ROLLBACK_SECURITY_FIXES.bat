@echo off
setlocal

REM ============================================
REM  ROLLBACK SECURITY FIXES
REM  Emergency Script to Restore Normal Operation
REM ============================================

echo.
echo ============================================
echo   ROLLBACK SECURITY FIXES
echo ============================================
echo.
echo This script will REMOVE all security restrictions:
echo   - Re-enable Task Manager
echo   - Re-enable Ctrl+Alt+Delete screen
echo   - Re-enable Windows Key combinations
echo   - Re-enable Power Button action
echo.
echo Use this ONLY if security fixes are causing issues!
echo.
echo Press Ctrl+C to cancel, or
pause

echo.
echo ============================================
echo   STARTING ROLLBACK...
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

REM Rollback Task Manager
echo [1/4] Re-enabling Task Manager...
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Task Manager re-enabled
) else (
    echo       ℹ️ Task Manager was not disabled
)
echo.

REM Rollback Ctrl+Alt+Delete
echo [2/4] Re-enabling Ctrl+Alt+Delete screen...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Ctrl+Alt+Delete screen re-enabled
) else (
    echo       ℹ️ Ctrl+Alt+Delete was not disabled
)
echo.

REM Rollback Windows Key
echo [3/4] Re-enabling Windows Key...
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Windows Key re-enabled
) else (
    echo       ℹ️ Windows Key was not disabled
)
echo.

REM Rollback Power Button
echo [4/4] Re-enabling Power Button...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PowerButtonAction" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo       ✅ Power Button re-enabled
) else (
    echo       ℹ️ Power Button was not disabled
)
echo.

echo ============================================
echo   ROLLBACK COMPLETE
echo ============================================
echo.
echo ✅ All security restrictions have been removed
echo.
echo IMPORTANT: Restart computer for changes to take effect
echo.
pause

REM Ask for restart
echo.
choice /C YN /M "Do you want to RESTART NOW"
if errorlevel 2 goto :no_restart
if errorlevel 1 goto :do_restart

:do_restart
echo.
echo Restarting in 5 seconds...
timeout /t 5
shutdown /r /t 0
exit /b 0

:no_restart
echo.
echo Remember to restart manually for changes to take effect
echo.
pause
exit /b 0
