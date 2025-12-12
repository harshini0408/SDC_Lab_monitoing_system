# 🔧 Hardware Monitoring System Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        STUDENT KIOSK (Electron App)                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │             HardwareMonitor Class                            │   │
│  │             (hardware-monitor.js)                            │   │
│  ├─────────────────────────────────────────────────────────────┤   │
│  │                                                               │   │
│  │  📡 Network Monitor                                          │   │
│  │     ├─ navigator.onLine events                              │   │
│  │     ├─ Socket disconnection detection                       │   │
│  │     └─ Periodic server ping (5 seconds)                     │   │
│  │                                                               │   │
│  │  🖱️ Mouse Monitor                                            │   │
│  │     ├─ Track mousemove events                               │   │
│  │     ├─ Detect 30s inactivity = disconnected                 │   │
│  │     └─ Alert on reconnection (movement detected)            │   │
│  │                                                               │   │
│  │  ⌨️ Keyboard Monitor                                         │   │
│  │     ├─ Track keydown events                                 │   │
│  │     └─ Detect 5-minute inactivity                           │   │
│  │                                                               │   │
│  │  💾 Alert Queue (localStorage)                              │   │
│  │     ├─ Store alerts when offline                            │   │
│  │     └─ Retry when connection restored                       │   │
│  │                                                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                             │                                        │
│                             │ socket.emit('hardware-alert')         │
│                             ▼                                        │
└─────────────────────────────────────────────────────────────────────┘

                              │
                              │ Socket.IO Connection
                              │ (ws://SERVER_IP:7401)
                              ▼

┌─────────────────────────────────────────────────────────────────────┐
│                    EXPRESS SERVER (Node.js)                         │
│                    (app.js - Port 7401)                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  socket.on('hardware-alert', async (alertData) => {                │
│                                                                       │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 1. RECEIVE ALERT                                        │      │
│    │    - Student ID                                         │      │
│    │    - Student Name                                       │      │
│    │    - System Number (e.g., CC1-05)                      │      │
│    │    - Device Type (Network/Mouse/Keyboard)              │      │
│    │    - Alert Type (disconnect/reconnect)                 │      │
│    │    - Timestamp                                          │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 2. SAVE TO DATABASE (MongoDB)                          │      │
│    │    Collection: HardwareAlerts                          │      │
│    │    Fields: studentId, systemNumber, deviceType,        │      │
│    │            type, severity, message, timestamp,         │      │
│    │            acknowledged, acknowledgedBy                │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 3. BROADCAST TO ADMIN DASHBOARDS                       │      │
│    │    io.to('admins').emit('admin-hardware-alert', {     │      │
│    │      ...alertData,                                      │      │
│    │      alertId: alert._id,                               │      │
│    │      savedAt: new Date()                               │      │
│    │    });                                                  │      │
│    └────────────────────────────────────────────────────────┘      │
│  });                                                                 │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

                              │
                              │ Socket.IO Broadcast
                              │ (to 'admins' room)
                              ▼

┌─────────────────────────────────────────────────────────────────────┐
│                   ADMIN DASHBOARD (Browser)                         │
│               (admin-dashboard.html)                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  socket.on('admin-hardware-alert', (alertData) => {                │
│                                                                       │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 1. PLAY ALERT SOUND                                     │      │
│    │    playAlertSound();                                    │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 2. SHOW DESKTOP NOTIFICATION                           │      │
│    │    "⚠️ Network disconnected on CC1-05"                │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 3. SHOW TOAST BANNER                                   │      │
│    │    Top-center banner with alert message                │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 4. UPDATE HARDWARE ALERTS PANEL                        │      │
│    │    - Add alert to list                                 │      │
│    │    - Update badge count                                │      │
│    │    - Show alert details (time, student, system)        │      │
│    └────────────────────────────────────────────────────────┘      │
│                         │                                            │
│                         ▼                                            │
│    ┌────────────────────────────────────────────────────────┐      │
│    │ 5. UPDATE STUDENT CARD VISUAL INDICATORS               │      │
│    │    - Network: 🔴 Red icon for disconnect              │      │
│    │    - Mouse: 🖱️❌ for disconnect                        │      │
│    │    - Reconnect: 🟢 Green icon                          │      │
│    └────────────────────────────────────────────────────────┘      │
│  });                                                                 │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Alert Types & Severity

```
┌──────────────────────┬─────────────┬──────────────────────────────┐
│ Device Type          │ Alert Type  │ Severity                     │
├──────────────────────┼─────────────┼──────────────────────────────┤
│ Network              │ Disconnect  │ 🔴 CRITICAL                  │
│ Network              │ Reconnect   │ 🟢 INFO                      │
│ Mouse                │ Disconnect  │ ⚠️ WARNING                   │
│ Mouse                │ Reconnect   │ 🟢 INFO                      │
│ Keyboard             │ Inactive    │ ⚠️ WARNING                   │
│ Keyboard             │ Active      │ 🟢 INFO                      │
│ User                 │ Inactivity  │ ⚠️ WARNING                   │
│ User                 │ Activity    │ 🟢 INFO                      │
└──────────────────────┴─────────────┴──────────────────────────────┘
```

---

## Monitoring Thresholds

```
┌────────────────────────────┬─────────────────┬──────────────────┐
│ Metric                     │ Threshold       │ Check Interval   │
├────────────────────────────┼─────────────────┼──────────────────┤
│ Network Status             │ Instant         │ 2 seconds        │
│ Server Ping                │ 3 failures      │ 5 seconds        │
│ Mouse Inactivity           │ 30 seconds      │ 10 seconds       │
│ Keyboard Inactivity        │ 5 minutes       │ 30 seconds       │
│ User Inactivity (Both)     │ 5 minutes       │ 30 seconds       │
└────────────────────────────┴─────────────────┴──────────────────┘
```

---

## Offline Alert Queueing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     OFFLINE SCENARIO                            │
└─────────────────────────────────────────────────────────────────┘

1. Network Disconnects
   │
   ├─ Socket connection lost
   │
   ├─ HardwareMonitor detects disconnection
   │
   └─ Generates "Network Disconnect" alert

2. Alert Queueing
   │
   ├─ Socket.emit() fails (not connected)
   │
   ├─ storeAlertInLocalStorage() called
   │     │
   │     └─ localStorage.setItem('pendingHardwareAlerts', [...])
   │
   └─ Console: "💾 Alert stored in localStorage. Total pending: 1"

3. Mouse Removed (While Still Offline)
   │
   ├─ 30 seconds of inactivity detected
   │
   ├─ Generates "Mouse Disconnect" alert
   │
   ├─ Stored in localStorage
   │
   └─ Console: "💾 Alert stored in localStorage. Total pending: 2"

4. Network Reconnects
   │
   ├─ Socket reconnects to server
   │
   ├─ loadPendingAlertsFromStorage() called
   │     │
   │     └─ Retrieves 2 pending alerts from localStorage
   │
   ├─ sendPendingAlertsFromStorage() called
   │     │
   │     ├─ Sends Alert 1: Network Disconnect
   │     │   (500ms delay)
   │     ├─ Sends Alert 2: Mouse Disconnect
   │     │
   │     └─ Console: "📤 Sending stored alert 1/2: Network"
   │               "📤 Sending stored alert 2/2: Mouse"
   │
   ├─ localStorage.removeItem('pendingHardwareAlerts')
   │
   └─ Console: "✅ Pending alerts sent and storage cleared"

5. Admin Dashboard Receives All Alerts
   │
   ├─ Shows both Network and Mouse disconnect alerts
   │
   ├─ Updates badge count: 2
   │
   └─ Shows visual indicators on student card
```

---

## Testing Scenarios

### Scenario 1: Network Disconnect on Laptop (Wi-Fi)
```
User Action:           Turn off Wi-Fi
Detection Time:        Instant (socket disconnect)
Kiosk Console:         "🔴 SOCKET DISCONNECTED - NETWORK ISSUE!"
Alert Stored:          Yes (localStorage)
Admin Notification:    After Wi-Fi restored
Visual Indicator:      🔴 Red network icon
```

### Scenario 2: Mouse Disconnect (Wireless Receiver)
```
User Action:           Unplug nano USB receiver
Detection Time:        30 seconds (inactivity threshold)
Kiosk Console:         "⚠️ Mouse inactivity detected"
Alert Stored:          Yes (if offline) or Sent immediately
Admin Notification:    "Mouse inactive for 0 minutes on CC1-05"
Visual Indicator:      🖱️❌ Mouse disconnect icon
```

### Scenario 3: College Lab Ethernet Unplug
```
User Action:           Physically unplug Ethernet cable
Detection Time:        Instant (socket disconnect)
Kiosk Console:         "🔴 SOCKET DISCONNECTED - NETWORK ISSUE!"
Alert Stored:          Yes (localStorage)
Admin Notification:    After Ethernet reconnected
Visual Indicator:      🔴 Red network icon
Note:                  Same code as Wi-Fi, no changes needed!
```

### Scenario 4: College Lab Wired Mouse Unplug
```
User Action:           Unplug USB cable of wired mouse
Detection Time:        30 seconds (inactivity threshold)
Kiosk Console:         "⚠️ Mouse inactivity detected"
Alert Stored:          Yes (if offline) or Sent immediately
Admin Notification:    "Mouse inactive for 0 minutes on CC1-23"
Visual Indicator:      🖱️❌ Mouse disconnect icon
Note:                  Same code as wireless, no changes needed!
```

---

## Database Schema

### HardwareAlerts Collection
```javascript
{
  _id: ObjectId,
  studentId: String,           // "22MCA001"
  studentName: String,         // "John Doe"
  systemNumber: String,        // "CC1-05"
  labId: String,              // "CC1" (optional)
  sessionId: ObjectId,        // Reference to LabSession
  deviceType: String,         // "Network", "Mouse", "Keyboard"
  type: String,               // "hardware_disconnect", "hardware_reconnect"
  severity: String,           // "critical", "warning", "info"
  message: String,            // "Network disconnected on CC1-05"
  timestamp: Date,            // 2025-12-12T10:30:00Z
  acknowledged: Boolean,      // false
  acknowledgedBy: String,     // "admin" (when acknowledged)
  acknowledgedAt: Date        // null (until acknowledged)
}
```

---

## Console Output Examples

### Kiosk Console (Successful Monitoring)
```
🔍 Hardware Monitor initialized for: John Doe
▶️ Starting hardware monitoring...
🌐 Network monitoring started. Current status: Online
🔌 Socket connection monitoring started
⌨️🖱️ Input device monitoring started
⏱️ Starting inactivity monitoring...
✅ Hardware monitoring started successfully
```

### Kiosk Console (Network Disconnect)
```
🔴 ========================================
🔴 SOCKET DISCONNECTED - NETWORK ISSUE!
🔴 ========================================
🚨 Network disconnect detected via socket: {
  type: "hardware_disconnect",
  deviceType: "Network",
  studentId: "22MCA001",
  systemNumber: "CC1-05",
  severity: "critical"
}
💾 Alert stored in localStorage. Total pending: 1
```

### Admin Console (Receiving Alert)
```
🚨 Hardware alert received: {
  type: "hardware_disconnect",
  deviceType: "Network",
  studentId: "22MCA001",
  studentName: "John Doe",
  systemNumber: "CC1-05",
  message: "Network disconnected on CC1-05",
  severity: "critical",
  timestamp: "2025-12-12T10:30:00.000Z"
}
✅ Hardware alert saved to database: 675a8e3d12f4ab1234567890
📡 Alert broadcast to admins: Network hardware_disconnect
```

---

## Quick Reference Commands

### Test Network Monitoring
```powershell
# Laptop: Turn off Wi-Fi
# Expected: Instant disconnect alert

# College Lab: Unplug Ethernet cable
# Expected: Instant disconnect alert
```

### Test Mouse Monitoring
```powershell
# Laptop: Unplug nano USB receiver
# Wait 30 seconds
# Expected: Mouse disconnect alert

# College Lab: Unplug USB mouse cable
# Wait 30 seconds
# Expected: Mouse disconnect alert
```

### Check Pending Alerts (Browser DevTools)
```javascript
// Open kiosk DevTools → Console
localStorage.getItem('pendingHardwareAlerts')
// Should return: null (if empty) or JSON array of alerts
```

### Manually Trigger Alert Retry (Emergency)
```javascript
// In kiosk console:
if (hardwareMonitor) {
  hardwareMonitor.retryPendingAlerts();
}
```

---

**✅ SYSTEM FULLY OPERATIONAL - Ready for Testing**
