import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/devices_remote_data_source.dart';
import '../data/datasources/firebase_push_source.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../data/repositories/push_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/repositories/push_repository.dart';
import '../domain/usecases/get_unread_notification_count.dart';
import '../domain/usecases/notification_usecases.dart';
import '../domain/usecases/push_usecases.dart';

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

/// Whether Firebase started (`main` overrides it once it has). Off in tests
/// and when Firebase fails, which leaves the inbox without pushes.
final pushEnabledProvider = Provider<bool>((ref) => false);

final pushRepositoryProvider = Provider<PushRepository>(
  (ref) => ref.watch(pushEnabledProvider)
      ? PushRepositoryImpl(
          FirebasePushSource(),
          DevicesRemoteDataSource(ref.watch(apiClientProvider)),
        )
      : const DisabledPushRepository(),
);

final enablePushProvider = Provider(
  (ref) => EnablePush(ref.watch(pushRepositoryProvider)),
);
final disablePushProvider = Provider(
  (ref) => DisablePush(ref.watch(pushRepositoryProvider)),
);
final watchReceivedPushesProvider = Provider(
  (ref) => WatchReceivedPushes(ref.watch(pushRepositoryProvider)),
);
final watchOpenedPushesProvider = Provider(
  (ref) => WatchOpenedPushes(ref.watch(pushRepositoryProvider)),
);
final watchPushTokenRefreshProvider = Provider(
  (ref) => WatchPushTokenRefresh(ref.watch(pushRepositoryProvider)),
);
final showPushProvider = Provider(
  (ref) => ShowPush(ref.watch(pushRepositoryProvider)),
);
