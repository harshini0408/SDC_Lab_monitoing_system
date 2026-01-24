@echo off
title Check Wake-on-LAN Status
color 0B

echo.
echo ============================================
echo   Wake-on-LAN Status Check
echo ============================================
echo.

powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Write-Host ''; Write-Host 'Adapter:' $_.Name -ForegroundColor Cyan; Write-Host 'MAC Address:' $_.MacAddress -ForegroundColor Yellow; try { $wol = Get-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Wake on Magic Packet' -ErrorAction SilentlyContinue; if ($wol.DisplayValue -eq 'Enabled') { Write-Host 'Wake-on-LAN: ENABLED' -ForegroundColor Green } else { Write-Host 'Wake-on-LAN: Not Configured' -ForegroundColor Red } } catch { Write-Host 'Wake-on-LAN: Unknown' -ForegroundColor Yellow } }"

echo.
echo ============================================

REM Check Fast Startup
echo.
echo Checking Fast Startup status...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled 2>nul | find "0x0" >nul
if %errorLevel% equ 0 (
    echo Fast Startup: DISABLED [Good for WoL]
) else (
    echo Fast Startup: ENABLED [May affect WoL]
)

echo.
echo ============================================
echo.

pause
