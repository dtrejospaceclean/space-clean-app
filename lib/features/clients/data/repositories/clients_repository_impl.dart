import '../../../../core/network/api_exception.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_data_source.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  const ClientsRepositoryImpl(this._remote);

  final ClientsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Client>> getMyClients({String search = ''}) =>
      _guard(() => _remote.getClients(search: search));

  @override
  Future<Client> getClient(String id) => _guard(() => _remote.getClient(id));

  @override
  Future<Client> createClient(ClientDraft draft) =>
      _guard(() => _remote.createClient(draft));

  @override
  Future<Client> updateClient(String id, ClientDraft draft) =>
      _guard(() => _remote.updateClient(id, draft));

  @override
  Future<void> deleteClient(String id) =>
      _guard(() => _remote.deleteClient(id));
}
