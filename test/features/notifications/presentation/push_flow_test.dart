import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/app_notification.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/push_message.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_language.dart';
import 'package:sp_cln_app/features/settings/presentation/controllers/language_controller.dart';
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

/// Ours, about [_quote], as the server sends it.
final _taskPush = PushMessage.fromData(
  const {
    'source': 'spclean',
    'notificationId': 'n-task',
    'type': 'notifications.task_assigned',
    'clientId': 'c1',
    'entityType': 'task',
    'entityId': 't-quote',
  },
  title: 'Carlos Medina assigned you a task',
  body: 'Send the floor 3 quote · Torre Norte',
);

final _inboxRow = AppNotification(
  id: 'n-task',
  type: NotificationTypes.taskAssigned,
  clientId: 'c1',
  entity: NotificationEntity.task,
  entityId: 't-quote',
  createdAt: DateTime(2026, 9, 23, 7, 30),
);

Future<void> _start(
  WidgetTester tester, {
  required FakePushRepository push,
  FakeNotificationsRepository? notifications,
  Map<String, Object> preferences = const {},
}) => pumpApp(
  tester,
  auth: FakeAuthRepository(sessionUser: ana),
  clients: FakeClientsRepository([_tower]),
  tasks: FakeTasksRepository([_quote]),
  notifications: notifications,
  push: push,
  preferences: preferences,
  access: FakeAccessRepository({
    'c1': const AccountAccess(
      clientId: 'c1',
      baseRole: 'supervisor',
      permissions: {Permissions.infoView, Permissions.tasksView},
    ),
  }),
);

void main() {
  test('pushes are routed by who sent them', () {
    expect(PushSource.of({'source': 'spclean'}), PushSource.spclean);
    expect(PushSource.of({'sender': 'stream.chat'}), PushSource.streamChat);
    expect(PushSource.of({}), PushSource.other);
    // What a tap carries back is what arrived.
    expect(PushMessage.fromData(_taskPush.data).data, _taskPush.data);
  });

  testWidgets('a signed-in phone is registered in the app language', (
    tester,
  ) async {
    final push = FakePushRepository();
    await _start(tester, push: push);

    expect(push.registered, [('token-1', 'en')]);
    expect(push.channelName, 'Work updates');

    // Switching language words the next pushes in it.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    await container
        .read(languageControllerProvider.notifier)
        .select(AppLanguage.es);
    await tester.pumpAndSettle();
    expect(push.registered.last, ('token-1', 'es'));

    // And a new token is registered too.
    push.refreshToken('token-2');
    await tester.pumpAndSettle();
    expect(push.registered.last, ('token-2', 'es'));
  });

  testWidgets('nothing is registered when notifications are refused', (
    tester,
  ) async {
    final push = FakePushRepository(allowed: false);
    await _start(tester, push: push);

    expect(push.registered, isEmpty);
  });

  testWidgets('a push while the app is open shows and updates the count', (
    tester,
  ) async {
    final push = FakePushRepository();
    final notifications = FakeNotificationsRepository(0);
    await _start(tester, push: push, notifications: notifications);

    notifications.unread = 1;
    push.receive(_taskPush);
    await tester.pumpAndSettle();

    expect(push.shown, [_taskPush]);
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    expect(find.text('1 unread'), findsOneWidget);
  });

  testWidgets("Stream Chat's pushes are left alone", (tester) async {
    final push = FakePushRepository();
    await _start(tester, push: push);

    push.receive(
      PushMessage.fromData(const {'sender': 'stream.chat', 'type': 'x'}),
    );
    await tester.pumpAndSettle();

    expect(push.shown, isEmpty);
  });

  testWidgets('tapping a push opens it and marks it read', (tester) async {
    final push = FakePushRepository();
    final notifications = FakeNotificationsRepository(1, items: [_inboxRow]);
    await _start(tester, push: push, notifications: notifications);

    push.tap(_taskPush);
    await tester.pumpAndSettle();

    expect(notifications.reads, ['n-task']);
    expect(find.text('Send the floor 3 quote'), findsWidgets);
  });

  testWidgets('a push that launched the app opens once signed in', (
    tester,
  ) async {
    final push = FakePushRepository(launch: _taskPush);
    final notifications = FakeNotificationsRepository(1, items: [_inboxRow]);
    await _start(tester, push: push, notifications: notifications);

    expect(notifications.reads, ['n-task']);
    expect(find.text('Send the floor 3 quote'), findsWidgets);
  });

  testWidgets('signing out stops the pushes', (tester) async {
    final push = FakePushRepository();
    await _start(tester, push: push);

    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();

    expect(push.unregistered, ['token-1']);
    expect(push.forgets, greaterThan(0));
  });
}
