# 🧪 Guest Mode - Quick Test Guide

## Prerequisites
- Server must be running
- MongoDB must be connected
- At least one kiosk system available

---

## ✅ Test 1: Admin Dashboard - View Guest Password

### Steps:
1. Open admin dashboard: `http://localhost:7401/admin-dashboard.html`
2. Scroll down to find the **purple panel** labeled "Guest Mode Password"
3. Verify you can see:
   - Today's date
   - 4-digit password (e.g., "5847")
   - Refresh button
   - Copy button

### Expected Results:
✅ Purple panel is visible
✅ Password displays 4 digits
✅ Date shows current day
✅ Buttons are clickable

---

## ✅ Test 2: Copy Guest Password

### Steps:
1. In admin dashboard, find guest password panel
2. Note the displayed password
3. Click "📋 Copy Password" button
4. Open Notepad and paste (Ctrl+V)

### Expected Results:
✅ Success notification appears
✅ Pasted text matches displayed password
✅ 4 digits are copied

---

## ✅ Test 3: Guest Login - Correct Password

### Steps:
1. Open kiosk interface on a student system
2. Click the **purple "Guest Mode"** button
3. Enter the guest password from admin dashboard
4. Click "Login as Guest"

### Expected Results:
✅ Login successful
✅ Session modal appears showing "Guest User"
✅ Student ID shows "GUEST"
✅ System unlocks for use

---

## ✅ Test 4: Guest Login - Wrong Password

### Steps:
1. Open kiosk interface
2. Click "Guest Mode" button
3. Enter incorrect password (e.g., "0000")
4. Click "Login as Guest"

### Expected Results:
❌ Error message appears
❌ Login rejected
❌ Session does not start
✅ User remains on login screen

---

## ✅ Test 5: Guest User Appears in Admin Dashboard

### Steps:
1. Login as guest on kiosk (Test 3)
2. Switch to admin dashboard
3. Look for the guest user in "Active Students" section

### Expected Results:
✅ Guest user card appears
✅ Card has **purple border** (3px solid)
✅ "🔓" icon shown instead of "👤"
✅ "GUEST MODE" badge visible
✅ Purple gradient background
✅ Student ID shows "GUEST"

---

## ✅ Test 6: Screen Mirroring for Guest

### Steps:
1. Guest user logged in on kiosk
2. In admin dashboard, verify guest card is visible
3. Screen should auto-connect (watch for video feed)
4. Click "🔍 Expand" to view fullscreen

### Expected Results:
✅ Video feed appears automatically
✅ Screen mirroring works
✅ Fullscreen view opens
✅ Can see guest's screen activity

---

## ✅ Test 7: Guest Logout

### Steps:
1. On kiosk with guest session active
2. Click "Logout" button
3. Confirm shutdown dialog

### Expected Results:
✅ Logout confirmation appears
✅ Session ends
✅ System returns to login screen
✅ Guest card removed from admin dashboard
✅ Shutdown countdown begins (60 seconds)

---

## ✅ Test 8: Refresh Guest Password

### Steps:
1. In admin dashboard, locate guest password panel
2. Note current password
3. Click "🔄 Refresh Password" button
4. Verify password still matches

### Expected Results:
✅ Success notification appears
✅ Password remains the same (same day)
✅ Date unchanged
✅ No errors

---

## ✅ Test 9: Multiple Guest Logins

### Steps:
1. Login as guest on System 1
2. Login as guest on System 2 (same password)
3. Check admin dashboard

### Expected Results:
✅ Both systems show in dashboard
✅ Both have purple borders
✅ Both show "GUEST" ID
✅ Different system numbers displayed
✅ Both screen mirrors work independently

---

## ✅ Test 10: API Endpoint Test

### Steps:
1. Open browser
2. Navigate to: `http://localhost:7401/api/guest-password`
3. Examine JSON response

### Expected Results:
```json
{
  "success": true,
  "date": "2026-02-06",
  "password": "5847"
}
```

✅ Success is true
✅ Date matches today
✅ Password is 4 digits

---

## 🔍 Verification Checklist

### Visual Appearance
- [ ] Guest button is purple (gradient: #667eea to #764ba2)
- [ ] Guest modal has purple styling
- [ ] Guest cards have 3px purple border
- [ ] Guest password panel has purple gradient
- [ ] "GUEST MODE" badge is visible

### Functionality
- [ ] Guest password generates automatically
- [ ] Same password works on multiple systems
- [ ] Wrong password is rejected
- [ ] Guest sessions tracked separately
- [ ] Screen mirroring works for guests
- [ ] Guest users can logout
- [ ] Admin can view password anytime

### Database
- [ ] Guest sessions stored with isGuest: true
- [ ] Guest password stored in GuestPassword collection
- [ ] System registry shows guest status
- [ ] Active sessions show guest users

---

## 🐛 Common Issues

### Issue: Guest password shows "Error"
**Solution**: 
- Check MongoDB connection
- Verify server is running
- Check browser console for API errors

### Issue: Guest button not visible
**Solution**:
- Clear browser cache
- Verify you're using updated HTML file
- Check file path is correct

### Issue: Guest login fails with correct password
**Solution**:
- Verify server API is reachable
- Check `/api/guest-authenticate` endpoint
- Check browser network tab for 401 errors

### Issue: Guest card doesn't appear in dashboard
**Solution**:
- Verify WebSocket connection
- Check if session was created in database
- Refresh admin dashboard
- Check browser console for errors

### Issue: Purple styling not showing
**Solution**:
- Hard refresh browser (Ctrl+Shift+R)
- Clear CSS cache
- Verify CSS is loaded correctly
- Check browser dev tools for styling

---

## 📋 Success Criteria

All tests should pass with these results:

✅ Guest password visible in admin dashboard
✅ Guest login works with correct password
✅ Guest login rejected with wrong password  
✅ Guest users show purple border in dashboard
✅ Guest sessions tracked in database
✅ Screen mirroring works for guests
✅ Multiple guests can login simultaneously
✅ Password refreshes correctly
✅ Copy to clipboard works
✅ API endpoint returns valid data

---

## 🎯 Quick Manual Test (5 Minutes)

1. **Start server**: Run `START_SERVER.bat`
2. **Open admin dashboard**: Note guest password
3. **Open kiosk**: Click guest mode, enter password
4. **Verify dashboard**: See purple bordered guest card
5. **Test logout**: Confirm system returns to login

**Expected Time**: 3-5 minutes
**Pass Criteria**: All 5 steps complete without errors

---

## 📞 Report Issues

If any test fails:
1. Note which test failed
2. Check browser console for errors
3. Check server console for API errors
4. Verify database connection
5. Document error messages

---

**Test Document Version**: 1.0  
**Last Updated**: February 6, 2026  
**Status**: Ready for Testing ✅
