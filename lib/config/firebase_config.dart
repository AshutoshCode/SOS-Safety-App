import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FirebaseConfig {
  static final logger = Logger();

  static Future<void> initialize() async {
    try {
      // Request notification permission
      await _requestNotificationPermissions();

      // Get FCM token for current device
      final token = await FirebaseMessaging.instance.getToken();
      logger.i('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        logger.i('Received message in foreground: ${message.messageId}');
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logger.i('App opened from message: ${message.messageId}');
      });

      logger.i('Firebase initialized successfully');
    } catch (e) {
      logger.e('Firebase initialization error: $e');
      rethrow;
    }
  }

  static Future<void> _requestNotificationPermissions() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carryForwardToken: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('Notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      logger.i('Provisional notification permission granted');
    } else {
      logger.w('Notification permission denied');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      logger.e('Error getting FCM token: $e');
      return null;
    }
  }
}
