import '../entities/contact.dart';

abstract class ContactsRepository {
  /// Get all emergency contacts for current user
  Future<List<Contact>> getEmergencyContacts();

  /// Add a contact
  Future<Contact> addContact(Contact contact);

  /// Update a contact
  Future<void> updateContact(Contact contact);

  /// Delete a contact
  Future<void> deleteContact(String contactId);

  /// Set emergency contact status
  Future<void> setEmergencyContact(String contactId, bool isEmergency);

  /// Get emergency contact IDs
  Future<List<String>> getEmergencyContactIds();

  /// Sync local contacts to Firebase
  Future<void> syncLocalContacts(List<Contact> contacts);
}
