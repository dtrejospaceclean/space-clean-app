import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Returns the user of a stored session, or `null` when there is no valid one.
class RestoreSession implements UseCase<User?, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<User?> call(NoParams params) async {
    if (!await _repository.hasSession()) return null;
    try {
      return await _repository.getCurrentUser();
    } on UnauthorizedFailure {
      // The token refresh already failed; drop what's left of the session.
      await _repository.logout();
      return null;
    }
  }
}
