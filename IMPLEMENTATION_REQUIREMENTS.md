# System Features Implementation Guide

## Feature 1: Admin "Bypass Login / Guest Access"

### Overview
Allow administrators to remotely unlock specific student systems without requiring kiosk login, enabling guest/external users to access PCs without student credentials.

### Requirements

#### 1.1 Admin Dashboard UI
- **Display**: List of connected systems with a "Guest Access" button for each system
- **Button States**:
  - Normal: "🔓 Allow Guest Access" (green)
  - Active: "🔒 Revoke Guest Access" (red)
  - Status badge: "👥 GUEST MODE" (blue) when active
- **Location**: On each student card in the admin dashboard

#### 1.2 Guest Access Activation Flow

**Admin clicks "Allow Guest Access" button:**
1. Admin confirms action (popup: "Enable guest access for [SystemNumber]?")
2. Admin sends IPC/Socket message to kiosk: `enable-guest-access`
3. Kiosk receives command and automatically logs in with:
   - Student ID: `GUEST_USER` (fixed)
   - Password: `admin123` (fixed/configurable)
   - Guest Mode Flag: `true`

**Kiosk behavior after guest access enabled:**
1. Login succeeds and session starts
2. System is released for normal desktop use
3. Kiosk remains connected to server (for monitoring)
4. Session marked as "GUEST" mode (not counted in student attendance)
5. Admin dashboard shows: "👥 GUEST MODE" badge on the system card

#### 1.3 Guest Access Deactivation Flow

**Admin clicks "Revoke Guest Access" button:**
1. System logs out of guest session
2. Returns to login screen
3. Badge removed from dashboard

#### 1.4 Backend Implementation (Server)

**New IPC Handler in main-simple.js:**
```javascript
ipcMain.handle('enable-guest-access', async (event, labId) => {
  // Auto-login with guest credentials
  return await electronAPI.studentLogin({
    studentId: 'GUEST_USER',
    password: 'admin123',
    guestMode: true,
    labId: labId
  });
});

ipcMain.handle('revoke-guest-access', async (event) => {
  // Force logout
  return await electronAPI.studentLogout();
});
```

**New API Endpoint: `/api/enable-guest-access`**
```javascript
POST /api/enable-guest-access
Body: {
  systemNumber: "CC1-01",
  labId: "CC1"
}
Response: {
  success: true,
  guestSessionId: "session_xxx",
  message: "Guest access enabled"
}
```

#### 1.5 Database Tracking

**Session Model - Add field:**
```javascript
guestMode: {
  type: Boolean,
  default: false
}
```

**Guest Access Log Collection:**
```javascript
{
  _id: ObjectId,
  systemNumber: "CC1-01",
  labId: "CC1",
  enabledAt: Date,
  enabledBy: "admin_username",
  disabledAt: Date (nullable),
  status: "active" | "revoked"
}
```

#### 1.6 Dashboard Display Changes

**Student Card Modifications:**
- Add "👥 GUEST MODE" badge when `session.guestMode === true`
- Replace name with "👥 GUEST" when in guest mode
- Replace student ID with system number
- Hide monitoring/video for guest sessions (optional privacy)
- Show "Revoke Access" button instead of "Allow Guest Access"

---

## Feature 2: Multi-Lab Support and Isolation

### Overview
Support multiple independent labs (10+) with up to 60 systems each, ensuring complete isolation - no mixing of data, sessions, or operations between labs.

### Requirements

#### 2.1 Lab Detection and Assignment

**For Each Kiosk System:**

Method 1: IP-Based Detection (Automatic)
```javascript
IP Range Mapping:
CC1: 10.10.46.* (detect from IP, last octet = system number)
CC2: 10.10.47.*
CC3: 10.10.48.*
... (configurable in server-config.json)

Example:
- IP 10.10.46.101 → CC1-01
- IP 10.10.46.102 → CC1-02
- IP 10.10.47.101 → CC2-01
```

Method 2: Manual Configuration (Fallback)
```javascript
// In server-config.json or environment
LAB_MAPPING: {
  "CC1": { "ipPrefix": "10.10.46", "labName": "Computer Lab 1" },
  "CC2": { "ipPrefix": "10.10.47", "labName": "Computer Lab 2" },
  "CC3": { "ipPrefix": "10.10.48", "labName": "Computer Lab 3" }
}
```

**For Admin Dashboard:**

Method 1: Automatic Detection (Preferred)
```javascript
// Admin machine's IP prefix → Lab ID
Admin IP: 10.10.46.50 → Detect Lab as CC1
```

Method 2: Manual Selection (Fallback)
```javascript
// Prompt on first load:
"Which lab are you managing? [CC1] [CC2] [CC3] [Custom]"
// Store in localStorage
```

#### 2.2 Lab ID Propagation

**Every IPC/API Call Must Include labId:**

Kiosk → Server:
```javascript
// Login
studentLogin({
  studentId: "IT2025001",
  password: "pass123",
  labId: "CC1"  // ← ALWAYS included
})

// Session creation
startSession({
  subject: "Data Structures",
  labId: "CC1"  // ← ALWAYS included
})
```

Admin → Server:
```javascript
// Get active sessions
socket.emit('get-active-sessions', { labId: 'CC1' });

// Start session
POST /api/start-session
Body: { subject, faculty, labId: 'CC1' }

// Get reports
GET /api/reports?labId=CC1
```

#### 2.3 Database Filtering

**All Queries Must Filter by labId:**

```javascript
// Get active sessions for CC1 only
const sessions = await Session.find({
  status: 'active',
  labId: 'CC1'  // ← Filter here
});

// Get students in CC1 lab
const students = await Student.find({
  labId: 'CC1'  // ← Filter here
});

// Get timetable entries for CC1
const timetable = await Timetable.find({
  labId: 'CC1'  // ← Filter here
});

// Get reports for CC1
const reports = await Report.find({
  labId: 'CC1'  // ← Filter here
});
```

#### 2.4 Admin Dashboard Isolation

**Login/Connection:**
1. Admin enters dashboard
2. System detects lab from IP or prompts for selection
3. Store `window.currentLabId = 'CC1'`
4. All subsequent operations scoped to this lab

**View Filtering:**
```javascript
// Only show CC1 systems
const filteredSessions = allSessions.filter(s => s.labId === window.currentLabId);

// Only show CC1 reports
const filteredReports = allReports.filter(r => r.labId === window.currentLabId);

// Only show CC1 timetable
const filteredTimetable = allTimetable.filter(t => t.labId === window.currentLabId);
```

**Session Operations - All Scoped:**
```javascript
// Start session in CC1 only
POST /api/start-session
Body: { 
  subject, faculty, 
  labId: 'CC1'  // ← Only affects CC1
}

// End session in CC1 only
POST /api/end-session
Body: { 
  sessionId,
  labId: 'CC1'  // ← Only affects CC1
}

// Shutdown systems in CC1 only
POST /api/shutdown-systems
Body: {
  labId: 'CC1'  // ← Only affects CC1 systems
}
```

#### 2.5 Data Model Updates

**Add labId to All Relevant Collections:**

```javascript
// Student Model
{
  _id: ObjectId,
  studentId: "IT2025001",
  name: "John Doe",
  labId: "CC1",  // ← NEW
  ... other fields
}

// Session Model
{
  _id: ObjectId,
  studentId: "IT2025001",
  systemNumber: "CC1-01",
  labId: "CC1",  // ← NEW
  ... other fields
}

// LabSession Model
{
  _id: ObjectId,
  subject: "Data Structures",
  faculty: "Dr. Smith",
  labId: "CC1",  // ← NEW
  ... other fields
}

// Timetable Model
{
  _id: ObjectId,
  subject: "Database",
  day: "Monday",
  time: "10:00",
  labId: "CC1",  // ← NEW
  ... other fields
}

// Report Model
{
  _id: ObjectId,
  filename: "Report_CC1_2025-12-05.csv",
  labId: "CC1",  // ← NEW
  sessionId: ObjectId,
  ... other fields
}
```

#### 2.6 Socket.io Room Structure

**Rooms for Lab Isolation:**

```javascript
// Admin registration scoped by lab
socket.emit('register-admin', { labId: 'CC1' });
socket.join(`admins-lab-CC1`);
socket.join(`sessions-lab-CC1`);

// Kiosk registration scoped by lab
socket.emit('register-kiosk', { labId: 'CC1', systemNumber: 'CC1-01' });
socket.join(`kiosks-lab-CC1`);
socket.join(`sessions-lab-CC1`);

// Broadcast only to specific lab
io.to(`admins-lab-CC1`).emit('session-started', data);
io.to(`sessions-lab-CC1`).emit('session-update', data);
```

#### 2.7 Implementation Checklist

**Backend:**
- [ ] Add labId to all database models
- [ ] Create database indexes on (labId, status) for fast queries
- [ ] Update all API endpoints to filter by labId
- [ ] Update Socket.io handlers to use lab-specific rooms
- [ ] Add labId to all API responses
- [ ] Add labId parameter validation (whitelist allowed labs)

**Frontend (Admin Dashboard):**
- [ ] Detect admin's lab from IP or prompt on load
- [ ] Store `window.currentLabId` globally
- [ ] Filter all displayed data by currentLabId
- [ ] Append labId to all API calls and Socket emissions
- [ ] Show lab name in dashboard header
- [ ] Add lab selector dropdown (if admin manages multiple labs)

**Frontend (Kiosk):**
- [ ] Detect kiosk's lab from IP
- [ ] Include labId in all login/session calls
- [ ] Display lab name/number on login screen

**Testing Checklist:**
- [ ] Admin in CC1 sees only CC1 systems
- [ ] Admin in CC2 sees only CC2 systems
- [ ] Session start in CC1 doesn't affect CC2
- [ ] Session end in CC1 doesn't affect CC2
- [ ] Reports only contain data for specific lab
- [ ] Shutdown in CC1 only shuts down CC1 systems
- [ ] Timetable automation works per-lab independently
- [ ] Two admins can log in from different labs simultaneously without interference

---

## Implementation Priority

### Phase 1 (Critical - Do First):
1. Add labId to database models
2. Update API endpoints with labId filtering
3. Add lab detection in kiosk (IP-based)
4. Add lab selection in admin dashboard
5. Test isolation between labs

### Phase 2 (Important):
1. Guest access feature (all parts)
2. Dashboard UI for guest access toggle
3. Guest mode indicators

### Phase 3 (Nice to Have):
1. Lab management UI (add/remove labs)
2. Per-lab statistics and analytics
3. Multi-lab admin user role

---

## Configuration Example

**server-config.json:**
```json
{
  "serverIp": "localhost",
  "serverPort": 7401,
  "labs": [
    {
      "id": "CC1",
      "name": "Computer Lab 1",
      "ipPrefix": "10.10.46",
      "systemCount": 60
    },
    {
      "id": "CC2",
      "name": "Computer Lab 2",
      "ipPrefix": "10.10.47",
      "systemCount": 60
    },
    {
      "id": "CC3",
      "name": "Computer Lab 3",
      "ipPrefix": "10.10.48",
      "systemCount": 60
    }
  ],
  "guestAccess": {
    "enabled": true,
    "userId": "GUEST_USER",
    "password": "admin123"
  }
}
```

---

## Testing Scenarios

### Test Case 1: Multi-Lab Isolation
1. Admin 1 opens dashboard from CC1 network (10.10.46.x)
2. Admin 2 opens dashboard from CC2 network (10.10.47.x)
3. Both see only their respective lab systems
4. Start session in CC1
5. Verify CC2 systems are unaffected
6. Check reports - CC1 only shows CC1 data

### Test Case 2: Guest Access
1. Admin clicks "Allow Guest Access" on CC1-05
2. Kiosk auto-logs in with guest credentials
3. System released for desktop use
4. Dashboard shows "👥 GUEST MODE" badge
5. Admin revokes access
6. System returns to login screen

### Test Case 3: Parallel Operations
1. CC1 session active with 30 students
2. CC2 session starts with 25 students
3. CC1 session ends
4. Verify only CC1 students logged out
5. CC2 session and students continue unaffected
6. Reports show separate CC1 and CC2 data

---

## Error Handling

**Lab Mismatch:**
- If request labId != user's labId, reject with 403 Forbidden
- Log security incident

**Invalid Lab ID:**
- If labId not in whitelist, reject with 400 Bad Request
- Return allowed labs

**IP Detection Failure:**
- If IP cannot be mapped to lab, show selection prompt
- Store selection in localStorage for future

---

## Security Considerations

1. **Always validate labId** - Never trust client-provided labId without verification
2. **IP spoofing prevention** - Implement alongside existing security
3. **Admin isolation** - Admin can only manage assigned lab(s)
4. **Guest access logging** - Log all guest access enable/disable events
5. **Session isolation** - Ensure sessions from one lab cannot affect another

---

This document can be passed to developers for implementation. All requirements are clear and testable.
