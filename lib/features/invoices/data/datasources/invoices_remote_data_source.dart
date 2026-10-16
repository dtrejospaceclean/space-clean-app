import 'dart:typed_data';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/job_billing_suggestion.dart';
import '../models/invoice_model.dart';

/// Talks to `/clients/:clientId/invoices`. Throws `ApiException`.
class InvoicesRemoteDataSource {
  const InvoicesRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/invoices';

  static Invoice _one(Object? data) =>
      InvoiceModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Invoice>> getInvoices(
    String clientId, {
    String? contractId,
  }) async => (await fetchAllPages(
    _api,
    _path(clientId),
    query: {'contractId': ?contractId},
  )).map(InvoiceModel.fromJson).toList();

  Future<Invoice> getInvoice(String clientId, String invoiceId) async =>
      _one(await _api.get('${_path(clientId)}/$invoiceId'));

  Future<Invoice> createInvoice(String clientId, InvoiceDraft draft) async =>
      _one(
        await _api.post(
          _path(clientId),
          body: InvoiceDraftModel.toJson(draft, create: true),
        ),
      );

  Future<Invoice> updateInvoice(
    String clientId,
    String invoiceId,
    InvoiceDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$invoiceId',
      body: InvoiceDraftModel.toJson(draft, create: false),
    ),
  );

  /// Takes no body.
  Future<Invoice> issueInvoice(String clientId, String invoiceId) async =>
      _one(await _api.post('${_path(clientId)}/$invoiceId/issue'));

  /// Takes no body.
  Future<Invoice> voidInvoice(String clientId, String invoiceId) async =>
      _one(await _api.post('${_path(clientId)}/$invoiceId/void'));

  /// Returns no data.
  Future<void> deleteInvoice(String clientId, String invoiceId) =>
      _api.delete('${_path(clientId)}/$invoiceId');

  Future<Invoice> recordPayment(
    String clientId,
    String invoiceId,
    PaymentDraft payment,
  ) async => _one(
    await _api.post(
      '${_path(clientId)}/$invoiceId/payments',
      body: InvoiceDraftModel.payment(payment),
    ),
  );

  /// The PDF bytes, not an envelope.
  Future<Uint8List> getInvoicePdf(
    String clientId,
    String invoiceId, {
    required String language,
  }) => _api.getBytes(
    '${_path(clientId)}/$invoiceId/pdf',
    query: {'language': language},
    expectedType: 'application/pdf',
  );

  Future<List<String>> sendInvoice(
    String clientId,
    String invoiceId, {
    required List<String> to,
    required String language,
  }) async {
    final data = await _api.post(
      '${_path(clientId)}/$invoiceId/send',
      body: {'to': to, 'language': language},
    ) as Map;
    return [for (final email in data['sentTo'] as List? ?? const []) '$email'];
  }

  /// Takes no body.
  Future<Invoice> voidPayment(
    String clientId,
    String invoiceId,
    String paymentId,
  ) async => _one(
    await _api.post('${_path(clientId)}/$invoiceId/payments/$paymentId/void'),
  );

  /// `GET /clients/:clientId/jobs/:jobId/billing-suggestion`.
  Future<JobBillingSuggestion> getJobBillingSuggestion(
    String clientId,
    String jobId,
  ) async {
    final data = await _api.get(
      '/clients/$clientId/jobs/$jobId/billing-suggestion',
    );
    return data is Map
        ? JobBillingSuggestionModel.fromJson(data.cast<String, dynamic>())
        : JobBillingSuggestion.none;
  }
}
