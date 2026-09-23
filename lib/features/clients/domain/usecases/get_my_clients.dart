import '../../../../core/usecase/usecase.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

/// The user's accounts, alphabetical by the name people use.
class GetMyClients implements UseCase<List<Client>, NoParams> {
  const GetMyClients(this._repository);

  final ClientsRepository _repository;

  @override
  Future<List<Client>> call(NoParams params) async {
    final clients = await _repository.getMyClients();
    return [...clients]..sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
  }
}
