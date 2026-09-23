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
    expect(find.text('Bayou Clinic · Main office'), findsOneWidget);
    expect(find.text('Tower · Main office'), findsOneWidget);
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

    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Bayou Clinic'), findsOneWidget);

    await tester.tap(find.text('Tower'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Your role: Crew', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Team'), findsNothing);
    expect(find.text('Contracts'), findsNothing);
  });

  testWidgets('a non-member account explains there is nothing to open', (
    tester,
  ) async {
    await signedIn(tester);

    await tester.tap(find.text('Accounts'));
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

    await tester.tap(find.text('Accounts'));
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

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(find.byType(SpaceBottomBar), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
  });
}
