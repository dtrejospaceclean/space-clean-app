import '../../../../core/error/failures.dart';
import '../../domain/repositories/password_reset_repository.dart';

/// The backend has no reset endpoints yet, so every step reports the feature
/// as unavailable. Replace with a remote data source once the API contract
/// (paths, bodies, error keys, code expiry) is defined; don't guess it.
class PasswordResetRepositoryImpl implements PasswordResetRepository {
  const PasswordResetRepositoryImpl();

  @override
  Future<void> requestCode(String email) async =>
      throw const UnavailableFailure();

  @override
  Future<void> verifyCode({
    required String email,
    required String code,
  }) async => throw const UnavailableFailure();

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async => throw const UnavailableFailure();
}
