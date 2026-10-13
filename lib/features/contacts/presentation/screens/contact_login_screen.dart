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
import '../../di/contacts_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/contact_usecases.dart';
import '../controllers/contacts_providers.dart';

/// An owner gives a contact a login: a client user with the contact's email
/// and name, a member of this account with the `client` role. The owner
/// sets the first password and shares it privately.
class ContactLoginScreen extends ConsumerWidget {
  const ContactLoginScreen({
    super.key,
    required this.clientId,
    required this.contactId,
  });

  final String clientId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(contactProvider((clientId, contactId)))) {
      AsyncValue(value: final contact?) => _LoginForm(contact: contact),
      final other => SpacePage(
        title: l10n.giveLogin,
        slivers: [
          AsyncSlivers<Contact>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(contactsProvider(clientId)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm({required this.contact});

  final Contact contact;

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    final contact = widget.contact;
    try {
      final login = await ref.read(createContactLoginProvider)(
        CreateContactLoginParams(
          contact: ContactRef(
            clientId: contact.clientId,
            contactId: contact.id,
          ),
          password: _password.text,
        ),
      );
      ref.invalidate(contactsProvider(contact.clientId));
      if (!mounted) return;
      setState(() => _saving = false);
      await _showCreated(login);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      // Re-run validators so server field errors appear on their fields.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showCreated(ContactLogin login) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.loginCreatedTitle),
        content: Text(l10n.loginCreatedBody(login.email)),
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
    final contact = widget.contact;
    final minLength = '${PasswordPolicy.minLength}';

    return SpacePage(
      title: l10n.giveLogin,
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
            label: l10n.giveLogin,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Field-level failures show on their field; the rest on top.
                if (failure != null && failure is! ValidationFailure)
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
                  PickerField(
                    label: l10n.emailLabel,
                    icon: Icons.mail_outline_rounded,
                    value: contact.email,
                    // Taken from the contact; edit the contact to change it.
                    onTap: null,
                  ),
                  SpaceTextField(
                    label: l10n.initialPasswordLabel,
                    controller: _password,
                    enabled: !_saving,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    helper: l10n.passwordHelpCreate,
                    suffix: IconButton(
                      tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    onFieldSubmitted: (_) => _save(),
                    validator: (v) {
                      if (_failure case ValidationFailure(:final fieldErrors)) {
                        if (fieldErrors['password'] case final errors?
                            when errors.isNotEmpty) {
                          return l10n.fieldError(errors.first);
                        }
                      }
                      return (v ?? '').length < PasswordPolicy.minLength
                          ? l10n.validationMinLength(minLength)
                          : null;
                    },
                  ),
                ], footer: l10n.giveLoginFootnote(contact.fullName)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
