import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
  industry: 'Offices',
  accountManager: ClientAssignee(id: 'm1', name: 'Marco Díaz'),
);

Future<FakeClientsRepository> openAccounts(
  WidgetTester tester,
  User user, {
  FakeClientsRepository? clients,
}) async {
  final repo = clients ?? FakeClientsRepository([_tower]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: repo,
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> openDetails(WidgetTester tester) async {
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  // The Account section sits below the Work tiles.
  await revealBelow(tester, find.text('Account details'));
  await tester.tap(find.text('Account details'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('people without a staff admin role can\'t add accounts', (
    tester,
  ) async {
    await openAccounts(tester, ana);

    expect(find.byTooltip('Create'), findsNothing);
  });

  testWidgets('an owner creates an account and lands on it', (tester) async {
    final clients = await openAccounts(tester, owner);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The legal name is required before calling the API.
    expect(find.text('This field is required.'), findsOneWidget);
    expect(clients.writes, isEmpty);

    await tester.enterText(field('Legal name'), 'Clínica Sur S.C.');
    await tester.enterText(field('Trade name (DBA)'), 'Clínica Sur');
    await tester.ensureVisible(find.text('Active'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(clients.writes, ['create:Clínica Sur S.C.']);
    expect(clients.drafts.single.status, ClientStatus.active);
    // The new account's own screen.
    expect(find.textContaining('Clínica Sur'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
  });

  testWidgets('an account manager is told they need to join a new account', (
    tester,
  ) async {
    final clients = await openAccounts(tester, accountManager);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Legal name'), 'Clínica Sur S.C.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(clients.writes, ['create:Clínica Sur S.C.']);
    expect(find.text('Account created'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Create'), findsOneWidget);
  });

  testWidgets('an owner edits an account\'s details', (tester) async {
    final clients = await openAccounts(tester, owner);
    await openDetails(tester);

    expect(find.text('Offices'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit account'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Industry'), 'Healthcare');
    // The form starts from the current people in charge.
    await revealBelow(tester, find.text('Marco Díaz'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(clients.writes, ['update:c1']);
    // Untouched fields aren't changed: status and assignees are left out.
    expect(clients.drafts.single.status, isNull);
    expect(clients.drafts.single.accountManagerUserId, isNull);
    expect(clients.drafts.single.cleared, isEmpty);
    expect(find.text('Healthcare'), findsOneWidget);
  });

  testWidgets('deleting an account with history asks to delete everything', (
    tester,
  ) async {
    final clients = FakeClientsRepository([_tower])
      ..deleteError = const ServerFailure(
        'clients.has_related_records',
        statusCode: 409,
      );
    await openAccounts(tester, owner, clients: clients);
    await openDetails(tester);

    await tester.tap(find.byTooltip('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    // Nothing is gone yet: the purge page explains first.
    expect(find.text('Delete everything'), findsOneWidget);
    expect(find.textContaining('set the account to Inactive'), findsOneWidget);
    expect(clients.writes, isEmpty);
    expect(clients.clients, hasLength(1));
  });

  testWidgets('an owner purges an account with history after typing its name', (
    tester,
  ) async {
    final clients = FakeClientsRepository([_tower])
      ..deleteError = const ServerFailure(
        'clients.has_related_records',
        statusCode: 409,
      );
    await openAccounts(tester, owner, clients: clients);
    await openDetails(tester);

    await tester.tap(find.byTooltip('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining("This can't be undone"), findsOneWidget);
    final purge = find.widgetWithText(
      FilledButton,
      'Delete account and history',
    );
    // Disabled until the legal name is typed; a trade name isn't enough.
    await tester.enterText(
      field('Type the legal name to confirm'),
      'Torre Norte',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(purge).onPressed, isNull);

    await tester.enterText(
      field('Type the legal name to confirm'),
      ' torre norte s.a. ',
    );
    await tester.pump();
    await tester.tap(purge);
    await tester.pumpAndSettle();

    expect(clients.writes, ['purge:c1']);
    expect(find.text('No accounts yet'), findsWidgets);
  });

  testWidgets('an owner deletes an unused account', (tester) async {
    final clients = await openAccounts(tester, owner);
    await openDetails(tester);

    await tester.tap(find.byTooltip('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(clients.writes, ['delete:c1']);
    expect(find.text('No accounts yet'), findsWidgets);
  });
}
