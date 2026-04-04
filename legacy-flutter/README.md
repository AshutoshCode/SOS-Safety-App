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
│   ├── theme/
│   │   └── app_theme.dart             # Premium Design System
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
│   │       ├── screens/               # ContactsScreen
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
├── build.gradle
└── build.gradle
```

---

## 🛠️ Environment Setup & Troubleshooting

> [!IMPORTANT]
> **Fixing "Term 'flutter' is not recognized" Error**
> If you see an error saying `'flutter' is not recognized as the name of a cmdlet` when running `flutter run`, your computer doesn't know where the Flutter SDK is located. Follow these steps:
>
> 1. **Find your Flutter Path**: Locate where you downloaded Flutter (e.g., `C:\src\flutter\bin`).
> 2. **Open Environment Variables**: Search Windows for "Edit the system environment variables".
> 3. **Edit Path**:
>    - Click **Environment Variables**.
>    - Under **User variables**, find **Path** and click **Edit**.
>    - Click **New** and paste the full path to your `flutter\bin` folder.
> 4. **Restart Terminal**: Close and reopen your terminal (VS Code, PowerShell, or CMD) for the changes to take effect.
> 5. **Verify**: Run `flutter --version` to confirm it works.

---

## Setup Instructions

### Prerequisites
- Flutter 3.19.0+ installed
- Firebase project created with Android app
- Android SDK 21+ (minSdkVersion)

### 1. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create/Select project and add an Android app.
3. Download `google-services.json` and save it to `android/app/`.
4. Enable **Phone Authentication**, **Firestore**, and **Storage**.

### 2. Generate Firebase Config
Run the following to generate `lib/firebase_options.dart`:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```

### 3. Install & Run
```bash
flutter pub get
flutter run
```

---

## Key Features

### 💎 Premium Design System
- **AppTheme**: A custom-built Dark/Light theme with Indigo and Crimson accents.
- **Glassmorphism**: Home screen utilizes frosted-glass containers and high-contrast pulse animations.

### 🆘 Panic-Proof Triggers
- **Shake-to-SOS**: Trigger a silent alert simply by shaking the device (background capable).
- **Haptic Intelligence**: Tactile feedback on all critical events (SOS triggers and resolutions).
- **Offline SMS**: SMS alerts are sent via native Android `SmsManager`, ensuring they are queued even without an internet connection.

---

## License
Part of the SOS Safety Initiative.
