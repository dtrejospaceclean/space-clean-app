import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../di/notifications_providers.dart';

/// Unread notifications for the avatar's badge; 0 when the feature is
/// unavailable (`UnavailableFailure`). Other failures leave it in error,
/// which also shows no badge: a count is never worth an error on Today.
final unreadNotificationsProvider = FutureProvider<int>((ref) async {
  try {
    return await ref.watch(getUnreadNotificationCountProvider)(
      const NoParams(),
    );
  } on UnavailableFailure {
    return 0;
  }
});
