@echo off
title Wake Student Computer
color 0A

echo.
echo ============================================
echo   Wake Student Computer from Admin
echo ============================================
echo.

set /p STUDENT_MAC="Enter Student Computer MAC Address (XX-XX-XX-XX-XX-XX or XX:XX:XX:XX:XX:XX): "

if "%STUDENT_MAC%"=="" (
    echo ERROR: MAC address is required!
    pause
    exit /b 1
)

echo.
echo Sending Wake-on-LAN packet to: %STUDENT_MAC%
echo.

REM Convert format if needed (replace - with :)
set STUDENT_MAC=%STUDENT_MAC:-=:%

echo Using PowerShell to send magic packet...
echo.

powershell -Command "$mac = '%STUDENT_MAC%'; $macBytes = $mac.Split(':') | ForEach-Object { [byte]('0x' + $_) }; $packet = [byte[]](,0xFF * 6); $packet += $macBytes * 16; $client = New-Object System.Net.Sockets.UdpClient; $client.Connect(([System.Net.IPAddress]::Broadcast), 9); try { $client.Send($packet, $packet.Length) | Out-Null; Write-Host 'Wake-on-LAN packet sent successfully!' -ForegroundColor Green; Write-Host 'Waiting for computer to wake up (this may take 10-30 seconds)...' -ForegroundColor Yellow; } catch { Write-Host 'Error sending packet:' $_.Exception.Message -ForegroundColor Red } finally { $client.Close() }"

echo.
echo ============================================
echo   Instructions:
echo ============================================
echo.
echo 1. Wait 10-30 seconds for the computer to wake
echo 2. Check AnyDesk to see if it comes online
echo 3. If it doesn't work, the computer might be:
echo    - Fully powered OFF (not in sleep mode)
echo    - BIOS WoL not enabled (needs physical restart)
echo    - On a different network
echo    - Ethernet cable disconnected
echo.

pause
