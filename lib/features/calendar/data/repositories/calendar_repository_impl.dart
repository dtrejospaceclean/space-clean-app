import '../../../../core/network/api_exception.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  const CalendarRepositoryImpl(this._remote);

  final CalendarRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<CalendarEvent>> getEvents(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) => _guard(() => _remote.getEvents(clientId, from: from, to: to));

  @override
  Future<int> generate(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) => _guard(() => _remote.generate(clientId, from: from, to: to));

  @override
  Future<CalendarEvent> getEvent(String clientId, String eventId) =>
      _guard(() => _remote.getEvent(clientId, eventId));

  @override
  Future<List<EventReschedule>> getReschedules(
    String clientId,
    String eventId,
  ) => _guard(() => _remote.getReschedules(clientId, eventId));

  @override
  Future<CalendarEvent> createEvent(String clientId, EventDraft draft) =>
      _guard(() => _remote.createEvent(clientId, draft));

  @override
  Future<CalendarEvent> updateEvent(
    String clientId,
    String eventId,
    EventDraft draft,
  ) => _guard(() => _remote.updateEvent(clientId, eventId, draft));

  @override
  Future<CalendarEvent> rescheduleEvent(
    String clientId,
    String eventId,
    RescheduleDraft draft,
  ) => _guard(() => _remote.rescheduleEvent(clientId, eventId, draft));

  @override
  Future<CalendarEvent> cancelEvent(String clientId, String eventId) =>
      _guard(() => _remote.cancelEvent(clientId, eventId));

  @override
  Future<void> deleteEvent(String clientId, String eventId) =>
      _guard(() => _remote.deleteEvent(clientId, eventId));
}
