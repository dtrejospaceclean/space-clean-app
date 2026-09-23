import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/password_policy.dart';
import '../controllers/password_reset_controller.dart';
import '../widgets/reset_step_page.dart';
import '../widgets/code_input.dart';
import 'new_password_screen.dart';

/// Step 2 of 3: the 6-digit code from the email.
class ResetCodeScreen extends ConsumerStatefulWidget {
  const ResetCodeScreen({super.key});

  static const path = '/login/forgot/code';

  @override
  ConsumerState<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends ConsumerState<ResetCodeScreen> {
  final _codeController = TextEditingController();
  Timer? _ticker;
  bool _submitting = false;
  bool _resending = false;
  bool _resent = false;
  String? _codeError;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    // Repaints the resend countdown.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text;
    setState(() {
      _failure = null;
      _codeError = code.length == PasswordPolicy.codeLength
          ? null
          : l10n.codeIncomplete;
    });
    if (_codeError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(passwordResetControllerProvider.notifier).verifyCode(code);
      if (mounted) context.push(NewPasswordScreen.path);
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() {
        if (f case ValidationFailure(:final fieldErrors)
            when fieldErrors['code']?.isNotEmpty ?? false) {
          _codeError = l10n.fieldError(fieldErrors['code']!.first);
        } else {
          _failure = f;
        }
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _resent = false;
      _failure = null;
    });
    try {
      await ref.read(passwordResetControllerProvider.notifier).resendCode();
      _codeController.clear();
      if (mounted) setState(() => _resent = true);
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(passwordResetControllerProvider);
    final wait = draft.resendWait(DateTime.now());
    final failure = _failure;

    return ResetStepPage(
      title: l10n.codeTitle,
      intro: l10n.codeIntro(draft.email),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null)
            Notice(message: l10n.failureMessage(failure))
          else if (_resent)
            Notice(message: l10n.codeResent, tone: NoticeTone.info),
          if (failure != null || _resent) const SizedBox(height: 12),
          CodeInput(
            controller: _codeController,
            label: l10n.codeLabel,
            length: PasswordPolicy.codeLength,
            enabled: !_submitting,
            errorText: _codeError,
            onCompleted: (_) => _submit(),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l10n.continueButton,
            busy: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: 8),
          Center(
            child: LinkButton(
              label: wait > Duration.zero
                  ? l10n.resendIn('${wait.inSeconds + 1}')
                  : l10n.resendCode,
              onPressed: wait > Duration.zero || _resending || _submitting
                  ? null
                  : _resend,
            ),
          ),
        ],
      ),
    );
  }
}
