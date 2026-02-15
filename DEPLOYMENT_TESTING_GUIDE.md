# 🚀 69-SYSTEM LAB MANAGEMENT - DEPLOYMENT & TESTING GUIDE

## 📋 PRE-DEPLOYMENT CHECKLIST

### ✅ Completed (From Summary)
- [x] Server API endpoints for heartbeat, system listing, shutdown
- [x] Student kiosk heartbeat system (30-second intervals)
- [x] Student kiosk shutdown handlers (complete Windows shutdown)
- [x] Admin dashboard "Show All Systems" modal UI
- [x] Admin dashboard shutdown controls with double confirmation
- [x] All syntax errors fixed (0 errors in app.js and admin-dashboard.html)
- [x] Complete server startup code with graceful shutdown
- [x] MongoDB connection handling with error messages

---

## 🧪 PHASE 1: SERVER TESTING (Admin PC - 10.10.46.103)

### Step 1.1: Start MongoDB
```batch
# On Windows (as Administrator):
net start MongoDB

# Verify it's running:
sc query MongoDB
```

### Step 1.2: Start Lab Management Server
```batch
# Option A: Use quick start script
QUICK_START_TEST.bat

# Option B: Manual start
cd central-admin\server
node app.js
```

### Step 1.3: Verify Server Startup Messages
**Expected Console Output:**
```
🔄 Lab Management Server - Starting...
============================================================
✅ Connected to MongoDB
📍 Server IP detected: 10.10.46.103
✅ Server config saved to server-config.json
============================================================
🚀 Lab Management Server Started Successfully
============================================================
📍 Server IP: 10.10.46.103
🔌 Port: 7401
🌐 Admin Dashboard: http://10.10.46.103:7401
============================================================
✅ Ready to accept connections...
```

### Step 1.4: Test Admin Dashboard Access
1. Open browser on admin PC
2. Navigate to: `http://10.10.46.103:7401`
3. Verify dashboard loads successfully
4. Check console for any errors (F12)

---

## 🖥️ PHASE 2: SINGLE-SYSTEM TEST

### Step 2.1: Deploy to Test System (e.g., System 12 at 10.10.46.12)

**Copy Files:**
```batch
# Copy entire student_deployment_package folder to:
C:\Lab-Kiosk\
```

**Required Files:**
```
C:\Lab-Kiosk\
├── student-kiosk\
│   ├── main-simple.js      (with heartbeat & shutdown handlers)
│   ├── student-interface.html  (with shutdown listener)
│   ├── preload.js          (with shutdown API bridge)
│   ├── package.json
│   └── node_modules\       (from npm install)
└── server-config.json      (will be created/updated by kiosk)
```

### Step 2.2: Configure server-config.json
**On test system, create/edit:**
```json
{
  "serverIP": "10.10.46.103",
  "serverPort": 7401
}
```

### Step 2.3: Start Student Kiosk
```batch
cd C:\Lab-Kiosk\student-kiosk
npm start
```

### Step 2.4: Verify Heartbeat Registration

**On Server Console (Admin PC):**
Watch for heartbeat logs every 30 seconds:
```
📡 System Heartbeat: System 12 | Lab: CC1 | IP: 10.10.46.12
```

**Check Database:**
```bash
# On admin PC, connect to MongoDB:
mongosh
use lab-management
db.systemregistries.find().pretty()

# Expected document:
{
  "_id": ObjectId("..."),
  "systemNumber": 12,
  "labId": "CC1",
  "ipAddress": "10.10.46.12",
  "socketId": "abc123...",
  "lastSeen": ISODate("2025-01-20T10:30:00.000Z")
}
```

---

## 🔍 PHASE 3: VERIFY "SHOW ALL SYSTEMS" FEATURE

### Step 3.1: Open Admin Dashboard
1. Navigate to: `http://10.10.46.103:7401`
2. Login as administrator

### Step 3.2: Click "Show All Systems" Button
- Location: Top session controls area
- Button text: **"🔻 Show All Systems (Shutdown)"**

### Step 3.3: Verify Modal Display

**Expected Stats Bar:**
```
📊 Total: 69 | 🟢 Online: 1 | 👤 Logged In: 0 | ⚪ Offline: 68
```

**Expected System Grid:**
- **System 12**: Should show as **ONLINE** with green indicator
  - Checkbox: ✅ Enabled
  - IP: 10.10.46.12
  - Status: "Last seen: X seconds ago"

- **Systems 1-11, 13-69**: Should show as **OFFLINE** with gray indicator
  - Checkbox: ❌ Disabled
  - Status: "Never connected" or last seen timestamp

### Step 3.4: Test Refresh Button
1. Click **"🔄 Refresh"** button in modal
2. Verify stats and system statuses update
3. Check browser console for API call:
```javascript
GET http://10.10.46.103:7401/api/lab-systems/CC1
Response: 200 OK
{
  "success": true,
  "systems": [{systemNumber: 12, status: "online", ...}, ...],
  "stats": {total: 69, online: 1, loggedIn: 0, offline: 68}
}
```

---

## ⚠️ PHASE 4: TEST SHUTDOWN (SINGLE SYSTEM)

### Step 4.1: Select System 12
1. In "Show All Systems" modal
2. Check the checkbox next to **System 12**
3. Verify it's the only system selected

### Step 4.2: Initiate Shutdown
1. Click **"🔌 Shutdown Selected Systems"** button
2. **First Confirmation Dialog:**
   ```
   ⚠️ SHUTDOWN SELECTED SYSTEMS
   
   Are you sure you want to SHUT DOWN 1 system(s)?
   
   This will:
   - Force close all programs
   - Power off the computer completely
   - Require manual restart
   
   [Cancel] [OK]
   ```
3. Click **OK**

4. **Second Confirmation Dialog:**
   ```
   ⚠️ FINAL CONFIRMATION
   
   Type "SHUTDOWN" to confirm shutdown of 1 system(s):
   
   [Text Input: _____________]
   
   [Cancel] [OK]
   ```
5. Type: `SHUTDOWN` (case-sensitive)
6. Click **OK**

### Step 4.3: Observe Student System Behavior

**On System 12 (Student Kiosk):**

1. **Red Warning Overlay Appears:**
   ```
   ⚠️ SYSTEM SHUTDOWN INITIATED ⚠️
   
   This system will shut down in:
   
   10 seconds
   
   Please save all work immediately!
   Administrator has initiated system shutdown.
   ```

2. **Countdown Animation:**
   - Counter decrements: 10 → 9 → 8 → 7 → 6 → 5 → 4 → 3 → 2 → 1 → 0
   - Numbers pulse/scale animation
   - Red background flashes

3. **Shutdown Execution:**
   - At 0 seconds, kiosk calls `electronAPI.forceWindowsShutdown()`
   - IPC handler executes: `shutdown /s /f /t 0`
   - Computer powers off **completely** (not just logout)

### Step 4.4: Verify Complete Shutdown

**Expected Result:**
- ✅ System 12 powers off completely
- ✅ Screen goes black
- ✅ Power LED turns off
- ✅ Fans stop
- ❌ System does NOT automatically restart

**To restart:**
- Manual power button press required
- Or wake-on-LAN if configured

---

## 🎯 PHASE 5: MULTI-SYSTEM TEST (2-3 Systems)

### Step 5.1: Bring More Systems Online
1. Deploy kiosk to System 13 and System 14
2. Start kiosks on both systems
3. Wait 30 seconds for heartbeats

### Step 5.2: Verify in Admin Dashboard
1. Click "Show All Systems"
2. Verify stats show:
   ```
   📊 Total: 69 | 🟢 Online: 3 | 👤 Logged In: 0 | ⚪ Offline: 66
   ```
3. Systems 12, 13, 14 should show as **ONLINE**

### Step 5.3: Test Selective Shutdown
1. Check Systems 12 and 14 (leave 13 unchecked)
2. Click "Shutdown Selected Systems"
3. Confirm: Type "SHUTDOWN"
4. Verify:
   - ✅ Systems 12 and 14 show countdown and shut down
   - ✅ System 13 remains running (no warning)

### Step 5.4: Test "Select All" / "Deselect All"
1. Click **"☑️ Select All"** button
   - All online systems should be checked
   - Offline systems remain unchecked (disabled)
2. Click **"☐ Deselect All"** button
   - All checkboxes should be unchecked

---

## 📦 PHASE 6: FULL DEPLOYMENT (All 69 Systems)

### Step 6.1: Prepare Deployment Package

**Create batch deployment script:**
```batch
REM deploy_to_all_systems.bat

@echo off
set SERVER_IP=10.10.46.103
set SERVER_PORT=7401

echo Deploying Lab Kiosk to all systems...

for /L %%i in (12,1,255) do (
    if not %%i==103 (
        echo Deploying to 10.10.46.%%i...
        xcopy /E /I /Y "student_deployment_package\*" "\\10.10.46.%%i\C$\Lab-Kiosk\"
        
        REM Create server-config.json
        echo {"serverIP":"%SERVER_IP%","serverPort":%SERVER_PORT%} > "\\10.10.46.%%i\C$\Lab-Kiosk\server-config.json"
    )
)

echo Deployment complete!
pause
```

### Step 6.2: Configure Auto-Start on All Systems

**Create Windows Task Scheduler entry on each system:**
```xml
Name: Lab-Kiosk-Startup
Trigger: At system startup
Action: Start a program
  Program: C:\Program Files\nodejs\node.exe
  Arguments: C:\Lab-Kiosk\student-kiosk\main-simple.js
Run with: Highest privileges
```

**Or use registry auto-start:**
```batch
REM Run on each system:
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "LabKiosk" /t REG_SZ /d "C:\Lab-Kiosk\student-kiosk\start-kiosk.bat" /f
```

### Step 6.3: Verify Full Deployment

**In Admin Dashboard:**
1. Click "Show All Systems (Shutdown)"
2. Verify all 69 systems appear
3. Check stats:
   ```
   📊 Total: 69 | 🟢 Online: 69 | 👤 Logged In: X | ⚪ Offline: 0
   ```
4. Verify each system shows:
   - Correct IP (10.10.46.12 - 10.10.46.255)
   - Online status
   - Recent heartbeat timestamp

---

## 🚨 TROUBLESHOOTING GUIDE

### Issue 1: Systems Not Appearing in Dashboard

**Check 1: Verify Network Connectivity**
```batch
# On admin PC:
ping 10.10.46.12
ping 10.10.46.13
```

**Check 2: Verify Server is Running**
```
http://10.10.46.103:7401
# Should see admin dashboard
```

**Check 3: Check Student Kiosk Logs**
```javascript
// In student-kiosk console (F12):
// Should see every 30 seconds:
"📡 Sending heartbeat: System 12 | Lab CC1 | IP 10.10.46.12"
```

**Check 4: Check Server-Config.json**
```json
// On student system: C:\Lab-Kiosk\server-config.json
{
  "serverIP": "10.10.46.103",  // Must be correct
  "serverPort": 7401
}
```

**Check 5: Verify Socket.IO Connection**
```javascript
// In admin dashboard console:
socket.connected  // Should return true
```

### Issue 2: Shutdown Not Working

**Check 1: Verify Socket.IO Event**
```javascript
// In student kiosk console:
// Should see when shutdown triggered:
"🔴 SHUTDOWN SIGNAL RECEIVED FROM ADMIN"
```

**Check 2: Check IPC Handler**
```javascript
// Verify in main-simple.js (line ~1220):
ipcMain.handle('force-windows-shutdown', async () => {
  const { exec } = require('child_process');
  exec('shutdown /s /f /t 0');
});
```

**Check 3: Test Manual Shutdown**
```batch
# On student system, run manually:
shutdown /s /f /t 0
# Should shut down immediately
```

**Check 4: Check Windows Permissions**
```batch
# Student kiosk must run with elevated privileges
# Right-click kiosk → Run as Administrator
```

### Issue 3: Heartbeat Not Sending

**Check 1: Verify System Number Detection**
```javascript
// In main-simple.js getLocalIP():
const ip = '10.10.46.12';
const match = ip.match(/10\.10\.46\.(\d+)/);
const systemNumber = match ? parseInt(match[1], 10) : null;
console.log('Detected System Number:', systemNumber);  // Should be 12
```

**Check 2: Verify Lab Detection**
```javascript
// In main-simple.js detectLabFromIP():
if (ip.startsWith('10.10.46.')) return 'CC1';
console.log('Detected Lab:', detectLabFromIP());  // Should be 'CC1'
```

**Check 3: Check Heartbeat Interval**
```javascript
// In main-simple.js (line ~1246):
setInterval(sendSystemHeartbeat, 30000);  // Every 30 seconds
```

### Issue 4: Database Issues

**Check 1: Verify MongoDB is Running**
```batch
sc query MongoDB
# Should show: STATE : 4  RUNNING
```

**Check 2: Check Database Connection**
```javascript
// In server console:
// Should see: "✅ Connected to MongoDB"
```

**Check 3: Query SystemRegistry Collection**
```bash
mongosh
use lab-management
db.systemregistries.find().pretty()
# Should show all online systems
```

**Check 4: Clear Stale Entries**
```bash
# Remove systems not seen in 5 minutes:
db.systemregistries.deleteMany({
  lastSeen: { $lt: new Date(Date.now() - 5*60*1000) }
})
```

---

## 📊 MONITORING & MAINTENANCE

### Daily Monitoring

**Check Dashboard Stats:**
- Navigate to: `http://10.10.46.103:7401`
- Click "Show All Systems"
- Verify expected number of online systems

**Check Server Logs:**
```batch
# View recent heartbeats:
cd central-admin\server
type logs\heartbeat.log | more

# Or in real-time:
tail -f logs\server.log
```

### Weekly Maintenance

**Clear Offline Systems:**
```bash
mongosh
use lab-management
db.systemregistries.deleteMany({
  lastSeen: { $lt: new Date(Date.now() - 24*60*60*1000) }
})
```

**Backup Database:**
```batch
mongodump --db lab-management --out C:\Backups\lab-management-%DATE%
```

### Emergency Shutdown All Systems

**From Admin Dashboard:**
1. Click "Show All Systems"
2. Click "Select All"
3. Click "Shutdown Selected Systems"
4. Type "SHUTDOWN"
5. All online systems will shut down in 10 seconds

---

## 📈 SUCCESS METRICS

### ✅ Deployment Successful When:
- [ ] All 69 systems appear in "Show All Systems" modal
- [ ] Stats show correct online/offline counts
- [ ] Systems update status every 30 seconds
- [ ] Selective shutdown works on chosen systems only
- [ ] Systems shut down completely (not just logout)
- [ ] No errors in server console
- [ ] No errors in student kiosk console
- [ ] Admin dashboard loads without errors

### ⚠️ Known Limitations
- Systems must be powered on to appear as "online"
- Offline systems cannot be shut down (no wake-on-LAN)
- Heartbeat has 30-second delay (systems offline >30s show as offline)
- Shutdown requires active Socket.IO connection

---

## 🎉 DEPLOYMENT COMPLETE CHECKLIST

- [ ] Server starts without errors
- [ ] MongoDB connection successful
- [ ] Admin dashboard accessible at `http://10.10.46.103:7401`
- [ ] Test system (1-2 systems) shows heartbeat
- [ ] Test shutdown works on selected systems
- [ ] Multi-system test (2-3 systems) successful
- [ ] All 69 systems deployed and showing in dashboard
- [ ] Auto-start configured on all systems
- [ ] Monitoring dashboard bookmarked
- [ ] Backup procedures in place
- [ ] Admin trained on shutdown procedures

---

## 📞 SUPPORT & DOCUMENTATION

**Related Documentation:**
- `69_SYSTEMS_IMPLEMENTATION_COMPLETE.md` - Technical implementation details
- `SERVER_STARTUP_FIX_COMPLETE.md` - Server configuration
- `ADMIN_DASHBOARD_69_SYSTEMS_UI.md` - UI implementation guide
- `LAB_69_SYSTEMS_COMPLETE.md` - Deployment summary

**Quick Reference:**
- Server IP: `10.10.46.103`
- Server Port: `7401`
- Admin Dashboard: `http://10.10.46.103:7401`
- System IP Range: `10.10.46.12` - `10.10.46.255`
- Heartbeat Interval: 30 seconds
- Shutdown Countdown: 10 seconds

---

**Last Updated:** 2025-01-20  
**Version:** 1.0  
**Status:** ✅ Ready for Production Deployment
