import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';

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
  name: 'Main office',
  address: '1 Main St',
  city: 'Houston',
  state: 'TX',
  zipCode: '77002',
);

const _carlos = Member(
  userId: 'u-carlos',
  clientId: 'c1',
  name: 'Carlos Medina',
  email: 'carlos@example.com',
  baseRole: 'crew',
);
const _luisa = Member(
  userId: 'u-luisa',
  clientId: 'c1',
  name: 'Luisa Ramos',
  email: 'luisa@example.com',
  baseRole: 'crew',
);

/// Today, with Carlos checked in and one item of two done.
final _nightly = job(
  'j1',
  'c1',
  title: 'Nightly clean',
  hour: 18,
  assignees: [
    JobAssignee(
      userId: 'u-carlos',
      name: 'Carlos Medina',
      roleOnJob: 'lead',
      checkInTime: DateTime(2026, 9, 23, 17, 55),
    ),
  ],
  checklist: const [
    ChecklistItem(id: 'i1', description: 'Empty trash', isCompleted: true),
    ChecklistItem(id: 'i2', description: 'Mop floors'),
  ],
);

/// Last week, finished.
final _lastWeek = job(
  'j-old',
  'c1',
  title: 'Carpet shampoo',
  day: 16,
  status: JobStatus.completed,
);

const _viewer = {Permissions.jobsView};
const _editor = {
  Permissions.jobsView,
  Permissions.jobsEdit,
  Permissions.jobsAssign,
  Permissions.infoView,
  Permissions.teamView,
  Permissions.scopeView,
};

/// Opens Torre Norte → Jobs as a member with [permissions].
Future<FakeJobsRepository> openJobs(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
  FakeCalendarRepository? calendar,
}) async {
  final repo = FakeJobsRepository({
    'c1': [_nightly, _lastWeek],
  });
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    jobs: repo,
    locations: FakeLocationsRepository([_floor3]),
    team: FakeTeamRepository([_carlos, _luisa]),
    calendar: calendar,
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
  if (calendar == null) {
    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();
  }
  return repo;
}

/// The job page's two-tone title.
Finder _headline(String title) =>
    find.textContaining(title, findRichText: true);

void main() {
  testWidgets('a viewer reads upcoming and past jobs, without changing them', (
    tester,
  ) async {
    final jobs = await openJobs(tester);

    expect(find.text('Nightly clean'), findsOneWidget);
    expect(find.text('Carpet shampoo'), findsNothing);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(find.text('Past 30 days'));
    await tester.pumpAndSettle();
    expect(find.text('Carpet shampoo'), findsOneWidget);
    expect(find.text('Nightly clean'), findsNothing);

    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    expect(find.text('Empty trash'), findsOneWidget);
    expect(find.text('Mop floors'), findsOneWidget);
    await revealBelow(tester, find.text('Carlos Medina'));
    // The role under the name, the check-in at the right.
    expect(find.text('lead'), findsOneWidget);
    expect(find.text('In 5:55 PM'), findsOneWidget);
    expect(find.byTooltip('Edit job'), findsNothing);
    expect(find.byTooltip('Delete job'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Cancel job'), findsNothing);
    expect(jobs.writes, isEmpty);
  });

  testWidgets('an editor creates a job from "+" and lands on it', (
    tester,
  ) async {
    final jobs = await openJobs(tester, permissions: _editor);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New job'), findsOneWidget);
    // The only location is taken; today at 8:00 to start.
    expect(find.text('Main office'), findsOneWidget);
    expect(find.text('Wednesday, September 23'), findsOneWidget);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    expect(jobs.writes, isEmpty);

    await tester.enterText(field('Title'), 'Window washing');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['create:Window washing']);
    final draft = jobs.drafts.single;
    expect(draft.locationId, 'l1');
    expect(draft.scheduledStart, DateTime(2026, 9, 23, 8));
    expect(draft.scheduledEnd, isNull);
    // Its own page, where crew and checklist are set.
    expect(_headline('Window washing'), findsOneWidget);
    expect(find.text('No checklist yet'), findsOneWidget);
    expect(find.text('No one assigned yet'), findsOneWidget);
    expect(find.byTooltip('Delete job'), findsOneWidget);
  });

  testWidgets('an editor changes the title, keeping the time', (tester) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit job'));
    await tester.pumpAndSettle();
    expect(find.text('6:00 PM'), findsOneWidget);
    expect(find.text('8:00 PM'), findsOneWidget);
    await tester.enterText(field('Title'), 'Evening clean');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['update:j1']);
    final draft = jobs.drafts.single;
    expect(draft.scheduledStart, DateTime(2026, 9, 23, 18));
    expect(draft.scheduledEnd, DateTime(2026, 9, 23, 20));
    expect(_headline('Evening clean'), findsOneWidget);
  });

  testWidgets('an editor picks the crew; who stays keeps their role', (
    tester,
  ) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Crew'));
    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text('Crew'), matching: find.byType(Row)),
        matching: find.text('Edit'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edit crew'), findsOneWidget);

    await tester.tap(find.text('Luisa Ramos'));
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['crew:j1']);
    expect([
      for (final c in jobs.crews.single) (c.userId, c.roleOnJob),
    ], unorderedEquals([('u-carlos', 'lead'), ('u-luisa', null)]));
    await revealBelow(tester, find.text('User u-luisa'));
    expect(find.text('Carlos Medina'), findsOneWidget);
  });

  testWidgets('an editor adds checklist items with "+", warned about ticks', (
    tester,
  ) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Mop floors'));
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit checklist'), findsOneWidget);
    expect(
      find.text('1 item is ticked. Saving a change clears the tick.'),
      findsOneWidget,
    );

    // Unchanged: nothing is sent, so the tick stays.
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(jobs.writes, isEmpty);

    await revealBelow(tester, find.text('Mop floors'));
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add checklist item'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Item 3'), '  Lock up  ');
    // A blank one is left out.
    await tester.tap(find.byTooltip('Add checklist item'));
    await tester.pumpAndSettle();
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['checklist:j1']);
    expect(jobs.checklists.single, ['Empty trash', 'Mop floors', 'Lock up']);
    await revealBelow(tester, find.text('Lock up'));
  });

  testWidgets('an editor ticks an item off and reopens another', (
    tester,
  ) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);

    await revealBelow(tester, find.text('Mop floors'));
    await tester.tap(find.text('Mop floors'));
    await tester.pumpAndSettle();
    expect(jobs.writes, ['tick:i2']);
    expect(find.text('Ana Pérez'), findsOneWidget);

    await tester.tap(find.text('Empty trash'));
    await tester.pumpAndSettle();
    expect(jobs.writes, ['tick:i2', 'reopen:i1']);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('crew tick their own job; others only read it', (tester) async {
    // Ana is crew here, without jobs.edit.
    final mine = job(
      'j-mine',
      'c1',
      title: 'My shift',
      hour: 10,
      assignees: const [JobAssignee(userId: 'u1', name: 'Ana Pérez')],
      checklist: const [ChecklistItem(id: 'm1', description: 'Dust desks')],
    );
    final repo = FakeJobsRepository({
      'c1': [mine, _nightly],
    });
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower]),
      jobs: repo,
      access: FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'crew',
          permissions: _viewer,
        ),
      }),
    );
    expect(ana.id, 'u1');
    await tester.tap(find.text('My shift'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Dust desks'));
    await tester.tap(find.text('Dust desks'));
    await tester.pumpAndSettle();
    expect(repo.writes, ['tick:m1']);

    // Not on this one's crew: the rows don't react.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Mop floors'));
    await tester.tap(find.text('Mop floors'));
    await tester.pumpAndSettle();
    expect(repo.writes, ['tick:m1']);
  });

  testWidgets('crew check in, start, tick, complete and check out', (
    tester,
  ) async {
    final repo = FakeJobsRepository({
      'c1': [
        job(
          'j-mine',
          'c1',
          title: 'My shift',
          hour: 10,
          assignees: const [JobAssignee(userId: 'u1', name: 'Ana Pérez')],
          checklist: const [
            ChecklistItem(id: 'm1', description: 'Dust desks'),
            ChecklistItem(id: 'm2', description: 'Mop floors'),
          ],
        ),
      ],
    });
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: ana),
      clients: FakeClientsRepository([_tower]),
      jobs: repo,
      access: FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'crew',
          permissions: _viewer,
        ),
      }),
    );
    // From Today, like on site.
    await tester.tap(find.text('My shift'));
    await tester.pumpAndSettle();
    expect(button('Check in'), findsOneWidget);
    expect(find.text('Start job'), findsOneWidget);
    expect(find.text('Check out'), findsNothing);

    await tester.tap(button('Check in'));
    await tester.pumpAndSettle();
    expect(find.text('You checked in at 8:00 AM.'), findsOneWidget);
    expect(button('Start job'), findsOneWidget);
    expect(find.text('Check out'), findsOneWidget);

    await tester.tap(button('Start job'));
    await tester.pumpAndSettle();
    expect(find.text('In progress'), findsOneWidget);
    expect(button('Complete job'), findsOneWidget);

    await revealBelow(tester, find.text('Dust desks'));
    await tester.tap(find.text('Dust desks'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(button('Complete job'));
    await tester.pumpAndSettle();
    // One item is still open: said, not blocking.
    expect(find.text("1 checklist item isn't ticked yet."), findsOneWidget);
    await tester.tap(find.text('4'));
    await tester.enterText(field('Crew notes'), 'Faucet leaks');
    await tester.enterText(field('Client sign-off'), 'María López');
    await tester.tap(button('Complete job'));
    await tester.pumpAndSettle();

    final done = repo.completions.single;
    expect(
      (done.qualityScore, done.cleanerNotes, done.clientSignoffName),
      (4, 'Faucet leaks', 'María López'),
    );
    expect(find.text('Completed'), findsWidgets);
    // Last, leaving the site.
    expect(button('Check out'), findsOneWidget);
    await tester.tap(button('Check out'));
    await tester.pumpAndSettle();

    expect(repo.writes, [
      'check-in:j-mine',
      'start:j-mine',
      'tick:m1',
      'complete:j-mine',
      'check-out:j-mine',
    ]);
    expect(
      find.text('You checked in at 8:00 AM and out at 10:00 AM.'),
      findsOneWidget,
    );
    expect(find.text('Check out'), findsNothing);
    await revealBelow(tester, find.text('4 of 5'));
    expect(find.text('María López'), findsOneWidget);
  });

  testWidgets('an editor off the crew starts a job but does not check in', (
    tester,
  ) async {
    await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    expect(button('Start job'), findsOneWidget);
    expect(find.text('Check in'), findsNothing);
    expect(find.text('Check out'), findsNothing);
  });

  testWidgets('an editor cancels a job, which turns read-only', (tester) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Cancel job'));
    await tester.tap(find.text('Cancel job'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this job?'), findsOneWidget);
    await tester.tap(find.text('Cancel job').last);
    await tester.pumpAndSettle();

    expect(jobs.writes, ['cancel:j1']);
    expect(find.byTooltip('Edit job'), findsNothing);
    expect(find.text('Cancel job'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(
      find.text("This job was cancelled, so it can't change."),
      findsOneWidget,
    );
  });

  testWidgets('an editor deletes a job that never started', (tester) async {
    final jobs = await openJobs(tester, permissions: _editor);
    await tester.tap(find.text('Nightly clean'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete job'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['delete:j1']);
    // Back on the list, now empty.
    expect(find.text('No upcoming jobs'), findsOneWidget);
  });

  testWidgets('a calendar event becomes a job with its assignee as crew', (
    tester,
  ) async {
    final calendar = FakeCalendarRepository([
      CalendarEvent(
        id: 'e1',
        title: 'Deep clean',
        date: DateTime(2026, 9, 23),
        startTime: const ClockTime(9, 0),
        status: CalendarEventStatus.scheduled,
        locationId: 'l1',
        locationName: 'Main office',
        assignedToId: 'u-carlos',
        assignedToName: 'Carlos Medina',
      ),
    ]);
    final jobs = await openJobs(
      tester,
      permissions: {..._editor, Permissions.calendarView},
      calendar: calendar,
    );
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep clean'));
    await tester.pumpAndSettle();

    await revealBelow(tester, button('Create job'));
    await tester.tap(button('Create job'));
    await tester.pumpAndSettle();

    expect(jobs.writes, ['convert:e1']);
    expect(jobs.crews.single.single.userId, 'u-carlos');
    expect(_headline('Job from e1'), findsOneWidget);
  });
}
