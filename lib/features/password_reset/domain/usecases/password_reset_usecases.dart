import '../../../../core/usecase/usecase.dart';
import '../repositories/password_reset_repository.dart';

class RequestResetCode implements UseCase<void, String> {
  const RequestResetCode(this._repository);

  final PasswordResetRepository _repository;

  @override
  Future<void> call(String email) =>
      _repository.requestCode(email.trim().toLowerCase());
}

class VerifyResetCodeParams {
  const VerifyResetCodeParams({required this.email, required this.code});

  final String email;
  final String code;
}

class VerifyResetCode implements UseCase<void, VerifyResetCodeParams> {
  const VerifyResetCode(this._repository);

  final PasswordResetRepository _repository;

  @override
  Future<void> call(VerifyResetCodeParams params) =>
      _repository.verifyCode(email: params.email, code: params.code);
}

class ResetPasswordParams {
  const ResetPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;
}

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final PasswordResetRepository _repository;

  @override
  Future<void> call(ResetPasswordParams params) => _repository.resetPassword(
    email: params.email,
    code: params.code,
    newPassword: params.newPassword,
  );
}
