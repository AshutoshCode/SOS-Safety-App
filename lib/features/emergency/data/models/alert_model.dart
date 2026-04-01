import '../../../emergency/domain/entities/alert.dart';

class AlertModel extends Alert {
  AlertModel({
    required String id,
    required AlertStatus status,
    required TriggerType triggerType,
    required DateTime createdAt,
    DateTime? resolvedAt,
    List<String> contactsNotified = const [],
    String? audioRecordingUrl,
    double? lastLatitude,
    double? lastLongitude,
  }) : super(
    id: id,
    status: status,
    triggerType: triggerType,
    createdAt: createdAt,
    resolvedAt: resolvedAt,
    contactsNotified: contactsNotified,
    audioRecordingUrl: audioRecordingUrl,
    lastLatitude: lastLatitude,
    lastLongitude: lastLongitude,
  );

  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      status: alert.status,
      triggerType: alert.triggerType,
      createdAt: alert.createdAt,
      resolvedAt: alert.resolvedAt,
      contactsNotified: alert.contactsNotified,
      audioRecordingUrl: alert.audioRecordingUrl,
      lastLatitude: alert.lastLatitude,
      lastLongitude: alert.lastLongitude,
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      status: AlertStatus.values.firstWhere(
        (s) => s.toString() == 'AlertStatus.${json['status']}',
        orElse: () => AlertStatus.active,
      ),
      triggerType: TriggerType.values.firstWhere(
        (t) => t.toString() == 'TriggerType.${json['triggerType']}',
        orElse: () => TriggerType.sos,
      ),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.parse(json['createdAt'] ?? ''),
      resolvedAt: json['resolvedAt'] != null
          ? (json['resolvedAt'] is DateTime
          ? json['resolvedAt']
          : DateTime.parse(json['resolvedAt']))
          : null,
      contactsNotified: List<String>.from(json['contactsNotified'] ?? []),
      audioRecordingUrl: json['audioRecordingUrl'],
      lastLatitude: (json['lastLatitude'] as num?)?.toDouble(),
      lastLongitude: (json['lastLongitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toString().split('.').last,
      'triggerType': triggerType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'contactsNotified': contactsNotified,
      'audioRecordingUrl': audioRecordingUrl,
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
    };
  }
}
