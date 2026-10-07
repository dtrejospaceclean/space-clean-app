import 'package:flutter/widgets.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(id: 'c1', legalName: 'Tower Holdings LLC', dba: 'Tower');
const _clinic = Client(id: 'c2', legalName: 'Bayou Clinic');

Future<void> signedIn(
  WidgetTester tester, {
  Map<String, Object> jobs = const {},
  Map<String, AccountAccess> access = const {},
}) => pumpApp(
  tester,
  auth: FakeAuthRepository(sessionUser: ana),
  clients: FakeClientsRepository([_tower, _clinic]),
  jobs: FakeJobsRepository(jobs),
  access: FakeAccessRepository(access),
);

void main() {
  testWidgets('Today merges both accounts, soonest first', (tester) async {
    await signedIn(
      tester,
      jobs: {
        'c1': [job('a', 'c1', title: 'Lobby deep clean', hour: 14)],
        'c2': [job('b', 'c2', title: 'Exam rooms', hour: 7)],
      },
    );

    expect(find.textContaining('Hi, Ana', findRichText: true), findsOneWidget);
    expect(find.text('Wednesday, September 23'), findsOneWidget);
    final first = tester.getTopLeft(find.text('Exam rooms')).dy;
    final second = tester.getTopLeft(find.text('Lobby deep clean')).dy;
    expect(first, lessThan(second));
    expect(find.text('Bayou Clinic • Main office'), findsOneWidget);
    expect(find.text('Tower • Main office'), findsOneWidget);
  });

  testWidgets('Today says which accounts could not load', (tester) async {
    await signedIn(
      tester,
      jobs: {
        'c1': [job('a', 'c1')],
        'c2': const NetworkFailure(),
      },
    );

    expect(
      find.text("1 account couldn't load. Pull down to try again."),
      findsOneWidget,
    );
    expect(find.text('Job a'), findsOneWidget);
  });

  testWidgets('opens a job from Today', (tester) async {
    await signedIn(
      tester,
      jobs: {
        'c1': [job('a', 'c1', title: 'Lobby deep clean')],
      },
    );

    await tester.tap(find.text('Lobby deep clean'));
    await tester.pumpAndSettle();

    expect(find.text('No one assigned yet'), findsOneWidget);
    expect(find.text('Main office'), findsOneWidget);
  });

  testWidgets('an account shows only what the member may open', (tester) async {
    await signedIn(
      tester,
      access: {
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'crew',
          permissions: {Permissions.jobsView, Permissions.tasksView},
        ),
      },
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Bayou Clinic'), findsOneWidget);

    await tester.tap(find.text('Tower'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Your role: Crew', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Jobs'), findsOneWidget);
    // No info.view, so no Account details.
    expect(find.text('Account details'), findsNothing);
    // Allowed, but not built yet: nothing is shown for it.
    expect(find.text('Tasks'), findsNothing);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('a non-member account explains there is nothing to open', (
    tester,
  ) async {
    await signedIn(tester);

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bayou Clinic'));
    await tester.pumpAndSettle();

    expect(
      find.text("You don't have access to anything in this account yet."),
      findsOneWidget,
    );
  });

  testWidgets('an account lists its upcoming jobs', (tester) async {
    await signedIn(
      tester,
      jobs: {
        'c1': [job('a', 'c1', title: 'Lobby deep clean')],
      },
      access: {
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'supervisor',
          permissions: {Permissions.jobsView},
        ),
      },
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tower'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, September 23'), findsOneWidget);
    expect(find.text('Lobby deep clean'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Me shows the user and switches language', (tester) async {
    await signedIn(tester);

    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);

    await revealBelow(tester, find.text('Language and appearance'));
    await tester.tap(find.text('Language and appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    // Settings answers in Spanish at once, English still findable.
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Inglés'), findsOneWidget);

    // Spanish now, so the back button says so too.
    await tester.tap(find.byTooltip('Atrás').first);
    await tester.pumpAndSettle();
    expect(find.text('Español · Tema del sistema'), findsOneWidget);
    await revealBelow(tester, find.text('Cerrar sesión'));
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(find.byType(SpaceBottomBar), findsOneWidget);
    expect(find.byTooltip('Hoy'), findsOneWidget);
  });

  testWidgets('Me opens from the avatar, not the dock, and back returns', (
    tester,
  ) async {
    await signedIn(tester);

    // Two tabs; Me is only Today's avatar.
    expect(find.byTooltip('Today'), findsOneWidget);
    expect(find.byTooltip('Accounts'), findsOneWidget);
    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Me'), findsNothing);
    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsNothing);
    expect(find.text('No jobs today'), findsOneWidget);

    // The system back does the same.
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('No jobs today'), findsOneWidget);
  });

  testWidgets('the avatar counts unread notifications', (tester) async {
    final semantics = tester.ensureSemantics();
    final notifications = FakeNotificationsRepository(3);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      notifications: notifications,
    );

    expect(
      find.descendant(of: find.byTooltip('Me'), matching: find.text('3')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Me, 3 unread notifications'), findsOneWidget);

    // None unread: no badge.
    notifications.unread = 0;
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byTooltip('Me'), matching: find.text('3')),
      findsNothing,
    );
    expect(find.bySemanticsLabel('Me'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('no badge with nothing unread', (tester) async {
    await signedIn(tester);
    expect(find.byType(CountBadge), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CountBadge),
        matching: find.byType(PositionedDirectional),
      ),
      findsNothing,
    );
  });

  testWidgets('the tab dock survives 200% text in Spanish', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      preferences: {'settings.language': 'es'},
    );

    // Yo opens from Today's avatar, then its back button returns.
    for (final target in ['Cuentas', 'Hoy', 'Yo', 'Atrás']) {
      await tester.tap(find.byTooltip(target));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Hoy'), findsWidgets);
  });

  group('the + beside the tab dock', () {
    testWidgets('is hidden for people who can create nothing', (tester) async {
      await signedIn(tester);

      expect(find.byTooltip('Create'), findsNothing);
    });

    testWidgets('offers only what the user may create', (tester) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(sessionUser: accountManager),
      );

      await tester.tap(find.byTooltip('Create'));
      await tester.pumpAndSettle();

      expect(find.text('New account'), findsOneWidget);
      expect(find.text('New service'), findsOneWidget);
      // Adding users is for owners.
      expect(find.text('New user'), findsNothing);
    });

    testWidgets('opens the chosen form in the tab that owns it', (
      tester,
    ) async {
      await pumpApp(tester, auth: FakeAuthRepository(sessionUser: owner));

      await tester.tap(find.byTooltip('Create'));
      await tester.pumpAndSettle();
      expect(find.text('New user'), findsOneWidget);
      await tester.tap(find.text('New service'));
      await tester.pumpAndSettle();

      expect(find.text('New service'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      // On the Me tab, where the catalog lives; back returns to it.
      final bar = tester.widget<SpaceBottomBar>(find.byType(SpaceBottomBar));
      expect(bar.currentIndex, 2);
    });
  });
}
