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
import 'reset_done_screen.dart';

/// Step 3 of 3: the new password, with its rules checked as you type.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  static const path = '/login/forgot/password';

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _confirmFocus = FocusNode();
  bool _obscure = true;
  bool _submitting = false;
  Failure? _failure;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool get _longEnough =>
      _passwordController.text.length >= PasswordPolicy.minLength;

  bool get _matches =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text == _passwordController.text;

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
          .resetPassword(_passwordController.text);
      TextInput.finishAutofillContext();
      if (mounted) context.go(ResetDoneScreen.path);
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
    final passwordError = switch (failure) {
      ValidationFailure(:final fieldErrors) =>
        switch (fieldErrors['newPassword'] ?? fieldErrors['password']) {
          final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
          _ => null,
        },
      _ => null,
    };
    final toggle = IconButton(
      tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
      iconSize: 26,
      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
    );

    return ResetStepPage(
      title: l10n.newPasswordTitle,
      intro: l10n.newPasswordIntro,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure != null && failure is! ValidationFailure) ...[
                Notice(message: l10n.failureMessage(failure)),
                const SizedBox(height: 12),
              ],
              SpaceTextField(
                label: l10n.newPasswordLabel,
                controller: _passwordController,
                enabled: !_submitting,
                autofocus: true,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                errorText: passwordError,
                suffix: toggle,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                validator: (value) =>
                    (value ?? '').length < PasswordPolicy.minLength
                    ? l10n.validationMinLength('${PasswordPolicy.minLength}')
                    : null,
              ),
              const SizedBox(height: 8),
              SpaceTextField(
                label: l10n.confirmPasswordLabel,
                controller: _confirmController,
                focusNode: _confirmFocus,
                enabled: !_submitting,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => value != _passwordController.text
                    ? l10n.passwordsDontMatch
                    : null,
              ),
              const SizedBox(height: 16),
              _Rule(
                met: _longEnough,
                label: l10n.ruleMinLength('${PasswordPolicy.minLength}'),
              ),
              _Rule(met: _matches, label: l10n.ruleMatch),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.savePasswordButton,
                busy: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A password rule. Met and unmet differ by icon shape, not only color.
class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icon = met
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked;

    return Semantics(
      label: '$label: ${met ? l10n.ruleMet : l10n.ruleNotMet}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                icon,
                key: ValueKey(met),
                size: 24,
                color: met ? context.colors.success : context.colors.inkSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: met ? FontWeight.w700 : FontWeight.w500,
                  color: met ? context.colors.ink : context.colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
