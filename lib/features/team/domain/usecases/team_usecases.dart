import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/member.dart';
import '../repositories/team_repository.dart';

/// Changing who works on an account, and what they may do there, is for
/// global owners (the API checks the global role, not `team.manage`).
/// Seeing the team needs `team.view` on the account.
abstract final class TeamPolicy {
  static bool canManage(User user) => user.hasRole(GlobalRole.owner);

  /// The base role that fits [roles] (a user's global roles) best: the most
  /// senior one that is also a base role, else [GlobalRole.client] for a
  /// client's own people and [GlobalRole.crew] for staff.
  static String suggestedRole(
    Iterable<String> roles,
    Iterable<String> baseRoles, {
    required bool external,
  }) {
    for (final role in baseRoles) {
      if (roles.contains(role)) return role;
    }
    return external ? GlobalRole.client : GlobalRole.crew;
  }
}

class GetMembers implements UseCase<List<Member>, String> {
  const GetMembers(this._repository);

  final TeamRepository _repository;

  @override
  Future<List<Member>> call(String clientId) =>
      _repository.getMembers(clientId);
}

class GetPermissionCatalog implements UseCase<PermissionCatalog, NoParams> {
  const GetPermissionCatalog(this._repository);

  final TeamRepository _repository;

  @override
  Future<PermissionCatalog> call(NoParams _) => _repository.getCatalog();
}

class AddMemberParams {
  const AddMemberParams({
    required this.clientId,
    required this.userId,
    required this.baseRole,
  });

  final String clientId;
  final String userId;
  final String baseRole;
}

class AddMember implements UseCase<Member, AddMemberParams> {
  const AddMember(this._repository);

  final TeamRepository _repository;

  @override
  Future<Member> call(AddMemberParams params) => _repository.setMember(
    params.clientId,
    userId: params.userId,
    baseRole: params.baseRole,
  );
}

class UpdateAccessParams {
  const UpdateAccessParams({
    required this.member,
    required this.catalog,
    required this.baseRole,
    required this.permissions,
  });

  final Member member;
  final PermissionCatalog catalog;
  final String baseRole;

  /// Every permission the member should have.
  final Set<String> permissions;
}

/// Saves a member's base role and permissions. The role goes first, and
/// only when it changed. The overrides are then worked out against the
/// (new) role's defaults and sent only when they differ from what's stored,
/// since the API keeps old overrides across a role change.
class UpdateMemberAccess implements UseCase<Member, UpdateAccessParams> {
  const UpdateMemberAccess(this._repository);

  final TeamRepository _repository;

  static bool _same(Map<String, bool> a, Map<String, bool> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  @override
  Future<Member> call(UpdateAccessParams params) async {
    var member = params.member;
    if (params.baseRole != member.baseRole) {
      member = await _repository.setMember(
        member.clientId,
        userId: member.userId,
        baseRole: params.baseRole,
      );
    }
    final overrides = params.catalog.overridesFor(
      params.baseRole,
      params.permissions,
    );
    if (!_same(overrides, member.overrides)) {
      member = await _repository.setOverrides(
        member.clientId,
        member.userId,
        overrides,
      );
    }
    return member;
  }
}

class MemberRef {
  const MemberRef({required this.clientId, required this.userId});

  final String clientId;
  final String userId;
}

class RemoveMember implements UseCase<void, MemberRef> {
  const RemoveMember(this._repository);

  final TeamRepository _repository;

  @override
  Future<void> call(MemberRef params) =>
      _repository.removeMember(params.clientId, params.userId);
}
