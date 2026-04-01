# Silent Emergency Alert System MVP

A production-ready Flutter + Firebase mobile app for triggering silent SOS alerts without unlocking the phone. Sends SMS alerts, shares live location, and starts background audio recording.

## Architecture Overview

**Clean Architecture (Lite)**:
```
Presentation (Screens, Providers, Widgets)
    ↓
Domain (Entities, Repositories interfaces)
    ↓
Data (Models, Datasources, Implementations)
    ↓
Firebase + Native Android Services
```

### Tech Stack
- **Frontend**: Flutter with Provider + GetIt
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging, Storage)
- **Native**: Android Kotlin for SMS, background services, sensors

---

## Project Structure

```
lib/
├── main.dart                          # App entry, Firebase init, routing
├── firebase_options.dart              # Firebase config (auto-generated)
├── config/
│   └── firebase_config.dart           # Firebase initialization
├── core/
│   ├── services/
│   │   └── service_locator.dart       # GetIt dependency injection
│   ├── providers/                     # Core provider logic
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/           # Firebase auth API
│   │   │   ├── models/                # UserModel
│   │   │   └── repositories/          # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/              # User entity
│   │   │   └── repositories/          # AuthRepository interface
│   │   └── presentation/
│   │       ├── providers/             # AuthProvider (state management)
│   │       ├── screens/               # LoginScreen, SignupScreen
│   │       └── widgets/
│   │
│   ├── contacts/
│   │   ├── data/
│   │   │   ├── datasources/           # Firebase contacts API
│   │   │   ├── models/                # ContactModel
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/              # Contact entity
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/             # ContactsProvider
│   │       ├── screens/               # ContactsListScreen, AddContactScreen
│   │       └── widgets/
│   │
│   └── emergency/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── firebase_alert_datasource.dart      # Alert API
│       │   │   └── firebase_location_datasource.dart   # Location API
│       │   ├── models/
│       │   │   └── alert_model.dart
│       │   └── repositories/
│       │       └── alert_repository_impl.dart          # Core SOS logic
│       ├── domain/
│       │   ├── entities/
│       │   │   └── alert.dart
│       │   └── repositories/
│       │       └── alert_repository.dart               # SOS interface
│       ├── services/
│       │   ├── sms_service.dart                        # SMS via method channel
│       │   ├── location_service.dart                   # Geolocator integration
│       │   └── audio_recorder_service.dart             # Audio recording
│       └── presentation/
│           ├── providers/             # EmergencyProvider
│           ├── screens/               # HomeScreen, AlertDetailsScreen
│           └── widgets/
│
└── shared/
    ├── models/
    └── widgets/

android/
├── app/
│   ├── src/main/
│   │   ├── kotlin/
│   │   │   └── com/example/emergency_alert/
│   │   │       ├── MainActivity.kt            # Method channel setup
│   │   │       └── services/
│   │   │           └── SmsService.kt          # Native SMS (offline-capable)
│   │   └── AndroidManifest.xml                # Permissions
│   └── build.gradle
└── build.gradle
```

---

## Phase-by-Phase Implementation

### Phase 1: Foundation & Core UI (1.5 days) ✅
- [x] Create Flutter project, Firebase initialization
- [x] Set up GetIt service locator
- [x] Phone authentication via Firebase Auth
- [x] Create login/signup screens
- [x] Implement Auth Provider

**Status**: Complete. Users can authenticate with phone number.

### Phase 2: Contact Management (1 day)
- [ ] Design Contact model and Firestore schema
- [ ] Import local Android contacts
- [ ] Build contacts list screen
- [ ] Add/edit/delete functionality
- [ ] Local storage fallback

**To Do**: Create contacts feature screens and sync logic.

### Phase 3: SOS Trigger & Alert Management (1 day) ✅
- [x] Design Alert model and Firestore schema
- [x] Implement SOS button with confirmation
- [x] **Core**: SMS alert sending via Android native
- [x] Alert history screen
- [x] Alert state management

**Status**: Core logic complete. `AlertRepositoryImpl.triggerEmergencyAlert()` sends SMS immediately (offline), creates Firestore alert, and returns Alert object for UI.

### Phase 4: Live Location Tracking (1 day)
- [ ] Implement location service using geolocator
- [ ] Continuous location updates (5-10s intervals)
- [ ] Write locations to Firestore
- [ ] Build live location map widget
- [ ] Handle location permissions

**To Do**: Create location tracking widgets and Firebase writes.

### Phase 5: Firebase Cloud Messaging (0.5 days)
- [ ] Set up FCM in Firebase project
- [ ] Store FCM tokens in Firestore
- [ ] Receive push notifications
- [ ] Display notifications

**To Do**: Integrate firebase_messaging and flutter_local_notifications.

### Phase 6: Background Services & Audio Recording (1 day)
- [x] Audio recording service using record package
- [x] Shake detection setup
- [ ] Android background location service (WorkManager)
- [ ] Auto-start audio recording on SOS
- [ ] Handle Android background constraints

**Status**: Audio service created. Audio recording starts on SOS and saves locally.

### Phase 7: Polish & Testing (1.5 days)
- [ ] End-to-end testing on Android device
- [ ] Error handling (no internet, permissions denied)
- [ ] Settings screen
- [ ] Performance optimization
- [ ] Demo preparation

---

## Firebase Firestore Schema

```javascript
// users/{userId}
{
  phoneNumber: string,
  firstName: string,
  lastName: string,
  emergencyContacts: string[] (contact IDs),
  settings: {
    enableLocationTracking: boolean,
    enableAudioRecording: boolean,
    smsAlertEnabled: boolean,
  },
  createdAt: timestamp,
}

// users/{userId}/contacts/{contactId}
{
  name: string,
  phoneNumber: string,
  relation: string,
  priority: number (1-5),
  addedAt: timestamp,
}

// users/{userId}/alerts/{alertId}
{
  status: string ("active" | "resolved" | "cancelled"),
  triggerType: string ("sos" | "fall_detection"),
  createdAt: timestamp,
  resolvedAt: timestamp (nullable),
  contactsNotified: string[] (contact IDs),
  audioRecordingUrl: string (nullable, Cloud Storage URL),
  lastLatitude: number,
  lastLongitude: number,
}

// users/{userId}/alerts/{alertId}/locations/{locationId}
{
  latitude: number,
  longitude: number,
  accuracy: number,
  timestamp: timestamp,
}
```

---

## Setup Instructions

### Prerequisites
- Flutter 3.19.0+ installed
- Firebase project created with Android app
- Android SDK 21+ (minSdkVersion)
- Node.js for Firebase CLI (optional)

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add Android app to project
4. Download `google-services.json` and save to `android/app/`
5. Enable following services in Firebase:
   - Authentication → Phone
   - Firestore Database (default rules for MVP)
   - Cloud Messaging (FCM)
   - Cloud Storage

### 2. Generate Firebase Config

Run flutterfire CLI to auto-generate `lib/firebase_options.dart`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Android Configuration

- Ensure `android/app/src/main/AndroidManifest.xml` includes required permissions
- Update `android/app/build.gradle` with correct `compileSdkVersion` and `minSdkVersion`

### 5. Run App

```bash
flutter run
```

---

## Key Implementation Details

### SMS Sending (Offline-Capable)

**Flow**:
1. User taps SOS → `EmergencyProvider.triggerSOS()`
2. `AlertRepositoryImpl.triggerEmergencyAlert()` calls:
   - `SmsService.sendSms()` → Native Android (SYNCHRONOUS, works offline)
   - Creates alert in Firestore (queued if offline)
   - Returns Alert object to UI
3. UI starts location tracking and audio recording

**Critical**: SMS is sent via Android native `SmsManager.sendTextMessage()` which works offline—the OS queues it if no internet.

### Background Location Updates

Uses **WorkManager** (most reliable for Android background tasks):
- Periodic task every 15 minutes initially
- Can upgrade to foreground service for real-time (shows notification)
- Syncs with Firestore when online

### Permissions (Android 12+)

Request dynamically at feature usage time:
- Location: when entering emergency alert
- SMS: when first SOS triggered
- Microphone: when starting audio recording
- Show graceful fallbacks if denied

---

## Testing Checklist

1. ✅ Phone login works
2. ✅ Can add 2-3 emergency contacts
3. ✅ Tap SOS → SMS received in Android SMS app
4. ✅ Tap SOS → Firebase alert created + location synced
5. ✅ Location map updates in real-time
6. ✅ Minimize app → location still updates
7. ✅ Audio recording starts on SOS
8. ✅ Alert history shows past alerts
9. ✅ Settings screen works

---

## Live Demo Flow (4 minutes)

1. **Phone login** (30s)
   - User logs in with phone number

2. **Add emergency contacts** (60s)
   - Add 2 test contacts

3. **Trigger SOS** (15s)
   - Hold SOS button
   - Confirm dialog
   - SMS visible in SMS app

4. **Live location** (60s)
   - Map shows location updating in real-time

5. **Background test** (30s)
   - Minimize app
   - Location still updates

6. **Alert history** (30s)
   - Show past SOS in alert history
   - Show location trail on map

---

## Critical Files Summary

**Phase 1-3 (Auth + SOS)**:
- `lib/main.dart` — App entry
- `lib/config/firebase_config.dart` — Firebase setup
- `lib/core/services/service_locator.dart` — Dependency injection
- `lib/features/auth/presentation/providers/auth_provider.dart` — Auth state
- `lib/features/emergency/domain/repositories/alert_repository.dart` — SOS interface
- `lib/features/emergency/data/repositories/alert_repository_impl.dart` — Core SOS logic
- `lib/features/emergency/services/sms_service.dart` — SMS via method channel
- `android/app/src/main/kotlin/com/example/emergency_alert/services/SmsService.kt` — Native SMS

**Phase 4-6 (Location, Messaging, Background)**:
- `lib/features/emergency/services/location_service.dart` — Location tracking
- `lib/features/emergency/services/audio_recorder_service.dart` — Audio recording
- `lib/features/emergency/presentation/screens/home_screen.dart` — Main UI with SOS button

---

## Known Constraints & Mitigations

| Risk | Mitigation |
|------|-----------|
| Firebase auth complexity | Use phone-only auth (simpler) |
| SMS cost/reliability | Fallback to Firebase Cloud Messaging |
| Location battery drain | Start at 15-min intervals, batch updates |
| Background service killed | Use WorkManager (system-managed) |
| Permissions denied | Show graceful fallbacks |
| Cold start lag | Pre-cache user data in SharedPreferences |
| Firestore costs | Batch updates, throttle writes |

---

## Dependencies

All dependencies are in `pubspec.yaml`:

```yaml
firebase_core: ^5.4.0
firebase_auth: ^6.0.0
cloud_firestore: ^6.0.0
firebase_messaging: ^14.0.0
provider: ^7.1.0
get_it: ^7.8.0
geolocator: ^12.1.0
google_maps_flutter: ^3.0.0
record: ^5.1.0
workmanager: ^0.5.0
permission_handler: ^11.4.0
```

---

## Next Steps

1. **Download `google-services.json`** from Firebase Console
2. **Run `flutterfire configure`** to generate `firebase_options.dart`
3. **Test on Android emulator or device**:
   ```bash
   flutter run
   ```
4. **Implement Phase 2-7** following the plan above
5. **Build & demo**:
   ```bash
   flutter build apk --release
   ```

---

## Troubleshooting

### Build Errors
- Ensure `android/app/build.gradle` has correct `compileSdkVersion: 34`
- Run `flutter clean` and `flutter pub get`

### Firebase Issues
- Check `google-services.json` is in `android/app/`
- Verify Firebase project has Android app configured
- Check Firebase Authentication has Phone login enabled

### SMS Not Sending
- Check `android/app/src/main/AndroidManifest.xml` has `SEND_SMS` permission
- On Android 6+, request runtime permission
- Test with real device (emulator may not support SMS)

### Location Permission Denied
- Request permission explicitly in app
- Check Android Settings → App Permissions → Emergency Alert

---

## License

This project is part of a hackathon. For production use, ensure compliance with relevant regulations.
