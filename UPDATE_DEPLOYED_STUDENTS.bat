@echo off
echo ========================================
echo  UPDATE DEPLOYED STUDENT SYSTEMS
echo ========================================
echo.
echo This script updates student-interface.html on all deployed systems
echo.
pause

echo.
echo Step 1: Copying updated files to deployment package...
echo.

REM Update the deployment package first
copy /Y "student_deployment_package\student-kiosk\student-interface.html" "student_deployment_package\student-kiosk\student-interface.html.backup"
echo ✓ Backup created

echo.
echo Step 2: Update instructions
echo.
echo CHOOSE YOUR METHOD:
echo.
echo [A] Network Share Deployment (if students run from \\SERVER\share)
echo     - Just copy updated files to network share
echo     - Students get updates on next restart
echo.
echo [B] Individual Installation (if installed locally on each PC)
echo     - Need to visit each computer OR use remote deployment
echo.
echo ========================================
echo.

:menu
echo Select update method:
echo 1. Network Share Update (Automatic)
echo 2. Create USB Update Package
echo 3. Remote Update Script (Advanced)
echo 4. Exit
echo.
choice /C 1234 /N /M "Enter your choice (1-4): "

if errorlevel 4 goto :end
if errorlevel 3 goto :remote
if errorlevel 2 goto :usb
if errorlevel 1 goto :network

:network
echo.
echo === NETWORK SHARE UPDATE ===
echo.
set /p sharePath="Enter network share path (e.g., \\SERVER\LabMonitoring): "
echo.
echo Copying files to %sharePath%...
xcopy /Y /E "student_deployment_package\student-kiosk\*.*" "%sharePath%\student-kiosk\"
if errorlevel 1 (
    echo ✗ Error copying files! Check network path and permissions.
) else (
    echo ✓ Files updated on network share!
    echo ✓ Students will get updates on next kiosk restart
)
goto :end

:usb
echo.
echo === USB UPDATE PACKAGE ===
echo.
echo Creating portable update package...
mkdir USB_UPDATE_PACKAGE 2>nul
xcopy /Y /E "student_deployment_package\student-kiosk\*.*" "USB_UPDATE_PACKAGE\"
echo.
echo ✓ USB package created in USB_UPDATE_PACKAGE folder
echo.
echo INSTRUCTIONS:
echo 1. Copy USB_UPDATE_PACKAGE folder to USB drive
echo 2. On each student PC, run the UPDATE_KIOSK.bat from USB
echo.
echo Creating UPDATE_KIOSK.bat...
(
echo @echo off
echo echo Updating Student Kiosk...
echo xcopy /Y /E *.* "%%LOCALAPPDATA%%\LabMonitoring\student-kiosk\"
echo echo Update complete! Restart the kiosk.
echo pause
) > "USB_UPDATE_PACKAGE\UPDATE_KIOSK.bat"
echo ✓ UPDATE_KIOSK.bat created
goto :end

:remote
echo.
echo === REMOTE UPDATE (ADVANCED) ===
echo.
echo This requires PsExec and admin credentials for remote computers
echo Download PsExec from: https://learn.microsoft.com/en-us/sysinternals/downloads/psexec
echo.
set /p computerList="Enter file with computer names (one per line): "
if not exist "%computerList%" (
    echo File not found!
    goto :end
)
echo.
echo Creating remote update script...
(
echo @echo off
echo for /f %%%%i in ^(%computerList%^) do ^(
echo     echo Updating %%%%i...
echo     xcopy /Y /E student_deployment_package\student-kiosk\*.* "\\%%%%i\c$\Users\Public\LabMonitoring\student-kiosk\" 
echo     echo ✓ %%%%i updated
echo ^)
) > "REMOTE_UPDATE_ALL.bat"
echo ✓ Script created: REMOTE_UPDATE_ALL.bat
echo Run this script with admin privileges
goto :end

:end
echo.
echo ========================================
echo Update process complete!
echo ========================================
pause
