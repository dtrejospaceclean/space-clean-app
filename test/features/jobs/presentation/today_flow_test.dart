import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/push_message.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(id: 'c1', legalName: 'Tower Holdings LLC', dba: 'Tower');
const _clinic = Client(id: 'c2', legalName: 'Bayou Clinic');

/// Only on crews: no global staff role.
const _luis = User(
  id: 'u-luis',
  email: 'luis@example.com',
  name: 'Luis Gómez',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r-crew', name: 'crew')],
);

const _onCrew = [JobAssignee(userId: 'u1', name: 'Ana Pérez')];

/// Ana's, on Tower, late in the day.
final _lobby = job(
  'a',
  'c1',
  title: 'Lobby deep clean',
  hour: 16,
  assignees: _onCrew,
);

/// Someone else's, on the clinic, early.
final _exam = job('b', 'c2', title: 'Exam rooms', hour: 7);

/// Ana's, three days late, from Tower.
final _quote = Task(
  id: 't-quote',
  clientId: 'c1',
  title: 'Send the floor 3 quote',
  priority: Priority.high,
  status: TaskStatus.pending,
  assignedToId: 'u1',
  assignedToName: 'Ana Pérez',
  dueDate: DateTime(2026, 9, 20),
  isOverdue: true,
  daysUntilDue: -3,
  accountName: 'Tower',
);

Future<(FakeJobsRepository, FakeTasksRepository)> _today(
  WidgetTester tester, {
  User user = ana,
  List<Task> tasks = const [],
  Duration? liveRefresh,
  FakePushRepository? push,
}) async {
  final jobs = FakeJobsRepository({
    'c1': [_lobby],
    'c2': [_exam],
  })..me = user.id;
  final taskRepo = FakeTasksRepository(tasks)..me = user.id;
  const access = AccountAccess(
    clientId: 'c1',
    baseRole: 'supervisor',
    permissions: {
      Permissions.jobsView,
      Permissions.tasksView,
      Permissions.tasksEdit,
    },
  );
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower, _clinic]),
    jobs: jobs,
    tasks: taskRepo,
    access: FakeAccessRepository({'c1': access}),
    liveRefresh: liveRefresh,
    push: push,
  );
  return (jobs, taskRepo);
}

/// The vertical position of [text] on screen.
double _y(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

void main() {
  testWidgets('staff see their own jobs first, then everyone else\'s', (
    tester,
  ) async {
    final (jobs, _) = await _today(tester);
    expect(jobs.listed, unorderedEquals(['c1', 'c2']));

    // Two jobs today in all, one of them Ana's.
    expect(
      find.textContaining('2 jobs today', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Your jobs'), findsOneWidget);
    expect(find.text('Lobby deep clean'), findsOneWidget);
    await revealBelow(tester, find.text('Exam rooms'));
    expect(find.text('Other jobs today'), findsOneWidget);
    // Hers is listed once, under her own, though it's also in its account.
    expect(
      _y(tester, 'Lobby deep clean'),
      lessThan(_y(tester, 'Other jobs today')),
    );
    expect(_y(tester, 'Other jobs today'), lessThan(_y(tester, 'Exam rooms')));
  });

  testWidgets('crew see only their own jobs', (tester) async {
    final (jobs, _) = await _today(tester, user: _luis);

    // Luis is on no crew today, and the accounts' other jobs aren't his.
    expect(find.text('No jobs today'), findsOneWidget);
    expect(find.text('Exam rooms'), findsNothing);
    expect(find.text('Other jobs today'), findsNothing);
    // One request for their own jobs, none per account.
    expect(jobs.listed, isEmpty);
  });

  testWidgets('staff on no crew today are told so, above everyone\'s jobs', (
    tester,
  ) async {
    final jobs = FakeJobsRepository({
      'c2': [_exam],
    });
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower, _clinic]),
      jobs: jobs,
    );

    expect(find.text('Nothing assigned to you today'), findsOneWidget);
    expect(find.text('Other jobs today'), findsOneWidget);
    expect(find.text('Exam rooms'), findsOneWidget);
  });

  testWidgets('overdue tasks come first and open within Today', (tester) async {
    final (_, tasks) = await _today(tester, tasks: [_quote]);

    expect(find.text('Overdue tasks'), findsOneWidget);
    // Which account it's from, and how late.
    expect(find.text('Tower · Sep 20, 2026'), findsOneWidget);
    expect(find.text('3 days overdue'), findsOneWidget);
    expect(_y(tester, 'Overdue tasks'), lessThan(_y(tester, 'Your jobs')));

    await tester.tap(find.text('Send the floor 3 quote'));
    await tester.pumpAndSettle();
    expect(find.text('Task'), findsOneWidget);
    await revealBelow(tester, find.widgetWithText(FilledButton, 'Complete'));
    await tester.tap(find.widgetWithText(FilledButton, 'Complete'));
    await tester.pumpAndSettle();
    expect(tasks.writes, ['complete:t-quote']);

    // Back on Today, it's no longer late.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Overdue tasks'), findsNothing);
  });

  testWidgets('deleting a task opened from Today goes back to Today', (
    tester,
  ) async {
    final (_, tasks) = await _today(tester, tasks: [_quote]);
    await tester.tap(find.text('Send the floor 3 quote'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Delete task'));
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(tasks.writes, ['delete:t-quote']);
    expect(find.text('Overdue tasks'), findsNothing);
    expect(find.text('Your jobs'), findsOneWidget);
  });

  group('keeps itself current', () {
    /// Someone else schedules a job at the clinic.
    void scheduleWindows(FakeJobsRepository jobs) => jobs.byClient['c2'] = [
      _exam,
      job('w', 'c2', title: 'Window washing', hour: 11),
    ];

    testWidgets('while it stays on screen, every minute', (tester) async {
      final (jobs, _) = await _today(
        tester,
        liveRefresh: const Duration(minutes: 1),
      );
      scheduleWindows(jobs);
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('Window washing'), findsNothing);

      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      await revealBelow(tester, find.text('Window washing'));
      expect(find.text('Window washing'), findsOneWidget);
      // Leaving the app's pages cancels the timer before the test ends.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('when it comes back into view', (tester) async {
      final (jobs, _) = await _today(tester);
      await tester.tap(find.byTooltip('Accounts'));
      await tester.pumpAndSettle();
      scheduleWindows(jobs);
      jobs.listed.clear();

      await tester.tap(find.byTooltip('Today'));
      await tester.pumpAndSettle();
      expect(jobs.listed, unorderedEquals(['c1', 'c2']));
      await revealBelow(tester, find.text('Window washing'));
      expect(find.text('Window washing'), findsOneWidget);
    });

    testWidgets('when a push arrives', (tester) async {
      final push = FakePushRepository();
      final (jobs, _) = await _today(tester, push: push);
      jobs.byClient['c1'] = [
        _lobby,
        job('g', 'c1', title: 'Garage sweep', hour: 18, assignees: _onCrew),
      ];

      push.receive(
        PushMessage.fromData(const {
          'source': 'spclean',
          'notificationId': 'n-crew',
          'type': 'notifications.job_crew_added',
          'clientId': 'c1',
          'entityType': 'job',
          'entityId': 'g',
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('Garage sweep'), findsOneWidget);
    });
  });
}
