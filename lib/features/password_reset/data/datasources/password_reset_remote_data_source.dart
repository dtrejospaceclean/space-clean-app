import '../../../../core/network/api_client.dart';
import '../../domain/entities/password_policy.dart';

/// Talks to the public reset endpoints under `/auth`. Throws `ApiException`.
class PasswordResetRemoteDataSource {
  const PasswordResetRemoteDataSource(this._api);

  final ApiClient _api;

  Future<void> requestCode(String email) => _api.post(
    '/auth/forgot-password',
    body: {'email': email},
    authenticated: false,
  );

  Future<ResetToken> verifyCode({
    required String email,
    required String code,
  }) async {
    final data = await _api.post(
      '/auth/verify-pin',
      body: {'email': email, 'pin': code},
      authenticated: false,
    ) as Map;
    return ResetToken(
      token: data['resetToken'] as String,
      expiresAt:
          DateTime.tryParse('${data['expiresAt']}')?.toLocal() ??
          DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _api.post(
    '/auth/reset-password',
    body: {'resetToken': resetToken, 'newPassword': newPassword},
    authenticated: false,
  );
}
