# 🚀 QUICK START - 69-System Lab Management

## ⚡ 5-MINUTE STARTUP GUIDE

### 1️⃣ START SERVER (Admin PC: 10.10.46.103)
```batch
# Double-click:
QUICK_START_TEST.bat

# Or manually:
net start MongoDB
cd central-admin\server
node app.js
```

**✅ VERIFY SERVER RUNNING:**
```
✅ Connected to MongoDB
📍 Server IP detected: 10.10.46.103
🚀 Lab Management Server Started Successfully
```

---

### 2️⃣ TEST WITH 1 SYSTEM
```batch
# On System 12 (10.10.46.12):
1. Copy folder to: C:\Lab-Kiosk\
2. Edit: C:\Lab-Kiosk\server-config.json
   {"serverIP":"10.10.46.103","serverPort":7401}
3. Run: cd C:\Lab-Kiosk\student-kiosk
        npm start
```

**✅ VERIFY HEARTBEAT:**
- Server console shows: `📡 System Heartbeat: System 12`
- Repeats every 30 seconds

---

### 3️⃣ TEST SHUTDOWN FEATURE
```
1. Open: http://10.10.46.103:7401
2. Click: "🔻 Show All Systems (Shutdown)"
3. Select: System 12 checkbox
4. Click: "🔌 Shutdown Selected Systems"
5. Type: "SHUTDOWN" to confirm
6. System 12 → Red warning → 10s countdown → Powers OFF
```

**✅ VERIFY COMPLETE SHUTDOWN:**
- ✅ System powers off completely
- ✅ Screen goes black
- ❌ Does NOT auto-restart

---

## 📊 ADMIN DASHBOARD FEATURES

### Show All Systems Modal
**Button Location:** Top session controls  
**Shows:** All 69 systems (online + offline)

**Stats Bar:**
```
📊 Total: 69 | 🟢 Online: X | 👤 Logged In: Y | ⚪ Offline: Z
```

**System Grid:**
- ✅ Online systems: Green, checkbox enabled
- ⚪ Offline systems: Gray, checkbox disabled
- Each shows: System #, IP, Status, Last seen

**Controls:**
- `☑️ Select All` - Checks all online systems
- `☐ Deselect All` - Unchecks all systems
- `🔄 Refresh` - Updates system status
- `🔌 Shutdown Selected` - Shuts down checked systems

---

## 🔴 SHUTDOWN PROCESS

### Admin Side (Dashboard):
```
1. Select systems → Click "Shutdown Selected"
2. Confirm: "Are you sure?" → OK
3. Type: "SHUTDOWN" → OK
4. Server sends shutdown signal via Socket.IO
```

### Student Side (Kiosk):
```
1. Receives 'force-shutdown-system' event
2. Shows full-screen red warning overlay
3. Countdown: 10 → 9 → 8 → ... → 1 → 0
4. Executes: shutdown /s /f /t 0
5. Computer powers off completely
```

---

## 📡 HEARTBEAT SYSTEM

**Frequency:** Every 30 seconds  
**Endpoint:** `POST /api/system-heartbeat`

**Payload:**
```json
{
  "systemNumber": 12,
  "labId": "CC1",
  "ipAddress": "10.10.46.12",
  "socketId": "abc123..."
}
```

**Stored in:** MongoDB `systemregistries` collection

---

## 🔧 TROUBLESHOOTING

### ❌ Server Won't Start
```batch
# Check MongoDB:
sc query MongoDB

# If not running:
net start MongoDB

# Check port 7401:
netstat -ano | findstr :7401
```

### ❌ Systems Not Appearing
```javascript
// Check student kiosk console (F12):
"📡 Sending heartbeat: System 12 | Lab CC1 | IP 10.10.46.12"

// Check server-config.json:
{"serverIP":"10.10.46.103","serverPort":7401}

// Check network:
ping 10.10.46.103
```

### ❌ Shutdown Not Working
```batch
# Test manual shutdown on student system:
shutdown /s /f /t 0

# Check Socket.IO connection in kiosk console:
socket.connected  // Should be true

# Check student kiosk console for:
"🔴 SHUTDOWN SIGNAL RECEIVED FROM ADMIN"
```

---

## 📝 IP RANGES

| Component | IP Address | Port |
|-----------|-----------|------|
| Admin Server | 10.10.46.103 | 7401 |
| Lab Systems | 10.10.46.12 - 10.10.46.255 | - |
| Total Systems | 69 | - |

---

## 🎯 SUCCESS CHECKLIST

- [ ] Server starts without errors
- [ ] MongoDB connected
- [ ] Dashboard accessible at `http://10.10.46.103:7401`
- [ ] Test system sends heartbeat every 30s
- [ ] "Show All Systems" modal shows all 69 systems
- [ ] Online systems have green status
- [ ] Offline systems have gray status
- [ ] Select/Deselect All buttons work
- [ ] Shutdown on 1 system works (complete power off)
- [ ] Selective shutdown works (only selected systems)

---

## 📚 FULL DOCUMENTATION

1. **DEPLOYMENT_TESTING_GUIDE.md** - Complete step-by-step guide
2. **TESTING_CHECKLIST_INTERACTIVE.html** - Interactive progress tracker
3. **69_SYSTEMS_IMPLEMENTATION_COMPLETE.md** - Technical details
4. **SERVER_STARTUP_FIX_COMPLETE.md** - Server configuration

---

## 🚨 EMERGENCY SHUTDOWN ALL

```
1. Dashboard → "Show All Systems"
2. Click "Select All"
3. Click "Shutdown Selected Systems"
4. Type "SHUTDOWN"
5. All online systems power off in 10 seconds
```

---

## 📞 QUICK REFERENCE

**Admin Dashboard:** http://10.10.46.103:7401  
**Server Console:** `cd central-admin\server && node app.js`  
**Student Kiosk:** `cd C:\Lab-Kiosk\student-kiosk && npm start`  
**MongoDB:** `net start MongoDB`

**Heartbeat Interval:** 30 seconds  
**Shutdown Countdown:** 10 seconds  
**Shutdown Command:** `shutdown /s /f /t 0`

---

**✅ Ready to Deploy!** 🚀  
**Last Updated:** 2025-01-20  
**Version:** 1.0
