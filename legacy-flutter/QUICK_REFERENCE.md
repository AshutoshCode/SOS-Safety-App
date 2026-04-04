# Quick Reference Card - Silent Emergency Alert MVP

## 🚀 Get Started (5 minutes)

```bash
cd /path/to/silent_emergency_alert

# 1. Install dependencies
flutter pub get

# 2. Setup Firebase (one-time)
flutterfire configure --project=YOUR_PROJECT_ID

# 3. Run app
flutter run
```

---

## 📋 File Locations Cheat Sheet

### Most Important Files
| File | Purpose | Lines |
|------|---------|-------|
| `lib/main.dart` | App entry, routing, Firebase init | 89 |
| `lib/features/emergency/data/repositories/alert_repository_impl.dart` | **CORE SOS LOGIC** | 148 |
| `lib/features/emergency/presentation/screens/home_screen.dart` | SOS button UI | 334 |
| `android/app/src/main/kotlin/.../services/SmsService.kt` | Native SMS (offline) | 65 |
| `lib/features/auth/presentation/screens/login_screen.dart` | Phone login UI | 222 |

### By Feature
```
Auth          → lib/features/auth/
Contacts      → lib/features/contacts/
Emergency     → lib/features/emergency/
Services      → lib/features/emergency/services/
Core Config   → lib/config/ + lib/core/
Android       → android/app/src/main/
```

---

## 🔑 Key Classes & Methods

### Authentication
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
AuthProvider
  .sendOtp(phoneNumber)          // Request OTP
  .verifyOtp(otp)                // Verify and sign in
  .signOut()                      // Logout
  .currentUser                    // Get logged-in user
  .isAuthenticated                // Check auth state
```

### Emergency (SOS) - **MOST IMPORTANT**
```dart
// lib/features/emergency/presentation/providers/emergency_provider.dart
EmergencyProvider
  .triggerSOS()                   // Start emergency alert
  .resolveAlert()                 // End alert
  .activeAlert                    // Current alert
  .isTrackingLocation             // Location active?
  .isRecordingAudio               // Audio active?
```

### Location
```dart
// lib/features/emergency/services/location_service.dart
LocationService
  .getCurrentLocation()           // Get current position
  .startLocationUpdates(...)      // Start tracking
  .stopLocationUpdates()          // Stop tracking
  .streamLocationUpdates()        // Real-time stream
```

### Audio Recording
```dart
// lib/features/emergency/services/audio_recorder_service.dart
AudioRecorderService
  .startRecording()               // Start recording
  .stopRecording()                // Stop and save
  .isRecording                    // Is recording?
```

### SMS (Native)
```dart
// lib/features/emergency/services/sms_service.dart
SmsService
  .sendSms(phoneNumber, message)  // Send SMS (offline-capable)
  .sendSmsToMultiple(...)         // Batch send
  .hasSmsPermission()             // Check permission
```

---

## 🏗️ Architecture Pattern

**Every feature follows Domain → Data → Presentation**:

```
Domain (Interfaces)
  ├─ entity.dart                  ← Data structure
  └─ repository.dart              ← Interface

Data (Implementation)
  ├─ model.dart                   ← Serialization
  ├─ datasource.dart              ← API calls
  └─ repository_impl.dart         ← Implements interface

Presentation (UI + State)
  ├─ provider.dart                ← ChangeNotifier
  ├─ screen.dart                  ← Widget
  └─ widget.dart                  ← Component
```

---

## 🔄 State Management Pattern

All state uses **Provider + ChangeNotifier**:

```dart
// Create provider
class MyProvider extends ChangeNotifier {
  String _data = '';
  String get data => _data;

  Future<void> loadData() async {
    _data = await repo.getData();
    notifyListeners();  // Rebuild UI
  }
}

// Use in widget
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return Text(provider.data);
  },
)

// Or read without rebuilding
context.read<MyProvider>().loadData();
```

---

## 🔌 Dependency Injection (GetIt)

All services are registered in `service_locator.dart` and accessed globally:

```dart
// Register (in service_locator.dart)
getIt.registerSingleton<AlertRepository>(
  AlertRepositoryImpl(...)
);

// Use anywhere
final alertRepo = getIt<AlertRepository>();

// With Logger
final logger = getIt<Logger>();
logger.i('Info');
logger.w('Warning');
logger.e('Error');
```

---

## 🌐 Firestore Collections

### users/{userId}
```
phoneNumber: string
firstName: string
lastName: string
createdAt: timestamp
settings: { enableLocationTracking, enableAudioRecording, smsAlertEnabled }
```

### users/{userId}/alerts/{alertId}
```
status: string ("active" | "resolved" | "cancelled")
triggerType: string ("sos" | "fall_detection")
createdAt: timestamp
resolvedAt: timestamp (nullable)
contactsNotified: string[]
audioRecordingUrl: string (nullable)
lastLatitude: number
lastLongitude: number
```

### users/{userId}/alerts/{alertId}/locations/{locationId}
```
latitude: number
longitude: number
accuracy: number
timestamp: timestamp
```

---

## 📱 Android Permissions

Required in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

Request at runtime in code (handled by services).

---

## 🎯 SOS Flow (Key Logic)

```
User: Long-press SOS button
       ↓ (after confirmation)
EmergencyProvider.triggerSOS()
       ↓
AlertRepositoryImpl.triggerEmergencyAlert()
       ├─ Get emergency contacts
       ├─ SMS each contact [OFFLINE-CAPABLE]
       ├─ Create alert in Firestore
       └─ Return Alert object
       ↓
LocationService.startLocationUpdates()  [Stream locations to Firestore]
AudioRecorderService.startRecording()   [Record to local file]
       ↓
Show AlertDetailsSheet
       ├─ Status: ACTIVE
       ├─ Location tracking: ✓
       ├─ Audio recording: ✓
       └─ Button: Resolve Alert
       ↓
User: Click Resolve Alert
       ↓
EmergencyProvider.resolveAlert()
       ├─ Stop location tracking
       ├─ Stop audio recording
       ├─ Update Firestore: status = "resolved"
       └─ Show alert history
```

---

## 🚨 Firebase Method Channel (SMS)

Flutter calls native Android code for SMS:

```dart
// Flutter (lib/features/emergency/services/sms_service.dart)
const platform = MethodChannel('com.example.emergency_alert/sms');
final result = await platform.invokeMethod<bool>(
  'sendSms',
  {'phoneNumber': phone, 'message': msg},
);

// Android (MainActivity.kt)
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
  .setMethodCallHandler { call, result ->
    when (call.method) {
      "sendSms" -> {
        val phone = call.argument<String>("phoneNumber")
        val msg = call.argument<String>("message")
        val success = smsService.sendSms(phone, msg)
        result.success(success)
      }
    }
  }
```

---

## 📊 Current Phase Status

| Phase | Feature | Status | LOC |
|-------|---------|--------|-----|
| 1 | Auth + Firebase | ✅ COMPLETE | ~500 |
| 2 | Contacts | 🟡 60% (structure) | ~300 |
| 3 | SOS + SMS | ✅ COMPLETE | ~1,000 |
| 4 | Location Map | 🟡 60% (service) | ~300 |
| 5 | FCM Notifications | 🟡 30% | ~200 |
| 6 | Background + Audio | 🟡 50% (audio) | ~400 |
| 7 | Polish & Testing | ⏳ 0% | ~300 |

---

## 🧪 Testing Checklist

### Phase 1 (Auth)
- [ ] Login with phone works
- [ ] OTP verification works
- [ ] User created in Firestore
- [ ] Can sign out

### Phase 3 (SOS) - CRITICAL
- [ ] Press SOS → Confirmation dialog
- [ ] Confirm → Alert created in Firestore
- [ ] Check: `users/{userId}/alerts/{alertId}` exists
- [ ] Check: `status = "active"`
- [ ] Check: `contactsNotified = []` (no contacts yet)

### Phase 4 (Location)
- [ ] Location permission requested
- [ ] Firestore: `users/{userId}/alerts/{alertId}/locations/` has docs
- [ ] Locations update every 30s

### Phase 6 (Audio)
- [ ] Audio starts on SOS
- [ ] Audio file saved to: `getApplicationDocumentsDirectory()/emergency_audio_*.wav`
- [ ] Can listen to file

---

## 🐛 Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| "Firebase not initialized" | Run `flutterfire configure` |
| "google-services.json not found" | Download from Firebase Console, place in `android/app/` |
| "Minsdkversion conflict" | Update `android/app/build.gradle` to `minSdkVersion 21` |
| "SMS not sending" | Check permissions, test on physical device |
| "Location permission denied" | Implement permission request in service |
| "Build fails with Kotlin error" | Update Kotlin version in `android/build.gradle` |

---

## 📚 Key Files to Read First

1. **`README.md`** (5 min) — Project overview
2. **`SETUP_GUIDE.md`** (10 min) — Firebase setup
3. **`lib/features/emergency/data/repositories/alert_repository_impl.dart`** (15 min) — Core SOS logic
4. **`lib/features/emergency/presentation/screens/home_screen.dart`** (10 min) — UI flow
5. **`lib/core/services/service_locator.dart`** (5 min) — Dependency injection

---

## 🎯 Next Action Items

### For Frontend Developer
```
1. Create contacts_provider.dart
   ↓
2. Build contacts_list_screen.dart
   ↓
3. Build add_contact_screen.dart
   ↓
4. Create live_location_map.dart widget
   ↓
5. Build settings_screen.dart
```

### For Backend Developer
```
1. Verify contact sync to Firestore
   ↓
2. Set up Cloud Functions for FCM
   ↓
3. Implement Android WorkManager for background location
   ↓
4. Setup audio file upload to Cloud Storage
   ↓
5. Configure error logging
```

### For Testing
```
1. Run app on real Android device
   ↓
2. Test phone auth flow
   ↓
3. Test SOS trigger (check Firestore)
   ↓
4. Test SMS sending (use real phone)
   ↓
5. Test location tracking
```

---

## 🚀 Deploy Checklist

- [ ] All Phases 1-7 complete
- [ ] Tested on multiple Android devices
- [ ] Firestore security rules configured
- [ ] Error logging (Crashlytics) set up
- [ ] Privacy policy written
- [ ] Terms of service reviewed
- [ ] App signed and ready for Google Play
- [ ] Demo script recorded
- [ ] Presentation slides prepared

---

## 🔗 Important Links

- **Firebase Console**: https://console.firebase.google.com
- **Flutter Docs**: https://flutter.dev/docs
- **Dart API Docs**: https://api.dart.dev
- **Pub.dev (Packages)**: https://pub.dev
- **Android Docs**: https://developer.android.com/docs

---

## 📞 Quick Help

**Q: Where do I check current user?**
```dart
final user = context.read<AuthProvider>().currentUser;
```

**Q: How do I call a repository?**
```dart
final repo = getIt<AlertRepository>();
final alert = await repo.triggerEmergencyAlert();
```

**Q: Where do I add a new route?**
```dart
// lib/main.dart → _buildRouter()
GoRoute(
  path: '/my-route',
  builder: (context, state) => const MyScreen(),
),
```

**Q: How do I update Firestore?**
```dart
// Use datasource in repository
await datasource.updateDocument(id, data);
```

**Q: How do I request a permission?**
```dart
// For location
await Geolocator.requestPermission();

// For audio
await audioRecorder.hasPermission();

// For SMS (Android, in native code)
ActivityCompat.requestPermissions(this, arrayOf(SEND_SMS), CODE);
```

---

## ⚡ Performance Tips

- Use `const` constructors when possible
- Call `notifyListeners()` only when necessary
- Batch Firestore writes
- Use streams for real-time data
- Limit location updates to 30s+ intervals
- Pre-cache user data in SharedPreferences

---

**Last Updated**: 2026-04-01
**Status**: Phase 1 & 3 Complete, Ready for Phase 2+
**Next Action**: Start Phase 2 (Contact Management)
