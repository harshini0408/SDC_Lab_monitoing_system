# 🏢 Multi-Lab Support & System Registry - Current Status

## ✅ BACKEND COMPLETE | UI UPDATES NEEDED

Last Updated: December 12, 2024

---

## 🎯 What's Working Now

### 1. **System Registry (Pre-Login Tracking)** ✅
- All powered-on kiosks are tracked in database
- Systems visible BEFORE student login
- Real-time status updates via Socket.IO
- Status types: available, logged-in, guest, offline

### 2. **IP-Based Lab Detection** ✅
- Server automatically detects lab from kiosk IP
- Example: `10.10.46.101` → CC2, `192.168.29.50` → CC1
- Configuration in `lab-config.js` (5 labs: CC1-CC5)
- Each lab supports 60 systems

### 3. **Lab Isolation with Socket.IO Rooms** ✅
- Lab-specific rooms: `lab-CC1`, `lab-CC2`, etc.
- Broadcasts scoped to selected lab
- No cross-lab message interference

### 4. **API Endpoints** ✅
- `GET /api/labs` - List all available labs
- `GET /api/systems/:labId` - Get all systems for a specific lab
- Returns system status, counts, current users

### 5. **Guest Access Integration** ✅
- Guest access updates system registry
- Admin can unlock pre-login systems
- Shows as "Guest User" with purple badge

---

## 📊 System Registry Database Schema

**Collection**: `SystemRegistry`

```javascript
{
  systemNumber: 'CC1-05',           // e.g., CC1-05, CC2-15
  labId: 'CC1',                     // Lab identifier
  ipAddress: '192.168.29.105',     // Detected IP
  status: 'available',              // available | logged-in | guest | offline
  lastSeen: ISODate(),              // Last heartbeat timestamp
  currentSessionId: ObjectId,       // Active session (if logged in)
  currentStudentId: 'GUEST',        // Current user ID
  currentStudentName: 'Guest User', // Current user name
  isGuest: false,                   // Guest mode flag
  socketId: 'xyz123'                // Socket.IO connection ID
}
```

---

## 🌐 API Endpoints Reference

### Get All Labs
```http
GET http://localhost:3001/api/labs

Response:
{
  "success": true,
  "labs": {
    "CC1": {
      "labId": "CC1",
      "labName": "Computer Center Lab 1",
      "ipPrefix": "192.168.29",
      "systemCount": 60,
      "systemRange": ["CC1-01", "CC1-02", ..., "CC1-60"]
    },
    "CC2": {
      "labId": "CC2",
      "labName": "Computer Center Lab 2",
      "ipPrefix": "10.10.46",
      "systemCount": 60,
      "systemRange": ["CC2-01", ..., "CC2-60"]
    }
  }
}
```

### Get Systems for a Lab
```http
GET http://localhost:3001/api/systems/CC1

Response:
{
  "success": true,
  "labId": "CC1",
  "labName": "Computer Center Lab 1",
  "systems": [
    {
      "systemNumber": "CC1-01",
      "labId": "CC1",
      "status": "available",      // 🟢 Available
      "ipAddress": "192.168.29.101",
      "lastSeen": "2024-12-12T10:30:00Z",
      "currentStudentId": null,
      "isGuest": false
    },
    {
      "systemNumber": "CC1-02",
      "status": "logged-in",      // 🔵 Logged In
      "currentStudentId": "22MCA001",
      "currentStudentName": "John Doe"
    },
    {
      "systemNumber": "CC1-03",
      "status": "guest",          // 🟣 Guest Mode
      "isGuest": true,
      "currentStudentId": "GUEST"
    },
    {
      "systemNumber": "CC1-04",
      "status": "offline"         // ⚫ Offline
    }
  ],
  "totalSystems": 60,
  "availableSystems": 45,
  "loggedInSystems": 10,
  "guestSystems": 2,
  "offlineSystems": 3
}
```

---

## 🔄 Current Workflow

### When Kiosk Powers On

1. **Kiosk starts** → Electron app launches
2. **Connects to server** → Socket.IO connection established
3. **Emits `register-kiosk`** → Sends system number (e.g., "CC1-05")
4. **Server extracts IP** → From `socket.handshake.address`
5. **Server detects lab** → `detectLabFromIP('10.10.46.105')` → "CC2"
6. **Updates registry** → Creates/updates SystemRegistry entry
7. **Sets status** → "available" (no student logged in yet)
8. **Joins room** → `socket.join('lab-CC2')`
9. **Broadcasts update** → Emits `systems-registry-update` to all admins

### When Admin Views Dashboard

1. **Dashboard loads** → Fetches `/api/labs`
2. **Shows lab selector** → Dropdown with CC1, CC2, CC3, etc.
3. **Admin selects lab** → e.g., "CC2"
4. **Fetches systems** → GET `/api/systems/CC2`
5. **Displays buttons** → Dynamically generates 60 buttons
6. **Color codes status**:
   - 🟢 Available → Can enable guest access
   - 🔵 Logged In → Student currently using
   - 🟣 Guest Mode → Guest access active
   - ⚫ Offline → Not responding

### When Admin Enables Guest Access

1. **Admin clicks** → "🔓 CC2-15" button
2. **Emits socket event** → `admin-enable-guest-access`
3. **Server updates registry** → status='guest', isGuest=true
4. **Server broadcasts** → `enable-guest-access` to kiosk CC2-15
5. **Kiosk auto-logs in** → GUEST / admin123
6. **Kiosk confirms** → Emits `guest-access-confirmed`
7. **Server updates registry** → Adds GUEST user info
8. **Admins see update** → Button turns purple, shows "GUEST MODE"

---

## 🎨 System Status Indicators

| Status | Color | Icon | Meaning | Admin Can Do |
|--------|-------|------|---------|-------------|
| **available** | 🟢 Green | 🔓 | System on, no user | Enable guest access |
| **logged-in** | 🔵 Blue | 👤 | Student using | View screen, monitor |
| **guest** | 🟣 Purple | 🆓 | Guest mode active | View screen, lock |
| **offline** | ⚫ Gray | ⏹️ | Not responding | Nothing (wait to come online) |

---

## 📝 What Needs to be Updated

### Admin Dashboard (`central-admin/dashboard/admin-dashboard.html`)

#### ⏳ TODO #1: Add Lab Selection Dropdown

**Location**: Top of guest access section (around line 580)

```html
<div class="lab-selector-container" style="margin-bottom: 20px;">
  <label for="labSelect" style="font-weight: bold; margin-right: 10px;">
    🏢 Select Lab:
  </label>
  <select id="labSelect" onchange="loadLabSystems(this.value)" 
          style="padding: 8px; font-size: 14px; min-width: 250px;">
    <option value="">-- Loading Labs --</option>
  </select>
  
  <div id="labStats" style="display: inline-block; margin-left: 20px; color: #666;">
    <span id="labStatsText"></span>
  </div>
</div>
```

#### ⏳ TODO #2: Replace Hardcoded Buttons with Dynamic Generation

**Current** (lines 582-621):
```html
<!-- ❌ HARDCODED - REMOVE THIS -->
<button onclick="enableGuestAccessForSystem('CC1-01')">🔓 CC1-01</button>
<button onclick="enableGuestAccessForSystem('CC1-02')">🔓 CC1-02</button>
<!-- ... more hardcoded buttons ... -->
```

**Replace with**:
```html
<div id="guestAccessButtons" class="guest-access-grid">
  <!-- Dynamically generated by loadLabSystems() -->
</div>

<style>
.guest-access-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
  padding: 10px;
}

.guest-btn {
  padding: 12px;
  border: 2px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
  text-align: center;
}

.guest-btn.available {
  background: linear-gradient(135deg, #4ade80 0%, #22c55e 100%);
  color: white;
  border-color: #16a34a;
}

.guest-btn.available:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4);
}

.guest-btn.logged-in {
  background: linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%);
  color: white;
  border-color: #2563eb;
  cursor: not-allowed;
}

.guest-btn.guest {
  background: linear-gradient(135deg, #c084fc 0%, #a855f7 100%);
  color: white;
  border-color: #9333ea;
}

.guest-btn.offline {
  background: #e5e7eb;
  color: #9ca3af;
  border-color: #d1d5db;
  cursor: not-allowed;
}
</style>
```

#### ⏳ TODO #3: Add JavaScript Functions

**Location**: Inside `<script>` tag (around line 1500)

```javascript
// Global state
let currentLabId = null;
let systemRegistry = [];

// Load all labs on page load
async function loadAllLabs() {
  try {
    const response = await fetch('/api/labs');
    const data = await response.json();
    
    if (data.success) {
      const labSelect = document.getElementById('labSelect');
      labSelect.innerHTML = '<option value="">-- Select Lab --</option>';
      
      Object.values(data.labs).forEach(lab => {
        const option = document.createElement('option');
        option.value = lab.labId;
        option.textContent = `${lab.labName} (${lab.labId})`;
        labSelect.appendChild(option);
      });
      
      // Auto-select first lab
      if (Object.keys(data.labs).length > 0) {
        const firstLabId = Object.keys(data.labs)[0];
        labSelect.value = firstLabId;
        loadLabSystems(firstLabId);
      }
    }
  } catch (error) {
    console.error('Error loading labs:', error);
    alert('Failed to load labs. Check server connection.');
  }
}

// Load systems for selected lab
async function loadLabSystems(labId) {
  if (!labId) {
    document.getElementById('guestAccessButtons').innerHTML = 
      '<p style="color: #999;">Please select a lab to view systems.</p>';
    return;
  }
  
  currentLabId = labId;
  
  try {
    const response = await fetch(`/api/systems/${labId}`);
    const data = await response.json();
    
    if (data.success) {
      systemRegistry = data.systems;
      renderSystemButtons(data);
      updateLabStats(data);
    }
  } catch (error) {
    console.error('Error loading systems:', error);
    alert('Failed to load systems. Check server connection.');
  }
}

// Render system buttons dynamically
function renderSystemButtons(data) {
  const container = document.getElementById('guestAccessButtons');
  
  if (data.systems.length === 0) {
    container.innerHTML = '<p style="color: #999;">No systems found for this lab.</p>';
    return;
  }
  
  const buttonsHTML = data.systems.map(system => {
    const statusClass = system.status || 'offline';
    const icon = getStatusIcon(system.status);
    const disabled = (system.status !== 'available' && system.status !== 'guest') ? 'disabled' : '';
    const tooltip = getTooltipText(system);
    
    return `
      <button 
        class="guest-btn ${statusClass}"
        onclick="handleSystemClick('${system.systemNumber}', '${system.status}')"
        ${disabled}
        title="${tooltip}">
        ${icon} ${system.systemNumber}
        ${system.currentStudentName ? '<br><small>' + system.currentStudentName + '</small>' : ''}
      </button>
    `;
  }).join('');
  
  container.innerHTML = buttonsHTML;
}

// Get status icon
function getStatusIcon(status) {
  const icons = {
    'available': '🔓',
    'logged-in': '👤',
    'guest': '🆓',
    'offline': '⏹️'
  };
  return icons[status] || '❓';
}

// Get tooltip text
function getTooltipText(system) {
  const tooltips = {
    'available': `Click to enable guest access on ${system.systemNumber}`,
    'logged-in': `${system.currentStudentName} is currently using this system`,
    'guest': `Guest access enabled on ${system.systemNumber}`,
    'offline': `${system.systemNumber} is offline or not responding`
  };
  return tooltips[system.status] || system.systemNumber;
}

// Update lab statistics
function updateLabStats(data) {
  const statsText = `
    Total: ${data.totalSystems} | 
    🟢 Available: ${data.availableSystems} | 
    🔵 Logged In: ${data.loggedInSystems} | 
    🟣 Guest: ${data.guestSystems} | 
    ⚫ Offline: ${data.offlineSystems}
  `;
  document.getElementById('labStatsText').textContent = statsText;
}

// Handle system button click
function handleSystemClick(systemNumber, status) {
  if (status === 'available') {
    enableGuestAccessForSystem(systemNumber);
  } else if (status === 'guest') {
    // Could add "lock system" functionality here
    alert(`${systemNumber} is already in guest mode. Feature: Lock system coming soon!`);
  }
}

// Update existing enableGuestAccessForSystem() to include labId
function enableGuestAccessForSystem(systemNumber) {
  if (!currentLabId) {
    alert('Please select a lab first.');
    return;
  }
  
  if (confirm(`Enable guest access on ${systemNumber}?`)) {
    const adminName = localStorage.getItem('adminName') || 'Admin';
    
    socket.emit('admin-enable-guest-access', {
      systemNumber: systemNumber,
      adminName: adminName,
      labId: currentLabId
    });
    
    showNotification(`Unlocking ${systemNumber}...`, 'info');
  }
}

// Listen for system registry updates
socket.on('systems-registry-update', (data) => {
  if (currentLabId && data.systems) {
    // Filter systems for current lab
    const labSystems = data.systems.filter(s => s.labId === currentLabId);
    
    // Update local registry
    systemRegistry = labSystems;
    
    // Re-render buttons
    renderSystemButtons({
      systems: labSystems,
      totalSystems: labSystems.length,
      availableSystems: labSystems.filter(s => s.status === 'available').length,
      loggedInSystems: labSystems.filter(s => s.status === 'logged-in').length,
      guestSystems: labSystems.filter(s => s.status === 'guest').length,
      offlineSystems: labSystems.filter(s => s.status === 'offline').length
    });
  }
});

// Call on page load
document.addEventListener('DOMContentLoaded', () => {
  loadAllLabs();
});
```

---

## 🧪 Testing Checklist

### Test 1: Lab Detection
- [ ] Start kiosk with IP `192.168.29.101`
- [ ] Check MongoDB: System should be in CC1
- [ ] Change IP to `10.10.46.101` (if possible)
- [ ] Check MongoDB: System should be in CC2

### Test 2: System Registry (Pre-Login)
- [ ] Power on kiosk (DON'T log in)
- [ ] Open admin dashboard
- [ ] Select lab (e.g., CC1)
- [ ] Verify system appears with 🟢 Available status

### Test 3: Guest Access on Available System
- [ ] Select lab in admin dashboard
- [ ] Find an available system (green button)
- [ ] Click the button
- [ ] Kiosk should auto-log in as GUEST
- [ ] Button should turn purple

### Test 4: Multi-Lab Isolation
- [ ] Open two admin dashboards in different browsers
- [ ] Dashboard 1: Select CC1
- [ ] Dashboard 2: Select CC2
- [ ] Enable guest on CC1-05 from Dashboard 1
- [ ] Verify Dashboard 2 doesn't show CC1-05

### Test 5: Real-Time Updates
- [ ] Admin 1: Viewing CC1 systems
- [ ] Admin 2: Viewing same CC1 systems
- [ ] Admin 1: Enables guest on CC1-10
- [ ] Admin 2: Should see CC1-10 turn purple immediately

---

## 🎯 Expected Results After UI Update

### Admin Dashboard View

```
┌─────────────────────────────────────────────────────────────┐
│ 🏢 Select Lab: [▼ Computer Center Lab 1 (CC1)            ]│
│    Total: 60 | 🟢 Available: 45 | 🔵 Logged In: 10 | ...   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 🔓 Guest Access - Available Systems                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  🔓 CC1-01   🔓 CC1-02   👤 CC1-03   🔓 CC1-04   ⏹️ CC1-05 │
│  Available   Available   John Doe    Available   Offline    │
│                                                               │
│  🆓 CC1-06   🔓 CC1-07   🔓 CC1-08   🔓 CC1-09   🔓 CC1-10 │
│  Guest User  Available   Available   Available   Available  │
│                                                               │
│  [... 50 more systems ...]                                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 👥 Active Students (CC1 Only)                               │
│ [Student cards with screen mirroring - filtered by CC1]     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Database Queries Working Now

### Get All Systems for a Lab
```javascript
const systems = await SystemRegistry.find({ labId: 'CC1' });
```

### Get Available Systems Only
```javascript
const available = await SystemRegistry.find({ 
  labId: 'CC1', 
  status: 'available' 
});
```

### Get Guest Mode Systems
```javascript
const guests = await SystemRegistry.find({ 
  labId: 'CC1', 
  isGuest: true 
});
```

### Mark System Offline (Timeout)
```javascript
// Run every 5 minutes
const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
await SystemRegistry.updateMany(
  { lastSeen: { $lt: fiveMinutesAgo }, status: { $ne: 'offline' } },
  { $set: { status: 'offline' } }
);
```

---

## 🚀 Next Steps

1. **Update Admin Dashboard HTML** → Add lab selector and remove hardcoded buttons
2. **Add JavaScript Functions** → Dynamic system rendering
3. **Test with Real IPs** → Verify lab detection works
4. **Add Offline Detection** → Auto-mark systems offline after 5 min
5. **Deploy to Multiple Labs** → Pilot with 2-3 labs

---

## ✅ What's Complete

- ✅ System registry database schema
- ✅ IP-based lab detection
- ✅ Lab configuration module
- ✅ API endpoints for labs and systems
- ✅ Socket.IO room-based isolation
- ✅ Guest access integration with registry
- ✅ Real-time system status updates

## ⏳ What's Pending

- ⏳ Admin dashboard lab selector UI
- ⏳ Dynamic system button generation
- ⏳ System status color coding
- ⏳ Lab-filtered student display
- ⏳ Multi-lab testing

---

**Ready to proceed with admin dashboard UI updates!**
