import '../entities/calendar_event.dart';

/// Every method throws a `Failure` on error.
abstract interface class CalendarRepository {
  /// An account's events from [from] to [to] (calendar days, both
  /// included, at most a year apart), by date and time. Needs
  /// `calendar.view`.
  Future<List<CalendarEvent>> getEvents(
    String clientId, {
    required DateTime from,
    required DateTime to,
  });

  /// Fills [from]–[to] with events from the active scopes' time windows;
  /// returns how many it created. Running it again creates nothing new.
  /// Needs `calendar.edit`.
  Future<int> generate(
    String clientId, {
    required DateTime from,
    required DateTime to,
  });

  /// Needs `calendar.view`.
  Future<CalendarEvent> getEvent(String clientId, String eventId);

  /// [eventId]'s moves, newest first. Needs `calendar.view`.
  Future<List<EventReschedule>> getReschedules(String clientId, String eventId);

  /// A one-off event. Needs `calendar.edit`.
  Future<CalendarEvent> createEvent(String clientId, EventDraft draft);

  /// Everything but the date and start time. Needs `calendar.edit`.
  Future<CalendarEvent> updateEvent(
    String clientId,
    String eventId,
    EventDraft draft,
  );

  /// Moves it and keeps a history entry. Needs `calendar.edit`.
  Future<CalendarEvent> rescheduleEvent(
    String clientId,
    String eventId,
    RescheduleDraft draft,
  );

  /// Needs `calendar.edit`. The event stays, read-only.
  Future<CalendarEvent> cancelEvent(String clientId, String eventId);

  /// Needs `calendar.edit`; refused once it became a job.
  Future<void> deleteEvent(String clientId, String eventId);
}
