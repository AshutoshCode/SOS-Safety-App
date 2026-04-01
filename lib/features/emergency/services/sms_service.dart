import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../../../core/services/service_locator.dart';

class SmsService {
  static const platform = MethodChannel('com.example.emergency_alert/sms');
  final Logger _logger = getIt<Logger>();

  /// Send SMS via native Android SMS manager
  /// Works offline - SMS is queued by Android system
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'sendSms',
        {
          'phoneNumber': phoneNumber,
          'message': message,
        },
      );

      if (result == true) {
        _logger.i('SMS sent to $phoneNumber');
        return true;
      } else {
        _logger.w('Failed to send SMS to $phoneNumber');
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e('SMS error: ${e.message}');
      return false;
    }
  }

  /// Send SMS to multiple recipients
  Future<Map<String, bool>> sendSmsToMultiple({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <String, bool>{};

    for (final phoneNumber in phoneNumbers) {
      results[phoneNumber] = await sendSms(
        phoneNumber: phoneNumber,
        message: message,
      );
    }

    return results;
  }

  /// Check if SMS permission is granted
  Future<bool> hasSmsPermission() async {
    try {
      final result = await platform.invokeMethod<bool>('hasSmsPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request SMS permission
  Future<bool> requestSmsPermission() async {
    try {
      final result = await platform.invokeMethod<bool>('requestSmsPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
