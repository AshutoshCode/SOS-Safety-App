import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirebaseLocationDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  static const uuid = Uuid();

  FirebaseLocationDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  String get _userId => _firebaseAuth.currentUser!.uid;

  /// Write location to Firestore
  Future<void> writeLocation(
    String alertId,
    double latitude,
    double longitude,
    double accuracy,
  ) async {
    try {
      final locationId = uuid.v4();

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .collection('locations')
          .doc(locationId)
          .set({
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': Timestamp.now(),
      });

      // Also update parent alert with latest location
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
      throw Exception('Failed to write location: ${e.message}');
    }
  }

  /// Get location history for an alert
  Future<List<Map<String, dynamic>>> getLocationHistory(String alertId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('alerts')
          .doc(alertId)
          .collection('locations')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch location history: ${e.message}');
    }
  }

  /// Stream locations for an alert (real-time updates)
  Stream<List<Map<String, dynamic>>> streamLocations(String alertId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('alerts')
        .doc(alertId)
        .collection('locations')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
