import '../entities/alert.dart';

abstract class AlertRepository {
  /// Trigger emergency alert - core SOS function
  /// Sends SMS offline, creates Firestore alert, starts recording
  Future<Alert> triggerEmergencyAlert({
    required TriggerType triggerType,
  });

  /// Resolve/cancel an active alert
  Future<void> resolveAlert(String alertId);

  /// Get alert history for current user
  Future<List<Alert>> getAlertHistory({int limit = 50});

  /// Get active alert (if any)
  Future<Alert?> getActiveAlert();

  /// Update alert with location
  Future<void> updateAlertLocation(String alertId, double latitude, double longitude);

  /// Update alert with audio recording URL
  Future<void> updateAlertAudioUrl(String alertId, String audioUrl);

  /// Get alert details
  Future<Alert?> getAlert(String alertId);

  /// Notify emergency contacts via SMS (synchronous - works offline)
  Future<void> notifyEmergencyContacts(Alert alert);
}
