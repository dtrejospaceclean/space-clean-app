import '../../../../core/network/api_exception.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_data_source.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  const ClientsRepositoryImpl(this._remote);

  final ClientsRemoteDataSource _remote;

  @override
  Future<List<Client>> getMyClients() async {
    try {
      return await _remote.getClients();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
