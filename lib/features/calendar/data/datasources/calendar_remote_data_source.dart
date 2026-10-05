import '../../../../core/network/api_client.dart';
import '../../domain/entities/calendar_event.dart';
import '../models/calendar_event_model.dart';

/// Talks to `/clients/:clientId/calendar`. Throws `ApiException`.
class CalendarRemoteDataSource {
  const CalendarRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/calendar';

  static CalendarEvent _one(Object? data) =>
      CalendarEventModel.fromJson((data! as Map).cast<String, dynamic>());

  /// Not paginated.
  Future<List<CalendarEvent>> getEvents(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get(
      _path(clientId),
      query: {
        'from': CalendarEventModel.ymd(from),
        'to': CalendarEventModel.ymd(to),
      },
    );
    return [
      for (final item in data! as List)
        CalendarEventModel.fromJson((item as Map).cast<String, dynamic>()),
    ];
  }

  /// Returns how many events it created.
  Future<int> generate(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.post(
      '${_path(clientId)}/generate',
      body: {
        'from': CalendarEventModel.ymd(from),
        'to': CalendarEventModel.ymd(to),
      },
    );
    return switch (data) {
      {'created': final num created} => created.toInt(),
      _ => 0,
    };
  }

  Future<CalendarEvent> getEvent(String clientId, String eventId) async =>
      _one(await _api.get('${_path(clientId)}/$eventId'));

  Future<List<EventReschedule>> getReschedules(
    String clientId,
    String eventId,
  ) async {
    final data = await _api.get('${_path(clientId)}/$eventId/reschedules');
    return [
      for (final item in data! as List)
        CalendarEventModel.rescheduleFromJson(
          (item as Map).cast<String, dynamic>(),
        ),
    ];
  }

  Future<CalendarEvent> createEvent(String clientId, EventDraft draft) async =>
      _one(
        await _api.post(
          _path(clientId),
          body: CalendarEventModel.draftToJson(draft, create: true),
        ),
      );

  Future<CalendarEvent> updateEvent(
    String clientId,
    String eventId,
    EventDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$eventId',
      body: CalendarEventModel.draftToJson(draft, create: false),
    ),
  );

  Future<CalendarEvent> rescheduleEvent(
    String clientId,
    String eventId,
    RescheduleDraft draft,
  ) async => _one(
    await _api.post(
      '${_path(clientId)}/$eventId/reschedule',
      body: CalendarEventModel.rescheduleToJson(draft),
    ),
  );

  /// Takes no body.
  Future<CalendarEvent> cancelEvent(String clientId, String eventId) async =>
      _one(await _api.post('${_path(clientId)}/$eventId/cancel'));

  /// Returns no data.
  Future<void> deleteEvent(String clientId, String eventId) =>
      _api.delete('${_path(clientId)}/$eventId');
}
