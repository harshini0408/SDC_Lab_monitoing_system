# ✅ Test Credentials - Kiosk Login

## Test Student Accounts (Now Available)

Use these credentials to test the kiosk login:

### Student 1 - Computer Science
- **Student ID**: `CS2021001`
- **Password**: `password123`
- **Name**: Rajesh Kumar
- **Lab**: CC1
- **Department**: Computer Science
- **Year**: 2

### Student 2 - Computer Science
- **Student ID**: `CS2021002`
- **Password**: `password123`
- **Name**: Priya Sharma
- **Lab**: CC1
- **Department**: Computer Science
- **Year**: 3

### Student 3 - Information Technology
- **Student ID**: `IT2021003`
- **Password**: `password123`
- **Name**: Arjun Patel
- **Lab**: CC1
- **Department**: Information Technology
- **Year**: 2

### Student 4 - Computer Science
- **Student ID**: `CS2021004`
- **Password**: `password123`
- **Name**: Sneha Reddy
- **Lab**: CC1
- **Department**: Computer Science
- **Year**: 3

### Student 5 - Information Technology
- **Student ID**: `IT2021005`
- **Password**: `password123`
- **Name**: Vikram Singh
- **Lab**: CC1
- **Department**: Information Technology
- **Year**: 4

---

## Guest Access Testing

For guest access (admin bypass login):
- **System ID**: Enter the system computer name displayed in kiosk UI
- **Lab ID**: CC1
- Admin dashboard should show "Allow Guest Access" button for each connected system
- When clicked, the kiosk will automatically login as "Guest User"

---

## Current Status

✅ Kiosk application running at `http://localhost:7401`
✅ Server running with 5 test students in database
✅ KIOSK_MODE enabled (full blocking mode active)
✅ Socket.io listening for guest-mode-enabled events
✅ /api/bypass-login endpoint implemented
