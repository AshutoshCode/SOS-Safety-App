# Developer Guide - Silent Emergency Alert MVP

Quick reference for developers working on this project.

## Project Structure Quick Navigation

### 📁 Starting Points
- **Main Entry**: `lib/main.dart` — App initialization, Firebase setup, routing
- **Home Screen**: `lib/features/emergency/presentation/screens/home_screen.dart` — SOS button UI
- **Auth Screen**: `lib/features/auth/presentation/screens/login_screen.dart` — Phone login

### 🏗️ Clean Architecture Layers

**Each feature follows: Domain → Data → Presentation**

```
Presentation (UI, State)
  └─ Screens (pages), Providers (state), Widgets (components)
Domain (Business Logic)
  └─ Entities (data structures), Repositories (interfaces)
Data (Implementation)
  └─ Models (serialization), DataSources (API calls), Repositories (impl)
```

### 💾 Core Services
- **Service Locator**: `lib/core/services/service_locator.dart` — All dependencies registered here
- **Firebase Config**: `lib/config/firebase_config.dart` — Firebase initialization

### 🚨 Emergency Alert (Phase 3 - Core)
- **Repository**: `lib/features/emergency/data/repositories/alert_repository_impl.dart` — **Main SOS logic**
- **Services**: `lib/features/emergency/services/` — SMS, Location, Audio
- **Screens**: `lib/features/emergency/presentation/screens/home_screen.dart` — UI

---

## Common Tasks

### Add a New Feature

1. **Create domain layer** (entities + repository interface)
   ```
   lib/features/my_feature/domain/
   ├── entities/
   │   └── my_entity.dart
   └── repositories/
       └── my_repository.dart
   ```

2. **Create data layer** (models + datasources + implementation)
   ```
   lib/features/my_feature/data/
   ├── datasources/
   │   └── firebase_my_datasource.dart
   ├── models/
   │   └── my_model.dart
   └── repositories/
       └── my_repository_impl.dart
   ```

3. **Create presentation layer** (screens + providers + widgets)
   ```
   lib/features/my_feature/presentation/
   ├── providers/
   │   └── my_provider.dart
   ├── screens/
   │   └── my_screen.dart
   └── widgets/
       └── my_widget.dart
   ```

4. **Register in service locator**
   ```dart
   // lib/core/services/service_locator.dart
   getIt.registerSingleton<MyRepository>(
     MyRepositoryImpl(dataSource: getIt<MyDataSource>()),
   );
   ```

5. **Add to routing**
   ```dart
   // lib/main.dart
   GoRoute(
     path: '/my-feature',
     builder: (context, state) => const MyScreen(),
   ),
   ```

### Modify State Management

All state is managed via `Provider` package + `ChangeNotifier`:

```dart
// lib/features/my_feature/presentation/providers/my_provider.dart
class MyProvider extends ChangeNotifier {
  MyRepository _repo = getIt<MyRepository>();

  String? _data;
  String? get data => _data;

  Future<void> fetchData() async {
    _data = await _repo.getData();
    notifyListeners(); // Rebuild widgets
  }
}

// Use in widget
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return Text(provider.data);
  },
)
```

### Call Firestore API

1. **Create datasource** to call Firestore
2. **Create repository implementation** that uses datasource
3. **Register in service locator**
4. **Use in provider** via `getIt<MyRepository>()`

Example (from emergency module):
```dart
// Datasource
class FirebaseAlertDataSource {
  Future<AlertModel> createAlert(AlertModel alert) async {
    final docRef = await _firestore.collection('users').doc(_userId).collection('alerts').add({
      'status': 'active',
      'createdAt': Timestamp.now(),
    });
    return AlertModel(id: docRef.id, ...);
  }
}

// Repository
class AlertRepositoryImpl implements AlertRepository {
  Future<Alert> triggerEmergencyAlert() async {
    return alertDataSource.createAlert(alertModel);
  }
}

// Provider
class EmergencyProvider extends ChangeNotifier {
  AlertRepository _repo = getIt<AlertRepository>();

  Future<void> triggerSOS() async {
    _activeAlert = await _repo.triggerEmergencyAlert();
    notifyListeners();
  }
}
```

### Call Native Android Code

Use **MethodChannel** for Flutter ↔ Android communication:

```dart
// Flutter side
const platform = MethodChannel('com.example.emergency_alert/sms');

Future<bool> sendSms(String phone, String message) async {
  try {
    final result = await platform.invokeMethod<bool>(
      'sendSms',
      {'phoneNumber': phone, 'message': message},
    );
    return result ?? false;
  } on PlatformException {
    return false;
  }
}

// Android side (MainActivity.kt)
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
  .setMethodCallHandler { call, result ->
    when (call.method) {
      "sendSms" -> {
        val phone = call.argument<String>("phoneNumber")
        val msg = call.argument<String>("message")
        smsService.sendSms(phone, msg)
        result.success(true)
      }
    }
  }
```

### Log Data

Use `Logger` from `logger` package:

```dart
import 'package:logger/logger.dart';
import 'lib/core/services/service_locator.dart';

final logger = getIt<Logger>();

logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
logger.d('Debug message');
```

### Handle Errors

```dart
try {
  await _alertRepository.triggerEmergencyAlert();
  _error = null;
} catch (e) {
  _error = 'Failed to trigger SOS: $e';
  logger.e(_error);
}
notifyListeners();
```

### Request Permissions

```dart
// Location
final permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) {
  // Show error
}

// SMS (Android native - in MainActivity.kt)
ActivityCompat.requestPermissions(this, arrayOf(SEND_SMS), REQUEST_CODE)

// Microphone
final hasPermission = await _audioRecorder.hasPermission();
if (!hasPermission) {
  // Show error
}
```

---

## Key Patterns

### Error Handling
```dart
try {
  final result = await _repository.doSomething();
  _data = result;
  _error = null;
} catch (e) {
  _error = e.toString();
}
notifyListeners();
```

### Loading State
```dart
_isLoading = true;
notifyListeners();
// ... do work ...
_isLoading = false;
notifyListeners();
```

### Stream Data
```dart
Stream<List<Location>> getLocationStream() {
  return _firestore
      .collection('locations')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Location.fromJson(doc.data())).toList());
}

// In widget
StreamBuilder<List<Location>>(
  stream: provider.getLocationStream(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    return ListView(children: snapshot.data!.map((loc) => Text(loc.toString())).toList());
  },
)
```

### Form Validation
```dart
TextField(
  controller: _phoneController,
  decoration: InputDecoration(
    labelText: 'Phone',
    errorText: _error,
  ),
)

void _submit() {
  final phone = _phoneController.text.trim();
  if (phone.isEmpty) {
    setState(() => _error = 'Phone required');
    return;
  }
  // Valid, proceed
}
```

---

## Common Files to Edit

### Adding a Firestore collection:
1. `lib/features/*/data/datasources/firebase_*.dart` — Add collection read/write
2. `lib/features/*/data/models/*.dart` — Add serialization (fromJson/toJson)
3. `lib/features/*/domain/entities/*.dart` — Add entity
4. `lib/features/*/domain/repositories/*.dart` — Add interface
5. `lib/features/*/data/repositories/*_impl.dart` — Add implementation

### Adding a screen:
1. `lib/features/*/presentation/screens/*.dart` — Add screen
2. `lib/features/*/presentation/providers/*.dart` — Add state (if needed)
3. `lib/main.dart` — Add GoRoute

### Adding a native feature:
1. `android/app/src/main/kotlin/.../*.kt` — Android implementation
2. `android/app/src/main/AndroidManifest.xml` — Add permissions
3. `lib/features/*/services/*.dart` — Method channel wrapper
4. `lib/core/services/service_locator.dart` — Register service

---

## Testing Locally

### Run on Emulator
```bash
# List emulators
flutter emulators

# Launch emulator
flutter emulators launch Pixel_6_API_34

# Run app
flutter run
```

### Run on Physical Device
```bash
# Connect device via USB, enable USB debugging
flutter devices
flutter run -d <device-id>
```

### Check Logs
```bash
# Flutter logs
flutter logs

# Android Logcat
adb logcat | grep flutter

# Firebase logs
adb shell dumpsys package com.example.emergency_alert
```

### Debug Mode
```bash
# Hot reload (Ctrl+R)
# Hot restart (Ctrl+Shift+R)
# Full restart (Q to quit, then run again)
```

---

## Git Workflow

### Branch Naming
- Feature: `feature/contacts-management`
- Bug fix: `fix/sms-not-sending`
- Docs: `docs/setup-guide`

### Commit Messages
```
[FEATURE] Add contact management screen
[BUGFIX] Fix location permission handling
[DOCS] Update setup guide
[REFACTOR] Reorganize auth provider
```

### Before Committing
```bash
flutter analyze  # Check linting
flutter test     # Run tests (if configured)
flutter format . # Format code
```

---

## Dependencies Reference

| Package | Purpose | Version |
|---------|---------|---------|
| `firebase_core` | Firebase SDK | ^5.4.0 |
| `firebase_auth` | Phone auth | ^6.0.0 |
| `cloud_firestore` | Database | ^6.0.0 |
| `firebase_messaging` | Push notifications | ^14.0.0 |
| `provider` | State management | ^7.1.0 |
| `get_it` | Dependency injection | ^7.8.0 |
| `geolocator` | Location tracking | ^12.1.0 |
| `google_maps_flutter` | Maps display | ^3.0.0 |
| `record` | Audio recording | ^5.1.0 |
| `workmanager` | Background tasks | ^0.5.0 |
| `permission_handler` | Permissions | ^11.4.0 |
| `logger` | Logging | ^2.3.0 |
| `go_router` | Navigation | ^14.0.0 |
| `uuid` | ID generation | ^4.1.0 |
| `path_provider` | File paths | ^2.1.0 |

Add new dependencies:
```bash
flutter pub add package_name
```

---

## Useful Links

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **Dart Packages**: https://pub.dev
- **Provider Package**: https://pub.dev/packages/provider
- **GetIt**: https://pub.dev/packages/get_it
- **GoRouter**: https://pub.dev/packages/go_router

---

## FAQ

**Q: Where do I add new routes?**
A: `lib/main.dart` in the `_buildRouter()` method.

**Q: How do I access current user?**
A: `context.read<AuthProvider>().currentUser`

**Q: How do I update Firestore?**
A: Use datasource in repository: `await datasource.updateDocument(...)`

**Q: Where are Firebase permissions set?**
A: `android/app/src/main/AndroidManifest.xml`

**Q: How do I test on a real device?**
A: Connect via USB, `adb devices`, then `flutter run -d <device-id>`

**Q: How do I debug native Android code?**
A: Use `adb logcat` or Android Studio debugger.

---

## Quick Checklist Before Demo

- [ ] Phone login works
- [ ] SOS button triggers alert
- [ ] Alert appears in Firestore
- [ ] Location updates to Firestore (if Phase 4 complete)
- [ ] Audio recording starts (if Phase 6 complete)
- [ ] Contacts display properly (if Phase 2 complete)
- [ ] No console errors
- [ ] App doesn't crash on permission denial
- [ ] Firebase is configured correctly

---

**Happy coding! 🚀**
