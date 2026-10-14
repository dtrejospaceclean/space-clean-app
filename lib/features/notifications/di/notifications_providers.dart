import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/usecases/get_unread_notification_count.dart';
import '../domain/usecases/notification_usecases.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(
    NotificationsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getUnreadNotificationCountProvider = Provider(
  (ref) =>
      GetUnreadNotificationCount(ref.watch(notificationsRepositoryProvider)),
);
final getNotificationsProvider = Provider(
  (ref) => GetNotifications(ref.watch(notificationsRepositoryProvider)),
);
final markNotificationReadProvider = Provider(
  (ref) => MarkNotificationRead(ref.watch(notificationsRepositoryProvider)),
);
final markAllNotificationsReadProvider = Provider(
  (ref) => MarkAllNotificationsRead(ref.watch(notificationsRepositoryProvider)),
);
