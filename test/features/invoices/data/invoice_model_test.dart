import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/invoices/data/models/invoice_model.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/invoice.dart';

void main() {
  test('reads an invoice as the API sends it', () {
    final invoice = InvoiceModel.fromJson({
      'id': 'i1',
      'clientAccountId': 'c1',
      'contractId': 'k1',
      'invoiceNumber': 'INV-2026-00042',
      'issueDate': '2026-10-01T00:00:00.000Z',
      'dueDate': '2026-10-31T00:00:00.000Z',
      'totalAmount': '2400',
      'status': 'partially_paid',
      'contract': {'id': 'k1', 'paymentTerms': 'Net 30', 'status': 'active'},
      'lineItems': [
        {
          'id': 'l1',
          'invoiceId': 'i1',
          'jobId': 'j1',
          'description': 'Limpieza mensual',
          'quantity': '1',
          'unitPrice': '2400',
          'lineTotal': '2400',
          'job': {'id': 'j1', 'title': 'Limpieza Torre Norte'},
        },
      ],
      'payments': [
        {
          'id': 'p1',
          'paymentDate': '2026-10-10T00:00:00.000Z',
          'amount': '1000',
          'paymentMethod': 'bank_transfer',
          'transactionReference': 'SPEI 123456',
          'status': 'completed',
        },
        {
          'id': 'p2',
          'paymentDate': '2026-10-11T00:00:00.000Z',
          'amount': 500,
          'paymentMethod': 'check',
          'status': 'voided',
        },
      ],
      'amountPaid': '1000',
      'balanceDue': '1400',
      'isOverdue': true,
      'daysOverdue': 3,
    });

    expect(invoice.status, InvoiceStatus.partiallyPaid);
    expect(invoice.dueDate, DateTime(2026, 10, 31));
    expect(invoice.contractPaymentTerms, 'Net 30');
    expect(invoice.lineItems.single.jobTitle, 'Limpieza Torre Norte');
    expect(invoice.payments.first.method, PaymentMethod.bankTransfer);
    expect(invoice.payments.first.isVoided, isFalse);
    expect(invoice.payments.last.amount, '500');
    expect(invoice.payments.last.isVoided, isTrue);
    expect(invoice.balanceDue, '1400');
    expect(invoice.daysOverdue, 3);
    expect(invoice.canPay, isTrue);
    expect(invoice.hasPayments, isTrue);
    // "void" on the wire.
    expect(InvoiceStatus.fromWire('void'), InvoiceStatus.voided);
  });

  test('a create leaves empty fields to the server', () {
    final body = InvoiceDraftModel.toJson(
      InvoiceDraft(
        issueDate: DateTime(2026, 9, 23),
        invoiceNumber: '  ',
        lineItems: const [
          InvoiceLineDraft(
            jobId: 'j1',
            jobTitle: 'Lobby',
            description: ' Monthly cleaning ',
            quantity: '1',
            unitPrice: '2400.50',
          ),
        ],
      ),
      create: true,
    );

    expect(body, {
      'issueDate': '2026-09-23',
      'lineItems': [
        {
          'jobId': 'j1',
          'description': 'Monthly cleaning',
          'quantity': 1,
          'unitPrice': 2400.5,
        },
      ],
    });
  });

  test('an edit clears the contract but keeps number and due date', () {
    final body = InvoiceDraftModel.toJson(
      InvoiceDraft(
        issueDate: DateTime(2026, 9, 23),
        dueDate: DateTime(2026, 10, 23),
        invoiceNumber: 'INV-7',
      ),
      create: false,
    );

    expect(body, {
      'contractId': null,
      'invoiceNumber': 'INV-7',
      'issueDate': '2026-09-23',
      'dueDate': '2026-10-23',
      'lineItems': <Object>[],
    });
  });

  test('a payment sends numbers and leaves an empty reference out', () {
    expect(
      InvoiceDraftModel.payment(
        PaymentDraft(
          amount: '99.50',
          method: PaymentMethod.bankTransfer,
          paymentDate: DateTime(2026, 9, 23),
          reference: ' ',
        ),
      ),
      {
        'amount': 99.5,
        'paymentMethod': 'bank_transfer',
        'paymentDate': '2026-09-23',
      },
    );
  });
}
