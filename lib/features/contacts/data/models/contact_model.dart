import '../../../contacts/domain/entities/contact.dart';

class ContactModel extends Contact {
  ContactModel({
    required String id,
    required String name,
    required String phoneNumber,
    String? relation,
    int priority = 3,
    required DateTime addedAt,
  }) : super(
    id: id,
    name: name,
    phoneNumber: phoneNumber,
    relation: relation,
    priority: priority,
    addedAt: addedAt,
  );

  factory ContactModel.fromEntity(Contact contact) {
    return ContactModel(
      id: contact.id,
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      relation: contact.relation,
      priority: contact.priority,
      addedAt: contact.addedAt,
    );
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      relation: json['relation'],
      priority: json['priority'] ?? 3,
      addedAt: json['addedAt'] is DateTime
          ? json['addedAt']
          : DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relation': relation,
      'priority': priority,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
