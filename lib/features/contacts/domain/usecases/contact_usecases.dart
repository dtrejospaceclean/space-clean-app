import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/contact.dart';
import '../repositories/contacts_repository.dart';

/// Handing out logins is staff-wide, gated by the global role. Everything
/// else on contacts is a per-account permission (`info.view`/`info.edit`).
abstract final class ContactLoginPolicy {
  static bool canCreate(User user) => user.hasRole(GlobalRole.owner);
}

class GetContacts implements UseCase<List<Contact>, String> {
  const GetContacts(this._repository);

  final ContactsRepository _repository;

  @override
  Future<List<Contact>> call(String clientId) =>
      _repository.getContacts(clientId);
}

class SaveContactParams {
  const SaveContactParams({
    required this.clientId,
    this.contactId,
    required this.draft,
  });

  final String clientId;

  /// Null to create a contact.
  final String? contactId;
  final ContactDraft draft;
}

class SaveContact implements UseCase<Contact, SaveContactParams> {
  const SaveContact(this._repository);

  final ContactsRepository _repository;

  @override
  Future<Contact> call(SaveContactParams params) => switch (params.contactId) {
    null => _repository.createContact(params.clientId, params.draft),
    final id => _repository.updateContact(params.clientId, id, params.draft),
  };
}

class ContactRef {
  const ContactRef({required this.clientId, required this.contactId});

  final String clientId;
  final String contactId;
}

class DeleteContact implements UseCase<void, ContactRef> {
  const DeleteContact(this._repository);

  final ContactsRepository _repository;

  @override
  Future<void> call(ContactRef params) =>
      _repository.deleteContact(params.clientId, params.contactId);
}

class CreateContactLoginParams {
  const CreateContactLoginParams({
    required this.contact,
    required this.password,
  });

  final ContactRef contact;
  final String password;
}

class CreateContactLogin
    implements UseCase<ContactLogin, CreateContactLoginParams> {
  const CreateContactLogin(this._repository);

  final ContactsRepository _repository;

  @override
  Future<ContactLogin> call(CreateContactLoginParams params) =>
      _repository.createLogin(
        params.contact.clientId,
        params.contact.contactId,
        params.password,
      );
}
