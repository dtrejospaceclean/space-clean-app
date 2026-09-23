import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class Logout implements UseCase<void, NoParams> {
  const Logout(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.logout();
}
