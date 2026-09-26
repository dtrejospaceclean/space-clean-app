import '../entities/account_access.dart';

/// Throws a `Failure` on error.
abstract interface class AccessRepository {
  /// The signed-in user's own membership on [clientId], or `null` when they
  /// aren't a member.
  Future<AccountAccess?> getMyMembership(String clientId);
}
