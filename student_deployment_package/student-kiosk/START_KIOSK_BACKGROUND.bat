@echo off
REM ==================================================================
REM Student Kiosk - Background Launcher
REM ==================================================================
REM This batch file launches the kiosk in the background without
REM keeping a CMD window open. It uses START /B to detach the process.
REM ==================================================================

cd /d C:\StudentKiosk

REM Launch npm start in background mode (no window)
REM /B = Start application without creating a new window
start /B npm start

REM Exit immediately - the kiosk is now running independently
exit
