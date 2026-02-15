@echo off
echo ============================================================
echo TESTING SERVER STARTUP FIX
echo ============================================================
echo.
echo Starting server...
echo.

cd /d d:\New_SDC\lab_monitoring_system\central-admin\server
node app.js

echo.
echo ============================================================
echo If you see the admin dashboard open in browser, SUCCESS!
echo ============================================================
pause
