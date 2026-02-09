@echo off
echo ========================================
echo  FIX GUEST LOGIN DUPLICATE HANDLER ERROR
echo ========================================
echo.
echo This script updates main-simple.js on deployed student systems
echo to fix the "Attempted to register a second handler for 'guest-login'" error
echo.
pause

echo.
echo Step 1: Checking if fix is available...
echo.

if not exist "student_deployment_package\student-kiosk\main-simple.js" (
    echo ERROR: Source file not found!
    echo Please run this script from the lab_monitoring_system folder
    pause
    exit /b 1
)

echo ✓ Source file found
echo.

:menu
echo Select deployment method:
echo.
echo 1. Network Share Deployment (\\SERVER\path)
echo 2. Local System (C:\StudentKiosk)
echo 3. Custom Path
echo 4. Exit
echo.
choice /C 1234 /N /M "Enter your choice (1-4): "

if errorlevel 4 goto :end
if errorlevel 3 goto :custom
if errorlevel 2 goto :local
if errorlevel 1 goto :network

:network
echo.
echo === NETWORK SHARE DEPLOYMENT ===
echo.
set /p networkPath="Enter network share path (e.g., \\10.10.46.103\LabMonitoring): "

if not exist "%networkPath%\student-kiosk" (
    echo ERROR: Path not found or not accessible!
    echo Please check the network path and try again.
    pause
    goto :menu
)

echo.
echo Copying fixed main-simple.js to network share...
copy /Y "student_deployment_package\student-kiosk\main-simple.js" "%networkPath%\student-kiosk\main-simple.js"

if errorlevel 1 (
    echo ✗ Error copying file! Check permissions.
    pause
    goto :end
)

echo.
echo ✓ File updated successfully on network share!
echo.
echo IMPORTANT: Students must restart their kiosk application:
echo   1. Close the kiosk (if running)
echo   2. Restart by running: npm start or double-clicking shortcut
echo.
echo The error should now be fixed!
pause
goto :end

:local
echo.
echo === LOCAL SYSTEM UPDATE ===
echo.

if not exist "C:\StudentKiosk" (
    echo ERROR: C:\StudentKiosk not found!
    echo Please enter a custom path.
    pause
    goto :menu
)

echo Copying fixed main-simple.js to C:\StudentKiosk...
copy /Y "student_deployment_package\student-kiosk\main-simple.js" "C:\StudentKiosk\main-simple.js"

if errorlevel 1 (
    echo ✗ Error copying file!
    pause
    goto :end
)

echo.
echo ✓ File updated successfully!
echo.
echo IMPORTANT: Restart the kiosk application:
echo   1. Close the kiosk (if running)
echo   2. Open command prompt in C:\StudentKiosk
echo   3. Run: npm start
echo.
echo The error should now be fixed!
pause
goto :end

:custom
echo.
echo === CUSTOM PATH DEPLOYMENT ===
echo.
set /p customPath="Enter full path to student-kiosk folder: "

if not exist "%customPath%" (
    echo ERROR: Path not found!
    pause
    goto :menu
)

echo.
echo Copying fixed main-simple.js to %customPath%...
copy /Y "student_deployment_package\student-kiosk\main-simple.js" "%customPath%\main-simple.js"

if errorlevel 1 (
    echo ✗ Error copying file!
    pause
    goto :end
)

echo.
echo ✓ File updated successfully!
echo.
echo IMPORTANT: Restart the kiosk application at this location.
pause
goto :end

:end
echo.
echo ========================================
echo Fix deployment complete!
echo ========================================
echo.
echo For more information, see:
echo GUEST_LOGIN_DUPLICATE_HANDLER_FIX.md
echo.
pause
