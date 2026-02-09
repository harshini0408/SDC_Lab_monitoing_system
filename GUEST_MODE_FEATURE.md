# 🔓 Guest Mode Feature - Implementation Summary

## Overview
Added a complete guest mode system that allows temporary access to lab computers without requiring student credentials. The guest password changes daily and is visible only to administrators.

---

## ✨ Features Implemented

### 1. **Guest Login in Kiosk Interface**
- **Location**: `student_deployment_package/student-kiosk/student-interface.html`
- **Features**:
  - New "Guest Mode" button with purple gradient styling
  - 4-digit password input (numeric only)
  - Guest password validation via server API
  - Guest sessions tracked separately from student sessions

### 2. **Daily Changing Guest Password**
- **Database Schema**: `GuestPassword` model
- **Password Generation**: Random 4-digit code (1000-9999)
- **Auto-Generation**: New password created automatically for each day
- **Cleanup**: Old passwords (30+ days) automatically deleted daily at midnight

### 3. **Admin Dashboard Guest Password Display**
- **Location**: `central-admin/dashboard/admin-dashboard.html`
- **Features**:
  - Dedicated purple-themed panel displaying today's guest password
  - Shows current date
  - Refresh button to reload password
  - Copy to clipboard functionality
  - Instructions for guest access
  - Auto-refreshes every 5 minutes

### 4. **Visual Identification of Guest Users**
- **Admin Dashboard**:
  - Guest logins displayed with **purple border** and gradient background
  - "GUEST MODE" badge on guest user cards
  - 🔓 icon instead of 👤 for guest users
  - Distinct styling: `border: 3px solid #667eea`

---

## 🔧 Technical Implementation

### Backend (Server)

#### New Database Schema
```javascript
const guestPasswordSchema = new mongoose.Schema({
  date: { type: String, required: true, unique: true }, // YYYY-MM-DD
  password: { type: String, required: true }, // 4-digit
  createdAt: { type: Date, default: Date.now }
});
```

#### Updated Session Schema
```javascript
const sessionSchema = new mongoose.Schema({
  // ... existing fields
  isGuest: { type: Boolean, default: false } // Track guest sessions
});
```

#### New API Endpoints

1. **POST `/api/guest-authenticate`**
   - Validates 4-digit guest password
   - Returns guest user object on success

2. **GET `/api/guest-password`**
   - Returns today's guest password (admin only)
   - Auto-generates if doesn't exist

#### Helper Functions
- `generateGuestPassword()`: Creates random 4-digit code
- `getTodayGuestPassword()`: Retrieves/creates today's password
- `cleanupOldGuestPasswords()`: Removes passwords older than 30 days

#### Cron Jobs
```javascript
// Daily cleanup at midnight
cron.schedule('0 0 * * *', async () => {
  await cleanupOldGuestPasswords();
});
```

### Frontend (Kiosk)

#### New Modal
```html
<div class="session-modal" id="guestLoginModal">
  <!-- 4-digit password input -->
  <!-- Login and Cancel buttons -->
</div>
```

#### New Functions
- `showGuestLogin()`: Displays guest login modal
- `guestLoginForm` event handler: Processes guest authentication

### Frontend (Admin Dashboard)

#### New Panel
- Purple gradient panel showing guest password
- Date display
- Password in large monospace font
- Refresh and copy buttons

#### New Functions
- `loadGuestPassword()`: Fetches and displays password
- `refreshGuestPassword()`: Manually refreshes password
- `copyGuestPassword()`: Copies to clipboard

#### Enhanced Student Card Rendering
```javascript
if (isGuest) {
  studentCard.classList.add('guest');
}
```

### Electron Main Process

#### New IPC Handler
```javascript
ipcMain.handle('guest-login', async (event, credentials) => {
  // Authenticate guest password
  // Create guest session
  // Unlock system for guest
  // Start screen mirroring
});
```

---

## 🎨 Visual Design

### Color Scheme
- **Primary Purple**: `#667eea`
- **Secondary Purple**: `#764ba2`
- **Gradient**: `linear-gradient(135deg, #667eea 0%, #764ba2 100%)`

### Guest User Card Styling
```css
.student-card.guest {
  border: 3px solid #667eea;
  background: linear-gradient(135deg, #f5f7ff 0%, #faf5ff 100%);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}
```

---

## 📋 Usage Instructions

### For Administrators

1. **View Guest Password**:
   - Open admin dashboard
   - Scroll to "Guest Mode Password" section (purple panel)
   - Password is displayed prominently with current date

2. **Share Password**:
   - Click "Copy Password" button
   - Share with students verbally or via projection

3. **Password Changes**:
   - Automatically updates at midnight daily
   - Click "Refresh Password" to check for updates

### For Students

1. **Guest Login**:
   - Go to kiosk interface
   - Click "Guest Mode" button (purple)
   - Enter 4-digit password from administrator
   - Click "Login as Guest"

2. **Guest Session**:
   - Full computer access
   - Session tracked in admin dashboard
   - Displayed with purple border
   - Logout ends session

---

## 🔒 Security Features

1. **Daily Password Rotation**:
   - New password generated automatically at midnight
   - Old passwords are invalidated

2. **Server-Side Validation**:
   - Password checked against database
   - No client-side bypass possible

3. **Session Tracking**:
   - All guest logins recorded
   - Tracked separately from student sessions
   - Visible to administrators

4. **Automatic Cleanup**:
   - Old passwords deleted after 30 days
   - Prevents database bloat

---

## 📁 Modified Files

### Backend
- `central-admin/server/app.js`
  - Added GuestPassword schema
  - Added guest authentication endpoint
  - Added guest password retrieval endpoint
  - Added daily cleanup cron job
  - Updated session schema with isGuest field

### Kiosk Interface
- `student_deployment_package/student-kiosk/student-interface.html`
  - Added guest login modal
  - Added guest login button
  - Added guest login form handler
  
- `student_deployment_package/student-kiosk/main-simple.js`
  - Added guest-login IPC handler
  - Guest session creation logic
  - System unlock for guest users

- `student_deployment_package/student-kiosk/preload.js`
  - Already had guestLogin exposed

### Admin Dashboard
- `central-admin/dashboard/admin-dashboard.html`
  - Added guest password display panel
  - Added guest card styling
  - Added guest identification in student cards
  - Added JavaScript functions for password management

---

## 🧪 Testing Checklist

### Guest Login
- [ ] Guest button appears in kiosk
- [ ] Modal opens with 4-digit input
- [ ] Correct password allows login
- [ ] Incorrect password shows error
- [ ] Guest session appears in admin dashboard

### Admin Dashboard
- [ ] Guest password panel is visible
- [ ] Password is displayed correctly
- [ ] Date is shown accurately
- [ ] Refresh button updates password
- [ ] Copy button works
- [ ] Guest users have purple border
- [ ] "GUEST MODE" badge appears

### Backend
- [ ] Guest password auto-generates on first access
- [ ] Same password returned for same day
- [ ] Password changes at midnight
- [ ] Old passwords cleaned up
- [ ] Guest sessions tracked in database

---

## 🚀 Deployment Notes

1. **Database Migration**:
   - No migration needed - schema auto-creates on first use
   - Guest password generated on first API call

2. **Existing Sessions**:
   - Existing sessions not affected
   - New isGuest field defaults to false

3. **Backward Compatibility**:
   - Fully compatible with existing system
   - Old student logins work unchanged
   - Guest mode is additive feature

---

## 📊 Future Enhancements (Optional)

1. **Password Complexity**:
   - Option for 6-digit passwords
   - Alphanumeric passwords
   - Custom password patterns

2. **Multiple Guest Passwords**:
   - Different passwords for different labs
   - Time-limited passwords
   - Single-use passwords

3. **Guest Restrictions**:
   - Limited session duration
   - Restricted access to certain systems
   - Usage quotas

4. **Analytics**:
   - Guest usage statistics
   - Peak guest usage times
   - Guest session duration tracking

---

## 📞 Support

For issues or questions about guest mode:
1. Check admin dashboard for current password
2. Verify kiosk is connected to server
3. Check browser console for errors
4. Verify MongoDB connection

---

**Feature Status**: ✅ **COMPLETE AND READY FOR TESTING**

**Last Updated**: February 6, 2026
