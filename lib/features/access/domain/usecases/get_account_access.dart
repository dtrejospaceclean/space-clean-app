import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/account_access.dart';
import '../repositories/access_repository.dart';

class AccountAccessParams {
  const AccountAccessParams({required this.clientId, required this.user});

  final String clientId;
  final User user;
}

/// The user's effective permissions on one account. Global owners skip the
/// membership check entirely, as the API does.
class GetAccountAccess implements UseCase<AccountAccess, AccountAccessParams> {
  const GetAccountAccess(this._repository);

  final AccessRepository _repository;

  @override
  Future<AccountAccess> call(AccountAccessParams params) async {
    if (params.user.hasRole(GlobalRole.owner)) {
      return AccountAccess.owner(params.clientId);
    }
    try {
      return await _repository.getMembership(
            clientId: params.clientId,
            userId: params.user.id,
          ) ??
          AccountAccess.none(params.clientId);
    } on ServerFailure catch (e) {
      if (e.statusCode != 403) rethrow;
      // Reading a membership needs team.view, which crew and client members
      // lack. The account came from their own list, so they are a member:
      // fall back to their role's documented defaults.
      return _fromRoleDefaults(params);
    }
  }

  AccountAccess _fromRoleDefaults(AccountAccessParams params) {
    for (final role in const ['supervisor', 'crew', 'client']) {
      if (params.user.hasRole(role)) {
        return AccountAccess(
          clientId: params.clientId,
          baseRole: role,
          permissions: Permissions.roleDefaults[role]!,
          estimated: true,
        );
      }
    }
    return AccountAccess.none(params.clientId);
  }
}
