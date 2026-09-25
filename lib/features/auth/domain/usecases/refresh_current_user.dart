import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Reloads the signed-in user (`/auth/me`), e.g. after they edited their
/// own profile.
class RefreshCurrentUser implements UseCase<User, NoParams> {
  const RefreshCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> call(NoParams params) => _repository.getCurrentUser();
}
