import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  /// Send OTP to phone number
  Future<String> sendOtp(String phoneNumber) async {
    late String verificationId;

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-complete for some devices
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('OTP verification failed: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
      timeout: const Duration(minutes: 2),
    );

    return verificationId;
  }

  /// Verify OTP and sign in
  Future<UserModel> verifyOtp(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      return UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        firstName: user.displayName?.split(' ').first,
        lastName: user.displayName?.split(' ').skip(1).join(' '),
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('OTP verification failed: ${e.message}');
    }
  }

  /// Get currently authenticated user
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      firstName: user.displayName?.split(' ').first,
      lastName: user.displayName?.split(' ').skip(1).join(' '),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Check if authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phoneNumber': user.phoneNumber,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'createdAt': Timestamp.now(),
        'settings': {
          'enableLocationTracking': true,
          'enableAudioRecording': true,
          'smsAlertEnabled': true,
        }
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user profile: ${e.message}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': user.firstName,
        'lastName': user.lastName,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    }
  }
}
