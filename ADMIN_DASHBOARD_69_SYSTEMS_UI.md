# 🖥️ Admin Dashboard - 69 Systems UI Implementation

## Quick Copy-Paste Code for admin-dashboard.html

### 1. Add Button to Session Controls (Line ~200)

Add this button after the existing session control buttons:

```html
<button class="btn btn-danger" onclick="showAllSystemsModal()" 
        style="background: #dc3545; color: white; font-weight: bold;">
    🔻 Show All Systems (Shutdown)
</button>
```

### 2. Add Modal HTML (Before `</body>` tag, around line 3000)

```html
<!-- All Systems Modal for Shutdown -->
<div id="allSystemsModal" class="fullscreen-modal">
    <div class="fullscreen-content" style="max-width: 1400px; max-height: 90vh; overflow-y: auto; background: white; border-radius: 15px; padding: 30px;">
        <button class="close-fullscreen" onclick="closeAllSystemsModal()">×</button>
        
        <h2 style="color: #dc3545; margin-bottom: 20px;">
            🖥️ All Lab Systems - Shutdown Control
        </h2>
        
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 2px solid #dee2e6;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <div>
                    <strong style="font-size: 1.1rem;">Lab:</strong> <span id="modalLabId" style="font-size: 1.1rem; color: #007bff;">CC1</span><br>
                    <strong>Total Systems:</strong> <span id="modalTotalSystems">0</span> |
                    <strong style="color: #28a745;">● Online:</strong> <span id="modalOnlineSystems">0</span> |
                    <strong style="color: #6c757d;">● Offline:</strong> <span id="modalOfflineSystems">0</span>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button onclick="selectAllSystems()" class="btn btn-success" style="padding: 10px 20px;">
                        ✅ Select All Online
                    </button>
                    <button onclick="deselectAllSystems()" class="btn btn-secondary" style="padding: 10px 20px;">
                        ❌ Deselect All
                    </button>
                    <button onclick="refreshSystemsGrid()" class="btn btn-primary" style="padding: 10px 20px;">
                        🔄 Refresh
                    </button>
                </div>
            </div>
        </div>
        
        <div id="allSystemsGrid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 15px; margin-bottom: 20px; max-height: 500px; overflow-y: auto; padding: 10px;">
            <!-- Systems will be populated here -->
        </div>
        
        <div style="display: flex; gap: 15px; justify-content: center; margin-top: 20px; padding-top: 20px; border-top: 2px solid #dee2e6;">
            <button onclick="shutdownSelectedSystems()" class="btn btn-danger" style="padding: 15px 40px; font-size: 1.2rem; font-weight: bold;">
                ⚡ Shutdown Selected Systems
            </button>
            <button onclick="closeAllSystemsModal()" class="btn btn-secondary" style="padding: 15px 40px; font-size: 1.2rem;">
                ❌ Cancel
            </button>
        </div>
        
        <div id="shutdownStatus" style="margin-top: 20px; padding: 15px; border-radius: 8px; display: none;"></div>
    </div>
</div>
```

### 3. Add JavaScript Functions (In `<script>` section, around line 800)

```javascript
// ========================================================================
// 69-SYSTEM LAB - ALL SYSTEMS MANAGEMENT & SHUTDOWN
// ========================================================================

let allSystemsData = [];

// Show all systems modal
async function showAllSystemsModal() {
    const modal = document.getElementById('allSystemsModal');
    modal.classList.add('active');
    
    await refreshSystemsGrid();
}

// Refresh systems grid
async function refreshSystemsGrid() {
    const labId = 'CC1'; // Or get from current session
    try {
        showNotification('🔄 Loading systems...', 'info', 2000);
        
        const response = await fetch(`${serverUrl}/api/lab-systems/${labId}`);
        const data = await response.json();
        
        if (data.success) {
            allSystemsData = data.systems || [];
            displayAllSystemsGrid(allSystemsData, data.stats);
            showNotification(`✅ Loaded ${allSystemsData.length} systems`, 'success', 2000);
        } else {
            throw new Error(data.error || 'Failed to load systems');
        }
    } catch (error) {
        console.error('Error loading systems:', error);
        showNotification('❌ Error loading systems', 'danger');
    }
}

// Display all systems in grid
function displayAllSystemsGrid(systems, stats) {
    const grid = document.getElementById('allSystemsGrid');
    const modalLabId = document.getElementById('modalLabId');
    const modalTotalSystems = document.getElementById('modalTotalSystems');
    const modalOnlineSystems = document.getElementById('modalOnlineSystems');
    const modalOfflineSystems = document.getElementById('modalOfflineSystems');
    
    if (systems.length > 0) {
        modalLabId.textContent = systems[0].labId;
    }
    
    modalTotalSystems.textContent = stats?.total || systems.length;
    modalOnlineSystems.textContent = stats?.online || 0;
    modalOfflineSystems.textContent = stats?.offline || 0;
    
    if (systems.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #6c757d;">
                <h3>No systems registered yet</h3>
                <p>Systems will appear here once they start sending heartbeats</p>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = systems.map(system => {
        const statusInfo = {
            'available': { color: '#28a745', icon: '●', text: 'Available', bg: '#d4edda' },
            'logged-in': { color: '#007bff', icon: '●', text: 'Logged In', bg: '#d1ecf1' },
            'guest': { color: '#ffc107', icon: '●', text: 'Guest', bg: '#fff3cd' },
            'offline': { color: '#6c757d', icon: '○', text: 'Offline', bg: '#f8f9fa' }
        }[system.status] || { color: '#6c757d', icon: '?', text: 'Unknown', bg: '#f8f9fa' };
        
        const isOffline = system.status === 'offline';
        const studentInfo = system.currentStudentName ? 
            `<div style="font-size: 0.75rem; color: #495057; margin-top: 5px; font-weight: 600;">👤 ${system.currentStudentName}</div>` : 
            '';
        
        return `
            <div style="border: 2px solid ${statusInfo.color}; border-radius: 10px; padding: 15px; background: ${statusInfo.bg}; transition: all 0.3s;">
                <label style="cursor: ${isOffline ? 'not-allowed' : 'pointer'}; display: block; opacity: ${isOffline ? '0.5' : '1'};">
                    <div style="display: flex; align-items: center; margin-bottom: 10px;">
                        <input type="checkbox" class="system-checkbox" value="${system.systemNumber}" 
                               ${isOffline ? 'disabled' : ''}
                               style="width: 20px; height: 20px; margin-right: 10px; cursor: ${isOffline ? 'not-allowed' : 'pointer'};">
                        <div style="font-weight: bold; font-size: 1.2rem; color: #2c3e50;">
                            ${system.systemNumber}
                        </div>
                    </div>
                    <div style="font-size: 0.9rem; color: ${statusInfo.color}; margin-bottom: 5px; font-weight: 600;">
                        ${statusInfo.icon} ${statusInfo.text}
                    </div>
                    <div style="font-size: 0.75rem; color: #6c757d;">
                        📍 ${system.ipAddress}
                    </div>
                    ${studentInfo}
                    ${!isOffline && system.secondsSinceLastSeen !== undefined ? 
                        `<div style="font-size: 0.7rem; color: #6c757d; margin-top: 5px;">⏱️ ${system.secondsSinceLastSeen}s ago</div>` : 
                        ''}
                </label>
            </div>
        `;
    }).join('');
}

// Select all online systems
function selectAllSystems() {
    const checkboxes = document.querySelectorAll('.system-checkbox:not([disabled])');
    checkboxes.forEach(cb => cb.checked = true);
    
    const count = checkboxes.length;
    showNotification(`✅ Selected ${count} online systems`, 'success', 2000);
}

// Deselect all systems
function deselectAllSystems() {
    document.querySelectorAll('.system-checkbox').forEach(cb => cb.checked = false);
    showNotification('❌ All systems deselected', 'info', 2000);
}

// Shutdown selected systems
async function shutdownSelectedSystems() {
    const selectedSystems = Array.from(document.querySelectorAll('.system-checkbox:checked'))
        .map(cb => cb.value);
    
    if (selectedSystems.length === 0) {
        showNotification('⚠️ Please select at least one system', 'warning');
        return;
    }
    
    const confirmMsg = `⚠️⚠️⚠️ CRITICAL WARNING ⚠️⚠️⚠️\n\n` +
        `You are about to COMPLETELY SHUTDOWN ${selectedSystems.length} computer(s).\n\n` +
        `This will:\n` +
        `• Force close all running programs\n` +
        `• Log out any active students\n` +
        `• Turn off computers completely\n` +
        `• Require manual power button press to restart\n\n` +
        `Systems to shutdown:\n${selectedSystems.join(', ')}\n\n` +
        `Are you absolutely sure?`;
    
    if (!confirm(confirmMsg)) {
        return;
    }
    
    // Second confirmation for safety
    if (!confirm('⚠️ FINAL CONFIRMATION\n\nThis action cannot be undone.\n\nShutdown ' + selected Systems.length + ' systems now?')) {
        return;
    }
    
    const statusDiv = document.getElementById('shutdownStatus');
    statusDiv.style.display = 'block';
    statusDiv.style.background = '#fff3cd';
    statusDiv.style.border = '2px solid #ffc107';
    statusDiv.style.color = '#856404';
    statusDiv.innerHTML = `
        <strong>⏳ SENDING SHUTDOWN COMMAND...</strong><br>
        Systems: ${selectedSystems.join(', ')}<br>
        <small>Shutdown command being sent to ${selectedSystems.length} systems...</small>
    `;
    
    try {
        const response = await fetch(`${serverUrl}/api/shutdown-systems`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                systemNumbers: selectedSystems,
                labId: 'CC1'
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            statusDiv.style.background = '#d4edda';
            statusDiv.style.border = '2px solid #28a745';
            statusDiv.style.color = '#155724';
            statusDiv.innerHTML = `
                <strong>✅ SHUTDOWN COMMAND SENT SUCCESSFULLY</strong><br>
                <div style="margin: 10px 0;">
                    <strong>${result.shutdownCount}</strong> of <strong>${result.totalRequested}</strong> systems received shutdown command
                </div>
                ${result.offlineCount > 0 ? `<div style="color: #856404;">⚠️ ${result.offlineCount} systems were offline</div>` : ''}
                <div style="margin-top: 10px; padding: 10px; background: #fff3cd; border-radius: 5px; border: 1px solid #ffc107;">
                    <strong>⏱️ Timeline:</strong><br>
                    <small>
                    • 10-second countdown shown on each system<br>
                    • Students see full-screen warning<br>
                    • Systems will power off completely after countdown<br>
                    • Manual power button press required to restart
                    </small>
                </div>
            `;
            
            showNotification(`✅ Shutdown initiated for ${result.shutdownCount} systems`, 'success', 5000);
            
            // Refresh grid after 3 seconds to show offline status
            setTimeout(() => {
                refreshSystemsGrid();
            }, 3000);
            
            // Auto-close modal after 8 seconds
            setTimeout(() => {
                closeAllSystemsModal();
            }, 8000);
        } else {
            throw new Error(result.error || 'Shutdown failed');
        }
    } catch (error) {
        console.error('Shutdown error:', error);
        statusDiv.style.background = '#f8d7da';
        statusDiv.style.border = '2px solid #dc3545';
        statusDiv.style.color = '#721c24';
        statusDiv.innerHTML = `
            <strong>❌ SHUTDOWN ERROR</strong><br>
            ${error.message}<br>
            <small>Please check network connection and try again</small>
        `;
        showNotification('❌ Shutdown failed: ' + error.message, 'danger');
    }
}

// Close all systems modal
function closeAllSystemsModal() {
    const modal = document.getElementById('allSystemsModal');
    modal.classList.remove('active');
    
    // Reset status
    const statusDiv = document.getElementById('shutdownStatus');
    statusDiv.style.display = 'none';
}

// ========================================================================
// END 69-SYSTEM LAB MANAGEMENT
// ========================================================================
```

## Deployment Instructions

### 1. Update Server (`app.js`)
✅ **ALREADY DONE** - Server endpoints added

### 2. Update Student Kiosk (`main-simple.js`)
✅ **ALREADY DONE** - Heartbeat and shutdown handlers added

### 3. Update Admin Dashboard (`admin-dashboard.html`)

**Copy the code above and add to your admin-dashboard.html:**
1. Button → Line ~200 (in session controls section)
2. Modal HTML → Before `</body>` tag
3. JavaScript functions → In `<script>` section

### 4. Test the System

1. Start 3-5 student kiosks
2. Wait 30 seconds for heartbeats
3. Open admin dashboard
4. Click "🔻 Show All Systems (Shutdown)"
5. Verify all systems appear
6. Select 1-2 systems
7. Click "⚡ Shutdown Selected Systems"
8. Confirm warnings
9. Watch systems shutdown after 10-second countdown

## System Status Legend

| Status | Icon | Color | Meaning |
|--------|------|-------|---------|
| Available | ● | 🟢 Green | System online, no student |
| Logged In | ● | 🔵 Blue | Student logged in + screen mirroring |
| Guest | ● | 🟡 Yellow | Guest user logged in |
| Offline | ○ | ⚪ Gray | System not responding (>60s) |

## Safety Features

1. ✅ **Double Confirmation** - Two confirm dialogs before shutdown
2. ✅ **10-Second Warning** - Full-screen countdown on student systems
3. ✅ **Offline Detection** - Cannot shutdown offline systems
4. ✅ **Visual Feedback** - Clear status updates during shutdown
5. ✅ **Logging** - All shutdown commands logged on server

## Troubleshooting

**Systems not appearing?**
- Wait 30 seconds for first heartbeat
- Check if kiosk is running on systems
- Verify network connectivity
- Check server logs for heartbeat errors

**Shutdown not working?**
- Verify system has socketId (check SystemRegistry)
- Ensure system status is not 'offline'
- Check Windows permissions for shutdown command
- Look for errors in kiosk console logs

**All systems show offline?**
- Check heartbeat interval (30 seconds)
- Verify server `/api/system-heartbeat` endpoint working
- Restart kiosk application on systems

---

**Status**: ✅ Ready for Implementation  
**Files Modified**: 3 (server, kiosk, admin dashboard)  
**Testing Required**: 1-2 hours  
**Full Deployment**: 2-3 hours for 69 systems
