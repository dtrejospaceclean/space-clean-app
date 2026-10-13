import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../di/password_reset_providers.dart';
import '../../domain/entities/password_policy.dart';
import '../../domain/usecases/password_reset_usecases.dart';

/// What the reset flow has collected so far, carried across its screens.
class PasswordResetDraft {
  const PasswordResetDraft({
    this.email = '',
    this.language = 'es',
    this.codeSentAt,
    this.token,
  });

  final String email;

  /// What the code email was written in; a resend uses it again.
  final String language;
  final DateTime? codeSentAt;

  /// From a verified code; spent by the new password.
  final ResetToken? token;

  /// Time left before another code may be requested.
  Duration resendWait(DateTime now) {
    final sentAt = codeSentAt;
    if (sentAt == null) return Duration.zero;
    final left = PasswordPolicy.resendCooldown - now.difference(sentAt);
    return left.isNegative ? Duration.zero : left;
  }
}

final passwordResetControllerProvider =
    NotifierProvider<PasswordResetController, PasswordResetDraft>(
      PasswordResetController.new,
    );

/// Each step throws a `Failure` to its screen.
class PasswordResetController extends Notifier<PasswordResetDraft> {
  /// Injectable clock for tests.
  DateTime Function() now = DateTime.now;

  @override
  PasswordResetDraft build() => const PasswordResetDraft();

  /// Sends a code, which replaces any earlier one (and its token). The
  /// email is in [language], the app's (`en` or `es`).
  Future<void> requestCode(String email, {required String language}) async {
    final normalized = email.trim().toLowerCase();
    await ref.read(requestResetCodeProvider)(
      RequestResetCodeParams(email: normalized, language: language),
    );
    state = PasswordResetDraft(
      email: normalized,
      language: language,
      codeSentAt: now(),
    );
  }

  Future<void> resendCode() =>
      requestCode(state.email, language: state.language);

  Future<void> verifyCode(String code) async {
    final token = await ref.read(verifyResetCodeProvider)(
      VerifyResetCodeParams(email: state.email, code: code),
    );
    state = PasswordResetDraft(
      email: state.email,
      language: state.language,
      codeSentAt: state.codeSentAt,
      token: token,
    );
  }

  /// Sets the password with the token from [verifyCode]; the server checks
  /// its 15 minutes. Without one it's refused the same way.
  Future<void> resetPassword(String newPassword) async {
    final token = state.token;
    if (token == null) {
      throw const ServerFailure('auth.invalid_reset_token', statusCode: 400);
    }
    await ref.read(resetPasswordProvider)(
      ResetPasswordParams(resetToken: token.token, newPassword: newPassword),
    );
  }
}
