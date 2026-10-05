import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/calendar_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/calendar_usecases.dart';

/// A month of an account's events, filled from the scopes first when the
/// query says so.
final monthEventsProvider = FutureProvider.autoDispose
    .family<List<CalendarEvent>, MonthQuery>(
      (ref, query) => ref.watch(getMonthEventsProvider)(query),
    );

/// One event: `(clientId, eventId)`.
final eventProvider = FutureProvider.autoDispose
    .family<CalendarEvent, (String, String)>(
      (ref, key) => ref.watch(getEventProvider)(
        EventRef(clientId: key.$1, eventId: key.$2),
      ),
    );

/// An event's moves, newest first: `(clientId, eventId)`.
final eventReschedulesProvider = FutureProvider.autoDispose
    .family<List<EventReschedule>, (String, String)>(
      (ref, key) => ref.watch(getEventReschedulesProvider)(
        EventRef(clientId: key.$1, eventId: key.$2),
      ),
    );

/// The day picked on each account's calendar (null: today), so a new event
/// from the dock's "+" starts on it.
final calendarDayProvider =
    NotifierProvider.family<CalendarDayController, DateTime?, String>(
      CalendarDayController.new,
    );

class CalendarDayController extends Notifier<DateTime?> {
  CalendarDayController(this.clientId);

  final String clientId;

  @override
  DateTime? build() => null;

  void select(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

/// Drops cached events after any write.
void invalidateCalendar(WidgetRef ref) => ref
  ..invalidate(monthEventsProvider)
  ..invalidate(eventProvider)
  ..invalidate(eventReschedulesProvider);
