import 'dart:typed_data';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../datasources/invoices_remote_data_source.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  const InvoicesRepositoryImpl(this._remote);

  final InvoicesRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Invoice>> getInvoices(String clientId, {String? contractId}) =>
      _guard(() => _remote.getInvoices(clientId, contractId: contractId));

  @override
  Future<Invoice> getInvoice(String clientId, String invoiceId) =>
      _guard(() => _remote.getInvoice(clientId, invoiceId));

  @override
  Future<Invoice> createInvoice(String clientId, InvoiceDraft draft) =>
      _guard(() => _remote.createInvoice(clientId, draft));

  @override
  Future<Invoice> updateInvoice(
    String clientId,
    String invoiceId,
    InvoiceDraft draft,
  ) => _guard(() => _remote.updateInvoice(clientId, invoiceId, draft));

  @override
  Future<Invoice> issueInvoice(String clientId, String invoiceId) =>
      _guard(() => _remote.issueInvoice(clientId, invoiceId));

  @override
  Future<Invoice> voidInvoice(String clientId, String invoiceId) =>
      _guard(() => _remote.voidInvoice(clientId, invoiceId));

  @override
  Future<void> deleteInvoice(String clientId, String invoiceId) =>
      _guard(() => _remote.deleteInvoice(clientId, invoiceId));

  @override
  Future<Invoice> recordPayment(
    String clientId,
    String invoiceId,
    PaymentDraft payment,
  ) => _guard(() => _remote.recordPayment(clientId, invoiceId, payment));

  @override
  Future<Uint8List> getInvoicePdf(
    String clientId,
    String invoiceId, {
    required String language,
  }) => _guard(
    () => _remote.getInvoicePdf(clientId, invoiceId, language: language),
  );

  @override
  Future<List<String>> sendInvoice(
    String clientId,
    String invoiceId, {
    required List<String> to,
    required String language,
  }) => _guard(
    () => _remote.sendInvoice(clientId, invoiceId, to: to, language: language),
  );

  @override
  Future<Invoice> voidPayment(
    String clientId,
    String invoiceId,
    String paymentId,
  ) => _guard(() => _remote.voidPayment(clientId, invoiceId, paymentId));
}
