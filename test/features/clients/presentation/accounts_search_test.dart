import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

import '../../../helpers/test_app.dart';

const _clients = [
  Client(
    id: 'c1',
    legalName: 'Torre Norte S.A.',
    dba: 'Torre Norte',
    taxId: 'TNO-123',
  ),
  Client(id: 'c2', legalName: 'Clínica Sur S.C.', dba: 'Clínica Sur'),
];

Future<FakeClientsRepository> openAccounts(
  WidgetTester tester, [
  List<Client> clients = _clients,
]) async {
  final repo = FakeClientsRepository(clients);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: owner),
    clients: repo,
  );
  await tester.tap(find.text('Accounts').last);
  await tester.pumpAndSettle();
  return repo;
}

Finder get _search => find.byType(TextField);

void main() {
  testWidgets('searches once typing pauses', (tester) async {
    final clients = await openAccounts(tester);

    await tester.enterText(_search, 'to');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_search, 'tor');
    await tester.pump(const Duration(milliseconds: 100));
    // Still typing: nothing sent yet.
    expect(clients.searches, isEmpty);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(clients.searches, ['tor']);
    expect(find.text('Torre Norte'), findsOneWidget);
    expect(find.text('Clínica Sur'), findsNothing);
    expect(find.text('1 account'), findsOneWidget);
  });

  testWidgets('shows a spinner from the first keystroke to the results', (
    tester,
  ) async {
    final clients = await openAccounts(tester);
    final spinner = find.bySemanticsLabel('Searching…');
    clients.searchGate = Completer();
    expect(spinner, findsNothing);

    await tester.enterText(_search, 'tor');
    await tester.pump();
    // Waiting out the debounce.
    expect(spinner, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    // Sent, and the server hasn't answered.
    expect(clients.searches, ['tor']);
    expect(spinner, findsOneWidget);

    clients.searchGate!.complete();
    await tester.pumpAndSettle();
    expect(spinner, findsNothing);
    expect(find.text('Clínica Sur'), findsNothing);
  });

  testWidgets('matches the tax ID too, and says when nothing matches', (
    tester,
  ) async {
    await openAccounts(tester);

    await tester.enterText(_search, 'tno-1');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Torre Norte'), findsOneWidget);

    await tester.enterText(_search, 'zzz');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('No accounts match'), findsOneWidget);
    // The search box stays so the text can be changed.
    expect(_search, findsOneWidget);
  });

  testWidgets('clearing the search brings every account back', (tester) async {
    await openAccounts(tester);

    await tester.enterText(_search, 'sur');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Torre Norte'), findsNothing);

    await tester.enterText(_search, '');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Torre Norte'), findsOneWidget);
    expect(find.text('Clínica Sur'), findsOneWidget);
  });

  testWidgets('no search box when there are no accounts at all', (
    tester,
  ) async {
    await openAccounts(tester, const []);

    expect(find.text('No accounts yet'), findsWidgets);
    expect(_search, findsNothing);
  });
}
