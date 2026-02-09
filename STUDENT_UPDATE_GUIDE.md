# 🔄 Student System Update Guide

## Overview
After deploying student kiosks, you need to update them when making changes. The method depends on how you deployed.

---

## ⚡ Quick Reference

| Change Type | Requires Update? | Restart Needed? |
|-------------|-----------------|-----------------|
| **server/app.js** (Backend) | ❌ No - students auto-connect | ✅ Yes (server) |
| **admin-dashboard.html** | ❌ No - just refresh browser | ❌ No |
| **student-interface.html** | ✅ Yes - update deployed files | ✅ Yes (kiosk) |
| **main-simple.js** (Electron) | ✅ Yes - update deployed files | ✅ Yes (kiosk) |
| **preload.js** | ✅ Yes - update deployed files | ✅ Yes (kiosk) |

---

## 🎯 Update Methods

### **Method 1: Network Share Deployment** ⭐ EASIEST

If students run kiosk from network share (`\\SERVER\LabMonitoring`):

```batch
# 1. Update files on network share
xcopy /Y /E student_deployment_package\student-kiosk\*.* \\SERVER\LabMonitoring\student-kiosk\

# 2. That's it! Students get updates on next restart
```

**Advantages:**
- ✅ Update once, all systems get it
- ✅ No need to visit each computer
- ✅ Centralized control

**To restart all kiosks:**
- Students can close and reopen
- OR use remote restart (see Method 4)

---

### **Method 2: USB Drive Update** 💾 PORTABLE

For local installations without network access:

**Step 1:** Create USB package
```batch
# Run this script
UPDATE_DEPLOYED_STUDENTS.bat

# Choose option 2 (USB Update)
# Copy USB_UPDATE_PACKAGE folder to USB drive
```

**Step 2:** On each student PC
1. Insert USB drive
2. Run `UPDATE_KIOSK.bat` from USB
3. Restart the kiosk application

**Best for:** Small deployments (1-10 computers)

---

### **Method 3: Remote Network Update** 🌐 AUTOMATED

For computers on same network with admin access:

**Step 1:** Create computer list
```text
File: computers.txt
LAB-PC-01
LAB-PC-02
LAB-PC-03
```

**Step 2:** Run remote update
```batch
# Update all at once
for /f %i in (computers.txt) do (
    xcopy /Y /E student_deployment_package\student-kiosk\*.* \\%i\c$\Users\Public\LabMonitoring\student-kiosk\
)
```

**Requirements:**
- Admin credentials on all computers
- File sharing enabled
- Same installation path on all PCs

---

### **Method 4: Group Policy / SCCM** 🏢 ENTERPRISE

For large deployments:

1. **Create MSI/Install package** with updated files
2. **Push via Group Policy** or **SCCM**
3. **Schedule deployment** during non-class hours
4. **Auto-restart kiosks** after update

---

## 📝 Step-by-Step: Common Scenarios

### Scenario A: Guest Mode Password Not Working

**What changed:** Backend (`app.js`)

**Steps:**
1. ⚠️ **STOP** - This is server-side only!
2. Restart the server:
   ```batch
   cd central-admin\server
   Ctrl+C (stop server)
   node app.js
   ```
3. ✅ No student updates needed!

---

### Scenario B: Guest Login Button Missing

**What changed:** Frontend (`student-interface.html`)

**Steps:**
1. Update your local file: `student-interface.html`
2. Deploy update:

   **If Network Share:**
   ```batch
   copy student_deployment_package\student-kiosk\student-interface.html \\SERVER\LabMonitoring\student-kiosk\
   ```

   **If Local Install:**
   - Visit each PC
   - Copy updated file to `%LOCALAPPDATA%\LabMonitoring\student-kiosk\`
   - Restart kiosk

3. ✅ Verify on one computer first!

---

### Scenario C: IPC Handler Update

**What changed:** Electron main process (`main-simple.js`)

**Steps:**
1. Update local file
2. **IMPORTANT:** Electron changes require full app restart
3. Deploy using same method as above
4. Students must close and reopen kiosk (not just refresh)

---

## 🚀 Recommended Workflow

### For Development/Testing:
```
1. Make changes to files in: student_deployment_package\student-kiosk\
2. Test locally first (run kiosk from this folder)
3. Once working, deploy to network share or individual PCs
```

### For Production Updates:
```
1. Backup current deployment
2. Test updated files on ONE computer
3. If working, deploy to all systems
4. Monitor first few students for issues
5. Keep backup for 24 hours
```

---

## ⚠️ Important Notes

### Server vs Client Changes

| Location | Type | Update Method |
|----------|------|---------------|
| `central-admin/server/app.js` | Server | Restart server only |
| `central-admin/dashboard/` | Admin UI | Just refresh browser |
| `student-kiosk/student-interface.html` | Client UI | Update deployed files |
| `student-kiosk/main-simple.js` | Client App | Update deployed files + restart |

### File Paths

**Development:**
```
d:\New_SDC\lab_monitoring_system\student_deployment_package\student-kiosk\
```

**Network Deployment:**
```
\\SERVER\LabMonitoring\student-kiosk\
```

**Local Installation:**
```
C:\Users\[username]\AppData\Local\LabMonitoring\student-kiosk\
```

---

## 🔧 Troubleshooting

### "Updates not appearing"
- ✅ Check file actually copied
- ✅ Restart kiosk (close and reopen)
- ✅ Clear cache: Delete `.cache` folder
- ✅ Verify correct path

### "Cannot access network share"
- ✅ Check network connectivity
- ✅ Verify share permissions
- ✅ Test with UNC path: `\\SERVER\share`

### "Some PCs updated, others didn't"
- ✅ Check installation paths are same
- ✅ Verify file permissions
- ✅ Some may need manual restart

---

## 📋 Update Checklist

Before deploying updates:

- [ ] Test changes locally first
- [ ] Backup current deployed version
- [ ] Document what changed
- [ ] Update version number/date
- [ ] Test on one student PC
- [ ] Notify lab users of update
- [ ] Deploy to all systems
- [ ] Verify on multiple PCs
- [ ] Monitor for issues
- [ ] Keep backup for 24 hours

---

## 🎯 Best Practices

1. **Always test first** - Don't deploy untested changes
2. **Update during off-hours** - Minimal disruption
3. **Keep backups** - Easy rollback if issues
4. **Document changes** - Know what was updated
5. **Staged rollout** - Update a few PCs first
6. **Version control** - Track all changes
7. **Communication** - Notify users of updates

---

## 🆘 Emergency Rollback

If update causes issues:

```batch
# 1. Restore from backup
xcopy /Y /E backup\student-kiosk\*.* \\SERVER\LabMonitoring\student-kiosk\

# 2. Restart affected kiosks

# 3. Investigate issue before re-deploying
```

---

## 📞 Quick Commands

### Check if file is updated:
```batch
dir \\SERVER\LabMonitoring\student-kiosk\student-interface.html
```

### Force restart all kiosks (PsExec):
```batch
for /f %i in (computers.txt) do psexec \\%i taskkill /F /IM "Lab Monitoring System.exe"
```

### Verify kiosk version:
- Open kiosk
- Check bottom of screen for version/date
- Or check file modified date

---

**Created:** February 8, 2026  
**Last Updated:** February 8, 2026
