/// Reset by a 6-digit code sent by email. Every method throws a `Failure`.
abstract interface class PasswordResetRepository {
  /// Emails a code to [email].
  Future<void> requestCode(String email);

  /// Checks [code] before asking for a new password.
  Future<void> verifyCode({required String email, required String code});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
