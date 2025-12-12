# 🧪 QUICK KIOSK LOCKDOWN TEST GUIDE

## ⚡ 5-Minute Pre-Deployment Test

Before deploying to college lab, run these quick tests to verify everything works.

---

## ✅ TEST 1: Build the Installer (2 minutes)

```powershell
cd d:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app

# Install dependencies (if not already installed)
npm install

# Build Windows installer
npm run build-win
```

**Expected Output:**
```
✓ Compiling...
✓ Building NSIS target
✓ Building target nsis
✓ Creating installer
✓ Packaging...
✓ Built: dist\College-Lab-Kiosk-Setup-1.0.0.exe
```

**Success Criteria:**
- ✅ No build errors
- ✅ Installer file created in `dist/` folder
- ✅ File size > 100MB (includes Electron runtime)

---

## ✅ TEST 2: Install & Launch (1 minute)

1. Navigate to `dist/` folder
2. Run `College-Lab-Kiosk-Setup-1.0.0.exe` (as administrator)
3. Complete installation
4. Verify kiosk launches automatically after install

**Expected Behavior:**
- ✅ Installer opens with college lab kiosk branding
- ✅ Installation completes without errors
- ✅ Kiosk launches in full-screen mode
- ✅ Login screen visible
- ✅ No minimize/maximize/close buttons
- ✅ Window covers entire screen

---

## ✅ TEST 3: Keyboard Blocking (2 minutes)

**With kiosk running (before login), try pressing each key:**

| Key Combo | Expected Result | Status |
|-----------|----------------|---------|
| **Escape** | 🚫 Blocked (window stays) | ☐ |
| **Alt+Tab** | 🚫 Blocked (can't switch apps) | ☐ |
| **Windows Key** | 🚫 Blocked (no Start menu) | ☐ |
| **Windows+D** | 🚫 Blocked (can't show desktop) | ☐ |
| **Windows+E** | 🚫 Blocked (can't open explorer) | ☐ |
| **Windows+R** | 🚫 Blocked (no Run dialog) | ☐ |
| **Windows+L** | 🚫 Blocked (can't lock screen) | ☐ |
| **Alt+F4** | 🚫 Blocked (can't close window) | ☐ |
| **Ctrl+Alt+Delete** | 🚫 Blocked | ☐ |
| **Ctrl+Shift+Escape** | 🚫 Blocked (no task manager) | ☐ |
| **F11** | 🚫 Blocked (can't exit fullscreen) | ☐ |
| **F12** | 🚫 Blocked (no DevTools) | ☐ |
| **Ctrl+Shift+I** | 🚫 Blocked (no DevTools) | ☐ |

**Console Verification (Development Mode Only):**
If running via `npm start` (testing mode), you should see:
```
🚫 Blocked shortcut: Escape
🚫 Blocked shortcut: Alt+Tab
🚫 Blocked shortcut: Meta+D
```

**Success Criteria:**
- ✅ ALL shortcuts above are blocked
- ✅ Window remains focused and on top
- ✅ No way to access other apps
- ✅ Taskbar not accessible

---

## ✅ TEST 4: Auto-Start Verification (2 minutes)

### Method 1: Registry Check (Quick)
```powershell
# Open PowerShell and run:
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object "College Lab Kiosk"
```

**Expected Output:**
```
College Lab Kiosk : C:\Program Files\College Lab Kiosk\College Lab Kiosk.exe
```

### Method 2: Reboot Test (Recommended)
1. Close the kiosk application (if possible - may need Task Manager in admin mode)
2. **Restart Windows computer**
3. Wait for Windows to boot
4. Verify kiosk launches automatically

**Success Criteria:**
- ✅ Registry entry exists
- ✅ After reboot, kiosk launches without user interaction
- ✅ Kiosk opens in full-screen lockdown mode

---

## ✅ TEST 5: Email Validation (1 minute)

1. Click "Forgot Password?" button
2. Try entering invalid emails:

| Email | Expected Result | Status |
|-------|----------------|---------|
| `test@gmail.com` | ❌ Error: "Only @psgitech.ac.in emails are allowed" | ☐ |
| `admin@psgitech.com` | ❌ Error: "Only @psgitech.ac.in emails are allowed" | ☐ |
| `student@psgitech.ac.in` | ✅ Accepts and sends OTP | ☐ |
| `JOHN@PSGITECH.AC.IN` | ✅ Accepts (case insensitive) | ☐ |

**Success Criteria:**
- ✅ Invalid emails rejected with clear error message
- ✅ Valid college emails accepted
- ✅ Validation works on both forgot password and first-time signin

---

## ✅ TEST 6: Server Connection (1 minute)

**Check Console (Testing Mode Only):**
```
✅ Application Ready - System: CC1-05, Lab: CC1
✅ Server: http://localhost:7401
🔒 FULL KIOSK MODE ACTIVE - System completely locked down!
🚫 All keyboard shortcuts blocked until student login
```

**Verify:**
- ☐ System number generated (e.g., CC1-05)
- ☐ Lab ID detected (e.g., CC1)
- ☐ Server URL correct
- ☐ "FULL KIOSK MODE ACTIVE" message present

**Success Criteria:**
- ✅ Server URL matches central admin server
- ✅ Lab detection working (based on IP)
- ✅ Kiosk mode active confirmed

---

## ✅ TEST 7: Student Login (1 minute)

**Prerequisites:**
- Server running (`cd central-admin/server && npm start`)
- Test student account exists

**Test Steps:**
1. Enter valid student credentials (admission number + password)
2. Click "Sign In"
3. Verify login succeeds
4. Check if keyboard shortcuts now work (Alt+Tab, Escape, etc.)

**Success Criteria:**
- ✅ Login successful
- ✅ Student interface loads
- ✅ Shortcuts REMAIN BLOCKED (DevTools still blocked)
- ✅ Admin dashboard shows system as "logged-in"

---

## 🚨 CRITICAL TESTS (Must Pass Before Deployment)

### Test #1: No Escape Before Login ⚠️
**Requirement:** Student CANNOT access Windows desktop before logging in

**Test:** Try EVERY method to escape:
- [ ] Press Escape key
- [ ] Press Alt+Tab
- [ ] Press Windows key
- [ ] Press Alt+F4
- [ ] Click taskbar
- [ ] Right-click window
- [ ] Try to minimize
- [ ] Try to close
- [ ] Try to resize

**Pass Criteria:** ✅ ALL attempts fail, window stays locked

---

### Test #2: Auto-Start Works ⚠️
**Requirement:** Kiosk MUST launch automatically when computer boots

**Test:**
1. Close kiosk (use Task Manager if needed - Ctrl+Shift+Esc in admin mode)
2. Restart Windows
3. Observe boot sequence

**Pass Criteria:** 
- ✅ Kiosk launches within 30 seconds of Windows login
- ✅ No user interaction required
- ✅ Kiosk opens in full-screen lockdown mode

---

### Test #3: DevTools Inaccessible ⚠️
**Requirement:** Students CANNOT open developer tools

**Test:** Try to open DevTools:
- [ ] Press F12
- [ ] Press Ctrl+Shift+I
- [ ] Press Ctrl+Shift+J
- [ ] Press Ctrl+Shift+C
- [ ] Right-click → Inspect (should be no context menu)

**Pass Criteria:** ✅ ALL attempts fail, DevTools never opens

---

## 📊 FULL TEST SUMMARY

**Before Marking as "Deployment Ready":**

| Test | Status | Critical? |
|------|--------|-----------|
| 1. Build Installer | ☐ | ✅ YES |
| 2. Install & Launch | ☐ | ✅ YES |
| 3. Keyboard Blocking | ☐ | ✅ YES |
| 4. Auto-Start | ☐ | ✅ YES |
| 5. Email Validation | ☐ | ⚠️ Important |
| 6. Server Connection | ☐ | ✅ YES |
| 7. Student Login | ☐ | ⚠️ Important |

**Deployment Decision:**
- ✅ **ALL critical tests pass** → DEPLOY TO COLLEGE LAB
- ❌ **Any critical test fails** → FIX ISSUE FIRST
- ⚠️ **Important test fails** → Deploy with caution, note issue

---

## 🐛 TROUBLESHOOTING DURING TESTING

### Issue: Build fails with "electron-builder not found"
```powershell
npm install --save-dev electron-builder
npm run build-win
```

### Issue: Installer doesn't create auto-start registry entry
**Check:** Verify `build/installer.nsh` exists and contains:
```nsis
WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "College Lab Kiosk" "$INSTDIR\College Lab Kiosk.exe"
```

**Fix:** Reinstall using the newly built installer

### Issue: Keyboard shortcuts NOT blocked
**Check:** Verify `KIOSK_MODE = true` in `main-simple.js` line 120

**Fix:**
1. Edit `main-simple.js` → Set `KIOSK_MODE = true`
2. Rebuild: `npm run build-win`
3. Reinstall

### Issue: Can't close kiosk to test reboot
**Solution:** Open Task Manager as admin:
```powershell
# In PowerShell (as admin):
taskkill /F /IM "College Lab Kiosk.exe"
```

### Issue: DevTools still accessible
**Check:**
1. Verify `KIOSK_MODE = true`
2. Verify `devTools: false` in window configuration
3. Rebuild installer

---

## ✅ QUICK TEST CHECKLIST (Print This)

**Date:** ___________  
**Tester:** ___________  
**System:** ___________

- [ ] Installer builds successfully
- [ ] Installation completes without errors
- [ ] Kiosk launches in full-screen
- [ ] **Escape key blocked**
- [ ] **Alt+Tab blocked**
- [ ] **Windows key blocked**
- [ ] **Alt+F4 blocked**
- [ ] **Ctrl+Alt+Delete blocked**
- [ ] **F12 blocked (no DevTools)**
- [ ] Registry entry created
- [ ] Auto-start works after reboot
- [ ] Email validation enforces @psgitech.ac.in
- [ ] Server connection successful
- [ ] Student login works

**Test Result:**
- [ ] ✅ ALL PASS - Ready for deployment
- [ ] ⚠️ SOME ISSUES - Review failed tests
- [ ] ❌ CRITICAL FAILURES - Do not deploy

**Notes:**
_________________________________
_________________________________
_________________________________

---

## 🚀 AFTER TESTING: DEPLOYMENT STEPS

**If all tests pass:**

1. **Copy installer to USB drive:**
   ```powershell
   Copy-Item "d:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app\dist\College-Lab-Kiosk-Setup-1.0.0.exe" -Destination "E:\" 
   ```

2. **For EACH lab computer:**
   - Insert USB drive
   - Run installer as administrator
   - Wait for installation to complete
   - Verify kiosk launches
   - Test Escape and Alt+Tab (should be blocked)
   - Restart computer
   - Verify auto-start works

3. **Document each system:**
   - Computer name: ___________
   - IP address: ___________
   - Lab ID detected: ___________
   - System number: ___________
   - Installation date: ___________
   - Tested by: ___________

4. **Final verification:**
   - All systems appear in admin dashboard
   - Screen mirroring works
   - Guest access functional
   - Students can login successfully

---

**⏱️ ESTIMATED TOTAL TEST TIME: 10-15 minutes**

**🎯 GOAL: 100% pass rate on all critical tests before college deployment**

---

**📞 Need Help?**
- Check `KIOSK_LOCKDOWN_COMPLETE.md` for detailed troubleshooting
- Review console logs (in testing mode: `npm start`)
- Verify all configuration files match documentation

**🔐 Remember:** Never deploy with `KIOSK_MODE = false` in production!
