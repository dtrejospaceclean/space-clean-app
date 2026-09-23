import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/account_access.dart';
import '../../domain/repositories/access_repository.dart';

/// Reads `GET /clients/:clientId/members/:userId`.
class AccessRepositoryImpl implements AccessRepository {
  const AccessRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<AccountAccess?> getMembership({
    required String clientId,
    required String userId,
  }) async {
    try {
      final data =
          await _api.get('/clients/$clientId/members/$userId') as Map? ?? {};
      final permissions = (data['permissions'] as Map? ?? {}).entries
          .where((e) => e.value == true)
          .map((e) => e.key as String)
          .toSet();
      return AccountAccess(
        clientId: clientId,
        baseRole: data['baseRole'] as String?,
        permissions: permissions,
      );
    } on ApiException catch (e) {
      if (e.key == 'members.not_found') return null;
      throw e.toFailure();
    }
  }
}
