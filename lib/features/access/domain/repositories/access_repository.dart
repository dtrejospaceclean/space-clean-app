import '../entities/account_access.dart';

/// Throws a `Failure` on error.
abstract interface class AccessRepository {
  /// The membership of [userId] on [clientId], or `null` when not a member.
  /// Throws `ServerFailure` 403 when the user may not read memberships
  /// (`team.view`), which crew and client members can't by default.
  Future<AccountAccess?> getMembership({
    required String clientId,
    required String userId,
  });
}
