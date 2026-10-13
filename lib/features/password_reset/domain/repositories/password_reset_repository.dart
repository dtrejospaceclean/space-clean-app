import '../entities/password_policy.dart';

/// Reset by a 6-digit code sent by email. Every method throws a `Failure`.
abstract interface class PasswordResetRepository {
  /// Emails a code to [email] if it has an account, the whole email in
  /// [language] (`en` or `es`). Succeeds either way, so nobody can learn
  /// which emails exist.
  Future<void> requestCode(String email, {required String language});

  /// Trades the code for a [ResetToken]. A wrong, expired or used-up code
  /// (5 tries) is `auth.invalid_pin`.
  Future<ResetToken> verifyCode({required String email, required String code});

  /// Sets the new password once per token (`auth.invalid_reset_token`
  /// otherwise) and signs out every other session. It doesn't sign in.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
