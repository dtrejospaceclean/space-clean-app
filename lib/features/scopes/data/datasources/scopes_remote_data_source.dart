import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/scope.dart';
import '../models/scope_model.dart';

/// Talks to `/clients/:clientId/scopes`. Throws `ApiException`.
class ScopesRemoteDataSource {
  const ScopesRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/scopes';

  static Scope _one(Object? data) =>
      ScopeModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Scope>> getScopes(String clientId, {String? contractId}) async =>
      (await fetchAllPages(
        _api,
        _path(clientId),
        query: {'contractId': ?contractId},
      )).map(ScopeModel.fromJson).toList();

  Future<Scope> getScope(String clientId, String scopeId) async =>
      _one(await _api.get('${_path(clientId)}/$scopeId'));

  Future<Scope> createScope(String clientId, ScopeDraft draft) async => _one(
    await _api.post(
      _path(clientId),
      body: ScopeDraftModel.toJson(draft, create: true),
    ),
  );

  Future<Scope> updateScope(
    String clientId,
    String scopeId,
    ScopeDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$scopeId',
      body: ScopeDraftModel.toJson(draft, create: false),
    ),
  );

  /// Returns no data.
  Future<void> deleteScope(String clientId, String scopeId) =>
      _api.delete('${_path(clientId)}/$scopeId');
}
