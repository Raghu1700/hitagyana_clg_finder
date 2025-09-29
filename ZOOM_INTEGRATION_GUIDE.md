# 🎥 Zoom Meeting Integration Guide

## Overview
This document describes the Zoom meeting integration added to the Hitagyana College Finder app. After enrolling in a class and completing payment, students can see Zoom meeting details and join classes directly from the app.

---

## ✅ What Was Implemented

### 1. **Updated Data Model**
- **File**: `lib/data/models/extracurricular_class_model.dart`
- **Added Fields**:
  - `zoomMeetingId`: String - Zoom meeting ID (e.g., "123 456 7890")
  - `zoomMeetingLink`: String - Direct Zoom meeting URL
  - `zoomPassword`: String - Meeting password
  - `isRecurring`: bool - Whether the meeting is recurring
  - `recurringDays`: List<String> - Days of the week for classes
  - `meetingTime`: String - Time of class (e.g., "7:00 PM - 8:30 PM")
  - `timezone`: String - Timezone (e.g., "IST")

### 2. **Sample Data with Zoom Information**
Updated sample courses with Zoom meeting data:

#### Digital Art Fundamentals
```dart
zoomMeetingId: "123 456 7890"
zoomMeetingLink: "https://zoom.us/j/1234567890?pwd=abc123"
zoomPassword: "art2025"
recurringDays: ["Monday", "Wednesday", "Friday"]
meetingTime: "7:00 PM - 8:30 PM"
```

#### Python Programming Bootcamp
```dart
zoomMeetingId: "987 654 3210"
zoomMeetingLink: "https://zoom.us/j/9876543210?pwd=xyz789"
zoomPassword: "python123"
recurringDays: ["Tuesday", "Thursday"]
meetingTime: "8:00 PM - 9:30 PM"
```

### 3. **Zoom Meeting Section Widget**
- **File**: `lib/presentation/course_page/widgets/zoom_meeting_section.dart`
- **Features**:
  - ✅ Displays next class date (Today, Tomorrow, or day of week)
  - ✅ Shows Zoom Meeting ID with copy-to-clipboard
  - ✅ Shows Password with copy-to-clipboard
  - ✅ Displays recurring schedule
  - ✅ "Join Zoom Meeting" button that redirects to Zoom
  - ✅ Beautiful UI with Zoom brand colors

### 4. **Updated Course Page**
- **File**: `lib/presentation/course_page/course_page.dart`
- **Changes**:
  - Added import for `ZoomMeetingSection` widget
  - Displays Zoom section **only for enrolled students**
  - Positioned above the enrollment/access buttons

---

## 🔄 User Flow

### Step 1: Browse Classes
User browses available classes in the "Classes" tab.

### Step 2: View Class Details
User clicks on a class to see details (instructor, rating, description, etc.)

### Step 3: Enroll & Pay
User clicks "Enroll Now" → Razorpay payment gateway opens → User completes payment

### Step 4: Access Enrolled Class
After payment, the class appears in "My Classes" tab with "Enrolled" badge

### Step 5: View Zoom Details
User clicks on enrolled class → **Zoom Meeting Section is now visible** with:
- Next class date and time
- Meeting ID (with copy button)
- Password (with copy button)
- Recurring schedule
- "Join Zoom Meeting" button

### Step 6: Join Meeting
User clicks "Join Zoom Meeting" → Zoom app opens (or web) → User joins the class

---

## 📱 Screenshots & UI

### Zoom Meeting Section (Visible Only When Enrolled)

```
┌─────────────────────────────────────────┐
│  🎥  Zoom Meeting Details               │
│      Recurring Class                    │
├─────────────────────────────────────────┤
│                                         │
│  🕒  Next Class: Tomorrow               │
│      8:00 PM - 9:30 PM IST              │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  🏷️  Meeting ID                         │
│     987 654 3210               [Copy]   │
│                                         │
│  🔒  Password                           │
│     python123                  [Copy]   │
│                                         │
│  📅  Schedule                           │
│     Tuesday, Thursday                   │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│      [📹 Join Zoom Meeting]             │
│                                         │
│  Make sure you have Zoom installed      │
└─────────────────────────────────────────┘
```

---

## 🛠️ Technical Implementation

### Copy to Clipboard
```dart
void _copyToClipboard(String text, String label) {
  Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.showToast(
    msg: "$label copied to clipboard",
    backgroundColor: AppTheme.byzantium,
  );
}
```

### Join Zoom Meeting
```dart
void _joinZoomMeeting() async {
  final zoomLink = course['zoomMeetingLink']?.toString() ?? '';
  
  if (zoomLink.isEmpty) {
    // Show error
    return;
  }

  final Uri url = Uri.parse(zoomLink);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
```

### Next Class Date Calculation
```dart
String _getNextClassDate() {
  final recurringDays = course['recurringDays'] as List?;
  final now = DateTime.now();
  final weekdays = ['Monday', 'Tuesday', 'Wednesday', ...];
  
  for (int i = 0; i < 7; i++) {
    final checkDate = now.add(Duration(days: i));
    final checkWeekday = weekdays[checkDate.weekday - 1];
    
    if (recurringDays.contains(checkWeekday)) {
      if (i == 0) return 'Today';
      if (i == 1) return 'Tomorrow';
      return checkWeekday;
    }
  }
}
```

---

## 🔐 Data Structure in Firebase

When saving courses to Firebase, include Zoom fields:

```json
{
  "id": "course_123",
  "name": "Python Programming Bootcamp",
  "instructor": "Michael Chen",
  "price": 4999,
  "rating": 4.9,
  "zoomMeetingId": "987 654 3210",
  "zoomMeetingLink": "https://zoom.us/j/9876543210?pwd=xyz789",
  "zoomPassword": "python123",
  "isRecurring": true,
  "recurringDays": ["Tuesday", "Thursday"],
  "meetingTime": "8:00 PM - 9:30 PM",
  "timezone": "IST"
}
```

---

## 📦 Dependencies Used

- **url_launcher**: ^6.3.1 - For opening Zoom links
- **flutter/services**: For clipboard functionality
- **fluttertoast**: ^8.2.12 - For showing copy notifications

---

## 🎨 UI Design Notes

### Colors
- **Zoom Blue**: `Color(0xFF2D8CFF)` - Used for Zoom branding
- **Success Green**: `Colors.green` - For next class info
- **Purple Theme**: `AppTheme.tyrianPurple` - For text and buttons

### Icons
- 🎥 `Icons.videocam` - Zoom section header
- 🕒 `Icons.schedule` - Next class time
- 🏷️ `Icons.tag` - Meeting ID
- 🔒 `Icons.lock` - Password
- 📅 `Icons.calendar_today` - Schedule
- 📹 `Icons.video_call` - Join button

---

## 🚀 Testing Instructions

### Test Scenario 1: New User Enrollment
1. Register/Login to the app
2. Go to "Classes" tab
3. Select "Python Programming Bootcamp" (pre-enrolled for testing)
4. Verify Zoom section appears
5. Click "Join Zoom Meeting" → Zoom should open

### Test Scenario 2: Enroll in New Class
1. Go to "Classes" tab
2. Select "Digital Art Fundamentals"
3. Click "Enroll Now" - ₹2,999
4. Complete payment (use test card if Razorpay test mode)
5. Course appears in "My Classes"
6. Open course → Zoom section should now be visible

### Test Scenario 3: Copy Functionality
1. Open enrolled course
2. Click copy button next to Meeting ID
3. Verify toast shows "Meeting ID copied to clipboard"
4. Paste in notes app to verify it copied correctly

### Test Scenario 4: Next Class Date
1. Check that "Next Class" shows correct upcoming day
2. For current day classes, should show "Today"
3. For tomorrow's classes, should show "Tomorrow"
4. Otherwise shows day name (e.g., "Monday")

---

## 🔧 Customization Guide

### Adding Zoom Info to New Courses

When creating new courses, include these fields:

```dart
{
  "name": "Your Course Name",
  "instructor": "Instructor Name",
  // ... other fields ...
  
  // Zoom Integration Fields
  "zoomMeetingId": "123 456 7890",
  "zoomMeetingLink": "https://zoom.us/j/1234567890?pwd=abc123",
  "zoomPassword": "yourpassword",
  "isRecurring": true,
  "recurringDays": ["Monday", "Wednesday", "Friday"],
  "meetingTime": "10:00 AM - 11:30 AM",
  "timezone": "IST",
}
```

### Making Classes One-Time Instead of Recurring

```dart
"isRecurring": false,
"recurringDays": [], // Empty array
"meetingTime": "December 15, 2024 - 2:00 PM",
```

---

## ⚠️ Important Notes

1. **Zoom App Required**: Users must have Zoom installed for best experience
2. **URL Format**: Zoom links should include password parameter for seamless join
3. **Enrollment Check**: Zoom section only shows if `_isEnrolled` is true
4. **Firebase Sync**: Ensure Firebase courses collection includes Zoom fields
5. **Null Safety**: Widget handles missing Zoom data gracefully (won't show if no link)

---

## 🐛 Troubleshooting

### Issue: Zoom section not showing
- **Check**: Is user actually enrolled? (Check "My Classes" tab)
- **Check**: Does course data have `zoomMeetingLink` field?
- **Check**: Is `zoomMeetingLink` non-empty?

### Issue: "Could not open Zoom" error
- **Check**: Is Zoom app installed?
- **Check**: Is URL format correct? Should be `https://zoom.us/j/...`
- **Check**: Try opening link in browser first to verify it works

### Issue: Copy not working
- **Check**: Android permissions for clipboard
- **Check**: Flutter clipboard service is initialized

---

## 📝 Future Enhancements

### Possible Improvements:
1. **Calendar Integration**: Add to Google Calendar / iCal
2. **Reminders**: Push notifications 5 minutes before class
3. **Recording Access**: Links to recorded sessions
4. **Attendance Tracking**: Mark attendance when joining
5. **Live Status**: Show if meeting is currently live
6. **Instructor Status**: Show if instructor has joined
7. **Meeting History**: List of past meetings and recordings
8. **Alternative Links**: Google Meet, Microsoft Teams support

---

## 📞 Support

For any issues or questions:
- 📧 Email: support@hitagyana.com
- 📱 Phone: +1-800-HITAGYANA
- 🐛 Report Issues: GitHub Issues

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Author**: Hitagyana Development Team
