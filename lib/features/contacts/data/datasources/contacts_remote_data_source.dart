import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact.dart';
import '../models/contact_model.dart';

/// Talks to `/clients/:clientId/contacts`. Throws `ApiException`.
class ContactsRemoteDataSource {
  const ContactsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/contacts';

  /// Not paginated: the whole list comes back at once.
  Future<List<Contact>> getContacts(String clientId) async =>
      ((await _api.get(_path(clientId)))! as List)
          .map((e) => ContactModel.fromJson(_map(e)))
          .toList();

  Future<Contact> createContact(String clientId, ContactDraft draft) async =>
      ContactModel.fromJson(
        _map(
          await _api.post(
            _path(clientId),
            body: ContactDraftModel.toJson(draft, create: true),
          ),
        ),
      );

  Future<Contact> updateContact(
    String clientId,
    String contactId,
    ContactDraft draft,
  ) async => ContactModel.fromJson(
    _map(
      await _api.patch(
        '${_path(clientId)}/$contactId',
        body: ContactDraftModel.toJson(draft, create: false),
      ),
    ),
  );

  Future<void> deleteContact(String clientId, String contactId) async =>
      _api.delete('${_path(clientId)}/$contactId');

  Future<ContactLogin> createLogin(
    String clientId,
    String contactId,
    String password,
  ) async {
    final json = _map(
      await _api.post(
        '${_path(clientId)}/$contactId/login',
        body: {'password': password},
      ),
    );
    return ContactLogin(
      userId: json['userId'] as String,
      email: json['email'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _map(Object? data) =>
      (data! as Map).cast<String, dynamic>();
}
