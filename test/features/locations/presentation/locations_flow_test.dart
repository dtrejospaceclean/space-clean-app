import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// TODO(address-search): uncomment with the tests below.
// import 'package:sp_cln_app/core/error/failures.dart';
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

  // TODO(address-search): disabled for now; uncomment to bring it back.
  // testWidgets('typing the address offers matches that fill the form', (
  //   tester,
  // ) async {
  //   final locations = await openLocations(
  //     tester,
  //     accountManager,
  //     permissions: _editor,
  //   );
  //   locations.suggestions = const [
  //     AddressSuggestion(
  //       id: 's1',
  //       name: '1980 Post Oak Boulevard',
  //       description: 'Houston, Texas 77056',
  //       address: '1980 Post Oak Boulevard',
  //       city: 'Houston',
  //       state: 'TX',
  //     ),
  //   ];
  //   await tester.tap(find.byTooltip('Create'));
  //   await tester.pumpAndSettle();
  //   await tester.enterText(field('Name'), 'Tower A');

  //   // Two letters aren't searched; then it waits for a pause in typing.
  //   await tester.enterText(field('Street address'), '19');
  //   await tester.pump(const Duration(milliseconds: 400));
  //   expect(locations.suggestQueries, isEmpty);
  //   await tester.enterText(field('Street address'), '1980 Po');
  //   await tester.pump(const Duration(milliseconds: 100));
  //   await tester.enterText(field('Street address'), '1980 Post Oak');
  //   await tester.pump(const Duration(milliseconds: 350));
  //   await tester.pumpAndSettle();
  //   expect(locations.suggestQueries, ['1980 Post Oak/en']);
  //   expect(find.text('Houston, Texas 77056'), findsOneWidget);
  //   expect(find.text('Suggestions by Mapbox'), findsOneWidget);

  //   await tester.tap(find.text('1980 Post Oak Boulevard'));
  //   await tester.pumpAndSettle();
  //   expect(find.text('Houston, Texas 77056'), findsNothing);
  //   // What the pick knew is filled; the ZIP it didn't is left to the user.
  //   expect(
  //     tester.widget<TextFormField>(field('Street address')).controller!.text,
  //     '1980 Post Oak Boulevard',
  //   );
  //   expect(
  //     tester.widget<TextFormField>(field('City')).controller!.text,
  //     'Houston',
  //   );
  //   expect(tester.widget<TextFormField>(field('State')).controller!.text, 'TX');
  //   await tester.enterText(field('ZIP code'), '77056');
  //   await tester.tap(find.text('Save'));
  //   await tester.pumpAndSettle();

  //   expect(locations.writes, ['create:Tower A']);
  //   final draft = locations.drafts.single;
  //   expect(
  //     [draft.address, draft.city, draft.state, draft.zipCode],
  //     ['1980 Post Oak Boulevard', 'Houston', 'TX', '77056'],
  //   );
  // });

  // testWidgets('without address search the address is typed by hand', (
  //   tester,
  // ) async {
  //   final locations = await openLocations(
  //     tester,
  //     accountManager,
  //     permissions: _editor,
  //   );
  //   locations.suggestFailure = const ServerFailure(
  //     'geo.limit_reached',
  //     statusCode: 429,
  //   );
  //   await tester.tap(find.byTooltip('Create'));
  //   await tester.pumpAndSettle();
  //   await tester.enterText(field('Street address'), '400 Dock');
  //   await tester.pump(const Duration(milliseconds: 350));
  //   await tester.pumpAndSettle();
  //   expect(
  //     find.text(
  //       "Address search isn't available right now. "
  //       'Please enter the address manually.',
  //     ),
  //     findsOneWidget,
  //   );

  //   // It stops asking for the rest of the form.
  //   await tester.enterText(field('Street address'), '400 Dock Rd');
  //   await tester.pump(const Duration(milliseconds: 350));
  //   await tester.pumpAndSettle();
  //   expect(locations.suggestQueries, ['400 Dock/en']);
  // });

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
