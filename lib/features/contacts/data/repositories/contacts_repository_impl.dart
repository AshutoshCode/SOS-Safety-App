import '../datasources/firebase_contacts_datasource.dart';
import '../models/contact_model.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final FirebaseContactsDataSource dataSource;

  ContactsRepositoryImpl({required this.dataSource});

  @override
  Future<List<Contact>> getEmergencyContacts() {
    return dataSource.getEmergencyContacts();
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    final contactModel = ContactModel.fromEntity(contact);
    return dataSource.addContact(contactModel);
  }

  @override
  Future<void> updateContact(Contact contact) {
    final contactModel = ContactModel.fromEntity(contact);
    return dataSource.updateContact(contactModel);
  }

  @override
  Future<void> deleteContact(String contactId) {
    return dataSource.deleteContact(contactId);
  }

  @override
  Future<void> setEmergencyContact(String contactId, bool isEmergency) async {
    // Implementation depends on how emergency status is tracked
    // For now, update priority based on emergency status
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getEmergencyContactIds() {
    return dataSource.getEmergencyContactIds();
  }

  @override
  Future<void> syncLocalContacts(List<Contact> contacts) async {
    final contactModels = contacts
        .map((c) => ContactModel.fromEntity(c))
        .toList();
    return dataSource.syncContactsBatch(contactModels);
  }
}
