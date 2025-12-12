# Guest Access Feature - Quick Test Guide

## Prerequisites

✅ You need:
- Server running: `d:\screen_mirror_deployment_my_laptop\central-admin\server`
- Kiosk running: `d:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app`
- Admin dashboard accessible at: `http://localhost:7401` or `http://192.168.0.102:7401`
- Two terminal windows (one for server, one for kiosk)

---

## Step 1: Start the Server

```powershell
cd 'd:\screen_mirror_deployment_my_laptop\central-admin\server'
npm start
```

**Expected Output**:
```
✅ Server running on port 7401
📡 Local Access: http://localhost:7401
✅ MongoDB connected successfully
✅ Email server is ready to send emails
```

**Note**: Keep this terminal running.

---

## Step 2: Start the Kiosk Application

```powershell
cd 'd:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app'
npm start
```

**Expected Output**:
```
🎬 Kiosk application starting...
✅ Lab detected from IP: CC1
✅ System number: CC1-03
✅ Server: http://localhost:7401
≡ƒöÆ FULL KIOSK MODE - All keyboard shortcuts blocked!
Γ£à Application Ready
```