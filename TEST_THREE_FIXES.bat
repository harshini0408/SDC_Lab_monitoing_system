@echo off
echo ========================================
echo  TESTING THREE CRITICAL FIXES
echo ========================================
echo.
echo DATE: %DATE% %TIME%
echo.

echo [1/4] Checking if server is running...
curl -s http://localhost:5000/api/health > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Server not running! Please start the server first.
    echo.
    echo Run: cd d:\New_SDC\lab_monitoring_system\central-admin\server
    echo      npm start
    pause
    exit /b 1
)
echo [OK] Server is running
echo.

echo [2/4] Testing upcoming sessions API...
curl -s "http://localhost:5000/api/timetable?upcoming=true" > temp_response.json
findstr /C:"success" temp_response.json > nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Upcoming sessions API responding
    echo.
    echo Response:
    type temp_response.json
    echo.
) else (
    echo [ERROR] API returned error
    type temp_response.json
)
echo.

echo [3/4] Checking active students endpoint...
curl -s "http://localhost:5000/api/active-students-count" > temp_count.json
echo Response:
type temp_count.json
echo.

echo [4/4] Opening admin dashboard...
start http://localhost:5000/admin/dashboard/admin-dashboard.html
echo.

echo ========================================
echo  MANUAL VERIFICATION STEPS
echo ========================================
echo.
echo 1. Upload a timetable CSV with entries for TODAY
echo 2. Check "Upcoming Sessions" section shows all entries
echo 3. Verify "Active Students" count shows 0 when no students
echo 4. Check console logs for timetable auto-start messages
echo.
echo Watch server console for these messages:
echo   - "TIMETABLE CHECK AT HH:MM"
echo   - "Found X timetable entries for today"
echo   - "TRIGGER: Starting session for [Subject]"
echo.

del temp_response.json 2>nul
del temp_count.json 2>nul

echo ========================================
echo Press any key to exit...
pause >nul
