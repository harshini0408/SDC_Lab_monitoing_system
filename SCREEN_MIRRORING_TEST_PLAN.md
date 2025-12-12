# Screen Mirroring Fix - Test Plan
**Date:** December 11, 2025  
**Time:** 19:00 IST

---

## 🔧 Changes Made

### Issue Identified:
1. **ICE candidates arriving before peer connection created** - Candidates queued but never flushed
2. **Kiosk stream tracks stopping prematurely** - No keepalive mechanism
3. **Connection timeout too aggressive** - 10 seconds not enough for slow networks
4. **Poor connection state monitoring** - Not enough diagnostic info

### Fixes Applied:

#### 1. Kiosk Side (`renderer.js`):
- ✅ Added track keepalive listeners - automatically restarts if track ends
- ✅ Enhanced track validation before adding to peer connection
- ✅ Better connection state monitoring with auto-recovery
- ✅ Detailed logging for senders and track states
- ✅ Added re-emission of screen-ready on connection failure

#### 2. Admin Side (`admin-dashboard.html`):
- ✅ Check for pre-queued ICE candidates when peer connection created
- ✅ Increased timeout from 10s to 15s for video track receipt
- ✅ Connection kept alive even after timeout (for recovery)
- ✅ Better diagnostic logging

---

## 🧪 Testing Steps

### Step 1: Upload Timetable ⏱️ 3 minutes

1. **Create test timetable CSV:**
   ```csv
   Date,Start Time,End Time,Subject,Faculty,Lab
   2025-12-11,19:15,19:45,Data Structures Test,Prof Test,CC1
   ```
   *(Set start time 10-15 minutes from now)*

2. **Upload to admin dashboard:**
   - Open: http://192.168.29.212:7401
   - Navigate to Timetable section
   - Click "Upload Timetable"
   - Select CSV file
   - Click "Upload"

3. **Verify upload:**
   - Success message: "✅ Timetable uploaded successfully! 1 entries saved."
   - Check server console for: "📅 Timetable entry created"

---

### Step 2: Wait for Automatic Session Start ⏱️ Variable

1. **Monitor server console at scheduled start time:**
   - Look for: `📅 Timetable trigger: Starting session for Data Structures Test`
   - Look for: `🎯 Lab session auto-started via timetable`

2. **Check admin dashboard:**
   - "Active Lab Session" card should show: "Data Structures Test"
   - Status: "Active"
   - Button should change to "End Lab Session"

3. **Expected logs:**
   ```
   📅 Timetable trigger: Starting session for Data Structures Test
   ✅ Lab session created: [session_id]
   🎯 Lab session auto-started via timetable
   📢 Broadcasting lab-session-started event to all kiosks
   ```

---

### Step 3: Student Login to Kiosk ⏱️ 2 minutes

1. **On kiosk system:**
   - Should see lab session notification (if popup enabled)
   - Login screen ready

2. **Login with test credentials:**
   - Student ID: `715524104158`
   - Password: `password123`
   - Click "Sign In"

3. **Expected kiosk logs:**
   ```
   🔐 Attempting authentication for: 715524104158
   ✅ Authentication successful for: Srijaa A
   ✅ Session created: [new_session_id]
   📡 Registering kiosk with sessionId: [new_session_id]
   🎥 Preparing screen capture...
   ✅ Screen stream obtained successfully
   📊 Stream tracks: video (screen:0:0)
   ✅ Track keeper active: video live
   🎉 EMITTING KIOSK-SCREEN-READY EVENT
   Session ID: [new_session_id]
   Has Video: true
   ✅ Screen ready event emitted successfully
   ```

---

### Step 4: Automatic Screen Mirroring Start ⏱️ 10-30 seconds

**CRITICAL: This should happen AUTOMATICALLY without clicking "Start Monitoring"!**

1. **Check admin dashboard immediately after login:**
   - New student card should appear in grid
   - Shows: "Srijaa A (715524104158)"
   - System: CC1-10
   - Status should show: "🔄 Auto-connecting..."

2. **Expected admin logs (within 5 seconds):**
   ```
   📱 New session created: {...}
   ⏳ Student added to grid, will auto-start monitoring in 2 seconds
   🎥 AUTO-STARTING monitoring after delay for: [session_id]
   📹 Starting monitoring for session: [session_id]
   🔗 Created peer connection with enhanced ICE configuration
   🧊 🔄 ADMIN: Found X PRE-QUEUED ICE candidates
   ✅ ADMIN: Offer created and local description set
   📤 ADMIN: Sending offer to kiosk for session: [session_id]
   ✅ ADMIN: Offer sent to kiosk
   🧊 ✅ ADMIN SENDING ICE CANDIDATE for session: [session_id]
   ```

3. **Expected kiosk logs (WebRTC handshake):**
   ```
   📥 KIOSK: Received admin offer
   📥 KIOSK: localStream available: true
   🔗 Creating peer connection for admin offer...
   ✅ KIOSK: Peer connection created
   📊 Adding tracks to peer connection...
   ✅ Adding track 1: video (screen:0:0) readyState: live
   ✅ Track added, sender: created
   ✅ Total tracks added to peer connection: 1
   📊 Peer connection senders: 1
   🤝 KIOSK: Setting remote description
   ✅ KIOSK: Remote description set
   📝 KIOSK: Creating answer
   ✅ KIOSK: Answer created
   📝 KIOSK: Setting local description
   ✅ KIOSK: Local description set
   📤 KIOSK: Sending answer to admin
   ✅ KIOSK: Answer sent - handshake completed!
   🧊 KIOSK SENDING ICE CANDIDATE: host
   🧊 KIOSK SENDING ICE CANDIDATE: srflx
   🔗 Kiosk connection state: connecting
   🧊 Kiosk ICE state: checking
   🔗 Kiosk connection state: connected
   ✅✅✅ KIOSK CONNECTED! VIDEO FLOWING!
   🧊 Kiosk ICE state: connected
   ```

4. **Expected admin logs (after answer received):**
   ```
   📹 WebRTC answer received for session: [session_id]
   ✅ ADMIN: Received answer from kiosk
   ✅ ADMIN: Remote description set successfully
   🧊 🔁 ADMIN: Flushing X queued ICE candidates
   🧊 ✅ ADMIN: ICE candidate added successfully (x times)
   📺 ✅ RECEIVED REMOTE STREAM for session: [session_id]
   📺 Stream tracks: [video track details]
   ✅ Video metadata loaded for session: [session_id]
   ▶️ Video started playing for session: [session_id]
   🔄 Connection state changed: connecting
   🔄 Connection state changed: connected
   ✅ ✅ WebRTC CONNECTED - Video should be flowing now!
   ```

5. **Visual verification on admin dashboard:**
   - Video player should appear in student card
   - Should see live kiosk screen (student's desktop after login)
   - Status indicator changes to: "✅ Connected"
   - Student card gets green border (monitoring class active)

---

## ✅ Success Criteria

### Must Have:
- [ ] Timetable upload successful
- [ ] Session auto-starts at scheduled time
- [ ] Student can login to kiosk
- [ ] Screen mirroring starts **AUTOMATICALLY** (no manual click)
- [ ] Video stream visible in admin dashboard within 30 seconds
- [ ] Video shows kiosk screen clearly
- [ ] Connection stays stable for at least 2 minutes

### Should Have:
- [ ] No console errors (warnings acceptable)
- [ ] Connection state reaches "connected" on both sides
- [ ] ICE state reaches "connected" on both sides
- [ ] Track state is "live" throughout

---

## ❌ Failure Scenarios & Recovery

### If video doesn't appear within 30 seconds:

**Check 1: Is kiosk sending stream?**
```
Look for in kiosk logs:
✅ Screen stream obtained successfully
✅ Track keeper active: video live
✅✅✅ KIOSK CONNECTED! VIDEO FLOWING!
```

**Check 2: Is admin receiving tracks?**
```
Look for in admin logs:
📺 ✅ RECEIVED REMOTE STREAM for session
✅ Video metadata loaded
```

**Check 3: Connection states**
```
Both should show:
Connection state: connected
ICE state: connected
```

**Recovery Actions:**
1. Check Windows Graphics Capture errors in kiosk - may need driver update
2. Verify firewall not blocking WebRTC (UDP ports)
3. Try restarting kiosk (Ctrl+R or npm start)
4. Check network connectivity between admin and kiosk

---

### If "NO VIDEO TRACK RECEIVED" error appears:

**Possible causes:**
1. **Kiosk stream not captured** - Check for Windows Graphics Capture errors
2. **Tracks not added to peer connection** - Check kiosk logs for "Track added"
3. **Network blocking UDP** - Check firewall/router settings
4. **Peer connection closed prematurely** - Check connection state logs

**Recovery:**
1. Kiosk: Press Ctrl+R to restart renderer (keeps session alive)
2. Admin: Refresh dashboard page
3. Check server logs for Socket.io disconnections

---

### If ICE candidates fail:

**Symptoms:**
```
ICE state: failed
Connection state: failed
```

**Causes:**
- NAT traversal issues
- Firewall blocking STUN servers
- Network topology incompatible

**Solutions:**
1. Ensure both on same LAN (192.168.29.x)
2. Check if STUN servers reachable (stun.l.google.com:19302)
3. May need TURN server for complex networks

---

## 📊 Diagnostic Commands

### Check if kiosk is sending video:
Open kiosk DevTools (Ctrl+Shift+I) → Console → Look for:
```javascript
localStream.getTracks()[0].readyState // Should be "live"
pc.getSenders()[0].track.enabled // Should be true
```

### Check if admin is receiving:
Open admin dashboard → F12 → Console → Look for:
```javascript
// Find the video element
document.querySelector(`video[id*="693"]`).srcObject // Should have MediaStream
// Check if stream has tracks
document.querySelector(`video[id*="693"]`).srcObject.getTracks() // Should have 1 video track
```

### Force restart monitoring (admin console):
```javascript
startMonitoring('693ac77dfabe89b108bd58cf') // Use actual session ID
```

---

## 🎯 Expected Timeline

| Time | Event | Duration |
|------|-------|----------|
| 19:00 | Upload timetable | 2 min |
| 19:15 | Session auto-starts | Instant |
| 19:16 | Student logs in | 1 min |
| 19:17 | Screen mirroring auto-starts | 10-30 sec |
| 19:18 | Video visible on admin dashboard | SUCCESS ✅ |

**Total expected time: ~18 minutes from upload to working video**

---

## 📝 Test Results Template

```
=== SCREEN MIRRORING AUTO-START TEST ===
Date: 2025-12-11
Start Time: _______
Tester: _________________

STEP 1: Timetable Upload
[ ] CSV created with correct format
[ ] Upload successful
[ ] Success message shown
Time: _______

STEP 2: Session Auto-Start
[ ] Server logs show timetable trigger
[ ] Admin dashboard shows active session
[ ] Subject and faculty displayed
Scheduled time: _______
Actual start: _______
Delay: _______ seconds

STEP 3: Student Login
[ ] Login successful
[ ] Session created
[ ] Kiosk registered with server
[ ] Screen capture prepared
Student: _________________
Login time: _______

STEP 4: Auto Screen Mirroring
[ ] Student card appeared in admin grid
[ ] "Auto-connecting..." status shown
[ ] Admin sent offer automatically
[ ] Kiosk received offer and sent answer
[ ] ICE candidates exchanged
[ ] Connection state: connected
[ ] Video stream received
[ ] Video visible in dashboard
Start time: _______
Video appeared: _______
Delay: _______ seconds

OVERALL RESULT:
[ ] SUCCESS - Video auto-started and working
[ ] PARTIAL - Video works but manual start needed
[ ] FAIL - No video or errors

Issues encountered:
1. _________________________________
2. _________________________________

Console errors (if any):
_______________________________________
_______________________________________

Video quality: [ ] Excellent [ ] Good [ ] Fair [ ] Poor

Connection stability (2 min test):
[ ] Stable - No disconnections
[ ] Unstable - Reconnected
[ ] Failed - Disconnected permanently

Recommendations:
_______________________________________
_______________________________________

Signature: _______________  Time: ______
```

---

*Ready to test! Start with Step 1: Upload the timetable.*
