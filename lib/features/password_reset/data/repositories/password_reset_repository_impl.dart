import '../../../../core/network/api_exception.dart';
import '../../domain/entities/password_policy.dart';
import '../../domain/repositories/password_reset_repository.dart';
import '../datasources/password_reset_remote_data_source.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  const PasswordResetRepositoryImpl(this._remote);

  final PasswordResetRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<void> requestCode(String email, {required String language}) =>
      _guard(() => _remote.requestCode(email, language: language));

  @override
  Future<ResetToken> verifyCode({
    required String email,
    required String code,
  }) => _guard(() => _remote.verifyCode(email: email, code: code));

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _guard(
    () =>
        _remote.resetPassword(resetToken: resetToken, newPassword: newPassword),
  );
}
