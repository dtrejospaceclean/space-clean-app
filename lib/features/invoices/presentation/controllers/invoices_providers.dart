import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/presentation/controllers/contracts_providers.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';

/// An account's invoices (or one contract's), latest issue date first.
final invoicesProvider = FutureProvider.autoDispose
    .family<List<Invoice>, InvoiceQuery>(
      (ref, query) => ref.watch(getInvoicesProvider)(query),
    );

/// One invoice: `(clientId, invoiceId)`.
final invoiceProvider = FutureProvider.autoDispose
    .family<Invoice, (String, String)>(
      (ref, key) => ref.watch(getInvoiceProvider)(
        InvoiceRef(clientId: key.$1, invoiceId: key.$2),
      ),
    );

/// An invoice's PDF in one language. Loaded each time it's opened, so it
/// shows the invoice as it is now.
final invoicePdfProvider = FutureProvider.autoDispose
    .family<Uint8List, InvoicePdfParams>(
      (ref, params) => ref.watch(getInvoicePdfProvider)(params),
    );

/// Drops cached invoices after any write, and the account's contracts,
/// which count their invoices.
void invalidateInvoices(WidgetRef ref, String clientId) {
  ref
    ..invalidate(invoicesProvider)
    ..invalidate(invoiceProvider)
    ..invalidate(invoicePdfProvider);
  invalidateContracts(ref, clientId);
}
