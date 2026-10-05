import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

class MonthQuery {
  const MonthQuery({
    required this.clientId,
    required this.year,
    required this.month,
    this.generate = false,
  });

  final String clientId;
  final int year;
  final int month;

  /// Fill the month from the scopes first (needs `calendar.edit`).
  final bool generate;

  DateTime get first => DateTime(year, month);
  DateTime get last => DateTime(year, month + 1, 0);

  @override
  bool operator ==(Object other) =>
      other is MonthQuery &&
      other.clientId == clientId &&
      other.year == year &&
      other.month == month &&
      other.generate == generate;

  @override
  int get hashCode => Object.hash(clientId, year, month, generate);
}

/// A month of an account's events. When the user may edit the calendar,
/// the month is first filled from the scopes' time windows, which is safe
/// to repeat. A failed fill still shows what's there.
class GetMonthEvents implements UseCase<List<CalendarEvent>, MonthQuery> {
  const GetMonthEvents(this._repository);

  final CalendarRepository _repository;

  @override
  Future<List<CalendarEvent>> call(MonthQuery q) async {
    if (q.generate) {
      try {
        await _repository.generate(q.clientId, from: q.first, to: q.last);
      } on Failure {
        // The events already there are still worth showing.
      }
    }
    return _repository.getEvents(q.clientId, from: q.first, to: q.last);
  }
}

class EventRef {
  const EventRef({required this.clientId, required this.eventId});

  final String clientId;
  final String eventId;
}

class GetEvent implements UseCase<CalendarEvent, EventRef> {
  const GetEvent(this._repository);

  final CalendarRepository _repository;

  @override
  Future<CalendarEvent> call(EventRef p) =>
      _repository.getEvent(p.clientId, p.eventId);
}

class GetEventReschedules implements UseCase<List<EventReschedule>, EventRef> {
  const GetEventReschedules(this._repository);

  final CalendarRepository _repository;

  @override
  Future<List<EventReschedule>> call(EventRef p) =>
      _repository.getReschedules(p.clientId, p.eventId);
}

class SaveEventParams {
  const SaveEventParams({
    required this.clientId,
    required this.draft,
    this.eventId,
  });

  final String clientId;

  /// The event edited; null to create a one-off.
  final String? eventId;
  final EventDraft draft;
}

class SaveEvent implements UseCase<CalendarEvent, SaveEventParams> {
  const SaveEvent(this._repository);

  final CalendarRepository _repository;

  @override
  Future<CalendarEvent> call(SaveEventParams p) => switch (p.eventId) {
    null => _repository.createEvent(p.clientId, p.draft),
    final id => _repository.updateEvent(p.clientId, id, p.draft),
  };
}

class RescheduleEventParams {
  const RescheduleEventParams({
    required this.clientId,
    required this.eventId,
    required this.draft,
  });

  final String clientId;
  final String eventId;
  final RescheduleDraft draft;
}

class RescheduleEvent implements UseCase<CalendarEvent, RescheduleEventParams> {
  const RescheduleEvent(this._repository);

  final CalendarRepository _repository;

  @override
  Future<CalendarEvent> call(RescheduleEventParams p) =>
      _repository.rescheduleEvent(p.clientId, p.eventId, p.draft);
}

class CancelEvent implements UseCase<CalendarEvent, EventRef> {
  const CancelEvent(this._repository);

  final CalendarRepository _repository;

  @override
  Future<CalendarEvent> call(EventRef p) =>
      _repository.cancelEvent(p.clientId, p.eventId);
}

class DeleteEvent implements UseCase<void, EventRef> {
  const DeleteEvent(this._repository);

  final CalendarRepository _repository;

  @override
  Future<void> call(EventRef p) =>
      _repository.deleteEvent(p.clientId, p.eventId);
}
