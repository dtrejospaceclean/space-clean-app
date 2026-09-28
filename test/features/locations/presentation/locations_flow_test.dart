import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

const _floor3 = Location(
  id: 'l1',
  clientId: 'c1',
  name: 'Tower A – Floor 3',
  address: '1980 Post Oak Blvd',
  city: 'Houston',
  state: 'TX',
  zipCode: '77056',
  accessCodes: 'Door 4521',
  squareFootage: '12000',
  floorCount: 1,
  scopeOfWorkCount: 2,
  jobCount: 14,
);

const _annex = Location(
  id: 'l2',
  clientId: 'c1',
  name: 'Annex',
  address: '12 Main St',
  city: 'Katy',
  state: 'TX',
  zipCode: '77449',
);

/// Opens Torre Norte → Locations as [user], a member with [permissions].
Future<FakeLocationsRepository> openLocations(
  WidgetTester tester,
  User user, {
  Set<String> permissions = const {Permissions.infoView},
}) async {
  final repo = FakeLocationsRepository([_floor3, _annex]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower]),
    locations: repo,
    access: FakeAccessRepository({
      'c1': AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: permissions,
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Locations'));
  await tester.tap(find.text('Locations'));
  await tester.pumpAndSettle();
  return repo;
}

const _editor = {Permissions.infoView, Permissions.infoEdit};

void main() {
  testWidgets('a member who can only view reads a location', (tester) async {
    final locations = await openLocations(tester, ana);

    // By name, with where each one is.
    expect(find.text('12 Main St, Katy, TX 77449'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(find.text('Tower A – Floor 3'));
    await tester.pumpAndSettle();
    expect(find.text('12,000 sq ft'), findsOneWidget);
    expect(find.text('Door 4521'), findsOneWidget);
    expect(find.byTooltip('Edit location'), findsNothing);
    await revealBelow(tester, find.text('14 jobs'));
    expect(find.text('2 scopes of work'), findsOneWidget);
    expect(find.text('Delete location'), findsNothing);
    expect(locations.writes, isEmpty);
  });

  testWidgets('searching asks the server', (tester) async {
    final locations = await openLocations(tester, ana);

    await tester.enterText(find.byType(TextField), 'katy');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(locations.searches, ['katy']);
    expect(find.text('Annex'), findsOneWidget);
    expect(find.text('Tower A – Floor 3'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nowhere');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches'), findsOneWidget);
  });

  testWidgets('an editor adds a location from "+"', (tester) async {
    final locations = await openLocations(
      tester,
      accountManager,
      permissions: _editor,
    );

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New location'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(5));

    await tester.enterText(field('Name'), 'Warehouse');
    await tester.enterText(field('Street address'), '400 Dock Rd');
    await tester.enterText(field('City'), 'Houston');
    await tester.enterText(field('State'), 'TX');
    await tester.enterText(field('ZIP code'), '77029');
    await revealBelow(tester, field('Square footage'));
    await tester.enterText(field('Square footage'), '850.555');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number like 12000 or 850.5.'), findsOneWidget);
    expect(locations.writes, isEmpty);

    await tester.enterText(field('Square footage'), '850.5');
    await tester.enterText(field('Floors'), '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(locations.writes, ['create:Warehouse']);
    expect(locations.drafts.single.squareFootage, '850.5');
    expect(find.text('Warehouse'), findsOneWidget);
  });

  testWidgets('an editor edits a location and clears a field', (tester) async {
    final locations = await openLocations(
      tester,
      accountManager,
      permissions: _editor,
    );
    await tester.tap(find.text('Tower A – Floor 3'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit location'));
    await tester.pumpAndSettle();
    await revealBelow(tester, field('Access codes'));
    await tester.enterText(field('Access codes'), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(locations.writes, ['update:l1']);
    expect(find.text('Door 4521'), findsNothing);
    expect(find.text('Access codes'), findsOneWidget);
  });

  testWidgets('a location in use says why it can\'t be deleted', (
    tester,
  ) async {
    await openLocations(tester, accountManager, permissions: _editor);
    await tester.tap(find.text('Tower A – Floor 3'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.textContaining('can\'t be deleted'));
    expect(find.text('Delete location'), findsNothing);
  });

  testWidgets('an editor deletes an unused location', (tester) async {
    final locations = await openLocations(
      tester,
      accountManager,
      permissions: _editor,
    );
    await tester.tap(find.text('Annex'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Delete location'));
    await tester.tap(find.text('Delete location'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(locations.writes, ['delete:l2']);
    expect(find.text('Annex'), findsNothing);
    expect(find.text('Tower A – Floor 3'), findsOneWidget);
  });
}
