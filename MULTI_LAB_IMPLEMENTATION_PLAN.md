# Multi-Lab Support & Isolation - Implementation Plan

## Overview

Enable multiple labs (CC1, CC2, CC3, etc.) to operate independently and simultaneously without data conflicts or interference.

---

## Requirements Met by Guest Access Foundation

✅ **Completed**: Guest access feature provides foundation for multi-lab by:
- Socket.io infrastructure in place
- Lab identification system ready (LAB_ID variable)
- Targeted messaging to specific systems

✅ **In Progress**: Next phase will add:
- Lab detection from IP addresses
- Lab filtering in all endpoints
- Admin lab association
- Multi-lab database schema updates

---

## Multi-Lab Implementation Phases

### Phase 1: Lab Configuration & Detection (Week 1)

#### 1.1 Lab Mapping Configuration
**File to Create**: `central-admin/server/config/lab-mapping.js`

```javascript
// Lab IP-to-Lab mapping for auto-detection
const LabMapping = {
  'CC1': {
    prefix: '10.10.46.',
    name: 'Computer Lab 1',
    subnet: '10.10.46.0/24',
    maxSystems: 60
  },
  'CC2': {
    prefix: '10.10.47.',
    name: 'Computer Lab 2',
    subnet: '10.10.47.0/24',
    maxSystems: 60
  },
  'CC3': {
    prefix: '10.10.48.',
    name: 'Computer Lab 3',
    subnet: '10.10.48.0/24',
    maxSystems: 60
  }
};

function getLabFromIP(ipAddress) {
  for (const [labId, config] of Object.entries(LabMapping)) {
    if (ipAddress.startsWith(config.prefix)) {
      return labId;
    }
  }
  return 'CC1'; // Default fallback
}

module.exports = { LabMapping, getLabFromIP };
```

#### 1.2 Update Kiosk Lab Detection
**File**: `student-kiosk/desktop-app/main-simple.js` - Lines 32-84

**Current State**: IP range check exists but mostly commented out
**Action**: Uncomment and populate with your college's IP ranges

```javascript
// IP range to Lab ID mapping
const labIPRanges = {
  '10.10.46.': 'CC1',
  '10.10.47.': 'CC2',
  '10.10.48.': 'CC3',
  // Add more as needed
};
```

#### 1.3 Admin Lab Detection/Selection
**Updates Needed**:
1. Modify login page to show lab selector dropdown
2. Auto-detect lab from IP (if available)
3. Allow manual override for flexibility
4. Store selected lab in session

---

### Phase 2: Database Schema Updates (Week 1)

#### 2.1 Add labId to Models
**File**: `central-admin/server/models/` or `app.js` if embedded

```javascript
// Student Schema - Add labId
{
  studentId: String,
  name: String,
  email: String,
  passwordHash: String,
  labId: String,  // NEW: Which lab this student belongs to
  dateOfBirth: Date,
  isPasswordSet: Boolean,
  department: String,
  createdAt: Date
}

// Session Schema - Add labId
{
  sessionId: String,
  labId: String,  // NEW: Which lab this session is in
  students: [{
    studentId: String,
    name: String,
    systemNumber: String,
    loginTime: Date
  }],
  status: String,
  startTime: Date,
  endTime: Date,
  createdAt: Date
}

// Admin Schema - Add labId
{
  adminId: String,
  email: String,
  passwordHash: String,
  labId: String,  // NEW: Which lab(s) this admin manages
  createdAt: Date
}

// System Schema - Add labId
{
  systemId: String,
  systemNumber: String,
  labId: String,  // NEW: Which lab this system is in
  ipAddress: String,
  status: String,
  createdAt: Date
}
```

---

### Phase 3: Backend Endpoint Updates (Week 1-2)

#### 3.1 Student Login Endpoint
**File**: `central-admin/server/app.js` - Line 2170

**Current**: `POST /api/student-login`
**Updates**:
```javascript
// BEFORE: 
POST /api/student-login
body: { studentName, studentId, computerName, labId, systemNumber }

// AFTER:
POST /api/student-login
1. Extract labId from request body
2. Query: Student.findOne({ studentId, labId }) // ← FILTERED
3. Verify student exists in THIS lab only
4. Create session with labId: req.body.labId
5. Update LabSession where labId matches
```

**Code Change**:
```javascript
app.post('/api/student-login', async (req, res) => {
  try {
    const { studentId, labId } = req.body;
    
    // 🔥 MULTI-LAB FIX: Filter by labId
    const student = await Student.findOne({ 
      studentId, 
      labId  // ← Only students in THIS lab
    });
    
    if (!student) {
      return res.status(400).json({ 
        success: false, 
        error: 'Student not found in lab' 
      });
    }
    
    // Create session
    const newSession = new Session({
      labId,  // ← Store lab ID
      // ... rest of session data
    });
    
    await newSession.save();
    // ...
  } catch (error) {
    // error handling
  }
});
```

#### 3.2 Authentication Endpoint
**File**: `central-admin/server/app.js` - (Search for `/api/authenticate`)

**Updates**:
```javascript
app.post('/api/authenticate', async (req, res) => {
  const { studentId, password, labId } = req.body;
  
  // 🔥 Filter by labId
  const student = await Student.findOne({ studentId, labId });
  
  if (!student) {
    return res.json({ success: false, error: 'Invalid credentials' });
  }
  
  // ... rest of auth logic
});
```

#### 3.3 Get Active Students Endpoint
**New/Updated**: `socket.on('get-active-sessions')`

**Updates**:
```javascript
socket.on('get-active-sessions', async (data) => {
  const adminLabId = data.labId || 'CC1';
  
  // 🔥 Filter by lab
  const sessions = await Session.find({ 
    labId: adminLabId,  // ← Only THIS lab
    status: 'active' 
  });
  
  // Emit only to this admin
  socket.emit('active-sessions', sessions);
});
```

#### 3.4 Start/End Lab Session Endpoints
**Updates**:
```javascript
// Start Lab Session
app.post('/api/start-session', async (req, res) => {
  const { subject, labId } = req.body;
  
  // Create session in specific lab
  const session = new LabSession({
    subject,
    labId,  // ← Scoped to lab
    status: 'active',
    startTime: new Date()
  });
  
  await session.save();
  
  // Broadcast ONLY to systems in THIS lab
  io.emit('lab-session-started-' + labId, { session });
});

// End Lab Session
app.post('/api/end-session', async (req, res) => {
  const { sessionId, labId } = req.body;
  
  const session = await LabSession.findOneAndUpdate(
    { _id: sessionId, labId },  // ← Both ID and lab match
    { status: 'ended', endTime: new Date() }
  );
});
```

#### 3.5 Reports Endpoints
**Updates**:
```javascript
app.post('/api/download-session-report', async (req, res) => {
  const { startDate, endDate, labId } = req.body;
  
  // Filter by lab
  const sessions = await Session.find({
    labId,  // ← Only THIS lab
    createdAt: { $gte: startDate, $lte: endDate }
  });
  
  // Generate CSV with lab-specific data
});
```

---

### Phase 4: Admin Dashboard Updates (Week 2)

#### 4.1 Admin Login Changes
**File**: `central-admin/dashboard/admin-login.html` or similar

```html
<!-- ADD: Lab Selector -->
<select id="labSelector" required>
  <option value="">Select Lab...</option>
  <option value="CC1">Computer Lab 1 (CC1)</option>
  <option value="CC2">Computer Lab 2 (CC2)</option>
  <option value="CC3">Computer Lab 3 (CC3)</option>
</select>

<!-- JavaScript -->
document.getElementById('loginForm').addEventListener('submit', async (e) => {
  const labId = document.getElementById('labSelector').value;
  
  if (!labId) {
    alert('Please select a lab');
    return;
  }
  
  // POST /api/admin-login with labId
  const result = await fetch('/api/admin-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      adminId,
      password,
      labId  // ← Send selected lab
    })
  });
});
```

#### 4.2 Dashboard Lab Header
**File**: `central-admin/dashboard/admin-dashboard.html`

```html
<!-- ADD: Lab Display in Header -->
<div class="lab-header">
  <h2>Lab: <span id="currentLabName">CC1</span></h2>
  <button onclick="switchLab()">Change Lab</button>
</div>

<!-- Store in JavaScript -->
<script>
  const currentLabId = localStorage.getItem('adminLabId') || 'CC1';
  const currentLabName = {
    'CC1': 'Computer Lab 1',
    'CC2': 'Computer Lab 2',
    'CC3': 'Computer Lab 3'
  }[currentLabId];
</script>
```

#### 4.3 Dashboard Data Filtering
**File**: `central-admin/dashboard/admin-dashboard.html`

**Updates** (Find all fetch calls):
```javascript
// BEFORE:
async function loadActiveStudents() {
  const res = await fetch('/api/get-students');
  const students = await res.json();
  displayStudents(students);
}

// AFTER:
async function loadActiveStudents() {
  const labId = window.currentLabId || 'CC1';
  
  const res = await fetch(`/api/get-students?labId=${labId}`);
  const students = await res.json();
  displayStudents(students);  // Only shows students in current lab
}
```

---

### Phase 5: Socket.io Multi-Lab Broadcasting (Week 2)

#### 5.1 Lab-Scoped Event Emission
**File**: `central-admin/server/app.js`

**Current Pattern**:
```javascript
// Broadcasts to EVERYONE (not scalable for multi-lab)
io.emit('lab-session-started', { data });

// NEW PATTERN: Broadcast only to lab
io.emit(`lab-session-started-${labId}`, { data });
```

#### 5.2 Client-Side Lab Event Listeners
**Files**: `admin-dashboard.html`, `student-interface.html`

```javascript
// Admin listens only to their lab
const currentLabId = window.currentLabId || 'CC1';
socket.on(`lab-session-started-${currentLabId}`, (data) => {
  console.log('Session started in MY lab:', data);
  refreshUI();
});

// Ignore events from other labs
socket.on(`lab-session-started-CC2`, (data) => {
  console.log('Session started in other lab - ignoring');
  // Do nothing
});
```

---

### Phase 6: Deployment & Testing (Week 2-3)

#### 6.1 Test Matrix

| Test Case | CC1 Admin | CC2 Admin | Expected Result |
|-----------|-----------|-----------|-----------------|
| Login CC1 admin | ✓ | - | See only CC1 systems |
| Login CC2 admin | - | ✓ | See only CC2 systems |
| CC1 admin starts session | ✓ | - | Only CC1 kiosks receive event |
| CC2 admin starts session (simultaneous) | ✓ | ✓ | Both sessions run independently |
| Kiosk in CC1 lab login | ✓ | - | Only CC1 students authenticate |
| Guest access in CC1 | ✓ | - | Only CC1 system unlocked |
| Session reports CC1 | ✓ | - | See only CC1 student records |

#### 6.2 Deployment Steps

1. **Backup Database**: Export existing MongoDB collections
2. **Add labId to Existing Data**:
   ```javascript
   // Migration script
   db.students.updateMany({}, { $set: { labId: 'CC1' } });
   db.sessions.updateMany({}, { $set: { labId: 'CC1' } });
   db.systems.updateMany({}, { $set: { labId: 'CC1' } });
   ```
3. **Deploy Updated Code**: Push all changes to production
4. **Test Each Lab**: Run through complete workflow for each lab
5. **Monitor Logs**: Watch for cross-lab data conflicts

---

## Files to Modify

### Backend
- [ ] `central-admin/server/app.js`
  - [ ] Update `/api/authenticate` with labId filtering
  - [ ] Update `/api/student-login` with labId
  - [ ] Update `/api/admin-login` with labId
  - [ ] Update `/api/start-session` with labId
  - [ ] Update `/api/end-session` with labId
  - [ ] Update all fetch endpoints with labId filter
  - [ ] Update Socket.io events with lab scoping

### Frontend (Kiosk)
- [ ] `student-kiosk/desktop-app/main-simple.js`
  - [ ] Ensure IP-based lab detection enabled
  - [ ] Pass labId in all API calls

### Frontend (Admin)
- [ ] `central-admin/dashboard/admin-login.html`
  - [ ] Add lab selector dropdown
  - [ ] Send labId to login endpoint
- [ ] `central-admin/dashboard/admin-dashboard.html`
  - [ ] Add lab display in header
  - [ ] Add lab change button
  - [ ] Filter all data displays by labId
  - [ ] Update Socket.io event listeners

### Configuration
- [ ] Create `central-admin/server/config/lab-mapping.js`
- [ ] Populate with college's actual IP ranges and lab IDs

---

## Architecture: Single vs Multi-Lab

### Before (Single Lab)
```
┌─────────────────┐
│   CC1 Admin     │
│  (Only one)     │
└────────┬────────┘
         │
    Connected to: All students, All systems, All sessions
         │
    ┌────┴────────────────┐
    │  All Data Mixed      │
    │  (No Isolation)      │
    └─────────────────────┘
```

### After (Multi-Lab)
```
┌─────────────────┐         ┌─────────────────┐
│   CC1 Admin     │         │   CC2 Admin     │
│  (Lab CC1)      │         │  (Lab CC2)      │
└────────┬────────┘         └────────┬────────┘
         │                           │
    Connected to:          Connected to:
    - CC1 Students    ×    - CC2 Students
    - CC1 Systems     ×    - CC2 Systems
    - CC1 Sessions    ×    - CC2 Sessions
         │                           │
    ┌────┴────┐              ┌──────┴─────┐
    │ CC1 Lab │              │ CC2 Lab    │
    │ Data    │              │ Data       │
    └─────────┘              └────────────┘
    
    ✅ Complete Isolation
    ✅ Simultaneous Sessions
    ✅ No Cross-Lab Conflicts
    ✅ Independent Reporting
```

---

## Rollout Strategy

### Stage 1: Development & Testing (1 week)
- Implement all Phase 1-5 changes locally
- Test with 2-3 mock labs
- Verify no data mixing

### Stage 2: Pilot Deployment (1 week)
- Deploy to test lab environment
- Run full workflow in CC1 and CC2
- Monitor for issues

### Stage 3: Production Rollout (1 day)
- Backup database
- Run migration script
- Deploy updated code
- Monitor logs

### Stage 4: Training & Documentation
- Train admins on lab selection
- Document IP ranges for their network
- Create troubleshooting guide

---

## Post-Implementation

### Configuration for New Labs
To add CC4 lab:

1. **IP Mapping**: `lab-mapping.js`
   ```javascript
   'CC4': { prefix: '10.10.49.', name: 'Computer Lab 4', ... }
   ```

2. **Kiosk IP Ranges**: `main-simple.js`
   ```javascript
   '10.10.49.': 'CC4'
   ```

3. **Admin Dashboard**: `admin-dashboard.html`
   ```javascript
   <option value="CC4">Computer Lab 4</option>
   ```

4. **Database Seed**: Add test students/systems for CC4
   ```javascript
   db.students.insert({ studentId: 'STU001', labId: 'CC4', ... })
   ```

---

## Expected Benefits

✅ **Scalability**: Support 10+ labs simultaneously
✅ **Isolation**: No data mixing between labs
✅ **Flexibility**: Different sessions at different times per lab
✅ **Reporting**: Per-lab analytics and records
✅ **Administration**: Independent admin control per lab
✅ **Future-Proof**: Easy to add new labs without conflicts

---

## Troubleshooting Guide

### Issue: Admin sees all labs' data
**Cause**: `labId` filter not applied to query
**Fix**: Add `.find({ labId: adminLabId })` to all database queries

### Issue: Kiosk can't authenticate
**Cause**: Student imported without `labId` or wrong labId
**Fix**: Re-import students with correct labId or update existing records

### Issue: Multiple admins interfere
**Cause**: Socket.io events not lab-scoped
**Fix**: Change `io.emit()` to `io.emit('event-' + labId)`

### Issue: Session data in wrong lab
**Cause**: labId not passed from kiosk
**Fix**: Verify kiosk sends `labId` in all POST requests

---

## Success Metrics

- [x] Guest access works across labs
- [ ] Admin only sees their lab's data (70% accuracy)
- [ ] Multiple labs run simultaneous sessions
- [ ] No cross-lab student authentication
- [ ] Reports filtered by lab
- [ ] Admin can easily switch labs

---

## Next Phase: Advanced Features

1. **Lab Capacity Monitoring**: Warn when lab reaches max systems
2. **Lab Scheduling**: Reserve labs for specific times
3. **Cross-Lab Reports**: Admin can view multiple labs if authorized
4. **Lab-Specific Timetables**: Different timetables per lab
5. **Lab Performance Metrics**: Per-lab analytics

