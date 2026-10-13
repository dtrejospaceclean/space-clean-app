import '../../../../core/domain/money.dart';

/// Where an invoice stands. "Overdue" isn't one: it's worked out by the
/// server from the due date and the balance ([Invoice.isOverdue]).
enum InvoiceStatus {
  draft('draft'),
  issued('issued'),
  partiallyPaid('partially_paid'),
  paid('paid'),
  voided('void'),

  /// A status this app doesn't know yet.
  unknown('');

  const InvoiceStatus(this.wire);

  /// The API's name for it.
  final String wire;

  static InvoiceStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// How a payment came in.
enum PaymentMethod {
  cash('cash'),
  check('check'),
  card('card'),
  bankTransfer('bank_transfer'),
  other('other'),

  /// A method this app doesn't know yet.
  unknown('');

  const PaymentMethod(this.wire);

  /// The API's name for it.
  final String wire;

  /// The ones a person can pick.
  static const choices = [cash, check, card, bankTransfer, other];

  static PaymentMethod fromWire(String? value) => values.firstWhere(
    (m) => m != unknown && m.wire == value,
    orElse: () => unknown,
  );
}

/// One billed line. The server computes [lineTotal].
class InvoiceLine {
  const InvoiceLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.jobId,
    this.jobTitle,
  });

  final String id;

  /// The job it bills, if any.
  final String? jobId;
  final String? jobTitle;
  final String description;

  /// Decimal strings as the API sends them ("1", "2400").
  final String quantity;
  final String unitPrice;
  final String lineTotal;
}

/// Money received against an invoice. Payments are never deleted: a
/// bounced check or a refund is voided, stays on record, and no longer
/// counts.
class Payment {
  const Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.reference,
    this.isVoided = false,
  });

  final String id;

  /// A decimal string.
  final String amount;
  final PaymentMethod method;

  /// A calendar day.
  final DateTime paymentDate;

  /// Check number, card authorization, transfer id…
  final String? reference;
  final bool isVoided;
}

/// A bill to a client account, usually under a contract. A draft can be
/// edited or deleted; issuing fixes it, and from then on it takes payments
/// and can only be voided (once its payments are voided).
class Invoice {
  const Invoice({
    required this.id,
    required this.clientId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    required this.status,
    this.contractId,
    this.contractPaymentTerms,
    this.lineItems = const [],
    this.payments = const [],
    this.amountPaid = '0',
    this.balanceDue = '0',
    this.isOverdue = false,
    this.daysOverdue,
  });

  final String id;
  final String clientId;

  /// e.g. "INV-2026-00042".
  final String invoiceNumber;

  /// Calendar days (no time).
  final DateTime issueDate;
  final DateTime dueDate;

  /// The sum of the lines, as a decimal string.
  final String totalAmount;
  final InvoiceStatus status;
  final String? contractId;

  /// The contract's terms ("Net 30"), which set the due date when none is
  /// given.
  final String? contractPaymentTerms;
  final List<InvoiceLine> lineItems;

  /// Oldest first, voided ones included.
  final List<Payment> payments;

  /// Decimal strings worked out by the server; only payments that aren't
  /// voided count.
  final String amountPaid;
  final String balanceDue;

  /// Issued or partly paid, and past its due date.
  final bool isOverdue;

  /// Whole days past the due date while [isOverdue]; null otherwise.
  final int? daysOverdue;

  bool get isDraft => status == InvoiceStatus.draft;
  bool get isVoided => status == InvoiceStatus.voided;

  /// Only a draft can change: its fields and lines, issuing, deleting.
  bool get isEditable => isDraft;

  /// Issuing needs lines adding up to more than zero.
  bool get canIssue =>
      isDraft && lineItems.isNotEmpty && toCents(totalAmount) > 0;

  /// Payments go on an issued or partly paid invoice.
  bool get canPay =>
      status == InvoiceStatus.issued || status == InvoiceStatus.partiallyPaid;

  /// Once issued, an invoice is history: it can only be voided, and only
  /// after its payments are ([hasPayments]).
  bool get canVoid => !isDraft && !isVoided;

  /// Payments that still count.
  bool get hasPayments => toCents(amountPaid) > 0;

  /// Only an issued invoice goes out by email: a draft isn't final and a
  /// void one isn't owed.
  bool get canSend =>
      status == InvoiceStatus.issued ||
      status == InvoiceStatus.partiallyPaid ||
      status == InvoiceStatus.paid;
}

/// A line as typed in the form. Numbers stay as typed ("1", "2400").
class InvoiceLineDraft {
  const InvoiceLineDraft({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.jobId,
    this.jobTitle,
  });

  final String? jobId;

  /// To show the linked job before it's saved; never sent.
  final String? jobTitle;
  final String description;
  final String quantity;
  final String unitPrice;
}

/// The editable fields of a draft invoice. Empty optional fields are left
/// to the server: a number is assigned and the due date comes from the
/// contract's payment terms.
class InvoiceDraft {
  const InvoiceDraft({
    required this.issueDate,
    this.contractId,
    this.invoiceNumber,
    this.dueDate,
    this.lineItems = const [],
  });

  final String? contractId;

  /// As typed; empty for the next `INV-<year>-<n>`.
  final String? invoiceNumber;
  final DateTime issueDate;
  final DateTime? dueDate;

  /// Replace every line on an edit.
  final List<InvoiceLineDraft> lineItems;
}

/// A payment as typed.
class PaymentDraft {
  const PaymentDraft({
    required this.amount,
    required this.method,
    this.paymentDate,
    this.reference,
  });

  /// As typed, up to two decimals.
  final String amount;
  final PaymentMethod method;

  /// Null for today.
  final DateTime? paymentDate;
  final String? reference;
}
