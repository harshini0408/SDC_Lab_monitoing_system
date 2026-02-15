@echo off
echo ========================================
echo Testing Server Startup
echo ========================================
echo.

cd /d "%~dp0"

echo Starting server...
echo.

node app.js

pause
