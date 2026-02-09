# 🔧 Guest Login Duplicate Handler Fix

## Error Fixed
```
(node:840) UnhandledPromiseRejectionWarning: Error: Attempted to register a second handler for 'guest-login'
    at IpcMainImpl.handle (node:electron/js2c/browser_init:2:97707)
```

## Problem
The `main-simple.js` file had **TWO** registrations of the same IPC handler `'guest-login'`:
- **Line 904**: First registration (with guest password authentication)
- **Line 1203**: Second registration (duplicate - causing the error)

## Root Cause
During the guest mode feature implementation, the handler was accidentally added twice in the same file. Electron's IPC system doesn't allow multiple handlers for the same event name.

## Solution Applied
✅ **Removed the duplicate handler** at line 1203

### What Was Removed:
```javascript
// DUPLICATE - REMOVED
ipcMain.handle('guest-login', async (event, data) => {
  // ... duplicate guest login logic
});
```

### What Remains (Line 904):
```javascript
// ✅ CORRECT - Only one handler
ipcMain.handle('guest-login', async (event, credentials) => {
  // Authenticate guest password
  const authRes = await fetch(`${SERVER_URL}/api/guest-authenticate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ password: credentials.password }),
  });
  // ... rest of guest login logic with authentication
});
```

## How to Update Deployed Systems

### For Network Share Deployment:
```batch
# Copy the fixed file to network share
copy student_deployment_package\student-kiosk\main-simple.js \\SERVER\LabMonitoring\student-kiosk\
```

### For Individual Systems:
```batch
# Copy to each student PC
copy student_deployment_package\student-kiosk\main-simple.js C:\StudentKiosk\
```

### Restart the Kiosk:
1. Close the running kiosk application
2. Restart: `npm start` or double-click shortcut

## Verification
After restarting, you should see:
```
✅ Kiosk application starting...
✅ Checking config at: C:\StudentKiosk\server-config.json
✅ Loaded server URL from config: http://10.10.46.103:7401
```

**NO ERROR** about duplicate handler!

## Important Notes

### Why This Happened:
- Guest mode was implemented in stages
- First handler was added for password authentication
- Second handler was accidentally added later
- Both handlers had same name → conflict

### Prevention:
- Always search for existing handlers before adding new ones:
  ```bash
  grep -n "ipcMain.handle('guest-login'" main-simple.js
  ```
- Use unique handler names if needed:
  - `guest-login` (authentication)
  - `guest-login-bypass` (no authentication)

### Testing After Fix:
1. ✅ Start kiosk - no errors
2. ✅ Click "Guest Mode" button
3. ✅ Enter 4-digit password
4. ✅ Should login successfully
5. ✅ Guest session shows in admin dashboard with purple styling

## Files Modified
- **`student_deployment_package/student-kiosk/main-simple.js`** - Removed duplicate handler

## Status
✅ **FIXED** - February 9, 2026

---

## Quick Commands

### Check for duplicates:
```cmd
findstr /n "ipcMain.handle('guest-login'" main-simple.js
```

### Deploy fix to network share:
```cmd
xcopy /Y student_deployment_package\student-kiosk\main-simple.js \\SERVER\LabMonitoring\student-kiosk\
```

### Restart all kiosks (if running):
```cmd
# Students must close and reopen kiosk application
```

---

**Fixed by:** GitHub Copilot AI  
**Date:** February 9, 2026  
**Affected Systems:** All deployed student kiosks using main-simple.js
