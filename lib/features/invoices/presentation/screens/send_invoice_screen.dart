import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/presentation/widgets/send_by_email_page.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import 'invoices_screen.dart';

/// Emails the invoice's PDF ([SendByEmailPage]). Billing contacts, else the
/// primary one, start picked, like the server's default. Needs
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

  final String clientId;
  final String invoiceId;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, invoiceId);
    return switch (ref.watch(invoiceProvider(key))) {
      AsyncValue(value: final invoice?) => SendByEmailPage(
        key: ValueKey(invoiceId),
        clientId: clientId,
        summary: ListCard(children: [InvoiceRow(invoice: invoice)]),
        defaults: _defaults,
        send: (to, language) => ref.read(sendInvoiceProvider)(
          SendInvoiceParams(
            clientId: clientId,
            invoiceId: invoiceId,
            to: to,
            language: language,
          ),
        ),
      ),
      final other => SpacePage(
        title: l10n.sendByEmail,
        slivers: [
          AsyncSlivers<Invoice>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(invoiceProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}
