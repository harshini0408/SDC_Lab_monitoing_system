# Feature Implementation Summary

## 🔓 Feature 1: Guest Access (Bypass Login)

### What It Does
Allows admin to unlock a system for guest users without student login credentials.

### Flow Diagram
```
Admin Dashboard
    ↓
  [Allow Guest Access Button]
    ↓
Kiosk Receives Command
    ↓
Auto-Login as GUEST_USER / admin123
    ↓
System Released for Desktop Use
    ↓
Dashboard Shows "👥 GUEST MODE"
    ↓
[Revoke Guest Access Button]
    ↓
System Returns to Login Screen
```

### Key Components
| Component | Details |
|-----------|---------|
| **Trigger** | "🔓 Allow Guest Access" button on each system card |
| **Auto-Login** | Student ID: `GUEST_USER`, Password: `admin123` |
| **Status** | Shows "👥 GUEST MODE" badge on dashboard |
| **Revoke** | "🔒 Revoke Guest Access" button to end guest session |
| **Tracking** | Guest access logged in database |
| **Attendance** | Guest sessions NOT counted in student reports |

### Use Case
- Visiting faculty need to use a lab PC
- External trainer/consultant needs computer access
- System needs temporary unlock without student ID

---

## 🏢 Feature 2: Multi-Lab Isolation

### What It Does
Supports 10+ independent labs with complete data isolation - no mixing between labs.

### Lab Structure
```
Department
├── Lab CC1 (10.10.46.*)
│   ├── System CC1-01 (10.10.46.101)
│   ├── System CC1-02 (10.10.46.102)
│   └── ... up to 60 systems
├── Lab CC2 (10.10.47.*)
│   ├── System CC2-01 (10.10.47.101)
│   ├── System CC2-02 (10.10.47.102)
│   └── ... up to 60 systems
└── Lab CC3 (10.10.48.*)
    └── ... more systems
```

### Lab Detection
```
Kiosk Startup
    ↓
Read Local IP (e.g., 10.10.46.101)
    ↓
Match to Lab Prefix (10.10.46.* = CC1)
    ↓
Set Lab ID = "CC1"
    ↓
Include in All Requests
```

### Admin Lab Selection
```
Admin Opens Dashboard
    ↓
Detect Admin's IP → Lab (or Prompt)
    ↓
Store Lab ID: window.currentLabId = "CC1"
    ↓
Filter All Data by Lab
    ↓
Show Only CC1 Systems/Sessions/Reports
```

### Isolation Examples

**Scenario 1: Concurrent Sessions**
```
Time 12:00 PM
├── CC1: Data Structures class (30 students logged in)
├── CC2: Database class (25 students logged in)  ← Completely separate
└── CC3: Web Dev class (20 students logged in)   ← No interference
```

**Scenario 2: Session Management**
```
CC1 Admin: Ends session at 2:30 PM
├── CC1 students logged out
├── CC2 students unaffected ← Still in active session
└── CC3 students unaffected ← Still in active session
```

**Scenario 3: Reports**
```
Generate Report from CC1 Dashboard
├── Contains ONLY CC1 data
├── CC2 data stored separately
└── CC3 data stored separately
```

### Data Flow with Lab Isolation
```
Admin CC1 → Request "Get Sessions"
    ↓
API: SELECT * WHERE labId='CC1'
    ↓
Returns 30 CC1 students

Admin CC2 → Request "Get Sessions" (simultaneously)
    ↓
API: SELECT * WHERE labId='CC2'
    ↓
Returns 25 CC2 students ← Different data set
```

### Key Components
| Component | Details |
|-----------|---------|
| **Detection** | Automatic via IP prefix mapping |
| **Fallback** | Manual lab selection if IP detection fails |
| **Propagation** | Every API call includes `labId` parameter |
| **Filtering** | All database queries filter by `labId` |
| **Rooms** | Socket.io rooms per lab: `admins-lab-CC1`, `sessions-lab-CC1`, etc. |
| **Reports** | Separate reports per lab, no mixing |
| **Timetable** | Timetable automation works per-lab independently |

---

## Implementation Priority

### 🔴 Phase 1: Multi-Lab Support (MUST DO FIRST)
1. Add labId to all database schemas
2. Update API endpoints to filter by labId
3. Implement kiosk lab detection (IP-based)
4. Add admin lab selection UI
5. Test: Two admins see only their lab data

### 🟡 Phase 2: Guest Access Feature
1. Add guest access button to dashboard
2. Implement kiosk auto-login logic
3. Add guest mode indicators
4. Test: Can enable/revoke guest access

### 🟢 Phase 3: Optional Enhancements
1. Lab management UI
2. Multi-lab admin role
3. Lab-specific configurations

---

## Database Changes Summary

**New Fields to Add (across all collections):**
```javascript
// Every collection needs:
labId: "CC1"  // References which lab this belongs to

// Index for performance:
db.sessions.createIndex({ labId: 1, status: 1 })
db.students.createIndex({ labId: 1 })
db.timetables.createIndex({ labId: 1 })
db.reports.createIndex({ labId: 1 })
```

---

## Configuration File

**server-config.json (Add labs array):**
```json
{
  "labs": [
    { "id": "CC1", "name": "Lab 1", "ipPrefix": "10.10.46", "systems": 60 },
    { "id": "CC2", "name": "Lab 2", "ipPrefix": "10.10.47", "systems": 60 },
    { "id": "CC3", "name": "Lab 3", "ipPrefix": "10.10.48", "systems": 60 }
  ],
  "guestAccess": {
    "enabled": true,
    "userId": "GUEST_USER",
    "password": "admin123"
  }
}
```

---

## Testing Checklist

### Multi-Lab Tests
- [ ] Admin in CC1 sees only CC1 systems (not CC2/CC3)
- [ ] Admin in CC2 sees only CC2 systems
- [ ] Two admins logged in simultaneously see correct data
- [ ] Starting session in CC1 doesn't affect CC2 session
- [ ] Ending session in CC1 only logs out CC1 students
- [ ] Shutdown command in CC1 only affects CC1 systems
- [ ] Reports show separate data per lab
- [ ] Timetable automation works independently per lab

### Guest Access Tests
- [ ] Admin can enable guest access on any system
- [ ] System auto-logs in with guest credentials
- [ ] Guest mode badge appears on dashboard
- [ ] System available for desktop use
- [ ] Admin can revoke guest access
- [ ] System returns to login screen after revoke
- [ ] Guest sessions not counted in attendance
- [ ] Guest access logged in database

---

## Security Notes

1. **Always validate labId** - Verify admin belongs to their lab
2. **Guest password** - Consider rotating `admin123` periodically
3. **Access logs** - All guest access events must be logged
4. **IP verification** - Can be spoofed; use alongside other checks
5. **Lab isolation** - Strictly enforce at database query level

---

## Questions to Ask Developer

1. Where should guest access password be stored (config/env/DB)?
2. Should guest sessions appear in reports (optional, hidden)?
3. Can one admin manage multiple labs?
4. Should we log all guest access enable/disable events?
5. What to do if IP detection fails - always prompt or use default?

---

This document provides the complete specification for both features. It's ready to share with your development team.
