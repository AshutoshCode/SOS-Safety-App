import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<String> sendOtp(String phoneNumber) {
    return dataSource.sendOtp(phoneNumber);
  }

  @override
  Future<User> verifyOtp(String verificationId, String otp) {
    return dataSource.verifyOtp(verificationId, otp);
  }

  @override
  Future<User?> getCurrentUser() {
    return dataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    return dataSource.isAuthenticated();
  }

  @override
  Future<void> createUserProfile(User user) {
    final userModel = UserModel.fromEntity(user);
    return dataSource.createUserProfile(userModel);
  }

  @override
  Future<void> updateUserProfile(User user) {
    final userModel = UserModel.fromEntity(user);
    return dataSource.updateUserProfile(userModel);
  }
}
