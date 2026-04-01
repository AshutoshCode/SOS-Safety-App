class User {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    required this.createdAt,
  });

  @override
  String toString() =>
      'User(uid: $uid, phoneNumber: $phoneNumber, firstName: $firstName, lastName: $lastName)';
}
