import '../../../../core/usecase/usecase.dart';
import '../entities/password_policy.dart';
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

class VerifyResetCode implements UseCase<ResetToken, VerifyResetCodeParams> {
  const VerifyResetCode(this._repository);

  final PasswordResetRepository _repository;

  @override
  Future<ResetToken> call(VerifyResetCodeParams params) =>
      _repository.verifyCode(email: params.email, code: params.code.trim());
}

class ResetPasswordParams {
  const ResetPasswordParams({
    required this.resetToken,
    required this.newPassword,
  });

  final String resetToken;
  final String newPassword;
}

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final PasswordResetRepository _repository;

  @override
  Future<void> call(ResetPasswordParams params) => _repository.resetPassword(
    resetToken: params.resetToken,
    newPassword: params.newPassword,
  );
}
