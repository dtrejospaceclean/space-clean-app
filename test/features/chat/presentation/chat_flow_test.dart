import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/chat/domain/entities/chat.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/jobs/presentation/screens/today_screen.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

const _message = ChatMessageRef(
  id: 'm1',
  text: 'Restroom 3B is out of soap\nCan someone bring a refill?',
  authorName: 'Bea Ruiz',
);

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(TodayScreen)));

void main() {
  testWidgets('without chat on the server, Today offers none', (tester) async {
    final chat = FakeChatRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      chat: chat,
    );

    expect(chat.credentialCalls, 1);
    expect(find.byTooltip('Chat'), findsNothing);
  });

  testWidgets('a chat that fails to connect says so and retries', (
    tester,
  ) async {
    final chat = FakeChatRepository(failure: const NetworkFailure());
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      chat: chat,
    );

    await tester.tap(find.byTooltip('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Chat'), findsWidgets);
    expect(find.byType(RetryButton), findsOneWidget);

    await tester.tap(find.byType(RetryButton));
    await tester.pumpAndSettle();
    expect(chat.credentialCalls, 2);
  });

  testWidgets('a message becomes a task that links back to it', (tester) async {
    final tasks = FakeTasksRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower]),
      tasks: tasks,
      access: FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'supervisor',
          permissions: {Permissions.tasksView, Permissions.tasksEdit},
        ),
      }),
    );

    _router(tester)
        .push('/today/chat/account-c1/new-task?client=c1', extra: _message);
    await tester.pumpAndSettle();
    expect(find.text('New task'), findsOneWidget);
    expect(find.text('From a chat message by Bea Ruiz.'), findsOneWidget);
    expect(find.text('Restroom 3B is out of soap'), findsWidgets);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    final draft = tasks.drafts.single;
    expect(draft.title, 'Restroom 3B is out of soap');
    expect(draft.description, _message.text);
    expect(draft.externalMessageId, 'm1');
    // Back in the conversation.
    expect(find.text('New task'), findsNothing);
  });

  testWidgets('a message becomes a complaint that links back to it', (
    tester,
  ) async {
    final complaints = FakeComplaintsRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower]),
      complaints: complaints,
      access: FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'supervisor',
          permissions: {Permissions.complaintsView, Permissions.complaintsEdit},
        ),
      }),
    );

    _router(
      tester,
    ).push('/today/chat/account-c1/new-complaint?client=c1', extra: _message);
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    final draft = complaints.drafts.single;
    expect(draft.title, 'Restroom 3B is out of soap');
    expect(draft.externalMessageId, 'm1');
  });

  testWidgets('a conversation hides the dock; the chat list keeps it', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    expect(find.byTooltip('Accounts'), findsOneWidget);
    final router = _router(tester);

    router.push('/today/chat');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Accounts'), findsOneWidget);

    router.push('/today/chat/account-c1');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Accounts'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Accounts'), findsOneWidget);
  });
}
