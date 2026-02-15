@echo off
echo ============================================================
echo    Quick Test - Start Server on Admin PC (10.10.46.103)
echo ============================================================
echo.

REM Check MongoDB
echo [Step 1] Checking MongoDB...
sc query MongoDB | find "RUNNING" >nul
if %errorlevel% neq 0 (
    echo ❌ MongoDB not running. Starting...
    net start MongoDB
    timeout /t 3 >nul
)
echo ✅ MongoDB ready
echo.

REM Start server
echo [Step 2] Starting server on port 7401...
cd /d "%~dp0central-admin\server"
echo.
echo ============================================================
echo 📋 WATCH FOR THESE MESSAGES:
echo    ✅ Connected to MongoDB
echo    📍 Server IP detected: 10.10.46.103
echo    🚀 Lab Management Server Started Successfully
echo ============================================================
echo.
node app.js

pause
