import '../../domain/entities/invoice.dart';
import '../../domain/entities/job_billing_suggestion.dart';

abstract final class InvoiceModel {
  /// A decimal column: a string from the API, tolerated as a number.
  static String? _decimal(Object? value) => switch (value) {
    final String s => s,
    final num n => '$n',
    _ => null,
  };

  /// A date-only column: keep the calendar day, ignore the UTC time.
  static DateTime? _day(Object? value) => switch (value) {
    final String s when s.length >= 10 => DateTime.tryParse(s.substring(0, 10)),
    _ => null,
  };

  static Map<String, dynamic> _map(Object? value) =>
      (value as Map? ?? const {}).cast<String, dynamic>();

  static InvoiceLine _line(Map<String, dynamic> json) => InvoiceLine(
    id: json['id'] as String? ?? '',
    jobId: json['jobId'] as String?,
    jobTitle: switch (json['job']) {
      {'title': final String title} => title,
      _ => null,
    },
    description: json['description'] as String? ?? '',
    quantity: _decimal(json['quantity']) ?? '0',
    unitPrice: _decimal(json['unitPrice']) ?? '0',
    lineTotal: _decimal(json['lineTotal']) ?? '0',
  );

  static Payment _payment(Map<String, dynamic> json) => Payment(
    id: json['id'] as String? ?? '',
    amount: _decimal(json['amount']) ?? '0',
    method: PaymentMethod.fromWire(json['paymentMethod'] as String?),
    paymentDate: _day(json['paymentDate']) ?? DateTime(1970),
    reference: json['transactionReference'] as String?,
    isVoided: json['status'] == 'voided',
  );

  static Invoice fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    contractId: json['contractId'] as String?,
    contractPaymentTerms: switch (json['contract']) {
      {'paymentTerms': final String terms} => terms,
      _ => null,
    },
    invoiceNumber: json['invoiceNumber'] as String? ?? '',
    issueDate: _day(json['issueDate']) ?? DateTime(1970),
    dueDate: _day(json['dueDate']) ?? DateTime(1970),
    totalAmount: _decimal(json['totalAmount']) ?? '0',
    status: InvoiceStatus.fromWire(json['status'] as String?),
    lineItems: [
      for (final item in json['lineItems'] as List? ?? const [])
        _line(_map(item)),
    ],
    payments: [
      for (final item in json['payments'] as List? ?? const [])
        _payment(_map(item)),
    ],
    amountPaid: _decimal(json['amountPaid']) ?? '0',
    balanceDue: _decimal(json['balanceDue']) ?? '0',
    isOverdue: json['isOverdue'] as bool? ?? false,
    daysOverdue: (json['daysOverdue'] as num?)?.toInt(),
  );
}

abstract final class InvoiceDraftModel {
  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String? _text(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  /// Body for a create or an update (`PATCH`). Money goes as numbers, and
  /// the total is never sent: the server sums the lines. Every line is
  /// sent, replacing the old ones. A create leaves empty fields out, so the
  /// server numbers the invoice and takes the due date from the contract;
  /// an update clears an empty contract (null) but keeps the number and the
  /// due date, which can't be empty.
  static Map<String, dynamic> toJson(InvoiceDraft d, {required bool create}) =>
      {
        if (create)
          'contractId': ?_text(d.contractId)
        else
          'contractId': _text(d.contractId),
        'invoiceNumber': ?_text(d.invoiceNumber),
        'issueDate': ymd(d.issueDate),
        if (d.dueDate case final due?) 'dueDate': ymd(due),
        'lineItems': [
          for (final line in d.lineItems)
            {
              'jobId': ?line.jobId,
              'description': line.description.trim(),
              'quantity': num.tryParse(line.quantity.trim()) ?? 0,
              'unitPrice': num.tryParse(line.unitPrice.trim()) ?? 0,
            },
        ],
      };

  /// Body of `POST …/payments`. Today is sent as no date.
  static Map<String, dynamic> payment(PaymentDraft p) => {
    'amount': num.tryParse(p.amount.trim()) ?? 0,
    'paymentMethod': p.method.wire,
    if (p.paymentDate case final day?) 'paymentDate': ymd(day),
    'transactionReference': ?_text(p.reference),
  };
}

abstract final class JobBillingSuggestionModel {
  static JobBillingSuggestion fromJson(Map<String, dynamic> json) {
    // Decimals may come as strings or numbers.
    String? decimal(Object? v) => v == null ? null : '$v';
    return JobBillingSuggestion(
      serviceId: json['serviceId'] as String?,
      serviceName: json['serviceName'] as String?,
      quantity: decimal(json['quantity']),
      unitPrice: decimal(json['unitPrice']),
      source: switch (json['source']) {
        'proposal' => BillingSource.proposal,
        'catalog' => BillingSource.catalog,
        _ => null,
      },
    );
  }
}
