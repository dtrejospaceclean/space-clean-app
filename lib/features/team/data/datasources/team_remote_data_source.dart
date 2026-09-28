import '../../../../core/network/api_client.dart';
import '../../domain/entities/member.dart';
import '../models/member_model.dart';

/// Talks to `/clients/:clientId/members` and `/permissions`. Throws
/// `ApiException`.
class TeamRemoteDataSource {
  const TeamRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/members';

  /// Not paginated: the whole team comes back at once.
  Future<List<Member>> getMembers(String clientId) async =>
      ((await _api.get(_path(clientId)))! as List)
          .map((e) => MemberModel.fromJson(_map(e)))
          .toList();

  Future<PermissionCatalog> getCatalog() async =>
      PermissionCatalogModel.fromJson(_map(await _api.get('/permissions')));

  Future<Member> setMember(
    String clientId, {
    required String userId,
    required String baseRole,
  }) async => MemberModel.fromJson(
    _map(
      await _api.post(
        _path(clientId),
        body: {'userId': userId, 'baseRole': baseRole},
      ),
    ),
  );

  Future<Member> setOverrides(
    String clientId,
    String userId,
    Map<String, bool> overrides,
  ) async => MemberModel.fromJson(
    _map(
      await _api.put(
        '${_path(clientId)}/$userId/permissions',
        body: {'permissions': overrides},
      ),
    ),
  );

  Future<void> removeMember(String clientId, String userId) async =>
      _api.delete('${_path(clientId)}/$userId');

  static Map<String, dynamic> _map(Object? data) =>
      (data! as Map).cast<String, dynamic>();
}
