import '../../../../core/network/api_exception.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_data_source.dart';

class TeamRepositoryImpl implements TeamRepository {
  const TeamRepositoryImpl(this._remote);

  final TeamRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Member>> getMembers(String clientId) =>
      _guard(() => _remote.getMembers(clientId));

  @override
  Future<PermissionCatalog> getCatalog() => _guard(_remote.getCatalog);

  @override
  Future<Member> setMember(
    String clientId, {
    required String userId,
    required String baseRole,
  }) => _guard(
    () => _remote.setMember(clientId, userId: userId, baseRole: baseRole),
  );

  @override
  Future<Member> setOverrides(
    String clientId,
    String userId,
    Map<String, bool> overrides,
  ) => _guard(() => _remote.setOverrides(clientId, userId, overrides));

  @override
  Future<void> removeMember(String clientId, String userId) =>
      _guard(() => _remote.removeMember(clientId, userId));
}
