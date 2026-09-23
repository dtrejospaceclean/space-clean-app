import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Synchronous: prefills the sign-in form on its first frame.
class GetRememberedEmail {
  const GetRememberedEmail(this._repository);

  final AuthRepository _repository;

  String? call() => _repository.rememberedEmail;
}

/// "Not you?": clears the prefilled email on a shared phone.
class ForgetRememberedEmail implements UseCase<void, NoParams> {
  const ForgetRememberedEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.forgetRememberedEmail();
}
