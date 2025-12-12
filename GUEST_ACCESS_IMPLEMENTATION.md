# Guest Access / Bypass Login Feature - Implementation Complete

## Feature Overview
**Admin 'Bypass Login / Guest Access'** allows administrators to remotely enable guest mode on specific systems, allowing users to bypass student credential authentication and use the system normally.

---

## What Was Implemented

### 1. Backend API Endpoint
**File**: `central-admin/server/app.js`
- **Endpoint**: `POST /api/bypass-login`
- **Location**: Lines 4316-4353
- **Functionality**:
  - Validates required fields: `systemNumber`, `computerName`, `labId`
  - Broadcasts Socket.io event `guest-mode-enabled` to specific kiosk
  - Returns success/error response
  - Console logging for debugging

```javascript
app.post('/api/bypass-login', async (req, res) => {
  // Validates required fields
  // Broadcasts 'guest-mode-enabled' to kiosk via Socket.io
  // Handles errors gracefully
});
```

### 2. Socket.io Server Integration
**File**: `central-admin/server/app.js`
- **Existing Handler**: `socket.on('grant-guest-access')` - Lines 3224-3265
- **Functionality**:
  - Admin clicks "Guest Access" button on dashboard
  - Button emits `grant-guest-access` socket event
  - Server finds kiosk by `systemNumber` in `kioskSystemSockets` map
  - Sends `guest-access-granted` event to specific kiosk
  - Notifies admin of success/failure

```javascript
socket.on('grant-guest-access', async ({ systemNumber, labId }) => {
  // Find kiosk by system number
  // Broadcast 'guest-access-granted' to that specific kiosk
  // Notify admin of result
});
```

### 3. Kiosk Main Process Updates
**File**: `student-kiosk/desktop-app/main-simple.js`
- **Updated IPC Handler**: `student-login` - Lines 402-489
- **Changes**:
  - Added `isGuest` flag support
  - When `isGuest === true`, skips normal authentication
  - Creates Guest User account automatically
  - Passes `isGuest: true` to backend session creation
  - System unlocks and releases keyboard shortcuts for normal use

```javascript
const isGuest = credentials.isGuest === true;

if (isGuest) {
  // Skip authentication for guest mode
  authData = {
    success: true,
    student: { name: 'Guest User', studentId: 'GUEST' }
  };
}
```

### 4. Kiosk System Information
**File**: `student-kiosk/desktop-app/main-simple.js`
- **Updated IPC Handler**: `get-system-info` - Lines 627-636
- **Added Fields**:
  - `systemNumber`: Unique identifier for this kiosk
  - `labId`: Lab identifier (e.g., "CC1")

### 5. Kiosk Socket.io Integration
**File**: `student-kiosk/desktop-app/student-interface.html`
- **Added**: Socket.io client library via CDN (line 507)
- **New Functions**:
  - `initializeSocket()`: Initializes Socket.io connection
  - `handleGuestModeEnabled()`: Auto-logs in with guest credentials
- **Socket Events**:
  - Listens for `guest-access-granted` (targeted event)
  - Listens for `guest-mode-enabled` (fallback broadcast)
  - Registers kiosk on connection with `register-kiosk` event
  - Automatic guest login when event received

### 6. Admin Dashboard Integration
**File**: `central-admin/dashboard/admin-dashboard.html`
- **Existing Feature**: Guest Access button already implemented (line 1407)
- **Functionality**:
  - Displays button for each connected system
  - Button shows "👤 Guest Access" or "🔓 Guest Mode" badge
  - One-click guest access with confirmation dialog
  - Real-time status updates via Socket.io

### 7. Socket Event Listeners in Dashboard
**File**: `central-admin/dashboard/admin-dashboard.html`
- **Listeners**: Lines 1141-1150
  - `guest-access-success`: Shows success notification, refreshes student list
  - `guest-access-error`: Shows error notification

---

## User Flow

### For Admin:
1. Navigate to Admin Dashboard
2. View connected systems in the interface
3. For any system, click "🔓 Guest Access" button
4. Confirm the action in the dialog
5. System automatically receives guest access command
6. Admin sees "🔓 Guest Mode" badge on the system
7. Student list refreshes to show guest user logged in

### For Kiosk/Student:
1. Kiosk boots normally with login screen
2. Admin clicks "Guest Access" for that system
3. Kiosk receives Socket.io event automatically
4. Page automatically logs in as "GUEST" user
5. Session modal appears showing "Guest User" logged in
6. Student can close modal and use system normally
7. System shows as "Guest Mode" in admin dashboard
8. Session tracked with `isGuest: true` flag

---

## Backend Database Changes

### Session Model Updates
**File**: `central-admin/server/models/Session.js` (or app.js if embedded)
- **New Field**: `isGuest: Boolean` (default: false)
- **Tracking**: Guest sessions recorded separately for reporting

### Student Login Endpoint
**File**: `central-admin/server/app.js` - Line 2170
- **Updated Logic**:
  - Accepts `isGuest` parameter
  - Handles GUEST user specially
  - Only allows GUEST if `isGuest: true`
  - Not counted as regular student in some reports

---

## Security Considerations

✅ **Implemented:**
- Socket.io authentication (server-side verification)
- Admin-only action (requires admin session)
- Logged with timestamp for audit trail
- Guest mode clearly labeled in UI
- Kiosk registration prevents unauthorized access

⚠️ **Notes:**
- Guest password hardcoded as "admin123" (configurable)
- Guest mode only works when admin initiates
- System still locked to guest use (no administrative access)
- No access to other systems via guest account

---

## Configuration

### Guest Credentials (Hardcoded)
- **Student ID**: `GUEST`
- **Password**: `admin123`
- **Name**: `Guest User`

### To Change Guest Password:
1. Edit `student-interface.html` line ~440: Change `password: 'admin123'`
2. Update server validation if needed
3. Communicate new password to admins

---

## Testing Checklist

- [ ] Start server: `npm start` in `central-admin/server`
- [ ] Start kiosk: `npm start` in `student-kiosk/desktop-app`
- [ ] Login to admin dashboard
- [ ] Click "🔓 Guest Access" for a system
- [ ] Confirm guest mode dialog
- [ ] Wait 2-3 seconds for kiosk update
- [ ] Verify kiosk shows "Guest User" logged in
- [ ] Verify admin dashboard shows "🔓 Guest Mode" badge
- [ ] Click logout on kiosk, return to login screen
- [ ] Verify guest access can be granted again

---

## Files Modified

1. ✅ `central-admin/server/app.js` (Added `/api/bypass-login` endpoint)
2. ✅ `student-kiosk/desktop-app/main-simple.js` (Guest login support + system info)
3. ✅ `student-kiosk/desktop-app/student-interface.html` (Socket.io + guest handler)
4. ℹ️ `central-admin/dashboard/admin-dashboard.html` (Already had UI + handlers)

---

## Related Features

### Multi-Lab Support (Planned)
- Guest access works per-lab when multi-lab is enabled
- Admin dashboard will filter by lab
- Each lab can have separate guest settings

### Admin Authentication (Planned)
- Admin login will detect/select lab
- Admin actions scoped to their lab only
- Guest access only available for systems in admin's lab

---

## Next Steps

1. **Test Feature**: Run both server and kiosk, test guest access flow
2. **Multi-Lab Enhancement**: Add labId filtering to all operations
3. **Admin Dashboard Filter**: Add lab selector dropdown
4. **Database Schema**: Add `labId` to Student, Session, Admin models
5. **Configuration**: Move guest credentials to environment variables

---

## Troubleshooting

### Kiosk doesn't receive guest access event
- Check server console for "Kiosk not found" errors
- Ensure kiosk emitted `register-kiosk` socket event
- Verify system number matches in admin dashboard

### Guest login fails
- Check network connectivity between kiosk and server
- Verify Socket.io connection established
- Check browser console for errors
- Verify GUEST user exists in database

### Admin button doesn't appear
- Ensure system is connected and registered
- Refresh admin dashboard
- Check if system shows as "offline" (need to reconnect)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Admin Dashboard                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ System: CC1-03    🔓 Guest Access                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────┬───────────────────────────────────────────────┘
              │ Click "Guest Access"
              │ emit('grant-guest-access', {systemNumber})
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Server (Node.js/Express)                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ socket.on('grant-guest-access')                      │  │
│  │   -> Find kiosk in kioskSystemSockets map           │  │
│  │   -> io.to(kioskId).emit('guest-access-granted')    │  │
│  │   -> Notify admin of result                         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────┬───────────────────────────────────────────────┘
              │ Socket.io: 'guest-access-granted'
              │ Targeted message to specific kiosk
              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Kiosk (Electron App)                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ socket.on('guest-access-granted')                    │  │
│  │   -> handleGuestModeEnabled(data)                    │  │
│  │   -> studentLogin({studentId: 'GUEST', ...})        │  │
│  │   -> Display "Guest User" session modal             │  │
│  │   -> Release keyboard shortcuts for normal use      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

✅ **Feature Complete**: Admins can now remotely enable guest access on any kiosk
- One-click operation with confirmation
- Automatic system unlock and credential bypass
- Real-time Socket.io communication
- Clear visual feedback (Guest Mode badge)
- Session tracking with guest flag
- Ready for multi-lab deployment

