import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(id: 'c1', legalName: 'Tower Holdings LLC', dba: 'Tower');

/// Opens Tower as a member who may see jobs, proposals and the account's
/// records (not the team).
Future<SharedPreferences> openTower(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
}) async {
  final prefs = await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    access: FakeAccessRepository({
      'c1': const AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: {
          Permissions.jobsView,
          Permissions.proposalView,
          Permissions.infoView,
        },
      ),
    }),
    preferences: preferences,
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tower'));
  await tester.pumpAndSettle();
  return prefs;
}

/// The module titles top to bottom.
List<String> shownOrder(WidgetTester tester) {
  const titles = [
    'Jobs',
    'Proposals',
    'Account details',
    'Contacts',
    'Locations',
  ];
  return titles.toList()..sort(
    (a, b) => tester
        .getTopLeft(find.text(a))
        .dy
        .compareTo(tester.getTopLeft(find.text(b)).dy),
  );
}

void main() {
  testWidgets('modules are a list, work first, each with what is inside', (
    tester,
  ) async {
    await openTower(tester);

    expect(shownOrder(tester), [
      'Jobs',
      'Proposals',
      'Account details',
      'Contacts',
      'Locations',
    ]);
    expect(find.text('Schedule, crew and progress'), findsOneWidget);
    expect(find.text('Team'), findsNothing);

    await tester.tap(find.text('Proposals'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Accounts'), findsOneWidget);
    expect(find.text('Schedule, crew and progress'), findsNothing);
  });

  testWidgets('the user drags modules into their own order, kept on device', (
    tester,
  ) async {
    final prefs = await openTower(tester);

    await tester.tap(find.byTooltip('Reorder'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Drag the handles to set the order. It's the same in every account.",
      ),
      findsOneWidget,
    );
    // Rows don't open anything while reordering.
    await tester.tap(find.text('Proposals'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule, crew and progress'), findsOneWidget);

    // Locations, last, dragged to the top.
    final handle = find.byIcon(Icons.drag_handle_rounded).last;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    // Past the first row's middle, in small steps like a finger.
    final distance =
        tester.getCenter(find.text('Jobs')).dy -
        tester.getCenter(handle).dy -
        30;
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(0, distance / 10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();
    expect(shownOrder(tester), [
      'Locations',
      'Jobs',
      'Proposals',
      'Account details',
      'Contacts',
    ]);
    // Hidden modules keep their places: Contracts, Invoices, Scope of
    // work, Calendar, Complaints and Tasks third to eighth, Team at the end.
    expect(prefs.getStringList('accounts.module_order'), [
      'locations',
      'jobs',
      'contracts',
      'invoices',
      'scopes',
      'calendar',
      'complaints',
      'tasks',
      'proposals',
      'info',
      'contacts',
      'team',
    ]);
  });

  testWidgets('a saved order is used from the start', (tester) async {
    await openTower(
      tester,
      preferences: {
        'accounts.module_order': ['contacts', 'proposals'],
      },
    );

    expect(shownOrder(tester), [
      'Contacts',
      'Proposals',
      'Jobs',
      'Account details',
      'Locations',
    ]);
  });
}
