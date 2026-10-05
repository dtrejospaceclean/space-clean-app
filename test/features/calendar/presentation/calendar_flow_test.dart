import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

/// Today on the test clock (Wednesday, Sep 23), made from a scope.
final _offices = CalendarEvent(
  id: 'e-offices',
  title: 'Offices',
  date: DateTime(2026, 9, 23),
  startTime: const ClockTime(7, 0),
  endTime: const ClockTime(8, 0),
  status: CalendarEventStatus.scheduled,
  locationName: 'Floor 3',
  scopeId: 's1',
  scopeArea: 'Offices',
  assignedToName: 'Carlos Medina',
  scheduleId: 'w1',
);

/// A one-off visit on Friday.
final _deepClean = CalendarEvent(
  id: 'e-deep',
  title: 'Deep clean',
  date: DateTime(2026, 9, 25),
  startTime: const ClockTime(9, 30),
  status: CalendarEventStatus.scheduled,
);

const _viewer = {Permissions.calendarView};
const _editor = {Permissions.calendarView, Permissions.calendarEdit};

/// Opens Torre Norte → Calendar as a member with [permissions].
Future<FakeCalendarRepository> openCalendar(
  WidgetTester tester, {
  Set<String> permissions = _viewer,
}) async {
  final repo = FakeCalendarRepository([_offices, _deepClean]);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: ana),
    clients: FakeClientsRepository([_tower]),
    calendar: repo,
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
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();
  return repo;
}

/// The grid cell for [day] of the month shown.
Finder _day(int day) =>
    find.descendant(of: find.byType(InkWell), matching: find.text('$day'));

void main() {
  testWidgets('a viewer reads the month and a day, without filling it', (
    tester,
  ) async {
    final calendar = await openCalendar(tester);

    expect(find.text('September 2026'), findsOneWidget);
    // Today is picked to start.
    expect(find.text('Wednesday, September 23'), findsOneWidget);
    expect(find.text('Offices'), findsOneWidget);
    expect(find.text('7:00 AM – 8:00 AM · Floor 3'), findsOneWidget);
    // Only editors fill the month from the scopes.
    expect(calendar.generated, isEmpty);
    expect(find.byTooltip('Create'), findsNothing);

    await tester.tap(_day(25));
    await tester.pumpAndSettle();
    expect(find.text('Friday, September 25'), findsOneWidget);
    expect(find.text('Deep clean'), findsOneWidget);
    expect(find.text('Offices'), findsNothing);

    await tester.tap(_day(24));
    await tester.pumpAndSettle();
    expect(find.text('Nothing scheduled'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Thursday, October 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Go to today'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    await tester.tap(find.text('Offices'));
    await tester.pumpAndSettle();
    expect(find.text('From a scope of work'), findsOneWidget);
    expect(find.text('Carlos Medina'), findsOneWidget);
    expect(find.byTooltip('Edit event'), findsNothing);
    expect(find.text('Reschedule'), findsNothing);
    expect(calendar.writes, isEmpty);
  });

  testWidgets('an editor fills each month opened, then adds a one-off', (
    tester,
  ) async {
    final calendar = await openCalendar(tester, permissions: _editor);
    expect(calendar.generated, ['2026-09-01..2026-09-30']);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(calendar.generated.last, '2026-10-01..2026-10-31');
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    // A new event starts on the day picked.
    await tester.tap(_day(24));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New event'), findsOneWidget);
    expect(find.text('Thursday, September 24'), findsOneWidget);
    expect(find.text('8:00 AM'), findsOneWidget);

    await tester.tap(button('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    expect(calendar.writes, isEmpty);

    await tester.enterText(field('Title'), 'Window washing');
    await tester.tap(button('Save'));
    await tester.pumpAndSettle();

    expect(calendar.writes, ['create:2026-09-24 08:00']);
    expect(calendar.drafts.single.title, 'Window washing');
    // Its own page; a one-off can be deleted.
    expect(find.text('Window washing'), findsOneWidget);
    expect(find.text('One-off'), findsOneWidget);
    expect(find.byTooltip('Delete event'), findsOneWidget);
  });

  testWidgets('a reschedule keeps where it was in the history', (tester) async {
    final calendar = await openCalendar(tester, permissions: _editor);
    await tester.tap(find.text('Offices'));
    await tester.pumpAndSettle();
    // Made from a scope, and still deletable: it won't come back.
    expect(find.byTooltip('Delete event'), findsOneWidget);

    await revealBelow(tester, button('Reschedule'));
    await tester.tap(button('Reschedule'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Reason'), 'Client asked');
    await tester.tap(button('Reschedule'));
    await tester.pumpAndSettle();

    expect(calendar.writes, [
      'reschedule:e-offices:2026-09-23 07:00-08:00:Client asked',
    ]);
    expect(find.text('Moved'), findsOneWidget);
    await revealBelow(tester, find.text('From Sep 23, 2026, 7:00 AM'));
    expect(find.textContaining('Client asked'), findsOneWidget);
    expect(find.textContaining('by Ana Pérez'), findsOneWidget);
  });

  testWidgets('an editor cancels an event, which turns read-only', (
    tester,
  ) async {
    final calendar = await openCalendar(tester, permissions: _editor);
    await tester.tap(find.text('Offices'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Cancel event'));
    await tester.tap(find.text('Cancel event'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this event?'), findsOneWidget);
    await tester.tap(find.text('Cancel event').last);
    await tester.pumpAndSettle();

    expect(calendar.writes, ['cancel:e-offices']);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(
      find.text("This event is cancelled and can't change."),
      findsOneWidget,
    );
    expect(find.byTooltip('Edit event'), findsNothing);
    expect(find.text('Cancel event'), findsNothing);
  });

  testWidgets('an editor deletes a one-off event', (tester) async {
    final calendar = await openCalendar(tester, permissions: _editor);
    await tester.tap(_day(25));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep clean'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(calendar.writes, ['delete:e-deep']);
    // Back on the calendar, on the same day, now empty.
    expect(find.text('Friday, September 25'), findsOneWidget);
    expect(find.text('Nothing scheduled'), findsOneWidget);
  });
}
