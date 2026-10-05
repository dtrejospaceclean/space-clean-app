import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

/// Signed, running, and ending within 30 days of the test clock (Sep 23).
final _running = Contract(
  id: 'k-run',
  clientId: 'c1',
  proposalId: 'p-ok',
  proposalVersion: 2,
  contractValue: '2400',
  startDate: DateTime(2025, 10, 15),
  expirationDate: DateTime(2026, 10, 14),
  paymentTerms: 'Net 30',
  status: ContractStatus.active,
  autoRenew: true,
  cancellationNoticeDays: 30,
  signedByName: 'Carlos Medina',
  signedDate: DateTime(2025, 10, 1),
  daysUntilExpiration: 21,
  isExpiringSoon: true,
);

final _draft = Contract(
  id: 'k-draft',
  clientId: 'c1',
  contractValue: '900',
  startDate: DateTime(2026, 11, 1),
  status: ContractStatus.draft,
);

const _approved = Proposal(
  id: 'p-ok',
  clientId: 'c1',
  groupId: 'g1',
  stage: ProposalStage.approved,
  versionNumber: 2,
  isCurrent: true,
  agreedPrice: '2400',
  lineItems: [
    ProposalLineItem(
      id: 'i1',
      description: 'Office cleaning',
      quantity: '1',
      unitPrice: '2400',
      lineTotal: '2400',
    ),
  ],
);

const _viewer = {Permissions.contractView, Permissions.proposalView};
const _editor = {
  Permissions.contractView,
  Permissions.contractEdit,
  Permissions.proposalView,
};

/// Opens Torre Norte → Contracts as [user], a member with [permissions].
Future<FakeContractsRepository> openContracts(
  WidgetTester tester, {
  User user = ana,
  Set<String> permissions = _viewer,
  List<Contract>? contracts,
}) async {
  final repo = FakeContractsRepository(contracts ?? [_running, _draft]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower]),
    contracts: repo,
    proposals: FakeProposalsRepository([_approved]),
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
  await tester.tap(find.text('Contracts'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _openDraft(WidgetTester tester) async {
  await tester.tap(find.text('From Nov 1, 2026'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a viewer reads contracts and narrows to expiring ones', (
    tester,
  ) async {
    final contracts = await openContracts(tester);

    expect(find.text('Oct 15, 2025 – Oct 14, 2026'), findsOneWidget);
    expect(find.text('From Nov 1, 2026'), findsOneWidget);
    expect(find.text(r'$2,400.00'), findsOneWidget);
    expect(find.text('From proposal version 2'), findsOneWidget);
    // "Expiring soon" stands in for Active on a contract about to end.
    expect(find.text('Expiring soon'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(find.text('Expiring soon (1)'));
    await tester.pumpAndSettle();
    expect(find.text('From Nov 1, 2026'), findsNothing);
    expect(find.text('Oct 15, 2025 – Oct 14, 2026'), findsOneWidget);

    await tester.tap(find.text('Oct 15, 2025 – Oct 14, 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Expires in 21 days'), findsOneWidget);
    expect(find.text('Net 30'), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('Signed by Carlos Medina on Oct 1, 2025'), findsOneWidget);
    expect(find.byTooltip('Edit contract'), findsNothing);
    expect(find.text('Cancel contract'), findsNothing);
    expect(find.text('Sign contract'), findsNothing);

    // The proposal it came from opens.
    await revealBelow(tester, find.text('From proposal version 2'));
    await tester.tap(find.text('From proposal version 2'));
    await tester.pumpAndSettle();
    expect(find.text('Proposal'), findsWidgets);
    expect(find.text('Office cleaning'), findsWidgets);
    expect(contracts.writes, isEmpty);
  });

  testWidgets('an editor creates a draft from "+"', (tester) async {
    final contracts = await openContracts(tester, permissions: _editor);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New contract'), findsOneWidget);
    // The start defaults to today.
    expect(find.text('Sep 23, 2026'), findsOneWidget);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    expect(contracts.writes, isEmpty);

    await tester.enterText(field('Contract value'), '1800.50');
    await tester.enterText(field('Payment terms'), 'Net 15');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(contracts.writes, ['create:null']);
    final draft = contracts.drafts.single;
    expect(draft.contractValue, '1800.50');
    expect(draft.startDate, DateTime(2026, 9, 23));
    expect(draft.paymentTerms, 'Net 15');
    // Its own page.
    expect(find.text('Contract'), findsOneWidget);
    expect(find.text(r'$1,800.50'), findsOneWidget);
    expect(find.text('Not signed yet'), findsOneWidget);
  });

  testWidgets('an approved proposal starts a contract at its price', (
    tester,
  ) async {
    final contracts = await openContracts(
      tester,
      permissions: _editor,
      contracts: const [],
    );
    expect(find.text('No contracts yet'), findsOneWidget);

    // Back to the account, then Proposals → the approved one.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proposals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Office cleaning'));
    await tester.pumpAndSettle();
    await revealBelow(tester, button('Create contract'));
    await tester.tap(button('Create contract'));
    await tester.pumpAndSettle();

    expect(find.text('New contract'), findsOneWidget);
    expect(find.text('Office cleaning · Version 2'), findsOneWidget);
    final value = tester.widget<EditableText>(
      find.descendant(
        of: field('Contract value'),
        matching: find.byType(EditableText),
      ),
    );
    expect(value.controller.text, '2400');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(contracts.writes, ['create:p-ok']);
    expect(contracts.drafts.single.contractValue, '2400');
  });

  testWidgets('an editor signs a draft, which activates it', (tester) async {
    final contracts = await openContracts(tester, permissions: _editor);
    await _openDraft(tester);

    await revealBelow(tester, button('Sign contract'));
    await tester.tap(button('Sign contract'));
    await tester.pumpAndSettle();
    expect(find.text('Signed on'), findsOneWidget);
    await tester.tap(button('Sign contract'));
    await tester.pumpAndSettle();

    // Today is the server's default, so no date is sent.
    expect(contracts.writes, ['sign:k-draft:null']);
    expect(find.text('Signed by Ana Pérez on Sep 23, 2026'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(button('Sign contract'), findsNothing);
    // No longer a draft, so it can't be deleted.
    expect(find.byTooltip('Delete contract'), findsNothing);
  });

  testWidgets('an editor cancels a contract, which turns read-only', (
    tester,
  ) async {
    final contracts = await openContracts(tester, permissions: _editor);
    await tester.tap(find.text('Oct 15, 2025 – Oct 14, 2026'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Edit contract'), findsOneWidget);

    await revealBelow(tester, find.text('Cancel contract'));
    // Any active contract can be marked expired, even one still running.
    expect(find.text('Mark expired'), findsOneWidget);
    await tester.tap(find.text('Cancel contract'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this contract?'), findsOneWidget);
    // Keeping it changes nothing.
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(contracts.writes, isEmpty);

    await tester.tap(find.text('Cancel contract'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel contract').last);
    await tester.pumpAndSettle();

    expect(contracts.writes, ['cancel:k-run']);
    expect(find.textContaining('This contract is cancelled'), findsOneWidget);
    expect(find.byTooltip('Edit contract'), findsNothing);
    expect(find.text('Cancel contract'), findsNothing);
  });

  testWidgets('an editor edits and deletes a draft', (tester) async {
    final contracts = await openContracts(tester, permissions: _editor);
    await _openDraft(tester);

    await tester.tap(find.byTooltip('Edit contract'));
    await tester.pumpAndSettle();
    expect(find.text('Edit contract'), findsOneWidget);
    // The proposal is fixed once the contract exists.
    expect(find.text('Proposal'), findsNothing);
    await tester.enterText(field('Contract value'), '950');
    await tester.enterText(field('Cancellation notice'), '15');
    await revealBelow(tester, find.text('Renews automatically'));
    await tester.tap(find.text('Renews automatically'));
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(contracts.writes, ['update:k-draft']);
    final draft = contracts.drafts.single;
    expect(draft.contractValue, '950');
    expect(draft.cancellationNoticeDays, '15');
    expect(draft.autoRenew, isTrue);
    expect(find.text(r'$950.00'), findsOneWidget);
    expect(find.text('15 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete contract'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this draft?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(contracts.writes, ['update:k-draft', 'delete:k-draft']);
    expect(find.text('From Nov 1, 2026'), findsNothing);
    expect(find.text('Oct 15, 2025 – Oct 14, 2026'), findsOneWidget);
  });

  testWidgets('an editor marks a contract past its end as expired', (
    tester,
  ) async {
    // Active, but its end (Sep 18) is before the test clock (Sep 23).
    final lapsed = Contract(
      id: 'k-lapsed',
      clientId: 'c1',
      contractValue: '1200',
      startDate: DateTime(2025, 9, 19),
      expirationDate: DateTime(2026, 9, 18),
      status: ContractStatus.active,
      signedDate: DateTime(2025, 9, 1),
      daysUntilExpiration: -5,
    );
    final contracts = await openContracts(
      tester,
      permissions: _editor,
      contracts: [lapsed],
    );
    expect(find.text('Active'), findsOneWidget);
    await tester.tap(find.text('Sep 19, 2025 – Sep 18, 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Ended Sep 18, 2026'), findsOneWidget);

    await revealBelow(tester, find.text('Mark expired'));
    await tester.tap(find.text('Mark expired'));
    await tester.pumpAndSettle();
    expect(find.text('Mark this contract expired?'), findsOneWidget);
    await tester.tap(find.text('Mark expired').last);
    await tester.pumpAndSettle();

    expect(contracts.writes, ['expire:k-lapsed']);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Mark expired'), findsNothing);
    expect(find.text('Ended Sep 18, 2026'), findsNothing);
    // Expired isn't cancelled: it can still be edited or cancelled.
    expect(find.byTooltip('Edit contract'), findsOneWidget);
  });
}
