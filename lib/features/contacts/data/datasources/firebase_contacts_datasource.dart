import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';

class FirebaseContactsDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseContactsDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  String get _userId => _firebaseAuth.currentUser!.uid;

  /// Get all emergency contacts
  Future<List<ContactModel>> getEmergencyContacts() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts')
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContactModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch contacts: ${e.message}');
    }
  }

  /// Add a contact
  Future<ContactModel> addContact(ContactModel contact) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts')
          .add({
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'relation': contact.relation,
        'priority': contact.priority,
        'addedAt': Timestamp.now(),
      });

      return ContactModel(
        id: docRef.id,
        name: contact.name,
        phoneNumber: contact.phoneNumber,
        relation: contact.relation,
        priority: contact.priority,
        addedAt: contact.addedAt,
      );
    } on FirebaseException catch (e) {
      throw Exception('Failed to add contact: ${e.message}');
    }
  }

  /// Update a contact
  Future<void> updateContact(ContactModel contact) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts')
          .doc(contact.id)
          .update({
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'relation': contact.relation,
        'priority': contact.priority,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update contact: ${e.message}');
    }
  }

  /// Delete a contact
  Future<void> deleteContact(String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete contact: ${e.message}');
    }
  }

  /// Get emergency contact IDs (contacts with priority > 2)
  Future<List<String>> getEmergencyContactIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts')
          .where('priority', isGreaterThan: 2)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch emergency contacts: ${e.message}');
    }
  }

  /// Sync batch of contacts (for bulk import)
  Future<void> syncContactsBatch(List<ContactModel> contacts) async {
    try {
      final batch = _firestore.batch();
      final userContactsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('contacts');

      for (final contact in contacts) {
        batch.set(userContactsRef.doc(contact.id), {
          'name': contact.name,
          'phoneNumber': contact.phoneNumber,
          'relation': contact.relation,
          'priority': contact.priority,
          'addedAt': Timestamp.fromDate(contact.addedAt),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Failed to sync contacts: ${e.message}');
    }
  }
}
