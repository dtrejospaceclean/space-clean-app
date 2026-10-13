import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

// The test clock is Sep 23, 2026; the list comes in the server's order.

/// High, assigned and three days late.
final _quote = Task(
  id: 't-quote',
  clientId: 'c1',
  title: 'Send the floor 3 quote',
  description: 'Two options: weekly and nightly.',
  priority: Priority.high,
  status: TaskStatus.pending,
  assignedToId: 'u-ana',
  assignedToName: 'Ana Pérez',
  dueDate: DateTime(2026, 9, 20),
  isOverdue: true,
  daysUntilDue: -3,
);

/// Started, and due tomorrow.
final _supplies = Task(
  id: 't-supplies',
  clientId: 'c1',
  title: 'Order restroom supplies',
  priority: Priority.medium,
  status: TaskStatus.inProgress,
  dueDate: DateTime(2026, 9, 24),
  daysUntilDue: 1,
);

/// Pending with no date: last.
const _permits = Task(
  id: 't-permits',
  clientId: 'c1',
  title: 'File the permits',
  priority: Priority.low,
  status: TaskStatus.pending,
);

final _done = Task(
  id: 't-done',
  clientId: 'c1',
  title: 'Walk the site with the client',
  priority: Priority.medium,
  status: TaskStatus.completed,
  dueDate: DateTime(2026, 9, 15),
  daysUntilDue: -8,
);

const _viewer = {Permissions.tasksView};
const _editor = {
  Permissions.tasksView,
  Permissions.tasksEdit,
  Permissions.teamView,
};

/// Opens Torre Norte → Tasks as a member with [permissions].
Future<FakeTasksRepository> openTasks(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
  List<Task>? tasks,
}) async {
  final repo = FakeTasksRepository(
    tasks ?? [_quote, _supplies, _permits, _done],
  );
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    tasks: repo,
    team: FakeTeamRepository(const [
      Member(
        userId: 'u-ana',
        clientId: 'c1',
        name: 'Ana Pérez',
        email: 'ana@spaceclean.com',
        baseRole: 'supervisor',
      ),
      Member(
        userId: 'u-client',
        clientId: 'c1',
        name: 'Carlos Medina',
        email: 'carlos@torrenorte.com',
        baseRole: 'client',
      ),
    ]),
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
  await revealBelow(tester, find.text('Tasks'));
  await tester.tap(find.text('Tasks'));
  await tester.pumpAndSettle();
  return repo;
}

/// The tappable box of the form's picker labeled [label].
Finder _picker(String label) => find.descendant(
  of: find.widgetWithText(PickerField, label),
  matching: find.byType(InkWell),
);

/// The vertical order of [texts] on screen.
List<String> _topToBottom(WidgetTester tester, List<String> texts) =>
    [...texts]..sort(
      (a, b) => tester
          .getTopLeft(find.text(a))
          .dy
          .compareTo(tester.getTopLeft(find.text(b)).dy),
    );

void main() {
  testWidgets('a viewer sees open tasks by due date, then the done ones', (
    tester,
  ) async {
    final tasks = await openTasks(tester);

    expect(find.text('Open (3)'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);
    expect(
      _topToBottom(tester, [
        'File the permits',
        'Order restroom supplies',
        'Send the floor 3 quote',
      ]),
      ['Send the floor 3 quote', 'Order restroom supplies', 'File the permits'],
    );
    expect(find.text('3 days overdue'), findsOneWidget);
    expect(find.text('Due tomorrow'), findsOneWidget);
    expect(find.text('Ana Pérez · Sep 20, 2026'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);
    expect(find.text('Walk the site with the client'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Walk the site with the client'), findsOneWidget);
    expect(find.text('Send the floor 3 quote'), findsNothing);

    // Read-only: no Edit, Complete, Reopen or Delete.
    await tester.tap(find.text('Walk the site with the client'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('No description'), findsOneWidget);
    expect(find.byTooltip('Edit task'), findsNothing);
    expect(find.text('Reopen'), findsNothing);
    expect(find.text('Delete task'), findsNothing);
    expect(tasks.writes, isEmpty);
  });

  testWidgets('an editor adds a task from "+"', (tester) async {
    final tasks = await openTasks(tester, permissions: _editor);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New task'), findsOneWidget);
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    expect(tasks.writes, isEmpty);

    await tester.enterText(field('Title'), 'Call the landlord');
    await tester.tap(find.text('High'));
    // Only the account's own staff can take it, not the client's people.
    await revealBelow(tester, _picker('Assigned to'));
    await tester.tap(_picker('Assigned to'));
    await tester.pumpAndSettle();
    expect(find.text('Carlos Medina'), findsNothing);
    await tester.tap(find.text('Ana Pérez').last);
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(tasks.writes, ['create:Call the landlord']);
    final draft = tasks.drafts.single;
    expect(draft.priority, Priority.high);
    expect(draft.assignedToId, 'u-ana');
    expect(draft.dueDate, isNull);
    // Its own page, pending.
    expect(find.text('Task'), findsOneWidget);
    expect(find.text('Call the landlord'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
  });

  testWidgets('an editor starts, completes and reopens a task', (tester) async {
    final tasks = await openTasks(tester, permissions: _editor);
    await tester.tap(find.text('File the permits'));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsOneWidget);

    await revealBelow(tester, button('Start'));
    await tester.tap(button('Start'));
    await tester.pumpAndSettle();
    expect(tasks.writes, ['status:t-permits:in_progress']);
    expect(button('Start'), findsNothing);

    await tester.tap(button('Complete'));
    await tester.pumpAndSettle();
    expect(tasks.writes.last, 'complete:t-permits');
    expect(find.textContaining('Reopen it to change it'), findsOneWidget);
    expect(find.byTooltip('Edit task'), findsNothing);
    expect(button('Complete'), findsNothing);

    await revealBelow(tester, find.text('Reopen'));
    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect(tasks.writes.last, 'reopen:t-permits');
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('cancelling and deleting ask first', (tester) async {
    final tasks = await openTasks(tester, permissions: _editor);
    await tester.tap(find.text('Order restroom supplies'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Cancel task'));
    await tester.tap(find.text('Cancel task'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this task?'), findsOneWidget);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(tasks.writes, isEmpty);

    await tester.tap(find.text('Cancel task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel task').last);
    await tester.pumpAndSettle();
    expect(tasks.writes, ['status:t-supplies:cancelled']);
    expect(find.text('Cancelled'), findsOneWidget);

    await revealBelow(tester, find.text('Delete task'));
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this task?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(tasks.writes.last, 'delete:t-supplies');
    // Back on the list, without it.
    expect(find.text('Open (2)'), findsOneWidget);
    expect(find.text('Order restroom supplies'), findsNothing);
  });

  testWidgets('an edit clears the due date and the assignee', (tester) async {
    final tasks = await openTasks(tester, permissions: _editor);
    await tester.tap(find.text('Send the floor 3 quote'));
    await tester.pumpAndSettle();
    expect(find.text('3 days overdue'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit task'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('No due date'));
    await tester.tap(find.text('No due date'));
    await tester.pumpAndSettle();
    await tester.tap(_picker('Assigned to'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not set').last);
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(tasks.writes, ['update:t-quote']);
    final draft = tasks.drafts.single;
    expect(draft.dueDate, isNull);
    expect(draft.assignedToId, isNull);
    expect(draft.description, 'Two options: weekly and nightly.');
    // No longer due, so no longer late.
    expect(find.text('3 days overdue'), findsNothing);
  });

  testWidgets('the search narrows the open tasks', (tester) async {
    await openTasks(tester);
    Future<void> search(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    await search('quote');
    expect(find.text('Send the floor 3 quote'), findsOneWidget);
    expect(find.text('Order restroom supplies'), findsNothing);

    // The status by name.
    await search('in progress');
    expect(find.text('Order restroom supplies'), findsOneWidget);
    expect(find.text('Send the floor 3 quote'), findsNothing);

    // Done, so not among the open ones.
    await search('walk the site');
    expect(find.text('Nothing matches'), findsOneWidget);
  });
}
