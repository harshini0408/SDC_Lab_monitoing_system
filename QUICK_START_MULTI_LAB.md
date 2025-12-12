# 🚀 Quick Start - Multi-Lab & Guest Access

## ⚡ Start in 3 Steps

### Step 1: Start Server
```powershell
cd d:\screen_mirror_deployment_my_laptop\central-admin\server
node app.js
```

**Expected Output**:
```
✅ Server running on http://localhost:3001
✅ MongoDB connected to: studentlabms
✅ Socket.IO initialized
📊 Lab configuration loaded:
   - CC1: Computer Center Lab 1 (192.168.29.*)
   - CC2: Computer Center Lab 2 (10.10.46.*)
   - CC3: Computer Center Lab 3 (10.10.47.*)
   - CC4: Computer Center Lab 4 (10.10.48.*)
   - CC5: Computer Center Lab 5 (10.10.49.*)
```

---

### Step 2: Start Kiosk
```powershell
cd d:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app
npm start
```

**What Happens**:
1. Kiosk app opens in fullscreen
2. Shows system number (e.g., CC1-05)
3. Connects to server
4. Server detects lab from IP
5. System registered in database

**Server Console Should Show**:
```
✅ Kiosk connected: socket_id_xyz
✅ Kiosk registered: CC1-05
🌐 Lab detected: CC1 (from IP: 192.168.29.XXX)
📝 System registry updated
```

---

### Step 3: Open Admin Dashboard
```
http://localhost:3001/admin-dashboard.html
```

**What You'll See**:
1. **Lab Selector** (top of page)
   - Dropdown showing: CC1, CC2, CC3, CC4, CC5
   - Auto-selects CC1

2. **Lab Statistics**
   ```
   Total: 60 | 🟢 Available: 1 | 🔵 Logged In: 0 | 🟣 Guest: 0 | ⚫ Offline: 59
   ```

3. **System Buttons** (60 buttons)
   - CC1-05 shows as 🟢 GREEN (Available)
   - All others show as ⚫ GRAY (Offline)

---

## 🔓 Test Guest Access

### Test: Unlock System Before Login

**Scenario**: Kiosk is powered on but NO student has logged in yet.

**Steps**:
1. **Kiosk**: Should show login screen (not logged in)
2. **Admin Dashboard**: Select CC1 from dropdown
3. **Admin Dashboard**: Find CC1-05 button (should be 🟢 green)
4. **Admin Dashboard**: Click "🟢 CC1-05"
5. **Confirm Dialog**: Click "OK"
6. **Kiosk**: Watch the screen

**Expected Result (Within 2 seconds)**:
- ✅ Kiosk shows "GUEST ACCESS ENABLED" message
- ✅ Login screen disappears
- ✅ Desktop interface appears
- ✅ System number shows "CC1-05 - GUEST MODE"
- ✅ Admin dashboard button turns 🟣 PURPLE
- ✅ Guest user card appears in "Active Students" section

---

## 📊 Verify System Registry

### Check MongoDB

```javascript
// Open MongoDB Compass or mongo shell
// Database: studentlabms
// Collection: systemregistries

// Should see:
{
  systemNumber: 'CC1-05',
  labId: 'CC1',
  ipAddress: '192.168.29.XXX',
  status: 'available',  // or 'guest' after unlocking
  lastSeen: ISODate(),
  isGuest: false,       // or true after unlocking
  socketId: 'abc123',
  currentStudentId: null  // or 'GUEST' after unlocking
}
```

---

## 🎯 Key Features to Test

### 1. Pre-Login Visibility ⭐
- Power on kiosk (don't login)
- System appears in admin dashboard immediately
- Status: 🟢 Available

### 2. Guest Access ⭐
- Click available system button
- Kiosk unlocks remotely
- No manual login needed

### 3. Lab Detection ⭐
- Server detects lab from IP automatically
- CC1: 192.168.29.*
- CC2: 10.10.46.* (if you have this network)

### 4. Multi-Lab Support
- Select different labs from dropdown
- Each lab shows 60 systems (CC1-01 to CC1-60)
- Systems are lab-specific

### 5. Real-Time Updates ⭐
- Open 2 admin dashboards
- Enable guest on one
- Other updates automatically

---

## 🐛 Quick Troubleshooting

### Kiosk Not Appearing in Dashboard

**Check**:
```powershell
# Is server running?
# Should see: "Server running on http://localhost:3001"

# Is kiosk connected?
# Server console should show: "Kiosk registered: CC1-05"

# Is lab selected?
# Admin dashboard: Select CC1 from dropdown
```

**Debug**:
```javascript
// Browser console (F12 on admin dashboard)
console.log('Check for errors here')

// Should see:
"Labs loaded: {...}"
"Loading systems for CC1..."
"Systems loaded: 60 systems"
```

### Guest Access Not Working

**Check**:
1. System status is 🟢 Available (green)?
2. Socket.IO connected? (Check server console)
3. Kiosk showing login screen? (Not locked or sleeping)

**Debug**:
```javascript
// Kiosk console (Ctrl+Shift+I in Electron)
// Should see:
"Guest access received for CC1-05"
"Auto-logging in as GUEST..."
```

---

## 📋 Quick Reference

### Server URLs
- Admin Dashboard: `http://localhost:3001/admin-dashboard.html`
- API Labs: `http://localhost:3001/api/labs`
- API Systems: `http://localhost:3001/api/systems/CC1`

### Default Credentials
- **Guest Login**: GUEST / admin123
- **Admin**: (No login required for dashboard currently)

### Lab Configuration
File: `central-admin/server/lab-config.js`

Current IP Mapping:
- CC1: 192.168.29.* (for testing)
- CC2: 10.10.46.*
- CC3: 10.10.47.*
- CC4: 10.10.48.*
- CC5: 10.10.49.*

### System Status Colors
- 🟢 Green = Available (can unlock)
- 🔵 Blue = Student logged in
- 🟣 Purple = Guest mode
- ⚫ Gray = Offline

---

## ✅ Success Checklist

After starting server and kiosk:

- [ ] Server console shows "Kiosk registered"
- [ ] Admin dashboard loads without errors
- [ ] Lab selector shows 5 labs
- [ ] Selecting CC1 loads 60 systems
- [ ] Your kiosk appears as 🟢 Available
- [ ] Lab stats show "Available: 1"
- [ ] Clicking kiosk button unlocks it
- [ ] Button turns 🟣 Purple after unlock
- [ ] Guest user card appears
- [ ] No errors in browser console
- [ ] No errors in server console

---

## 📚 Full Documentation

- **MULTI_LAB_IMPLEMENTATION_COMPLETE.md** - Complete overview
- **MULTI_LAB_STATUS.md** - Implementation details
- **MULTI_LAB_TEST_GUIDE.md** - Comprehensive testing
- **GUEST_ACCESS_COMPLETE.md** - Guest access details

---

## 🎉 That's It!

Your multi-lab system with pre-login guest access is now running!

**Next**: Follow `MULTI_LAB_TEST_GUIDE.md` for detailed testing.
