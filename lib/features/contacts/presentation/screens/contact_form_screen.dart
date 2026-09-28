import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/contacts_providers.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/contact_usecases.dart';
import '../controllers/contacts_providers.dart';
import '../../../../core/widgets/us_phone.dart';

/// Add a contact to an account ([contactId] null) or edit one. Both need
/// `info.edit` on the account.
class ContactFormScreen extends ConsumerWidget {
  const ContactFormScreen({super.key, required this.clientId, this.contactId});

  final String clientId;
  final String? contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = contactId;
    if (id == null) {
      return _ContactForm(clientId: clientId, title: l10n.newContactTitle);
    }
    // Wait for the contact before building fields.
    return switch (ref.watch(contactProvider((clientId, id)))) {
      AsyncData(value: final contact) => _ContactForm(
        key: ValueKey(id),
        clientId: clientId,
        title: l10n.editContact,
        initial: contact,
      ),
      final other => SpacePage(
        title: l10n.editContact,
        slivers: [
          AsyncSlivers<Contact>(
            value: other,
            onRetry: () => ref.invalidate(contactsProvider(clientId)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

/// The two per-account roles a contact can hold.
enum _Flag { primary, billing }

class _ContactForm extends ConsumerStatefulWidget {
  const _ContactForm({
    super.key,
    required this.clientId,
    required this.title,
    this.initial,
  });

  final String clientId;
  final String title;
  final Contact? initial;

  @override
  ConsumerState<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<_ContactForm> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(
    text: widget.initial?.firstName,
  );
  late final _lastName = TextEditingController(text: widget.initial?.lastName);
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _email = TextEditingController(text: widget.initial?.email);
  late final _phone = TextEditingController(
    text: UsPhone.format(widget.initial?.phone),
  );
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late final _flags = <_Flag>{
    if (widget.initial?.isPrimary ?? false) _Flag.primary,
    if (widget.initial?.isBillingContact ?? false) _Flag.billing,
  };

  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _title, _email, _phone, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) => (value) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return local?.call(value ?? '');
  };

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(saveContactProvider)(
        SaveContactParams(
          clientId: widget.clientId,
          contactId: widget.initial?.id,
          draft: ContactDraft(
            firstName: _firstName.text,
            lastName: _lastName.text,
            title: _title.text,
            email: _email.text,
            phone: _phone.text,
            notes: _notes.text,
            isPrimary: _flags.contains(_Flag.primary),
            isBillingContact: _flags.contains(_Flag.billing),
          ),
        ),
      );
      // Flags may have moved off other contacts, so reload them all.
      ref.invalidate(contactsProvider(widget.clientId));
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

  Widget _text(
    String label,
    TextEditingController controller,
    String field, {
    String? hint,
    TextCapitalization capitalization = TextCapitalization.words,
    TextInputType? keyboardType,
    TextInputAction action = TextInputAction.next,
    int? maxLines = 1,
    bool phone = false,
    String? Function(String value)? validate,
  }) => SpaceTextField(
    label: label,
    controller: controller,
    enabled: !_saving,
    hint: hint,
    textCapitalization: capitalization,
    keyboardType: keyboardType,
    textInputAction: action,
    maxLines: maxLines,
    phone: phone,
    validator: _validator(field, validate),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    String? required(String v) =>
        v.trim().isEmpty ? l10n.validationRequired : null;

    return SpacePage(
      title: widget.title,
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
            label: l10n.saveButton,
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
                // Field-level failures show on their fields; the rest on top.
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
                FormSection(l10n.sectionPerson, [
                  _text(
                    l10n.firstNameLabel,
                    _firstName,
                    'firstName',
                    validate: required,
                  ),
                  _text(
                    l10n.lastNameLabel,
                    _lastName,
                    'lastName',
                    validate: required,
                  ),
                  _text(
                    l10n.jobTitleLabel,
                    _title,
                    'title',
                    hint: l10n.jobTitleHint,
                    capitalization: TextCapitalization.sentences,
                  ),
                  _text(
                    l10n.notesLabel,
                    _notes,
                    'notes',
                    hint: l10n.contactNotesHint,
                    capitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    action: TextInputAction.newline,
                    maxLines: null,
                  ),
                ]),
                FormSection(l10n.sectionContact, [
                  _text(
                    l10n.emailLabel,
                    _email,
                    'email',
                    hint: l10n.emailHint,
                    capitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
                    validate: (v) =>
                        v.trim().isNotEmpty && !_emailPattern.hasMatch(v.trim())
                        ? l10n.validationInvalidEmail
                        : null,
                  ),
                  _text(l10n.phoneLabel, _phone, 'phone', phone: true),
                ]),
                FormSection(l10n.contactRoleLabel, [
                  ChoicePills<_Flag>(
                    options: {
                      _Flag.primary: l10n.primaryContactTag,
                      _Flag.billing: l10n.billingContactTag,
                    },
                    selected: _flags,
                    onToggle: _saving
                        ? null
                        : (flag) => setState(
                            () => _flags.contains(flag)
                                ? _flags.remove(flag)
                                : _flags.add(flag),
                          ),
                  ),
                ], footer: l10n.contactRoleHelp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
