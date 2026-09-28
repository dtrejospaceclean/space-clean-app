import '../entities/member.dart';

/// Every method throws a `Failure` on error.
abstract interface class TeamRepository {
  /// An account's members by name. Needs `team.view`.
  Future<List<Member>> getMembers(String clientId);

  /// Any signed-in user.
  Future<PermissionCatalog> getCatalog();

  /// Adds [userId] to the account, or changes an existing member's base
  /// role (their overrides stay). Global `owner` only; the user must be
  /// active (`members.user_not_active`).
  Future<Member> setMember(
    String clientId, {
    required String userId,
    required String baseRole,
  });

  /// Replaces the member's overrides; `{}` goes back to the role's
  /// defaults. Global `owner` only.
  Future<Member> setOverrides(
    String clientId,
    String userId,
    Map<String, bool> overrides,
  );

  /// Global `owner` only.
  Future<void> removeMember(String clientId, String userId);
}
