@echo off
echo ============================================================
echo TESTING ADMIN DASHBOARD ACCESS
echo ============================================================
echo.
echo This will:
echo 1. Start the server
echo 2. Auto-open admin dashboard in browser
echo 3. Verify the 404 error is fixed
echo.
echo ============================================================
echo.

cd /d d:\New_SDC\lab_monitoring_system\central-admin\server

echo Starting server...
echo.
echo If you see the admin dashboard open in your browser,
echo the fix is working!
echo.
echo Press Ctrl+C to stop the server when done testing.
echo.
echo ============================================================
echo.

node app.js
