# Quick Test Guide - Remaining Features

**System Status:** Server running at `http://192.168.29.212:7401`  
**Active Session:** `693ac27ac6e54dcfd1d2f93d`  
**Logged-in Student:** Srijaa A (715524104158)  
**Kiosk System:** CC1-10

---

## Test 1: Screen Mirroring (WebRTC) - 5 minutes

**Prerequisites:**
- ✅ Admin dashboard open: http://192.168.29.212:7401
- ✅ Kiosk logged in (Session: 693ac27ac6e54dcfd1d2f93d)
- ✅ ICE candidate queueing fixed

**Steps:**
1. In admin dashboard, find the student card for "Srijaa A" (System: CC1-10)
2. Click the **"Start Monitoring"** button on the student card
3. **Expected Results:**
   - Video player appears on admin dashboard
   - Kiosk screen visible in video stream
   - No console errors about "remote description was null"
4. **If it works:** ✅ Mark as PASSED
5. **If errors:** Check browser console for specific WebRTC errors

**Known Issue:**
- Kiosk shows Windows Graphics Capture errors (error code -2147024809)
- This may affect stream quality but should not prevent basic functionality

---

## Test 2: Forgot Password Flow - 10 minutes

**Prerequisites:**
- Test email configured in server
- Student exists: 715524104158 / password123

**Steps:**
1. **Logout from kiosk:**
   - Close timer window or use logout button
   - Return to login screen

2. **Click "Forgot Password"** on login screen

3. **Enter Student ID:** 715524104158

4. **Enter email address** (the one registered for this student)

5. **Check email for OTP code**
   - OTP expires in 10 minutes
   - Check spam folder if not in inbox

6. **Enter OTP and new password:**
   - New password: `newpass123` (or any secure password)
   - Confirm new password

7. **Submit reset form**

8. **Login with new credentials:**
   - Student ID: 715524104158
   - Password: newpass123 (the new one you set)

**Expected Results:**
- ✅ OTP email received within 30 seconds
- ✅ Password reset successful message shown
- ✅ Login works with new password
- ✅ Old password (password123) no longer works

**If it fails:**
- Check server logs for email sending errors
- Verify email configuration in server
- Check MongoDB for student record

---

## Test 3: First-Time Sign In - 10 minutes

**Prerequisites:**
- New student not yet in database
- Test DOB known for verification

**Steps:**
1. **Click "First Time Sign In"** on login screen

2. **Enter new student details:**
   - Student ID: `NEW2025001` (any unique ID)
   - Name: `Test New Student`
   - Email: `testnew@example.com`
   - Phone: `9876543210`
   - Department: Computer Science and Engineering
   - Section: A
   - Year: 2

3. **Enter Date of Birth for verification:**
   - Use a memorable DOB like: 15/08/2003

4. **Set initial password:**
   - Password: `firstpass123`
   - Confirm password: `firstpass123`

5. **Submit form**

6. **Login with new credentials:**
   - Student ID: NEW2025001
   - Password: firstpass123

**Expected Results:**
- ✅ Account created successfully
- ✅ Success message shown
- ✅ New student visible in MongoDB/admin dashboard
- ✅ Login works immediately with new credentials

**If it fails:**
- Check server logs for database errors
- Verify DOB format accepted by server
- Check if student ID already exists

---

## Test 4: Automatic Timetable - Variable time

**Prerequisites:**
- Sample CSV file ready
- Admin dashboard access

**Sample CSV Format:**
```csv
Date,Start Time,End Time,Subject,Faculty,Lab
2025-12-11,19:00,19:30,Test Session,Prof Test,CC1
```

**Steps:**
1. **Create test timetable CSV:**
   - Set start time 5 minutes from now
   - Set end time 10 minutes after start
   - Use current date (2025-12-11)

2. **Upload to admin dashboard:**
   - Navigate to Timetable section
   - Click "Upload Timetable"
   - Select your CSV file
   - Click "Upload"

3. **Verify upload success:**
   - Success message should show: "✅ Timetable uploaded successfully! X entries saved."
   - Check server logs for timetable entry creation

4. **Wait for scheduled start time:**
   - Watch server console at scheduled time
   - Look for: `📅 Timetable trigger: Starting session for Test Session`

5. **Verify on kiosk:**
   - Kiosk should show lab session started notification
   - System should become monitored

6. **Wait for scheduled end time:**
   - Look for: `📅 Timetable trigger: Ending session for Test Session`
   - Kiosk should show 60-second countdown
   - Logout should occur automatically

**Expected Results:**
- ✅ Upload successful with entry count
- ✅ Session starts automatically at scheduled time
- ✅ Console log shows timetable trigger
- ✅ Session ends automatically at end time
- ✅ CSV report generated in reports/automatic/

**If it fails:**
- Check CSV format matches expected structure
- Verify times are in HH:MM format (24-hour)
- Check server cron scheduler is running
- Verify date format is YYYY-MM-DD

---

## Test 5: Session End & Shutdown - 5 minutes

**Prerequisites:**
- Active lab session running
- Student logged into kiosk

**Steps:**
1. **Admin ends session:**
   - Click "End Lab Session" in admin dashboard
   - Confirm the action

2. **Check kiosk immediately:**
   - Should show notification: "Lab session ending in 60 seconds"
   - Countdown timer visible
   - "Logout" button present

3. **Option A - Manual logout:**
   - Click "Logout" button
   - Verify shutdown countdown: "System will shutdown in 90 seconds"
   - Verify timer shows "1 minute 30 seconds"

4. **Option B - Auto logout:**
   - Wait for 60-second countdown to reach 0
   - Auto-logout should trigger
   - Shutdown countdown should start

5. **Cancel shutdown (for testing):**
   - Open CMD as administrator
   - Run: `shutdown /a`
   - This aborts the shutdown for testing purposes

**Expected Results:**
- ✅ Notification appears within 2 seconds
- ✅ 60-second countdown accurate
- ✅ Logout button functional
- ✅ Auto-logout works if no action taken
- ✅ 90-second shutdown countdown starts
- ✅ Return to login screen after logout

**If it fails:**
- Check Socket.io connection in browser console
- Verify `lab-session-ending` event handler in renderer.js
- Check if shutdown command requires admin privileges

---

## Quick Verification Commands

### Check if server is running:
```powershell
Test-NetConnection -ComputerName 192.168.29.212 -Port 7401
```

### Check processes:
```powershell
Get-Process | Where-Object {$_.ProcessName -match "node|electron"}
```

### Check MongoDB connection:
- Open admin dashboard
- Check browser console for "MongoDB connected"

### View server logs in real-time:
```powershell
cd D:\screen_mirror_deployment_my_laptop\central-admin\server
node app.js 2>&1 | Tee-Object -FilePath server.log
```

---

## Troubleshooting

### Screen Mirroring Not Working:
1. Check browser console for WebRTC errors
2. Verify Socket.io connection in Network tab
3. Check kiosk logs for "Permission requested: media"
4. Try refreshing admin dashboard

### Forgot Password OTP Not Received:
1. Check server logs for email sending errors
2. Verify nodemailer configuration
3. Check spam folder
4. Ensure student has email address in database

### Automatic Timetable Not Triggering:
1. Verify current server time: `Get-Date -Format "HH:mm"`
2. Check timetable entries in MongoDB
3. Verify cron scheduler running (server logs)
4. Ensure date/time format matches exactly

### Kiosk Not Receiving Events:
1. Check Socket.io connection status
2. Verify kiosk registered with correct session ID
3. Refresh kiosk application
4. Check server logs for socket events

---

## Test Results Template

Copy this to record your test results:

```
=== TEST RESULTS ===
Date: 2025-12-11
Time: 18:45 IST

[ ] Test 1: Screen Mirroring
    Status: ___________
    Notes: ___________

[ ] Test 2: Forgot Password
    Status: ___________
    Notes: ___________

[ ] Test 3: First-Time Sign In
    Status: ___________
    Notes: ___________

[ ] Test 4: Automatic Timetable
    Status: ___________
    Notes: ___________

[ ] Test 5: Session End & Shutdown
    Status: ___________
    Notes: ___________

Overall Status: ___ / 5 tests passed

Issues Found:
1. ___________
2. ___________

Recommendations:
1. ___________
2. ___________
```

---

*Generated: 2025-12-11 18:45 IST*  
*System Version: 1.0.0*
