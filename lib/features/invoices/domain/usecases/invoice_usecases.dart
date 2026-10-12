import '../../../../core/usecase/usecase.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class InvoiceQuery {
  const InvoiceQuery({required this.clientId, this.contractId});

  final String clientId;

  /// Only this contract's invoices.
  final String? contractId;

  @override
  bool operator ==(Object other) =>
      other is InvoiceQuery &&
      other.clientId == clientId &&
      other.contractId == contractId;

  @override
  int get hashCode => Object.hash(clientId, contractId);
}

class GetInvoices implements UseCase<List<Invoice>, InvoiceQuery> {
  const GetInvoices(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<List<Invoice>> call(InvoiceQuery q) =>
      _repository.getInvoices(q.clientId, contractId: q.contractId);
}

class InvoiceRef {
  const InvoiceRef({required this.clientId, required this.invoiceId});

  final String clientId;
  final String invoiceId;
}

class GetInvoice implements UseCase<Invoice, InvoiceRef> {
  const GetInvoice(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(InvoiceRef params) =>
      _repository.getInvoice(params.clientId, params.invoiceId);
}

class SaveInvoiceParams {
  const SaveInvoiceParams({
    required this.clientId,
    required this.draft,
    this.invoiceId,
  });

  final String clientId;

  /// The draft edited; null to create.
  final String? invoiceId;
  final InvoiceDraft draft;
}

/// Creates a draft or edits one; returns the saved invoice.
class SaveInvoice implements UseCase<Invoice, SaveInvoiceParams> {
  const SaveInvoice(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(SaveInvoiceParams p) => switch (p.invoiceId) {
    null => _repository.createInvoice(p.clientId, p.draft),
    final id => _repository.updateInvoice(p.clientId, id, p.draft),
  };
}

class IssueInvoice implements UseCase<Invoice, InvoiceRef> {
  const IssueInvoice(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(InvoiceRef params) =>
      _repository.issueInvoice(params.clientId, params.invoiceId);
}

class VoidInvoice implements UseCase<Invoice, InvoiceRef> {
  const VoidInvoice(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(InvoiceRef params) =>
      _repository.voidInvoice(params.clientId, params.invoiceId);
}

class DeleteInvoice implements UseCase<void, InvoiceRef> {
  const DeleteInvoice(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<void> call(InvoiceRef params) =>
      _repository.deleteInvoice(params.clientId, params.invoiceId);
}

class RecordPaymentParams {
  const RecordPaymentParams({
    required this.clientId,
    required this.invoiceId,
    required this.payment,
  });

  final String clientId;
  final String invoiceId;
  final PaymentDraft payment;
}

class RecordPayment implements UseCase<Invoice, RecordPaymentParams> {
  const RecordPayment(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(RecordPaymentParams p) =>
      _repository.recordPayment(p.clientId, p.invoiceId, p.payment);
}

class VoidPaymentParams {
  const VoidPaymentParams({
    required this.clientId,
    required this.invoiceId,
    required this.paymentId,
  });

  final String clientId;
  final String invoiceId;
  final String paymentId;
}

class VoidPayment implements UseCase<Invoice, VoidPaymentParams> {
  const VoidPayment(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Invoice> call(VoidPaymentParams p) =>
      _repository.voidPayment(p.clientId, p.invoiceId, p.paymentId);
}
