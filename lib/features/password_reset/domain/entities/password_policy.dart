/// Rules the new password and reset code must satisfy.
abstract final class PasswordPolicy {
  /// Matches the API's rule for user passwords (12–128 characters).
  static const minLength = 12;

  static const codeLength = 6;

  /// The API sends one code a minute per user and silently ignores more, so
  /// "Send a new code" waits this long.
  static const resendCooldown = Duration(seconds: 60);
}

/// What a verified code buys: one try at setting the new password, until
/// [expiresAt] (15 minutes).
class ResetToken {
  const ResetToken({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}
