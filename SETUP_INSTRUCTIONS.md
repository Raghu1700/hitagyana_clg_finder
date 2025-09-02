# 🚀 Quick Setup Guide - Add Mock College Data

## Step 1: Fix Firestore Security Rules

1. **Go to Firebase Console:**
   - Open: https://console.firebase.google.com/
   - Select project: `hitagyana-clg-finder`

2. **Update Firestore Rules:**
   - Go to **Firestore Database** → **Rules** tab
   - Copy the content from `firestore_rules.txt` file
   - Paste it in the rules editor
   - Click **"Publish"**

## Step 2: Add Mock College Data

### Option A: Using the Web Interface (Recommended)

1. **Open the HTML file:**
   - Open `add_mock_data_web.html` in your web browser
   - Click the **"Add Mock Data"** button
   - Wait for success messages

### Option B: Manual Addition via Firebase Console

1. **Go to Firestore Database:**
   - Click **"Start collection"**
   - Collection ID: `colleges`
   - Click **"Next"**

2. **Add First College (IIT Delhi):**
   - Document ID: `iit-delhi`
   - Add all fields from the mock data (see firebase_setup_guide.md)

3. **Add Second College (AIIMS Delhi):**
   - Document ID: `aiims-delhi`
   - Add all fields from the mock data

## Step 3: Test the App

1. **Hot Reload the Flutter App:**
   - In your Flutter terminal, press `r` for hot reload
   - The app should now show the mock college data

2. **Verify Features:**
   - ✅ Colleges appear on main screen
   - ✅ Search functionality works
   - ✅ Category filters work (Engineering, Medical)
   - ✅ College details page works
   - ✅ Save/unsave functionality works

## Expected Results

After setup, you should see:
- **2 colleges** in the main dashboard
- **IIT Delhi** (Engineering category)
- **AIIMS Delhi** (Medical category)
- **No more permission errors** in the terminal
- **Full app functionality** working

## Troubleshooting

If you still see permission errors:
1. Make sure you published the Firestore rules
2. Wait 1-2 minutes for rules to propagate
3. Hot reload the Flutter app (`r` in terminal)

## Clean Up

After testing, remember to:
1. Update Firestore rules to production-ready rules
2. Delete the temporary setup files
3. Add proper authentication-based security rules
