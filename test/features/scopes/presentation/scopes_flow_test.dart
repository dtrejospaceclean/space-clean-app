import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

final _contract = Contract(
  id: 'k1',
  clientId: 'c1',
  contractValue: '2400',
  startDate: DateTime(2026, 3, 1),
  status: ContractStatus.active,
  scopeOfWorkCount: 2,
);

const _floor3 = Location(
  id: 'l1',
  clientId: 'c1',
  name: 'Floor 3',
  address: 'Av. Reforma 1',
  city: 'CDMX',
  state: 'CDMX',
  zipCode: '06600',
);

/// Weekly offices, one paused evening window; already made jobs.
final _offices = Scope(
  id: 's1',
  contractId: 'k1',
  contractStart: DateTime(2026, 3, 1),
  locationId: 'l1',
  locationName: 'Floor 3',
  locationCity: 'CDMX',
  areaName: 'Offices',
  frequency: ScopeFrequency.weekly,
  exclusions: 'Server room',
  estimatedDurationMinutes: 60,
  jobCount: 12,
  schedules: const [
    ScopeSchedule(
      daysOfWeek: [1, 3, 5],
      startTime: ClockTime(7, 0),
      endTime: ClockTime(8, 0),
    ),
    ScopeSchedule(
      daysOfWeek: [2],
      startTime: ClockTime(18, 0),
      isActive: false,
    ),
  ],
);

/// Daily restrooms with no jobs yet.
const _restrooms = Scope(
  id: 's2',
  contractId: 'k1',
  locationId: 'l1',
  locationName: 'Floor 3',
  areaName: 'Restrooms',
  frequency: ScopeFrequency.daily,
  schedules: [ScopeSchedule(startTime: ClockTime(12, 0))],
);

const _viewer = {Permissions.scopeView, Permissions.contractView};
const _editor = {
  Permissions.scopeView,
  Permissions.scopeEdit,
  Permissions.contractView,
};

/// Opens Torre Norte → Scope of work as a member with [permissions].
Future<FakeScopesRepository> openScopes(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
  List<Scope>? scopes,
  FakeLocationsRepository? locations,
}) async {
  final repo = FakeScopesRepository(scopes ?? [_offices, _restrooms]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    contracts: FakeContractsRepository([_contract]),
    locations: locations ?? FakeLocationsRepository([_floor3]),
    scopes: repo,
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
  await tester.tap(find.text('Scope of work'));
  await tester.pumpAndSettle();
  return repo;
}

/// Refuses to list locations, like the API without `info.view`.
class _ForbiddenLocations extends FakeLocationsRepository {
  @override
  Future<List<Location>> getLocations(
    String clientId, {
    String search = '',
  }) async => throw const ServerFailure(
    'auth.insufficient_permission',
    statusCode: 403,
  );
}

void main() {
  testWidgets('a viewer reads scopes by location with their windows', (
    tester,
  ) async {
    final scopes = await openScopes(tester);

    expect(find.text('Floor 3'), findsOneWidget);
    expect(find.text('Offices'), findsOneWidget);
    // The paused window doesn't count on the row.
    expect(find.text('Mon, Wed, Fri · 7:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    // Daily work doesn't name days.
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(find.text('Offices'));
    await tester.pumpAndSettle();
    expect(find.text('Floor 3 · CDMX'), findsOneWidget);
    expect(find.text('7:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.text('Mon, Wed, Fri'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    await revealBelow(tester, find.text('Server room'));
    expect(find.text('60 min'), findsOneWidget);
    expect(find.text('From Mar 1, 2026'), findsOneWidget);
    expect(find.text('12 jobs'), findsOneWidget);
    expect(find.byTooltip('Edit scope'), findsNothing);
    expect(find.text('Delete scope'), findsNothing);
    expect(scopes.writes, isEmpty);
  });

  testWidgets('an editor adds a weekly scope with a time window', (
    tester,
  ) async {
    final scopes = await openScopes(tester, permissions: _editor);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New scope of work'), findsOneWidget);
    // The account's only contract and location are taken as the default.
    expect(find.text('From Mar 1, 2026'), findsOneWidget);
    expect(find.text('Floor 3'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    await tester.enterText(field('Area'), 'Lobby');

    // Windows come from the dock's "+".
    await tester.tap(find.byTooltip('Add time window'));
    await tester.pumpAndSettle();
    expect(find.text('Add time window'), findsWidgets);
    // Weekly work needs its days.
    await tester.tap(button('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Pick at least one day.'), findsOneWidget);
    await tester.tap(find.text('Tue'));
    await tester.tap(find.text('Thu'));
    await tester.pumpAndSettle();
    await tester.tap(button('Done'));
    await tester.pumpAndSettle();

    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('Tue, Thu'), findsOneWidget);
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(scopes.writes, ['create:k1']);
    final draft = scopes.drafts.single;
    expect(draft.locationId, 'l1');
    expect(draft.areaName, 'Lobby');
    expect(draft.frequency, ScopeFrequency.weekly);
    expect(draft.schedules, const [
      ScopeSchedule(daysOfWeek: [2, 4], startTime: ClockTime(8, 0)),
    ]);
    // Its own page.
    expect(find.text('Scope of work'), findsOneWidget);
    expect(find.text('Lobby'), findsOneWidget);
    // No jobs yet, so it can be deleted.
    await revealBelow(tester, find.text('Delete scope'));
    expect(find.text('Delete scope'), findsOneWidget);
  });

  testWidgets('an edit sends the windows only when they changed', (
    tester,
  ) async {
    final scopes = await openScopes(tester, permissions: _editor);
    await tester.tap(find.text('Offices'));
    await tester.pumpAndSettle();
    // It made jobs, so it stays; the page says what to do instead.
    await revealBelow(tester, find.textContaining('Pause its time windows'));
    expect(find.text('Delete scope'), findsNothing);
    await tester.scrollUntilVisible(
      find.byTooltip('Edit scope'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit scope'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Area'), 'Open offices');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(scopes.writes, ['update:s1']);
    // Untouched windows aren't sent, so the jobs made from them stay linked.
    expect(scopes.drafts.last.schedules, isNull);
    expect(find.text('Open offices'), findsOneWidget);

    // Pausing the morning window sends them all.
    await tester.tap(find.byTooltip('Edit scope'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('7:00 AM – 8:00 AM'));
    await tester.tap(find.text('7:00 AM – 8:00 AM'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Running'));
    await tester.tap(find.text('Running'));
    await tester.tap(button('Done'));
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(scopes.writes, ['update:s1', 'update:s1']);
    final sent = scopes.drafts.last.schedules!;
    expect(sent.map((w) => w.isActive), [false, false]);
    expect(sent.first.daysOfWeek, [1, 3, 5]);
  });

  testWidgets('an editor deletes a scope that made no jobs', (tester) async {
    final scopes = await openScopes(tester, permissions: _editor);
    await tester.tap(find.text('Restrooms'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Delete scope'));
    await tester.tap(find.text('Delete scope'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this scope?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(scopes.writes, ['delete:s2']);
    expect(find.text('Restrooms'), findsNothing);
    expect(find.text('Offices'), findsOneWidget);
  });

  testWidgets("a contract lists its own scopes", (tester) async {
    await openScopes(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contracts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From Mar 1, 2026'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('2 scopes of work'));
    await tester.tap(find.text('2 scopes of work'));
    await tester.pumpAndSettle();
    expect(find.text("Showing one contract's scopes."), findsOneWidget);
    expect(find.text('Offices'), findsOneWidget);
    expect(find.text('Restrooms'), findsOneWidget);
  });

  testWidgets('the form says why it has no locations to offer', (tester) async {
    await openScopes(
      tester,
      permissions: _editor,
      locations: _ForbiddenLocations(),
    );
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    // Listing locations needs info.view; the form says so instead of
    // showing an empty picker.
    expect(find.text("You don't have permission to do that."), findsOneWidget);
  });

  testWidgets('an account without locations is told to add one first', (
    tester,
  ) async {
    final scopes = await openScopes(
      tester,
      permissions: _editor,
      locations: FakeLocationsRepository(),
    );
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    // The location field, still empty.
    await tester.tap(find.text('Not set').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This account has no locations yet. Add one under Locations first.',
      ),
      findsOneWidget,
    );
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(scopes.writes, isEmpty);
  });
}
