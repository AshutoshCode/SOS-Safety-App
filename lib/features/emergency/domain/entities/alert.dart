enum AlertStatus { active, resolved, cancelled }

enum TriggerType { sos, fallDetection, customTrigger }

class Alert {
  final String id;
  final AlertStatus status;
  final TriggerType triggerType;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> contactsNotified;
  final String? audioRecordingUrl;
  final double? lastLatitude;
  final double? lastLongitude;

  Alert({
    required this.id,
    required this.status,
    required this.triggerType,
    required this.createdAt,
    this.resolvedAt,
    this.contactsNotified = const [],
    this.audioRecordingUrl,
    this.lastLatitude,
    this.lastLongitude,
  });

  @override
  String toString() =>
      'Alert(id: $id, status: $status, triggerType: $triggerType, createdAt: $createdAt)';
}
