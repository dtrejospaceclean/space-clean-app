import '../entities/contact.dart';

/// Every method throws a `Failure` on error.
abstract interface class ContactsRepository {
  /// An account's contacts, primary first. Needs `info.view`.
  Future<List<Contact>> getContacts(String clientId);

  /// Needs `info.edit`.
  Future<Contact> createContact(String clientId, ContactDraft draft);

  /// Needs `info.edit`.
  Future<Contact> updateContact(
    String clientId,
    String contactId,
    ContactDraft draft,
  );

  /// Needs `info.edit`. A login the contact had stays.
  Future<void> deleteContact(String clientId, String contactId);

  /// Global `owner` only. Creates a client user from the contact's email and
  /// name and makes it a member of the account (`client_contacts.email_required`,
  /// `client_contacts.login_exists`, `users.email_taken` otherwise).
  Future<ContactLogin> createLogin(
    String clientId,
    String contactId,
    String password,
  );
}
