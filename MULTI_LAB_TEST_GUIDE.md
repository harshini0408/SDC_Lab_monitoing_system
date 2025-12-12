# 🧪 Multi-Lab Support & Guest Access - Testing Guide

## ✅ What Was Implemented

### Backend (Server)
- ✅ System Registry database (tracks all systems pre-login)
- ✅ IP-based lab detection (auto-detects lab from kiosk IP)
- ✅ Lab configuration module (lab-config.js)
- ✅ API endpoints: `/api/labs`, `/api/systems/:labId`
- ✅ Socket.IO lab rooms for isolation
- ✅ Guest access integration with registry

### Frontend (Admin Dashboard)
- ✅ Lab selection dropdown
- ✅ Dynamic system button generation (all 60 systems)
- ✅ Color-coded status indicators (🟢🔵🟣⚫)
- ✅ Real-time system registry updates
- ✅ Lab statistics display

---

## 🎯 Test Scenarios

### Test 1: Lab Detection from IP ⭐ CRITICAL

**Purpose**: Verify server correctly detects lab from kiosk IP

**Steps**:
1. Start server: `node central-admin/server/app.js`
2. Note your kiosk's current IP address
3. Check `central-admin/server/lab-config.js`:
   - If IP starts with `192.168.29.*` → Detected as CC1
   - If IP starts with `10.10.46.*` → Detected as CC2
   - If IP starts with `10.10.47.*` → Detected as CC3
4. Start kiosk (any system number, e.g., CC1-05)
5. Check server console logs:
   ```
   ✅ Kiosk registered: CC1-05
   🌐 Lab detected: CC1 (from IP: 192.168.29.XXX)
   📝 System registry updated
   ```

**Expected Result**:
- System appears in correct lab based on IP prefix
- Server console shows detected lab

**Verify in MongoDB**:
```javascript
db.systemregistries.find({ systemNumber: 'CC1-05' })

// Should return:
{
  systemNumber: 'CC1-05',
  labId: 'CC1',
  ipAddress: '192.168.29.XXX',
  status: 'available',
  lastSeen: ISODate(),
  isGuest: false
}
```

---

### Test 2: Pre-Login System Visibility ⭐ CRITICAL

**Purpose**: Verify systems appear in admin dashboard BEFORE student login

**Steps**:
1. Power on kiosk (DON'T log in as student)
2. Kiosk should show login screen with CC1-05 system number
3. Open admin dashboard: `http://localhost:3001/admin-dashboard.html`
4. Dashboard loads, shows lab selector
5. Select "Computer Center Lab 1 (CC1)"
6. Look for CC1-05 button

**Expected Result**:
- ✅ CC1-05 appears with 🟢 GREEN status (Available)
- ✅ Button is clickable
- ✅ Button text: "🟢 CC1-05"
- ✅ No student name shown underneath

**This proves**: Guest access can work on systems before login!

---

### Test 3: Guest Access on Available System ⭐ CRITICAL

**Purpose**: Test remote guest unlock feature

**Setup**:
- Kiosk powered on, showing login screen (NOT logged in)
- Admin dashboard open, CC1 lab selected

**Steps**:
1. **Admin**: Find CC1-05 with 🟢 status
2. **Admin**: Click "🟢 CC1-05" button
3. **Admin**: Confirm dialog: "Enable guest access?"
4. **Kiosk**: Watch the screen carefully
5. **Kiosk**: Should automatically:
   - Show "GUEST ACCESS ENABLED" message
   - Login screen disappears
   - Desktop appears (minimal interface)
   - System number shows "CC1-05 - GUEST MODE"

**Expected Result**:
- ✅ Kiosk unlocks within 2 seconds
- ✅ Admin dashboard button changes to 🟣 PURPLE
- ✅ Button shows: "🟣 CC1-05" with "Guest User" underneath
- ✅ Admin console shows: "Guest access enabled for CC1-05"

**Verify Guest Card**:
- Card appears in "Active Students" section
- Badge: "🆓 GUEST MODE" (purple background)
- Student ID: GUEST
- Student Name: Guest User
- System: CC1-05

---

### Test 4: Multi-Lab Isolation

**Purpose**: Verify labs don't interfere with each other

**Setup** (if you can simulate):
- Edit `lab-config.js` temporarily:
  ```javascript
  'CC1': { ipPrefix: '192.168.29', ... },
  'CC2': { ipPrefix: '192.168.30', ... }, // Use a different subnet
  ```
- Start 2 kiosks with different IPs

**Steps**:
1. Kiosk 1: IP `192.168.29.101`, System CC1-05
2. Kiosk 2: IP `192.168.30.101`, System CC2-10
3. Open Admin Dashboard 1: Select CC1
4. Open Admin Dashboard 2: Select CC2
5. Dashboard 1: Enable guest on CC1-05
6. Dashboard 2: Should NOT show CC1-05 (only CC2 systems)

**Expected Result**:
- Dashboard 1: Shows 60 systems CC1-01 to CC1-60
- Dashboard 2: Shows 60 systems CC2-01 to CC2-60
- No cross-lab visibility

---

### Test 5: Lab Selector UI

**Purpose**: Test lab dropdown and system loading

**Steps**:
1. Open admin dashboard
2. Check lab selector dropdown (top of guest access section)
3. Dropdown should show:
   ```
   -- Select Lab --
   Computer Center Lab 1 (CC1)
   Computer Center Lab 2 (CC2)
   Computer Center Lab 3 (CC3)
   Computer Center Lab 4 (CC4)
   Computer Center Lab 5 (CC5)
   ```
4. Select CC1
5. Wait for systems to load (1-2 seconds)
6. Should see 60 system buttons: CC1-01 through CC1-60
7. Lab stats should show:
   ```
   Total: 60 | 🟢 Available: X | 🔵 Logged In: X | 🟣 Guest: X | ⚫ Offline: X
   ```

**Expected Result**:
- Dropdown works smoothly
- Systems load dynamically
- All 60 systems visible
- Stats update correctly

---

### Test 6: Status Color Coding

**Purpose**: Verify system status colors are correct

**Setup**: Need systems in different states

**Status Scenarios**:

| Status | Button Color | Icon | Condition |
|--------|-------------|------|-----------|
| **Available** | 🟢 Green gradient | 🟢 | Kiosk on, no user |
| **Logged In** | 🔵 Blue gradient | 🔵 | Student logged in |
| **Guest** | 🟣 Purple gradient | 🟣 | Guest access enabled |
| **Offline** | ⚫ Gray | ⚫ | Not responding |

**Steps**:
1. **Available**: Power on kiosk, don't login → Should be 🟢
2. **Logged In**: Login as student → Should change to 🔵
3. **Guest**: Enable guest access → Should change to 🟣
4. **Offline**: Shut down kiosk → Should change to ⚫ (after 5 min)

**Expected Result**:
- Colors match status accurately
- Transitions happen in real-time
- Available and Guest buttons are clickable
- Logged In and Offline buttons are disabled

---

### Test 7: Real-Time Updates

**Purpose**: Test Socket.IO broadcast updates

**Setup**:
- Open 2 admin dashboards in different browser windows
- Both select same lab (CC1)
- Both should see same systems

**Steps**:
1. Admin 1: Enable guest on CC1-05
2. Admin 2: Watch CC1-05 button
3. Button should turn purple automatically (within 1 second)
4. Admin 2: No page refresh needed

**Expected Result**:
- ✅ Changes sync across all admin dashboards instantly
- ✅ No manual refresh required
- ✅ System registry updates broadcast to all admins

---

### Test 8: Student Login After Guest Mode

**Purpose**: Test transition from guest to student login

**Steps**:
1. Enable guest on CC1-05 (system unlocks)
2. Guest user uses system for a while
3. Admin locks system (or guest logs out manually)
4. Student logs in normally on CC1-05
5. Admin dashboard should show:
   - Status changes from 🟣 Guest to 🔵 Logged In
   - Student name appears
   - Guest card disappears
   - Normal student card appears

**Expected Result**:
- Smooth transition from guest to student
- No database conflicts
- System registry updates correctly

---

### Test 9: API Endpoint Testing

**Purpose**: Verify API endpoints work correctly

**Using Browser or Postman**:

#### Test `/api/labs`
```http
GET http://localhost:3001/api/labs

Expected Response:
{
  "success": true,
  "labs": {
    "CC1": {
      "labId": "CC1",
      "labName": "Computer Center Lab 1",
      "ipPrefix": "192.168.29",
      "systemCount": 60,
      "systemRange": ["CC1-01", ..., "CC1-60"]
    },
    "CC2": { ... },
    ...
  }
}
```

#### Test `/api/systems/:labId`
```http
GET http://localhost:3001/api/systems/CC1

Expected Response:
{
  "success": true,
  "labId": "CC1",
  "labName": "Computer Center Lab 1",
  "systems": [
    {
      "systemNumber": "CC1-01",
      "labId": "CC1",
      "status": "available",
      "ipAddress": "192.168.29.101",
      "lastSeen": "2024-12-12T10:30:00Z",
      "currentStudentId": null,
      "isGuest": false
    },
    ...
  ],
  "totalSystems": 60,
  "availableSystems": 45,
  "loggedInSystems": 10,
  "guestSystems": 2,
  "offlineSystems": 3
}
```

---

### Test 10: Offline Detection (Future)

**Purpose**: Verify systems marked offline after timeout

**Setup**: Requires timeout implementation (not yet added)

**Steps**:
1. System CC1-05 is online (green)
2. Shut down kiosk (power off)
3. Wait 5 minutes
4. Server should auto-mark as offline
5. Admin dashboard shows ⚫ gray button

**Implementation Needed**:
Add to `app.js`:
```javascript
// Run every 5 minutes
setInterval(async () => {
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
  await SystemRegistry.updateMany(
    { lastSeen: { $lt: fiveMinutesAgo }, status: { $ne: 'offline' } },
    { $set: { status: 'offline' } }
  );
}, 5 * 60 * 1000);
```

---

## 🐛 Troubleshooting

### Issue: Systems Not Appearing in Dashboard

**Possible Causes**:
1. Kiosk not connected to server
2. Lab selector not selected
3. API endpoint error

**Debug Steps**:
```javascript
// Check browser console (Admin Dashboard)
// Should see:
"📄 Admin dashboard DOM loaded"
"Labs loaded: { CC1: {...}, CC2: {...} }"
"Loading systems for CC1..."
"Systems loaded: 60 systems"

// Check server console
// Should see:
"✅ Kiosk registered: CC1-05"
"🌐 Lab detected: CC1"
"📝 System registry updated"

// Check MongoDB
db.systemregistries.find()
```

### Issue: Guest Access Not Working

**Check**:
1. Socket.IO connection established?
2. System number matches exactly?
3. Kiosk listening for `enable-guest-access` event?

**Debug**:
```javascript
// Kiosk console (student-interface.html)
socket.on('enable-guest-access', (data) => {
  console.log('🔓 Guest access received:', data);
  // Should trigger auto-login
});
```

### Issue: Wrong Lab Detected

**Check `lab-config.js`**:
- IP prefix matches your network
- Example: If your kiosk IP is `10.10.46.105` but lab shows CC1:
  ```javascript
  'CC2': {
    ipPrefix: '10.10.46',  // ← Make sure this matches
    ...
  }
  ```

---

## ✅ Success Criteria

### ✅ Test Pass Checklist

- [ ] Server detects lab from IP correctly
- [ ] Systems appear in dashboard before login (pre-login visibility)
- [ ] Guest access unlocks kiosk remotely
- [ ] Button colors match status (🟢🔵🟣⚫)
- [ ] Lab selector loads all labs
- [ ] Selecting lab loads 60 systems
- [ ] Real-time updates work across multiple admins
- [ ] Lab statistics show correct counts
- [ ] API endpoints return valid data
- [ ] No errors in browser console
- [ ] No errors in server console

---

## 📊 Expected Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│ 🏢 Select Lab: [▼ Computer Center Lab 1 (CC1)        ]│
│    Total: 60 | 🟢 45 | 🔵 10 | 🟣 2 | ⚫ 3            │
├─────────────────────────────────────────────────────────┤
│ Legend: 🟢 Available | 🔵 Logged In | 🟣 Guest | ⚫ Off│
├─────────────────────────────────────────────────────────┤
│                                                           │
│  [🟢 CC1-01]  [🟢 CC1-02]  [🔵 CC1-03]  [🟢 CC1-04]  │
│              Available    John Doe     Available        │
│                                                           │
│  [⚫ CC1-05]  [🟣 CC1-06]  [🟢 CC1-07]  [🟢 CC1-08]  │
│   Offline     Guest User   Available    Available        │
│                                                           │
│  [... 52 more systems ...]                               │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Next Steps After Testing

1. ✅ Verify basic functionality works
2. ⏳ Add offline detection (5-minute timeout)
3. ⏳ Filter active students by selected lab
4. ⏳ Add lab-scoped timetable upload
5. ⏳ Test with actual college IP ranges
6. ⏳ Deploy to production labs

---

## 📝 Test Results Template

```markdown
# Test Results - [Date]

## Environment
- Server: Running / Not Running
- MongoDB: Connected / Not Connected
- Kiosk IP: [Your IP]
- Detected Lab: [CC1/CC2/etc]

## Test Results

### Test 1: Lab Detection
- ✅ PASS / ❌ FAIL
- Notes: [Any issues or observations]

### Test 2: Pre-Login Visibility
- ✅ PASS / ❌ FAIL
- Notes: [...]

### Test 3: Guest Access
- ✅ PASS / ❌ FAIL
- Notes: [...]

[... continue for all tests ...]

## Issues Found
1. [Issue description]
2. [Issue description]

## Overall Status
- ✅ Ready for Production
- ⏳ Needs Minor Fixes
- ❌ Major Issues Found
```

---

**Ready to test! Start with Test 1 (Lab Detection) and work your way through.**
