class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? relation;
  final int priority; // 1-5
  final DateTime addedAt;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relation,
    this.priority = 3,
    required this.addedAt,
  });

  @override
  String toString() =>
      'Contact(id: $id, name: $name, phoneNumber: $phoneNumber, priority: $priority)';
}
