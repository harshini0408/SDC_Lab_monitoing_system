@echo off
REM ==================================================================
REM ADVANCED KIOSK SECURITY - WINDOWS SHELL REPLACEMENT
REM ==================================================================
REM WARNING: This makes the kiosk the Windows shell (replaces explorer.exe)
REM          Use this ONLY if you need MAXIMUM security
REM          The kiosk will launch BEFORE Windows desktop
REM
REM To restore normal Windows: Run RESTORE_EXPLORER_SHELL.bat
REM ==================================================================

echo ================================================
echo   ADVANCED SECURITY: SHELL REPLACEMENT MODE
echo ================================================
echo.
echo WARNING: This will replace Windows Explorer with the kiosk!
echo.
echo Effects:
echo - Kiosk launches IMMEDIATELY after Windows login
echo - NO Windows desktop, taskbar, or start menu
echo - MAXIMUM security - impossible to access Windows
echo - Can only be reversed with administrative access
echo.
echo RECOMMENDED: Only use this on dedicated kiosk systems!
echo.
pause
echo.

REM Backup current shell value
echo [1/3] Backing up current shell configuration...
reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "C:\StudentKiosk\SHELL_BACKUP.reg" /y

REM Get the path to node and create a direct launcher
echo [2/3] Creating shell launcher...
where node > "C:\StudentKiosk\node_path.txt"
set /p NODE_PATH=<"C:\StudentKiosk\node_path.txt"
del "C:\StudentKiosk\node_path.txt"

REM Create a batch file that launches the kiosk directly
(
echo @echo off
echo cd /d C:\StudentKiosk
echo "%NODE_PATH%" "%CD%\node_modules\electron\cli.js" .
) > "C:\StudentKiosk\KIOSK_SHELL_LAUNCHER.bat"

REM Replace Windows Shell with kiosk
echo [3/3] Replacing Windows Shell...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "C:\StudentKiosk\KIOSK_SHELL_LAUNCHER.bat" /f

echo.
echo ================================================
echo   SHELL REPLACEMENT COMPLETE!
echo ================================================
echo.
echo CRITICAL INFORMATION:
echo - Backup saved to: C:\StudentKiosk\SHELL_BACKUP.reg
echo - Shell launcher: C:\StudentKiosk\KIOSK_SHELL_LAUNCHER.bat
echo.
echo On next login:
echo - Kiosk will launch IMMEDIATELY (no desktop)
echo - Windows Explorer will NOT run
echo - Maximum security mode active
echo.
echo To restore Windows Explorer:
echo 1. Boot into Safe Mode (F8 during startup)
echo 2. Run: C:\StudentKiosk\RESTORE_EXPLORER_SHELL.bat
echo    OR
echo 3. Restore registry: C:\StudentKiosk\SHELL_BACKUP.reg
echo.
echo RESTART required for changes to take effect!
echo.
pause
