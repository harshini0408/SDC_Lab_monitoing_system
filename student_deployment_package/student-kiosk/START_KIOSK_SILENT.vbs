' ==================================================================
' Student Kiosk - Silent Launcher (No CMD Window)
' ==================================================================
' This VBScript launches the kiosk application without showing any
' visible CMD window. The kiosk runs as a background process.
' ==================================================================

Set WshShell = CreateObject("WScript.Shell")

' Change to kiosk directory
kioskPath = "C:\StudentKiosk"

' Build command to run npm start in hidden mode
' /B = Run without creating a new window
' > nul 2>&1 = Suppress all output
command = "cmd /c cd /d """ & kioskPath & """ && start /B npm start"

' Run command with windowStyle = 0 (completely hidden)
' Parameters: command, windowStyle, waitOnReturn
' windowStyle: 0 = Hidden, 1 = Normal, 2 = Minimized, 3 = Maximized
' waitOnReturn: False = Don't wait for process to complete
WshShell.Run command, 0, False

' Clean up
Set WshShell = Nothing
