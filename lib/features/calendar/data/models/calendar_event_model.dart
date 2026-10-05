import '../../../scopes/domain/entities/scope.dart';
import '../../domain/entities/calendar_event.dart';

abstract final class CalendarEventModel {
  /// A date-only column: keep the calendar day, ignore the UTC time.
  static DateTime? day(Object? value) => switch (value) {
    final String s when s.length >= 10 => DateTime.tryParse(s.substring(0, 10)),
    _ => null,
  };

  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String? _name(Object? user) => switch (user) {
    {'name': final String name} => name,
    _ => null,
  };

  static CalendarEvent fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map?;
    final scope = json['scopeOfWork'] as Map?;
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      date: day(json['eventDate']) ?? DateTime(1970),
      startTime:
          ClockTime.tryParse(json['startTime'] as String?) ??
          const ClockTime(0, 0),
      endTime: ClockTime.tryParse(json['endTime'] as String?),
      status: CalendarEventStatus.fromWire(json['status'] as String?),
      notes: json['notes'] as String?,
      locationId: json['locationId'] as String?,
      locationName: location?['name'] as String?,
      scopeId: json['scopeOfWorkId'] as String?,
      scopeArea: scope?['areaName'] as String?,
      assignedToId: json['assignedToUserId'] as String?,
      assignedToName: _name(json['assignedTo']),
      jobId: json['jobId'] as String?,
      scheduleId: json['recurringScheduleId'] as String?,
    );
  }

  static EventReschedule rescheduleFromJson(Map<String, dynamic> json) =>
      EventReschedule(
        previousDate: day(json['previousDate']) ?? DateTime(1970),
        previousStart:
            ClockTime.tryParse(json['previousStartTime'] as String?) ??
            const ClockTime(0, 0),
        newDate: day(json['newDate']) ?? DateTime(1970),
        newStart:
            ClockTime.tryParse(json['newStartTime'] as String?) ??
            const ClockTime(0, 0),
        reason: json['reason'] as String?,
        byName: _name(json['rescheduledBy']),
      );

  /// Body for a create or an update (`PATCH`). A create sends the date and
  /// start time and leaves empty fields out; an update never sends them
  /// (moving is a reschedule) and sends empty fields as null to clear them.
  static Map<String, dynamic> draftToJson(
    EventDraft d, {
    required bool create,
  }) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'endTime': d.endTime?.wire,
      'locationId': text(d.locationId),
      'scopeOfWorkId': text(d.scopeId),
      'assignedToUserId': text(d.assignedToId),
      'notes': text(d.notes),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'title': d.title.trim(),
      if (create) ...{
        'eventDate': ymd(d.date!),
        'startTime': d.startTime!.wire,
      },
      ...optional,
    };
  }

  /// The end goes as null when there's none, so an old end can't land
  /// before the new start.
  static Map<String, dynamic> rescheduleToJson(RescheduleDraft d) => {
    'eventDate': ymd(d.date),
    'startTime': d.startTime.wire,
    'endTime': d.endTime?.wire,
    if (d.reason?.trim() case final reason? when reason.isNotEmpty)
      'reason': reason,
  };
}
