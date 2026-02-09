# 🔓 Guest Mode - Quick Reference Card

## 🎯 What is Guest Mode?
Temporary lab access using a daily-changing 4-digit password. No student account required.

---

## 📋 Quick Access

### Admin: View Password
1. Open: `http://localhost:7401/admin-dashboard.html`
2. Scroll to **purple "Guest Mode Password" panel**
3. Password displayed in large font
4. Click "📋 Copy" to clipboard

### Student: Guest Login
1. Go to kiosk login screen
2. Click **purple "Guest Mode"** button
3. Enter 4-digit password
4. Click "Login as Guest"

---

## 🎨 Visual Identification

### Guest Button
- **Color**: Purple gradient (#667eea → #764ba2)
- **Icon**: 🔓 Unlocked
- **Text**: "Guest Mode"

### Guest User Card (Admin Dashboard)
- **Border**: 3px solid purple (#667eea)
- **Background**: Purple gradient (#f5f7ff → #faf5ff)
- **Badge**: "GUEST MODE" in purple
- **Icon**: 🔓 instead of 👤
- **ID**: Shows "GUEST"

---

## 🔐 Security

- **Password**: Changes daily at midnight
- **Validation**: Server-side only
- **Tracking**: All guest sessions logged
- **Cleanup**: Old passwords auto-deleted (30 days)

---

## 🔧 API Endpoints

```
GET  /api/guest-password        → Returns today's password
POST /api/guest-authenticate    → Validates password
```

---

## 📂 Key Files

```
Backend:
  central-admin/server/app.js

Kiosk:
  student_deployment_package/student-kiosk/student-interface.html
  student_deployment_package/student-kiosk/main-simple.js

Admin:
  central-admin/dashboard/admin-dashboard.html
```

---

## 🧪 Quick Test

```bash
# 1. Start server
cd central-admin\server
node app.js

# 2. Open admin dashboard
http://localhost:7401/admin-dashboard.html

# 3. Note guest password from purple panel

# 4. Test guest login on kiosk
```

---

## ✅ Checklist

- [ ] Purple "Guest Mode" button visible in kiosk
- [ ] Password displayed in admin dashboard
- [ ] Guest login works with correct password
- [ ] Wrong password rejected
- [ ] Guest card has purple border in dashboard
- [ ] "GUEST MODE" badge visible
- [ ] Screen mirroring works for guests

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Password shows "Error" | Check MongoDB connection |
| Guest button missing | Clear browser cache, refresh |
| Login fails | Verify password is correct |
| No purple border | Hard refresh (Ctrl+Shift+R) |
| Card not appearing | Check WebSocket connection |

---

## 💡 Tips

- **Copy button**: Quick way to share password
- **Refresh button**: Check for password updates
- **Purple color**: Easy to spot guests in dashboard
- **Multiple logins**: Same password works on all systems
- **Auto-refresh**: Password display updates every 5 minutes

---

## 📊 Database Fields

```javascript
// GuestPassword
{
  date: "2026-02-06",
  password: "5847",
  createdAt: Date
}

// Session (with guest)
{
  studentId: "GUEST",
  studentName: "Guest User",
  isGuest: true,
  // ... other fields
}
```

---

## 🎯 Feature Benefits

✅ **Quick Access**: No account creation needed
✅ **Secure**: Daily password rotation
✅ **Trackable**: All sessions logged
✅ **Visible**: Purple border identification
✅ **Automated**: No manual password management

---

## 📞 Support

- **Documentation**: See `GUEST_MODE_FEATURE.md`
- **Testing**: See `GUEST_MODE_TEST_GUIDE.md`
- **Visual Guide**: Open `GUEST_MODE_VISUAL_GUIDE.html`

---

**Status**: ✅ Ready for Use
**Version**: 1.0
**Date**: February 6, 2026

---

## 🔗 Related Features

- Student Login (standard authentication)
- Screen Mirroring (works for guests too)
- Session Management (tracks guest sessions)
- Admin Dashboard (displays guest users)

---

**Print this card for quick reference! 📄**
