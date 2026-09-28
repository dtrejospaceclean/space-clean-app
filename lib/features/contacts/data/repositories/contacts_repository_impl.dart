import '../../../../core/network/api_exception.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_remote_data_source.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl(this._remote);

  final ContactsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Contact>> getContacts(String clientId) =>
      _guard(() => _remote.getContacts(clientId));

  @override
  Future<Contact> createContact(String clientId, ContactDraft draft) =>
      _guard(() => _remote.createContact(clientId, draft));

  @override
  Future<Contact> updateContact(
    String clientId,
    String contactId,
    ContactDraft draft,
  ) => _guard(() => _remote.updateContact(clientId, contactId, draft));

  @override
  Future<void> deleteContact(String clientId, String contactId) =>
      _guard(() => _remote.deleteContact(clientId, contactId));

  @override
  Future<ContactLogin> createLogin(
    String clientId,
    String contactId,
    String password,
  ) => _guard(() => _remote.createLogin(clientId, contactId, password));
}
