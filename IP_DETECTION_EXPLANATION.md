# IP Address Detection - How It Works

## Overview
The system automatically detects your computer's IP address to allow other devices (kiosks, admin dashboards) to connect to the server.

## Step-by-Step Process

### 1. **Server Startup** (`central-admin/server/app.js`)

When the server starts:
```javascript
const serverIp = detectLocalIP();  // Detects your IP
saveServerConfig(serverIp, PORT);  // Saves to server-config.json
```

### 2. **IP Detection Function** (`central-admin/server/ip-detector.js`)

The `detectLocalIP()` function:

1. **Gets all network interfaces** from your computer:
   ```javascript
   const interfaces = os.networkInterfaces();
   ```

2. **Priority order** (checks in this order):
   - Wi-Fi / WiFi
   - Ethernet
   - eth0, en0, wlan0 (Linux/Mac names)
   - Any other network interface

3. **Finds IPv4 address** that is:
   - Not internal (not 127.0.0.1 or ::1)
   - IPv4 family
   - Active and connected

4. **Returns the IP** or `'localhost'` if none found

### 3. **Saves to Config File**

The detected IP is saved to `server-config.json`:
```json
{
  "serverIp": "192.168.1.100",
  "serverPort": 7401,
  "lastUpdated": "2025-01-15T10:30:00.000Z",
  "autoDetect": true
}
```

### 4. **Client Access** (Admin Dashboard / Kiosk)

Clients read this config file:
```javascript
const response = await fetch('/server-config.json');
const config = await response.json();
serverUrl = `http://${config.serverIp}:${config.serverPort}`;
```

## On Localhost

### When You Access `http://localhost:7401`:

1. **Server detects IP**: Your actual network IP (e.g., `192.168.1.100`)
2. **Saves to config**: `server-config.json` contains `192.168.1.100`
3. **Dashboard loads**: Reads config, uses `http://192.168.1.100:7401`
4. **Socket.io connects**: Uses the detected IP, not localhost

### Why This Works:

- **Same machine**: `localhost` works because you're on the server machine
- **Other devices**: Need the actual IP (e.g., `192.168.1.100`) to connect
- **Auto-detection**: System finds the right IP automatically

## Example Flow

```
1. Server starts
   ↓
2. detectLocalIP() runs
   ↓
3. Finds: "192.168.1.100" (your WiFi IP)
   ↓
4. Saves to server-config.json
   ↓
5. Server running on: http://192.168.1.100:7401
   ↓
6. Admin dashboard loads
   ↓
7. Reads server-config.json
   ↓
8. Connects to: http://192.168.1.100:7401
   ↓
9. ✅ Connected!
```

## Troubleshooting

### If IP detection fails:

1. **Check network connection**: Make sure WiFi/Ethernet is connected
2. **Check server console**: Look for "✅ Detected IP from..." message
3. **Check server-config.json**: Verify it contains a valid IP
4. **Manual override**: Edit `server-config.json` manually if needed

### Common IPs:

- **Localhost**: `127.0.0.1` or `localhost` (only works on same machine)
- **Local network**: `192.168.x.x` or `10.0.x.x` (works on same WiFi/network)
- **Public IP**: Your internet IP (for remote access, requires port forwarding)

## Lab Detection (Separate Feature)

**Lab detection** (CC1, CC2, etc.) is different from IP detection:

- **IP detection**: Finds your computer's network address
- **Lab detection**: Maps IP ranges to lab IDs (e.g., `10.10.46.*` → CC1)

Currently, lab detection defaults to **CC1** when not at college (no IP ranges configured).




