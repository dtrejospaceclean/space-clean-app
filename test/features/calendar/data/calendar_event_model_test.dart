import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/calendar/data/models/calendar_event_model.dart';
import 'package:sp_cln_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';

void main() {
  test('fromJson reads a generated event with its links', () {
    final e = CalendarEventModel.fromJson({
      'id': 'e1',
      'clientAccountId': 'c1',
      'locationId': 'l1',
      'scopeOfWorkId': 's1',
      'recurringScheduleId': 'w1',
      'jobId': null,
      'title': 'Oficinas',
      'eventDate': '2026-10-05T00:00:00.000Z',
      'startTime': '07:00',
      'endTime': '08:00',
      'status': 'rescheduled',
      'assignedToUserId': 'u1',
      'notes': null,
      'location': {'id': 'l1', 'name': 'Floor 3'},
      'scopeOfWork': {
        'id': 's1',
        'areaName': 'Oficinas',
        'frequency': 'weekly',
      },
      'assignedTo': {'id': 'u1', 'name': 'Carlos Medina'},
    });

    // The calendar day stays put in any time zone.
    expect(e.date, DateTime(2026, 10, 5));
    expect(e.startTime, const ClockTime(7, 0));
    expect(e.endTime, const ClockTime(8, 0));
    expect(e.status, CalendarEventStatus.rescheduled);
    expect(e.locationName, 'Floor 3');
    expect(e.scopeArea, 'Oficinas');
    expect(e.assignedToName, 'Carlos Medina');
    expect(e.isGenerated, isTrue);
    expect(e.isEditable, isTrue);
    // Generated events come back when their month is filled again.
    expect(e.canDelete, isFalse);
  });

  test('a one-off turned into a job is history', () {
    final e = CalendarEventModel.fromJson({
      'id': 'e2',
      'title': 'Deep clean',
      'eventDate': '2026-10-06',
      'startTime': '09:30',
      'endTime': null,
      'status': 'converted',
      'jobId': 'j1',
    });
    expect(e.isGenerated, isFalse);
    expect(e.isConverted, isTrue);
    expect(e.isEditable, isFalse);
    expect(e.canDelete, isFalse);
  });

  test('a create sends the day and start; an update never does', () {
    final draft = EventDraft(
      title: ' Deep clean ',
      date: DateTime(2026, 10, 6),
      startTime: const ClockTime(9, 30),
      locationId: 'l1',
      notes: ' ',
    );
    expect(CalendarEventModel.draftToJson(draft, create: true), {
      'title': 'Deep clean',
      'eventDate': '2026-10-06',
      'startTime': '09:30',
      'locationId': 'l1',
    });
    expect(CalendarEventModel.draftToJson(draft, create: false), {
      'title': 'Deep clean',
      'endTime': null,
      'locationId': 'l1',
      'scopeOfWorkId': null,
      'assignedToUserId': null,
      'notes': null,
    });
  });

  test('a reschedule always says where the end goes', () {
    expect(
      CalendarEventModel.rescheduleToJson(
        RescheduleDraft(
          date: DateTime(2026, 10, 8),
          startTime: const ClockTime(15, 0),
          reason: '  ',
        ),
      ),
      {'eventDate': '2026-10-08', 'startTime': '15:00', 'endTime': null},
    );
  });
}
