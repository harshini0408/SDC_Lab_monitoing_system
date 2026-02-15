@echo off
title Today's Admin Password - Lab Monitoring System
color 0A

echo ============================================================
echo    TODAY'S ADMIN PASSWORD - LAB MONITORING SYSTEM
echo ============================================================
echo.
echo [*] Fetching today's 4-digit admin password...
echo.

REM Start server temporarily if not running
cd "%~dp0central-admin\server"
start /min cmd /c "node app.js > nul 2>&1"
timeout /t 3 /nobreak > nul

REM Fetch password from API
powershell -Command "try { $response = Invoke-RestMethod -Uri 'http://localhost:7401/api/guest-password' -Method Get; Write-Host ''; Write-Host '============================================================' -ForegroundColor Green; Write-Host '   TODAY''S ADMIN PASSWORD (14 Feb 2026):' -ForegroundColor Cyan; Write-Host '   ' $response.password -ForegroundColor Yellow -BackgroundColor Blue; Write-Host '============================================================' -ForegroundColor Green; Write-Host ''; Write-Host 'Date: ' $response.formattedDate -ForegroundColor White; Write-Host 'Password changes daily at midnight (IST)' -ForegroundColor Gray; } catch { Write-Host 'Error: Could not fetch password. Please start the server first.' -ForegroundColor Red; }"

echo.
echo.
echo [i] This password is valid for today only (14 Feb 2026)
echo [i] Password changes automatically at midnight IST
echo [i] Use this password to login to the admin dashboard
echo.
echo ============================================================
echo    HOW TO ACCESS ADMIN DASHBOARD
echo ============================================================
echo.
echo 1. Open browser and go to: http://localhost:7401
echo 2. Enter the 4-digit password shown above
echo 3. Click "Access Dashboard"
echo.
echo ============================================================
echo.
pause
