import '../../../scopes/domain/entities/scope.dart';

/// Where an event stands.
enum CalendarEventStatus {
  scheduled('scheduled'),

  /// Moved at least once; the moves are kept as history.
  rescheduled('rescheduled'),
  cancelled('cancelled'),

  /// Turned into a job.
  converted('converted'),

  /// A status this app doesn't know yet.
  unknown('');

  const CalendarEventStatus(this.wire);

  /// The API's name for it.
  final String wire;

  static CalendarEventStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// One visit on an account's calendar: made from a scope's time window
/// (generated) or added by hand (one-off).
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.status,
    this.endTime,
    this.notes,
    this.locationId,
    this.locationName,
    this.scopeId,
    this.scopeArea,
    this.assignedToId,
    this.assignedToName,
    this.jobId,
    this.scheduleId,
  });

  final String id;
  final String title;

  /// A calendar day (no time).
  final DateTime date;
  final ClockTime startTime;
  final ClockTime? endTime;
  final CalendarEventStatus status;
  final String? notes;
  final String? locationId;
  final String? locationName;
  final String? scopeId;
  final String? scopeArea;
  final String? assignedToId;
  final String? assignedToName;

  /// Set once it became a job.
  final String? jobId;

  /// The scope time window it was generated from; null for a one-off.
  final String? scheduleId;

  bool get isGenerated => scheduleId != null;
  bool get isCancelled => status == CalendarEventStatus.cancelled;
  bool get isConverted => jobId != null;

  /// Cancelled events and those turned into jobs are history
  /// (`calendar.cancelled`, `calendar.already_converted`).
  bool get isEditable => !isCancelled && !isConverted;

  /// Only one-off events: a generated one would come back the next time
  /// its month is generated, so it's cancelled instead.
  bool get canDelete => !isGenerated && !isConverted;
}

/// One move of an event, newest first.
class EventReschedule {
  const EventReschedule({
    required this.previousDate,
    required this.previousStart,
    required this.newDate,
    required this.newStart,
    this.reason,
    this.byName,
  });

  final DateTime previousDate;
  final ClockTime previousStart;
  final DateTime newDate;
  final ClockTime newStart;
  final String? reason;
  final String? byName;
}

/// The fields of an event as typed. [date] and [startTime] are only set on
/// a create: moving goes through a reschedule, which keeps the history.
/// Empty optional fields clear them on an edit.
class EventDraft {
  const EventDraft({
    required this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.locationId,
    this.scopeId,
    this.assignedToId,
    this.notes,
  });

  final String title;
  final DateTime? date;
  final ClockTime? startTime;
  final ClockTime? endTime;
  final String? locationId;
  final String? scopeId;
  final String? assignedToId;
  final String? notes;
}

/// Where an event moves to, and why.
class RescheduleDraft {
  const RescheduleDraft({
    required this.date,
    required this.startTime,
    this.endTime,
    this.reason,
  });

  final DateTime date;
  final ClockTime startTime;

  /// Null leaves it open-ended.
  final ClockTime? endTime;
  final String? reason;
}
