# WebRTC Diagnostic Guide

## Check These in Order:

### 1. Is Server Running?
```powershell
Test-NetConnection -ComputerName 192.168.29.212 -Port 7401
```
**Expected:** `TcpTestSucceeded: True`

### 2. Is Kiosk Running?
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "electron"}
```
**Expected:** At least 3-5 electron processes

### 3. Check Kiosk Console Logs
1. Click on kiosk window
2. Press `Ctrl+Shift+I` (or F12)
3. Go to Console tab
4. Look for:
   - ✅ `Socket connected`
   - ✅ `Session created:` [sessionId]
   - ✅ `Screen stream obtained successfully`
   - ✅ `EMITTING KIOSK-SCREEN-READY EVENT`

### 4. Check Session ID Match
**In Kiosk Console, type:**
```javascript
sessionId
```
**In Admin Dashboard Console, check the session ID in the error message**

**They MUST match!**

### 5. If Session IDs Don't Match:
The kiosk's sessionId might be stale. **Restart the kiosk:**
```powershell
cd D:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app
npm start
```

### 6. Check Kiosk is Receiving Offer
**In Kiosk Console, when admin tries to connect, you should see:**
```
📥 KIOSK: Received admin offer for session: [id]
📥 KIOSK: Current sessionId: [id]
📥 KIOSK: localStream available: true
🔗 Creating peer connection for admin offer...
✅ KIOSK: Peer connection created
📊 Adding tracks to peer connection...
✅ Track added, sender: created
✅ Total tracks added to peer connection: 1
🤝 KIOSK: Setting remote description
✅ KIOSK: Remote description set
📝 KIOSK: Creating answer
✅ KIOSK: Answer created
📝 KIOSK: Setting local description
✅ KIOSK: Local description set
📤 KIOSK: Sending answer to admin
✅ KIOSK: Answer sent - handshake completed!
```

### 7. If You Don't See "Received admin offer":
**Problem:** Offer not reaching kiosk

**Solutions:**
a) Check if kiosk socket is connected:
   ```javascript
   // In kiosk console:
   socket.connected
   ```
   Should return: `true`

b) Check which socket ID the kiosk has:
   ```javascript
   // In kiosk console:
   socket.id
   ```

c) Check if kiosk is registered on server:
   - Look at server console for: `📡 Kiosk registered: [sessionId]`

### 8. If Answer is Not Reaching Admin:
**In Admin Dashboard Console, you should see:**
```
📹 WebRTC answer received for session: [id]
✅ ADMIN: Received answer from kiosk
✅ ADMIN: Remote description set successfully
🧊 🔁 ADMIN: Flushing X queued ICE candidates
```

**If you don't see "WebRTC answer received":**
- The answer is not being sent by kiosk, OR
- The server is not forwarding it, OR
- The adminSocketId is wrong

### 9. Common Issues & Fixes:

**Issue: "Session ID mismatch"**
```
Fix: Restart kiosk to get fresh session
```

**Issue: "localStream not available"**
```
Fix: Check for Windows Graphics Capture errors in kiosk logs
      May need graphics driver update
```

**Issue: "Connection state: closed immediately"**
```
Fix: Usually means answer never arrived
     Check kiosk console for errors in handleAdminOffer
```

**Issue: "ICE candidates queued but never flushed"**
```
Fix: This confirms answer is not arriving
     Check steps 6-8 above
```

### 10. Nuclear Option - Full Restart:

```powershell
# Stop everything
Stop-Process -Name "electron" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue

# Wait 3 seconds
Start-Sleep -Seconds 3

# Start server
cd D:\screen_mirror_deployment_my_laptop\central-admin\server
Start-Process powershell -ArgumentList "-NoExit", "-Command", "node app.js"

# Wait 5 seconds for server to start
Start-Sleep -Seconds 5

# Start kiosk
cd D:\screen_mirror_deployment_my_laptop\student-kiosk\desktop-app
npm start

# Wait for kiosk to load, then login with:
# Student ID: 715524104158
# Password: password123

# Then refresh admin dashboard and wait 10-15 seconds
```

---

## Quick Diagnostic Commands:

**Check everything at once:**
```powershell
Write-Host "=== DIAGNOSTIC CHECK ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Server Status:" -ForegroundColor Yellow
Test-NetConnection -ComputerName 192.168.29.212 -Port 7401 | Select-Object TcpTestSucceeded

Write-Host ""
Write-Host "2. Electron Processes:" -ForegroundColor Yellow
Get-Process -Name "electron" -ErrorAction SilentlyContinue | Select-Object Id, StartTime

Write-Host ""
Write-Host "3. Node Processes:" -ForegroundColor Yellow
Get-Process -Name "node" -ErrorAction SilentlyContinue | Select-Object Id, StartTime

Write-Host ""
Write-Host "Next: Check kiosk console (Ctrl+Shift+I) for session ID and offer logs"
```
