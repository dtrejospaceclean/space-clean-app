import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/calendar_remote_data_source.dart';
import '../data/repositories/calendar_repository_impl.dart';
import '../domain/repositories/calendar_repository.dart';
import '../domain/usecases/calendar_usecases.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepositoryImpl(
    CalendarRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getMonthEventsProvider = Provider(
  (ref) => GetMonthEvents(ref.watch(calendarRepositoryProvider)),
);
final getEventProvider = Provider(
  (ref) => GetEvent(ref.watch(calendarRepositoryProvider)),
);
final getEventReschedulesProvider = Provider(
  (ref) => GetEventReschedules(ref.watch(calendarRepositoryProvider)),
);
final saveEventProvider = Provider(
  (ref) => SaveEvent(ref.watch(calendarRepositoryProvider)),
);
final rescheduleEventProvider = Provider(
  (ref) => RescheduleEvent(ref.watch(calendarRepositoryProvider)),
);
final cancelEventProvider = Provider(
  (ref) => CancelEvent(ref.watch(calendarRepositoryProvider)),
);
final deleteEventProvider = Provider(
  (ref) => DeleteEvent(ref.watch(calendarRepositoryProvider)),
);
