import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';
import 'package:sp_cln_app/features/proposals/presentation/screens/proposals_screen.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

const _offices = ProposalLineItem(
  id: 'i1',
  serviceId: 's1',
  description: 'Office cleaning',
  quantity: '12000',
  unitPrice: '0.12',
  lineTotal: '1440',
);

const _windows = ProposalLineItem(
  id: 'i2',
  description: 'Window washing',
  quantity: '4',
  unitPrice: '150',
  lineTotal: '600',
);

/// Version 1 of the Torre Norte negotiation, kept as history.
const _v1 = Proposal(
  id: 'p-v1',
  clientId: 'c1',
  groupId: 'g1',
  stage: ProposalStage.pricing,
  versionNumber: 1,
  isCurrent: false,
  lineItems: [
    ProposalLineItem(
      id: 'i0',
      description: 'Office cleaning',
      quantity: '12000',
      unitPrice: '0.15',
      lineTotal: '1800',
    ),
  ],
);

final _v2 = Proposal(
  id: 'p-v2',
  clientId: 'c1',
  groupId: 'g1',
  stage: ProposalStage.negotiation,
  versionNumber: 2,
  isCurrent: true,
  versionNote: 'Annual discount',
  preparedByName: 'Carlos Medina',
  validUntil: DateTime(2026, 10, 31),
  lineItems: const [_offices, _windows],
);

const _lead = Proposal(
  id: 'p-lead',
  clientId: 'c1',
  groupId: 'g2',
  stage: ProposalStage.lead,
  versionNumber: 1,
  isCurrent: true,
);

/// Opens Torre Norte → Proposals as [user], a member with [permissions].
Future<FakeProposalsRepository> openProposals(
  WidgetTester tester,
  User user, {
  Set<String> permissions = const {Permissions.proposalView},
}) async {
  final repo = FakeProposalsRepository([_v1, _v2, _lead]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower]),
    proposals: repo,
    access: FakeAccessRepository({
      'c1': AccountAccess(
        clientId: 'c1',
        baseRole: 'salesperson',
        permissions: permissions,
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Proposals'));
  await tester.pumpAndSettle();
  return repo;
}

/// Opens the current Torre Norte version from the list.
Future<void> openCurrent(WidgetTester tester) async {
  await tester.tap(find.text('Office cleaning and 1 more'));
  await tester.pumpAndSettle();
}

const _editor = {Permissions.proposalView, Permissions.proposalEdit};

void main() {
  testWidgets('a viewer reads the pipeline and the history', (tester) async {
    final proposals = await openProposals(tester, ana);

    // One list, newest first, one row per negotiation, each with its stage.
    expect(find.text('Lead'), findsOneWidget);
    expect(find.text('Negotiation'), findsOneWidget);
    // Version 1 is history, so its stage isn't listed.
    expect(find.text('Pricing'), findsNothing);
    expect(
      tester.getTopLeft(find.text('No line items yet')).dy,
      lessThan(tester.getTopLeft(find.text('Office cleaning and 1 more')).dy),
    );
    // The price trails each row; a bare lead has none rather than $0.
    expect(find.text(r'$2,040.00'), findsOneWidget);
    expect(find.text('Version 2'), findsOneWidget);
    expect(find.text('No line items yet'), findsOneWidget);
    expect(find.text(r'$0.00'), findsNothing);
    expect(find.byTooltip('Create'), findsNothing);

    await openCurrent(tester);
    expect(find.text(r'$2,040.00'), findsWidgets);
    // How long the price holds sits with the price.
    expect(find.text('Valid until Oct 31, 2026'), findsOneWidget);
    expect(find.text('Annual discount'), findsOneWidget);
    expect(find.byTooltip('Edit proposal'), findsNothing);
    await revealBelow(tester, find.text(r'12,000 × $0.12'));
    expect(find.text(r'$1,440.00'), findsOneWidget);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('New version'), findsNothing);

    // The earlier version opens read-only.
    await revealBelow(tester, find.text('Version 1'));
    await tester.tap(find.text('Version 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('earlier version'), findsOneWidget);
    expect(find.text(r'$1,800.00'), findsWidgets);
    expect(proposals.writes, isEmpty);
  });

  testWidgets('an open proposal past its date says it expired', (tester) async {
    // The test clock reads Sep 23, 2026.
    final stale = Proposal(
      id: 'p-old',
      clientId: 'c1',
      groupId: 'g9',
      stage: ProposalStage.proposal,
      versionNumber: 1,
      isCurrent: true,
      validUntil: DateTime(2026, 9, 1),
      lineItems: const [_windows],
    );
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower]),
      proposals: FakeProposalsRepository([stale]),
      access: FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'salesperson',
          permissions: {Permissions.proposalView},
        ),
      }),
    );
    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Torre Norte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proposals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Window washing'));
    await tester.pumpAndSettle();

    expect(find.text('Expired Sep 1, 2026'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('the search matches services, stage and notes as you type', (
    tester,
  ) async {
    final proposals = await openProposals(tester, ana);
    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    // Any line item, not just the first.
    await search('window');
    expect(find.text('Office cleaning and 1 more'), findsOneWidget);
    expect(find.text('No line items yet'), findsNothing);

    // The stage by name, every word counting.
    await search('lead');
    expect(find.text('No line items yet'), findsOneWidget);
    expect(find.text('Office cleaning and 1 more'), findsNothing);
    await search('office negotiation');
    expect(find.text('Office cleaning and 1 more'), findsOneWidget);

    await search('annual discount');
    expect(find.text('Office cleaning and 1 more'), findsOneWidget);

    await search('nowhere');
    expect(find.text('Nothing matches'), findsOneWidget);

    await search('');
    expect(find.byType(ProposalRow), findsNWidgets(2));
    expect(proposals.writes, isEmpty);
  });

  testWidgets('an editor starts a proposal from "+" with a catalog service', (
    tester,
  ) async {
    final proposals = await openProposals(
      tester,
      accountManager,
      permissions: _editor,
    );

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New proposal'), findsOneWidget);

    // Line items come from the "+" beside the dock and get their own page.
    expect(find.text('Add line item'), findsNothing);
    expect(find.text('Pricing'), findsNothing);
    expect(find.byTooltip('Create'), findsNothing);
    await tester.tap(find.byTooltip('Add line item'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(3));

    // Picking a service fills the description and its price.
    await tester.tap(find.text('Not set'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'Office cleaning · $0.12 per sq ft'));
    await tester.pumpAndSettle();
    expect(find.text('Quantity (sq ft)'), findsOneWidget);
    await tester.enterText(field('Quantity (sq ft)'), '12000');
    await tester.pumpAndSettle();
    expect(find.text(r'Line total: $1,440.00'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Back on the form, as a row over the price, with the running total.
    expect(find.text('Done'), findsNothing);
    expect(find.byTooltip('Add line item'), findsOneWidget);
    expect(find.text(r'12,000 sq ft × $0.12'), findsOneWidget);
    expect(find.text(r'Line items total: $1,440.00'), findsOneWidget);
    expect(proposals.writes, isEmpty);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(proposals.writes, ['create']);
    final item = proposals.drafts.single.lineItems.single;
    expect(item.serviceId, 's1');
    expect(item.description, 'Office cleaning');
    expect(item.unitPrice, '0.12');
    expect(proposals.drafts.single.stage, ProposalStage.lead);
    // Lands on the new proposal.
    expect(find.text('Proposal'), findsOneWidget);
    expect(find.text(r'$1,440.00'), findsWidgets);
  });

  testWidgets('an editor approves the current version', (tester) async {
    final proposals = await openProposals(
      tester,
      accountManager,
      permissions: _editor,
    );
    await openCurrent(tester);

    await revealBelow(tester, button('Approve'));
    await tester.tap(button('Approve'));
    await tester.pumpAndSettle();
    expect(find.text('Approve proposal'), findsOneWidget);
    // Starts from the line items' total.
    expect(find.widgetWithText(TextFormField, '2040.00'), findsOneWidget);

    await tester.enterText(field('Agreed price'), '2000');
    await tester.tap(button('Approve'));
    await tester.pumpAndSettle();

    expect(proposals.writes, ['approve:p-v2:2000']);
    expect(find.text('Approved by Olga Ruiz on Sep 23, 2026'), findsOneWidget);
    expect(find.byTooltip('Edit proposal'), findsNothing);
    // The agreed price heads the page.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text(r'$2,000.00'), findsOneWidget);
    expect(find.text('Agreed price'), findsOneWidget);
    await revealBelow(tester, find.text('An approved proposal can\'t change.'));
    expect(button('Approve'), findsNothing);
  });

  testWidgets('a new version keeps the current one as history', (tester) async {
    final proposals = await openProposals(
      tester,
      accountManager,
      permissions: _editor,
    );
    await openCurrent(tester);

    await revealBelow(tester, find.text('New version'));
    await tester.tap(find.text('New version'));
    await tester.pumpAndSettle();
    // Prefilled from version 2, except its note.
    expect(find.widgetWithText(TextFormField, 'Annual discount'), findsNothing);
    await revealBelow(tester, find.text('Window washing'));
    expect(find.text('Office cleaning'), findsOneWidget);

    // An item opens on its own page, where it can be changed or removed.
    await tester.tap(find.text('Window washing'));
    await tester.pumpAndSettle();
    expect(find.text('Edit line item'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '150'), findsOneWidget);
    await revealBelow(tester, find.text('Remove item'));
    await tester.tap(find.text('Remove item'));
    await tester.pumpAndSettle();
    expect(find.text('Window washing'), findsNothing);

    await tester.tap(find.text('Office cleaning'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Unit price'), '0.11');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text(r'Line items total: $1,320.00'), findsOneWidget);

    await tester.enterText(field('Version note'), 'Two-year term');
    await revealBelow(tester, field('Agreed price'));
    await tester.enterText(field('Agreed price'), '1900');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(proposals.writes, ['version:p-v2']);
    // The form's "+" leaves with it.
    expect(find.byTooltip('Add line item'), findsNothing);
    expect(proposals.drafts.single.lineItems.single.unitPrice, '0.11');
    expect(find.textContaining('Version 3'), findsOneWidget);
    expect(find.text(r'$1,900.00'), findsWidgets);
    await revealBelow(tester, find.text('Version 1'));
    expect(find.text('Version 2'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
  });

  testWidgets('an editor moves a proposal to another stage', (tester) async {
    final proposals = await openProposals(
      tester,
      accountManager,
      permissions: _editor,
    );
    await openCurrent(tester);

    await tester.tap(find.byTooltip('Edit proposal'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Annual discount'), findsOne);
    await tester.tap(find.text('Negotiation'));
    await tester.pumpAndSettle();
    // Approved is reached only by approving.
    expect(find.text('Approved'), findsNothing);
    await tester.tap(find.text('Proposal').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(proposals.writes, ['update:p-v2']);
    expect(proposals.drafts.single.stage, ProposalStage.proposal);
    expect(proposals.drafts.single.versionNote, 'Annual discount');
    expect(find.byTooltip('Edit proposal'), findsOneWidget);
  });
}
