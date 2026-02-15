# ✅ 69-System Selective Shutdown Endpoints - ADDED

## 📅 Date: February 11, 2026

## 🎯 Status: **COMPLETE**

All three critical API endpoints for the 69-system lab management with selective shutdown have been successfully added to `central-admin/server/app.js`.

---

## ✅ ADDED ENDPOINTS

### 1. **System Heartbeat Registration** 
```http
POST /api/system-heartbeat
```

**Purpose**: Student kiosks send heartbeat every 30 seconds to register/update their status

**Request Body**:
```json
{
  "systemNumber": 1,
  "labId": "CC1",
  "ipAddress": "192.168.1.101",
  "socketId": "abc123xyz"
}
```

**Response**:
```json
{
  "success": true
}
```

**Database Action**:
- Upserts (create/update) entry in `SystemRegistry` collection
- Updates `lastSeen` timestamp
- Marks status as `online`

---

### 2. **Get All Lab Systems**
```http
GET /api/lab-systems/:labId
```

**Purpose**: Admin dashboard fetches all systems (including offline) for a specific lab

**Example**: `GET /api/lab-systems/CC1`

**Response**:
```json
{
  "success": true,
  "systems": [
    {
      "systemNumber": 1,
      "labId": "CC1",
      "ipAddress": "192.168.1.101",
      "socketId": "abc123",
      "status": "online",
      "isOnline": true,
      "lastSeenAgo": 15,
      "currentStudentId": "CS2021001",
      "currentStudentName": "John Doe"
    },
    {
      "systemNumber": 2,
      "labId": "CC1",
      "ipAddress": "192.168.1.102",
      "status": "offline",
      "isOnline": false,
      "lastSeenAgo": 120
    }
  ],
  "stats": {
    "total": 69,
    "online": 45,
    "offline": 24,
    "loggedIn": 30,
    "available": 15,
    "guest": 2
  }
}
```

**Logic**:
- Fetches all systems from `SystemRegistry` for the specified lab
- Marks system as **offline** if `lastSeen > 60 seconds ago`
- Calculates statistics (total, online, offline, logged in, available, guest)

---

### 3. **Shutdown Selected Systems**
```http
POST /api/shutdown-systems
```

**Purpose**: Admin sends shutdown command to selected systems via Socket.IO

**Request Body**:
```json
{
  "systemNumbers": [1, 5, 10, 15, 23],
  "labId": "CC1"
}
```

**Response**:
```json
{
  "success": true,
  "shutdownCount": 4,
  "offlineCount": 1,
  "totalRequested": 5,
  "message": "Shutdown command sent to 4 systems (1 offline)"
}
```

**Process**:
1. Validates `systemNumbers` array and `labId`
2. For each system number:
   - Queries `SystemRegistry` for socketId
   - Checks if system is online (lastSeen < 60 seconds)
   - If online: Emits `force-shutdown-system` Socket.IO event to kiosk
   - If offline: Counts as offline
3. Broadcasts `systems-shutdown-initiated` event to all admins
4. Returns summary of shutdown status

**Socket.IO Event Emitted**:
```javascript
io.to(socketId).emit('force-shutdown-system', {
  systemNumber: 5,
  labId: "CC1",
  timestamp: "2026-02-11T18:30:00.000Z"
});
```

---

## 📋 LOCATION IN FILE

**File**: `d:\New_SDC\lab_monitoring_system\central-admin\server\app.js`

**Section**: Lines ~5010-5220 (before the 404 handler)

**Markers**:
```javascript
// ========================================================================
// 69-SYSTEM LAB MANAGEMENT - SELECTIVE SHUTDOWN
// ========================================================================

// API 1: System Heartbeat Registration
// API 2: Get All Lab Systems
// API 3: Shutdown Selected Systems

// ========================================================================
// END 69-SYSTEM LAB MANAGEMENT
// ========================================================================
```

---

## 🔗 INTEGRATION WITH EXISTING CODE

### ✅ **SystemRegistry Schema** (Already Exists)
Located at line ~296 in app.js:
```javascript
const systemRegistrySchema = new mongoose.Schema({
  systemNumber: { type: Number, required: true },
  labId: { type: String, required: true },
  computerName: String,
  ipAddress: String,
  socketId: String,
  status: { type: String, default: 'offline' },
  currentStudentId: String,
  currentStudentName: String,
  isGuest: { type: Boolean, default: false },
  lastSeen: { type: Date, default: Date.now }
});
```

### ✅ **Socket.IO Already Initialized**
Line ~40:
```javascript
const io = socketIo(server, {
  cors: { origin: "*" }
});
```

### ✅ **Kiosk Socket Handlers** (Already Exist)
Lines ~3480-3950:
- `socket.on('register-kiosk', ...)` - Registers kiosk socket
- `socket.on('shutdown-system', ...)` - Handles single shutdown
- `socket.on('shutdown-all-systems', ...)` - Handles bulk shutdown

---

## 🎯 NEXT STEPS FOR FULL FUNCTIONALITY

### 1. **Student Kiosk Must Send Heartbeats**
File: `student_deployment_package/student-kiosk/main-simple.js`

Required code (check if present):
```javascript
// Send heartbeat every 30 seconds
setInterval(() => {
  sendSystemHeartbeat();
}, 30000);

function sendSystemHeartbeat() {
  fetch(`${SERVER_URL}/api/system-heartbeat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemNumber: detectSystemNumber(),
      labId: detectLabFromIP() || 'CC1',
      ipAddress: getLocalIP(),
      socketId: socket ? socket.id : null
    })
  });
}
```

### 2. **Student Kiosk Must Handle Shutdown Command**
Required Socket.IO listener in kiosk:
```javascript
socket.on('force-shutdown-system', async (data) => {
  console.log('🔌 FORCE SHUTDOWN RECEIVED:', data);
  
  // Attempt quick logout (2 second timeout)
  try {
    await ipcRenderer.invoke('force-windows-shutdown');
  } catch (error) {
    console.error('Shutdown error:', error);
  }
});
```

### 3. **Admin Dashboard Must Use These Endpoints**
File: `central-admin/dashboard/admin-dashboard.html`

Required JavaScript functions:
```javascript
// Fetch all systems
async function loadLabSystems() {
  const response = await fetch(`${SERVER_URL}/api/lab-systems/${currentLabId}`);
  const data = await response.json();
  
  // Display systems in UI with checkboxes
  displaySystemsTable(data.systems);
}

// Shutdown selected systems
async function shutdownSelectedSystems() {
  const selectedSystems = getSelectedSystemNumbers(); // from checkboxes
  
  const response = await fetch(`${SERVER_URL}/api/shutdown-systems`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemNumbers: selectedSystems,
      labId: currentLabId
    })
  });
  
  const result = await response.json();
  alert(`Shutdown command sent to ${result.shutdownCount} systems`);
}
```

---

## ✅ VERIFICATION CHECKLIST

- [x] **Endpoint 1**: `/api/system-heartbeat` (POST) - ✅ Added
- [x] **Endpoint 2**: `/api/lab-systems/:labId` (GET) - ✅ Added
- [x] **Endpoint 3**: `/api/shutdown-systems` (POST) - ✅ Added
- [x] **No Syntax Errors**: ✅ Verified with `get_errors` tool
- [x] **SystemRegistry Schema**: ✅ Already exists (line 296)
- [x] **Socket.IO Initialized**: ✅ Already exists (line 40)
- [x] **Proper Location**: ✅ Before 404 handler
- [ ] **Kiosk Heartbeat**: ⚠️ Check `main-simple.js`
- [ ] **Kiosk Shutdown Handler**: ⚠️ Check `main-simple.js`
- [ ] **Admin Dashboard UI**: ⚠️ Check `admin-dashboard.html`

---

## 🚀 TESTING PROCEDURE

### Step 1: Start Server
```bash
cd d:\New_SDC\lab_monitoring_system\central-admin\server
node app.js
```

### Step 2: Test Heartbeat Endpoint
```bash
curl -X POST http://localhost:7401/api/system-heartbeat ^
  -H "Content-Type: application/json" ^
  -d "{\"systemNumber\":1,\"labId\":\"CC1\",\"ipAddress\":\"192.168.1.101\"}"
```

Expected: `{"success":true}`

### Step 3: Test Get Systems Endpoint
```bash
curl http://localhost:7401/api/lab-systems/CC1
```

Expected: JSON with systems array and stats

### Step 4: Test Shutdown Endpoint
```bash
curl -X POST http://localhost:7401/api/shutdown-systems ^
  -H "Content-Type: application/json" ^
  -d "{\"systemNumbers\":[1,2,3],\"labId\":\"CC1\"}"
```

Expected: JSON with shutdownCount and offlineCount

---

## 📊 CONSOLE OUTPUT EXAMPLES

### Heartbeat Registration:
```
(No console output - silent operation for performance)
```

### Get Lab Systems:
```
(No console output - standard GET request)
```

### Shutdown Selected Systems:
```
============================================================
🔌 SELECTIVE SHUTDOWN REQUEST
   Lab ID: CC1
   Systems: 1, 5, 10, 15, 23
   Total: 5 systems
============================================================

✅ Shutdown signal sent to System 1 (Socket: abc123)
✅ Shutdown signal sent to System 5 (Socket: def456)
✅ Shutdown signal sent to System 10 (Socket: ghi789)
✅ Shutdown signal sent to System 15 (Socket: jkl012)
⚠️ System 23 is offline (last seen 120s ago)

============================================================
📊 SHUTDOWN SUMMARY
   Requested: 5 systems
   Sent: 4 shutdown commands
   Offline: 1 systems
============================================================
```

---

## 🎉 CONCLUSION

All three API endpoints for 69-system selective shutdown have been successfully added to the server. The server now supports:

1. ✅ **System registration** via heartbeat (every 30 seconds)
2. ✅ **Real-time status tracking** (online/offline detection)
3. ✅ **Selective shutdown** of multiple systems

**Status**: Server-side implementation is **COMPLETE**

**Next**: Verify kiosk-side heartbeat and shutdown handlers are implemented.
