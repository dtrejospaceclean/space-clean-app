import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/usecases/get_unread_notification_count.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => const NotificationsRepositoryImpl(),
);

final getUnreadNotificationCountProvider = Provider(
  (ref) =>
      GetUnreadNotificationCount(ref.watch(notificationsRepositoryProvider)),
);
