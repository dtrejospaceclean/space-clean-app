import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/document_language.dart';
import '../../../../core/widgets/pdf_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import 'send_invoice_screen.dart';

/// The invoice as the client gets it: the server's PDF, in the app's
/// language, to scroll and zoom. Needs `invoice.view`. With `invoice.edit`,
/// an issued invoice can be emailed from here too.
class InvoicePdfScreen extends ConsumerWidget {
  const InvoicePdfScreen({
    super.key,
    required this.clientId,
    required this.invoiceId,
  });

  /// Path segment under an invoice's page.
  static const route = 'pdf';

  final String clientId;
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final params = InvoicePdfParams(
      clientId: clientId,
      invoiceId: invoiceId,
      language: documentLanguage(context),
    );
    final pdf = ref.watch(invoicePdfProvider(params));
    final invoice = ref.watch(invoiceProvider((clientId, invoiceId))).value;
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.invoiceEdit) ??
        false;
    final number = invoice?.invoiceNumber;
    final here = GoRouterState.of(context).matchedLocation;
    final invoicePage = here.substring(0, here.lastIndexOf('/'));
    Future<void> refresh() => ref.refresh(invoicePdfProvider(params).future);

    return SpacePage(
      title: number ?? l10n.invoicePdfTitle,
      actions: [
        if (canEdit && (invoice?.canSend ?? false))
          CircleButton.light(
            icon: Icons.send_outlined,
            tooltip: l10n.sendByEmail,
            onPressed: () =>
                context.push('$invoicePage/${SendInvoiceScreen.route}'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: pdf,
          skeleton: SkeletonLayout.detail,
          onRetry: refresh,
          builder: (bytes) => SliverFillRemaining(
            hasScrollBody: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              // The viewer scrolls and zooms on its own.
              child: ref.read(pdfViewProvider)(
                bytes,
                '${number ?? invoiceId}-${params.language}.pdf',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
