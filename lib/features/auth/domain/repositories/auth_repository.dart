import '../entities/user.dart';

abstract class AuthRepository {
  /// Send OTP to phone number and return verification ID
  Future<String> sendOtp(String phoneNumber);

  /// Verify OTP and sign in user
  Future<User> verifyOtp(String verificationId, String otp);

  /// Get currently authenticated user
  Future<User?> getCurrentUser();

  /// Sign out current user
  Future<void> signOut();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Create user profile in Firestore
  Future<void> createUserProfile(User user);

  /// Update user profile
  Future<void> updateUserProfile(User user);
}
