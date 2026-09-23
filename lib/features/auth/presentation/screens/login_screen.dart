// Visual reference for the whole app: docs/example_app.png (gray ground,
// white rounded cards, big bold titles, black round and pill actions),
// in Space Clean's colors. See DESIGN.md.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../password_reset/presentation/screens/forgot_password_screen.dart';
import '../../../settings/presentation/widgets/language_toggle.dart';
import '../../di/auth_providers.dart';
import '../controllers/auth_controller.dart';

/// Sign-in: logo, two-tone headline, and the form in one white card.
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
    final sessionExpired = switch (ref.watch(authControllerProvider).value) {
      Unauthenticated(:final sessionExpired) => sessionExpired,
      _ => false,
    };
    final notice = switch (_failure) {
      null || ValidationFailure() =>
        sessionExpired && !_dismissedExpiryNotice
            ? Notice(message: l10n.authSessionExpired, tone: NoticeTone.info)
            : null,
      final failure => Notice(message: l10n.failureMessage(failure)),
    };

    return SpacePage(
      showBack: false,
      actions: const [LanguageToggle(compact: true)],
      slivers: [
        PageBox(
          top: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/brand/space_clean_logo.svg',
                height: 72,
                semanticsLabel: 'Space Clean',
              ),
              const SizedBox(height: 24),
              HeroHeadline(
                primary: l10n.loginTitle,
                secondary: l10n.brandTagline,
              ),
            ],
          ),
        ),
        PageBox(
          top: 24,
          child: SpaceCard(
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (notice != null) ...[notice, const SizedBox(height: 12)],
                    SpaceTextField(
                      label: l10n.emailLabel,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      enabled: !_submitting,
                      hint: l10n.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      errorText: _serverFieldError(l10n, 'email'),
                      labelAction: _hasRememberedEmail
                          ? LinkButton(
                              label: l10n.notYou,
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
                    const SizedBox(height: 12),
                    SpaceTextField(
                      label: l10n.passwordLabel,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      enabled: !_submitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      errorText: _serverFieldError(l10n, 'password'),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => (value ?? '').isEmpty
                          ? l10n.validationRequired
                          : null,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: l10n.signInButton,
                      busy: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: LinkButton(
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
          ),
        ),
      ],
    );
  }
}
