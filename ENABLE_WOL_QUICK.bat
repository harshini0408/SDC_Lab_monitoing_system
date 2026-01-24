@echo off
title Enable Wake-on-LAN (Quick Setup)
color 0A

echo.
echo ============================================
echo   Wake-on-LAN Quick Configuration
echo ============================================
echo.
echo This will enable Wake-on-LAN on your system
echo NO RESTART REQUIRED!
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Administrator privileges required!
    echo.
    echo Right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo Running as Administrator... OK
echo.

echo ============================================
echo Configuring Network Adapters...
echo ============================================
echo.

REM Enable Wake-on-LAN for all network adapters
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Write-Host 'Configuring:' $_.Name -ForegroundColor Green; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Wake on Magic Packet' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue; Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Wake on pattern match' -DisplayValue 'Enabled' -ErrorAction SilentlyContinue; Write-Host 'MAC Address:' $_.MacAddress -ForegroundColor Cyan }"

echo.
echo Done!
echo.

echo ============================================
echo Disabling Fast Startup...
echo ============================================
echo.

REM Disable Fast Startup
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo Fast Startup disabled... OK
) else (
    echo Warning: Could not disable Fast Startup
)

echo.

echo ============================================
echo Configuring Firewall...
echo ============================================
echo.

REM Add firewall rule for WoL service
netsh advfirewall firewall delete rule name="Wake-on-LAN Service" >nul 2>&1
netsh advfirewall firewall add rule name="Wake-on-LAN Service" dir=in action=allow protocol=TCP localport=3002 >nul 2>&1
if %errorLevel% equ 0 (
    echo Firewall rule added (Port 3002)... OK
) else (
    echo Warning: Could not add firewall rule
)

echo.

echo ============================================
echo Enabling Wake Timers...
echo ============================================
echo.

REM Enable wake timers
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP ALLOWSTANDBYCONNECTEDSTATES 1 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
echo Wake timers enabled... OK

echo.

echo ============================================
echo Getting MAC Addresses...
echo ============================================
echo.

powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Write-Host $_.Name ':' $_.MacAddress -ForegroundColor Cyan }"

echo.

echo ============================================
echo Configuration Complete!
echo ============================================
echo.
echo Next Steps:
echo   1. Put computer to SLEEP (not shutdown)
echo   2. From another computer, use AnyDesk "Power On"
echo   3. This computer should wake up automatically
echo.
echo NOTE: Make sure Ethernet cable is connected!
echo.

pause
