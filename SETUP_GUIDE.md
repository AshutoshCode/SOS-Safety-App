# Setup Guide - Silent Emergency Alert MVP

Complete step-by-step guide to set up and run the app locally.

## Prerequisites

- **Flutter**: 3.19.0 or higher ([Install](https://flutter.dev/docs/get-started/install))
- **Android SDK**: API 21+ (install via Android Studio)
- **Xcode**: (optional, for iOS testing)
- **Firebase Project**: (create at https://console.firebase.google.com)
- **Node.js**: (optional, for Firebase CLI)

Verify your setup:

```bash
flutter doctor
```

---

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console

Visit [https://console.firebase.google.com](https://console.firebase.google.com)

### 1.2 Create New Project

1. Click "Create Project"
2. Enter project name (e.g., `emergency-alert-mvp`)
3. Disable Google Analytics (optional for MVP)
4. Click "Create Project"

### 1.3 Add Android App

1. In Firebase project, click "Add App" → Android
2. Register Android app:
   - **Package name**: `com.example.emergency_alert`
   - **App nickname**: `Emergency Alert`
   - **Debug SHA-1**: (optional for now)
3. Download `google-services.json`
4. Move file to `android/app/google-services.json`

### 1.4 Enable Authentication (Phone)

1. Go to **Authentication** → **Sign-in method**
2. Click "Phone" → Enable
3. Add test phone numbers (optional):
   - Click "Phone numbers for testing"
   - Add your phone number + one test OTP (e.g., `123456`)

### 1.5 Create Firestore Database

1. Go to **Firestore Database**
2. Click "Create Database"
3. Start in **Test mode** (for MVP development)
4. Select location (closest to you)

### 1.6 Enable Cloud Storage (for audio recordings)

1. Go to **Storage**
2. Click "Get Started"
3. Start in **Test mode**
4. Select location

### 1.7 Enable Cloud Messaging (FCM)

1. Go to **Cloud Messaging** tab
2. Copy **Server API Key** (save for later if needed)

---

## Step 2: Configure Flutter Project

### 2.1 Install Dependencies

```bash
cd /path/to/silent_emergency_alert
flutter pub get
```

### 2.2 Generate Firebase Options

Install flutterfire CLI:

```bash
dart pub global activate flutterfire_cli
```

Run configuration:

```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

This generates `lib/firebase_options.dart` automatically.

If you already have `google-services.json`, you can skip this and manually populate `lib/firebase_options.dart` (template already exists).

### 2.3 Verify Firebase Config

Check `lib/firebase_options.dart` contains your Firebase credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '...',
  appId: '...',
  messagingSenderId: '...',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

---

## Step 3: Android Setup

### 3.1 Update Project Name (Optional)

If you don't want package name `com.example.emergency_alert`:

```bash
flutter pub global activate rename
rename_app --appname "Emergency Alert" --bundleId com.yourcompany.emergencyalert
```

### 3.2 Verify Android Manifest

Check `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.emergency_alert">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <!-- ... more permissions ... -->
</manifest>
```

### 3.3 Check Gradle Configuration

Verify `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    minSdkVersion 21
    targetSdkVersion 34
}
```

---

## Step 4: Run the App

### 4.1 Start Android Emulator or Connect Device

**Using Emulator**:
```bash
flutter emulators
flutter emulators launch Pixel_6_API_34  # or your emulator
```

**Using Physical Device**:
- Connect Android device via USB
- Enable Developer Mode and USB Debugging
- Run `flutter devices` to verify

### 4.2 Run Flutter App

```bash
flutter run
```

Or with specific device:

```bash
flutter run -d <device-id>
```

### 4.3 Expected Output

1. App launches
2. LoginScreen appears
3. Enter your test phone number (or use test phone from Firebase)
4. Enter OTP (if using Firebase test phone, use test OTP `123456`)
5. HomeScreen appears with SOS button

---

## Step 5: Test Core Functionality

### 5.1 Phone Authentication

- [ ] Enter phone number in format: `9876543210` (or `+91 9876543210`)
- [ ] Request OTP
- [ ] Receive OTP via SMS (or use test OTP `123456`)
- [ ] Enter OTP and verify
- [ ] Should see HomeScreen with SOS button

### 5.2 SOS Button Test

- [ ] On HomeScreen, long-press the red SOS button
- [ ] Confirmation dialog appears
- [ ] Click "YES, EMERGENCY"
- [ ] Alert is created in Firestore
- [ ] SMS should be queued (check if permissions granted)

### 5.3 Check Firestore Data

1. Go to Firebase Console → Firestore Database
2. Navigate to `users/{yourUserId}/alerts/{alertId}`
3. Should see alert document with:
   - `status: "active"`
   - `triggerType: "sos"`
   - `createdAt: <timestamp>`
   - `contactsNotified: []` (empty since no contacts yet)

---

## Step 6: Add Emergency Contacts (Phase 2)

Once Phase 2 is complete:

1. [ ] Go to Contacts screen
2. [ ] Add 2-3 test contacts with phone numbers
3. [ ] Mark as "Emergency Contacts"
4. [ ] Verify contacts sync to Firestore:
   - `users/{userId}/contacts/{contactId}`

---

## Step 7: Test Location Tracking (Phase 4)

Once Phase 4 is complete:

1. [ ] Grant location permission when prompted
2. [ ] Trigger SOS
3. [ ] Check Firestore for location updates:
   - `users/{userId}/alerts/{alertId}/locations/{locationId}`
4. [ ] Should have multiple location docs with `latitude`, `longitude`, `accuracy`, `timestamp`

---

## Troubleshooting

### Issue: "Flutter SDK not found"

**Solution**:
```bash
flutter config --android-sdk /path/to/android-sdk
```

### Issue: "google-services.json not found"

**Solution**:
1. Download from Firebase Console
2. Place in `android/app/google-services.json`

### Issue: "Failed to connect to Firebase"

**Solution**:
1. Check Firebase project ID in `firebase_options.dart`
2. Check internet connection
3. Verify Firebase Authentication → Phone is enabled
4. Clear build cache:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue: "SMS Permission Denied"

**Solution**:
1. Grant permission in Android Settings
2. Or modify `MainActivity.kt` to request permission on app start
3. Test on physical device (emulator may not support SMS)

### Issue: "Location Permission Denied"

**Solution**:
1. Request permission when entering emergency alert
2. Or add to AndroidManifest.xml with `android:maxSdkVersion`

### Issue: "Build failed - minSdkVersion conflict"

**Solution**:
Update `android/app/build.gradle`:
```gradle
android {
    minSdkVersion 21  // or higher if plugin requires
}
```

---

## Debug Tips

### View Flutter Logs

```bash
flutter logs
```

### View Android Logcat

```bash
adb logcat | grep flutter
```

### Hot Reload / Hot Restart

During development:
- **Hot Reload**: Type `r` (fast, keeps state)
- **Hot Restart**: Type `R` (full restart)

### Disable Optimizations for Debugging

```bash
flutter run --profile  # Better for testing
```

---

## Next Steps

1. **Run the app** and test phone authentication
2. **Implement Phase 2** (Contact Management)
3. **Test SOS trigger** and check Firestore
4. **Implement Phase 4** (Location Tracking)
5. **Complete Phase 7** (Polish & Demo)

---

## Important: Production Setup

Before deploying to production:

1. ✅ Change Firestore security rules (test rules expire in 30 days):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
         match /contacts/{document=**} {
           allow read, write: if request.auth.uid == userId;
         }
       }
     }
   }
   ```

2. ✅ Update Cloud Storage rules
3. ✅ Set up backup strategies
4. ✅ Configure error logging (Crashlytics)
5. ✅ Test on multiple Android versions

---

## Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Android Docs**: https://developer.android.com/docs
- **Dart Package Docs**: https://pub.dev

---

**Ready?** Run `flutter run` and start testing! 🚀
