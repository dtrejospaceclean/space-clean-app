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
    return await _repository.getMyMembership(params.clientId) ??
        AccountAccess.none(params.clientId);
  }
}
