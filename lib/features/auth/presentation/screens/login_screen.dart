/*
THESIS: A clean white door into work. The full-color logo carries the brand;
the form is oversized and plain so every role, crew included, gets in fast.
(Revised at the user's request: the ground was brand orange #C2410C; it is now
white in light mode. Dark mode keeps the ember ground.)
OWN-WORLD: white ground (ember #431407 in dark mode); the full-color planet mark
and wordmark (white knockout on ember); 64-dp fields with a stone #78716C
outline and 18-sp ink; a logo-navy #0A4781 full-width 60-dp action; brand
orange #C2410C for text links; red errors and tinted notice panels; native
controls per OS.
STORY: Any role (owner through crew or client) recognizes Space Clean, sees
their email already filled in, types a password, taps the one navy button, and
lands on their own day.
FIRST VIEWPORT: EN/ES switch top right; logo and the real tagline centered in
the upper free space; "Sign in" heading, email with "Not you?", password with a
show toggle, the navy button in the thumb zone, "Forgot password?" under it.
FORM: grounded list #4 (brand drench), seed key cc5b039b.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/threshold/brand_block.dart';
import '../../../../core/widgets/threshold/threshold_buttons.dart';
import '../../../../core/widgets/threshold/threshold_field.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
import '../../../../core/widgets/threshold/threshold_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../password_reset/presentation/screens/forgot_password_screen.dart';
import '../../../settings/presentation/widgets/language_switch.dart';
import '../../di/auth_providers.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.prefillEmail});

  static const path = '/login';

  /// Email handed over by another flow (password reset), preferred over the
  /// remembered one.
  final String? prefillEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late bool _hasRememberedEmail;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _dismissedExpiryNotice = false;
  Failure? _failure;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    final email = widget.prefillEmail ?? ref.read(getRememberedEmailProvider)();
    _emailController = TextEditingController(text: email);
    _hasRememberedEmail = email != null && email.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _failure = null;
      _dismissedExpiryNotice = true;
    });
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    TextInput.finishAutofillContext();
    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // The router redirects away once the auth state flips.
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _notYou() async {
    await ref.read(forgetRememberedEmailProvider)(const NoParams());
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _hasRememberedEmail = false;
      _failure = null;
    });
    _emailFocus.requestFocus();
  }

  String? _serverFieldError(AppLocalizations l10n, String field) =>
      switch (_failure) {
        ValidationFailure(:final fieldErrors) => switch (fieldErrors[field]) {
          final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
          _ => null,
        },
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final cupertino = useCupertino(context);
    final sessionExpired = switch (ref.watch(authControllerProvider).value) {
      Unauthenticated(:final sessionExpired) => sessionExpired,
      _ => false,
    };
    final notice = switch (_failure) {
      null || ValidationFailure() =>
        sessionExpired && !_dismissedExpiryNotice
            ? ThresholdNotice(
                message: l10n.authSessionExpired,
                tone: NoticeTone.info,
              )
            : null,
      final failure => ThresholdNotice(message: l10n.failureMessage(failure)),
    };

    return ThresholdScaffold(
      trailing: const LanguageSwitch(),
      centerHeader: true,
      header: BrandBlock(
        tagline: l10n.brandTagline,
        compact: keyboardOpen,
        condensed: notice != null,
      ),
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThresholdHeading(title: l10n.loginTitle),
              if (notice != null) ...[const SizedBox(height: 16), notice],
              const SizedBox(height: 12),
              ThresholdField(
                label: l10n.emailLabel,
                controller: _emailController,
                focusNode: _emailFocus,
                enabled: !_submitting,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                errorText: _serverFieldError(l10n, 'email'),
                labelAction: _hasRememberedEmail
                    ? ThresholdLinkButton(
                        label: l10n.notYou,
                        compact: true,
                        onPressed: _submitting ? null : _notYou,
                      )
                    : null,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return l10n.validationRequired;
                  if (!_emailPattern.hasMatch(email)) {
                    return l10n.validationInvalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ThresholdField(
                label: l10n.passwordLabel,
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !_submitting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                errorText: _serverFieldError(l10n, 'password'),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) =>
                    (value ?? '').isEmpty ? l10n.validationRequired : null,
                suffix: IconButton(
                  tooltip: _obscurePassword
                      ? l10n.showPassword
                      : l10n.hidePassword,
                  iconSize: 26,
                  constraints: const BoxConstraints.tightFor(
                    width: 56,
                    height: 56,
                  ),
                  icon: Icon(switch ((cupertino, _obscurePassword)) {
                    (true, true) => CupertinoIcons.eye,
                    (true, false) => CupertinoIcons.eye_slash,
                    (false, true) => Icons.visibility_outlined,
                    (false, false) => Icons.visibility_off_outlined,
                  }),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 28),
              ThresholdButton(
                label: l10n.signInButton,
                busy: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              Center(
                child: ThresholdLinkButton(
                  label: l10n.forgotPassword,
                  onPressed: _submitting
                      ? null
                      : () => context.push(
                          Uri(
                            path: ForgotPasswordScreen.path,
                            queryParameters: {
                              if (_emailController.text.trim().isNotEmpty)
                                'email': _emailController.text.trim(),
                            },
                          ).toString(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
