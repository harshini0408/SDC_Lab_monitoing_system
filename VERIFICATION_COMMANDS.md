# 🔍 Admin Fix Verification Commands

**Purpose:** Console commands to verify the admin session persistence fix is working

---

## 📋 Browser Console Commands

Open browser DevTools (F12), go to Console tab, and run these commands:

---

## ✅ Check if Session State is Saved

```javascript
// View saved session state
JSON.parse(localStorage.getItem('adminSessionState'))
```

**Expected Output:**
```json
{
  "sessionActive": true,
  "currentLabSession": {
    "_id": "...",
    "subject": "Data Structures",
    "faculty": "Dr. Smith",
    "year": 2,
    "department": "CSE",
    "section": "A",
    "periods": 2,
    "startTime": "2026-01-20T14:00:00.000Z",
    "expectedDuration": 100
  },
  "sessionEndTime": "2026-01-20T15:40:00.000Z",
  "sessionExported": false,
  "connectedStudents": [
    ["65abc123...", { "name": "Student Name", "studentId": "TSI001", ... }]
  ],
  "timestamp": "2026-01-20T14:30:00.000Z"
}
```

**If null:** State is not being saved ❌

---

## 🔄 Check How Old the Saved State Is

```javascript
// Calculate age of saved state
const state = JSON.parse(localStorage.getItem('adminSessionState'));
if (state) {
    const savedTime = new Date(state.timestamp);
    const now = new Date();
    const hoursDiff = (now - savedTime) / (1000 * 60 * 60);
    console.log(`State saved ${hoursDiff.toFixed(2)} hours ago`);
    console.log(`Will expire in ${(24 - hoursDiff).toFixed(2)} hours`);
} else {
    console.log('No saved state found');
}
```

**Expected Output:**
```
State saved 0.25 hours ago
Will expire in 23.75 hours
```

---

## 👥 Check Connected Students Count

```javascript
// View number of connected students
const state = JSON.parse(localStorage.getItem('adminSessionState'));
if (state && state.connectedStudents) {
    console.log(`Connected students: ${state.connectedStudents.length}`);
    state.connectedStudents.forEach(([sessionId, data]) => {
        console.log(`  - ${data.name} (${data.studentId}) - System ${data.systemNumber}`);
    });
} else {
    console.log('No connected students saved');
}
```

**Expected Output:**
```
Connected students: 3
  - Subhahrini (TSI001) - System 5
  - John Doe (TSI002) - System 8
  - Jane Smith (TSI003) - System 12
```

---

## 🎥 Check Active Monitoring Connections

```javascript
// View active WebRTC connections
console.log(`Active monitoring connections: ${monitoringConnections.size}`);
monitoringConnections.forEach((pc, sessionId) => {
    console.log(`  - ${sessionId}: ${pc.connectionState} / ${pc.iceConnectionState}`);
});
```

**Expected Output:**
```
Active monitoring connections: 3
  - 65abc123...: connected / connected
  - 65def456...: connected / connected
  - 65ghi789...: connected / connected
```

---

## 🔗 Check Connected Students in Memory

```javascript
// View connectedStudents Map
console.log(`connectedStudents size: ${connectedStudents.size}`);
connectedStudents.forEach((data, sessionId) => {
    console.log(`  - ${sessionId.substring(0, 8)}... : ${data.name}`);
});
```

**Expected Output:**
```
connectedStudents size: 3
  - 65abc123... : Subhahrini
  - 65def456... : John Doe
  - 65ghi789... : Jane Smith
```

---

## ⏱️ Check Session Timer Status

```javascript
// Check session timer
if (sessionActive) {
    console.log('Session active: YES');
    console.log('Session end time:', sessionEndTime);
    console.log('Time remaining:', Math.round((sessionEndTime - new Date()) / 60000), 'minutes');
} else {
    console.log('Session active: NO');
}
```

**Expected Output:**
```
Session active: YES
Session end time: Mon Jan 20 2026 15:40:00 GMT+0530
Time remaining: 42 minutes
```

---

## 🧹 Manually Clear Session State (For Testing)

```javascript
// Clear saved state
localStorage.removeItem('adminSessionState');
console.log('Session state cleared');
```

**Use this to test:**
1. Start session
2. Clear state with this command
3. Refresh page
4. Verify state does NOT restore (expected)

---

## 💾 Manually Save Current State (For Testing)

```javascript
// Manually trigger save
saveAdminSessionState();
console.log('Session state manually saved');
```

---

## 🔄 Manually Trigger Reconnection (For Testing)

```javascript
// Manually trigger reconnection
reconnectToActiveStudents();
```

**Watch console for:**
```
============================================================
🔄 RECONNECTING TO ACTIVE STUDENTS
============================================================
✅ Socket connected, requesting active sessions...
🔍 Found X connected students
🎥 Restarting screen mirroring for all students...
🎥 Reconnecting to session: [sessionId] (Student Name)
✅ Initiated reconnection for X students
============================================================
✅ RECONNECTION PROCESS COMPLETE
============================================================
```

---

## 📊 View All localStorage Keys

```javascript
// View all localStorage keys
console.log('localStorage keys:');
for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    const value = localStorage.getItem(key);
    console.log(`  ${key}: ${value.substring(0, 50)}...`);
}
```

**Expected Output:**
```
localStorage keys:
  adminSessionState: {"sessionActive":true,"currentLabSe...
  uploadedTimetableInfo: {"filename":"timetable.csv","u...
```

---

## 🎯 Complete Health Check

```javascript
// Run complete health check
console.log('='.repeat(60));
console.log('ADMIN DASHBOARD HEALTH CHECK');
console.log('='.repeat(60));

// 1. Socket connection
console.log('1. Socket:', socket.connected ? '✅ Connected' : '❌ Disconnected');

// 2. Session state
const state = JSON.parse(localStorage.getItem('adminSessionState'));
console.log('2. Session saved:', state ? '✅ YES' : '❌ NO');
if (state) {
    console.log('   - Session active:', sessionActive ? '✅ YES' : '❌ NO');
    console.log('   - Students saved:', state.connectedStudents?.length || 0);
}

// 3. Connected students
console.log('3. Students in memory:', connectedStudents.size);

// 4. Monitoring connections
console.log('4. Active monitors:', monitoringConnections.size);

// 5. Match check
const savedCount = state?.connectedStudents?.length || 0;
const memoryCount = connectedStudents.size;
const monitorCount = monitoringConnections.size;

console.log('5. Counts match:');
console.log('   - Saved:', savedCount);
console.log('   - Memory:', memoryCount);
console.log('   - Monitors:', monitorCount);

if (savedCount === memoryCount && memoryCount === monitorCount) {
    console.log('   ✅ ALL COUNTS MATCH');
} else {
    console.log('   ⚠️ COUNTS DO NOT MATCH');
}

console.log('='.repeat(60));
```

**Expected Output:**
```
============================================================
ADMIN DASHBOARD HEALTH CHECK
============================================================
1. Socket: ✅ Connected
2. Session saved: ✅ YES
   - Session active: ✅ YES
   - Students saved: 3
3. Students in memory: 3
4. Active monitors: 3
5. Counts match:
   - Saved: 3
   - Memory: 3
   - Monitors: 3
   ✅ ALL COUNTS MATCH
============================================================
```

---

## 🧪 Test Auto-Save (Watch for 10 seconds)

```javascript
// Watch for auto-save messages
console.log('Watching for auto-save... (wait 10 seconds)');
setTimeout(() => {
    console.log('Check complete - did you see "💾 Admin session state saved to localStorage"?');
}, 11000);
```

**Expected:** Within 10 seconds, you should see:
```
💾 Admin session state saved to localStorage
```

---

## 🎬 Simulate Page Refresh (Testing)

```javascript
// Simulate what happens on page load
console.log('Simulating page refresh...');

// Step 1: Clear current state
connectedStudents.clear();
monitoringConnections.clear();
sessionActive = false;

console.log('Cleared current state');

// Step 2: Restore from localStorage
const restored = restoreAdminSessionState();
console.log('Restoration result:', restored ? '✅ SUCCESS' : '❌ FAILED');

// Step 3: Show restored data
console.log('Restored students:', connectedStudents.size);
console.log('Session active:', sessionActive);
```

---

## 🚨 Emergency: Force Clear Everything

```javascript
// Nuclear option - clear everything and start fresh
localStorage.clear();
sessionStorage.clear();
location.reload();
console.log('Everything cleared, page reloading...');
```

**⚠️ Warning:** This will clear ALL saved data and reload the page!

---

## 📝 Copy All State to Clipboard (For Debugging)

```javascript
// Copy state to clipboard for sharing
const state = {
    localStorage: JSON.parse(localStorage.getItem('adminSessionState')),
    sessionActive,
    currentLabSession,
    connectedStudentsCount: connectedStudents.size,
    monitoringConnectionsCount: monitoringConnections.size,
    socketConnected: socket?.connected
};

copy(JSON.stringify(state, null, 2));
console.log('State copied to clipboard! Paste it to share.');
```

**Note:** `copy()` function may not work in all browsers. If it doesn't, manually copy the output.

---

## 🔍 Debug Screen Mirroring Issues

```javascript
// Check each student's video container and monitoring status
connectedStudents.forEach((data, sessionId) => {
    console.log(`\nStudent: ${data.name} (${sessionId.substring(0, 8)}...)`);
    
    // Check video container
    const videoContainer = document.getElementById(`video-${sessionId}`);
    console.log('  Video container:', videoContainer ? '✅ EXISTS' : '❌ MISSING');
    
    // Check monitoring connection
    const pc = monitoringConnections.get(sessionId);
    console.log('  Peer connection:', pc ? '✅ EXISTS' : '❌ MISSING');
    
    if (pc) {
        console.log('  Connection state:', pc.connectionState);
        console.log('  ICE state:', pc.iceConnectionState);
    }
    
    // Check video element
    if (videoContainer) {
        const video = videoContainer.querySelector('video');
        console.log('  Video element:', video ? '✅ EXISTS' : '❌ MISSING');
        if (video) {
            console.log('  Video playing:', !video.paused ? '✅ YES' : '❌ NO');
            console.log('  Has stream:', video.srcObject ? '✅ YES' : '❌ NO');
        }
    }
});
```

---

## ✅ Quick Pass/Fail Test

```javascript
// Quick test - should all be true
const tests = {
    'Socket connected': socket?.connected,
    'Session state saved': !!localStorage.getItem('adminSessionState'),
    'Students in memory': connectedStudents.size > 0,
    'Monitoring active': monitoringConnections.size > 0,
    'Auto-save function exists': typeof saveAdminSessionState === 'function',
    'Restore function exists': typeof restoreAdminSessionState === 'function',
    'Reconnect function exists': typeof reconnectToActiveStudents === 'function'
};

console.log('QUICK TEST RESULTS:');
Object.entries(tests).forEach(([test, passed]) => {
    console.log(`${passed ? '✅' : '❌'} ${test}`);
});

const allPassed = Object.values(tests).every(v => v);
console.log('\nOVERALL:', allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED');
```

---

**Tip:** Bookmark this file and keep it open while testing! 🔖
