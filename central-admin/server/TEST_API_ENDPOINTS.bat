@echo off
echo ============================================================
echo TESTING API ENDPOINTS FIX
echo ============================================================
echo.
echo This will test all 5 fixed API endpoints:
echo 1. GET /api/labs
echo 2. GET /api/guest-password
echo 3. GET /api/report-schedule/CC1
echo 4. GET /api/timetable?upcoming=true
echo 5. GET /api/manual-reports
echo.
echo ============================================================
echo.

set SERVER_URL=http://10.10.46.103:7401

echo Testing API Endpoints...
echo.

echo [1/5] Testing /api/labs...
curl -s %SERVER_URL%/api/labs
echo.
echo.

echo [2/5] Testing /api/guest-password...
curl -s %SERVER_URL%/api/guest-password
echo.
echo.

echo [3/5] Testing /api/report-schedule/CC1...
curl -s %SERVER_URL%/api/report-schedule/CC1
echo.
echo.

echo [4/5] Testing /api/timetable?upcoming=true...
curl -s "%SERVER_URL%/api/timetable?upcoming=true"
echo.
echo.

echo [5/5] Testing /api/manual-reports...
curl -s %SERVER_URL%/api/manual-reports
echo.
echo.

echo ============================================================
echo TEST COMPLETE
echo ============================================================
echo.
echo If you see JSON responses above (not 404 errors), the fix worked!
echo.
pause
