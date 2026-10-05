import '../../../../core/network/api_exception.dart';
import '../../domain/entities/scope.dart';
import '../../domain/repositories/scopes_repository.dart';
import '../datasources/scopes_remote_data_source.dart';

class ScopesRepositoryImpl implements ScopesRepository {
  const ScopesRepositoryImpl(this._remote);

  final ScopesRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Scope>> getScopes(String clientId, {String? contractId}) =>
      _guard(() => _remote.getScopes(clientId, contractId: contractId));

  @override
  Future<Scope> getScope(String clientId, String scopeId) =>
      _guard(() => _remote.getScope(clientId, scopeId));

  @override
  Future<Scope> createScope(String clientId, ScopeDraft draft) =>
      _guard(() => _remote.createScope(clientId, draft));

  @override
  Future<Scope> updateScope(
    String clientId,
    String scopeId,
    ScopeDraft draft,
  ) => _guard(() => _remote.updateScope(clientId, scopeId, draft));

  @override
  Future<void> deleteScope(String clientId, String scopeId) =>
      _guard(() => _remote.deleteScope(clientId, scopeId));
}
