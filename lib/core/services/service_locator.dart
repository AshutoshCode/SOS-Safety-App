import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features - Auth
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Features - Contacts
import '../../features/contacts/data/datasources/firebase_contacts_datasource.dart';
import '../../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../../features/contacts/domain/repositories/contacts_repository.dart';

// Features - Emergency
import '../../features/emergency/data/datasources/firebase_alert_datasource.dart';
import '../../features/emergency/data/datasources/firebase_location_datasource.dart';
import '../../features/emergency/data/repositories/alert_repository_impl.dart';
import '../../features/emergency/domain/repositories/alert_repository.dart';

// Services
import '../../features/emergency/services/location_service.dart';
import '../../features/emergency/services/audio_recorder_service.dart';
import '../../features/emergency/services/sms_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Singletons - Core
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // SharedPreferences - must be awaited at app startup
  // This is registered as a singleton after initialization
  _registerSharedPreferences();

  // Auth DataSources & Repositories
  getIt.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource(
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      dataSource: getIt<FirebaseAuthDataSource>(),
    ),
  );

  // Contacts DataSources & Repositories
  getIt.registerSingleton<FirebaseContactsDataSource>(
    FirebaseContactsDataSource(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerSingleton<ContactsRepository>(
    ContactsRepositoryImpl(
      dataSource: getIt<FirebaseContactsDataSource>(),
    ),
  );

  // Emergency Alert DataSources & Repositories
  getIt.registerSingleton<FirebaseAlertDataSource>(
    FirebaseAlertDataSource(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerSingleton<FirebaseLocationDataSource>(
    FirebaseLocationDataSource(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerSingleton<AlertRepository>(
    AlertRepositoryImpl(
      alertDataSource: getIt<FirebaseAlertDataSource>(),
      locationDataSource: getIt<FirebaseLocationDataSource>(),
      smsService: getIt<SmsService>(),
    ),
  );

  // Services
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<AudioRecorderService>(AudioRecorderService());
  getIt.registerSingleton<SmsService>(SmsService());

  getIt<Logger>().i('Service locator initialized');
}

void _registerSharedPreferences() {
  // This should be called after SharedPreferences.getInstance()
  // See app_initializer.dart for async initialization
}

Future<void> initializeSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
}
