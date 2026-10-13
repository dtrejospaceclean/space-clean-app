import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/password_reset_controller.dart';
import '../widgets/reset_step_page.dart';
import 'reset_code_screen.dart';

/// Step 1 of 3: the email to send the code to.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.prefillEmail});

  static const path = '/login/forgot';

  final String? prefillEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.prefillEmail,
  );
  bool _submitting = false;
  Failure? _failure;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(passwordResetControllerProvider.notifier)
          .requestCode(
            _emailController.text,
            // The email is written in the language the app is in.
            language: Localizations.localeOf(context).languageCode == 'en'
                ? 'en'
                : 'es',
          );
      if (mounted) context.push(ResetCodeScreen.path);
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final emailError = switch (failure) {
      ValidationFailure(:final fieldErrors) => switch (fieldErrors['email']) {
        final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
        _ => null,
      },
      _ => null,
    };

    return ResetStepPage(
      title: l10n.resetTitle,
      intro: l10n.resetEmailIntro,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (failure != null && failure is! ValidationFailure) ...[
              Notice(message: l10n.failureMessage(failure)),
              const SizedBox(height: 12),
            ],
            SpaceTextField(
              label: l10n.emailLabel,
              controller: _emailController,
              enabled: !_submitting,
              autofocus: widget.prefillEmail == null,
              hint: l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
              errorText: emailError,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return l10n.validationRequired;
                if (!_emailPattern.hasMatch(email)) {
                  return l10n.validationInvalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: l10n.sendCodeButton,
              busy: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
