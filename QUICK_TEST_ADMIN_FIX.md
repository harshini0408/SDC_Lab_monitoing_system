# ⚡ Quick Testing Guide - Admin Session Persistence Fix

**Date:** January 20, 2026  
**Purpose:** Verify screen mirroring and session persistence work correctly

---

## 🎯 What Was Fixed

1. ✅ Screen mirroring now works DURING active session
2. ✅ Admin session persists after page refresh
3. ✅ Screen mirroring reconnects automatically after refresh

---

## 🧪 Quick Test (5 Minutes)

### Step 1: Start Admin Dashboard

1. Open admin dashboard in browser
2. Login if required
3. Wait for page to fully load

### Step 2: Login 1-2 Students

1. Use AnyDesk to access student system(s)
2. Login to student kiosk with credentials
3. Wait for student to appear in admin dashboard
4. Verify screen mirroring starts automatically (video appears)

**✅ Expected:** Video feed appears for each student

### Step 3: Start a Lab Session

**Option A: Upload Timetable**
1. Click "Upload Timetable"
2. Select CSV file
3. Wait for session to auto-start

**Option B: Manual Start**
1. Click "Start Lab Session"
2. Fill in subject, faculty details
3. Click confirm

**✅ Expected:** 
- Session starts successfully
- Screen mirroring CONTINUES working (video doesn't stop)
- Console shows: "Force-starting monitoring for: [sessionId]"

### Step 4: Test Page Refresh

1. Press **F5** or **Ctrl+R** to refresh the page
2. Wait 5-10 seconds

**✅ Expected:**
- Page reloads
- Session info restored (subject, faculty, timer)
- Student tiles reappear
- Screen mirroring reconnects automatically
- Notification appears: "SESSION RESTORED - Reconnecting screen mirroring..."

### Step 5: Test Multiple Refreshes

1. Refresh the page 2-3 more times
2. Wait a few seconds after each refresh

**✅ Expected:**
- Session persists after each refresh
- Screen mirroring reconnects each time
- No errors in console

---

## ✅ Success Criteria

All of these should work:

- [ ] Screen mirroring works BEFORE session starts
- [ ] Screen mirroring works AFTER session starts
- [ ] Screen mirroring works DURING active session
- [ ] Page refresh restores session state
- [ ] Page refresh restores student connections
- [ ] Page refresh restores screen mirroring
- [ ] Multiple refreshes work without issues
- [ ] Session timer continues after refresh
- [ ] End session button works and clears state

---

## 🐛 If Something Doesn't Work

### Check 1: Browser Console

Open DevTools (F12) and look for:

**Good signs (✅):**
```
💾 Admin session state saved to localStorage
📦 Found saved admin session state
🔄 Restored X connected students
✅ Admin session state restored from localStorage
🔄 RECONNECTING TO ACTIVE STUDENTS
🎥 Reconnecting to session: [sessionId]
```

**Bad signs (❌):**
```
❌ Failed to save admin session state
❌ Failed to restore admin session state
❌ Video container not found
❌ Connection failed
```

### Check 2: localStorage

In browser console, run:
```javascript
JSON.parse(localStorage.getItem('adminSessionState'))
```

Should show:
```json
{
  "sessionActive": true,
  "currentLabSession": { ... },
  "connectedStudents": [ ... ],
  "timestamp": "2026-01-20T..."
}
```

If null or undefined, state is not being saved.

### Check 3: Network

1. Verify server is running
2. Check if student systems can reach server
3. Test: `ping [server IP]` from student system

---

## 🔧 Common Issues

### Issue 1: Screen Mirroring Stops After Session Start

**Symptom:** Video feeds go blank when session starts

**Solution:** 
- This should now be fixed
- Check console for "Force-starting monitoring" messages
- If still broken, restart admin dashboard

### Issue 2: Session Not Restored After Refresh

**Symptom:** Page refresh clears everything

**Solution:**
- Check localStorage (see above)
- Ensure you're using the updated admin-dashboard.html
- Check browser console for errors

### Issue 3: Screen Mirroring Doesn't Reconnect

**Symptom:** Session restores but no video feeds

**Solution:**
- Wait 10 seconds (reconnection takes time)
- Check console for "Reconnecting to session" messages
- Manually click "Start Monitoring" button if available

---

## 📊 Monitoring During Tests

### What to Watch in Console

**On Page Load:**
```
🚀 Admin dashboard loading...
🔗 Connecting to: http://10.10.46.103:7401
✅ Admin dashboard connected
📦 Found saved admin session state
🔄 Restored X connected students
✅ Admin session state restored from localStorage
🔄 RECONNECTING TO ACTIVE STUDENTS
```

**Every 10 Seconds:**
```
💾 Admin session state saved to localStorage
```

**When Student Connects:**
```
📱 New session created
🎥 AUTO-STARTING monitoring for NEW session
💾 Admin session state saved to localStorage
```

---

## 📝 Test Results Template

Use this to record your test results:

```
========================================
ADMIN SESSION PERSISTENCE TEST RESULTS
========================================

Date: _______________
Tested By: _______________

Test 1: Screen Mirroring During Active Session
[ ] PASS  [ ] FAIL
Notes: _______________________________

Test 2: Session Restoration After Refresh
[ ] PASS  [ ] FAIL
Notes: _______________________________

Test 3: Screen Mirroring Reconnection
[ ] PASS  [ ] FAIL
Notes: _______________________________

Test 4: Multiple Refreshes
[ ] PASS  [ ] FAIL
Notes: _______________________________

Test 5: Session End Cleanup
[ ] PASS  [ ] FAIL
Notes: _______________________________

Overall Status: [ ] ALL PASS  [ ] NEEDS WORK

Issues Encountered:
_____________________________________
_____________________________________
_____________________________________
```

---

## 🚀 Advanced Testing (Optional)

### Test Scenario 1: Network Interruption

1. Start session with students
2. Disable network adapter briefly
3. Re-enable network
4. Verify reconnection

### Test Scenario 2: Long-Running Session

1. Start session
2. Leave it running for 2+ hours
3. Refresh page occasionally
4. Verify state persists

### Test Scenario 3: Browser Close/Reopen

1. Start session with students
2. Close browser completely
3. Reopen browser and navigate to admin dashboard
4. Verify session restores (if within 24 hours)

---

## 🎉 Expected Outcome

After these fixes, you should experience:

✅ **Seamless Screen Mirroring:** Works before, during, and after session starts  
✅ **Persistent Sessions:** Page refresh doesn't break anything  
✅ **Automatic Recovery:** Everything reconnects automatically  
✅ **No Manual Intervention:** Just refresh and wait 5-10 seconds  

---

## 📞 Need Help?

If tests fail:

1. Check `ADMIN_SESSION_PERSISTENCE_FIX.md` for detailed information
2. Review browser console for error messages
3. Verify server is running and accessible
4. Check network connectivity
5. Review `TSI_TROUBLESHOOTING_GUIDE.md`

---

**Ready to test?** Follow the steps above and check off each item! 🚀
