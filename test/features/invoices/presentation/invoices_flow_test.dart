import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/invoice.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/job_billing_suggestion.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
  accountManager: ClientAssignee(
    id: 'u-am',
    name: 'Carlos Medina',
    email: 'carlos@spaceclean.com',
  ),
  // No email: can't be offered.
  supervisor: ClientAssignee(id: 'u-sup', name: 'Rosa Díaz'),
);

const _contacts = [
  Contact(
    id: 'ct1',
    clientId: 'c1',
    firstName: 'Laura',
    lastName: 'Ortiz',
    email: 'Laura@TorreNorte.com',
    isBillingContact: true,
  ),
  Contact(
    id: 'ct2',
    clientId: 'c1',
    firstName: 'Pedro',
    lastName: 'Ruiz',
    email: 'pedro@torrenorte.com',
    isPrimary: true,
  ),
];

final _contract = Contract(
  id: 'k1',
  clientId: 'c1',
  contractValue: '2400',
  startDate: DateTime(2026, 1, 1),
  expirationDate: DateTime(2026, 12, 31),
  paymentTerms: 'Net 30',
  status: ContractStatus.active,
  invoiceCount: 3,
);

/// Issued, $1,000 of $2,400 paid, 5 days past due.
final _overdue = Invoice(
  id: 'inv-a',
  clientId: 'c1',
  contractId: 'k1',
  contractPaymentTerms: 'Net 30',
  invoiceNumber: 'INV-2026-00041',
  issueDate: DateTime(2026, 8, 19),
  dueDate: DateTime(2026, 9, 18),
  totalAmount: '2400',
  status: InvoiceStatus.partiallyPaid,
  lineItems: const [
    InvoiceLine(
      id: 'l1',
      jobId: 'j1',
      jobTitle: 'Lobby deep clean',
      description: 'Monthly cleaning',
      quantity: '1',
      unitPrice: '2400',
      lineTotal: '2400',
    ),
  ],
  payments: [
    Payment(
      id: 'pay-1',
      amount: '1000',
      method: PaymentMethod.bankTransfer,
      paymentDate: DateTime(2026, 9, 10),
      reference: 'SPEI 123456',
    ),
  ],
  amountPaid: '1000',
  balanceDue: '1400',
  isOverdue: true,
  daysOverdue: 5,
);

final _draftInvoice = Invoice(
  id: 'inv-b',
  clientId: 'c1',
  invoiceNumber: 'INV-2026-00042',
  issueDate: DateTime(2026, 9, 20),
  dueDate: DateTime(2026, 10, 20),
  totalAmount: '300',
  status: InvoiceStatus.draft,
  lineItems: const [
    InvoiceLine(
      id: 'l2',
      description: 'Window washing',
      quantity: '2',
      unitPrice: '150',
      lineTotal: '300',
    ),
  ],
);

final _paid = Invoice(
  id: 'inv-c',
  clientId: 'c1',
  contractId: 'k1',
  invoiceNumber: 'INV-2026-00040',
  issueDate: DateTime(2026, 7, 20),
  dueDate: DateTime(2026, 8, 19),
  totalAmount: '900',
  status: InvoiceStatus.paid,
  lineItems: const [
    InvoiceLine(
      id: 'l3',
      description: 'Carpet care',
      quantity: '1',
      unitPrice: '900',
      lineTotal: '900',
    ),
  ],
  payments: [
    Payment(
      id: 'pay-2',
      amount: '900',
      method: PaymentMethod.cash,
      paymentDate: DateTime(2026, 8, 1),
    ),
  ],
  amountPaid: '900',
  balanceDue: '0',
);

const _viewer = {Permissions.invoiceView, Permissions.contractView};
const _editor = {
  Permissions.invoiceView,
  Permissions.invoiceEdit,
  Permissions.contractView,
  Permissions.infoView,
};

/// Opens Torre Norte → Invoices as a member with [permissions].
/// Holds [getClient] on [gate], like a slow server.
class _SlowClients extends FakeClientsRepository {
  _SlowClients() : super([_tower]);

  Completer<void>? gate;

  @override
  Future<Client> getClient(String id) async {
    await gate?.future;
    return super.getClient(id);
  }
}

Future<FakeInvoicesRepository> _openInvoices(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
  List<Invoice>? invoices,
  FakeClientsRepository? clients,
  FakeJobsRepository? jobs,
}) async {
  final repo = FakeInvoicesRepository(
    invoices ?? [_overdue, _draftInvoice, _paid],
  );
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: clients ?? FakeClientsRepository([_tower]),
    contracts: FakeContractsRepository([_contract]),
    contacts: FakeContactsRepository(_contacts),
    invoices: repo,
    jobs: jobs,
    access: FakeAccessRepository({
      'c1': AccountAccess(
        clientId: 'c1',
        baseRole: 'account_manager',
        permissions: permissions,
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Invoices'));
  await tester.tap(find.text('Invoices'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _open(WidgetTester tester, String number) async {
  await tester.tap(find.text(number));
  await tester.pumpAndSettle();
}

/// Taps [label] in an open confirmation dialog, which sits above the page
/// (where the same words may also show).
Future<void> _confirm(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a viewer reads invoices and narrows to the overdue ones', (
    tester,
  ) async {
    await _openInvoices(tester);

    expect(find.text('INV-2026-00041'), findsOneWidget);
    expect(find.text('INV-2026-00042'), findsOneWidget);
    expect(find.text('INV-2026-00040'), findsOneWidget);
    // Overdue stands in for the status, with what's left to collect.
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text(r'5 days overdue · $1,400.00 due'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text(r'$2,400.00'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(find.text('Overdue (1)'));
    await tester.pumpAndSettle();
    expect(find.text('INV-2026-00041'), findsOneWidget);
    expect(find.text('INV-2026-00042'), findsNothing);

    await _open(tester, 'INV-2026-00041');
    expect(find.text('Invoice'), findsOneWidget);
    expect(find.text(r'$1,000.00 paid of $2,400.00'), findsOneWidget);
    expect(
      find.text(r'Balance due: $1,400.00 · 5 days overdue'),
      findsOneWidget,
    );
    expect(find.text(r'1 × $2,400.00 · Job: Lobby deep clean'), findsOneWidget);
    await revealBelow(tester, find.text('Bank transfer · SPEI 123456'));
    // Read-only: nothing to edit, collect or void.
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Record payment'), findsNothing);
    expect(find.text('Void invoice'), findsNothing);
  });

  testWidgets('an editor drafts an invoice from "+" under the only contract', (
    tester,
  ) async {
    final invoices = await _openInvoices(
      tester,
      permissions: _editor,
      invoices: const [],
    );
    expect(find.text('No invoices'), findsOneWidget);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New invoice'), findsOneWidget);
    // The account's only contract is the default; the number and due date
    // are left to the server.
    expect(find.text('Jan 1, 2026 – Dec 31, 2026 · Net 30'), findsOneWidget);
    expect(find.text('Sep 23, 2026'), findsOneWidget);
    expect(
      find.text(
        'Leave the due date empty to use the contract\'s payment terms.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Add line item'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Description'), 'Monthly cleaning');
    await tester.enterText(field('Unit price'), '2400');
    await tester.pumpAndSettle();
    expect(find.text(r'Line total: $2,400.00'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text(r'Invoice total: $2,400.00'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(invoices.writes, ['create']);
    final draft = invoices.drafts.single;
    expect(draft.contractId, 'k1');
    expect(draft.dueDate, isNull);
    expect(draft.invoiceNumber, '');
    expect(draft.lineItems.single.quantity, '1');
    // Lands on the new draft, numbered by the server.
    expect(find.text('Invoice'), findsOneWidget);
    expect(find.text('INV-2026-00001'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  group('picking a job prices the line from its service', () {
    final jobs = FakeJobsRepository({
      'c1': [
        job('j1', 'c1', title: 'Office cleaning', day: 22),
        job('j2', 'c1', title: 'Window washing', day: 21),
        job('j3', 'c1', title: 'Carpet care', day: 20),
      ],
    });

    Future<FakeInvoicesRepository> openLine(WidgetTester tester) async {
      final invoices = await _openInvoices(
        tester,
        permissions: _editor,
        jobs: jobs,
      );
      invoices.billing = {
        'j1': const JobBillingSuggestion(
          serviceId: 's1',
          serviceName: 'Office cleaning',
          quantity: '12000.00',
          unitPrice: '0.12',
          source: BillingSource.proposal,
        ),
        'j2': const JobBillingSuggestion(
          serviceId: 's2',
          serviceName: 'Window washing',
          unitPrice: '150.00',
          source: BillingSource.catalog,
        ),
      };
      await tester.tap(find.byTooltip('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add line item'));
      await tester.pumpAndSettle();
      return invoices;
    }

    /// Opens the job picker from its value ("Not set" or the job picked).
    Future<void> pickJob(
      WidgetTester tester,
      String label, {
      String? from,
    }) async {
      await tester.tap(find.text(from ?? 'Not set'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    testWidgets('with the price agreed in the proposal', (tester) async {
      await openLine(tester);
      await pickJob(tester, 'Office cleaning · Sep 22, 2026');

      expect(find.text('Office cleaning'), findsWidgets);
      expect(_text(tester, 'Quantity'), '12000');
      expect(_text(tester, 'Unit price'), '0.12');
      expect(
        find.text('Line total: \$1,440.00\nPrice agreed in the proposal.'),
        findsOneWidget,
      );

      // Another job replaces what the first one filled in; the catalog has
      // no quantity, so the one filled in stays.
      await pickJob(
        tester,
        'Window washing · Sep 21, 2026',
        from: 'Office cleaning · Sep 22, 2026',
      );
      expect(_text(tester, 'Unit price'), '150');
      expect(_text(tester, 'Quantity'), '12000');
      expect(
        find.textContaining('Price from the service catalog.'),
        findsOneWidget,
      );
    });

    testWidgets('the price fields spin while the price is looked up', (
      tester,
    ) async {
      final invoices = await openLine(tester)
        ..billingGate = Completer();
      await tester.tap(find.text('Not set'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Office cleaning · Sep 22, 2026'));
      // The spinners never settle, so step past the sheet closing.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Quantity and unit price, the fields about to be filled; the footer
      // says so in words, for screen readers.
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      expect(
        find.textContaining("Looking up the job's price…"),
        findsOneWidget,
      );
      expect(_text(tester, 'Unit price'), '');

      invoices.billingGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(_text(tester, 'Unit price'), '0.12');
    });

    testWidgets('never over what was typed by hand', (tester) async {
      await openLine(tester);
      await tester.enterText(field('Unit price'), '95');
      await tester.enterText(field('Quantity'), '3');
      await pickJob(tester, 'Office cleaning · Sep 22, 2026');

      expect(_text(tester, 'Quantity'), '3');
      expect(_text(tester, 'Unit price'), '95');
      expect(find.textContaining('Price agreed'), findsNothing);
    });

    testWidgets('a job with nothing to suggest leaves the line', (
      tester,
    ) async {
      await openLine(tester);
      await pickJob(tester, 'Carpet care · Sep 20, 2026');

      expect(_text(tester, 'Quantity'), '1');
      expect(_text(tester, 'Unit price'), '');
    });
  });

  testWidgets('a number already used shows on its field', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Invoice number'), 'INV-2026-00040');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(invoices.writes, isEmpty);
    expect(find.text('That invoice number is already used.'), findsOneWidget);
  });

  testWidgets('a draft is issued, then paid in two payments', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00042');
    // Payments come once it's issued.
    expect(find.text('Payments'), findsNothing);
    expect(find.text('Edit'), findsOneWidget);

    await revealBelow(tester, button('Issue invoice'));
    await tester.tap(button('Issue invoice'));
    await tester.pumpAndSettle();
    expect(find.text('Issue this invoice?'), findsOneWidget);
    await _confirm(tester, 'Issue invoice');
    expect(invoices.writes, ['issue:inv-b']);
    expect(find.text('Issued'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete invoice'), findsNothing);

    await revealBelow(tester, button('Record payment'));
    await tester.tap(button('Record payment'));
    await tester.pumpAndSettle();
    // Starts at the balance; never more, and the method is required.
    expect(find.text('300.00'), findsOneWidget);
    await tester.enterText(field('Amount'), '350');
    await tester.tap(button('Record payment'));
    await tester.pumpAndSettle();
    expect(
      find.text("That's more than the balance due (\$300.00)."),
      findsOneWidget,
    );
    expect(find.text('Pick how it was paid.'), findsOneWidget);
    await tester.enterText(field('Amount'), '100');
    await tester.tap(find.text('Check'));
    await tester.enterText(field('Reference'), '#1042');
    await tester.tap(button('Record payment'));
    await tester.pumpAndSettle();

    expect(invoices.writes, ['issue:inv-b', 'pay:inv-b']);
    final payment = invoices.payments.single;
    expect(payment.method, PaymentMethod.check);
    // The phone's day goes with it, not the server's (UTC) today.
    expect(payment.paymentDate, DateTime(2026, 9, 23));
    expect(find.text('Partly paid'), findsOneWidget);
    expect(find.text(r'$100.00 paid of $300.00'), findsOneWidget);

    await revealBelow(tester, button('Record payment'));
    await tester.tap(button('Record payment'));
    await tester.pumpAndSettle();
    expect(find.text('200.00'), findsOneWidget);
    await tester.tap(find.text('Cash'));
    await tester.tap(button('Record payment'));
    await tester.pumpAndSettle();

    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Paid in full'), findsOneWidget);
    expect(button('Record payment'), findsNothing);
  });

  testWidgets('voiding needs its payments voided first', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00041');

    await revealBelow(tester, find.text('Void invoice'));
    await tester.tap(find.text('Void invoice'));
    await tester.pumpAndSettle();
    expect(find.text('Void its payments first, then the invoice.'), findsOne);
    await _confirm(tester, 'Done');
    expect(invoices.writes, isEmpty);

    // A bounced transfer: voided, kept, and the balance goes back up.
    await revealBelow(tester, find.text('Bank transfer · SPEI 123456'));
    await tester.tap(find.text('Bank transfer · SPEI 123456'));
    await tester.pumpAndSettle();
    expect(find.text('Void this payment?'), findsOneWidget);
    await _confirm(tester, 'Void payment');
    expect(invoices.writes, ['void-payment:pay-1']);
    expect(find.text('Voided'), findsOneWidget);
    // The head card is above, out of view after scrolling down.
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 3000),
      3000,
    );
    await tester.pumpAndSettle();
    expect(
      find.text(r'Balance due: $2,400.00 · 5 days overdue'),
      findsOneWidget,
    );

    await revealBelow(tester, find.text('Void invoice'));
    await tester.tap(find.text('Void invoice'));
    await tester.pumpAndSettle();
    await _confirm(tester, 'Void invoice');
    expect(invoices.writes.last, 'void:inv-a');
    expect(find.text('Void'), findsOneWidget);
    expect(
      find.text('This invoice is void. It stays for the record.'),
      findsOneWidget,
    );
    expect(find.text('Void invoice'), findsNothing);
    expect(button('Record payment'), findsNothing);
  });

  testWidgets('a draft is edited, then deleted', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00042');

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit invoice'), findsOneWidget);
    expect(find.text(r'2 × $150.00'), findsOneWidget);
    await tester.tap(find.text(r'2 × $150.00'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Quantity'), '3');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text(r'Invoice total: $450.00'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(invoices.writes, ['update:inv-b']);
    expect(invoices.drafts.single.invoiceNumber, 'INV-2026-00042');
    expect(invoices.drafts.single.lineItems.single.quantity, '3');
    expect(find.text(r'$450.00'), findsWidgets);

    await revealBelow(tester, find.text('Delete invoice'));
    await tester.tap(find.text('Delete invoice'));
    await tester.pumpAndSettle();
    await _confirm(tester, 'Delete');

    expect(invoices.writes.last, 'delete:inv-b');
    expect(find.text('INV-2026-00042'), findsNothing);
    expect(find.text('INV-2026-00041'), findsOneWidget);
  });

  testWidgets('a contract lists its invoices', (tester) async {
    await _openInvoices(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contracts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jan 1, 2026 – Dec 31, 2026'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('3 invoices'));
    await tester.tap(find.text('3 invoices'));
    await tester.pumpAndSettle();

    expect(find.text('Showing one contract\'s invoices.'), findsOneWidget);
    expect(find.text('INV-2026-00041'), findsOneWidget);
    expect(find.text('INV-2026-00040'), findsOneWidget);
    // The draft has no contract.
    expect(find.text('INV-2026-00042'), findsNothing);
  });

  testWidgets('anyone who sees an invoice opens its PDF', (tester) async {
    final invoices = await _openInvoices(tester);
    await _open(tester, 'INV-2026-00042');

    await revealBelow(tester, find.text('View PDF'));
    await tester.tap(find.text('View PDF'));
    await tester.pumpAndSettle();

    // In the app's language; drafts too (the server marks them).
    expect(invoices.pdfs, ['inv-b:en']);
    expect(find.text('INV-2026-00042'), findsOneWidget);
    expect(find.textContaining('PDF INV-2026-00042-en.pdf'), findsOneWidget);
    // Sending is for editors, and only once issued.
    expect(find.byTooltip('Send by email'), findsNothing);
  });

  testWidgets('an editor emails the invoice to people they pick', (
    tester,
  ) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00041');

    await revealBelow(tester, find.text('Send by email'));
    await tester.tap(find.text('Send by email'));
    await tester.pumpAndSettle();

    // The people in charge with an email, then the contacts; the billing
    // contact starts picked, like the server's own default.
    expect(find.text('People in charge'), findsOneWidget);
    expect(
      find.text('Account manager · carlos@spaceclean.com'),
      findsOneWidget,
    );
    expect(find.text('Rosa Díaz'), findsNothing);
    expect(find.text('Billing · laura@torrenorte.com'), findsOneWidget);
    expect(find.text('Send to 1 person'), findsOneWidget);

    await tester.tap(find.text('Carlos Medina'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Other emails'));
    await tester.enterText(field('Email'), 'not-an-email');
    await tester.tap(find.byTooltip('Add email'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    await tester.enterText(field('Email'), 'Pagos@Torre.mx');
    await tester.tap(find.byTooltip('Add email'));
    await tester.pumpAndSettle();
    expect(find.text('pagos@torre.mx'), findsOneWidget);

    await tester.tap(find.text('Send to 3 people'));
    await tester.pumpAndSettle();

    final (to, language) = invoices.sends.single;
    expect(
      to,
      unorderedEquals([
        'laura@torrenorte.com',
        'carlos@spaceclean.com',
        'pagos@torre.mx',
      ]),
    );
    expect(language, 'en');
    // Back on the invoice, which says who got it.
    expect(
      find.text(
        'Sent to laura@torrenorte.com, carlos@spaceclean.com, '
        'pagos@torre.mx.',
      ),
      findsOneWidget,
    );
    expect(find.text('Record payment'), findsOneWidget);
  });

  testWidgets('the people in charge shimmer while they load', (tester) async {
    final clients = _SlowClients();
    await _openInvoices(tester, permissions: _editor, clients: clients);
    await _open(tester, 'INV-2026-00041');

    clients.gate = Completer();
    await revealBelow(tester, find.text('Send by email'));
    await tester.tap(find.text('Send by email'));
    // The shimmer never settles, so step through the page transition.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('People in charge'), findsOneWidget);
    expect(find.byType(SkeletonListCard), findsOneWidget);
    expect(find.text('Carlos Medina'), findsNothing);
    // The contacts don't wait for them.
    expect(find.text('Billing · laura@torrenorte.com'), findsOneWidget);

    clients.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(SkeletonListCard), findsNothing);
    expect(
      find.text('Account manager · carlos@spaceclean.com'),
      findsOneWidget,
    );
  });

  testWidgets('sending needs someone to send to', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00041');
    await revealBelow(tester, find.text('Send by email'));
    await tester.tap(find.text('Send by email'));
    await tester.pumpAndSettle();

    // Untick the billing contact.
    await revealBelow(tester, find.text('Laura Ortiz'));
    await tester.tap(find.text('Laura Ortiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pick at least one person, or add an email.'),
      findsOneWidget,
    );
    expect(invoices.sends, isEmpty);
  });

  testWidgets('a failed email says so and stays on the page', (tester) async {
    final invoices = await _openInvoices(tester, permissions: _editor)
      ..sendError = const ServerFailure('mail.send_failed', statusCode: 502);
    await _open(tester, 'INV-2026-00041');
    await revealBelow(tester, find.text('Send by email'));
    await tester.tap(find.text('Send by email'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send to 1 person'));
    await tester.pumpAndSettle();

    expect(
      find.text('The email couldn\'t be sent. Try again in a moment.'),
      findsOneWidget,
    );
    expect(find.text('Send to 1 person'), findsOneWidget);
    expect(invoices.sends, isEmpty);
  });

  testWidgets('a draft is not emailed', (tester) async {
    await _openInvoices(tester, permissions: _editor);
    await _open(tester, 'INV-2026-00042');

    await revealBelow(tester, find.text('View PDF'));
    expect(find.text('Send by email'), findsNothing);
  });

  testWidgets('the search finds an invoice by number', (tester) async {
    await _openInvoices(tester);
    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    await search('00041');
    expect(find.text('INV-2026-00041'), findsOneWidget);
    expect(find.text('INV-2026-00042'), findsNothing);
    expect(find.text('INV-2026-00040'), findsNothing);

    await search('nothing like it');
    expect(find.text('Nothing matches'), findsOneWidget);
  });
}

/// What the field labelled [label] holds.
String _text(WidgetTester tester, String label) => tester
    .widget<TextField>(
      find.descendant(of: field(label), matching: find.byType(TextField)),
    )
    .controller!
    .text;
