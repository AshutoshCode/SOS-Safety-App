import '../../../auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String uid,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    required DateTime createdAt,
  }) : super(
    uid: uid,
    phoneNumber: phoneNumber,
    firstName: firstName,
    lastName: lastName,
    createdAt: createdAt,
  );

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      firstName: user.firstName,
      lastName: user.lastName,
      createdAt: user.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.parse(json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
