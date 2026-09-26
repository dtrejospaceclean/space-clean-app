import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/account_access.dart';
import '../../domain/repositories/access_repository.dart';

/// Reads `GET /clients/:clientId/members/me`, which every member may call.
class AccessRepositoryImpl implements AccessRepository {
  const AccessRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<AccountAccess?> getMyMembership(String clientId) async {
    try {
      final data =
          await _api.get('/clients/$clientId/members/me') as Map? ?? {};
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
      // A non-member gets 403.
      if (e.key == 'auth.insufficient_permission') return null;
      throw e.toFailure();
    }
  }
}
