import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/invoices_remote_data_source.dart';
import '../data/repositories/invoices_repository_impl.dart';
import '../domain/repositories/invoices_repository.dart';
import '../domain/usecases/invoice_usecases.dart';

final invoicesRepositoryProvider = Provider<InvoicesRepository>(
  (ref) => InvoicesRepositoryImpl(
    InvoicesRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getInvoicesProvider = Provider(
  (ref) => GetInvoices(ref.watch(invoicesRepositoryProvider)),
);
final getInvoiceProvider = Provider(
  (ref) => GetInvoice(ref.watch(invoicesRepositoryProvider)),
);
final saveInvoiceProvider = Provider(
  (ref) => SaveInvoice(ref.watch(invoicesRepositoryProvider)),
);
final issueInvoiceProvider = Provider(
  (ref) => IssueInvoice(ref.watch(invoicesRepositoryProvider)),
);
final voidInvoiceProvider = Provider(
  (ref) => VoidInvoice(ref.watch(invoicesRepositoryProvider)),
);
final deleteInvoiceProvider = Provider(
  (ref) => DeleteInvoice(ref.watch(invoicesRepositoryProvider)),
);
final recordPaymentProvider = Provider(
  (ref) => RecordPayment(ref.watch(invoicesRepositoryProvider)),
);
final getInvoicePdfProvider = Provider(
  (ref) => GetInvoicePdf(ref.watch(invoicesRepositoryProvider)),
);
final sendInvoiceProvider = Provider(
  (ref) => SendInvoice(ref.watch(invoicesRepositoryProvider)),
);
final voidPaymentProvider = Provider(
  (ref) => VoidPayment(ref.watch(invoicesRepositoryProvider)),
);
final getJobBillingSuggestionProvider = Provider(
  (ref) => GetJobBillingSuggestion(ref.watch(invoicesRepositoryProvider)),
);
