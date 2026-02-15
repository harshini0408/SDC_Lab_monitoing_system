@echo off
echo ============================================================
echo Starting Lab Management Server
echo ============================================================
echo.

cd /d "%~dp0"
node app.js

echo.
echo ============================================================
echo Server stopped or error occurred
echo ============================================================
pause
