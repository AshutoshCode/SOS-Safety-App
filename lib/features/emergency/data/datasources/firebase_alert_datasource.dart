import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert_model.dart';
import '../../domain/entities/alert.dart';

class FirebaseAlertDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseAlertDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  String get _userId => _firebaseAuth.currentUser!.uid;

  /// Create a new alert
  Future<AlertModel> createAlert(AlertModel alert) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .add({
        'status': alert.status.toString().split('.').last,
        'triggerType': alert.triggerType.toString().split('.').last,
        'createdAt': Timestamp.now(),
        'resolvedAt': null,
        'contactsNotified': [],
        'audioRecordingUrl': null,
        'lastGeopoint': null,
      });

      return AlertModel(
        id: docRef.id,
        status: alert.status,
        triggerType: alert.triggerType,
        createdAt: alert.createdAt,
        contactsNotified: [],
        audioRecordingUrl: null,
      );
    } on FirebaseException catch (e) {
      throw Exception('Failed to create alert: ${e.message}');
    }
  }

  /// Update alert status
  Future<void> updateAlertStatus(String alertId, AlertStatus status) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
      };

      if (status == AlertStatus.resolved) {
        updateData['resolvedAt'] = Timestamp.now();
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update alert: ${e.message}');
    }
  }

  /// Get alert history
  Future<List<AlertModel>> getAlertHistory({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AlertModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch alert history: ${e.message}');
    }
  }

  /// Get active alert
  Future<AlertModel?> getActiveAlert() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return AlertModel.fromJson({
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch active alert: ${e.message}');
    }
  }

  /// Update alert location
  Future<void> updateAlertLocation(String alertId, double latitude, double longitude) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .update({
        'lastGeopoint': GeoPoint(latitude, longitude),
        'lastLatitude': latitude,
        'lastLongitude': longitude,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update alert location: ${e.message}');
    }
  }

  /// Update alert with audio URL
  Future<void> updateAlertAudioUrl(String alertId, String audioUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .update({
        'audioRecordingUrl': audioUrl,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update audio URL: ${e.message}');
    }
  }

  /// Mark contacts as notified
  Future<void> markContactsNotified(String alertId, List<String> contactIds) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .update({
        'contactsNotified': contactIds,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update contacts notified: ${e.message}');
    }
  }

  /// Get alert by ID
  Future<AlertModel?> getAlert(String alertId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .get();

      if (!doc.exists) return null;

      return AlertModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch alert: ${e.message}');
    }
  }
}
