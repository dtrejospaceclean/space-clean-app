import '../entities/invoice.dart';

/// Every method throws a `Failure` on error.
abstract interface class InvoicesRepository {
  /// An account's invoices, latest issue date first; only [contractId]'s
  /// when given. Needs `invoice.view`.
  Future<List<Invoice>> getInvoices(String clientId, {String? contractId});

  /// Needs `invoice.view`.
  Future<Invoice> getInvoice(String clientId, String invoiceId);

  /// A new draft. Needs `invoice.edit`. Without a due date the contract's
  /// payment terms must imply one (`invoices.due_date_required`).
  Future<Invoice> createInvoice(String clientId, InvoiceDraft draft);

  /// Replaces a draft's fields and every line. Needs `invoice.edit`; only
  /// a draft (`invoices.not_draft`).
  Future<Invoice> updateInvoice(
    String clientId,
    String invoiceId,
    InvoiceDraft draft,
  );

  /// Fixes a draft and sends it out. Needs `invoice.edit`; it needs lines
  /// and a total above zero (`invoices.empty`).
  Future<Invoice> issueInvoice(String clientId, String invoiceId);

  /// Cancels an issued invoice for good. Needs `invoice.edit`; its payments
  /// must be voided first (`invoices.has_payments`).
  Future<Invoice> voidInvoice(String clientId, String invoiceId);

  /// Needs `invoice.edit`; only a draft (`invoices.only_drafts_deletable`).
  Future<void> deleteInvoice(String clientId, String invoiceId);

  /// Needs `invoice.edit`; only on an issued or partly paid invoice
  /// (`invoices.not_payable`), up to the balance (`invoices.overpayment`).
  Future<Invoice> recordPayment(
    String clientId,
    String invoiceId,
    PaymentDraft payment,
  );

  /// A bounced check or a refund: the payment stays, voided, and the
  /// balance goes back up. Needs `invoice.edit`.
  Future<Invoice> voidPayment(
    String clientId,
    String invoiceId,
    String paymentId,
  );
}
