import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/client.dart';
import '../models/client_model.dart';

/// Talks to `/clients`. Throws `ApiException`.
class ClientsRemoteDataSource {
  const ClientsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Client>> getClients() async => (await fetchAllPages(
    _api,
    '/clients',
  )).map(ClientModel.fromJson).toList();
}
