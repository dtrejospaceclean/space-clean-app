import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/client.dart';
import '../models/client_model.dart';

/// Talks to `/clients`. Throws `ApiException`.
class ClientsRemoteDataSource {
  const ClientsRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Client>> getClients({String search = ''}) async =>
      (await fetchAllPages(
        _api,
        '/clients',
        query: {if (search.isNotEmpty) 'search': search},
      )).map(ClientModel.fromJson).toList();

  Future<Client> getClient(String id) async =>
      ClientModel.fromJson(_map(await _api.get('/clients/$id')));

  Future<Client> createClient(ClientDraft draft) async => ClientModel.fromJson(
    _map(
      await _api.post(
        '/clients',
        body: ClientDraftModel.toJson(draft, create: true),
      ),
    ),
  );

  Future<Client> updateClient(String id, ClientDraft draft) async =>
      ClientModel.fromJson(
        _map(
          await _api.patch(
            '/clients/$id',
            body: ClientDraftModel.toJson(draft, create: false),
          ),
        ),
      );

  Future<void> deleteClient(String id) async => _api.delete('/clients/$id');

  static Map<String, dynamic> _map(Object? data) =>
      (data! as Map).cast<String, dynamic>();
}
