@echo off
title Wake-on-LAN Troubleshooting
color 0E

echo.
echo ============================================
echo   Wake-on-LAN Troubleshooting
echo ============================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Administrator privileges required!
    echo Right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo [1/7] Checking Network Adapters...
echo ----------------------------------------
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Write-Host 'Name:' $_.Name -ForegroundColor Cyan; Write-Host 'MAC:' $_.MacAddress -ForegroundColor Yellow; Write-Host 'Status:' $_.Status -ForegroundColor Green; Write-Host '' }"

echo.
echo [2/7] Checking WoL Registry Settings...
echo ----------------------------------------
powershell -Command "$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}; foreach ($adapter in $adapters) { try { $wol = Get-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName 'Wake on Magic Packet' -ErrorAction SilentlyContinue; if ($wol) { Write-Host $adapter.Name':' $wol.DisplayValue -ForegroundColor $(if($wol.DisplayValue -eq 'Enabled'){'Green'}else{'Red'}) } else { Write-Host $adapter.Name': Not supported' -ForegroundColor Yellow } } catch { Write-Host $adapter.Name': Error checking' -ForegroundColor Red } }"

echo.
echo [3/7] Checking Power Management...
echo ----------------------------------------
powershell -Command "$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}; foreach ($adapter in $adapters) { $powerMgmt = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi -ErrorAction SilentlyContinue | Where-Object {$_.InstanceName -like '*'+$adapter.DeviceID+'*'}; if ($powerMgmt) { if ($powerMgmt.Enable) { Write-Host $adapter.Name': Power wake ENABLED' -ForegroundColor Green } else { Write-Host $adapter.Name': Power wake DISABLED' -ForegroundColor Red } } }"

echo.
echo [4/7] Checking Fast Startup...
echo ----------------------------------------
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled 2>nul | find "0x0" >nul
if %errorLevel% equ 0 (
    echo Fast Startup: DISABLED [Good] 
) else (
    echo Fast Startup: ENABLED [Bad for WoL] - FIXING...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1
    echo Fast Startup: NOW DISABLED
)

echo.
echo [5/7] Checking Firewall Rules...
echo ----------------------------------------
netsh advfirewall firewall show rule name="Wake-on-LAN Service" >nul 2>&1
if %errorLevel% equ 0 (
    echo Firewall: Port 3002 is OPEN
) else (
    echo Firewall: Port 3002 NOT configured - FIXING...
    netsh advfirewall firewall add rule name="Wake-on-LAN Service" dir=in action=allow protocol=TCP localport=3002 >nul 2>&1
    echo Firewall: NOW CONFIGURED
)

echo.
echo [6/7] Enabling Device Wake Permissions...
echo ----------------------------------------
powershell -Command "$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}; foreach ($adapter in $adapters) { $device = Get-WmiObject Win32_NetworkAdapter | Where-Object {$_.GUID -eq $adapter.InterfaceGuid}; if ($device) { $pnpEntity = Get-WmiObject Win32_PnPEntity | Where-Object {$_.DeviceID -eq $device.PNPDeviceID}; if ($pnpEntity) { Write-Host 'Enabling wake for:' $adapter.Name -ForegroundColor Cyan; $powerMgmt = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi | Where-Object {$_.InstanceName -like '*'+$device.PNPDeviceID+'*'}; if ($powerMgmt) { $powerMgmt.Enable = $true; $powerMgmt.Put() | Out-Null; Write-Host 'Wake enabled for' $adapter.Name -ForegroundColor Green } } } }"

echo.
echo [7/7] Checking AnyDesk Service...
echo ----------------------------------------
sc query AnyDesk >nul 2>&1
if %errorLevel% equ 0 (
    echo AnyDesk Service: INSTALLED
    sc query AnyDesk | find "RUNNING" >nul
    if %errorLevel% equ 0 (
        echo AnyDesk Status: RUNNING
    ) else (
        echo AnyDesk Status: NOT RUNNING - STARTING...
        sc start AnyDesk >nul 2>&1
        echo AnyDesk: NOW STARTED
    )
) else (
    echo AnyDesk Service: NOT INSTALLED
    echo Install AnyDesk with "Install as Service" option!
)

echo.
echo ============================================
echo   CRITICAL CHECKS
echo ============================================
echo.

echo IMPORTANT: For AnyDesk Power On to work:
echo.
echo 1. BIOS/UEFI Settings (REQUIRES RESTART):
echo    - Restart computer and enter BIOS
echo    - Find "Wake on LAN" or "PME Event Wake Up"
echo    - Set to ENABLED
echo    - Save and exit
echo.
echo 2. Power State:
echo    - Use SLEEP mode (NOT full shutdown)
echo    - From Start Menu: Power ^> Sleep
echo    - OR: Close laptop lid (if configured for sleep)
echo.
echo 3. Network Connection:
echo    - MUST use Ethernet cable (Wi-Fi WoL is unreliable)
echo    - Cable must stay connected when sleeping
echo.
echo 4. AnyDesk Configuration:
echo    - AnyDesk must be installed as SERVICE
echo    - Not just as user application
echo.
echo 5. Same Network:
echo    - Both computers must be on same LAN
echo    - Not across VPN or different networks
echo.

echo ============================================
echo   RECOMMENDED NEXT STEPS
echo ============================================
echo.
echo [STEP 1] Restart computer and enable WoL in BIOS
echo          Look for: "Wake on LAN", "PME Event", "Power On by PCI-E"
echo.
echo [STEP 2] Put computer to SLEEP (not shutdown)
echo          Win+X ^> Sleep
echo.
echo [STEP 3] From another PC, open AnyDesk and click Power On
echo.

echo ============================================
echo.

echo MAC Address for manual WoL:
powershell -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 | ForEach-Object { Write-Host $_.MacAddress -ForegroundColor Yellow }"

echo.
pause
