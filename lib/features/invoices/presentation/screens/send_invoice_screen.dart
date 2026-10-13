import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/controllers/clients_providers.dart';
import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/presentation/controllers/contacts_providers.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import 'invoice_pdf_screen.dart';
import 'invoices_screen.dart';

/// Emails the invoice's PDF. Recipients are picked from the people in charge
/// of the account and its contacts (billing contacts, else the primary one,
/// start picked, like the server's default), plus any other address typed
/// in; up to 10. The email and the PDF are in the app's language. Needs
/// `invoice.edit`, for an issued, partly paid or paid invoice. Hands back
/// who it went to.
class SendInvoiceScreen extends ConsumerWidget {
  const SendInvoiceScreen({
    super.key,
    required this.clientId,
    required this.invoiceId,
  });

  /// Path segment under an invoice's page.
  static const route = 'send';

  /// The API's limit.
  static const maxRecipients = 10;

  final String clientId;
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, invoiceId);
    return switch (ref.watch(invoiceProvider(key))) {
      AsyncValue(value: final invoice?) => _SendForm(
        key: ValueKey(invoiceId),
        clientId: clientId,
        invoice: invoice,
      ),
      final other => SpacePage(
        title: l10n.sendInvoice,
        slivers: [
          AsyncSlivers<Invoice>(
            value: other,
            onRetry: () => ref.invalidate(invoiceProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

/// Someone the invoice can go to.
class _Recipient {
  const _Recipient({required this.email, required this.name, this.role});

  /// Lowercased.
  final String email;
  final String name;

  /// What they are to the account ("Account manager", "Billing contact").
  final String? role;
}

class _SendForm extends ConsumerStatefulWidget {
  const _SendForm({super.key, required this.clientId, required this.invoice});

  final String clientId;
  final Invoice invoice;

  @override
  ConsumerState<_SendForm> createState() => _SendFormState();
}

class _SendFormState extends ConsumerState<_SendForm> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _other = TextEditingController();

  /// Picked addresses, lowercased. Null until the defaults are set from the
  /// contacts, so they're set once.
  Set<String>? _picked;

  /// Addresses typed in, in the order added.
  final _typed = <String>[];
  String? _otherError;
  String? _notice;
  bool _sending = false;
  Failure? _failure;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  /// Billing contacts with an email, else the primary contact: what the
  /// server would pick on its own.
  static Set<String> _defaults(List<Contact> contacts) {
    final withEmail = [
      for (final c in contacts)
        if (c.email case final e? when e.trim().isNotEmpty) c,
    ];
    final billing = withEmail.where((c) => c.isBillingContact);
    final chosen = billing.isNotEmpty
        ? billing
        : withEmail.where((c) => c.isPrimary);
    return {for (final c in chosen) c.email!.trim().toLowerCase()};
  }

  Set<String> get _selected => _picked ?? const {};

  void _toggle(String email) => setState(() {
    _notice = null;
    final picked = {..._selected};
    if (!picked.remove(email)) picked.add(email);
    _picked = picked;
  });

  void _addOther() {
    final l10n = AppLocalizations.of(context);
    final email = _other.text.trim().toLowerCase();
    setState(() {
      _notice = null;
      if (email.isEmpty) {
        _otherError = null;
      } else if (!_emailPattern.hasMatch(email)) {
        _otherError = l10n.validationInvalidEmail;
      } else {
        _otherError = null;
        if (!_typed.contains(email)) _typed.add(email);
        _picked = {..._selected, email};
        _other.clear();
      }
    });
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    // An address still in the field counts, as if Add was tapped.
    if (_other.text.trim().isNotEmpty) {
      _addOther();
      if (_otherError != null) {
        HapticFeedback.mediumImpact();
        return;
      }
    }
    final to = _selected.toList();
    final problem = switch (to.length) {
      0 => l10n.sendInvoiceNoRecipients,
      > SendInvoiceScreen.maxRecipients => l10n.sendInvoiceTooMany(
        SendInvoiceScreen.maxRecipients,
      ),
      _ => null,
    };
    if (problem != null) {
      HapticFeedback.mediumImpact();
      setState(() => _notice = problem);
      return;
    }
    setState(() {
      _sending = true;
      _failure = null;
      _notice = null;
    });
    try {
      final sentTo = await ref.read(sendInvoiceProvider)(
        SendInvoiceParams(
          clientId: widget.clientId,
          invoiceId: widget.invoice.id,
          to: to,
          language: documentLanguage(context),
        ),
      );
      if (!mounted) return;
      // The page holds back pops while sending; let this one through.
      setState(() => _sending = false);
      context.pop(sentTo);
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final failure = _failure;
    final problem = failure != null ? l10n.failureMessage(failure) : _notice;
    // Either list may be out of reach (no `info.view`); the other still
    // shows, and typed addresses always work.
    final client = ref.watch(clientDetailProvider(widget.clientId)).value;
    final contacts = ref.watch(contactsProvider(widget.clientId)).value;
    if (_picked == null && contacts != null) {
      // Set once, from the contacts, before anyone picks.
      _picked = _defaults(contacts);
    }

    final inCharge = <_Recipient>[
      for (final (role, person) in <(String, ClientAssignee?)>[
        (l10n.roleAccountManager, client?.accountManager),
        (l10n.roleSupervisor, client?.supervisor),
        (l10n.salespersonLabel, client?.salesperson),
      ])
        if (person?.email case final email? when email.trim().isNotEmpty)
          _Recipient(
            email: email.trim().toLowerCase(),
            name: person!.name,
            role: role,
          ),
    ];
    final contactRows = <_Recipient>[
      for (final c in contacts ?? const <Contact>[])
        if (c.email case final email? when email.trim().isNotEmpty)
          _Recipient(
            email: email.trim().toLowerCase(),
            name: c.fullName,
            role: c.isBillingContact
                ? l10n.billingContactTag
                : c.isPrimary
                ? l10n.primaryContactTag
                : null,
          ),
    ];
    // Someone listed twice (staff who is also a contact) shows once.
    final listed = {
      for (final r in [...inCharge, ...contactRows]) r.email,
    };
    final typed = [
      for (final e in _typed)
        if (!listed.contains(e)) e,
    ];

    Widget row(_Recipient r) => ChoiceRow(
      title: r.name.isEmpty ? r.email : r.name,
      subtitle: [?r.role, if (r.name.isNotEmpty) r.email].join(' · '),
      selected: _selected.contains(r.email),
      multiple: true,
      onSelect: () => _toggle(r.email),
    );

    return PopScope(
      canPop: !_sending,
      child: AbsorbPointer(
        absorbing: _sending,
        child: SpacePage(
          title: l10n.sendInvoice,
          bottom: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(side, 8, side, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Right above the button, so it's seen however far the
                  // list is scrolled.
                  if (problem != null) ...[
                    Notice(message: problem),
                    const SizedBox(height: 8),
                  ],
                  PrimaryButton(
                    label: _selected.isEmpty
                        ? l10n.sendInvoiceButton
                        : l10n.sendInvoiceTo(_selected.length),
                    icon: Icons.send_outlined,
                    busy: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
          slivers: [
            PageBox(
              top: 4,
              child: ListCard(children: [InvoiceRow(invoice: widget.invoice)]),
            ),
            if (inCharge.isNotEmpty) ...[
              PageBox(
                top: 16,
                child: SectionHeader(title: l10n.sectionPeopleInCharge),
              ),
              PageBox(
                top: 0,
                child: ListCard(children: [for (final r in inCharge) row(r)]),
              ),
            ],
            if (contactRows.isNotEmpty) ...[
              PageBox(
                top: 16,
                child: SectionHeader(title: l10n.moduleContacts),
              ),
              PageBox(
                top: 0,
                child: ListCard(
                  children: [
                    for (final r in contactRows)
                      if (!inCharge.any((p) => p.email == r.email)) row(r),
                  ],
                ),
              ),
            ],
            PageBox(
              top: 16,
              child: SectionHeader(title: l10n.sendInvoiceOtherEmails),
            ),
            if (typed.isNotEmpty)
              PageBox(
                top: 0,
                child: ListCard(
                  children: [
                    for (final e in typed) row(_Recipient(email: e, name: '')),
                  ],
                ),
              ),
            PageBox(
              top: typed.isEmpty ? 0 : 12,
              child: SpaceCard(
                child: SpaceTextField(
                  label: l10n.emailLabel,
                  controller: _other,
                  hint: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  errorText: _otherError,
                  onFieldSubmitted: (_) => _addOther(),
                  suffix: IconButton(
                    tooltip: l10n.sendInvoiceAddEmail,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addOther,
                  ),
                ),
              ),
            ),
            PageBox(
              top: 8,
              child: Text(
                l10n.sendInvoiceHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
