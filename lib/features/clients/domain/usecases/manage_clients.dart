import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

/// Staff-wide account actions, gated by the global role. Editing one
/// account is a per-account permission (`info.edit`) instead.
abstract final class AccountAdminPolicy {
  static bool canCreate(User user) =>
      user.hasAnyRole(const [GlobalRole.owner, GlobalRole.accountManager]);

  static bool canDelete(User user) => user.hasRole(GlobalRole.owner);

  /// Global owners see every account, so they can open one they just made.
  /// Anyone else needs a membership first.
  static bool seesAllAccounts(User user) => user.hasRole(GlobalRole.owner);
}

class GetClient implements UseCase<Client, String> {
  const GetClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Client> call(String id) => _repository.getClient(id);
}

class CreateClient implements UseCase<Client, ClientDraft> {
  const CreateClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Client> call(ClientDraft draft) => _repository.createClient(draft);
}

class UpdateClientParams {
  const UpdateClientParams({required this.id, required this.draft});

  final String id;
  final ClientDraft draft;
}

class UpdateClient implements UseCase<Client, UpdateClientParams> {
  const UpdateClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Client> call(UpdateClientParams params) =>
      _repository.updateClient(params.id, params.draft);
}

class DeleteClient implements UseCase<void, String> {
  const DeleteClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteClient(id);
}
