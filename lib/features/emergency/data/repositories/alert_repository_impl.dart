import 'package:uuid/uuid.dart';
import '../datasources/firebase_alert_datasource.dart';
import '../datasources/firebase_location_datasource.dart';
import '../models/alert_model.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../contacts/domain/repositories/contacts_repository.dart';
import '../../services/sms_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/services/service_locator.dart';
import 'package:logger/logger.dart';

class AlertRepositoryImpl implements AlertRepository {
  final FirebaseAlertDataSource alertDataSource;
  final FirebaseLocationDataSource locationDataSource;
  final SmsService smsService;

  static const uuid = Uuid();
  final Logger _logger = getIt<Logger>();

  AlertRepositoryImpl({
    required this.alertDataSource,
    required this.locationDataSource,
    required this.smsService,
  });

  /// Core SOS function: Trigger emergency alert
  /// 1. Send SMS immediately (offline-capable)
  /// 2. Create alert in Firestore
  /// 3. Return Alert object for UI to start location tracking
  @override
  Future<Alert> triggerEmergencyAlert({
    required TriggerType triggerType,
  }) async {
    try {
      // Get current user
      final authRepo = getIt<AuthRepository>();
      final user = await authRepo.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      // Get emergency contacts
      final contactsRepo = getIt<ContactsRepository>();
      final contacts = await contactsRepo.getEmergencyContacts();

      if (contacts.isEmpty) {
        _logger.w('No emergency contacts configured');
      }

      // Send SMS immediately (works offline)
      await notifyEmergencyContacts(contacts, user.phoneNumber);

      // Create alert in Firestore (will sync when online)
      final alertModel = AlertModel(
        id: uuid.v4(),
        status: AlertStatus.active,
        triggerType: triggerType,
        createdAt: DateTime.now(),
        contactsNotified: contacts.map((c) => c.id).toList(),
      );

      final createdAlert = await alertDataSource.createAlert(alertModel);

      _logger.i('Emergency alert triggered: ${createdAlert.id}');
      return createdAlert;
    } catch (e) {
      _logger.e('Failed to trigger emergency alert: $e');
      rethrow;
    }
  }

  /// Notify emergency contacts via SMS
  Future<void> notifyEmergencyContacts(
    List<dynamic> contacts,
    String userPhoneNumber,
  ) async {
    try {
      final message = 'EMERGENCY ALERT! User $userPhoneNumber needs help. Please contact them immediately.';

      for (final contact in contacts) {
        final phoneNumber = contact.phoneNumber ?? '';
        if (phoneNumber.isNotEmpty) {
          await smsService.sendSms(
            phoneNumber: phoneNumber,
            message: message,
          );
        }
      }

      _logger.i('Notified ${contacts.length} contacts');
    } catch (e) {
      _logger.e('Failed to notify contacts: $e');
    }
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    try {
      await alertDataSource.updateAlertStatus(alertId, AlertStatus.resolved);
      _logger.i('Alert resolved: $alertId');
    } catch (e) {
      _logger.e('Failed to resolve alert: $e');
      rethrow;
    }
  }

  @override
  Future<List<Alert>> getAlertHistory({int limit = 50}) async {
    try {
      return await alertDataSource.getAlertHistory(limit: limit);
    } catch (e) {
      _logger.e('Failed to fetch alert history: $e');
      rethrow;
    }
  }

  @override
  Future<Alert?> getActiveAlert() async {
    try {
      return await alertDataSource.getActiveAlert();
    } catch (e) {
      _logger.e('Failed to fetch active alert: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAlertLocation(String alertId, double latitude, double longitude) async {
    try {
      await locationDataSource.writeLocation(alertId, latitude, longitude, 0);
      _logger.d('Location updated: $latitude, $longitude');
    } catch (e) {
      _logger.e('Failed to update location: $e');
    }
  }

  @override
  Future<void> updateAlertAudioUrl(String alertId, String audioUrl) async {
    try {
      await alertDataSource.updateAlertAudioUrl(alertId, audioUrl);
      _logger.i('Audio URL updated: $audioUrl');
    } catch (e) {
      _logger.e('Failed to update audio URL: $e');
      rethrow;
    }
  }

  @override
  Future<Alert?> getAlert(String alertId) async {
    try {
      return await alertDataSource.getAlert(alertId);
    } catch (e) {
      _logger.e('Failed to fetch alert: $e');
      rethrow;
    }
  }
}
