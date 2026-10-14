import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/app_notification.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

const _quote = Task(
  id: 't-quote',
  clientId: 'c1',
  title: 'Send the floor 3 quote',
  priority: Priority.high,
  status: TaskStatus.pending,
);

// The test clock is Sep 23, 2026, 8:00.

/// Unread, from someone, about a task: opens it.
final _taskAssigned = AppNotification(
  id: 'n-task',
  type: NotificationTypes.taskAssigned,
  params: const {
    'taskTitle': 'Send the floor 3 quote',
    'actorName': 'Carlos Medina',
  },
  clientId: 'c1',
  accountName: 'Torre Norte',
  entity: NotificationEntity.task,
  entityId: 't-quote',
  createdAt: DateTime(2026, 9, 23, 7, 30),
);

/// Unread, with its priority.
final _reported = AppNotification(
  id: 'n-reported',
  type: NotificationTypes.complaintReported,
  params: const {
    'complaintTitle': 'Restrooms out of paper',
    'priority': 'high',
    'actorName': null,
  },
  clientId: 'c1',
  accountName: 'Torre Norte',
  entity: NotificationEntity.complaint,
  entityId: 'q-paper',
  createdAt: DateTime(2026, 9, 22, 18),
);

/// Already read.
final _cancelled = AppNotification(
  id: 'n-cancelled',
  type: NotificationTypes.jobCancelled,
  params: const {
    'jobTitle': 'Night clean',
    'start': '2026-09-25T01:00:00.000Z',
    'actorName': 'Marco Díaz',
  },
  clientId: 'c1',
  accountName: 'Torre Norte',
  entity: NotificationEntity.job,
  entityId: 'j-night',
  isRead: true,
  createdAt: DateTime(2026, 9, 10, 9),
);

Future<FakeNotificationsRepository> _openInbox(
  WidgetTester tester, {
  List<AppNotification>? items,
}) async {
  final list = items ?? [_taskAssigned, _reported, _cancelled];
  final repo = FakeNotificationsRepository(
    list.where((n) => !n.isRead).length,
    items: list,
  );
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    tasks: FakeTasksRepository([_quote]),
    notifications: repo,
    access: FakeAccessRepository({
      'c1': const AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: {Permissions.infoView, Permissions.tasksView},
      ),
    }),
  );
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Notifications'));
  await tester.pumpAndSettle();
  return repo;
}

/// The unread dot, read out as "Unread" (merged into its row's label).
Finder get _unread => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == 'Unread',
);

void main() {
  testWidgets('Me counts the unread ones and opens the inbox', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      notifications: FakeNotificationsRepository(2),
    );
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('2 unread'), findsOneWidget);
  });

  testWidgets('the inbox words each one in the app language', (tester) async {
    await _openInbox(tester);

    // Who did what, then what it's about, the account and when.
    expect(find.text('Carlos Medina assigned you a task'), findsOneWidget);
    expect(
      find.text('Send the floor 3 quote · Torre Norte · 7:30 AM'),
      findsOneWidget,
    );
    // Nobody named: worded without a person, with the priority.
    expect(find.text('A complaint was reported'), findsOneWidget);
    expect(
      find.text('Restrooms out of paper · Torre Norte · Yesterday'),
      findsOneWidget,
    );
    expect(find.text('High'), findsOneWidget);
    // A job says when it was.
    expect(find.text("Marco Díaz cancelled a job you're on"), findsOneWidget);
    expect(find.textContaining('Night clean · Sep 2'), findsOneWidget);
    expect(_unread, findsNWidgets(2));
  });

  testWidgets('tapping one marks it read and opens it in its account', (
    tester,
  ) async {
    final repo = await _openInbox(tester);

    await tester.tap(find.text('Carlos Medina assigned you a task'));
    await tester.pumpAndSettle();

    expect(repo.reads, ['n-task']);
    // The task's page, in the Accounts tab.
    expect(find.text('Send the floor 3 quote'), findsWidgets);
    expect(find.text('Notifications'), findsNothing);
  });

  testWidgets('mark all as read clears the dots and the count', (tester) async {
    final repo = await _openInbox(tester);

    await tester.tap(find.byTooltip('Mark all as read'));
    await tester.pumpAndSettle();

    expect(repo.readAlls, 1);
    expect(_unread, findsNothing);
    // Nothing left to mark.
    expect(find.byTooltip('Mark all as read'), findsNothing);
  });

  testWidgets('a failed mark all says why and keeps them unread', (
    tester,
  ) async {
    final repo = await _openInbox(tester);
    repo.readAllError = const NetworkFailure();

    await tester.tap(find.byTooltip('Mark all as read'));
    await tester.pumpAndSettle();

    expect(repo.readAlls, 0);
    expect(_unread, findsNWidgets(2));
    expect(find.byTooltip('Mark all as read'), findsOneWidget);
  });

  testWidgets('an empty inbox says what will show up', (tester) async {
    await _openInbox(tester, items: const []);

    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.byTooltip('Mark all as read'), findsNothing);
  });
}
