/// Rules the new password and reset code must satisfy.
abstract final class PasswordPolicy {
  /// Matches the API's rule for user passwords (`POST /users`).
  static const minLength = 12;

  static const codeLength = 6;

  /// Client-side guard against resend spam. The backend's own limit is still undecided.
  static const resendCooldown = Duration(seconds: 60);
}
