import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../password_reset/domain/entities/password_policy.dart';
import '../../di/profile_providers.dart';
import '../../domain/usecases/profile_usecases.dart';

/// The signed-in user changes their own password. They stay signed in:
/// tokens issued before the change keep working.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  static const path = '/me/password';

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  static const _wrongCurrent = 'auth.wrong_current_password';

  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    for (final c in [_current, _new, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A server-side error for [field], shown by that field's validator.
  String? _serverError(String field) {
    final l10n = AppLocalizations.of(context);
    return switch (_failure) {
      ValidationFailure(:final fieldErrors) => switch (fieldErrors[field]) {
        final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
        _ => null,
      },
      ServerFailure(messageKey: _wrongCurrent)
          when field == 'currentPassword' =>
        l10n.authWrongCurrentPassword,
      _ => null,
    };
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(changePasswordProvider)(
        ChangePasswordParams(
          currentPassword: _current.text,
          newPassword: _new.text,
        ),
      );
      TextInput.finishAutofillContext();
      if (!mounted) return;
      setState(() => _saving = false);
      await _showChanged();
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      // Re-run validators so server errors appear on their fields.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showChanged() {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.passwordChangedTitle),
        content: Text(l10n.passwordChangedBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    // Field-level failures show on their fields; everything else on top.
    final showBanner =
        failure != null &&
        failure is! ValidationFailure &&
        failure.messageKey != _wrongCurrent;
    final toggle = IconButton(
      tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscure = !_obscure),
    );
    final minLength = '${PasswordPolicy.minLength}';

    return SpacePage(
      title: l10n.changePasswordTitle,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            pageSide(context),
            8,
            pageSide(context),
            12,
          ),
          child: PrimaryButton(
            label: l10n.savePasswordButton,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBanner)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        pageSide(context),
                        4,
                        pageSide(context),
                        0,
                      ),
                      child: Notice(message: l10n.failureMessage(failure)),
                    ),
                  FormSection(l10n.sectionSignIn, [
                    SpaceTextField(
                      label: l10n.currentPasswordLabel,
                      controller: _current,
                      enabled: !_saving,
                      obscureText: _obscure,
                      suffix: toggle,
                      autofillHints: const [AutofillHints.password],
                      validator: (v) =>
                          _serverError('currentPassword') ??
                          ((v ?? '').isEmpty ? l10n.validationRequired : null),
                    ),
                    SpaceTextField(
                      label: l10n.newPasswordLabel,
                      controller: _new,
                      enabled: !_saving,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      helper: l10n.ruleMinLength(minLength),
                      validator: (v) =>
                          _serverError('newPassword') ??
                          ((v ?? '').length < PasswordPolicy.minLength
                              ? l10n.validationMinLength(minLength)
                              : null),
                    ),
                    SpaceTextField(
                      label: l10n.confirmPasswordLabel,
                      controller: _confirm,
                      enabled: !_saving,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _save(),
                      validator: (v) =>
                          v != _new.text ? l10n.passwordsDontMatch : null,
                    ),
                  ], footer: l10n.changePasswordFootnote),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
