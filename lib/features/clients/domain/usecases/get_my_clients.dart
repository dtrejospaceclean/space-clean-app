import '../../../../core/usecase/usecase.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

/// The user's accounts, alphabetical by the name people use.
class GetMyClients implements UseCase<List<Client>, NoParams> {
  const GetMyClients(this._repository);

  final ClientsRepository _repository;

  @override
  Future<List<Client>> call(NoParams params) async =>
      _byName(await _repository.getMyClients());
}

/// The user's accounts whose legal name, trade name or tax ID contains the
/// text (the server matches). Alphabetical, like [GetMyClients].
class SearchMyClients implements UseCase<List<Client>, String> {
  const SearchMyClients(this._repository);

  final ClientsRepository _repository;

  @override
  Future<List<Client>> call(String search) async =>
      _byName(await _repository.getMyClients(search: search.trim()));
}

List<Client> _byName(List<Client> clients) => [...clients]
  ..sort(
    (a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
  );
