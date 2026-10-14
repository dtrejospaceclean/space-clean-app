import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../di/notifications_providers.dart';
import '../../domain/entities/app_notification.dart';

/// Unread notifications for the avatar's badge and Me's row; 0 when the
/// feature is unavailable (`UnavailableFailure`). Other failures leave it
/// in error, which also shows no badge: a count is never worth an error on
/// Today.
final unreadNotificationsProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  try {
    return await ref.watch(getUnreadNotificationCountProvider)(
      const NoParams(),
    );
  } on UnavailableFailure {
    return 0;
  }
});

/// The inbox: the latest notifications, newest first.
final notificationsProvider = FutureProvider.autoDispose<NotificationPage>(
  (ref) => ref.watch(getNotificationsProvider)(const NoParams()),
);

/// After reading one or all: the inbox and every unread count.
void invalidateNotifications(WidgetRef ref) => ref
  ..invalidate(notificationsProvider)
  ..invalidate(unreadNotificationsProvider);
