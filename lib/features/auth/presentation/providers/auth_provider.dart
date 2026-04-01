import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final Logger _logger = getIt<Logger>();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _authRepository.getCurrentUser();

      if (_currentUser != null) {
        _logger.i('User loaded: ${_currentUser!.phoneNumber}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _verificationId = await _authRepository.sendOtp(phoneNumber);
      _logger.i('OTP sent to $phoneNumber');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send OTP: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_verificationId == null) {
        throw Exception('Verification ID not found');
      }

      _currentUser = await _authRepository.verifyOtp(_verificationId!, otp);

      // Create user profile in Firestore
      if (_currentUser != null) {
        await _authRepository.createUserProfile(_currentUser!);
        _logger.i('User profile created: ${_currentUser!.phoneNumber}');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to verify OTP: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.signOut();
      _currentUser = null;
      _verificationId = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
