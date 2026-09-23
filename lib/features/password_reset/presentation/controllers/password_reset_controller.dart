import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/password_reset_providers.dart';
import '../../domain/entities/password_policy.dart';
import '../../domain/usecases/password_reset_usecases.dart';

/// What the reset flow has collected so far, carried across its screens.
class PasswordResetDraft {
  const PasswordResetDraft({this.email = '', this.code = '', this.codeSentAt});

  final String email;
  final String code;
  final DateTime? codeSentAt;

  /// Time left before another code may be requested.
  Duration resendWait(DateTime now) {
    final sentAt = codeSentAt;
    if (sentAt == null) return Duration.zero;
    final left = PasswordPolicy.resendCooldown - now.difference(sentAt);
    return left.isNegative ? Duration.zero : left;
  }

  PasswordResetDraft copyWith({
    String? email,
    String? code,
    DateTime? codeSentAt,
  }) => PasswordResetDraft(
    email: email ?? this.email,
    code: code ?? this.code,
    codeSentAt: codeSentAt ?? this.codeSentAt,
  );
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

  Future<void> requestCode(String email) async {
    final normalized = email.trim().toLowerCase();
    await ref.read(requestResetCodeProvider)(normalized);
    state = PasswordResetDraft(email: normalized, codeSentAt: now());
  }

  Future<void> resendCode() => requestCode(state.email);

  Future<void> verifyCode(String code) async {
    await ref.read(verifyResetCodeProvider)(
      VerifyResetCodeParams(email: state.email, code: code),
    );
    state = state.copyWith(code: code);
  }

  Future<void> resetPassword(String newPassword) =>
      ref.read(resetPasswordProvider)(
        ResetPasswordParams(
          email: state.email,
          code: state.code,
          newPassword: newPassword,
        ),
      );
}
